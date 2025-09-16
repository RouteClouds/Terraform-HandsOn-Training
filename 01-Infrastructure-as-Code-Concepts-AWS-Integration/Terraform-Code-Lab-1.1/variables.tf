# Variables Configuration for Infrastructure as Code Lab 1.1
# Topic 1: Infrastructure as Code Concepts & AWS Integration
#
# This file defines all input variables for the lab with comprehensive
# descriptions, types, validation rules, and default values following
# enterprise best practices for Infrastructure as Code.
#
# Variable Categories:
# 1. Project and Environment Configuration
# 2. AWS Provider Configuration
# 3. Network Configuration
# 4. Compute Configuration
# 5. Database Configuration
# 6. Security Configuration
# 7. Cost and Governance Configuration
# 8. Monitoring and Operations Configuration
#
# Last Updated: January 2025

# =============================================================================
# 1. PROJECT AND ENVIRONMENT CONFIGURATION
# =============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and tagging. Used as prefix for all resources."
  type        = string
  default     = "iac-lab-1"
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be between 1 and 20 characters."
  }
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for resource organization and lifecycle management"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "created_by" {
  description = "Name or identifier of the person/system creating the infrastructure"
  type        = string
  default     = "terraform-lab-student"
  
  validation {
    condition     = length(var.created_by) > 0 && length(var.created_by) <= 50
    error_message = "Created by must be between 1 and 50 characters."
  }
}

variable "business_unit" {
  description = "Business unit responsible for the infrastructure and associated costs"
  type        = string
  default     = "training"
  
  validation {
    condition     = contains(["training", "engineering", "product", "operations", "finance"], var.business_unit)
    error_message = "Business unit must be one of: training, engineering, product, operations, finance."
  }
}

variable "student_group" {
  description = "Student group or class identifier for educational tracking"
  type        = string
  default     = "terraform-basics-2025"
  
  validation {
    condition     = length(var.student_group) > 0 && length(var.student_group) <= 30
    error_message = "Student group must be between 1 and 30 characters."
  }
}

# =============================================================================
# 2. AWS PROVIDER CONFIGURATION
# =============================================================================

variable "aws_region" {
  description = "AWS region for resource deployment. Standardized to us-east-1 for all labs."
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-east-1, eu-west-1, etc."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication (optional)"
  type        = string
  default     = null
}

variable "assume_role_arn" {
  description = "ARN of IAM role to assume for cross-account access (optional)"
  type        = string
  default     = null
  
  validation {
    condition = var.assume_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.assume_role_arn))
    error_message = "Assume role ARN must be a valid IAM role ARN format."
  }
}

# =============================================================================
# 3. NETWORK CONFIGURATION
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be a valid IPv4 CIDR block."
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
  
  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 24
    error_message = "VPC CIDR prefix must be between /16 and /24."
  }
}

variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  
  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 6
    error_message = "Must specify between 2 and 6 availability zones."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC for better resource identification"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC for name resolution"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for cost optimization (not recommended for production)"
  type        = bool
  default     = false
}

# =============================================================================
# 4. COMPUTE CONFIGURATION
# =============================================================================

variable "instance_type" {
  description = "EC2 instance type for web servers. Optimized for cost and performance."
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge",
      "t3a.micro", "t3a.small", "t3a.medium", "t3a.large",
      "m5.large", "m5.xlarge", "c5.large", "c5.xlarge"
    ], var.instance_type)
    error_message = "Instance type must be a supported type for this lab."
  }
}

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 1
  
  validation {
    condition     = var.min_size >= 1 && var.min_size <= 10
    error_message = "Minimum size must be between 1 and 10."
  }
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 3
  
  validation {
    condition     = var.max_size >= 1 && var.max_size <= 20
    error_message = "Maximum size must be between 1 and 20."
  }
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 2
  
  validation {
    condition     = var.desired_capacity >= 1 && var.desired_capacity <= 10
    error_message = "Desired capacity must be between 1 and 10."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2 instances"
  type        = bool
  default     = true
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access (optional)"
  type        = string
  default     = null
}

# =============================================================================
# 5. DATABASE CONFIGURATION
# =============================================================================

variable "db_instance_class" {
  description = "RDS instance class for the database server"
  type        = string
  default     = "db.t3.micro"
  
  validation {
    condition = contains([
      "db.t3.micro", "db.t3.small", "db.t3.medium",
      "db.t4g.micro", "db.t4g.small", "db.t4g.medium",
      "db.m5.large", "db.m5.xlarge"
    ], var.db_instance_class)
    error_message = "Database instance class must be a supported type for this lab."
  }
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance in GB"
  type        = number
  default     = 20
  
  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 100
    error_message = "Database storage must be between 20 and 100 GB."
  }
}

