# AWS Terraform Training - Variables and Outputs
# Lab 5.1: Advanced Variable Management and Output Patterns
# File: variables.tf - Comprehensive Variable Definitions with Advanced Patterns

# ============================================================================
# PROJECT AND ENVIRONMENT VARIABLES
# ============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 30
    error_message = "Project name must be between 3 and 30 characters long."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  
  validation {
    condition = contains([
      "development", "staging", "production", "disaster-recovery"
    ], var.environment)
    error_message = "Environment must be development, staging, production, or disaster-recovery."
  }
}

variable "owner_email" {
  description = "Email address of the project owner"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  
  validation {
    condition     = can(regex("^[A-Z0-9-]+$", var.cost_center))
    error_message = "Cost center must contain only uppercase letters, numbers, and hyphens."
  }
}

# ============================================================================
# AWS CONFIGURATION VARIABLES
# ============================================================================

variable "aws_region" {
  description = "Primary AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "eu-north-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ap-northeast-2",
      "ca-central-1", "sa-east-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid and supported region."
  }
}

variable "secondary_aws_region" {
  description = "Secondary AWS region for multi-region deployments"
  type        = string
  default     = "us-west-2"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "eu-north-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ap-northeast-2",
      "ca-central-1", "sa-east-1"
    ], var.secondary_aws_region)
    error_message = "Secondary AWS region must be a valid and supported region."
  }
}

variable "enable_multi_region" {
  description = "Enable multi-region deployment for disaster recovery"
  type        = bool
  default     = false
}

# ============================================================================
# COMPLEX INFRASTRUCTURE CONFIGURATION VARIABLE
# ============================================================================

