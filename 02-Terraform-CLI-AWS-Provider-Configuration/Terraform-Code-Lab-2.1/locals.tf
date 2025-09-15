# AWS Terraform Training - Terraform CLI & AWS Provider Configuration
# Lab 2.1: Advanced CLI Setup and Provider Configuration
# File: locals.tf - Local Values for Provider Configuration and CLI Management

# ============================================================================
# TERRAFORM CLI CONFIGURATION LOCALS
# ============================================================================

locals {
  # Terraform CLI version management
  terraform_version_info = {
    required_version = "~> 1.13.0"
    current_version  = "1.13.7"  # Latest stable as of January 2025
    upgrade_path     = "https://releases.hashicorp.com/terraform/"
    installation_methods = [
      "package_manager",  # apt, yum, brew, choco
      "binary_download",  # Direct binary download
      "tfenv",           # Terraform version manager
      "docker",          # Docker container
      "cloud_shell"      # AWS CloudShell, Azure Cloud Shell
    ]
  }
  
  # CLI configuration paths and settings
  cli_configuration = {
    # Configuration directories
    config_dir = {
      linux   = "~/.terraform.d"
      macos   = "~/.terraform.d"
      windows = "%APPDATA%\\terraform.d"
    }
    
    # Plugin directories
    plugin_dir = {
      linux   = "~/.terraform.d/plugins"
      macos   = "~/.terraform.d/plugins"
      windows = "%APPDATA%\\terraform.d\\plugins"
    }
    
    # Credential helpers
    credential_helpers = [
      "terraform-credentials-env",
      "terraform-credentials-keychain",
      "terraform-credentials-vault"
    ]
    
    # CLI configuration file settings
    cli_config_file = {
      disable_checkpoint           = true
      disable_checkpoint_signature = true
      plugin_cache_dir            = "~/.terraform.d/plugin-cache"
      provider_installation = {
        filesystem_mirror = {
          path    = "~/.terraform.d/providers"
          include = ["registry.terraform.io/*/*"]
        }
        network_mirror = {
          url     = "https://terraform-mirror.example.com/"
          include = ["registry.terraform.io/*/*"]
        }
      }
    }
  }
  
  # Environment-specific CLI settings
  environment_cli_settings = {
    development = {
      log_level           = "DEBUG"
      parallelism         = 5
      plugin_cache_enabled = true
      auto_approve_enabled = false
    }
    staging = {
      log_level           = "INFO"
      parallelism         = 10
      plugin_cache_enabled = true
      auto_approve_enabled = false
    }
    production = {
      log_level           = "WARN"
      parallelism         = 20
      plugin_cache_enabled = true
      auto_approve_enabled = false
    }
  }
  
  # Current environment CLI settings
  current_cli_settings = local.environment_cli_settings[var.environment]
}

# ============================================================================
# AWS PROVIDER CONFIGURATION LOCALS
# ============================================================================

