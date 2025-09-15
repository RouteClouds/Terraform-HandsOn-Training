# ============================================================================
# MAIN INFRASTRUCTURE CONFIGURATION
# Topic 8: Advanced State Management with AWS
# ============================================================================

# ============================================================================
# RANDOM RESOURCE GENERATION
# ============================================================================

# Generate random suffix for unique resource naming
resource "random_id" "bucket_suffix" {
  byte_length = var.random_suffix_length / 2
  
  keepers = {
    organization = var.organization
    project      = var.project_name
    environment  = var.environment
  }
}

# Generate random password for additional security
resource "random_password" "state_access_key" {
  length  = 32
  special = true
  
  keepers = {
    organization = var.organization
    project      = var.project_name
  }
}

# ============================================================================
# KMS KEY MANAGEMENT
# ============================================================================

# Primary KMS key for state encryption
resource "aws_kms_key" "terraform_state_primary" {
  provider = aws.primary
  
  description             = "KMS key for Terraform state encryption in ${var.aws_region}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Terraform State Access"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name        = "${local.resource_prefix}-terraform-state-key-primary"
    Purpose     = "terraform-state-encryption"
    Region      = var.aws_region
    KeyRotation = "enabled"
  })
}

# KMS key alias for easier reference
resource "aws_kms_alias" "terraform_state_primary" {
  provider = aws.primary
  
  name          = "alias/${local.resource_prefix}-terraform-state-primary"
  target_key_id = aws_kms_key.terraform_state_primary.key_id
}

# Disaster recovery KMS key
resource "aws_kms_key" "terraform_state_dr" {
  provider = aws.disaster_recovery
  
  description             = "KMS key for Terraform state encryption in ${var.dr_region} (DR)"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Terraform State Access"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name        = "${local.resource_prefix}-terraform-state-key-dr"
    Purpose     = "terraform-state-encryption-dr"
    Region      = var.dr_region
    KeyRotation = "enabled"
  })
}

# DR KMS key alias
resource "aws_kms_alias" "terraform_state_dr" {
  provider = aws.disaster_recovery
  
  name          = "alias/${local.resource_prefix}-terraform-state-dr"
  target_key_id = aws_kms_key.terraform_state_dr.key_id
}

# ============================================================================
# S3 BUCKET FOR STATE STORAGE (PRIMARY)
# ============================================================================

# Primary state bucket
resource "aws_s3_bucket" "terraform_state_primary" {
  provider = aws.primary
  
  bucket        = "${var.state_bucket_prefix}-${var.organization}-${random_id.bucket_suffix.hex}"
  force_destroy = false

  tags = merge(local.common_tags, {
    Name                = "${local.resource_prefix}-terraform-state-primary"
    Purpose             = "terraform-state-storage"
    Region              = var.aws_region
    DataClassification  = var.data_classification
    BackupRequired      = "true"
    ReplicationEnabled  = var.enable_cross_region_replication ? "true" : "false"
  })
}

# Bucket versioning configuration
resource "aws_s3_bucket_versioning" "terraform_state_primary" {
  provider = aws.primary
  
  bucket = aws_s3_bucket.terraform_state_primary.id
  
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
    
    dynamic "mfa_delete" {
      for_each = var.enable_mfa_delete ? [1] : []
      content {
        status = "Enabled"
      }
    }
  }
}

# Bucket encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_primary" {
  provider = aws.primary
  
  bucket = aws_s3_bucket.terraform_state_primary.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_primary.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state_primary" {
  provider = aws.primary
  
  bucket = aws_s3_bucket.terraform_state_primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_primary" {
  provider = aws.primary
  
  bucket = aws_s3_bucket.terraform_state_primary.id

  rule {
    id     = "terraform-state-lifecycle"
    status = "Enabled"

    # Transition old versions to IA after 30 days
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    # Transition old versions to Glacier after 90 days
    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    # Delete old versions after retention period
    noncurrent_version_expiration {
      noncurrent_days = var.versioning_retention_days
    }

    # Abort incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Intelligent tiering for cost optimization
  dynamic "rule" {
    for_each = var.enable_cost_optimization ? [1] : []
    content {
      id     = "intelligent-tiering"
      status = "Enabled"

      transition {
        days          = 0
        storage_class = "INTELLIGENT_TIERING"
      }
    }
  }
}

# ============================================================================
# S3 BUCKET FOR STATE STORAGE (DISASTER RECOVERY)
# ============================================================================

# Disaster recovery state bucket
resource "aws_s3_bucket" "terraform_state_dr" {
  provider = aws.disaster_recovery
  
  bucket        = "${var.state_bucket_prefix}-${var.organization}-dr-${random_id.bucket_suffix.hex}"
  force_destroy = false

  tags = merge(local.common_tags, {
    Name               = "${local.resource_prefix}-terraform-state-dr"
    Purpose            = "terraform-state-storage-dr"
    Region             = var.dr_region
    DataClassification = var.data_classification
    BackupRequired     = "true"
    ReplicationTarget  = "true"
  })
}

