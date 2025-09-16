# AWS Terraform Training - Topic 4: Resource Management & Dependencies
# Terraform Code Lab 4.1 - Variable Definitions
#
# This file defines comprehensive variables for the Resource Management & Dependencies
# lab, demonstrating advanced variable patterns, validation rules, and complex
# data structures for enterprise-scale infrastructure management.

# Environment and Project Configuration
variable "environment" {
  description = "Environment name for resource deployment and configuration"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
  
  validation {
    condition = length(var.environment) >= 3 && length(var.environment) <= 10
    error_message = "Environment name must be between 3 and 10 characters."
  }
}

variable "project_name" {
  description = "Project name for resource identification and grouping"
  type        = string
  default     = "fintech-platform"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition = length(var.project_name) >= 3 && length(var.project_name) <= 30
    error_message = "Project name must be between 3 and 30 characters."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-east-1, eu-west-1, etc."
  }
}

variable "owner_email" {
  description = "Email address of the resource owner for tagging and notifications"
  type        = string
  
  validation {
    condition = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center for resource billing and allocation"
  type        = string
  default     = "engineering"
  
  validation {
    condition = contains(["engineering", "operations", "finance", "marketing", "sales"], var.cost_center)
    error_message = "Cost center must be one of: engineering, operations, finance, marketing, sales."
  }
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
  
  validation {
    condition = split("/", var.vpc_cidr)[1] >= "16" && split("/", var.vpc_cidr)[1] <= "24"
    error_message = "VPC CIDR must have a prefix between /16 and /24."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use for resource deployment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  validation {
    condition = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 6
    error_message = "Must specify between 2 and 6 availability zones."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway for hybrid connectivity"
  type        = bool
  default     = false
}

# Application Configuration
variable "applications" {
  description = "Complex application tier configurations with dependencies"
  type = map(object({
    instance_type     = string
    min_capacity      = number
    max_capacity      = number
    desired_capacity  = number
    health_check_path = string
    port              = number
    protocol          = string
    environment_vars  = map(string)
    security_groups   = list(string)
    subnets          = string
    enable_monitoring = bool
    backup_required   = bool
    dependencies     = list(string)
    scaling_policy = object({
      target_cpu_utilization = number
      scale_up_cooldown      = number
      scale_down_cooldown    = number
    })
  }))
  
  default = {
    web = {
      instance_type     = "t3.medium"
      min_capacity      = 2
      max_capacity      = 10
      desired_capacity  = 3
      health_check_path = "/health"
      port              = 80
      protocol          = "HTTP"
      environment_vars = {
        APP_ENV     = "production"
        LOG_LEVEL   = "info"
        PORT        = "80"
        NODE_ENV    = "production"
      }
      security_groups   = ["web", "common"]
      subnets          = "public"
      enable_monitoring = true
      backup_required   = false
      dependencies     = []
      scaling_policy = {
        target_cpu_utilization = 70
        scale_up_cooldown      = 300
        scale_down_cooldown    = 300
      }
    }
    api = {
      instance_type     = "t3.large"
      min_capacity      = 3
      max_capacity      = 15
      desired_capacity  = 5
      health_check_path = "/api/health"
      port              = 8080
      protocol          = "HTTP"
      environment_vars = {
        APP_ENV      = "production"
        LOG_LEVEL    = "warn"
        DB_POOL_SIZE = "20"
        PORT         = "8080"
        API_VERSION  = "v1"
      }
      security_groups   = ["api", "database", "common"]
      subnets          = "private"
      enable_monitoring = true
      backup_required   = true
      dependencies     = ["database"]
      scaling_policy = {
        target_cpu_utilization = 60
        scale_up_cooldown      = 180
        scale_down_cooldown    = 300
      }
    }
    worker = {
      instance_type     = "t3.xlarge"
      min_capacity      = 1
      max_capacity      = 5
      desired_capacity  = 2
      health_check_path = "/worker/health"
      port              = 9090
      protocol          = "HTTP"
      environment_vars = {
        APP_ENV        = "production"
        LOG_LEVEL      = "debug"
        WORKER_THREADS = "8"
        PORT           = "9090"
        QUEUE_SIZE     = "1000"
      }
      security_groups   = ["worker", "database", "queue", "common"]
      subnets          = "private"
      enable_monitoring = true
      backup_required   = true
      dependencies     = ["database", "queue"]
      scaling_policy = {
        target_cpu_utilization = 80
        scale_up_cooldown      = 120
        scale_down_cooldown    = 600
      }
    }
  }
  
  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      app_config.min_capacity <= app_config.desired_capacity &&
      app_config.desired_capacity <= app_config.max_capacity
    ])
    error_message = "For each application: min_capacity <= desired_capacity <= max_capacity."
  }
  
  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      contains(["t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge"], app_config.instance_type)
    ])
    error_message = "Instance type must be a valid t3 instance type."
  }
}

