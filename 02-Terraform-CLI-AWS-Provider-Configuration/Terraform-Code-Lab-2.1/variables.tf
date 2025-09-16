# AWS Terraform Training - Topic 2: Terraform CLI & AWS Provider Configuration
# Terraform Code Lab 2.1 - Variable Definitions
#
# This file defines all input variables for the Terraform configuration,
# demonstrating best practices for variable organization, validation, and documentation.
#
# Learning Objectives:
# 1. Variable definition and validation patterns
# 2. Type constraints and default values
# 3. Sensitive variable handling
# 4. Environment-specific variable organization
# 5. Enterprise variable management strategies

# =============================================================================
# CORE CONFIGURATION VARIABLES
# =============================================================================

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in valid format (e.g., us-east-1, eu-west-1)."
  }
}

variable "environment" {
  description = "Environment name for resource organization and tagging"
  type        = string
  
  validation {
    condition = contains(["dev", "development", "staging", "stage", "prod", "production"], var.environment)
    error_message = "Environment must be one of: dev, development, staging, stage, prod, production."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile for authentication (local development)"
  type        = string
  default     = "default"
  
  validation {
    condition = length(var.aws_profile) > 0
    error_message = "AWS profile cannot be empty."
  }
}

# =============================================================================
# AUTHENTICATION AND SECURITY VARIABLES
# =============================================================================

variable "assume_role_arn" {
  description = "ARN of the IAM role to assume for cross-account access"
  type        = string
  default     = null
  
  validation {
    condition = var.assume_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.assume_role_arn))
    error_message = "Assume role ARN must be a valid IAM role ARN format."
  }
}

variable "external_id" {
  description = "External ID for role assumption (additional security layer)"
  type        = string
  default     = null
  sensitive   = true
  
  validation {
    condition = var.external_id == null || length(var.external_id) >= 8
    error_message = "External ID must be at least 8 characters long when specified."
  }
}

variable "mfa_device_arn" {
  description = "ARN of MFA device for enhanced security"
  type        = string
  default     = null
  sensitive   = true
  
  validation {
    condition = var.mfa_device_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:mfa/.+", var.mfa_device_arn))
    error_message = "MFA device ARN must be a valid MFA device ARN format."
  }
}

# =============================================================================
# MULTI-ACCOUNT CONFIGURATION VARIABLES
# =============================================================================

variable "staging_account_id" {
  description = "AWS account ID for staging environment"
  type        = string
  default     = null
  
  validation {
    condition = var.staging_account_id == null || can(regex("^[0-9]{12}$", var.staging_account_id))
    error_message = "AWS account ID must be exactly 12 digits."
  }
}

variable "production_account_id" {
  description = "AWS account ID for production environment"
  type        = string
  default     = null
  
  validation {
    condition = var.production_account_id == null || can(regex("^[0-9]{12}$", var.production_account_id))
    error_message = "AWS account ID must be exactly 12 digits."
  }
}

# =============================================================================
# CI/CD AND AUTOMATION VARIABLES
# =============================================================================

variable "cicd_role_arn" {
  description = "ARN of IAM role for CI/CD pipeline authentication"
  type        = string
  default     = null
  
  validation {
    condition = var.cicd_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.cicd_role_arn))
    error_message = "CI/CD role ARN must be a valid IAM role ARN format."
  }
}

variable "web_identity_token_file" {
  description = "Path to web identity token file for OIDC authentication"
  type        = string
  default     = null
  
  validation {
    condition = var.web_identity_token_file == null || length(var.web_identity_token_file) > 0
    error_message = "Web identity token file path cannot be empty when specified."
  }
}

# =============================================================================
# RESOURCE TAGGING AND ORGANIZATION VARIABLES
# =============================================================================

variable "owner" {
  description = "Resource owner for accountability and contact information"
  type        = string
  default     = "platform-team"
  
  validation {
    condition = length(var.owner) > 0 && length(var.owner) <= 50
    error_message = "Owner must be between 1 and 50 characters."
  }
}

variable "cost_center" {
  description = "Cost center for billing allocation and chargeback"
  type        = string
  default     = "engineering"
  
  validation {
    condition = contains(["engineering", "marketing", "sales", "operations", "training"], var.cost_center)
    error_message = "Cost center must be one of: engineering, marketing, sales, operations, training."
  }
}