# DR bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state_dr" {
  provider = aws.disaster_recovery
  
  bucket = aws_s3_bucket.terraform_state_dr.id
  
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# DR bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_dr" {
  provider = aws.disaster_recovery
  
  bucket = aws_s3_bucket.terraform_state_dr.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_dr.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# DR bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state_dr" {
  provider = aws.disaster_recovery
  
  bucket = aws_s3_bucket.terraform_state_dr.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# CROSS-REGION REPLICATION
# ============================================================================

# IAM role for cross-region replication
resource "aws_iam_role" "replication" {
  provider = aws.primary
  count    = var.enable_cross_region_replication ? 1 : 0
  
  name = "${local.resource_prefix}-terraform-state-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-terraform-state-replication-role"
    Purpose = "s3-cross-region-replication"
  })
}

# IAM policy for replication role
resource "aws_iam_role_policy" "replication" {
  provider = aws.primary
  count    = var.enable_cross_region_replication ? 1 : 0
  
  name = "${local.resource_prefix}-terraform-state-replication-policy"
  role = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.terraform_state_primary.arn}/*"
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = aws_s3_bucket.terraform_state_primary.arn
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.terraform_state_dr.arn}/*"
      },
      {
        Action = [
          "kms:Decrypt"
        ]
        Effect = "Allow"
        Resource = aws_kms_key.terraform_state_primary.arn
      },
      {
        Action = [
          "kms:GenerateDataKey"
        ]
        Effect = "Allow"
        Resource = aws_kms_key.terraform_state_dr.arn
      }
    ]
  })
}

# Cross-region replication configuration
resource "aws_s3_bucket_replication_configuration" "terraform_state_replication" {
  provider   = aws.primary
  count      = var.enable_cross_region_replication ? 1 : 0
  depends_on = [aws_s3_bucket_versioning.terraform_state_primary]

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.terraform_state_primary.id

  rule {
    id     = "terraform-state-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.terraform_state_dr.arn
      storage_class = var.replication_storage_class

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.terraform_state_dr.arn
      }
    }
  }
}

# ============================================================================
# DYNAMODB TABLES FOR STATE LOCKING
# ============================================================================

# Primary DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks_primary" {
  provider = aws.primary

  name           = "${local.resource_prefix}-terraform-locks"
  billing_mode   = var.lock_table_billing_mode
  hash_key       = "LockID"

  # Conditional capacity configuration for PROVISIONED billing mode
  dynamic "read_capacity" {
    for_each = var.lock_table_billing_mode == "PROVISIONED" ? [1] : []
    content {
      read_capacity = var.lock_table_read_capacity
    }
  }

  dynamic "write_capacity" {
    for_each = var.lock_table_billing_mode == "PROVISIONED" ? [1] : []
    content {
      write_capacity = var.lock_table_write_capacity
    }
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Server-side encryption
  server_side_encryption {
    enabled     = true
    kms_key_id  = aws_kms_key.terraform_state_primary.arn
  }

  tags = merge(local.common_tags, {
    Name               = "${local.resource_prefix}-terraform-locks"
    Purpose            = "terraform-state-locking"
    Region             = var.aws_region
    BillingMode        = var.lock_table_billing_mode
    PointInTimeRecovery = var.enable_point_in_time_recovery ? "enabled" : "disabled"
  })
}

# Disaster recovery DynamoDB table
resource "aws_dynamodb_table" "terraform_locks_dr" {
  provider = aws.disaster_recovery

  name           = "${local.resource_prefix}-terraform-locks-dr"
  billing_mode   = var.lock_table_billing_mode
  hash_key       = "LockID"

  # Conditional capacity configuration for PROVISIONED billing mode
  dynamic "read_capacity" {
    for_each = var.lock_table_billing_mode == "PROVISIONED" ? [1] : []
    content {
      read_capacity = var.lock_table_read_capacity
    }
  }

  dynamic "write_capacity" {
    for_each = var.lock_table_billing_mode == "PROVISIONED" ? [1] : []
    content {
      write_capacity = var.lock_table_write_capacity
    }
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled     = true
    kms_key_id  = aws_kms_key.terraform_state_dr.arn
  }

  tags = merge(local.common_tags, {
    Name               = "${local.resource_prefix}-terraform-locks-dr"
    Purpose            = "terraform-state-locking-dr"
    Region             = var.dr_region
    BillingMode        = var.lock_table_billing_mode
    PointInTimeRecovery = var.enable_point_in_time_recovery ? "enabled" : "disabled"
  })
}
