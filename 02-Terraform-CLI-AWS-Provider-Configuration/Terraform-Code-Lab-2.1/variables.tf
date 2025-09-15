# AWS Terraform Training - Terraform CLI & AWS Provider Configuration
# Lab 2.1: Advanced Provider Configuration and Authentication
# File: variables.tf - Comprehensive Variable Definitions

# ============================================================================
# PROJECT IDENTIFICATION VARIABLES
# ============================================================================

variable "project_name" {
  description = "Name of the project for resource identification and tagging"
  type        = string
  default     = "terraform-cli-aws-provider"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "student_name" {
  description = "Student name for resource identification and cost tracking"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.student_name))
    error_message = "Student name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "owner_email" {
  description = "Email address of the resource owner for notifications and billing"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation tracking"
  type        = string
  default     = "training"
}

# ============================================================================
# AWS REGION AND AVAILABILITY ZONE CONFIGURATION
# ============================================================================

variable "aws_region" {
  description = "Primary AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid AWS region."
  }
}

variable "secondary_region" {
  description = "Secondary AWS region for multi-region deployments"
  type        = string
  default     = "us-west-2"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.secondary_region)
    error_message = "Secondary region must be a valid AWS region."
  }
}

variable "disaster_recovery_region" {
  description = "Disaster recovery AWS region for backup deployments"
  type        = string
  default     = "us-west-1"
}

variable "availability_zones" {
  description = "List of availability zones to use in the primary region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for high availability."
  }
}

# ============================================================================
# AWS AUTHENTICATION CONFIGURATION
# ============================================================================

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "default"
}

variable "auth_method" {
  description = "Authentication method being used (for tagging and documentation)"
  type        = string
  default     = "aws-profile"
  
  validation {
    condition = contains([
      "aws-profile", "environment-variables", "iam-role", 
      "aws-sso", "instance-profile", "assume-role"
    ], var.auth_method)
    error_message = "Auth method must be one of: aws-profile, environment-variables, iam-role, aws-sso, instance-profile, assume-role."
  }
}

variable "shared_config_files" {
  description = "List of AWS shared config files"
  type        = list(string)
  default     = ["~/.aws/config"]
}

variable "shared_credentials_files" {
  description = "List of AWS shared credentials files"
  type        = list(string)
  default     = ["~/.aws/credentials"]
}

# ============================================================================
# ASSUME ROLE CONFIGURATION
# ============================================================================

variable "assume_role_arn" {
  description = "ARN of the IAM role to assume for primary provider"
  type        = string
  default     = ""
}

variable "session_name" {
  description = "Session name for assume role operations"
  type        = string
  default     = "terraform-session"
}

variable "external_id" {
  description = "External ID for assume role operations (for enhanced security)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "session_duration" {
  description = "Duration of the assume role session in seconds"
  type        = number
  default     = 3600
  
  validation {
    condition     = var.session_duration >= 900 && var.session_duration <= 43200
    error_message = "Session duration must be between 900 seconds (15 minutes) and 43200 seconds (12 hours)."
  }
}

variable "assume_role_policy" {
  description = "IAM policy to apply during assume role operation"
  type        = string
  default     = ""
}

# ============================================================================
# ENVIRONMENT-SPECIFIC AUTHENTICATION
# ============================================================================

variable "development_profile" {
  description = "AWS CLI profile for development environment"
  type        = string
  default     = "development"
}

variable "staging_profile" {
  description = "AWS CLI profile for staging environment"
  type        = string
  default     = "staging"
}

variable "production_profile" {
  description = "AWS CLI profile for production environment"
  type        = string
  default     = "production"
}

variable "development_role_arn" {
  description = "ARN of the IAM role for development environment"
  type        = string
  default     = ""
}

variable "staging_role_arn" {
  description = "ARN of the IAM role for staging environment"
  type        = string
  default     = ""
}

variable "production_role_arn" {
  description = "ARN of the IAM role for production environment"
  type        = string
  default     = ""
}

# ============================================================================
# PROVIDER PERFORMANCE CONFIGURATION
# ============================================================================

variable "max_retries" {
  description = "Maximum number of retries for AWS API calls"
  type        = number
  default     = 10
  
  validation {
    condition     = var.max_retries >= 1 && var.max_retries <= 25
    error_message = "Max retries must be between 1 and 25."
  }
}

