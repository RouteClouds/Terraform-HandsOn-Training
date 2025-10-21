# =============================================================================
# AWS Terraform Training - Topic 7: Modules and Module Development
# Variable Definitions with Advanced Validation
# =============================================================================

# Project and Environment Configuration
variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "terraform-modules-training"
  
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

variable "secondary_region" {
  description = "Secondary AWS region for multi-region module testing"
  type        = string
  default     = "us-west-2"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-1",
      "ap-southeast-2", "ap-northeast-1"
    ], var.secondary_region)
    error_message = "Secondary region must be a valid and supported region."
  }
  
  validation {
    condition     = var.secondary_region != var.aws_region
    error_message = "Secondary region must be different from the primary region."
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

# Module Development Configuration
variable "module_development_mode" {
  description = "Enable module development mode with additional features"
  type        = bool
  default     = true
}

variable "enable_module_testing" {
  description = "Enable module testing infrastructure"
  type        = bool
  default     = true
}

variable "module_registry_url" {
  description = "URL of the private module registry (optional)"
  type        = string
  default     = null
  
  validation {
    condition = var.module_registry_url == null || can(regex(
      "^https?://[a-zA-Z0-9.-]+(/.*)?$",
      var.module_registry_url
    ))
    error_message = "Module registry URL must be a valid HTTP/HTTPS URL."
  }
}

# Network Configuration for Module Testing
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

# Module Configuration Examples
variable "module_examples" {
  description = "Configuration for different module examples"
  type = map(object({
    enabled           = bool
    instance_type     = string
    min_size         = number
    max_size         = number
    desired_capacity = number
    enable_monitoring = bool
    tags             = map(string)
  }))
  
  default = {
    vpc_module = {
      enabled           = true
      instance_type     = "t3.micro"
      min_size         = 1
      max_size         = 3
      desired_capacity = 2
      enable_monitoring = false
      tags = {
        ModuleType = "networking"
        Purpose    = "vpc-example"
      }
    }
    compute_module = {
      enabled           = true
      instance_type     = "t3.small"
      min_size         = 1
      max_size         = 5
      desired_capacity = 2
      enable_monitoring = true
      tags = {
        ModuleType = "compute"
        Purpose    = "ec2-example"
      }
    }
    storage_module = {
      enabled           = true
      instance_type     = "t3.medium"
      min_size         = 1
      max_size         = 2
      desired_capacity = 1
      enable_monitoring = true
      tags = {
        ModuleType = "storage"
        Purpose    = "s3-example"
      }
    }
  }
  
  validation {
    condition = alltrue([
      for module_name, config in var.module_examples :
      contains(["t3.micro", "t3.small", "t3.medium", "t3.large"], config.instance_type)
    ])
    error_message = "Instance type must be one of: t3.micro, t3.small, t3.medium, t3.large."
  }
  
  validation {
    condition = alltrue([
      for module_name, config in var.module_examples :
      config.min_size >= 1 && config.max_size >= config.min_size && config.desired_capacity >= config.min_size && config.desired_capacity <= config.max_size
    ])
    error_message = "Min size must be >= 1, max size >= min size, and desired capacity between min and max."
  }
}

# Module Testing Configuration
variable "testing_environments" {
  description = "Configuration for module testing environments"
  type = map(object({
    enabled              = bool
    auto_destroy        = bool
    test_duration_hours = number
    test_scenarios      = list(string)
    notification_email  = string
  }))
  
  default = {
    unit_testing = {
      enabled              = true
      auto_destroy        = true
      test_duration_hours = 1
      test_scenarios      = ["basic_functionality", "error_handling"]
      notification_email  = "dev-team@example.com"
    }
    integration_testing = {
      enabled              = true
      auto_destroy        = true
      test_duration_hours = 2
      test_scenarios      = ["module_composition", "cross_module_dependencies"]
      notification_email  = "qa-team@example.com"
    }
    performance_testing = {
      enabled              = false
      auto_destroy        = true
      test_duration_hours = 4
      test_scenarios      = ["load_testing", "stress_testing", "scalability"]
      notification_email  = "performance-team@example.com"
    }
  }
  
  validation {
    condition = alltrue([
      for env_name, config in var.testing_environments :
      config.test_duration_hours >= 1 && config.test_duration_hours <= 24
    ])
    error_message = "Test duration must be between 1 and 24 hours."
  }
  
  validation {
    condition = alltrue([
      for env_name, config in var.testing_environments :
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", config.notification_email))
    ])
    error_message = "Notification email must be a valid email address format."
  }
}

# Security Configuration
variable "enable_security_scanning" {
  description = "Enable security scanning for modules"
  type        = bool
  default     = true
}

variable "enable_compliance_checking" {
  description = "Enable compliance checking for modules"
  type        = bool
  default     = true
}

variable "security_scan_schedule" {
  description = "Cron schedule for security scanning"
  type        = string
  default     = "0 2 * * *"  # Daily at 2 AM
  
  validation {
    condition     = can(regex("^[0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+$", var.security_scan_schedule))
    error_message = "Security scan schedule must be a valid cron expression."
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
  default     = 200
  
  validation {
    condition     = var.budget_limit > 0 && var.budget_limit <= 10000
    error_message = "Budget limit must be between 1 and 10000 USD."
  }
}

# Feature Flags
variable "enable_multi_region_testing" {
  description = "Enable multi-region module testing"
  type        = bool
  default     = false
}

variable "enable_module_versioning" {
  description = "Enable module versioning and tagging"
  type        = bool
  default     = true
}

variable "enable_automated_testing" {
  description = "Enable automated module testing"
  type        = bool
  default     = true
}

variable "module_version" {
  description = "Version of the modules being developed"
  type        = string
  default     = "1.0.0"
  
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+(-[a-zA-Z0-9]+)?$", var.module_version))
    error_message = "Module version must follow semantic versioning format (e.g., 1.0.0 or 1.0.0-beta)."
  }
}

# =============================================================================
# Variable Configuration Notes:
# 
# 1. Module Development Focus:
#    - Variables specifically designed for module development workflows
#    - Testing environment configurations
#    - Module registry integration settings
#    - Version management and tagging
#
# 2. Validation Rules:
#    - Comprehensive validation for all inputs
#    - Module-specific validation patterns
#    - Security validation for sensitive parameters
#    - Format validation for module development
#
# 3. Default Values:
#    - Development-friendly defaults for module creation
#    - Testing-optimized defaults for rapid iteration
#    - Security-first defaults for production modules
#    - Cost-optimized defaults for training environments
#
# 4. Type Safety:
#    - Strong typing for all variables
#    - Complex object types for module configurations
#    - Sensitive marking for security-related variables
#    - Nullable types where appropriate
#
# 5. Documentation:
#    - Clear descriptions for all variables
#    - Module development context
#    - Testing and validation guidance
#    - Security implications noted where relevant
# =============================================================================