variable "infrastructure_config" {
  description = "Complete infrastructure configuration with comprehensive validation"
  type = object({
    # Environment configuration
    environment = object({
      name         = string
      tier         = string
      region       = string
      multi_az     = bool
      backup_enabled = bool
    })
    
    # Compute configuration
    compute = object({
      web_tier = object({
        instance_type    = string
        min_capacity     = number
        max_capacity     = number
        desired_capacity = number
        ami_id          = optional(string)
        key_pair_name   = optional(string)
      })
      
      app_tier = object({
        instance_type    = string
        min_capacity     = number
        max_capacity     = number
        desired_capacity = number
        ami_id          = optional(string)
        key_pair_name   = optional(string)
      })
    })
    
    # Network configuration
    networking = object({
      vpc_cidr             = string
      availability_zones   = list(string)
      public_subnet_cidrs  = list(string)
      private_subnet_cidrs = list(string)
      enable_nat_gateway   = bool
      enable_vpn_gateway   = bool
      enable_flow_logs     = optional(bool, true)
    })
    
    # Database configuration
    database = object({
      engine               = string
      engine_version       = string
      instance_class       = string
      allocated_storage    = number
      max_allocated_storage = optional(number)
      backup_retention     = number
      backup_window        = optional(string, "03:00-04:00")
      maintenance_window   = optional(string, "sun:04:00-sun:05:00")
      multi_az            = bool
      encryption_enabled   = bool
      deletion_protection  = optional(bool, true)
    })
    
    # Storage configuration
    storage = object({
      s3_buckets = map(object({
        versioning_enabled = bool
        encryption_enabled = bool
        lifecycle_enabled  = bool
        public_access_block = bool
      }))
      
      efs_file_systems = optional(map(object({
        performance_mode = string
        throughput_mode  = string
        encrypted       = bool
      })), {})
    })
    
    # Monitoring configuration
    monitoring = object({
      enable_detailed_monitoring = bool
      log_retention_days         = number
      enable_cloudtrail         = bool
      enable_config             = bool
      enable_guardduty          = optional(bool, false)
      alert_email               = string
      dashboard_enabled         = optional(bool, true)
    })
    
    # Security configuration
    security = object({
      enable_waf              = bool
      enable_shield           = optional(bool, false)
      ssl_policy             = string
      enable_secrets_manager  = optional(bool, true)
      enable_parameter_store  = optional(bool, true)
      kms_key_rotation       = optional(bool, true)
    })
  })
  
  # Comprehensive validation rules
  validation {
    condition = contains([
      "development", "staging", "production", "disaster-recovery"
    ], var.infrastructure_config.environment.name)
    error_message = "Environment name must be development, staging, production, or disaster-recovery."
  }
  
  validation {
    condition = contains([
      "basic", "standard", "premium", "enterprise"
    ], var.infrastructure_config.environment.tier)
    error_message = "Environment tier must be basic, standard, premium, or enterprise."
  }
  
  validation {
    condition = can(cidrhost(var.infrastructure_config.networking.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
  
  validation {
    condition = length(var.infrastructure_config.networking.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for high availability."
  }
  
  validation {
    condition = length(var.infrastructure_config.networking.public_subnet_cidrs) == length(var.infrastructure_config.networking.availability_zones)
    error_message = "Number of public subnet CIDRs must match number of availability zones."
  }
  
  validation {
    condition = length(var.infrastructure_config.networking.private_subnet_cidrs) == length(var.infrastructure_config.networking.availability_zones)
    error_message = "Number of private subnet CIDRs must match number of availability zones."
  }
  
  validation {
    condition = var.infrastructure_config.compute.web_tier.min_capacity <= var.infrastructure_config.compute.web_tier.max_capacity
    error_message = "Web tier min_capacity must be less than or equal to max_capacity."
  }
  
  validation {
    condition = var.infrastructure_config.compute.web_tier.desired_capacity >= var.infrastructure_config.compute.web_tier.min_capacity && var.infrastructure_config.compute.web_tier.desired_capacity <= var.infrastructure_config.compute.web_tier.max_capacity
    error_message = "Web tier desired_capacity must be between min_capacity and max_capacity."
  }
  
  validation {
    condition = var.infrastructure_config.compute.app_tier.min_capacity <= var.infrastructure_config.compute.app_tier.max_capacity
    error_message = "App tier min_capacity must be less than or equal to max_capacity."
  }
  
  validation {
    condition = contains([
      "mysql", "postgres", "mariadb", "oracle-ee", "oracle-se2", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"
    ], var.infrastructure_config.database.engine)
    error_message = "Database engine must be a supported RDS engine type."
  }
  
  validation {
    condition = var.infrastructure_config.database.backup_retention >= 0 && var.infrastructure_config.database.backup_retention <= 35
    error_message = "Database backup retention must be between 0 and 35 days."
  }
  
  validation {
    condition = var.infrastructure_config.database.allocated_storage >= 20 && var.infrastructure_config.database.allocated_storage <= 65536
    error_message = "Database allocated storage must be between 20 GB and 65536 GB."
  }
  
  validation {
    condition = var.infrastructure_config.monitoring.log_retention_days >= 1 && var.infrastructure_config.monitoring.log_retention_days <= 3653
    error_message = "Log retention days must be between 1 and 3653 days (10 years)."
  }
  
  validation {
    condition = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.infrastructure_config.monitoring.alert_email))
    error_message = "Alert email must be a valid email address."
  }
  
  validation {
    condition = contains([
      "ELBSecurityPolicy-TLS-1-0-2015-04",
      "ELBSecurityPolicy-TLS-1-1-2017-01",
      "ELBSecurityPolicy-TLS-1-2-2017-01",
      "ELBSecurityPolicy-TLS-1-2-Ext-2018-06",
      "ELBSecurityPolicy-FS-2018-06",
      "ELBSecurityPolicy-FS-1-1-2019-08",
      "ELBSecurityPolicy-FS-1-2-2019-08",
      "ELBSecurityPolicy-FS-1-2-Res-2019-08"
    ], var.infrastructure_config.security.ssl_policy)
    error_message = "SSL policy must be a valid ELB security policy."
  }
}

# ============================================================================
# ENVIRONMENT-SPECIFIC CONFIGURATION VARIABLES
# ============================================================================

variable "environment_configs" {
  description = "Environment-specific configuration overrides with comprehensive settings"
  type = map(object({
    # Instance type configurations
    instance_types = object({
      web = string
      app = string
      db  = string
    })
    
    # Auto Scaling configurations
    scaling_config = object({
      web_min = number
      web_max = number
      app_min = number
      app_max = number
    })
    
    # Security configurations
    security_config = object({
      enable_waf           = bool
      enable_shield        = bool
      ssl_policy          = string
      backup_frequency    = string
      encryption_level    = string
    })
    
    # Cost optimization configurations
    cost_config = object({
      enable_spot_instances = bool
      reserved_capacity     = number
      budget_limit_usd     = number
      auto_shutdown_enabled = bool
    })
    
    # Performance configurations
    performance_config = object({
      enable_enhanced_monitoring = bool
      enable_performance_insights = bool
      cloudwatch_detailed_monitoring = bool
      log_level = string
    })
    
    # Compliance configurations
    compliance_config = object({
      data_residency_required = bool
      audit_logging_required  = bool
      encryption_required     = bool
      backup_required        = bool
    })
  }))
  
  default = {
    development = {
      instance_types = {
        web = "t3.micro"
        app = "t3.small"
        db  = "db.t3.micro"
      }
      scaling_config = {
        web_min = 1
        web_max = 3
        app_min = 1
        app_max = 2
      }
      security_config = {
        enable_waf        = false
        enable_shield     = false
        ssl_policy       = "ELBSecurityPolicy-TLS-1-2-2017-01"
        backup_frequency = "daily"
        encryption_level = "standard"
      }
      cost_config = {
        enable_spot_instances = true
        reserved_capacity     = 0
        budget_limit_usd     = 100
        auto_shutdown_enabled = true
      }
      performance_config = {
        enable_enhanced_monitoring = false
        enable_performance_insights = false
        cloudwatch_detailed_monitoring = false
        log_level = "INFO"
      }
      compliance_config = {
        data_residency_required = false
        audit_logging_required  = false
        encryption_required     = false
        backup_required        = true
      }
    }
    
    staging = {
      instance_types = {
        web = "t3.small"
        app = "t3.medium"
        db  = "db.t3.small"
      }
      scaling_config = {
        web_min = 2
        web_max = 6
        app_min = 2
        app_max = 4
      }
      security_config = {
        enable_waf        = true
        enable_shield     = false
        ssl_policy       = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
        backup_frequency = "daily"
        encryption_level = "enhanced"
      }
      cost_config = {
        enable_spot_instances = true
        reserved_capacity     = 25
        budget_limit_usd     = 500
        auto_shutdown_enabled = false
      }
      performance_config = {
        enable_enhanced_monitoring = true
        enable_performance_insights = false
        cloudwatch_detailed_monitoring = true
        log_level = "DEBUG"
      }
      compliance_config = {
        data_residency_required = true
        audit_logging_required  = true
        encryption_required     = true
        backup_required        = true
      }
    }
    
    production = {
      instance_types = {
        web = "t3.large"
        app = "t3.xlarge"
        db  = "db.r5.large"
      }
      scaling_config = {
        web_min = 3
        web_max = 20
        app_min = 3
        app_max = 15
      }
      security_config = {
        enable_waf        = true
        enable_shield     = true
        ssl_policy       = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
        backup_frequency = "continuous"
        encryption_level = "maximum"
      }
      cost_config = {
        enable_spot_instances = false
        reserved_capacity     = 75
        budget_limit_usd     = 5000
        auto_shutdown_enabled = false
      }
      performance_config = {
        enable_enhanced_monitoring = true
        enable_performance_insights = true
        cloudwatch_detailed_monitoring = true
        log_level = "WARN"
      }
      compliance_config = {
        data_residency_required = true
        audit_logging_required  = true
        encryption_required     = true
        backup_required        = true
      }
    }
  }
  
  # Validation for environment configurations
  validation {
    condition = alltrue([
      for env_name, config in var.environment_configs : contains([
        "t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge",
        "m5.large", "m5.xlarge", "m5.2xlarge", "c5.large", "c5.xlarge"
      ], config.instance_types.web)
    ])
    error_message = "Web instance types must be valid EC2 instance types."
  }
  
  validation {
    condition = alltrue([
      for env_name, config in var.environment_configs : 
      config.scaling_config.web_min <= config.scaling_config.web_max
    ])
    error_message = "Web tier min capacity must be less than or equal to max capacity for all environments."
  }
  
  validation {
    condition = alltrue([
      for env_name, config in var.environment_configs : 
      config.cost_config.budget_limit_usd > 0
    ])
    error_message = "Budget limit must be greater than 0 for all environments."
  }
  
  validation {
    condition = alltrue([
      for env_name, config in var.environment_configs :
      config.cost_config.reserved_capacity >= 0 && config.cost_config.reserved_capacity <= 100
    ])
    error_message = "Reserved capacity percentage must be between 0 and 100 for all environments."
  }
}

# ============================================================================
# SENSITIVE VARIABLES
# ============================================================================

variable "database_credentials" {
  description = "Database master credentials for RDS instances"
  type = object({
    username = string
    password = string
  })
  sensitive = true

  validation {
    condition     = length(var.database_credentials.password) >= 12
    error_message = "Database password must be at least 12 characters long."
  }

  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_credentials.username))
    error_message = "Database username must start with a letter and contain only alphanumeric characters and underscores."
  }

  validation {
    condition = can(regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]", var.database_credentials.password))
    error_message = "Database password must contain at least one lowercase letter, one uppercase letter, one digit, and one special character."
  }
}