variable "db_engine_version" {
  description = "MySQL engine version for RDS instance"
  type        = string
  default     = "8.0"
  
  validation {
    condition     = contains(["8.0", "5.7"], var.db_engine_version)
    error_message = "Database engine version must be 8.0 or 5.7."
  }
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated database backups"
  type        = number
  default     = 7
  
  validation {
    condition     = var.db_backup_retention_period >= 1 && var.db_backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment for RDS instance (high availability)"
  type        = bool
  default     = false
}

# =============================================================================
# 6. SECURITY CONFIGURATION
# =============================================================================

variable "data_classification" {
  description = "Data classification level for compliance and security controls"
  type        = string
  default     = "internal"
  
  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "encryption_at_rest" {
  description = "Enable encryption at rest for all storage resources"
  type        = bool
  default     = true
}

variable "encryption_in_transit" {
  description = "Enable encryption in transit for all network communications"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail for audit logging and compliance"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config for configuration compliance monitoring"
  type        = bool
  default     = false
}

variable "compliance_scope" {
  description = "Compliance framework scope for the infrastructure"
  type        = string
  default     = "none"
  
  validation {
    condition     = contains(["none", "soc2", "hipaa", "pci", "gdpr"], var.compliance_scope)
    error_message = "Compliance scope must be one of: none, soc2, hipaa, pci, gdpr."
  }
}

# =============================================================================
# 7. COST AND GOVERNANCE CONFIGURATION
# =============================================================================

variable "cost_center" {
  description = "Cost center for billing and financial reporting"
  type        = string
  default     = "training"
  
  validation {
    condition     = length(var.cost_center) > 0 && length(var.cost_center) <= 20
    error_message = "Cost center must be between 1 and 20 characters."
  }
}

variable "owner_email" {
  description = "Email address of the infrastructure owner for notifications and billing"
  type        = string
  default     = "student@company.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address format."
  }
}

variable "budget_limit" {
  description = "Monthly budget limit in USD for cost monitoring and alerts"
  type        = number
  default     = 50
  
  validation {
    condition     = var.budget_limit > 0 && var.budget_limit <= 1000
    error_message = "Budget limit must be between 1 and 1000 USD."
  }
}

variable "auto_shutdown_enabled" {
  description = "Enable automatic shutdown of non-production resources for cost optimization"
  type        = bool
  default     = true
}

variable "auto_shutdown_schedule" {
  description = "Cron expression for automatic shutdown schedule (UTC)"
  type        = string
  default     = "0 22 * * MON-FRI"
  
  validation {
    condition     = can(regex("^[0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [A-Z*,-]+$", var.auto_shutdown_schedule))
    error_message = "Auto shutdown schedule must be a valid cron expression."
  }
}

# =============================================================================
# 8. MONITORING AND OPERATIONS CONFIGURATION
# =============================================================================

variable "monitoring_level" {
  description = "Level of monitoring and alerting for the infrastructure"
  type        = string
  default     = "basic"
  
  validation {
    condition     = contains(["basic", "standard", "enhanced", "comprehensive"], var.monitoring_level)
    error_message = "Monitoring level must be one of: basic, standard, enhanced, comprehensive."
  }
}

variable "backup_required" {
  description = "Indicates if automated backups are required for compliance"
  type        = string
  default     = "yes"
  
  validation {
    condition     = contains(["yes", "no"], var.backup_required)
    error_message = "Backup required must be 'yes' or 'no'."
  }
}

variable "lifecycle_stage" {
  description = "Current lifecycle stage of the infrastructure"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["development", "testing", "staging", "production", "deprecated"], var.lifecycle_stage)
    error_message = "Lifecycle stage must be one of: development, testing, staging, production, deprecated."
  }
}

variable "maintenance_window" {
  description = "Preferred maintenance window for updates and patches (UTC)"
  type        = string
  default     = "sun:03:00-sun:04:00"
  
  validation {
    condition     = can(regex("^[a-z]{3}:[0-9]{2}:[0-9]{2}-[a-z]{3}:[0-9]{2}:[0-9]{2}$", var.maintenance_window))
    error_message = "Maintenance window must be in format: sun:03:00-sun:04:00."
  }
}

variable "support_level" {
  description = "Support level for the infrastructure and applications"
  type        = string
  default     = "basic"
  
  validation {
    condition     = contains(["basic", "business", "enterprise"], var.support_level)
    error_message = "Support level must be one of: basic, business, enterprise."
  }
}

variable "notification_email" {
  description = "Email address for operational notifications and alerts"
  type        = string
  default     = null
  
  validation {
    condition = var.notification_email == null || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Notification email must be a valid email address format."
  }
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights for RDS monitoring and optimization"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
  
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

# =============================================================================
# VARIABLE DEPENDENCIES AND VALIDATION
# =============================================================================

# Validation to ensure desired capacity is within min/max range
locals {
  capacity_validation = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
}

# Additional validation for complex relationships
variable "validate_capacity_range" {
  description = "Internal validation for capacity range consistency"
  type        = bool
  default     = true
  
  validation {
    condition     = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
    error_message = "Desired capacity must be between min_size and max_size."
  }
}
