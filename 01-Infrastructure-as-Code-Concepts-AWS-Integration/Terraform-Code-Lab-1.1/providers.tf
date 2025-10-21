# AWS Provider Configuration for Infrastructure as Code Lab 1.1
# Topic 1: Infrastructure as Code Concepts & AWS Integration
#
# This file configures the AWS provider with the latest stable versions
# and implements enterprise-grade standards for Infrastructure as Code.
#
# Version Requirements:
# - Terraform: ~> 1.13.0 (latest stable)
# - AWS Provider: ~> 6.12.0 (latest stable, published September 2025)
# - Region: us-east-1 (standardized for all labs)
#
# Last Updated: January 2025

terraform {
  # Terraform version constraint - ensures compatibility and stability
  required_version = "~> 1.13.0"
  
  # Required providers with version constraints
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    
    # Random provider for generating unique resource names
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    
    # Local provider for local file operations and data processing
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    # Template provider for dynamic configuration generation
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  
  # Backend configuration for state management
  # Note: For production environments, use remote backend (S3 + DynamoDB)
  # For lab purposes, local backend is acceptable
  backend "local" {
    path = "terraform.tfstate"
  }
  
  # Experimental features (if needed for latest Terraform features)
  # experiments = []
}

# AWS Provider Configuration
provider "aws" {
  # Region configuration - standardized to us-east-1 for all labs
  region = var.aws_region
  
  # Profile configuration (optional - uses default if not specified)
  # profile = var.aws_profile
  
  # Default tags applied to all resources
  # These tags ensure consistent resource management, cost tracking, and governance
  default_tags {
    tags = {
      # Project identification
      Project     = var.project_name
      Environment = var.environment
      
      # Infrastructure management
      ManagedBy        = "terraform"
      TerraformVersion = "1.13.x"
      ProviderVersion  = "6.12.x"
      
      # Operational metadata
      CreatedDate = timestamp()
      CreatedBy   = var.created_by
      
      # Cost and governance
      CostCenter    = var.cost_center
      Owner         = var.owner_email
      BusinessUnit  = var.business_unit
      
      # Compliance and security
      DataClass       = var.data_classification
      BackupRequired  = var.backup_required
      MonitoringLevel = var.monitoring_level
      
      # Automation and lifecycle
      AutoShutdown    = var.auto_shutdown_enabled
      LifecycleStage  = var.lifecycle_stage
      MaintenanceWindow = var.maintenance_window
      
      # Educational context
      TrainingTopic = "01-Infrastructure-as-Code-Concepts"
      LabNumber     = "1.1"
      StudentGroup  = var.student_group
    }
  }
  
  # Assume role configuration (for cross-account access if needed)
  # assume_role {
  #   role_arn     = var.assume_role_arn
  #   session_name = "terraform-iac-lab-1-1"
  #   external_id  = var.external_id
  # }
  
  # Retry configuration for improved reliability
  retry_mode      = "adaptive"
  max_retries     = 3
  
  # Request timeout configuration
  http_timeout = "30s"
  
  # Skip metadata API check (useful in some CI/CD environments)
  # skip_metadata_api_check = true
  
  # Skip region validation (only if using non-standard regions)
  # skip_region_validation = true
  
  # Skip credentials validation (only for specific use cases)
  # skip_credentials_validation = true
  
  # Custom endpoint configuration (for testing or special environments)
  # endpoints {
  #   ec2 = var.custom_ec2_endpoint
  #   s3  = var.custom_s3_endpoint
  # }
}

# Random Provider Configuration
provider "random" {
  # No specific configuration required for random provider
  # Used for generating unique resource names and IDs
}

# Local Provider Configuration
provider "local" {
  # No specific configuration required for local provider
  # Used for local file operations and data processing
}

# Template Provider Configuration
provider "template" {
  # No specific configuration required for template provider
  # Used for dynamic configuration file generation
}

# Data sources for provider validation and information
data "aws_caller_identity" "current" {
  # Retrieves information about the AWS account and user/role
  # Used for validation and resource naming
}

data "aws_region" "current" {
  # Retrieves information about the current AWS region
  # Used for region-specific configurations
}

data "aws_availability_zones" "available" {
  # Retrieves list of available availability zones in the current region
  state = "available"
  
  # Filter out zones that might not support all required services
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_partition" "current" {
  # Retrieves the AWS partition (aws, aws-cn, aws-us-gov)
  # Used for constructing ARNs and region-specific configurations
}

# Local values for provider information and validation
locals {
  # Account and region information
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition
  
  # Availability zone information
  azs = data.aws_availability_zones.available.names
  
  # Provider validation
  provider_info = {
    terraform_version = "~> 1.13.0"
    aws_provider_version = "~> 6.12.0"
    account_id = local.account_id
    region = local.region
    partition = local.partition
    available_azs = length(local.azs)
  }
  
  # Resource naming conventions
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags for resources that don't inherit default tags
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedBy   = var.created_by
    CostCenter  = var.cost_center
    Owner       = var.owner_email
  }
  
  # Security and compliance tags
  security_tags = {
    DataClass       = var.data_classification
    BackupRequired  = var.backup_required
    MonitoringLevel = var.monitoring_level
    ComplianceScope = var.compliance_scope
  }
  
  # Operational tags
  operational_tags = {
    AutoShutdown      = var.auto_shutdown_enabled
    LifecycleStage    = var.lifecycle_stage
    MaintenanceWindow = var.maintenance_window
    SupportLevel      = var.support_level
  }
}

# Validation checks for provider configuration
resource "null_resource" "provider_validation" {
  # Validate that we're using the correct region
  lifecycle {
    precondition {
      condition     = local.region == var.aws_region
      error_message = "Provider region (${local.region}) does not match configured region (${var.aws_region})."
    }
  }
  
  # Validate that we have sufficient availability zones
  lifecycle {
    precondition {
      condition     = length(local.azs) >= 2
      error_message = "Region ${local.region} must have at least 2 availability zones. Found: ${length(local.azs)}."
    }
  }
  
  # Validate account ID format
  lifecycle {
    precondition {
      condition     = can(regex("^[0-9]{12}$", local.account_id))
      error_message = "Invalid AWS account ID format: ${local.account_id}."
    }
  }
  
  triggers = {
    # Trigger validation on provider configuration changes
    terraform_version = "~> 1.13.0"
    aws_provider_version = "~> 6.12.0"
    region = var.aws_region
    timestamp = timestamp()
  }
}

# Output provider information for debugging and validation
output "provider_info" {
  description = "Information about the configured providers and AWS environment"
  value = {
    terraform_version = "~> 1.13.0"
    aws_provider_version = "~> 6.12.0"
    aws_account_id = local.account_id
    aws_region = local.region
    aws_partition = local.partition
    availability_zones = local.azs
    name_prefix = local.name_prefix
  }
}

# Security note: This configuration follows AWS and Terraform best practices:
# 1. Version constraints prevent breaking changes
# 2. Default tags ensure consistent resource management
# 3. Retry configuration improves reliability
# 4. Data sources provide environment validation
# 5. Local values enable consistent naming and tagging
# 6. Validation checks prevent common configuration errors
#
# For production environments, consider:
# 1. Remote state backend (S3 + DynamoDB)
# 2. Cross-account role assumption
# 3. Custom endpoints for VPC endpoints
# 4. Additional security configurations
# 5. Compliance-specific settings
