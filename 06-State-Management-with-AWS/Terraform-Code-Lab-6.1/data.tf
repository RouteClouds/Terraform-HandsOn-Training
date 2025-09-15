# =============================================================================
# AWS Terraform Training - Topic 6: State Management with AWS
# Data Sources for Dynamic Configuration
# =============================================================================

# =============================================================================
# AWS Account and Identity Information
# =============================================================================

# Current AWS caller identity
data "aws_caller_identity" "current" {
  # No configuration required - provides account ID, user ID, and ARN
}

# Current AWS region
data "aws_region" "current" {
  # No configuration required - provides current region name
}

# Current AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {
  # No configuration required - provides partition information
}

# =============================================================================
# Availability Zone Information
# =============================================================================

# Available availability zones in current region
data "aws_availability_zones" "available" {
  state = "available"
  
  # Exclude zones that might not support all services
  exclude_zone_ids = []
  
  # Filter for zones that support EC2 instances
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Specific availability zone information
data "aws_availability_zone" "selected" {
  count = length(var.availability_zones)
  name  = var.availability_zones[count.index]
}

# =============================================================================
# AMI Information for Demo Instances
# =============================================================================

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# =============================================================================
# IAM Policy Documents
# =============================================================================

# S3 bucket policy for state storage
data "aws_iam_policy_document" "state_bucket_policy" {
  # Deny insecure connections
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    
    actions = ["s3:*"]
    
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  
  # Allow access from current account
  statement {
    sid    = "AllowCurrentAccount"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketVersioning"
    ]
    
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
  }
  
  # Allow CloudTrail to write logs (if enabled)
  dynamic "statement" {
    for_each = var.enable_cloudtrail ? [1] : []
    
    content {
      sid    = "AllowCloudTrailLogs"
      effect = "Allow"
      
      principals {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }
      
      actions = [
        "s3:PutObject",
        "s3:GetBucketAcl"
      ]
      
      resources = [
        aws_s3_bucket.terraform_state.arn,
        "${aws_s3_bucket.terraform_state.arn}/cloudtrail-logs/*"
      ]
    }
  }
}

# IAM policy for Terraform execution
data "aws_iam_policy_document" "terraform_execution_policy" {
  # S3 state bucket access
  statement {
    sid    = "StateStorageAccess"
    effect = "Allow"
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
      "s3:ListBucketVersions",
      "s3:GetObjectVersion"
    ]
    
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
  }
  
  # DynamoDB state locking access
  statement {
    sid    = "StateLockingAccess"
    effect = "Allow"
    
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    
    resources = [
      aws_dynamodb_table.terraform_locks.arn
    ]
  }
  
  # KMS access for encryption
  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    
    resources = [
      var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].arn, "*")
    ]
  }
}

# Cross-account assume role policy
data "aws_iam_policy_document" "cross_account_assume_role" {
  count = var.assume_role_arn != null ? 1 : 0
  
  statement {
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
    
    actions = ["sts:AssumeRole"]
    
    dynamic "condition" {
      for_each = var.external_id != null ? [1] : []
      
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.external_id]
      }
    }
  }
}

# =============================================================================
# Existing Resources (for import scenarios)
# =============================================================================

# Existing VPC (if importing)
data "aws_vpc" "existing" {
  count = 0 # Set to 1 if importing existing VPC
  
  # Uncomment and modify as needed for import scenarios
  # id = "vpc-12345678"
  # 
  # tags = {
  #   Name = "existing-vpc"
  # }
}

# Existing subnets (if importing)
data "aws_subnets" "existing" {
  count = 0 # Set to 1 if importing existing subnets
  
  # Uncomment and modify as needed for import scenarios
  # filter {
  #   name   = "vpc-id"
  #   values = [data.aws_vpc.existing[0].id]
  # }
  # 
  # tags = {
  #   Type = "public"
  # }
}

# =============================================================================
# Service Information
# =============================================================================

# AWS service endpoints for current region
data "aws_service" "s3" {
  region     = data.aws_region.current.name
  service_id = "s3"
}

data "aws_service" "dynamodb" {
  region     = data.aws_region.current.name
  service_id = "dynamodb"
}

# =============================================================================
# Pricing Information (for cost estimation)
# =============================================================================

# EC2 instance type information
data "aws_ec2_instance_type" "selected" {
  count = length(var.workspace_environments[terraform.workspace].instance_types)
  
  instance_type = var.workspace_environments[terraform.workspace].instance_types[count.index]
}

# =============================================================================
# Workspace-Specific Data
# =============================================================================

# Current workspace configuration
locals {
  current_workspace_config = try(var.workspace_environments[terraform.workspace], var.workspace_environments["development"])
  
  # Derived values based on workspace
  is_production = contains(["production", "prod"], terraform.workspace)
  is_staging    = contains(["staging", "stage"], terraform.workspace)
  is_development = contains(["development", "dev"], terraform.workspace)
  
  # Environment-specific settings
  backup_required = local.is_production || local.is_staging
  monitoring_level = local.is_production ? "detailed" : local.is_staging ? "standard" : "basic"
  
  # Compliance requirements
  compliance_required = local.is_production
  audit_retention_days = local.is_production ? 2555 : local.is_staging ? 365 : 90
}

# =============================================================================
# External Data Sources (for advanced scenarios)
# =============================================================================

# External script for custom validation
data "external" "state_validation" {
  count = 0 # Enable for advanced validation scenarios
  
  program = ["python3", "${path.module}/scripts/validate_state.py"]
  
  query = {
    bucket_name = aws_s3_bucket.terraform_state.bucket
    table_name  = aws_dynamodb_table.terraform_locks.name
    region      = data.aws_region.current.name
  }
}

# =============================================================================
# Template Files
# =============================================================================

# Backend configuration template
data "template_file" "backend_config" {
  template = file("${path.module}/templates/backend.tpl")
  
  vars = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    region         = data.aws_region.current.name
    kms_key_id     = var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].key_id, "")
  }
}

# =============================================================================
# Data Source Configuration Notes:
# 
# 1. Identity and Region:
#    - Current AWS account and caller information
#    - Region and partition details for cross-region scenarios
#    - Availability zone information for multi-AZ deployments
#
# 2. AMI Selection:
#    - Latest Amazon Linux 2 and Ubuntu AMIs
#    - Filtered for availability and compatibility
#    - Owner verification for security
#
# 3. IAM Policies:
#    - State bucket access policies with security controls
#    - Terraform execution policies with least privilege
#    - Cross-account assume role policies
#
# 4. Workspace Awareness:
#    - Environment-specific configurations
#    - Compliance and monitoring requirements
#    - Cost optimization based on environment type
#
# 5. Import Support:
#    - Data sources for existing resource import
#    - Template files for configuration generation
#    - External validation scripts for advanced scenarios
# =============================================================================
