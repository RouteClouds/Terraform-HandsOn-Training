# Variables for Terraform Modules and Module Development Demo

# Project Configuration
variable "project_name" {
  description = "Name of the project - used for resource naming"
  type        = string
  default     = "terraform-modules-demo"
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "Project name must be between 1 and 32 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Platform Team"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-east-1, eu-west-1, etc."
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

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid IPv4 CIDR blocks."
  }
}

# Compute Configuration
variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
  default     = ""
}

# Database Configuration
variable "db_storage_size" {
  description = "Initial storage size for RDS instance (GB)"
  type        = number
  default     = 20
  
  validation {
    condition     = var.db_storage_size >= 20 && var.db_storage_size <= 65536
    error_message = "Database storage size must be between 20 and 65536 GB."
  }
}

variable "db_max_storage_size" {
  description = "Maximum storage size for RDS instance (GB)"
  type        = number
  default     = 100
  
  validation {
    condition     = var.db_max_storage_size >= 20 && var.db_max_storage_size <= 65536
    error_message = "Maximum database storage size must be between 20 and 65536 GB."
  }
}

# SSL/TLS Configuration
variable "enable_ssl" {
  description = "Enable SSL/TLS for the load balancer"
  type        = bool
  default     = false
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = ""
  
  validation {
    condition = var.ssl_certificate_arn == "" || can(regex("^arn:aws:acm:", var.ssl_certificate_arn))
    error_message = "SSL certificate ARN must be a valid ACM certificate ARN or empty string."
  }
}

# Monitoring Configuration
variable "sns_topic_arn" {
  description = "ARN of SNS topic for alerts"
  type        = string
  default     = ""
  
  validation {
    condition = var.sns_topic_arn == "" || can(regex("^arn:aws:sns:", var.sns_topic_arn))
    error_message = "SNS topic ARN must be a valid SNS topic ARN or empty string."
  }
}

# Feature Flags
variable "enable_monitoring" {
  description = "Enable detailed monitoring and alerting"
  type        = bool
  default     = true
}

variable "enable_backups" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption for storage resources"
  type        = bool
  default     = true
}

# Cost Optimization
variable "enable_cost_optimization" {
  description = "Enable cost optimization features (scheduled scaling, etc.)"
  type        = bool
  default     = true
}

# Module Configuration Examples
variable "module_composition_pattern" {
  description = "Module composition pattern to demonstrate (monolithic, layered, microservice, composite)"
  type        = string
  default     = "layered"
  
  validation {
    condition     = contains(["monolithic", "layered", "microservice", "composite"], var.module_composition_pattern)
    error_message = "Module composition pattern must be one of: monolithic, layered, microservice, composite."
  }
}

# Advanced Module Features
variable "enable_conditional_resources" {
  description = "Enable conditional resource creation examples"
  type        = bool
  default     = true
}

variable "enable_dynamic_configuration" {
  description = "Enable dynamic configuration examples"
  type        = bool
  default     = true
}

variable "enable_cross_module_dependencies" {
  description = "Enable cross-module dependency examples"
  type        = bool
  default     = true
}

# Testing Configuration
variable "enable_testing_resources" {
  description = "Enable resources for testing module functionality"
  type        = bool
  default     = false
}

variable "test_scenarios" {
  description = "List of test scenarios to enable"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for scenario in var.test_scenarios : contains([
        "basic_functionality",
        "high_availability",
        "disaster_recovery",
        "security_compliance",
        "performance_testing"
      ], scenario)
    ])
    error_message = "Test scenarios must be from the predefined list of valid scenarios."
  }
}

# Environment-Specific Overrides
variable "environment_overrides" {
  description = "Environment-specific configuration overrides"
  type = object({
    instance_type     = optional(string)
    min_instances     = optional(number)
    max_instances     = optional(number)
    db_instance_class = optional(string)
    enable_multi_az   = optional(bool)
    backup_retention  = optional(number)
  })
  default = {}
}

# Tagging Configuration
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for key, value in var.additional_tags : length(key) <= 128 && length(value) <= 256
    ])
    error_message = "Tag keys must be <= 128 characters and values must be <= 256 characters."
  }
}

# Module Source Configuration
variable "module_sources" {
  description = "Configuration for module sources (local, git, registry)"
  type = object({
    use_local_modules    = optional(bool, true)
    use_git_modules      = optional(bool, false)
    use_registry_modules = optional(bool, false)
    git_base_url        = optional(string, "")
    registry_namespace  = optional(string, "")
  })
  default = {}
}

# Validation and Testing
variable "enable_input_validation" {
  description = "Enable comprehensive input validation examples"
  type        = bool
  default     = true
}

variable "enable_output_validation" {
  description = "Enable output validation examples"
  type        = bool
  default     = true
}

# Documentation and Examples
variable "generate_documentation" {
  description = "Generate module documentation and examples"
  type        = bool
  default     = true
}

variable "include_usage_examples" {
  description = "Include usage examples in module outputs"
  type        = bool
  default     = true
}
