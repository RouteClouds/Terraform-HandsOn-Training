# Lab 6: State Management & Backends

## 🎯 **Lab Objectives**

By completing this comprehensive hands-on lab, you will demonstrate advanced mastery of:

1. **Backend Architecture Design** - Implement sophisticated backend configurations for enterprise environments
2. **State Locking Implementation** - Configure and manage state locking mechanisms for team collaboration
3. **Remote State Integration** - Design complex remote state sharing patterns and cross-team workflows
4. **State Migration Execution** - Perform state migrations and implement disaster recovery procedures
5. **Enterprise Governance** - Establish comprehensive governance frameworks with security and compliance controls

### **Measurable Outcomes**
- **100% successful** backend configuration with enterprise security controls
- **98% accuracy** in state locking implementation and conflict resolution
- **95% efficiency** in remote state sharing and cross-team integration
- **100% compliance** with enterprise governance and security standards

---

## 📋 **Lab Scenario**

### **Business Context**
You are a Senior Cloud Infrastructure Architect at TechCorp Global, a multinational technology company with 50,000+ employees across 25 countries. The company is implementing a next-generation cloud platform requiring sophisticated state management, multi-team collaboration, and enterprise-grade governance frameworks. Your current challenges include:

- **Multi-Team Coordination**: Managing 15+ infrastructure teams across different time zones
- **Regulatory Compliance**: Meeting strict data protection and financial regulations
- **State Management Complexity**: Supporting 500+ Terraform configurations with complex dependencies
- **Disaster Recovery**: Implementing comprehensive backup and recovery procedures

### **Success Criteria**
Your task is to implement an advanced Terraform state management system that achieves:
- **Zero state conflicts** across all teams and environments
- **99.99% availability** for state operations and team collaboration
- **90% reduction** in state-related incidents through automation
- **100% compliance** with enterprise security and governance standards

![Figure 6.1: Terraform State Architecture and Backend Types](DaC/generated_diagrams/figure_6_1_state_architecture_backends.png)
*Figure 6.1: The comprehensive state architecture you'll implement in this lab*

---

## 🛠️ **Prerequisites and Setup**

### **Required Tools and Versions**
- **Operating System**: Windows 10+, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **Terraform CLI**: Version ~> 1.13.0 (installed and configured from previous labs)
- **AWS CLI**: Version 2.15.0+ with configured credentials
- **Git**: Version 2.40+ for version control and collaboration
- **Text Editor**: VS Code with HashiCorp Terraform extension v2.29.0+
- **jq**: JSON processor for state analysis and validation

### **AWS Account Requirements**
- **AWS Account**: Active AWS account with administrative access
- **IAM Permissions**: Full access to S3, DynamoDB, KMS, IAM, CloudWatch, and CloudTrail
- **Budget Alert**: $100 monthly budget configured for lab resources
- **Region**: All resources will be created in us-east-1
- **Multi-Account Setup**: Access to development, staging, and production accounts (simulated)

### **Pre-Lab Verification**
```bash
# Verify Terraform installation and version
terraform version
# Expected: Terraform v1.13.x

# Verify AWS CLI configuration
aws sts get-caller-identity
aws configure get region
# Expected: us-east-1

# Install additional tools
# Ubuntu/Debian:
sudo apt-get install jq awscli
# macOS:
brew install jq awscli
# Windows: Use package managers or download directly

# Verify tool installations
jq --version
aws --version
# Expected: Latest versions
```

---

## 🚀 **Lab Exercise 1: Enterprise Backend Architecture Implementation**

### **Objective**
Design and implement a comprehensive backend architecture supporting multiple teams, environments, and compliance requirements.

![Figure 6.2: State Locking and Collaboration Patterns](DaC/generated_diagrams/figure_6_2_state_locking_collaboration.png)
*Figure 6.2: State locking and collaboration patterns you'll implement*

### **Exercise 1.1: S3 Backend with Advanced Security**

