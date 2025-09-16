# AWS Terraform Training - Topic 3: Core Terraform Operations
# Terraform Code Lab 3.1 - Variable Definitions
#
# This file defines comprehensive input variables for core Terraform operations,
# demonstrating advanced variable patterns, validation, and enterprise configuration
# management for resource lifecycle, data sources, provisioners, and meta-arguments.
#
# Learning Objectives:
# 1. Advanced variable definition patterns and validation
# 2. Complex type constraints and default values
# 3. Environment-specific variable organization
# 4. Enterprise variable management and governance
# 5. Resource configuration through variables

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
  description = "Environment name for resource organization"
  type        = string
  
  validation {
    condition = contains(["dev", "development", "staging", "stage", "prod", "production"], var.environment)
    error_message = "Environment must be one of: dev, development, staging, stage, prod, production."
  }
}

variable "project_name" {
  description = "Project name for resource identification"
  type        = string
  default     = "core-terraform-operations"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile for authentication"
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
  description = "ARN of IAM role to assume for cross-account access"
  type        = string
  default     = null
  
  validation {
    condition = var.assume_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.assume_role_arn))
    error_message = "Assume role ARN must be a valid IAM role ARN format."
  }
}

variable "production_role_arn" {
  description = "ARN of IAM role for production environment access"
  type        = string
  default     = null
  
  validation {
    condition = var.production_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.production_role_arn))
    error_message = "Production role ARN must be a valid IAM role ARN format."
  }
}

variable "external_id" {
  description = "External ID for role assumption security"
  type        = string
  default     = null
  sensitive   = true
  
  validation {
    condition = var.external_id == null || length(var.external_id) >= 8
    error_message = "External ID must be at least 8 characters when specified."
  }
}

