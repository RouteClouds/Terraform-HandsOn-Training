# AWS Terraform Training - Topic 2: Terraform CLI & AWS Provider Configuration
# Terraform Code Lab 2.1 - Main Infrastructure Configuration
#
# This file demonstrates practical implementation of Terraform CLI and AWS Provider
# configuration through real infrastructure deployment examples.
#
# Learning Objectives:
# 1. Practical application of provider configuration
# 2. Resource creation with proper tagging and security
# 3. Multi-provider resource management
# 4. Enterprise-grade infrastructure patterns

# =============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# =============================================================================

locals {
  # Common naming prefix for resource consistency
  name_prefix = "${var.environment}-${var.project_name}"
  
  # Current timestamp for resource tracking
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  
  # Environment-specific configuration
  env_config = var.environment_config[var.environment]
  
  # Comprehensive resource tags
  common_tags = merge(
    {
      Environment        = var.environment
      Project           = var.project_name
      ManagedBy         = "terraform"
      Owner             = var.owner
      CostCenter        = var.cost_center
      CreatedDate       = formatdate("YYYY-MM-DD", timestamp())
      LastModified      = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
      TrainingTopic     = "terraform-cli-aws-provider-configuration"
      DataClassification = var.data_classification
      BackupRequired    = var.enable_backup ? "true" : "false"
      MonitoringEnabled = var.enable_detailed_monitoring ? "true" : "false"
      ComplianceScope   = join(",", var.compliance_requirements)
    },
    var.cost_allocation_tags
  )
  
  # Security configuration
  security_config = {
    encryption_at_rest    = var.encryption_at_rest
    encryption_in_transit = var.encryption_in_transit
    enable_logging       = var.feature_flags.enable_logging
    enable_monitoring    = var.feature_flags.enable_metrics
  }
}

# =============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# =============================================================================

resource "random_id" "bucket_suffix" {
  byte_length = 4
  
  keepers = {
    environment = var.environment
    project     = var.project_name
  }
}

resource "random_password" "example_password" {
  length  = 16
  special = true
  
  keepers = {
    environment = var.environment
  }
}

# =============================================================================
# S3 BUCKET FOR TERRAFORM STATE AND ARTIFACTS
# =============================================================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.name_prefix}-terraform-state-${random_id.bucket_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-terraform-state"
    Purpose     = "Terraform state storage"
    Component   = "infrastructure"
    Criticality = "high"
  })
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "terraform_state_lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.backup_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# =============================================================================
# DYNAMODB TABLE FOR STATE LOCKING
# =============================================================================

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${local.name_prefix}-terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = var.encryption_at_rest
  }

  point_in_time_recovery {
    enabled = var.enable_backup
  }

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-terraform-state-lock"
    Purpose     = "Terraform state locking"
    Component   = "infrastructure"
    Criticality = "high"
  })
}

# =============================================================================
# IAM ROLE FOR TERRAFORM EXECUTION
# =============================================================================

resource "aws_iam_role" "terraform_execution" {
  name = "${local.name_prefix}-terraform-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-terraform-execution-role"
    Purpose   = "Terraform execution permissions"
    Component = "security"
  })
}

resource "aws_iam_role_policy" "terraform_execution" {
  name = "${local.name_prefix}-terraform-execution-policy"
  role = aws_iam_role.terraform_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_state_lock.arn
      }
    ]
  })
}

# =============================================================================
# CLOUDWATCH LOG GROUP FOR TERRAFORM OPERATIONS
# =============================================================================

resource "aws_cloudwatch_log_group" "terraform_operations" {
  count = var.feature_flags.enable_logging ? 1 : 0
  
  name              = "/aws/terraform/${local.name_prefix}"
  retention_in_days = var.backup_retention_days

  kms_key_id = var.encryption_at_rest ? aws_kms_key.terraform_key[0].arn : null

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-terraform-operations"
    Purpose   = "Terraform operation logging"
    Component = "monitoring"
  })
}

# =============================================================================
# KMS KEY FOR ENCRYPTION
# =============================================================================

resource "aws_kms_key" "terraform_key" {
  count = var.encryption_at_rest ? 1 : 0
  
  description             = "KMS key for ${local.name_prefix} Terraform resources"
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
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-terraform-key"
    Purpose   = "Terraform resource encryption"
    Component = "security"
  })
}

resource "aws_kms_alias" "terraform_key" {
  count = var.encryption_at_rest ? 1 : 0
  
  name          = "alias/${local.name_prefix}-terraform-key"
  target_key_id = aws_kms_key.terraform_key[0].key_id
}

# =============================================================================
# BUDGET FOR COST CONTROL
# =============================================================================

resource "aws_budgets_budget" "terraform_budget" {
  name         = "${local.name_prefix}-terraform-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_limit)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  time_period_start = formatdate("YYYY-MM-01_00:00", timestamp())

  cost_filters = {
    TagKey = ["Project"]
    TagValue = [var.project_name]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = ["${var.owner}@example.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["${var.owner}@example.com"]
  }

  depends_on = [aws_s3_bucket.terraform_state]
}

# =============================================================================
# PROVIDER VALIDATION RESOURCES
# =============================================================================

# Test resource creation with default provider
resource "aws_s3_bucket" "provider_test_default" {
  bucket = "${local.name_prefix}-provider-test-default-${random_id.bucket_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-provider-test-default"
    Purpose  = "Provider configuration validation"
    Provider = "default"
  })
}

# Test resource creation with development provider
resource "aws_s3_bucket" "provider_test_dev" {
  provider = aws.development
  bucket   = "${local.name_prefix}-provider-test-dev-${random_id.bucket_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-provider-test-dev"
    Purpose  = "Provider configuration validation"
    Provider = "development"
  })
}

# =============================================================================
# MULTI-REGION RESOURCE EXAMPLE
# =============================================================================

resource "aws_s3_bucket" "multi_region_test" {
  provider = aws.us_west_2
  bucket   = "${local.name_prefix}-multi-region-${random_id.bucket_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-multi-region"
    Purpose  = "Multi-region provider validation"
    Provider = "us-west-2"
    Region   = "us-west-2"
  })
}
