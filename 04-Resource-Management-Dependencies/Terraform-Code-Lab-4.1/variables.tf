# AWS Terraform Training - Resource Management & Dependencies
# Lab 4.1: Advanced Resource Dependencies and Meta-Arguments
# File: variables.tf - Comprehensive Variable Definitions for Dependency Management

# ============================================================================
# PROJECT IDENTIFICATION VARIABLES
# ============================================================================

variable "project_name" {
  description = "Name of the project for resource identification and dependency tracking"
  type        = string
  default     = "resource-management-dependencies"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for resource categorization and dependency isolation"
  type        = string
  default     = "lab"
  
  validation {
    condition     = contains(["lab", "development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: lab, development, staging, production."
  }
}

variable "student_name" {
  description = "Student name for resource identification and dependency tracking"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.student_name))
    error_message = "Student name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "owner_email" {
  description = "Email address of the resource owner for dependency notifications"
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
# AWS CONFIGURATION VARIABLES
# ============================================================================

variable "aws_region" {
  description = "AWS region for resource deployment and dependency management"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid AWS region."
  }
}

variable "availability_zones" {
  description = "List of availability zones for multi-AZ dependency patterns"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for dependency patterns."
  }
}

# ============================================================================
# DEPENDENCY MANAGEMENT CONFIGURATION
# ============================================================================

variable "dependency_complexity_level" {
  description = "Level of dependency complexity to demonstrate"
  type        = string
  default     = "advanced"
  
  validation {
    condition = contains([
      "basic", "intermediate", "advanced", "enterprise"
    ], var.dependency_complexity_level)
    error_message = "Dependency complexity level must be one of: basic, intermediate, advanced, enterprise."
  }
}

variable "enable_explicit_dependencies" {
  description = "Enable explicit dependency patterns with depends_on"
  type        = bool
  default     = true
}

variable "enable_lifecycle_management" {
  description = "Enable advanced lifecycle management patterns"
  type        = bool
  default     = true
}

variable "enable_circular_dependency_resolution" {
  description = "Enable circular dependency resolution demonstrations"
  type        = bool
  default     = true
}

# ============================================================================
# INFRASTRUCTURE CONFIGURATION VARIABLES
# ============================================================================

