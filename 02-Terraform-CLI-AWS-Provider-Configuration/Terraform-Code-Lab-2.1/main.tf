# AWS Terraform Training - Terraform CLI & AWS Provider Configuration
# Lab 2.1: Advanced Provider Configuration and Authentication
# File: main.tf - Infrastructure Resources for Provider Testing

# ============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# ============================================================================

resource "random_id" "suffix" {
  byte_length = 4
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# ============================================================================
# STATE BACKEND INFRASTRUCTURE
# ============================================================================

# S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state" {
  count = var.create_test_resources ? 1 : 0
  
  bucket = "terraform-state-${var.student_name}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "terraform-state-bucket"
    Purpose     = "terraform-state-storage"
    Environment = "shared"
    Student     = var.student_name
    Lab         = "terraform-cli-aws-provider"
  }
}

# S3 bucket versioning for state history
resource "aws_s3_bucket_versioning" "terraform_state" {
  count = var.create_test_resources ? 1 : 0
  
  bucket = aws_s3_bucket.terraform_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption for state security
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count = var.create_test_resources && var.encryption_enabled ? 1 : 0
  
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 bucket public access block for security
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count = var.create_test_resources ? 1 : 0
  
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  count = var.create_test_resources ? 1 : 0
  
  name           = "terraform-locks-${var.student_name}-${random_id.suffix.hex}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-state-locks"
    Purpose     = "terraform-state-locking"
    Environment = "shared"
    Student     = var.student_name
    Lab         = "terraform-cli-aws-provider"
  }
}

# ============================================================================
# PRIMARY REGION TEST RESOURCES
# ============================================================================

# Test S3 bucket in primary region
resource "aws_s3_bucket" "test_primary" {
  count = var.create_test_resources ? 1 : 0
  
  bucket = "test-primary-${var.student_name}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "test-primary-bucket"
    Region      = var.aws_region
    Purpose     = "provider-testing"
    Environment = var.environment
  }
}

# CloudWatch log group for monitoring
resource "aws_cloudwatch_log_group" "provider_test" {
  count = var.create_test_resources && var.monitoring_enabled ? 1 : 0
  
  name              = "/aws/terraform-cli-lab/${var.student_name}"
  retention_in_days = 7

  tags = {
    Name        = "terraform-cli-log-group"
    Purpose     = "provider-testing"
    Environment = var.environment
    Student     = var.student_name
  }
}

# IAM role for testing assume role functionality
resource "aws_iam_role" "test_role" {
  count = var.create_test_resources ? 1 : 0
  
  name = "terraform-cli-test-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "terraform-cli-lab-${var.student_name}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "terraform-cli-test-role"
    Purpose     = "assume-role-testing"
    Environment = var.environment
    Student     = var.student_name
  }
}

# IAM policy for test role
resource "aws_iam_role_policy" "test_role_policy" {
  count = var.create_test_resources ? 1 : 0
  
  name = "terraform-cli-test-policy"
  role = aws_iam_role.test_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.test_primary[0].arn,
          "${aws_s3_bucket.test_primary[0].arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = var.monitoring_enabled ? aws_cloudwatch_log_group.provider_test[0].arn : "*"
      }
    ]
  })
}

# ============================================================================
# SECONDARY REGION TEST RESOURCES
# ============================================================================

# Test S3 bucket in secondary region
resource "aws_s3_bucket" "test_secondary" {
  count = var.create_test_resources && var.enable_multi_region ? 1 : 0
  
  provider = aws.secondary
  bucket   = "test-secondary-${var.student_name}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "test-secondary-bucket"
    Region      = var.secondary_region
    Purpose     = "multi-region-testing"
    Environment = var.environment
  }
}

# CloudWatch log group in secondary region
resource "aws_cloudwatch_log_group" "provider_test_secondary" {
  count = var.create_test_resources && var.enable_multi_region && var.monitoring_enabled ? 1 : 0
  
  provider          = aws.secondary
  name              = "/aws/terraform-cli-lab-secondary/${var.student_name}"
  retention_in_days = 7

  tags = {
    Name        = "terraform-cli-log-group-secondary"
    Purpose     = "multi-region-testing"
    Environment = var.environment
    Student     = var.student_name
    Region      = var.secondary_region
  }
}

# ============================================================================
# DISASTER RECOVERY REGION RESOURCES
# ============================================================================