# Database Configuration
variable "database_config" {
  description = "Comprehensive database configuration with lifecycle management"
  type = object({
    engine                  = string
    engine_version         = string
    instance_class         = string
    allocated_storage      = number
    max_allocated_storage  = number
    backup_retention_period = number
    backup_window         = string
    maintenance_window    = string
    multi_az              = bool
    storage_encrypted     = bool
    deletion_protection   = bool
    performance_insights  = bool
    monitoring_interval   = number
    auto_minor_version_upgrade = bool
  })
  
  default = {
    engine                  = "mysql"
    engine_version         = "8.0"
    instance_class         = "db.t3.medium"
    allocated_storage      = 100
    max_allocated_storage  = 1000
    backup_retention_period = 30
    backup_window         = "03:00-04:00"
    maintenance_window    = "sun:04:00-sun:05:00"
    multi_az              = true
    storage_encrypted     = true
    deletion_protection   = true
    performance_insights  = true
    monitoring_interval   = 60
    auto_minor_version_upgrade = false
  }
  
  validation {
    condition = contains(["mysql", "postgres", "mariadb"], var.database_config.engine)
    error_message = "Database engine must be mysql, postgres, or mariadb."
  }
  
  validation {
    condition = var.database_config.allocated_storage >= 20 && var.database_config.allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
  
  validation {
    condition = var.database_config.backup_retention_period >= 0 && var.database_config.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

# Feature Flags for Conditional Resources
variable "feature_flags" {
  description = "Feature flags for enabling/disabling optional infrastructure components"
  type = object({
    enable_monitoring     = bool
    enable_backup        = bool
    enable_cdn           = bool
    enable_waf           = bool
    enable_elasticsearch = bool
    enable_redis_cache   = bool
    enable_queue         = bool
    enable_secrets_manager = bool
    enable_parameter_store = bool
    enable_cloudtrail    = bool
  })
  
  default = {
    enable_monitoring     = true
    enable_backup        = true
    enable_cdn           = false
    enable_waf           = true
    enable_elasticsearch = false
    enable_redis_cache   = true
    enable_queue         = true
    enable_secrets_manager = true
    enable_parameter_store = true
    enable_cloudtrail    = false
  }
}

# Security Configuration
variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the infrastructure"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
  default     = "terraform-lab-key"
  
  validation {
    condition = length(var.key_pair_name) >= 1 && length(var.key_pair_name) <= 255
    error_message = "Key pair name must be between 1 and 255 characters."
  }
}

# Monitoring and Alerting Configuration
variable "monitoring_config" {
  description = "Configuration for monitoring and alerting"
  type = object({
    enable_detailed_monitoring = bool
    log_retention_days        = number
    alarm_email_endpoints     = list(string)
    dashboard_refresh_interval = string
  })
  
  default = {
    enable_detailed_monitoring = true
    log_retention_days        = 30
    alarm_email_endpoints     = []
    dashboard_refresh_interval = "1m"
  }
  
  validation {
    condition = var.monitoring_config.log_retention_days >= 1 && var.monitoring_config.log_retention_days <= 3653
    error_message = "Log retention days must be between 1 and 3653 (10 years)."
  }
}

# Backup Configuration
variable "backup_config" {
  description = "Configuration for backup and disaster recovery"
  type = object({
    backup_schedule           = string
    backup_retention_days     = number
    cross_region_backup      = bool
    backup_vault_kms_key_id  = string
  })
  
  default = {
    backup_schedule           = "cron(0 2 * * ? *)"  # Daily at 2 AM
    backup_retention_days     = 30
    cross_region_backup      = false
    backup_vault_kms_key_id  = ""
  }
  
  validation {
    condition = var.backup_config.backup_retention_days >= 1 && var.backup_config.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}
