# Terraform Code Lab 5.1: Advanced Variables and Outputs
# Comprehensive Variable Definitions
#
# This file demonstrates advanced variable patterns including complex types,
# comprehensive validation rules, enterprise governance, and best practices
# for large-scale infrastructure deployments.

# AWS Region Configuration
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in valid format (e.g., us-east-1)."
  }
}

# Environment Configuration
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

# Organization Configuration
variable "organization_config" {
  description = <<-EOT
    Organization-wide configuration and governance settings.
    
    This comprehensive configuration defines organization-level settings including
    governance policies, security baselines, compliance requirements, and
    operational standards that apply across all environments and applications.
    
    Usage Examples:
    - Enterprise governance and compliance enforcement
    - Security baseline configuration across all resources
    - Cost management and resource tagging standards
    - Audit and change management requirements
    
    Dependencies:
    - Must align with organizational security policies
    - Requires compliance team approval for changes
    - Integrates with enterprise monitoring and governance tools
  EOT
  
  type = object({
    # Basic organization information
    name                = string
    domain              = string
    primary_region      = string
    backup_region       = string
    compliance_level    = string
    cost_center_default = string
    data_classification = string
    
    # Governance and change management
    governance = object({
      change_approval_required = bool
      multi_environment_sync   = bool
      audit_logging_enabled    = bool
      compliance_scanning      = bool
      policy_enforcement       = bool
      automated_remediation    = bool
    })
    
    # Security baseline requirements
    security_baseline = object({
      encryption_required       = bool
      mfa_required             = bool
      network_isolation        = bool
      data_loss_prevention     = bool
      vulnerability_scanning   = bool
      penetration_testing      = bool
      security_monitoring      = bool
      incident_response        = bool
    })
    
    # Compliance and regulatory requirements
    compliance = object({
      gdpr_required     = bool
      hipaa_required    = bool
      sox_required      = bool
      pci_dss_required  = bool
      iso27001_required = bool
      fedramp_required  = bool
    })
    
    # Cost management and optimization
    cost_management = object({
      budget_alerts_enabled    = bool
      cost_optimization       = bool
      resource_tagging_required = bool
      spend_analysis          = bool
      rightsizing_enabled     = bool
    })
  })
  
  # Comprehensive validation rules
  validation {
    condition = can(regex("^[a-zA-Z0-9\\s\\-\\.]+$", var.organization_config.name))
    error_message = "Organization name must contain only letters, numbers, spaces, hyphens, and periods."
  }
  
  validation {
    condition = can(regex("^[a-z0-9\\-\\.]+\\.[a-z]{2,}$", var.organization_config.domain))
    error_message = "Domain must be a valid domain name format."
  }
  
  validation {
    condition = contains(["low", "medium", "high", "critical"], var.organization_config.compliance_level)
    error_message = "Compliance level must be low, medium, high, or critical."
  }
  
  validation {
    condition = contains(["public", "internal", "confidential", "restricted"], var.organization_config.data_classification)
    error_message = "Data classification must be public, internal, confidential, or restricted."
  }
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.organization_config.primary_region))
    error_message = "Primary region must be a valid AWS region format."
  }
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.organization_config.backup_region))
    error_message = "Backup region must be a valid AWS region format."
  }
  
  validation {
    condition = var.organization_config.primary_region != var.organization_config.backup_region
    error_message = "Primary and backup regions must be different."
  }
}