variable "retry_mode" {
  description = "Retry mode for AWS API calls (standard, adaptive)"
  type        = string
  default     = "adaptive"
  
  validation {
    condition     = contains(["standard", "adaptive"], var.retry_mode)
    error_message = "Retry mode must be either 'standard' or 'adaptive'."
  }
}

# ============================================================================
# RESOURCE CONFIGURATION
# ============================================================================

variable "create_test_resources" {
  description = "Whether to create test resources for provider validation"
  type        = bool
  default     = true
}

variable "enable_multi_region" {
  description = "Enable multi-region resource deployment"
  type        = bool
  default     = true
}

variable "enable_cross_account" {
  description = "Enable cross-account resource deployment"
  type        = bool
  default     = false
}

# ============================================================================
# SECURITY AND COMPLIANCE CONFIGURATION
# ============================================================================

variable "data_classification" {
  description = "Data classification level for compliance and security"
  type        = string
  default     = "internal"
  
  validation {
    condition = contains([
      "public", "internal", "confidential", "restricted"
    ], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "compliance_framework" {
  description = "Compliance framework requirements"
  type        = string
  default     = "training"
  
  validation {
    condition = contains([
      "training", "development", "sox", "pci", "hipaa", "gdpr"
    ], var.compliance_framework)
    error_message = "Compliance framework must be one of: training, development, sox, pci, hipaa, gdpr."
  }
}

variable "backup_required" {
  description = "Whether backup is required for created resources"
  type        = bool
  default     = false
}

variable "monitoring_enabled" {
  description = "Whether monitoring should be enabled for resources"
  type        = bool
  default     = true
}

variable "encryption_enabled" {
  description = "Whether encryption should be enabled for all storage resources"
  type        = bool
  default     = true
}

# ============================================================================
# COST OPTIMIZATION CONFIGURATION
# ============================================================================

variable "auto_shutdown_enabled" {
  description = "Enable automatic shutdown of resources for cost optimization"
  type        = bool
  default     = true
}

variable "auto_shutdown_hours" {
  description = "Number of hours after which resources should be automatically shut down"
  type        = number
  default     = 4
  
  validation {
    condition     = var.auto_shutdown_hours >= 1 && var.auto_shutdown_hours <= 24
    error_message = "Auto shutdown hours must be between 1 and 24."
  }
}

variable "cost_optimization_level" {
  description = "Level of cost optimization to apply"
  type        = string
  default     = "aggressive"
  
  validation {
    condition = contains([
      "none", "basic", "moderate", "aggressive"
    ], var.cost_optimization_level)
    error_message = "Cost optimization level must be one of: none, basic, moderate, aggressive."
  }
}

# ============================================================================
# TESTING AND VALIDATION CONFIGURATION
# ============================================================================

variable "enable_provider_validation" {
  description = "Enable provider configuration validation tests"
  type        = bool
  default     = true
}

variable "enable_authentication_test" {
  description = "Enable authentication method testing"
  type        = bool
  default     = true
}

variable "enable_multi_region_test" {
  description = "Enable multi-region configuration testing"
  type        = bool
  default     = true
}

variable "test_resource_prefix" {
  description = "Prefix for test resources to avoid naming conflicts"
  type        = string
  default     = "terraform-cli-test"
}

# ============================================================================
# ADVANCED CONFIGURATION
# ============================================================================

variable "custom_endpoints" {
  description = "Custom AWS service endpoints for testing or private deployments"
  type = object({
    s3  = optional(string)
    ec2 = optional(string)
    iam = optional(string)
  })
  default = {}
}

variable "provider_tags" {
  description = "Additional tags to apply to all resources via provider default_tags"
  type        = map(string)
  default     = {}
}

variable "ignore_tag_keys" {
  description = "List of tag keys to ignore during resource updates"
  type        = list(string)
  default = [
    "LastAccessed",
    "TemporaryTag",
    "AutoGenerated"
  ]
}

variable "ignore_tag_key_prefixes" {
  description = "List of tag key prefixes to ignore during resource updates"
  type        = list(string)
  default = [
    "aws:",
    "kubernetes.io/",
    "eks:",
    "auto-"
  ]
}

# ============================================================================
# WORKSPACE AND STATE CONFIGURATION
# ============================================================================

variable "workspace_name" {
  description = "Terraform workspace name for state isolation"
  type        = string
  default     = ""
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state storage"
  type        = string
  default     = ""
}

variable "state_dynamodb_table" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = ""
}

variable "state_encryption_enabled" {
  description = "Enable encryption for Terraform state files"
  type        = bool
  default     = true
}
