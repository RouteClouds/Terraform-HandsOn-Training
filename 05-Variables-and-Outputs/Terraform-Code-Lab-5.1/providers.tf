# AWS Terraform Training - Variables and Outputs
# Lab 5.1: Advanced Variable Management and Output Patterns
# File: providers.tf - Provider Configuration with Variable-Driven Settings

# ============================================================================
# TERRAFORM CONFIGURATION
# ============================================================================

terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.0"
    }
    
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
    
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10.0"
    }
  }
  
  # Backend configuration for state management
  # This will be configured based on environment variables
  backend "s3" {
    # Configuration will be provided via backend config file or CLI
    # bucket = "terraform-state-${var.project_name}-${var.environment}"
    # key    = "variables-outputs/${var.environment}/terraform.tfstate"
    # region = var.aws_region
    # 
    # encrypt        = true
    # dynamodb_table = "terraform-state-locks-${var.project_name}"
  }
}

# ============================================================================
# AWS PROVIDER CONFIGURATION
# ============================================================================

# Primary AWS provider with variable-driven configuration
provider "aws" {
  region = var.aws_region
  
  # Provider-level default tags applied to all resources
  default_tags {
    tags = merge(
      local.common_tags,
      {
        # Provider-specific tags
        TerraformProvider = "aws"
        ProviderVersion   = "~> 6.12.0"
        
        # Variable-driven tags
        Environment = var.environment
        Project     = var.project_name
        Owner       = var.owner_email
        CostCenter  = var.cost_center
        
        # Operational tags
        BackupRequired    = var.enable_backup ? "true" : "false"
        MonitoringEnabled = var.enable_monitoring ? "true" : "false"
        AutoShutdown      = var.enable_auto_shutdown ? "true" : "false"
        
        # Compliance tags
        DataClassification = var.data_classification
        ComplianceFramework = var.compliance_framework
        RetentionPeriod    = var.data_retention_period
      }
    )
  }
  
  # Variable-driven provider configuration
  max_retries = var.aws_max_retries
  
  # Skip validations for faster development (variable-controlled)
  skip_credentials_validation = var.skip_aws_validations
  skip_metadata_api_check     = var.skip_aws_validations
  skip_region_validation      = var.skip_aws_validations
  
  # Custom endpoints for VPC endpoints or testing (variable-driven)
  dynamic "endpoints" {
    for_each = var.custom_aws_endpoints != null ? [var.custom_aws_endpoints] : []
    
    content {
      s3  = lookup(endpoints.value, "s3", null)
      ec2 = lookup(endpoints.value, "ec2", null)
      rds = lookup(endpoints.value, "rds", null)
      iam = lookup(endpoints.value, "iam", null)
      sts = lookup(endpoints.value, "sts", null)
    }
  }
  
  # Assume role configuration (variable-driven)
  dynamic "assume_role" {
    for_each = var.assume_role_arn != null ? [1] : []
    
    content {
      role_arn     = var.assume_role_arn
      session_name = "terraform-variables-outputs-${var.environment}"
      external_id  = var.assume_role_external_id
      
      # Variable-driven session duration
      duration = var.assume_role_duration
      
      # Policy for additional restrictions
      policy = var.assume_role_policy
      
      # Tags for the assumed role session
      tags = {
        TerraformSession = "variables-outputs-lab"
        Environment      = var.environment
        Project          = var.project_name
      }
    }
  }
  
  # Ignore specific tags that change frequently
  ignore_tags {
    keys = var.ignore_tag_keys
    key_prefixes = var.ignore_tag_key_prefixes
  }
}

# ============================================================================
# MULTI-REGION PROVIDER CONFIGURATION
# ============================================================================

# Secondary provider for multi-region resources (variable-controlled)
provider "aws" {
  count  = var.enable_multi_region ? 1 : 0
  alias  = "secondary"
  region = var.secondary_aws_region
  
  # Same configuration as primary provider
  default_tags {
    tags = merge(
      local.common_tags,
      {
        # Secondary region specific tags
        Region          = var.secondary_aws_region
        RegionType      = "secondary"
        PrimaryRegion   = var.aws_region
        
        # Cross-region replication tags
        ReplicationEnabled = "true"
        ReplicationSource  = var.aws_region
      }
    )
  }
  
  max_retries = var.aws_max_retries
  
  skip_credentials_validation = var.skip_aws_validations
  skip_metadata_api_check     = var.skip_aws_validations
  skip_region_validation      = var.skip_aws_validations
  
  # Assume role for secondary region (if different)
  dynamic "assume_role" {
    for_each = var.secondary_assume_role_arn != null ? [1] : []
    
    content {
      role_arn     = var.secondary_assume_role_arn
      session_name = "terraform-variables-outputs-${var.environment}-secondary"
      external_id  = var.assume_role_external_id
      duration     = var.assume_role_duration
    }
  }
}

# ============================================================================
# GLOBAL SERVICES PROVIDER CONFIGURATION
# ============================================================================

