# =============================================================================
# AWS Terraform Training - Topic 6: State Management with AWS
# Main Infrastructure Configuration
# =============================================================================

# Random ID for unique resource naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Random password for demonstration purposes
resource "random_password" "demo_password" {
  length  = 16
  special = true
}

# =============================================================================
# State Backend Infrastructure
# =============================================================================

# S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-state-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "Terraform State Bucket"
    Purpose     = "state-storage"
    Environment = var.environment
    Backup      = "required"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

# S3 bucket versioning for state history
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = var.enable_state_versioning ? "Enabled" : "Suspended"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "state_file_lifecycle"
    status = "Enabled"
    
    noncurrent_version_expiration {
      noncurrent_days = var.state_version_retention * 30
    }
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_id
  }
  
  tags = {
    Name        = "Terraform State Locks"
    Purpose     = "state-locking"
    Environment = var.environment
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

# =============================================================================
# KMS Key for State Encryption (Optional)
# =============================================================================

resource "aws_kms_key" "terraform_state" {
  count = var.kms_key_id == null ? 1 : 0
  
  description             = "KMS key for Terraform state encryption"
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
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name        = "Terraform State KMS Key"
    Purpose     = "state-encryption"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "terraform_state" {
  count = var.kms_key_id == null ? 1 : 0
  
  name          = "alias/${var.project_name}-terraform-state"
  target_key_id = aws_kms_key.terraform_state[0].key_id
}

# =============================================================================
# Backup Region Resources (Optional)
# =============================================================================

# S3 bucket in backup region for cross-region replication
resource "aws_s3_bucket" "terraform_state_backup" {
  count = var.enable_backup_region_resources ? 1 : 0
  
  provider = aws.backup_region
  bucket   = "${var.project_name}-state-backup-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "Terraform State Backup Bucket"
    Purpose     = "state-backup"
    Environment = var.environment
    Region      = "backup"
  }
}

# Cross-region replication configuration
resource "aws_s3_bucket_replication_configuration" "terraform_state" {
  count = var.enable_cross_region_replication ? 1 : 0
  
  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "state_replication"
    status = "Enabled"
    
    destination {
      bucket        = aws_s3_bucket.terraform_state_backup[0].arn
      storage_class = "STANDARD_IA"
      
      encryption_configuration {
        replica_kms_key_id = var.kms_key_id
      }
    }
  }
  
  depends_on = [aws_s3_bucket_versioning.terraform_state]
}

# IAM role for S3 replication
resource "aws_iam_role" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0
  
  name = "${var.project_name}-s3-replication-role"
  
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
}

# =============================================================================
# Demo Infrastructure for State Management Testing
# =============================================================================

# VPC for demo infrastructure
resource "aws_vpc" "demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.project_name}-demo-vpc"
    Purpose     = "state-management-demo"
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

# Internet Gateway
resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id
  
  tags = {
    Name        = "${var.project_name}-demo-igw"
    Purpose     = "internet-access"
    Environment = var.environment
  }
}

# Public subnets for demo
resource "aws_subnet" "public" {
  count = min(length(var.availability_zones), 3)
  
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Type        = "public"
    Environment = var.environment
    AZ          = var.availability_zones[count.index]
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
  
  tags = {
    Name        = "${var.project_name}-public-rt"
    Type        = "public"
    Environment = var.environment
  }
}

# Route table associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security group for demo instances
resource "aws_security_group" "demo" {
  name_prefix = "${var.project_name}-demo-"
  vpc_id      = aws_vpc.demo.id
  description = "Security group for state management demo"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "SSH access from private networks"
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = {
    Name        = "${var.project_name}-demo-sg"
    Purpose     = "demo-security"
    Environment = var.environment
  }
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# Time-based resources for demonstration
# =============================================================================

resource "time_static" "deployment_time" {}

resource "time_rotating" "monthly_rotation" {
  rotation_days = 30
}

# =============================================================================
# Configuration Notes:
# 
# 1. State Backend Setup:
#    - S3 bucket with versioning and encryption
#    - DynamoDB table for state locking
#    - Cross-region backup capabilities
#    - Lifecycle policies for cost optimization
#
# 2. Security Features:
#    - KMS encryption for state files
#    - Public access blocking for S3
#    - IAM roles with least privilege
#    - Security groups with minimal access
#
# 3. High Availability:
#    - Multi-AZ deployment support
#    - Cross-region replication options
#    - Point-in-time recovery for DynamoDB
#    - Backup and disaster recovery ready
#
# 4. Cost Optimization:
#    - Lifecycle policies for old versions
#    - Pay-per-request DynamoDB billing
#    - Standard-IA storage for backups
#    - Resource tagging for cost allocation
# =============================================================================
