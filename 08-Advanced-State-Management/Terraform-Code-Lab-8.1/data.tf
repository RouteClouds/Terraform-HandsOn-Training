# ============================================================================
# DATA SOURCES
# Topic 8: Advanced State Management with AWS
# ============================================================================

# ============================================================================
# AWS ACCOUNT AND IDENTITY INFORMATION
# ============================================================================

# Get current AWS account information
data "aws_caller_identity" "current" {
  provider = aws.primary
}

# Get current AWS region information
data "aws_region" "primary" {
  provider = aws.primary
}

# Get disaster recovery region information
data "aws_region" "dr" {
  provider = aws.disaster_recovery
}

# Get monitoring region information
data "aws_region" "monitoring" {
  provider = aws.monitoring
}

# Get current AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {
  provider = aws.primary
}

# ============================================================================
# AVAILABILITY ZONES
# ============================================================================

# Get available availability zones in primary region
data "aws_availability_zones" "primary" {
  provider = aws.primary
  
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Get available availability zones in DR region
data "aws_availability_zones" "dr" {
  provider = aws.disaster_recovery
  
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# ============================================================================
# IAM POLICY DOCUMENTS
# ============================================================================

# S3 bucket policy for state bucket security
data "aws_iam_policy_document" "state_bucket_policy" {
  # Deny unencrypted object uploads
  statement {
    sid    = "DenyUnencryptedObjectUploads"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    
    actions = ["s3:PutObject"]
    
    resources = [
      "${aws_s3_bucket.terraform_state_primary.arn}/*"
    ]
    
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
  
  # Deny requests that do not use HTTPS
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    
    actions = ["s3:*"]
    
    resources = [
      aws_s3_bucket.terraform_state_primary.arn,
      "${aws_s3_bucket.terraform_state_primary.arn}/*"
    ]
    
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  
  # Allow access only from specific IP ranges (if configured)
  dynamic "statement" {
    for_each = var.enable_advanced_security ? [1] : []
    
    content {
      sid    = "RestrictToSpecificIPs"
      effect = "Deny"
      
      principals {
        type        = "*"
        identifiers = ["*"]
      }
      
      actions = ["s3:*"]
      
      resources = [
        aws_s3_bucket.terraform_state_primary.arn,
        "${aws_s3_bucket.terraform_state_primary.arn}/*"
      ]
      
      condition {
        test     = "NotIpAddress"
        variable = "aws:SourceIp"
        values   = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      }
    }
  }
}

# IAM policy for limited state access
data "aws_iam_policy_document" "limited_state_access" {
  # Allow read access to state bucket
  statement {
    sid    = "AllowStateRead"
    effect = "Allow"
    
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]
    
    resources = [
      aws_s3_bucket.terraform_state_primary.arn,
      "${aws_s3_bucket.terraform_state_primary.arn}/*"
    ]
  }
  
  # Allow DynamoDB lock operations
  statement {
    sid    = "AllowLockOperations"
    effect = "Allow"
    
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    
    resources = [
      aws_dynamodb_table.terraform_locks_primary.arn
    ]
  }
  
  # Allow KMS operations for decryption
  statement {
    sid    = "AllowKMSDecryption"
    effect = "Allow"
    
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    
    resources = [
      aws_kms_key.terraform_state_primary.arn
    ]
  }
}

# IAM policy for full state management access
data "aws_iam_policy_document" "full_state_access" {
  # Allow full access to state bucket
  statement {
    sid    = "AllowFullStateAccess"
    effect = "Allow"
    
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]
    
    resources = [
      aws_s3_bucket.terraform_state_primary.arn,
      "${aws_s3_bucket.terraform_state_primary.arn}/*"
    ]
  }
  
  # Allow full DynamoDB lock operations
  statement {
    sid    = "AllowFullLockOperations"
    effect = "Allow"
    
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    
    resources = [
      aws_dynamodb_table.terraform_locks_primary.arn
    ]
  }
  
  # Allow full KMS operations
  statement {
    sid    = "AllowFullKMSAccess"
    effect = "Allow"
    
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    
    resources = [
      aws_kms_key.terraform_state_primary.arn
    ]
  }
}

# ============================================================================
# EXISTING RESOURCES VALIDATION
# ============================================================================

# Check if S3 bucket name is available
data "aws_s3_bucket" "existing_state_bucket" {
  provider = aws.primary
  count    = 0  # Disabled by default, enable for validation
  
  bucket = local.primary_bucket_name
}

# Check if DynamoDB table name is available
data "aws_dynamodb_table" "existing_lock_table" {
  provider = aws.primary
  count    = 0  # Disabled by default, enable for validation
  
  name = local.primary_table_name
}

# ============================================================================
# AWS SERVICES AVAILABILITY
# ============================================================================

# Check S3 service availability in primary region
data "aws_service" "s3_primary" {
  provider = aws.primary
  
  service_id = "s3"
  region     = var.aws_region
}

# Check DynamoDB service availability in primary region
data "aws_service" "dynamodb_primary" {
  provider = aws.primary
  
  service_id = "dynamodb"
  region     = var.aws_region
}

# Check KMS service availability in primary region
data "aws_service" "kms_primary" {
  provider = aws.primary
  
  service_id = "kms"
  region     = var.aws_region
}

# ============================================================================
# COST AND BILLING INFORMATION
# ============================================================================

# Get current AWS pricing for S3 in primary region
data "aws_pricing_product" "s3_pricing" {
  provider = aws.primary
  
  service_code = "AmazonS3"
  
  filters {
    field = "location"
    value = data.aws_region.primary.description
  }
  
  filters {
    field = "storageClass"
    value = "General Purpose"
  }
}

# Get current AWS pricing for DynamoDB in primary region
data "aws_pricing_product" "dynamodb_pricing" {
  provider = aws.primary
  
  service_code = "AmazonDynamoDB"
  
  filters {
    field = "location"
    value = data.aws_region.primary.description
  }
  
  filters {
    field = "group"
    value = "DDB-Operation-Requests"
  }
}

# ============================================================================
# SECURITY AND COMPLIANCE INFORMATION
# ============================================================================

# Get current AWS account password policy
data "aws_iam_account_password_policy" "current" {
  provider = aws.primary
}

# Get current AWS account summary
data "aws_iam_account_summary" "current" {
  provider = aws.primary
}

# ============================================================================
# NETWORK AND CONNECTIVITY
# ============================================================================

# Get default VPC in primary region
data "aws_vpc" "default_primary" {
  provider = aws.primary
  
  default = true
}

# Get default VPC in DR region
data "aws_vpc" "default_dr" {
  provider = aws.disaster_recovery
  
  default = true
}

# Get VPC endpoints for S3 in primary region (if advanced security is enabled)
data "aws_vpc_endpoint_service" "s3_primary" {
  provider = aws.primary
  count    = var.enable_advanced_security ? 1 : 0
  
  service = "s3"
}

# Get VPC endpoints for DynamoDB in primary region (if advanced security is enabled)
data "aws_vpc_endpoint_service" "dynamodb_primary" {
  provider = aws.primary
  count    = var.enable_advanced_security ? 1 : 0
  
  service = "dynamodb"
}

# ============================================================================
# MONITORING AND LOGGING
# ============================================================================

# Get existing CloudWatch log groups for state management
data "aws_cloudwatch_log_groups" "state_management" {
  provider = aws.monitoring
  
  log_group_name_prefix = "/aws/terraform/state"
}

# Get existing SNS topics for notifications
data "aws_sns_topics" "existing" {
  provider = aws.monitoring
  
  name_contains = "terraform"
}

# ============================================================================
# BACKUP AND RECOVERY
# ============================================================================

# Get existing backup vaults in primary region
data "aws_backup_vault" "existing_primary" {
  provider = aws.primary
  count    = 0  # Disabled by default
  
  name = "terraform-state-backup"
}

# Get existing backup vaults in DR region
data "aws_backup_vault" "existing_dr" {
  provider = aws.disaster_recovery
  count    = 0  # Disabled by default
  
  name = "terraform-state-backup-dr"
}

# ============================================================================
# VALIDATION DATA SOURCES
# ============================================================================

# Validate current Terraform version
data "external" "terraform_version" {
  program = ["bash", "-c", "terraform version -json | jq -r '{version: .terraform_version}'"]
}

# Validate AWS CLI version
data "external" "aws_cli_version" {
  program = ["bash", "-c", "aws --version 2>&1 | head -1 | awk '{print $1}' | cut -d'/' -f2 | jq -R '{version: .}'"]
}

# ============================================================================
# COMPUTED DATA VALUES
# ============================================================================

# Local values for data processing
locals {
  # Account information
  account_id = data.aws_caller_identity.current.account_id
  user_id    = data.aws_caller_identity.current.user_id
  arn        = data.aws_caller_identity.current.arn
  
  # Region information
  primary_region_name = data.aws_region.primary.name
  dr_region_name      = data.aws_region.dr.name
  
  # Availability zones
  primary_azs = data.aws_availability_zones.primary.names
  dr_azs      = data.aws_availability_zones.dr.names
  
  # Service availability
  services_available = {
    s3       = length(data.aws_service.s3_primary.supported_regions) > 0
    dynamodb = length(data.aws_service.dynamodb_primary.supported_regions) > 0
    kms      = length(data.aws_service.kms_primary.supported_regions) > 0
  }
  
  # Network information
  default_vpc_primary = try(data.aws_vpc.default_primary.id, null)
  default_vpc_dr      = try(data.aws_vpc.default_dr.id, null)
  
  # Validation results
  terraform_version_valid = can(regex("^1\\.13\\.", try(data.external.terraform_version.result.version, "")))
  aws_cli_available      = try(data.external.aws_cli_version.result.version, "") != ""
}
