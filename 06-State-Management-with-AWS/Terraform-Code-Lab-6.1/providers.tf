# =============================================================================
# AWS Terraform Training - Topic 6: State Management with AWS
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
  }

  # Remote backend configuration for state management
  # This demonstrates the enterprise-grade state backend setup
  backend "s3" {
    # S3 bucket for state storage
    bucket = "terraform-state-management-training-${random_id.bucket_suffix.hex}"
    
    # State file key with workspace support
    key = "state-management-lab/terraform.tfstate"
    
    # AWS region for the backend
    region = "us-east-1"
    
    # DynamoDB table for state locking
    dynamodb_table = "terraform-state-locks"
    
    # Enable server-side encryption
    encrypt = true
    
    # KMS key for encryption (optional - uses AWS managed key if not specified)
    # kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    
    # Enable versioning for state file history
    versioning = true
    
    # Workspace key prefix for multi-environment support
    workspace_key_prefix = "env"
    
    # Additional security and performance settings
    force_path_style = false
    skip_credentials_validation = false
    skip_metadata_api_check = false
    skip_region_validation = false
    skip_requesting_account_id = false
    
    # Server-side encryption configuration
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
        bucket_key_enabled = true
      }
    }
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
      TrainingModule      = "Topic-6-State-Management"
      CreatedDate         = formatdate("YYYY-MM-DD", timestamp())
      Workspace           = terraform.workspace
      TerraformVersion    = "~> 1.13.0"
      ProviderVersion     = "~> 6.12.0"
    }
  }
  
  # Assume role configuration for cross-account access (optional)
  dynamic "assume_role" {
    for_each = var.assume_role_arn != null ? [1] : []
    content {
      role_arn     = var.assume_role_arn
      session_name = "terraform-state-management-${var.environment}"
      external_id  = var.external_id
    }
  }
}

# Secondary AWS provider for cross-region operations
provider "aws" {
  alias  = "backup_region"
  region = var.backup_region
  
  # Default tags for backup region resources
  default_tags {
    tags = {
      Project             = var.project_name
      Environment         = var.environment
      Owner               = var.owner
      CostCenter          = var.cost_center
      ManagedBy           = "Terraform"
      TrainingModule      = "Topic-6-State-Management"
      CreatedDate         = formatdate("YYYY-MM-DD", timestamp())
      Workspace           = terraform.workspace
      Region              = "backup"
      Purpose             = "disaster-recovery"
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

# =============================================================================
# Provider Configuration Notes:
# 
# 1. Backend Configuration:
#    - Uses S3 for state storage with encryption
#    - DynamoDB for state locking to prevent conflicts
#    - Workspace support for environment isolation
#    - Versioning enabled for state history
#
# 2. Multi-Provider Setup:
#    - Primary provider for main resources
#    - Secondary provider for backup/DR scenarios
#    - Random provider for unique naming
#    - Time provider for timestamp operations
#
# 3. Security Features:
#    - Server-side encryption for state files
#    - IAM role assumption for cross-account access
#    - Comprehensive tagging for governance
#    - Skip validation flags for security
#
# 4. Enterprise Features:
#    - Default tags for all resources
#    - Workspace-aware configuration
#    - Cost center tracking
#    - Compliance-ready setup
# =============================================================================