variable "api_credentials" {
  description = "External API credentials and configuration"
  type = map(object({
    api_key    = string
    secret_key = string
    endpoint   = string
    region     = optional(string, "us-east-1")
    timeout    = optional(number, 30)
  }))
  sensitive = true
  default   = {}

  validation {
    condition = alltrue([
      for service, creds in var.api_credentials :
      length(creds.api_key) >= 20 && length(creds.secret_key) >= 40
    ])
    error_message = "API keys must be at least 20 characters and secret keys at least 40 characters."
  }

  validation {
    condition = alltrue([
      for service, creds in var.api_credentials :
      can(regex("^https?://", creds.endpoint))
    ])
    error_message = "API endpoints must be valid HTTP or HTTPS URLs."
  }
}

variable "ssl_certificates" {
  description = "SSL certificate configuration for load balancers and services"
  type = map(object({
    domain_name                = string
    subject_alternative_names  = list(string)
    validation_method         = string
    key_algorithm            = optional(string, "RSA_2048")
    certificate_transparency_logging_preference = optional(string, "ENABLED")
  }))
  sensitive = true
  default   = {}

  validation {
    condition = alltrue([
      for cert_name, cert in var.ssl_certificates :
      contains(["DNS", "EMAIL"], cert.validation_method)
    ])
    error_message = "SSL certificate validation method must be DNS or EMAIL."
  }

  validation {
    condition = alltrue([
      for cert_name, cert in var.ssl_certificates :
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\\.[a-zA-Z]{2,}$", cert.domain_name))
    ])
    error_message = "Domain names must be valid FQDN format."
  }

  validation {
    condition = alltrue([
      for cert_name, cert in var.ssl_certificates :
      contains(["RSA_1024", "RSA_2048", "RSA_3072", "RSA_4096", "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"], cert.key_algorithm)
    ])
    error_message = "Key algorithm must be a valid ACM supported algorithm."
  }
}