variable "data_classification" {
  description = "Data classification level for compliance"
  type        = string
  default     = "internal"
  
  validation {
    condition = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

# =============================================================================
# RESOURCE ORGANIZATION VARIABLES
# =============================================================================

variable "owner" {
  description = "Resource owner for accountability"
  type        = string
  default     = "platform-team"
  
  validation {
    condition = length(var.owner) > 0 && length(var.owner) <= 50
    error_message = "Owner must be between 1 and 50 characters."
  }
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
  default     = "engineering"
  
  validation {
    condition = contains(["engineering", "marketing", "sales", "operations", "training"], var.cost_center)
    error_message = "Cost center must be one of: engineering, marketing, sales, operations, training."
  }
}

variable "backup_required" {
  description = "Enable backup for applicable resources"
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Enable monitoring for resources"
  type        = bool
  default     = true
}

# =============================================================================
# NETWORK CONFIGURATION VARIABLES
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = []
  
  validation {
    condition = length(var.availability_zones) <= 6
    error_message = "Maximum of 6 availability zones can be specified."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway for hybrid connectivity"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

# =============================================================================
# COMPUTE CONFIGURATION VARIABLES
# =============================================================================

variable "instance_types" {
  description = "Map of instance types by environment"
  type = map(object({
    web = string
    app = string
    database = string
  }))
  
  default = {
    dev = {
      web      = "t3.micro"
      app      = "t3.micro"
      database = "db.t3.micro"
    }
    staging = {
      web      = "t3.small"
      app      = "t3.small"
      database = "db.t3.small"
    }
    prod = {
      web      = "t3.medium"
      app      = "t3.large"
      database = "db.t3.medium"
    }
  }
}

variable "instance_count" {
  description = "Number of instances per tier"
  type = object({
    web = number
    app = number
  })
  
  default = {
    web = 2
    app = 2
  }
  
  validation {
    condition = var.instance_count.web >= 1 && var.instance_count.web <= 10
    error_message = "Web instance count must be between 1 and 10."
  }
  
  validation {
    condition = var.instance_count.app >= 1 && var.instance_count.app <= 10
    error_message = "App instance count must be between 1 and 10."
  }
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "terraform-lab-key"
  
  validation {
    condition = length(var.key_pair_name) > 0
    error_message = "Key pair name cannot be empty."
  }
}

# =============================================================================
# DATABASE CONFIGURATION VARIABLES
# =============================================================================

variable "database_config" {
  description = "Database configuration parameters"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
    max_allocated_storage = number
    backup_retention_period = number
    backup_window = string
    maintenance_window = string
    multi_az = bool
    storage_encrypted = bool
  })
  
  default = {
    engine                  = "mysql"
    engine_version         = "8.0"
    instance_class         = "db.t3.micro"
    allocated_storage      = 20
    max_allocated_storage  = 100
    backup_retention_period = 7
    backup_window         = "03:00-04:00"
    maintenance_window    = "sun:04:00-sun:05:00"
    multi_az              = false
    storage_encrypted     = true
  }
}

variable "database_credentials" {
  description = "Database credentials configuration"
  type = object({
    username = string
    password = string
    database_name = string
  })
  
  default = {
    username      = "admin"
    password      = "changeme123!"  # In production, use AWS Secrets Manager
    database_name = "appdb"
  }
  
  sensitive = true
}

# =============================================================================
# LOAD BALANCER CONFIGURATION VARIABLES
# =============================================================================

variable "load_balancer_config" {
  description = "Load balancer configuration"
  type = object({
    type = string
    scheme = string
    enable_deletion_protection = bool
    idle_timeout = number
    enable_cross_zone_load_balancing = bool
  })
  
  default = {
    type                            = "application"
    scheme                         = "internet-facing"
    enable_deletion_protection     = false
    idle_timeout                   = 60
    enable_cross_zone_load_balancing = true
  }
}

variable "target_group_config" {
  description = "Target group configuration"
  type = object({
    port = number
    protocol = string
    health_check_path = string
    health_check_interval = number
    health_check_timeout = number
    healthy_threshold = number
    unhealthy_threshold = number
  })
  
  default = {
    port                    = 80
    protocol               = "HTTP"
    health_check_path      = "/"
    health_check_interval  = 30
    health_check_timeout   = 5
    healthy_threshold      = 2
    unhealthy_threshold    = 2
  }
}

# =============================================================================
# SECURITY CONFIGURATION VARIABLES
# =============================================================================

variable "security_groups" {
  description = "Security group configurations"
  type = list(object({
    name        = string
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
  }))
  
  default = [
    {
      name        = "web"
      description = "Security group for web servers"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP access from internet"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS access from internet"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    },
    {
      name        = "app"
      description = "Security group for application servers"
      ingress_rules = [
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
          description = "Application port from VPC"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    },
    {
      name        = "database"
      description = "Security group for database servers"
      ingress_rules = [
        {
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
          description = "MySQL access from VPC"
        }
      ]
      egress_rules = []
    }
  ]
}

# =============================================================================
# FEATURE FLAGS AND TOGGLES
# =============================================================================

variable "feature_flags" {
  description = "Feature flags for enabling/disabling functionality"
  type = object({
    enable_auto_scaling = bool
    enable_cloudwatch_logs = bool
    enable_ssl_termination = bool
    enable_waf = bool
    enable_backup_automation = bool
    enable_cost_optimization = bool
  })
  
  default = {
    enable_auto_scaling      = true
    enable_cloudwatch_logs   = true
    enable_ssl_termination   = false
    enable_waf              = false
    enable_backup_automation = true
    enable_cost_optimization = true
  }
}

# =============================================================================
# PROVISIONER CONFIGURATION VARIABLES
# =============================================================================

variable "provisioner_config" {
  description = "Provisioner configuration settings"
  type = object({
    enable_remote_exec = bool
    enable_file_provisioner = bool
    enable_local_exec = bool
    connection_timeout = string
    retry_attempts = number
  })
  
  default = {
    enable_remote_exec      = true
    enable_file_provisioner = true
    enable_local_exec       = true
    connection_timeout      = "5m"
    retry_attempts         = 3
  }
}

variable "user_data_scripts" {
  description = "User data script configurations"
  type = map(string)
  
  default = {
    web_server = "web_server.sh"
    app_server = "app_server.sh"
    database   = "database.sh"
  }
}

# =============================================================================
# COST MANAGEMENT VARIABLES
# =============================================================================

variable "budget_config" {
  description = "Budget configuration for cost control"
  type = object({
    limit_amount = number
    time_unit = string
    budget_type = string
    threshold_percentage = number
  })
  
  default = {
    limit_amount         = 100
    time_unit           = "MONTHLY"
    budget_type         = "COST"
    threshold_percentage = 80
  }
}

variable "cost_allocation_tags" {
  description = "Additional tags for cost allocation"
  type        = map(string)
  default     = {}
  
  validation {
    condition = length(var.cost_allocation_tags) <= 10
    error_message = "Maximum of 10 cost allocation tags allowed."
  }
}