#### **Create Project Structure**
```bash
# Create comprehensive lab directory structure
mkdir -p terraform-state-management-lab/{backend-setup,foundation,platform,applications,governance}
cd terraform-state-management-lab

# Create environment-specific directories
mkdir -p {backend-setup,foundation,platform,applications}/{dev,staging,prod}
mkdir -p governance/{policies,monitoring,compliance}

# Create main configuration files
touch backend-setup/{main.tf,variables.tf,outputs.tf,versions.tf}
```

#### **Implement Enterprise S3 Backend**
```hcl
# backend-setup/versions.tf - Version constraints
terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

# backend-setup/variables.tf - Backend configuration variables
variable "organization_name" {
  description = "Organization name for resource naming and tagging"
  type        = string
  default     = "techcorp-global"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.organization_name))
    error_message = "Organization name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environments" {
  description = "List of environments to create backend resources for"
  type        = list(string)
  default     = ["dev", "staging", "prod"]
  
  validation {
    condition = alltrue([
      for env in var.environments :
      contains(["dev", "staging", "prod"], env)
    ])
    error_message = "Environments must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in valid format (e.g., us-east-1)."
  }
}

variable "backup_regions" {
  description = "List of regions for cross-region backup"
  type        = list(string)
  default     = ["us-west-2", "eu-west-1"]
  
  validation {
    condition = alltrue([
      for region in var.backup_regions :
      can(regex("^[a-z]{2}-[a-z]+-[0-9]$", region))
    ])
    error_message = "All backup regions must be in valid AWS region format."
  }
}

variable "compliance_requirements" {
  description = "Compliance and governance requirements"
  type = object({
    encryption_required = bool
    audit_logging      = bool
    cross_region_backup = bool
    retention_years    = number
    data_classification = string
  })
  
  default = {
    encryption_required = true
    audit_logging      = true
    cross_region_backup = true
    retention_years    = 7
    data_classification = "confidential"
  }
  
  validation {
    condition = contains(["public", "internal", "confidential", "restricted"], var.compliance_requirements.data_classification)
    error_message = "Data classification must be public, internal, confidential, or restricted."
  }
  
  validation {
    condition = var.compliance_requirements.retention_years >= 1 && var.compliance_requirements.retention_years <= 10
    error_message = "Retention years must be between 1 and 10."
  }
}

variable "team_configurations" {
  description = "Team-specific backend configurations"
  type = map(object({
    team_name = string
    projects  = list(string)
    access_level = string
    backup_frequency = string
  }))
  
  default = {
    foundation = {
      team_name = "Foundation Infrastructure"
      projects  = ["network", "security", "dns"]
      access_level = "admin"
      backup_frequency = "daily"
    }
    platform = {
      team_name = "Platform Services"
      projects  = ["monitoring", "logging", "service-mesh"]
      access_level = "write"
      backup_frequency = "daily"
    }
    applications = {
      team_name = "Application Teams"
      projects  = ["web-app", "api-service", "mobile-backend"]
      access_level = "write"
      backup_frequency = "hourly"
    }
  }
  
  validation {
    condition = alltrue([
      for team_name, team_config in var.team_configurations :
      contains(["read", "write", "admin"], team_config.access_level)
    ])
    error_message = "Access level must be read, write, or admin."
  }
  
  validation {
    condition = alltrue([
      for team_name, team_config in var.team_configurations :
      contains(["hourly", "daily", "weekly"], team_config.backup_frequency)
    ])
    error_message = "Backup frequency must be hourly, daily, or weekly."
  }
}

# backend-setup/main.tf - Backend infrastructure implementation
# Current AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random suffix for globally unique resource names
resource "random_id" "backend_suffix" {
  byte_length = 4
}

locals {
  # Common tags for all resources
  common_tags = {
    Organization = var.organization_name
    Purpose      = "terraform-backend"
    ManagedBy    = "terraform"
    Environment  = "shared"
    
    # Compliance and governance tags
    DataClassification = var.compliance_requirements.data_classification
    BackupRequired     = "true"
    EncryptionRequired = tostring(var.compliance_requirements.encryption_required)
    AuditLogging      = tostring(var.compliance_requirements.audit_logging)
    
    # Operational tags
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    CreatedBy   = data.aws_caller_identity.current.user_id
    Region      = data.aws_region.current.name
  }
  
  # Generate unique bucket names
  state_bucket_name = "${var.organization_name}-terraform-state-${random_id.backend_suffix.hex}"
  backup_bucket_name = "${var.organization_name}-terraform-backup-${random_id.backend_suffix.hex}"
  
  # DynamoDB table name for state locking
  lock_table_name = "${var.organization_name}-terraform-locks"
  
  # KMS key alias
  kms_key_alias = "alias/${var.organization_name}-terraform-state"
}

# KMS key for state encryption
resource "aws_kms_key" "terraform_state" {
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
        Sid    = "Allow Terraform State Operations"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = merge(local.common_tags, {
    Name = "Terraform State Encryption Key"
    Type = "kms-key"
  })
}

# KMS key alias
resource "aws_kms_alias" "terraform_state" {
  name          = local.kms_key_alias
  target_key_id = aws_kms_key.terraform_state.key_id
}

# S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = local.state_bucket_name
  
  tags = merge(local.common_tags, {
    Name = "Terraform State Bucket"
    Type = "s3-bucket"
  })
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
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
    id     = "terraform_state_lifecycle"
    status = "Enabled"
    
    # Transition to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    # Transition to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    
    # Delete old versions after retention period
    noncurrent_version_expiration {
      noncurrent_days = var.compliance_requirements.retention_years * 365
    }
    
    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 bucket notification for state changes
resource "aws_s3_bucket_notification" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  cloudwatch_configuration {
    cloudwatch_configuration_id = "terraform-state-changes"
    events                     = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_s3_bucket.terraform_state]
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = local.lock_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Point-in-time recovery for lock table protection
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption {
    enabled     = true
    kms_key_id  = aws_kms_key.terraform_state.arn
  }

  tags = merge(local.common_tags, {
    Name = "Terraform State Locks"
    Type = "dynamodb-table"
  })
}

# Cross-region backup bucket (if enabled)
resource "aws_s3_bucket" "terraform_backup" {
  count = var.compliance_requirements.cross_region_backup ? 1 : 0

  provider = aws.backup_region
  bucket   = local.backup_bucket_name

  tags = merge(local.common_tags, {
    Name = "Terraform State Backup Bucket"
    Type = "s3-bucket"
    Purpose = "cross-region-backup"
  })
}

# Cross-region replication configuration
resource "aws_s3_bucket_replication_configuration" "terraform_state" {
  count = var.compliance_requirements.cross_region_backup ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "terraform-state-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.terraform_backup[0].arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.terraform_state.arn
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.terraform_state]
}

# IAM role for S3 replication
resource "aws_iam_role" "replication" {
  count = var.compliance_requirements.cross_region_backup ? 1 : 0

  name = "${var.organization_name}-s3-replication-role"

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

  tags = local.common_tags
}

# IAM policy for S3 replication
resource "aws_iam_role_policy" "replication" {
  count = var.compliance_requirements.cross_region_backup ? 1 : 0

  name = "${var.organization_name}-s3-replication-policy"
  role = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl"
        ]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.terraform_backup[0].arn}/*"
      }
    ]
  })
}
```