# Provider for global services (CloudFront, Route53, IAM)
provider "aws" {
  alias  = "global"
  region = "us-east-1"  # Global services are always in us-east-1
  
  default_tags {
    tags = merge(
      local.common_tags,
      {
        # Global services specific tags
        ServiceScope = "global"
        Region       = "us-east-1"
        GlobalService = "true"
      }
    )
  }
  
  max_retries = var.aws_max_retries
  
  # Global services assume role (if different)
  dynamic "assume_role" {
    for_each = var.global_services_assume_role_arn != null ? [1] : []
    
    content {
      role_arn     = var.global_services_assume_role_arn
      session_name = "terraform-variables-outputs-${var.environment}-global"
      external_id  = var.assume_role_external_id
      duration     = var.assume_role_duration
    }
  }
}

# ============================================================================
# RANDOM PROVIDER CONFIGURATION
# ============================================================================

# Random provider for generating unique identifiers
provider "random" {
  # No specific configuration needed
}

# ============================================================================
# EXTERNAL PROVIDER CONFIGURATION
# ============================================================================

# External provider for running external scripts and commands
provider "external" {
  # No specific configuration needed
}

# ============================================================================
# HTTP PROVIDER CONFIGURATION
# ============================================================================

# HTTP provider for making HTTP requests
provider "http" {
  # No specific configuration needed
}

# ============================================================================
# TIME PROVIDER CONFIGURATION
# ============================================================================

# Time provider for time-based resources
provider "time" {
  # No specific configuration needed
}

# ============================================================================
# PROVIDER FEATURE FLAGS AND EXPERIMENTAL FEATURES
# ============================================================================

# Configure provider features based on variables
locals {
  # AWS provider features configuration
  aws_provider_features = {
    # S3 features
    s3_force_path_style = var.s3_force_path_style
    s3_use_accelerate   = var.s3_use_accelerate_endpoint
    s3_use_dualstack    = var.s3_use_dualstack_endpoint
    
    # EC2 features
    ec2_metadata_service_endpoint_mode = var.ec2_metadata_service_endpoint_mode
    ec2_metadata_service_endpoint      = var.ec2_metadata_service_endpoint
    
    # IAM features
    iam_use_service_linked_role = var.iam_use_service_linked_role
    
    # RDS features
    rds_force_ssl = var.rds_force_ssl
    
    # VPC features
    vpc_enable_dns_hostnames = var.vpc_enable_dns_hostnames
    vpc_enable_dns_support   = var.vpc_enable_dns_support
  }
  
  # Provider retry configuration
  retry_configuration = {
    max_retries = var.aws_max_retries
    retry_mode  = var.aws_retry_mode
    
    # Custom retry configuration for specific services
    service_retry_config = {
      ec2 = {
        max_retries = var.ec2_max_retries
        retry_mode  = var.ec2_retry_mode
      }
      
      rds = {
        max_retries = var.rds_max_retries
        retry_mode  = var.rds_retry_mode
      }
      
      s3 = {
        max_retries = var.s3_max_retries
        retry_mode  = var.s3_retry_mode
      }
    }
  }
  
  # Provider endpoint configuration
  endpoint_configuration = {
    # Use VPC endpoints if enabled
    use_vpc_endpoints = var.enable_vpc_endpoints
    
    # Custom endpoint URLs
    custom_endpoints = var.custom_aws_endpoints
    
    # Endpoint discovery configuration
    endpoint_discovery = {
      enabled = var.enable_endpoint_discovery
      cache_size = var.endpoint_discovery_cache_size
    }
  }
}

# ============================================================================
# PROVIDER VALIDATION AND HEALTH CHECKS
# ============================================================================

# Validate provider configuration
locals {
  # Provider validation checks
  provider_validation = {
    # Region validation
    primary_region_valid = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.aws_region)
    
    # Secondary region validation (if enabled)
    secondary_region_valid = var.enable_multi_region ? contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.secondary_aws_region) : true
    
    # Cross-region validation
    regions_different = var.enable_multi_region ? var.aws_region != var.secondary_aws_region : true
    
    # Assume role validation
    assume_role_valid = var.assume_role_arn != null ? can(regex("^arn:aws:iam::", var.assume_role_arn)) : true
    
    # Environment validation
    environment_valid = contains(["development", "staging", "production"], var.environment)
  }
  
  # All provider validations passed
  provider_config_valid = alltrue([
    local.provider_validation.primary_region_valid,
    local.provider_validation.secondary_region_valid,
    local.provider_validation.regions_different,
    local.provider_validation.assume_role_valid,
    local.provider_validation.environment_valid
  ])
}

# Validation resource to ensure provider configuration is correct
resource "null_resource" "provider_validation" {
  count = local.provider_config_valid ? 0 : 1
  
  provisioner "local-exec" {
    command = "echo 'Provider configuration validation failed. Check your variable values.' && exit 1"
  }
}