# ============================================================================
# FEATURE FLAGS AND OPTIONAL CONFIGURATIONS
# ============================================================================

variable "enable_backup" {
  description = "Enable automated backup for resources"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alerting"
  type        = bool
  default     = true
}

variable "enable_auto_shutdown" {
  description = "Enable automatic shutdown for cost optimization"
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = false
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup replication"
  type        = bool
  default     = false
}

variable "enable_compliance_monitoring" {
  description = "Enable compliance monitoring with AWS Config"
  type        = bool
  default     = false
}

# ============================================================================
# TAGGING AND METADATA VARIABLES
# ============================================================================

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.default_tags :
      length(key) <= 128 && length(value) <= 256
    ])
    error_message = "Tag keys must be 128 characters or less, and values must be 256 characters or less."
  }
}

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}

variable "data_classification" {
  description = "Data classification level for compliance"
  type        = string
  default     = "internal"

  validation {
    condition = contains([
      "public", "internal", "confidential", "restricted"
    ], var.data_classification)
    error_message = "Data classification must be public, internal, confidential, or restricted."
  }
}

variable "compliance_framework" {
  description = "Compliance framework requirements"
  type        = string
  default     = ""

  validation {
    condition = var.compliance_framework == "" || contains([
      "soc2", "pci-dss", "hipaa", "gdpr", "iso27001", "fedramp"
    ], var.compliance_framework)
    error_message = "Compliance framework must be empty or one of: soc2, pci-dss, hipaa, gdpr, iso27001, fedramp."
  }
}

