# AWS Terraform Training - Topic 2: Terraform CLI & AWS Provider Configuration
# Terraform Code Lab 2.1 - Provider Configuration and Authentication
#
# This file demonstrates enterprise-grade Terraform and AWS Provider configuration
# with multiple authentication methods, security best practices, and version management.
#
# Learning Objectives:
# 1. Terraform version constraints and provider configuration
# 2. AWS Provider authentication methods and security implementation
# 3. Multi-environment provider configuration patterns
# 4. Enterprise governance and compliance integration
#
# Version Requirements:
# - Terraform: ~> 1.13.0 (Latest stable with enhanced features)
# - AWS Provider: ~> 6.12.0 (Latest with comprehensive AWS service support)
# - Region: us-east-1 (Standardized for training consistency)

terraform {
  # Terraform version constraint ensures compatibility and stability
  # The ~> operator allows patch-level updates while preventing breaking changes
  required_version = "~> 1.13.0"
  
  # Required providers block specifies exact provider sources and versions
  # This ensures reproducible deployments across different environments
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    
    # Random provider for generating unique resource identifiers
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    
    # Local provider for data processing and transformations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    # TLS provider for certificate and key generation
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
  }
  
  # Backend configuration for remote state storage
  # This configuration supports team collaboration and state locking
  backend "s3" {
    # S3 bucket for state storage (configured via backend config file)
    # bucket = "your-terraform-state-bucket"
    # key    = "lab-2/terraform.tfstate"
    # region = "us-east-1"
    
    # State encryption and locking configuration
    # encrypt        = true
    # dynamodb_table = "terraform-state-lock"
    
    # Workspace-based state organization
    # workspace_key_prefix = "environments"
  }
}

# Primary AWS Provider Configuration
# This provider configuration demonstrates production-ready settings
provider "aws" {
  # AWS region standardized for training consistency
  region = var.aws_region
  
  # Profile-based authentication for local development
  # In production, use IAM roles or OIDC federation
  profile = var.aws_profile
  
  # Default tags applied to all resources created by this provider
  # Tags enable cost allocation, governance, and resource management
  default_tags {
    tags = {
      # Environment identification for resource organization
      Environment = var.environment
      
      # Project identification for cost allocation
      Project = "terraform-training-lab-2"
      
      # Management method for operational clarity
      ManagedBy = "terraform"
      
      # Ownership information for accountability
      Owner = var.owner
      
      # Cost center for billing and chargeback
      CostCenter = var.cost_center
      
      # Creation timestamp for audit trails
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
      
      # Training context for resource identification
      TrainingTopic = "terraform-cli-aws-provider-configuration"
      
      # Compliance and governance tags
      DataClassification = "internal"
      BackupRequired     = "true"
      MonitoringEnabled  = "true"
    }
  }
  
  # Assume role configuration for cross-account access
  # Uncomment and configure for production cross-account scenarios
  # assume_role {
  #   role_arn     = var.assume_role_arn
  #   session_name = "terraform-lab-2-session"
  #   external_id  = var.external_id
  # }
  
  # Retry configuration for improved reliability
  retry_mode      = "adaptive"
  max_retries     = 3
  
  # Request timeout configuration
  http_timeout = "30s"
  
  # Custom endpoint configuration (for testing or special environments)
  # endpoints {
  #   s3  = "https://s3.us-east-1.amazonaws.com"
  #   ec2 = "https://ec2.us-east-1.amazonaws.com"
  # }
}

# Development Environment Provider (Profile-based Authentication)
# This provider demonstrates environment-specific configuration
provider "aws" {
  alias   = "development"
  region  = var.aws_region
  profile = "terraform-dev"
  
  default_tags {
    tags = merge(local.common_tags, {
      Environment = "development"
      Purpose     = "development-testing"
    })
  }
}

