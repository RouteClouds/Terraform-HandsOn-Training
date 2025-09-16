# Terraform Code Lab 6.1: Advanced State Management & Backends
# Backend Setup - Variable Definitions
#
# This file defines variables for configuring the enterprise backend
# infrastructure including S3 buckets, DynamoDB tables, KMS keys,
# and IAM policies for secure state management.

variable "organization_name" {
  description = "Organization name for resource naming and tagging"
  type        = string
  default     = "techcorp-global"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.organization_name))
    error_message = "Organization name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in valid format (e.g., us-east-1)."
  }
}

variable "backup_regions" {
  description = "List of regions for cross-region backup"
  type        = list(string)
  default     = ["us-west-2", "eu-west-1"]
  
  validation {
    condition = alltrue([
      for region in var.backup_regions :
      can(regex("^[a-z]{2}-[a-z]+-[0-9]$", region))
    ])
    error_message = "All backup regions must be in valid AWS region format."
  }
}

variable "environments" {
  description = "List of environments to support"
  type        = list(string)
  default     = ["dev", "staging", "prod"]
  
  validation {
    condition = alltrue([
      for env in var.environments :
      contains(["dev", "staging", "prod"], env)
    ])
    error_message = "Environments must be dev, staging, or prod."
  }
}

variable "compliance_requirements" {
  description = "Compliance and governance requirements"
  type = object({
    encryption_required = bool
    audit_logging      = bool
    cross_region_backup = bool
    retention_years    = number
    data_classification = string
  })
  
  default = {
    encryption_required = true
    audit_logging      = true
    cross_region_backup = true
    retention_years    = 7
    data_classification = "confidential"
  }
  
  validation {
    condition = contains(["public", "internal", "confidential", "restricted"], var.compliance_requirements.data_classification)
    error_message = "Data classification must be public, internal, confidential, or restricted."
  }
  
  validation {
    condition = var.compliance_requirements.retention_years >= 1 && var.compliance_requirements.retention_years <= 10
    error_message = "Retention years must be between 1 and 10."
  }
}

variable "team_configurations" {
  description = "Team-specific backend access configurations"
  type = map(object({
    team_name = string
    projects  = list(string)
    access_level = string
    backup_frequency = string
  }))
  
  default = {
    foundation = {
      team_name = "Foundation Infrastructure"
      projects  = ["network", "security", "dns"]
      access_level = "admin"
      backup_frequency = "daily"
    }
    platform = {
      team_name = "Platform Services"
      projects  = ["monitoring", "logging", "service-mesh"]
      access_level = "write"
      backup_frequency = "daily"
    }
    applications = {
      team_name = "Application Teams"
      projects  = ["web-app", "api-service", "database"]
      access_level = "write"
      backup_frequency = "hourly"
    }
    governance = {
      team_name = "Governance and Compliance"
      projects  = ["policies", "monitoring", "cost-management"]
      access_level = "admin"
      backup_frequency = "daily"
    }
  }
  
  validation {
    condition = alltrue([
      for team_name, team_config in var.team_configurations :
      contains(["read", "write", "admin"], team_config.access_level)
    ])
    error_message = "Access level must be read, write, or admin."
  }
  
  validation {
    condition = alltrue([
      for team_name, team_config in var.team_configurations :
      contains(["hourly", "daily", "weekly"], team_config.backup_frequency)
    ])
    error_message = "Backup frequency must be hourly, daily, or weekly."
  }
}

variable "monitoring_configuration" {
  description = "Monitoring and alerting configuration for backend operations"
  type = object({
    enable_detailed_monitoring = bool
    enable_cost_monitoring    = bool
    alert_email_addresses     = list(string)
    slack_webhook_url        = string
    dashboard_enabled        = bool
  })
  
  default = {
    enable_detailed_monitoring = true
    enable_cost_monitoring    = true
    alert_email_addresses     = []
    slack_webhook_url        = ""
    dashboard_enabled        = true
  }
  
  validation {
    condition = alltrue([
      for email in var.monitoring_configuration.alert_email_addresses :
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All alert email addresses must be valid email format."
  }
}

variable "security_configuration" {
  description = "Security configuration for backend infrastructure"
  type = object({
    enable_mfa_delete        = bool
    enable_access_logging    = bool
    enable_object_lock       = bool
    enable_vpc_endpoints     = bool
    allowed_ip_ranges        = list(string)
    require_ssl              = bool
  })
  
  default = {
    enable_mfa_delete     = true
    enable_access_logging = true
    enable_object_lock    = false
    enable_vpc_endpoints  = true
    allowed_ip_ranges     = []
    require_ssl           = true
  }
  
  validation {
    condition = alltrue([
      for cidr in var.security_configuration.allowed_ip_ranges :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All allowed IP ranges must be valid CIDR blocks."
  }
}

variable "cost_optimization" {
  description = "Cost optimization settings for backend resources"
  type = object({
    enable_intelligent_tiering = bool
    enable_lifecycle_policies  = bool
    transition_to_ia_days      = number
    transition_to_glacier_days = number
    delete_old_versions_days   = number
  })
  
  default = {
    enable_intelligent_tiering = true
    enable_lifecycle_policies  = true
    transition_to_ia_days      = 30
    transition_to_glacier_days = 90
    delete_old_versions_days   = 2555  # 7 years
  }
  
  validation {
    condition = var.cost_optimization.transition_to_ia_days < var.cost_optimization.transition_to_glacier_days
    error_message = "IA transition must occur before Glacier transition."
  }
  
  validation {
    condition = var.cost_optimization.delete_old_versions_days >= 365
    error_message = "Old version deletion must be at least 1 year for compliance."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for key, value in var.tags :
      can(regex("^[a-zA-Z0-9\\s\\-\\._:/=+@]+$", key)) && can(regex("^[a-zA-Z0-9\\s\\-\\._:/=+@]*$", value))
    ])
    error_message = "Tag keys and values must contain only alphanumeric characters, spaces, and the following characters: - . _ : / = + @"
  }
}