locals {
  # AWS Provider version management
  aws_provider_info = {
    required_version = "~> 6.12.0"
    current_version  = "6.12.0"  # Latest stable as of January 2025
    changelog_url    = "https://github.com/hashicorp/terraform-provider-aws/releases"
    documentation_url = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs"
    
    # New features in 6.12.0
    new_features = [
      "Enhanced IAM role assumption",
      "Improved S3 bucket configuration",
      "Advanced VPC endpoint support",
      "Enhanced CloudWatch integration",
      "Improved error handling and retry logic"
    ]
  }
  
  # AWS authentication methods configuration
  authentication_methods = {
    # Method 1: Environment variables
    environment_variables = {
      aws_access_key_id     = "AWS_ACCESS_KEY_ID"
      aws_secret_access_key = "AWS_SECRET_ACCESS_KEY"
      aws_session_token     = "AWS_SESSION_TOKEN"
      aws_region           = "AWS_DEFAULT_REGION"
      aws_profile          = "AWS_PROFILE"
    }
    
    # Method 2: AWS credentials file
    credentials_file = {
      location = {
        linux   = "~/.aws/credentials"
        macos   = "~/.aws/credentials"
        windows = "%USERPROFILE%\\.aws\\credentials"
      }
      config_location = {
        linux   = "~/.aws/config"
        macos   = "~/.aws/config"
        windows = "%USERPROFILE%\\.aws\\config"
      }
    }
    
    # Method 3: IAM roles for EC2
    ec2_instance_profile = {
      metadata_endpoint = "http://169.254.169.254/latest/meta-data/iam/security-credentials/"
      timeout_seconds   = 30
      retry_attempts    = 3
    }
    
    # Method 4: IAM roles for cross-account access
    assume_role = {
      role_arn         = var.cross_account_role_arn
      session_name     = "terraform-session-${var.student_name}"
      external_id      = var.external_id
      duration_seconds = 3600
      policy          = var.assume_role_policy
    }
    
    # Method 5: AWS SSO
    sso_configuration = {
      sso_start_url = var.sso_start_url
      sso_region    = var.sso_region
      account_id    = var.sso_account_id
      role_name     = var.sso_role_name
    }
  }
  
  # Provider configuration for different environments
  provider_configurations = {
    development = {
      region                      = "us-east-1"
      profile                     = "dev"
      max_retries                = 3
      skip_credentials_validation = false
      skip_metadata_api_check     = false
      skip_region_validation      = false
      
      # Development-specific settings
      endpoints = {}  # Use default endpoints
      ignore_tags = {
        keys = ["LastModified"]
      }
    }
    
    staging = {
      region                      = "us-east-1"
      profile                     = "staging"
      max_retries                = 5
      skip_credentials_validation = false
      skip_metadata_api_check     = false
      skip_region_validation      = false
      
      # Staging-specific settings
      endpoints = {}  # Use default endpoints
      ignore_tags = {
        keys = ["LastModified", "DeploymentTime"]
      }
    }
    
    production = {
      region                      = "us-east-1"
      profile                     = "prod"
      max_retries                = 10
      skip_credentials_validation = false
      skip_metadata_api_check     = false
      skip_region_validation      = false
      
      # Production-specific settings
      endpoints = {}  # Use default endpoints
      ignore_tags = {
        keys = ["LastModified", "DeploymentTime"]
        key_prefixes = ["aws:", "kubernetes.io/"]
      }
    }
  }
  
  # Current environment provider configuration
  current_provider_config = local.provider_configurations[var.environment]
}

# ============================================================================
# AUTHENTICATION AND SECURITY LOCALS
# ============================================================================

locals {
  # Security best practices configuration
  security_configuration = {
    # MFA requirements
    mfa_required = var.environment == "production"
    mfa_duration = 3600  # 1 hour
    
    # IP restrictions
    allowed_ip_ranges = var.allowed_ip_ranges
    
    # Session management
    session_duration = {
      development = 28800  # 8 hours
      staging     = 14400  # 4 hours
      production  = 3600   # 1 hour
    }
    
    # Audit logging
    enable_cloudtrail = var.environment != "development"
    log_retention_days = {
      development = 7
      staging     = 30
      production  = 90
    }
  }
  
  # Provider alias configurations for multi-region deployments
  provider_aliases = {
    primary = {
      region = var.primary_region
      alias  = "primary"
    }
    backup = {
      region = var.backup_region
      alias  = "backup"
    }
    global = {
      region = "us-east-1"  # For global services like CloudFront, Route53
      alias  = "global"
    }
  }
  
  # Cross-account role configuration
  cross_account_config = var.enable_cross_account ? {
    role_arn     = var.cross_account_role_arn
    external_id  = var.external_id
    session_name = "terraform-${var.project_name}-${var.environment}"
    
    # Trust policy for the role
    trust_policy = {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = var.trusted_account_arns
          }
          Action = "sts:AssumeRole"
          Condition = {
            StringEquals = {
              "sts:ExternalId" = var.external_id
            }
            IpAddress = {
              "aws:SourceIp" = var.allowed_ip_ranges
            }
          }
        }
      ]
    }
  } : null
}

# ============================================================================
# PROVIDER FEATURE FLAGS AND EXPERIMENTAL FEATURES
# ============================================================================

