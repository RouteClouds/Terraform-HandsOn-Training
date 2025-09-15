# AWS Terraform Training - Core Terraform Operations
# Lab 3.1: Core Workflow and Resource Lifecycle Management
# File: variables.tf - Variable Definitions

# ============================================================================
# PROJECT IDENTIFICATION VARIABLES
# ============================================================================

variable "project_name" {
  description = "Name of the project for resource identification"
  type        = string
  default     = "core-terraform-operations"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "lab"
  
  validation {
    condition     = contains(["lab", "development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: lab, development, staging, production."
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
  description = "Email address of the resource owner"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "training"
}

# ============================================================================
# AWS CONFIGURATION VARIABLES
# ============================================================================

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid AWS region."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified."
  }
}

# ============================================================================
# INFRASTRUCTURE CONFIGURATION VARIABLES
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  
  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnet CIDRs must be specified."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
  
  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least 2 private subnet CIDRs must be specified."
  }
}

# ============================================================================
# EC2 CONFIGURATION VARIABLES
# ============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium", "t3.large"
    ], var.instance_type)
    error_message = "Instance type must be a valid t3 instance type."
  }
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
  default     = ""
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2 instances"
  type        = bool
  default     = false
}

# ============================================================================
# LOAD BALANCER CONFIGURATION VARIABLES
# ============================================================================

variable "enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "load_balancer_type" {
  description = "Type of load balancer (application or network)"
  type        = string
  default     = "application"
  
  validation {
    condition     = contains(["application", "network"], var.load_balancer_type)
    error_message = "Load balancer type must be either 'application' or 'network'."
  }
}

# ============================================================================
# STORAGE CONFIGURATION VARIABLES
# ============================================================================

variable "create_s3_bucket" {
  description = "Create S3 bucket for application data"
  type        = bool
  default     = true
}

variable "s3_bucket_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "s3_lifecycle_enabled" {
  description = "Enable S3 lifecycle management"
  type        = bool
  default     = true
}

# ============================================================================
# MONITORING AND LOGGING VARIABLES
# ============================================================================

variable "monitoring_enabled" {
  description = "Enable CloudWatch monitoring and logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

# ============================================================================
# SECURITY CONFIGURATION VARIABLES
# ============================================================================

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
  
  validation {
    condition = contains([
      "public", "internal", "confidential", "restricted"
    ], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "backup_required" {
  description = "Whether backup is required for resources"
  type        = bool
  default     = false
}

variable "encryption_enabled" {
  description = "Enable encryption for storage resources"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this in production
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ============================================================================
# COST OPTIMIZATION VARIABLES
# ============================================================================

variable "auto_shutdown_enabled" {
  description = "Enable automatic shutdown for cost optimization"
  type        = bool
  default     = true
}

variable "auto_shutdown_hours" {
  description = "Hours after which resources should auto-shutdown"
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
# FEATURE TOGGLE VARIABLES
# ============================================================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false  # Disabled for cost optimization in lab
}

variable "enable_bastion_host" {
  description = "Enable bastion host for secure access"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = false
}

variable "enable_rds" {
  description = "Enable RDS database instance"
  type        = bool
  default     = false
}

# ============================================================================
# TESTING AND VALIDATION VARIABLES
# ============================================================================

variable "enable_dependency_testing" {
  description = "Enable resources for dependency testing"
  type        = bool
  default     = true
}

variable "enable_lifecycle_testing" {
  description = "Enable resources for lifecycle testing"
  type        = bool
  default     = true
}

variable "enable_performance_testing" {
  description = "Enable resources for performance testing"
  type        = bool
  default     = true
}

# ============================================================================
# ADVANCED CONFIGURATION VARIABLES
# ============================================================================

variable "custom_tags" {
  description = "Additional custom tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "resource_prefix" {
  description = "Prefix for resource names to avoid conflicts"
  type        = string
  default     = "lab"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Resource prefix must contain only lowercase letters, numbers, and hyphens."
  }
}