variable "project_name" {
  description = "Project name for resource organization and identification"
  type        = string
  default     = "terraform-training-lab-2"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# =============================================================================
# INFRASTRUCTURE CONFIGURATION VARIABLES
# =============================================================================

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for resources"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable automated backup for applicable resources"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
  
  validation {
    condition = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}

# =============================================================================
# NETWORK CONFIGURATION VARIABLES
# =============================================================================

variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployments"
  type        = list(string)
  default     = []
  
  validation {
    condition = length(var.availability_zones) <= 6
    error_message = "Maximum of 6 availability zones can be specified."
  }
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = false
}

# =============================================================================
# SECURITY AND COMPLIANCE VARIABLES
# =============================================================================

variable "data_classification" {
  description = "Data classification level for compliance and security"
  type        = string
  default     = "internal"
  
  validation {
    condition = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "compliance_requirements" {
  description = "List of compliance requirements (SOC2, PCI-DSS, HIPAA, etc.)"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for req in var.compliance_requirements : 
      contains(["SOC2", "PCI-DSS", "HIPAA", "GDPR", "FedRAMP"], req)
    ])
    error_message = "Compliance requirements must be from: SOC2, PCI-DSS, HIPAA, GDPR, FedRAMP."
  }
}

variable "encryption_at_rest" {
  description = "Enable encryption at rest for all applicable resources"
  type        = bool
  default     = true
}

variable "encryption_in_transit" {
  description = "Enable encryption in transit for all applicable resources"
  type        = bool
  default     = true
}

# =============================================================================
# COST MANAGEMENT VARIABLES
# =============================================================================

variable "budget_limit" {
  description = "Monthly budget limit in USD for cost control"
  type        = number
  default     = 100
  
  validation {
    condition = var.budget_limit > 0 && var.budget_limit <= 10000
    error_message = "Budget limit must be between 1 and 10000 USD."
  }
}

variable "cost_allocation_tags" {
  description = "Additional tags for cost allocation and tracking"
  type        = map(string)
  default     = {}
  
  validation {
    condition = length(var.cost_allocation_tags) <= 10
    error_message = "Maximum of 10 cost allocation tags can be specified."
  }
}

# =============================================================================
# ADVANCED CONFIGURATION VARIABLES
# =============================================================================

variable "terraform_version" {
  description = "Required Terraform version for validation"
  type        = string
  default     = "~> 1.13.0"
  
  validation {
    condition = can(regex("^~> [0-9]+\\.[0-9]+\\.[0-9]+$", var.terraform_version))
    error_message = "Terraform version must be in format '~> X.Y.Z'."
  }
}

variable "aws_provider_version" {
  description = "Required AWS provider version for validation"
  type        = string
  default     = "~> 6.12.0"
  
  validation {
    condition = can(regex("^~> [0-9]+\\.[0-9]+\\.[0-9]+$", var.aws_provider_version))
    error_message = "AWS provider version must be in format '~> X.Y.Z'."
  }
}

variable "enable_experimental_features" {
  description = "Enable experimental Terraform features (use with caution)"
  type        = bool
  default     = false
}

# =============================================================================
# ENVIRONMENT-SPECIFIC VARIABLE MAPS
# =============================================================================

variable "environment_config" {
  description = "Environment-specific configuration overrides"
  type = map(object({
    instance_type     = string
    min_capacity      = number
    max_capacity      = number
    enable_monitoring = bool
    backup_retention  = number
  }))
  default = {
    dev = {
      instance_type     = "t3.micro"
      min_capacity      = 1
      max_capacity      = 2
      enable_monitoring = false
      backup_retention  = 3
    }
    staging = {
      instance_type     = "t3.small"
      min_capacity      = 1
      max_capacity      = 3
      enable_monitoring = true
      backup_retention  = 7
    }
    prod = {
      instance_type     = "t3.medium"
      min_capacity      = 2
      max_capacity      = 10
      enable_monitoring = true
      backup_retention  = 30
    }
  }
}

# =============================================================================
# FEATURE FLAGS
# =============================================================================

variable "feature_flags" {
  description = "Feature flags for enabling/disabling specific functionality"
  type = object({
    enable_logging           = bool
    enable_metrics          = bool
    enable_tracing          = bool
    enable_auto_scaling     = bool
    enable_load_balancing   = bool
    enable_ssl_termination  = bool
  })
  default = {
    enable_logging          = true
    enable_metrics         = true
    enable_tracing         = false
    enable_auto_scaling    = true
    enable_load_balancing  = false
    enable_ssl_termination = true
  }
}
