# Terraform Code Lab 5.1: Advanced Variables and Outputs
# Version Constraints and Provider Requirements
#
# This file defines the Terraform version constraints and required providers
# for the advanced variables and outputs lab. It ensures compatibility and
# provides access to the latest features for enterprise-scale deployments.

terraform {
  # Terraform version constraint
  # Using ~> 1.13.0 to allow patch updates while maintaining compatibility
  required_version = "~> 1.13.0"
  
  # Required providers with version constraints
  required_providers {
    # AWS Provider - Primary cloud provider for infrastructure resources
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    
    # Random Provider - For generating random values and IDs
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    
    # TLS Provider - For generating certificates and keys
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    
    # Local Provider - For local file operations and computations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
    
    # Null Provider - For null resources and provisioners
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
  }
  
  # Optional: Backend configuration for remote state
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "labs/variables-outputs/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-locks"
  # }
}

# Provider configuration blocks will be defined in providers.tf
# This separation follows best practices for large configurations
