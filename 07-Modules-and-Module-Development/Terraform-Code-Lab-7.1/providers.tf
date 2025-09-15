# =============================================================================
# AWS Terraform Training - Topic 7: Modules and Module Development
# Terraform Provider Configuration
# =============================================================================

# Terraform version and provider requirements
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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
  }

  # Remote backend configuration for state management
  # This demonstrates module development with proper state management
  backend "s3" {
    # S3 bucket for state storage
    bucket = "terraform-modules-training-state"
    
    # State file key with workspace support
    key = "modules-lab/terraform.tfstate"
    
    # AWS region for the backend
    region = "us-east-1"
    
    # DynamoDB table for state locking
    dynamodb_table = "terraform-modules-locks"
    
    # Enable server-side encryption
    encrypt = true
    
    # Workspace key prefix for multi-environment support
    workspace_key_prefix = "env"
    
    # Additional security settings
    force_path_style = false
    skip_credentials_validation = false
    skip_metadata_api_check = false
    skip_region_validation = false
    skip_requesting_account_id = false
  }
}

# Primary AWS provider configuration
provider "aws" {
  region = var.aws_region
  
  # Default tags applied to all resources
  default_tags {
    tags = {
      Project             = var.project_name
      Environment         = var.environment
      Owner               = var.owner
      CostCenter          = var.cost_center
      ManagedBy           = "Terraform"
      TrainingModule      = "Topic-7-Modules-Development"
      CreatedDate         = formatdate("YYYY-MM-DD", timestamp())
      Workspace           = terraform.workspace
      TerraformVersion    = "~> 1.13.0"
      ProviderVersion     = "~> 6.12.0"
      ModuleDevelopment   = "true"
    }
  }
  
  # Assume role configuration for cross-account access (optional)
  dynamic "assume_role" {
    for_each = var.assume_role_arn != null ? [1] : []
    content {
      role_arn     = var.assume_role_arn
      session_name = "terraform-modules-${var.environment}"
      external_id  = var.external_id
    }
  }
}

# Secondary AWS provider for multi-region module testing
provider "aws" {
  alias  = "secondary_region"
  region = var.secondary_region
  
  # Default tags for secondary region resources
  default_tags {
    tags = {
      Project             = var.project_name
      Environment         = var.environment
      Owner               = var.owner
      CostCenter          = var.cost_center
      ManagedBy           = "Terraform"
      TrainingModule      = "Topic-7-Modules-Development"
      CreatedDate         = formatdate("YYYY-MM-DD", timestamp())
      Workspace           = terraform.workspace
      Region              = "secondary"
      Purpose             = "multi-region-testing"
      ModuleDevelopment   = "true"
    }
  }
}

# Random provider for generating unique identifiers
provider "random" {
  # No specific configuration required
}

# Time provider for time-based resources
provider "time" {
  # No specific configuration required
}

# TLS provider for certificate generation
provider "tls" {
  # No specific configuration required
}

# =============================================================================
# Provider Configuration Notes:
# 
# 1. Module Development Focus:
#    - Backend configured for module development workflows
#    - Multi-region provider setup for testing
#    - Comprehensive tagging for module tracking
#    - Version constraints for stability
#
# 2. Multi-Provider Setup:
#    - Primary provider for main module development
#    - Secondary provider for multi-region module testing
#    - Random provider for unique naming in modules
#    - Time provider for timestamp operations
#    - TLS provider for certificate generation in modules
#
# 3. Security Features:
#    - Server-side encryption for state files
#    - IAM role assumption for cross-account module testing
#    - Comprehensive tagging for governance
#    - Skip validation flags for security
#
# 4. Module Development Features:
#    - Default tags for all module-created resources
#    - Workspace-aware configuration
#    - Cost center tracking for module usage
#    - Module development identification
#    - Cross-region testing capabilities
# =============================================================================