# Network Configuration
variable "network_configuration" {
  description = <<-EOT
    Comprehensive network configuration with advanced CIDR validation and security.
    
    This configuration defines the complete network architecture including VPC,
    subnets, gateways, and security settings. It supports multi-AZ deployments
    with proper CIDR allocation and security controls.
    
    Features:
    - Automatic subnet CIDR calculation and validation
    - Multi-AZ deployment support
    - Gateway and routing configuration
    - Network security and access controls
    - DNS and connectivity settings
    
    Validation:
    - CIDR blocks must be valid IPv4 ranges
    - Subnet CIDRs must not overlap
    - Security configurations must meet baseline requirements
  EOT
  
  type = object({
    # VPC configuration
    vpc = object({
      cidr_block           = string
      enable_dns_hostnames = bool
      enable_dns_support   = bool
      instance_tenancy     = string
    })
    
    # Subnet configuration with automatic CIDR calculation
    subnets = object({
      public = list(object({
        name              = string
        cidr_block        = string
        availability_zone = string
        map_public_ip     = bool
      }))
      
      private = list(object({
        name              = string
        cidr_block        = string
        availability_zone = string
      }))
      
      database = list(object({
        name              = string
        cidr_block        = string
        availability_zone = string
      }))
    })
    
    # Gateway and routing configuration
    gateways = object({
      internet_gateway = object({
        enabled = bool
      })
      
      nat_gateway = object({
        enabled = bool
        type    = string  # "instance" or "gateway"
        high_availability = bool
      })
      
      vpn_gateway = object({
        enabled = bool
        type    = string
        amazon_side_asn = number
      })
    })
    
    # Security and monitoring configuration
    security = object({
      flow_logs_enabled = bool
      flow_logs_destination = string
      
      # Network ACL configuration
      network_acls = list(object({
        name = string
        rules = list(object({
          rule_number = number
          protocol    = string
          rule_action = string
          cidr_block  = string
          from_port   = number
          to_port     = number
        }))
      }))
      
      # Security baseline enforcement
      security_baseline = object({
        restrict_default_sg = bool
        enable_guardduty   = bool
        enable_config      = bool
        enable_cloudtrail  = bool
      })
    })
  })
  
  # CIDR and network validation
  validation {
    condition = can(cidrhost(var.network_configuration.vpc.cidr_block, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
  
  validation {
    condition = tonumber(split("/", var.network_configuration.vpc.cidr_block)[1]) >= 16 && tonumber(split("/", var.network_configuration.vpc.cidr_block)[1]) <= 24
    error_message = "VPC CIDR must have a prefix between /16 and /24."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.network_configuration.subnets.public :
      can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All public subnet CIDR blocks must be valid."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.network_configuration.subnets.private :
      can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All private subnet CIDR blocks must be valid."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.network_configuration.subnets.database :
      can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All database subnet CIDR blocks must be valid."
  }
  
  validation {
    condition = contains(["default", "dedicated", "host"], var.network_configuration.vpc.instance_tenancy)
    error_message = "Instance tenancy must be default, dedicated, or host."
  }
  
  validation {
    condition = contains(["instance", "gateway"], var.network_configuration.gateways.nat_gateway.type)
    error_message = "NAT gateway type must be instance or gateway."
  }
  
  validation {
    condition = contains(["cloud-watch-logs", "s3"], var.network_configuration.security.flow_logs_destination)
    error_message = "Flow logs destination must be cloud-watch-logs or s3."
  }
}

# Application Configuration
variable "applications" {
  description = <<-EOT
    Comprehensive application configurations with advanced validation and governance.
    
    This variable defines complete application configurations including metadata,
    infrastructure requirements, security settings, monitoring configuration,
    and compliance requirements. Each application is validated against enterprise
    standards and governance policies.
    
    Features:
    - Complete application lifecycle management
    - Infrastructure and scaling configuration
    - Security and compliance enforcement
    - Monitoring and alerting setup
    - Cost optimization and resource management
    
    Validation:
    - Application names must follow naming conventions
    - Resource configurations must meet minimum requirements
    - Security settings must comply with baseline policies
    - Monitoring must be configured for production workloads
  EOT
  
  type = map(object({
    # Application metadata and identification
    metadata = object({
      name            = string
      version         = string
      description     = string
      team_email      = string
      repository_url  = string
      documentation_url = string
      support_contact = string
      business_unit   = string
      cost_center     = string
    })
    
    # Infrastructure and compute configuration
    infrastructure = object({
      instance_type     = string
      min_capacity      = number
      max_capacity      = number
      desired_capacity  = number
      availability_zones = list(string)
      
      # Storage configuration
      storage = object({
        root_volume_size = number
        root_volume_type = string
        root_volume_encrypted = bool
        additional_volumes = list(object({
          size        = number
          type        = string
          encrypted   = bool
          mount_point = string
          iops        = number
        }))
      })
      
      # Auto Scaling configuration
      auto_scaling = object({
        scale_up_adjustment   = number
        scale_down_adjustment = number
        scale_up_cooldown    = number
        scale_down_cooldown  = number
        target_cpu_utilization = number
        target_memory_utilization = number
        predictive_scaling   = bool
      })
    })
    
    # Network and connectivity configuration
    network = object({
      vpc_id              = string
      subnet_type         = string
      security_groups     = list(string)
      load_balancer_type  = string
      health_check_path   = string
      health_check_interval = number
      health_check_timeout  = number
      
      # SSL/TLS configuration
      ssl_config = object({
        certificate_arn = string
        ssl_policy     = string
        redirect_http  = bool
        hsts_enabled   = bool
      })
      
      # CDN configuration
      cdn_config = object({
        enabled = bool
        price_class = string
        geo_restriction = object({
          restriction_type = string
          locations       = list(string)
        })
      })
    })
    
    # Application-specific settings
    application = object({
      port              = number
      protocol          = string
      environment_vars  = map(string)
      secrets          = list(string)
      configuration_files = list(string)
      
      # Application performance
      performance = object({
        cpu_request    = string
        memory_request = string
        cpu_limit      = string
        memory_limit   = string
        jvm_options    = string
      })
      
      # Health and readiness checks
      health_checks = object({
        readiness_probe = object({
          path               = string
          initial_delay_seconds = number
          period_seconds     = number
          timeout_seconds    = number
          failure_threshold  = number
        })
        liveness_probe = object({
          path               = string
          initial_delay_seconds = number
          period_seconds     = number
          timeout_seconds    = number
          failure_threshold  = number
        })
      })
    })

    # Monitoring and observability configuration
    monitoring = object({
      enable_detailed_monitoring = bool
      enable_container_insights  = bool
      log_retention_days        = number
      custom_metrics           = list(string)

      # Alerting configuration
      alerting = object({
        email_endpoints    = list(string)
        slack_webhook_url  = string
        pagerduty_key     = string
        alert_thresholds = object({
          cpu_high        = number
          memory_high     = number
          disk_high       = number
          error_rate_high = number
          response_time_high = number
        })
      })

      # Logging configuration
      logging = object({
        log_level        = string
        structured_logs  = bool
        log_aggregation  = bool
        retention_policy = string
      })
    })

    # Security and compliance configuration
    security = object({
      enable_waf           = bool
      enable_ddos_protection = bool
      enable_encryption    = bool
      backup_required      = bool

      # Access control and authentication
      access_control = object({
        authentication_method = string
        authorization_policy  = string
        session_timeout      = number
        max_concurrent_sessions = number
        mfa_required         = bool
      })

      # Data protection
      data_protection = object({
        encryption_at_rest   = bool
        encryption_in_transit = bool
        key_rotation_enabled = bool
        data_masking        = bool
      })
    })

    # Compliance and governance
    compliance = object({
      data_classification   = string
      retention_policy     = string
      audit_logging        = bool
      compliance_scanning  = bool

      # Regulatory requirements
      regulatory = object({
        gdpr_compliant     = bool
        hipaa_compliant    = bool
        sox_compliant      = bool
        pci_dss_compliant  = bool
      })

      # Change management
      change_management = object({
        approval_required = bool
        testing_required  = bool
        rollback_plan    = bool
      })
    })
  }))

  # Comprehensive validation rules for applications
  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      can(regex("^[a-z0-9-]+$", app_config.metadata.name))
    ])
    error_message = "All application names must contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", app_config.metadata.version))
    ])
    error_message = "All application versions must follow semantic versioning (x.y.z)."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", app_config.metadata.team_email))
    ])
    error_message = "All team emails must be valid email addresses."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      app_config.infrastructure.min_capacity <= app_config.infrastructure.desired_capacity &&
      app_config.infrastructure.desired_capacity <= app_config.infrastructure.max_capacity
    ])
    error_message = "For each application: min_capacity <= desired_capacity <= max_capacity."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      contains(["t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge", "m5.large", "m5.xlarge", "c5.large", "c5.xlarge"], app_config.infrastructure.instance_type)
    ])
    error_message = "Instance types must be from the approved list of t3, m5, or c5 instance types."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      app_config.application.port >= 1024 && app_config.application.port <= 65535
    ])
    error_message = "Application ports must be between 1024 and 65535."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      contains(["HTTP", "HTTPS", "TCP", "UDP"], app_config.application.protocol)
    ])
    error_message = "Protocol must be HTTP, HTTPS, TCP, or UDP."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      app_config.infrastructure.auto_scaling.target_cpu_utilization >= 10 &&
      app_config.infrastructure.auto_scaling.target_cpu_utilization <= 90
    ])
    error_message = "Target CPU utilization must be between 10% and 90%."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      app_config.monitoring.log_retention_days >= 1 && app_config.monitoring.log_retention_days <= 3653
    ])
    error_message = "Log retention days must be between 1 and 3653 (10 years)."
  }

  validation {
    condition = alltrue([
      for app_name, app_config in var.applications :
      contains(["public", "internal", "confidential", "restricted"], app_config.compliance.data_classification)
    ])
    error_message = "Data classification must be public, internal, confidential, or restricted."
  }
}

# Optional variables for advanced configurations
variable "http_proxy" {
  description = "HTTP proxy URL for AWS provider"
  type        = string
  default     = null
}

variable "assume_role_arn" {
  description = "ARN of IAM role to assume for cross-account access"
  type        = string
  default     = null
}

variable "external_id" {
  description = "External ID for assume role"
  type        = string
  default     = null
  sensitive   = true
}

variable "custom_endpoints" {
  description = "Custom AWS service endpoints for testing"
  type = object({
    ec2 = string
    rds = string
    s3  = string
  })
  default = {
    ec2 = null
    rds = null
    s3  = null
  }
}