# Backup S3 bucket in disaster recovery region
resource "aws_s3_bucket" "backup_dr" {
  count = var.create_test_resources && var.enable_multi_region ? 1 : 0
  
  provider = aws.disaster_recovery
  bucket   = "backup-dr-${var.student_name}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "backup-disaster-recovery-bucket"
    Region      = var.disaster_recovery_region
    Purpose     = "disaster-recovery"
    Environment = var.environment
  }
}

# ============================================================================
# PROVIDER VALIDATION RESOURCES
# ============================================================================

# Test file to validate local provider
resource "local_file" "provider_test" {
  count = var.create_test_resources && var.enable_provider_validation ? 1 : 0
  
  filename = "${path.module}/provider-test-${random_id.suffix.hex}.txt"
  content = templatefile("${path.module}/templates/provider-test.tpl", {
    student_name     = var.student_name
    environment      = var.environment
    aws_region       = var.aws_region
    secondary_region = var.secondary_region
    timestamp        = timestamp()
    workspace        = terraform.workspace
    auth_method      = var.auth_method
    aws_profile      = var.aws_profile
  })
}

# TLS private key for testing TLS provider
resource "tls_private_key" "test_key" {
  count = var.create_test_resources && var.enable_provider_validation ? 1 : 0
  
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Archive file for testing archive provider
data "archive_file" "test_archive" {
  count = var.create_test_resources && var.enable_provider_validation ? 1 : 0
  
  type        = "zip"
  output_path = "${path.module}/test-archive-${random_id.suffix.hex}.zip"
  
  source {
    content  = "This is a test file for archive provider validation."
    filename = "test.txt"
  }
  
  source {
    content = jsonencode({
      student_name = var.student_name
      environment  = var.environment
      timestamp    = timestamp()
      lab          = "terraform-cli-aws-provider"
    })
    filename = "metadata.json"
  }
}

# ============================================================================
# AUTHENTICATION TESTING RESOURCES
# ============================================================================

# S3 object to test authentication and permissions
resource "aws_s3_object" "auth_test" {
  count = var.create_test_resources && var.enable_authentication_test ? 1 : 0
  
  bucket = aws_s3_bucket.test_primary[0].bucket
  key    = "auth-test/test-object-${random_id.suffix.hex}.json"
  
  content = jsonencode({
    test_type        = "authentication-validation"
    student_name     = var.student_name
    environment      = var.environment
    aws_account_id   = data.aws_caller_identity.current.account_id
    aws_user_id      = data.aws_caller_identity.current.user_id
    aws_arn          = data.aws_caller_identity.current.arn
    aws_region       = data.aws_region.current.name
    terraform_workspace = terraform.workspace
    auth_method      = var.auth_method
    aws_profile      = var.aws_profile
    timestamp        = timestamp()
  })

  tags = {
    Name        = "auth-test-object"
    Purpose     = "authentication-testing"
    Environment = var.environment
    Student     = var.student_name
  }
}

# ============================================================================
# COST OPTIMIZATION RESOURCES
# ============================================================================

# Lambda function for auto-shutdown (if enabled)
resource "aws_lambda_function" "auto_shutdown" {
  count = var.create_test_resources && var.auto_shutdown_enabled ? 1 : 0
  
  filename         = data.archive_file.lambda_zip[0].output_path
  function_name    = "terraform-cli-auto-shutdown-${random_id.suffix.hex}"
  role            = aws_iam_role.lambda_role[0].arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 60
  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256

  environment {
    variables = {
      STUDENT_NAME = var.student_name
      ENVIRONMENT  = var.environment
      REGION       = var.aws_region
    }
  }

  tags = {
    Name        = "terraform-cli-auto-shutdown"
    Purpose     = "cost-optimization"
    Environment = var.environment
    Student     = var.student_name
  }
}

# Lambda IAM role
resource "aws_iam_role" "lambda_role" {
  count = var.create_test_resources && var.auto_shutdown_enabled ? 1 : 0
  
  name = "terraform-cli-lambda-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "terraform-cli-lambda-role"
  }
}

# Lambda function code
data "archive_file" "lambda_zip" {
  count = var.create_test_resources && var.auto_shutdown_enabled ? 1 : 0
  
  type        = "zip"
  output_path = "${path.module}/auto_shutdown.zip"
  
  source {
    content = templatefile("${path.module}/scripts/auto_shutdown.py", {
      student_name = var.student_name
      environment  = var.environment
    })
    filename = "index.py"
  }
}