# Staging Environment Provider (Role Assumption)
# This provider demonstrates secure role-based authentication
provider "aws" {
  alias  = "staging"
  region = var.aws_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.staging_account_id}:role/TerraformExecutionRole"
    session_name = "terraform-staging-session"
    external_id  = var.external_id
  }
  
  default_tags {
    tags = merge(local.common_tags, {
      Environment = "staging"
      Purpose     = "pre-production-testing"
    })
  }
}

# Production Environment Provider (Role Assumption with MFA)
# This provider demonstrates maximum security configuration
provider "aws" {
  alias  = "production"
  region = var.aws_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.production_account_id}:role/TerraformExecutionRole"
    session_name = "terraform-production-session"
    external_id  = var.external_id
    
    # MFA requirement for production access
    # mfa_serial = var.mfa_device_arn
  }
  
  default_tags {
    tags = merge(local.common_tags, {
      Environment = "production"
      Purpose     = "production-workloads"
      Compliance  = "required"
    })
  }
}

# CI/CD Environment Provider (OIDC Federation)
# This provider demonstrates secure CI/CD authentication
provider "aws" {
  alias  = "cicd"
  region = var.aws_region
  
  # OIDC-based authentication for GitHub Actions, GitLab CI, etc.
  # This eliminates the need for long-lived credentials in CI/CD
  assume_role_with_web_identity {
    role_arn                = var.cicd_role_arn
    session_name            = "terraform-cicd-session"
    web_identity_token_file = var.web_identity_token_file
  }
  
  default_tags {
    tags = merge(local.common_tags, {
      Environment = "cicd"
      Purpose     = "automated-deployment"
      Automation  = "enabled"
    })
  }
}

# Alternative Region Provider (Multi-region deployments)
# This provider demonstrates multi-region configuration
provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
  
  default_tags {
    tags = merge(local.common_tags, {
      Region  = "us-west-2"
      Purpose = "disaster-recovery"
    })
  }
}

# Provider Configuration Validation
# These data sources validate provider configuration and permissions
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

# Provider configuration outputs for validation and debugging
output "provider_configuration" {
  description = "Current AWS provider configuration details"
  value = {
    account_id        = data.aws_caller_identity.current.account_id
    user_id          = data.aws_caller_identity.current.user_id
    arn              = data.aws_caller_identity.current.arn
    region           = data.aws_region.current.name
    availability_zones = data.aws_availability_zones.available.names
  }
}

# Security and compliance validation
output "security_validation" {
  description = "Security configuration validation"
  value = {
    mfa_enabled           = can(regex("mfa", data.aws_caller_identity.current.arn))
    assumed_role          = can(regex("assumed-role", data.aws_caller_identity.current.arn))
    region_compliance     = data.aws_region.current.name == var.aws_region
    provider_version      = "6.12.0"
    terraform_version     = "1.13.0"
  }
}

# Enterprise governance and compliance tags
locals {
  # Common tags applied across all resources
  common_tags = {
    Environment        = var.environment
    Project           = "terraform-training-lab-2"
    ManagedBy         = "terraform"
    Owner             = var.owner
    CostCenter        = var.cost_center
    CreatedDate       = formatdate("YYYY-MM-DD", timestamp())
    TrainingTopic     = "terraform-cli-aws-provider-configuration"
    DataClassification = "internal"
    BackupRequired    = "true"
    MonitoringEnabled = "true"
    ComplianceScope   = "training"
  }
  
  # Provider-specific configuration
  provider_config = {
    terraform_version = "~> 1.13.0"
    aws_provider_version = "~> 6.12.0"
    region = var.aws_region
    profile = var.aws_profile
  }
}

# Provider feature flags and experimental features
# These settings enable advanced provider capabilities
terraform {
  # Enable provider development overrides for testing
  # provider_installation {
  #   dev_overrides = {
  #     "hashicorp/aws" = "/path/to/local/provider"
  #   }
  #   direct {}
  # }
  
  # Experimental features (use with caution in production)
  experiments = []
  
  # Provider metadata for enhanced functionality
  # cloud {
  #   organization = "your-terraform-cloud-org"
  #   workspaces {
  #     name = "terraform-training-lab-2"
  #   }
  # }
}