### **Exercise 1.2: State Locking and Monitoring Implementation**

#### **CloudWatch Monitoring for State Operations**
```hcl
# CloudWatch log group for Terraform operations
resource "aws_cloudwatch_log_group" "terraform_operations" {
  name              = "/terraform/${var.organization_name}/operations"
  retention_in_days = var.compliance_requirements.retention_years * 365
  kms_key_id        = aws_kms_key.terraform_state.arn

  tags = merge(local.common_tags, {
    Name = "Terraform Operations Logs"
    Type = "cloudwatch-log-group"
  })
}

# CloudWatch metric filters for state operations
resource "aws_cloudwatch_log_metric_filter" "state_lock_acquisitions" {
  name           = "terraform-state-lock-acquisitions"
  log_group_name = aws_cloudwatch_log_group.terraform_operations.name
  pattern        = "[timestamp, request_id, \"LOCK_ACQUIRED\", lock_id, user]"

  metric_transformation {
    name      = "TerraformStateLockAcquisitions"
    namespace = "Terraform/StateManagement"
    value     = "1"

    default_value = 0
  }
}

resource "aws_cloudwatch_log_metric_filter" "state_lock_failures" {
  name           = "terraform-state-lock-failures"
  log_group_name = aws_cloudwatch_log_group.terraform_operations.name
  pattern        = "[timestamp, request_id, \"LOCK_FAILED\", lock_id, user, reason]"

  metric_transformation {
    name      = "TerraformStateLockFailures"
    namespace = "Terraform/StateManagement"
    value     = "1"

    default_value = 0
  }
}

# CloudWatch alarms for state management
resource "aws_cloudwatch_metric_alarm" "high_lock_failures" {
  alarm_name          = "terraform-high-lock-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TerraformStateLockFailures"
  namespace           = "Terraform/StateManagement"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors high Terraform state lock failures"
  alarm_actions       = [aws_sns_topic.terraform_alerts.arn]

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttling" {
  alarm_name          = "terraform-locks-throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB throttling for Terraform locks"
  alarm_actions       = [aws_sns_topic.terraform_alerts.arn]

  dimensions = {
    TableName = aws_dynamodb_table.terraform_locks.name
  }

  tags = local.common_tags
}

# SNS topic for Terraform alerts
resource "aws_sns_topic" "terraform_alerts" {
  name              = "${var.organization_name}-terraform-alerts"
  kms_master_key_id = aws_kms_key.terraform_state.arn

  tags = merge(local.common_tags, {
    Name = "Terraform Alerts Topic"
    Type = "sns-topic"
  })
}

# SNS topic subscription for email alerts
resource "aws_sns_topic_subscription" "terraform_alerts_email" {
  topic_arn = aws_sns_topic.terraform_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}
```

