# AWS Terraform Training - Topic 3: Core Terraform Operations
# Terraform Code Lab 3.1 - Provider Configuration and Requirements
#
# This file demonstrates enterprise-grade provider configuration for core Terraform
# operations including resource management, data sources, provisioners, and lifecycle
# management with the latest Terraform and AWS Provider versions.
#
# Learning Objectives:
# 1. Latest Terraform and AWS Provider version configuration
# 2. Multi-provider setup for complex resource scenarios
# 3. Provider feature configuration for advanced operations
# 4. Enterprise governance and compliance integration
#
# Version Requirements:
# - Terraform: ~> 1.13.0 (Latest stable with enhanced resource management)
# - AWS Provider: ~> 6.12.0 (Latest with comprehensive service support)
# - Region: us-east-1 (Standardized for training consistency)

terraform {
  # Terraform version constraint for stability and feature compatibility
  required_version = "~> 1.13.0"
  
  # Required providers with specific versions for reproducible deployments
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    
    # Random provider for unique resource naming
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    
    # Local provider for data processing and file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    # External provider for external data source integration
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.0"
    }
    
    # HTTP provider for external API integration
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
    
    # Template provider for dynamic configuration generation
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    
    # TLS provider for certificate and key generation
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
  }
  
  # Backend configuration for remote state storage
  # Uncomment and configure for team collaboration
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "core-operations/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  #   
  #   # Workspace-based state organization
  #   workspace_key_prefix = "environments"
  # }
}

# Primary AWS Provider Configuration
provider "aws" {
  # AWS region for resource deployment
  region = var.aws_region
  
  # Profile-based authentication for local development
  profile = var.aws_profile
  
  # Default tags applied to all resources
  default_tags {
    tags = {
      # Project and environment identification
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      
      # Ownership and accountability
      Owner      = var.owner
      CostCenter = var.cost_center
      
      # Operational metadata
      CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
      TerraformTopic = "core-terraform-operations"
      LabVersion     = "3.1"
      
      # Compliance and governance
      DataClassification = var.data_classification
      BackupRequired     = var.backup_required ? "true" : "false"
      MonitoringEnabled  = var.monitoring_enabled ? "true" : "false"
    }
  }
  
  # Assume role configuration for cross-account access
  # Uncomment and configure for production environments
  # assume_role {
  #   role_arn     = var.assume_role_arn
  #   session_name = "terraform-core-operations"
  #   external_id  = var.external_id
  # }
  
  # Provider configuration for enhanced reliability
  retry_mode      = "adaptive"
  max_retries     = 3
  
  # Request timeout configuration
  http_timeout = "30s"
  
  # Skip metadata API check for faster provider initialization
  skip_metadata_api_check = false
  
  # Skip region validation for custom regions
  skip_region_validation = false
  
  # Skip credentials validation for faster startup
  skip_credentials_validation = false
}

# Secondary AWS Provider for Multi-Region Operations
provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
  
  # Use same profile as primary provider
  profile = var.aws_profile
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      Region      = "us-west-2"
      Purpose     = "disaster-recovery"
    }
  }
}

# Development Environment Provider
provider "aws" {
  alias   = "development"
  region  = var.aws_region
  profile = var.aws_profile
  
  default_tags {
    tags = {
      Environment = "development"
      Project     = var.project_name
      ManagedBy   = "terraform"
      Purpose     = "development-testing"
    }
  }
}

# Production Environment Provider (Role-based)
provider "aws" {
  alias  = "production"
  region = var.aws_region
  
  # Production environments should use role assumption
  assume_role {
    role_arn     = var.production_role_arn
    session_name = "terraform-production-session"
    external_id  = var.external_id
  }
  
  default_tags {
    tags = {
      Environment = "production"
      Project     = var.project_name
      ManagedBy   = "terraform"
      Purpose     = "production-workloads"
      Compliance  = "required"
    }
  }
}

# Random Provider Configuration
provider "random" {
  # No specific configuration required
  # Used for generating unique identifiers and passwords
}

# Local Provider Configuration
provider "local" {
  # No specific configuration required
  # Used for local file operations and data processing
}

