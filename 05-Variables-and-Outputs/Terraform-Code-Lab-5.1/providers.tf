# Terraform Code Lab 5.1: Advanced Variables and Outputs
# Provider Configuration
#
# This file configures the required providers for the advanced variables and
# outputs lab. It includes AWS provider configuration with proper tagging,
# region settings, and security configurations.

# AWS Provider Configuration
provider "aws" {
  # Region configuration - using variable for flexibility
  region = var.aws_region
  
  # Default tags applied to all resources
  # These tags support governance, cost management, and compliance
  default_tags {
    tags = {
      # Project identification
      Project     = var.organization_config.name
      Environment = var.environment
      ManagedBy   = "terraform"
      
      # Governance and compliance
      Owner           = var.organization_config.cost_center_default
      CostCenter      = var.organization_config.cost_center_default
      DataClassification = var.organization_config.data_classification
      ComplianceLevel = var.organization_config.compliance_level
      
      # Operational metadata
      CreatedDate     = formatdate("YYYY-MM-DD", timestamp())
      TerraformConfig = "variables-outputs-lab"
      LabVersion      = "5.1"
      
      # Change management
      ChangeApprovalRequired = tostring(var.organization_config.governance.change_approval_required)
      AuditLoggingEnabled   = tostring(var.organization_config.governance.audit_logging_enabled)
      
      # Security baseline
      EncryptionRequired = tostring(var.organization_config.security_baseline.encryption_required)
      NetworkIsolation  = tostring(var.organization_config.security_baseline.network_isolation)
    }
  }
  
  # Assume role configuration (optional)
  # Uncomment and configure for cross-account deployments
  # assume_role {
  #   role_arn     = var.assume_role_arn
  #   session_name = "terraform-variables-outputs-lab"
  #   external_id  = var.external_id
  # }
  
  # Retry configuration for API calls
  retry_mode = "adaptive"
  max_retries = 3
  
  # HTTP configuration
  http_proxy                = var.http_proxy
  insecure                 = false
  skip_credentials_validation = false
  skip_metadata_api_check  = false
  skip_region_validation   = false
  skip_requesting_account_id = false
  
  # S3 configuration
  s3_use_path_style = false
  
  # Additional provider configuration based on environment
  # Development environments may have relaxed settings
  # Production environments enforce strict security
  
  # Endpoints configuration (for testing with LocalStack or custom endpoints)
  # endpoints {
  #   ec2 = var.custom_endpoints.ec2
  #   rds = var.custom_endpoints.rds
  #   s3  = var.custom_endpoints.s3
  # }
}

# Random Provider Configuration
provider "random" {
  # No specific configuration required
  # Used for generating random values for resource naming and secrets
}

# TLS Provider Configuration
provider "tls" {
  # No specific configuration required
  # Used for generating certificates and cryptographic keys
}

# Local Provider Configuration
provider "local" {
  # No specific configuration required
  # Used for local file operations and computations
}

# Null Provider Configuration
provider "null" {
  # No specific configuration required
  # Used for null resources and custom provisioners
}

# Provider aliases for multi-region deployments (optional)
# Uncomment for multi-region scenarios

# provider "aws" {
#   alias  = "backup_region"
#   region = var.organization_config.backup_region
#   
#   default_tags {
#     tags = {
#       Project     = var.organization_config.name
#       Environment = var.environment
#       ManagedBy   = "terraform"
#       Region      = "backup"
#       Purpose     = "disaster-recovery"
#     }
#   }
# }

# provider "aws" {
#   alias  = "us_east_1"
#   region = "us-east-1"
#   
#   default_tags {
#     tags = {
#       Project     = var.organization_config.name
#       Environment = var.environment
#       ManagedBy   = "terraform"
#       Region      = "primary"
#       Purpose     = "global-resources"
#     }
#   }
# }