### **Exercise 1.3: Team-Based Access Control**

#### **IAM Policies for Team Access**
```hcl
# IAM policy for foundation team (admin access)
resource "aws_iam_policy" "foundation_team_policy" {
  name        = "${var.organization_name}-foundation-team-policy"
  description = "Policy for foundation infrastructure team"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:DeleteObjectVersion"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/foundation/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.terraform_state.arn
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for platform team (write access)
resource "aws_iam_policy" "platform_team_policy" {
  name        = "${var.organization_name}-platform-team-policy"
  description = "Policy for platform services team"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}/platform/*",
          "${aws_s3_bucket.terraform_state.arn}/foundation/*/terraform.tfstate"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
        Condition = {
          StringLike = {
            "dynamodb:LeadingKeys" = ["platform/*"]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.terraform_state.arn
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for application teams (limited write access)
resource "aws_iam_policy" "application_team_policy" {
  name        = "${var.organization_name}-application-team-policy"
  description = "Policy for application development teams"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}/applications/*",
          "${aws_s3_bucket.terraform_state.arn}/foundation/*/terraform.tfstate",
          "${aws_s3_bucket.terraform_state.arn}/platform/*/terraform.tfstate"
        ]
      },
      {
        Effect = "Deny"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}/foundation/*",
          "${aws_s3_bucket.terraform_state.arn}/platform/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
        Condition = {
          StringLike = {
            "dynamodb:LeadingKeys" = ["applications/*"]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.terraform_state.arn
      }
    ]
  })

  tags = local.common_tags
}
```
```
