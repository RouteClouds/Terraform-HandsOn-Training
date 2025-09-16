# AWS Terraform Training - Topic 4: Resource Management & Dependencies
# Terraform Code Lab 4.1 - Provider Configuration
#
# This file configures the Terraform providers and required versions for the
# Resource Management & Dependencies lab. It demonstrates enterprise-grade
# provider configuration with proper version constraints and default tagging.

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
  
  # Backend configuration for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "resource-management-dependencies/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-locks"
  # }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
  
  # Default tags applied to all resources
  default_tags {
    tags = {
      Environment      = var.environment
      Project          = var.project_name
      ManagedBy        = "terraform"
      TerraformVersion = "1.13.x"
      ProviderVersion  = "6.12.x"
      TrainingModule   = "04-resource-management-dependencies"
      LabVersion       = "4.1"
      CreatedDate      = formatdate("YYYY-MM-DD", timestamp())
      Owner            = var.owner_email
      CostCenter       = var.cost_center
      Compliance       = "required"
    }
  }
  
  # Assume role configuration for cross-account access
  # Uncomment and configure for production use
  # assume_role {
  #   role_arn     = var.assume_role_arn
  #   session_name = "terraform-resource-management"
  #   external_id  = var.external_id
  # }
}

# Random Provider Configuration
provider "random" {
  # No specific configuration required
}

# Time Provider Configuration
provider "time" {
  # No specific configuration required
}

# Provider Features and Capabilities
#
# AWS Provider v6.12.0 Features:
# - Enhanced resource lifecycle management
# - Improved dependency resolution
# - Advanced tagging capabilities
# - Better error handling and validation
# - Support for latest AWS services and features
#
# Random Provider v3.6.0 Features:
# - Cryptographically secure random generation
# - Multiple random resource types
# - Consistent behavior across platforms
#
# Time Provider v0.12.0 Features:
# - Time-based resource management
# - Rotation and scheduling capabilities
# - Timezone-aware operations
#
# Version Constraints Explanation:
# - "~> 1.13.0": Allows 1.13.x but not 1.14.0 (pessimistic constraint)
# - "~> 6.12.0": Allows 6.12.x but not 6.13.0 (provider stability)
# - "~> 3.6.0":  Allows 3.6.x but not 3.7.0 (feature compatibility)
#
# Default Tags Strategy:
# - Environment: Deployment environment (dev/staging/prod)
# - Project: Project identifier for resource grouping
# - ManagedBy: Indicates Terraform management
# - Versions: Track Terraform and provider versions
# - TrainingModule: Identifies the training context
# - CreatedDate: Resource creation timestamp
# - Owner: Responsible party for the resources
# - CostCenter: For cost allocation and tracking
# - Compliance: Indicates compliance requirements
#
# Security Considerations:
# - Provider versions are pinned for security and stability
# - Default tags include compliance and ownership information
# - Backend configuration supports encryption and locking
# - Assume role configuration available for secure access
#
# Best Practices Implemented:
# - Explicit version constraints for reproducible deployments
# - Comprehensive default tagging for governance
# - Provider configuration separation for maintainability
# - Documentation for configuration options
# - Security-first approach with encryption and access controls
#
# Integration with Training Objectives:
# - Demonstrates provider dependency management
# - Shows enterprise-grade configuration patterns
# - Supports advanced resource management scenarios
# - Enables complex dependency relationship testing
# - Provides foundation for lifecycle management exercises
#
# Troubleshooting Notes:
# - If provider download fails, check network connectivity
# - Version conflicts may require constraint adjustment
# - Backend configuration requires pre-existing S3 bucket
# - Default tags can be overridden at resource level
# - Provider features may vary between versions
#
# Performance Considerations:
# - Provider caching improves initialization speed
# - Version constraints prevent unexpected updates
# - Default tags reduce configuration duplication
# - Backend state improves collaboration and safety
# - Assume role configuration enables secure multi-account access