locals {
  # Provider feature flags
  provider_features = {
    # S3 features
    s3_features = {
      force_path_style                = false
      use_accelerate_endpoint        = var.enable_s3_acceleration
      use_dualstack_endpoint         = var.enable_s3_dualstack
    }
    
    # EC2 features
    ec2_features = {
      default_tags_enabled           = true
      instance_metadata_service_v2   = true
      ebs_encryption_by_default      = var.environment == "production"
    }
    
    # IAM features
    iam_features = {
      max_session_duration          = local.security_configuration.session_duration[var.environment]
      require_mfa                   = local.security_configuration.mfa_required
    }
    
    # VPC features
    vpc_features = {
      enable_dns_hostnames          = true
      enable_dns_support            = true
      enable_network_address_usage_metrics = var.enable_vpc_metrics
    }
  }
  
  # Experimental features (when available)
  experimental_features = {
    # These may be available in future provider versions
    enhanced_error_reporting = true
    improved_state_refresh   = true
    parallel_resource_creation = true
  }
}

# ============================================================================
# COST OPTIMIZATION AND MONITORING LOCALS
# ============================================================================

locals {
  # Cost optimization settings
  cost_optimization = {
    # Resource tagging for cost allocation
    cost_allocation_tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner_email
      CostCenter  = var.cost_center
      BillingCode = var.billing_code
    }
    
    # Auto-shutdown configuration
    auto_shutdown = var.enable_auto_shutdown ? {
      enabled = true
      schedule = var.auto_shutdown_schedule
      exclude_tags = {
        "AutoShutdown" = "disabled"
        "Environment"  = "production"
      }
    } : null
    
    # Budget alerts
    budget_configuration = {
      monthly_limit = var.monthly_budget_limit
      alert_thresholds = [50, 80, 100]  # Percentage thresholds
      notification_emails = [var.owner_email, var.billing_contact_email]
    }
  }
  
  # Monitoring and observability
  monitoring_configuration = {
    # CloudWatch settings
    cloudwatch = {
      log_retention_days = local.security_configuration.log_retention_days[var.environment]
      metric_namespace   = "Terraform/${var.project_name}"
      enable_detailed_monitoring = var.environment != "development"
    }
    
    # AWS Config settings
    config_settings = {
      enable_config_recorder = var.environment == "production"
      enable_compliance_rules = var.enable_compliance_monitoring
      config_bucket_name = "${var.project_name}-config-${var.environment}-${random_id.bucket_suffix.hex}"
    }
    
    # CloudTrail settings
    cloudtrail_settings = {
      enable_cloudtrail = local.security_configuration.enable_cloudtrail
      s3_bucket_name   = "${var.project_name}-cloudtrail-${var.environment}-${random_id.bucket_suffix.hex}"
      include_global_service_events = true
      is_multi_region_trail = true
      enable_log_file_validation = true
    }
  }
}

# ============================================================================
# VALIDATION AND COMPLIANCE LOCALS
# ============================================================================

locals {
  # Configuration validation
  validation_checks = {
    # Provider version validation
    provider_version_valid = can(regex("^6\\.[0-9]+\\.[0-9]+$", local.aws_provider_info.current_version))
    
    # Authentication method validation
    auth_method_configured = (
      var.aws_access_key_id != "" ||
      var.aws_profile != "" ||
      var.cross_account_role_arn != "" ||
      var.use_instance_profile == true
    )
    
    # Region validation
    region_valid = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.primary_region)
    
    # Security validation
    security_compliant = (
      var.environment != "production" || (
        local.security_configuration.mfa_required &&
        length(var.allowed_ip_ranges) > 0 &&
        var.enable_encryption
      )
    )
  }
  
  # All validation checks passed
  all_validations_passed = alltrue([
    local.validation_checks.provider_version_valid,
    local.validation_checks.auth_method_configured,
    local.validation_checks.region_valid,
    local.validation_checks.security_compliant
  ])
  
  # Compliance framework settings
  compliance_settings = {
    framework = var.compliance_framework
    
    # SOC 2 compliance requirements
    soc2_requirements = var.compliance_framework == "soc2" ? {
      encryption_required = true
      audit_logging_required = true
      access_controls_required = true
      monitoring_required = true
    } : null
    
    # PCI DSS compliance requirements
    pci_requirements = var.compliance_framework == "pci" ? {
      network_segmentation_required = true
      encryption_in_transit_required = true
      encryption_at_rest_required = true
      access_logging_required = true
    } : null
    
    # HIPAA compliance requirements
    hipaa_requirements = var.compliance_framework == "hipaa" ? {
      encryption_required = true
      audit_logging_required = true
      access_controls_required = true
      data_residency_required = true
    } : null
  }
}