variable "data_retention_period" {
  description = "Data retention period in days"
  type        = string
  default     = "2555"  # 7 years

  validation {
    condition     = can(tonumber(var.data_retention_period)) && tonumber(var.data_retention_period) > 0
    error_message = "Data retention period must be a positive number."
  }
}

# ============================================================================
# PROVIDER CONFIGURATION VARIABLES
# ============================================================================

variable "aws_max_retries" {
  description = "Maximum number of retries for AWS API calls"
  type        = number
  default     = 3

  validation {
    condition     = var.aws_max_retries >= 1 && var.aws_max_retries <= 10
    error_message = "AWS max retries must be between 1 and 10."
  }
}

variable "skip_aws_validations" {
  description = "Skip AWS provider validations for faster development"
  type        = bool
  default     = false
}

variable "custom_aws_endpoints" {
  description = "Custom AWS service endpoints for VPC endpoints or testing"
  type        = map(string)
  default     = null
}

variable "assume_role_arn" {
  description = "ARN of the IAM role to assume for AWS operations"
  type        = string
  default     = null

  validation {
    condition     = var.assume_role_arn == null || can(regex("^arn:aws:iam::", var.assume_role_arn))
    error_message = "Assume role ARN must be a valid IAM role ARN."
  }
}

variable "assume_role_external_id" {
  description = "External ID for assume role operations"
  type        = string
  default     = null
  sensitive   = true
}

variable "assume_role_duration" {
  description = "Duration for assume role session in seconds"
  type        = string
  default     = "3600"

  validation {
    condition     = can(tonumber(var.assume_role_duration)) && tonumber(var.assume_role_duration) >= 900 && tonumber(var.assume_role_duration) <= 43200
    error_message = "Assume role duration must be between 900 (15 minutes) and 43200 (12 hours) seconds."
  }
}

variable "assume_role_policy" {
  description = "Additional policy to apply during assume role"
  type        = string
  default     = null
}

variable "secondary_assume_role_arn" {
  description = "ARN of the IAM role to assume for secondary region operations"
  type        = string
  default     = null
}

variable "global_services_assume_role_arn" {
  description = "ARN of the IAM role to assume for global services"
  type        = string
  default     = null
}

variable "ignore_tag_keys" {
  description = "Tag keys to ignore when managing resources"
  type        = list(string)
  default     = ["LastModified", "DeploymentTime"]
}

variable "ignore_tag_key_prefixes" {
  description = "Tag key prefixes to ignore when managing resources"
  type        = list(string)
  default     = ["aws:", "kubernetes.io/"]
}
