# Terraform Code Lab 6.1: Advanced State Management & Backends
# Backend Setup - Version Constraints
#
# This file defines the Terraform version constraints and required providers
# for the backend infrastructure setup. It ensures compatibility and provides
# access to the latest features for enterprise-scale state management.

terraform {
  # Terraform version constraint
  # Using ~> 1.13.0 to allow patch updates while maintaining compatibility
  required_version = "~> 1.13.0"
  
  # Required providers with version constraints
  required_providers {
    # AWS Provider - Primary cloud provider for backend infrastructure
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    
    # Random Provider - For generating unique resource names
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    
    # TLS Provider - For generating certificates and keys
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    
    # Local Provider - For local file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
  
  # Note: This configuration uses local backend for initial setup
  # After creating the S3 backend infrastructure, other configurations
  # will use the S3 backend created by this setup
}
