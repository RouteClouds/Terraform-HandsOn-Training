# =============================================================================
# AWS Terraform Training - Topic 6: State Management with AWS
# Variable Definitions with Advanced Validation
# =============================================================================

# Project and Environment Configuration
variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "terraform-state-management-training"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 50
    error_message = "Project name must be between 3 and 50 characters long."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["development", "staging", "production", "dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: development, staging, production, dev, stage, prod."
  }
}

variable "owner" {
  description = "Owner of the resources for accountability and contact"
  type        = string
  default     = "terraform-training-team"
  
  validation {
    condition     = length(var.owner) > 0
    error_message = "Owner must not be empty."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "training-infrastructure"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cost_center))
    error_message = "Cost center must contain only lowercase letters, numbers, and hyphens."
  }
}

# AWS Configuration
variable "aws_region" {
  description = "Primary AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-1",
      "ap-southeast-2", "ap-northeast-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid and supported region."
  }
}

variable "backup_region" {
  description = "Secondary AWS region for backup and disaster recovery"
  type        = string
  default     = "us-west-2"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-1",
      "ap-southeast-2", "ap-northeast-1"
    ], var.backup_region)
    error_message = "Backup region must be a valid and supported region."
  }
  
  validation {
    condition     = var.backup_region != var.aws_region
    error_message = "Backup region must be different from the primary region."
  }
}

# Cross-Account Access Configuration
variable "assume_role_arn" {
  description = "ARN of the IAM role to assume for cross-account access"
  type        = string
  default     = null
  
  validation {
    condition = var.assume_role_arn == null || can(regex(
      "^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9+=,.@_-]+$",
      var.assume_role_arn
    ))
    error_message = "Assume role ARN must be a valid IAM role ARN format."
  }
}

variable "external_id" {
  description = "External ID for assume role operations (security best practice)"
  type        = string
  default     = null
  sensitive   = true
  
  validation {
    condition = var.external_id == null || (
      length(var.external_id) >= 2 && length(var.external_id) <= 1224
    )
    error_message = "External ID must be between 2 and 1224 characters long."
  }
}

# State Backend Configuration
variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state storage"
  type        = string
  default     = null
  
  validation {
    condition = var.state_bucket_name == null || can(regex(
      "^[a-z0-9][a-z0-9-]*[a-z0-9]$",
      var.state_bucket_name
    ))
    error_message = "S3 bucket name must follow AWS naming conventions."
  }
  
  validation {
    condition = var.state_bucket_name == null || (
      length(var.state_bucket_name) >= 3 && length(var.state_bucket_name) <= 63
    )
    error_message = "S3 bucket name must be between 3 and 63 characters long."
  }
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-locks"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.dynamodb_table_name))
    error_message = "DynamoDB table name must contain only letters, numbers, underscores, periods, and hyphens."
  }
  
  validation {
    condition     = length(var.dynamodb_table_name) >= 3 && length(var.dynamodb_table_name) <= 255
    error_message = "DynamoDB table name must be between 3 and 255 characters long."
  }
}

variable "enable_state_encryption" {
  description = "Enable server-side encryption for state files"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for state file encryption (optional)"
  type        = string
  default     = null
  
  validation {
    condition = var.kms_key_id == null || can(regex(
      "^(arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+|[a-f0-9-]+)$",
      var.kms_key_id
    ))
    error_message = "KMS key ID must be a valid key ID or ARN format."
  }
}

# Workspace and Environment Management
variable "workspace_environments" {
  description = "Map of workspace names to environment configurations"
  type = map(object({
    environment_type = string
    instance_types   = list(string)
    min_capacity     = number
    max_capacity     = number
    enable_monitoring = bool
    backup_retention = number
  }))
  
  default = {
    development = {
      environment_type  = "dev"
      instance_types    = ["t3.micro", "t3.small"]
      min_capacity      = 1
      max_capacity      = 3
      enable_monitoring = false
      backup_retention  = 7
    }
    staging = {
      environment_type  = "stage"
      instance_types    = ["t3.medium", "m5.large"]
      min_capacity      = 2
      max_capacity      = 5
      enable_monitoring = true
      backup_retention  = 14
    }
    production = {
      environment_type  = "prod"
      instance_types    = ["m5.large", "m5.xlarge"]
      min_capacity      = 3
      max_capacity      = 10
      enable_monitoring = true
      backup_retention  = 30
    }
  }
  
  validation {
    condition = alltrue([
      for env, config in var.workspace_environments :
      contains(["dev", "stage", "prod"], config.environment_type)
    ])
    error_message = "Environment type must be one of: dev, stage, prod."
  }
  
  validation {
    condition = alltrue([
      for env, config in var.workspace_environments :
      config.min_capacity >= 1 && config.max_capacity >= config.min_capacity
    ])
    error_message = "Min capacity must be at least 1 and max capacity must be >= min capacity."
  }
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for high availability."
  }
}

# Security Configuration
variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail for API logging and auditing"
  type        = bool
  default     = true
}

variable "cloudtrail_retention_days" {
  description = "Number of days to retain CloudTrail logs"
  type        = number
  default     = 90
  
  validation {
    condition     = var.cloudtrail_retention_days >= 1 && var.cloudtrail_retention_days <= 3653
    error_message = "CloudTrail retention must be between 1 and 3653 days."
  }
}

# Monitoring and Alerting
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email address for notifications and alerts"
  type        = string
  default     = "admin@example.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Notification email must be a valid email address format."
  }
}

# Cost Management
variable "enable_cost_allocation_tags" {
  description = "Enable cost allocation tags for billing analysis"
  type        = bool
  default     = true
}

variable "budget_limit" {
  description = "Monthly budget limit in USD for cost monitoring"
  type        = number
  default     = 100
  
  validation {
    condition     = var.budget_limit > 0 && var.budget_limit <= 10000
    error_message = "Budget limit must be between 1 and 10000 USD."
  }
}

# Feature Flags
variable "enable_backup_region_resources" {
  description = "Enable resources in backup region for disaster recovery"
  type        = bool
  default     = false
}

variable "enable_cross_region_replication" {
  description = "Enable cross-region replication for state backups"
  type        = bool
  default     = false
}

variable "enable_state_versioning" {
  description = "Enable versioning for state files"
  type        = bool
  default     = true
}

variable "state_version_retention" {
  description = "Number of state file versions to retain"
  type        = number
  default     = 10
  
  validation {
    condition     = var.state_version_retention >= 1 && var.state_version_retention <= 100
    error_message = "State version retention must be between 1 and 100 versions."
  }
}

# =============================================================================
# Variable Configuration Notes:
# 
# 1. Validation Rules:
#    - Comprehensive validation for all inputs
#    - Business logic validation for complex scenarios
#    - Security validation for sensitive parameters
#    - Format validation for AWS resource naming
#
# 2. Default Values:
#    - Production-ready defaults where appropriate
#    - Development-friendly defaults for training
#    - Security-first defaults for sensitive settings
#    - Cost-optimized defaults for training environments
#
# 3. Type Safety:
#    - Strong typing for all variables
#    - Complex object types for structured data
#    - Sensitive marking for security-related variables
#    - Nullable types where appropriate
#
# 4. Documentation:
#    - Clear descriptions for all variables
#    - Usage examples in validation messages
#    - Business context for complex variables
#    - Security implications noted where relevant
# =============================================================================