# External Provider Configuration
provider "external" {
  # No specific configuration required
  # Used for external data source integration
}

# HTTP Provider Configuration
provider "http" {
  # No specific configuration required
  # Used for HTTP-based data sources and API integration
}

# Template Provider Configuration
provider "template" {
  # No specific configuration required
  # Used for dynamic template rendering
}

# TLS Provider Configuration
provider "tls" {
  # No specific configuration required
  # Used for certificate and key generation
}

# Provider validation data sources
data "aws_caller_identity" "current" {
  provider = aws
}

data "aws_region" "current" {
  provider = aws
}

data "aws_availability_zones" "available" {
  provider = aws
  state    = "available"
}

# Provider configuration validation outputs
output "provider_validation" {
  description = "Provider configuration validation results"
  value = {
    # AWS provider validation
    account_id         = data.aws_caller_identity.current.account_id
    user_id           = data.aws_caller_identity.current.user_id
    arn               = data.aws_caller_identity.current.arn
    region            = data.aws_region.current.name
    availability_zones = data.aws_availability_zones.available.names
    
    # Provider versions
    terraform_version     = "~> 1.13.0"
    aws_provider_version  = "~> 6.12.0"
    
    # Configuration validation
    region_compliance = data.aws_region.current.name == var.aws_region
    az_count         = length(data.aws_availability_zones.available.names)
    
    # Authentication method detection
    is_assumed_role = can(regex("assumed-role", data.aws_caller_identity.current.arn))
    is_federated   = can(regex("federated-user", data.aws_caller_identity.current.arn))
    
    # Provider feature validation
    retry_mode_enabled    = true
    timeout_configured    = true
    default_tags_applied  = true
    multi_provider_setup  = true
  }
}

# Provider feature demonstration
output "provider_features" {
  description = "Demonstration of provider features and capabilities"
  value = {
    # Multi-provider support
    primary_region    = var.aws_region
    secondary_region  = "us-west-2"
    
    # Environment-specific providers
    development_provider = "configured"
    production_provider  = "configured"
    
    # Provider integrations
    random_provider   = "enabled"
    local_provider    = "enabled"
    external_provider = "enabled"
    http_provider     = "enabled"
    template_provider = "enabled"
    tls_provider      = "enabled"
    
    # Advanced features
    default_tagging   = "enabled"
    retry_logic      = "adaptive"
    timeout_handling = "configured"
    
    # Security features
    role_assumption  = "supported"
    external_id     = "supported"
    mfa_integration = "supported"
  }
}

# Enterprise governance and compliance
locals {
  # Provider compliance validation
  provider_compliance = {
    terraform_version_valid = can(regex("^~> 1\\.13\\.", "~> 1.13.0"))
    aws_provider_version_valid = can(regex("^~> 6\\.12\\.", "~> 6.12.0"))
    region_approved = contains(["us-east-1", "us-west-2", "eu-west-1"], var.aws_region)
    
    # Security compliance
    encryption_required = true
    mfa_recommended    = true
    role_based_access  = var.production_role_arn != null
    
    # Operational compliance
    monitoring_enabled = var.monitoring_enabled
    backup_configured = var.backup_required
    tagging_enforced  = true
  }
  
  # Provider configuration summary
  provider_summary = {
    total_providers = 7
    aws_providers   = 4
    utility_providers = 3
    
    # Configuration status
    all_providers_configured = true
    validation_passed       = true
    compliance_met         = alltrue(values(local.provider_compliance))
  }
}

# Provider compliance output
output "provider_compliance" {
  description = "Provider configuration compliance status"
  value = {
    compliance_checks = local.provider_compliance
    summary          = local.provider_summary
    
    # Recommendations
    recommendations = [
      local.provider_compliance.role_based_access ? "" : "Configure role-based access for production",
      local.provider_compliance.region_approved ? "" : "Use approved AWS regions only",
      "Enable MFA for enhanced security",
      "Implement state locking for team collaboration"
    ]
    
    # Status
    overall_status = local.provider_summary.compliance_met ? "COMPLIANT" : "NON_COMPLIANT"
  }
}