variable "vpc_configuration" {
  description = "VPC configuration for multi-tier dependency architecture"
  type = object({
    cidr_block           = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
    enable_flow_logs     = bool
  })
  default = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_flow_logs     = false
  }
  
  validation {
    condition     = can(cidrhost(var.vpc_configuration.cidr_block, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "subnet_configurations" {
  description = "Subnet configurations for dependency tier separation"
  type = map(object({
    cidr_blocks                = list(string)
    map_public_ip_on_launch   = bool
    availability_zone_mapping = bool
  }))
  default = {
    public = {
      cidr_blocks                = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      map_public_ip_on_launch   = true
      availability_zone_mapping = true
    }
    private = {
      cidr_blocks                = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
      map_public_ip_on_launch   = false
      availability_zone_mapping = true
    }
    database = {
      cidr_blocks                = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
      map_public_ip_on_launch   = false
      availability_zone_mapping = true
    }
  }
}

# ============================================================================
# DATABASE TIER CONFIGURATION
# ============================================================================

variable "database_configuration" {
  description = "Database configuration for dependency demonstration"
  type = object({
    engine                = string
    engine_version        = string
    instance_class        = string
    allocated_storage     = number
    max_allocated_storage = number
    storage_type          = string
    storage_encrypted     = bool
    username              = string
    password              = string
    backup_retention_period = number
    backup_window         = string
    maintenance_window    = string
    multi_az              = bool
    deletion_protection   = bool
  })
  default = {
    engine                = "mysql"
    engine_version        = "8.0"
    instance_class        = "db.t3.micro"
    allocated_storage     = 20
    max_allocated_storage = 100
    storage_type          = "gp2"
    storage_encrypted     = true
    username              = "admin"
    password              = "changeme123!"
    backup_retention_period = 7
    backup_window         = "03:00-04:00"
    maintenance_window    = "sun:04:00-sun:05:00"
    multi_az              = false
    deletion_protection   = false
  }
  
  validation {
    condition     = var.database_configuration.allocated_storage >= 20
    error_message = "Database allocated storage must be at least 20 GB."
  }
}

# ============================================================================
# APPLICATION TIER CONFIGURATION
# ============================================================================

variable "application_tiers" {
  description = "Application tier configurations for for_each demonstration"
  type = map(object({
    instance_type        = string
    min_size            = number
    max_size            = number
    desired_capacity    = number
    health_check_type   = string
    health_check_grace_period = number
    target_group_port   = number
    target_group_protocol = string
    enable_monitoring   = bool
  }))
  default = {
    web = {
      instance_type        = "t3.micro"
      min_size            = 2
      max_size            = 6
      desired_capacity    = 3
      health_check_type   = "ELB"
      health_check_grace_period = 300
      target_group_port   = 80
      target_group_protocol = "HTTP"
      enable_monitoring   = true
    }
    app = {
      instance_type        = "t3.small"
      min_size            = 2
      max_size            = 4
      desired_capacity    = 2
      health_check_type   = "EC2"
      health_check_grace_period = 300
      target_group_port   = 8080
      target_group_protocol = "HTTP"
      enable_monitoring   = false
    }
    api = {
      instance_type        = "t3.micro"
      min_size            = 1
      max_size            = 3
      desired_capacity    = 2
      health_check_type   = "EC2"
      health_check_grace_period = 300
      target_group_port   = 3000
      target_group_protocol = "HTTP"
      enable_monitoring   = false
    }
  }
}

# ============================================================================
# LOAD BALANCER CONFIGURATION
# ============================================================================

variable "load_balancer_configuration" {
  description = "Load balancer configuration for dependency management"
  type = object({
    enable_application_lb = bool
    enable_network_lb     = bool
    internal              = bool
    enable_deletion_protection = bool
    idle_timeout          = number
    enable_cross_zone_load_balancing = bool
  })
  default = {
    enable_application_lb = true
    enable_network_lb     = false
    internal              = false
    enable_deletion_protection = false
    idle_timeout          = 60
    enable_cross_zone_load_balancing = true
  }
}

# ============================================================================
# SECURITY CONFIGURATION
# ============================================================================

variable "security_configuration" {
  description = "Security configuration for dependency-aware security groups"
  type = object({
    enable_strict_security_groups = bool
    allowed_ssh_cidrs            = list(string)
    allowed_http_cidrs           = list(string)
    allowed_https_cidrs          = list(string)
    enable_vpc_flow_logs         = bool
    enable_security_group_logging = bool
  })
  default = {
    enable_strict_security_groups = true
    allowed_ssh_cidrs            = ["10.0.0.0/16"]
    allowed_http_cidrs           = ["0.0.0.0/0"]
    allowed_https_cidrs          = ["0.0.0.0/0"]
    enable_vpc_flow_logs         = false
    enable_security_group_logging = false
  }
}

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

variable "backup_required" {
  description = "Whether backup is required for resources"
  type        = bool
  default     = true
}

variable "encryption_enabled" {
  description = "Enable encryption for storage resources"
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

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2 instances"
  type        = bool
  default     = false
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
  description = "Enable Auto Scaling Groups for application tiers"
  type        = bool
  default     = true
}

variable "enable_rds" {
  description = "Enable RDS database instance"
  type        = bool
  default     = true
}

variable "enable_elasticache" {
  description = "Enable ElastiCache for caching layer"
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

variable "enable_meta_argument_testing" {
  description = "Enable resources for meta-argument testing"
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
  default     = false
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

variable "cross_account_role_arn" {
  description = "Cross-account role ARN for dependency management (optional)"
  type        = string
  default     = ""
}

variable "enable_cross_region_dependencies" {
  description = "Enable cross-region dependency demonstrations"
  type        = bool
  default     = false
}
