# =============================================================================
# Terraform Backend Configuration Template
# Generated for AWS S3 Backend with DynamoDB Locking
# =============================================================================

terraform {
  backend "s3" {
    # S3 bucket for state storage
    bucket = "${bucket}"
    
    # State file key (path within bucket)
    key = "${key}"
    
    # AWS region for the backend
    region = "${region}"
    
    # DynamoDB table for state locking
    dynamodb_table = "${dynamodb_table}"
    
    # Enable server-side encryption
    encrypt = true
    
    # KMS key for encryption (optional)
    %{ if kms_key_id != "" }
    kms_key_id = "${kms_key_id}"
    %{ endif }
    
    # Enable versioning for state file history
    versioning = true
    
    # Workspace key prefix for multi-environment support
    workspace_key_prefix = "env"
    
    # Additional security and performance settings
    force_path_style            = false
    skip_credentials_validation = false
    skip_metadata_api_check     = false
    skip_region_validation      = false
    skip_requesting_account_id  = false
    
    # Maximum number of times to retry a failed operation
    max_retries = 5
    
    # Enable shared credentials file
    shared_credentials_file = ""
    
    # AWS profile to use (optional)
    profile = ""
    
    # Role ARN for cross-account access (optional)
    # role_arn = "arn:aws:iam::ACCOUNT-ID:role/ROLE-NAME"
    
    # External ID for assume role (optional)
    # external_id = "EXTERNAL-ID"
    
    # Session name for assume role (optional)
    # session_name = "terraform-session"
  }
}

# =============================================================================
# Backend Configuration Notes:
# 
# 1. Security Features:
#    - Server-side encryption enabled by default
#    - Optional KMS key for enhanced encryption
#    - State locking with DynamoDB prevents concurrent modifications
#    - Versioning enabled for state file history and rollback
#
# 2. Multi-Environment Support:
#    - Workspace key prefix allows environment isolation
#    - Each workspace gets its own state file path
#    - Example: env:/development/terraform.tfstate
#
# 3. Cross-Account Access:
#    - Uncomment role_arn for cross-account deployments
#    - Use external_id for additional security
#    - Session name helps with audit trails
#
# 4. Performance and Reliability:
#    - Retry configuration for transient failures
#    - Skip validation flags for faster initialization
#    - Force path style disabled for better performance
#
# Usage Instructions:
# 1. Save this configuration in your terraform block
# 2. Run 'terraform init' to initialize the backend
# 3. For migration: 'terraform init -migrate-state'
# 4. For reconfiguration: 'terraform init -reconfigure'
# =============================================================================
