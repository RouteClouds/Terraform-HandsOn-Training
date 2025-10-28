# State Backend Infrastructure
# This creates the S3 bucket and DynamoDB table for Terraform state management

terraform {
  required_version = ">= 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Multi-Environment-Pipeline"
      ManagedBy   = "Terraform"
      Environment = "state-backend"
      Purpose     = "State Management"
    }
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Local values
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  
  # State bucket name
  state_bucket_name = "terraform-state-${local.account_id}-${local.region}"
  
  # Environments
  environments = ["dev", "staging", "prod"]
  
  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = local.state_bucket_name
  
  tags = merge(local.common_tags, {
    Name        = local.state_bucket_name
    Description = "Terraform state storage for all environments"
  })
}

# Enable versioning for state bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for old versions
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  
  rule {
    id     = "delete-old-delete-markers"
    status = "Enabled"
    
    expiration {
      expired_object_delete_marker = true
    }
  }
}

# DynamoDB Tables for State Locking (one per environment)
resource "aws_dynamodb_table" "terraform_locks" {
  for_each = toset(local.environments)
  
  name         = "terraform-locks-${each.key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  tags = merge(local.common_tags, {
    Name        = "terraform-locks-${each.key}"
    Environment = each.key
    Description = "Terraform state locking for ${each.key} environment"
  })
}

# S3 Bucket for State Backups
resource "aws_s3_bucket" "state_backups" {
  bucket = "${local.state_bucket_name}-backups"
  
  tags = merge(local.common_tags, {
    Name        = "${local.state_bucket_name}-backups"
    Description = "Terraform state backups"
  })
}

# Enable versioning for backup bucket
resource "aws_s3_bucket_versioning" "state_backups" {
  bucket = aws_s3_bucket.state_backups.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for backup bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "state_backups" {
  bucket = aws_s3_bucket.state_backups.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for backup bucket
resource "aws_s3_bucket_public_access_block" "state_backups" {
  bucket = aws_s3_bucket.state_backups.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for backups
resource "aws_s3_bucket_lifecycle_configuration" "state_backups" {
  bucket = aws_s3_bucket.state_backups.id
  
  rule {
    id     = "expire-old-backups"
    status = "Enabled"
    
    expiration {
      days = 30
    }
  }
}

# CloudWatch Log Group for state changes
resource "aws_cloudwatch_log_group" "state_changes" {
  name              = "/terraform/state-changes"
  retention_in_days = 30
  
  tags = merge(local.common_tags, {
    Name        = "terraform-state-changes"
    Description = "Logs for Terraform state changes"
  })
}

# SNS Topic for state change notifications
resource "aws_sns_topic" "state_notifications" {
  name = "terraform-state-notifications"
  
  tags = merge(local.common_tags, {
    Name        = "terraform-state-notifications"
    Description = "Notifications for Terraform state changes"
  })
}

# SNS Topic Subscription (email)
resource "aws_sns_topic_subscription" "state_notifications_email" {
  count = var.notification_email != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.state_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# S3 Bucket Notification for state changes
resource "aws_s3_bucket_notification" "state_changes" {
  bucket = aws_s3_bucket.terraform_state.id
  
  topic {
    topic_arn = aws_sns_topic.state_notifications.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    
    filter_suffix = ".tfstate"
  }
  
  depends_on = [aws_sns_topic_policy.state_notifications]
}

# SNS Topic Policy to allow S3 to publish
resource "aws_sns_topic_policy" "state_notifications" {
  arn = aws_sns_topic.state_notifications.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.state_notifications.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.terraform_state.arn
          }
        }
      }
    ]
  })
}

