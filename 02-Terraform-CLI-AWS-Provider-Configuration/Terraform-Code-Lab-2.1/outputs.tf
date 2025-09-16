# AWS Terraform Training - Topic 2: Terraform CLI & AWS Provider Configuration
# Terraform Code Lab 2.1 - Output Definitions
#
# This file defines all output values for the Terraform configuration,
# demonstrating best practices for output organization, sensitive data handling,
# and integration with external systems.
#
# Learning Objectives:
# 1. Output value definition and organization
# 2. Sensitive output handling
# 3. Structured output for automation integration
# 4. Provider configuration validation outputs
# 5. Resource information exposure for downstream consumption

# =============================================================================
# PROVIDER CONFIGURATION OUTPUTS
# =============================================================================

output "provider_configuration" {
  description = "Current AWS provider configuration and validation details"
  value = {
    # Account and identity information
    account_id = data.aws_caller_identity.current.account_id
    user_id    = data.aws_caller_identity.current.user_id
    arn        = data.aws_caller_identity.current.arn
    
    # Regional configuration
    region             = data.aws_region.current.name
    availability_zones = data.aws_availability_zones.available.names
    
    # Provider version information
    terraform_version     = var.terraform_version
    aws_provider_version  = var.aws_provider_version
    
    # Configuration validation
    region_compliance = data.aws_region.current.name == var.aws_region
    profile_used      = var.aws_profile
    environment       = var.environment
  }
}

output "authentication_details" {
  description = "Authentication method and security validation"
  value = {
    # Authentication method detection
    is_assumed_role = can(regex("assumed-role", data.aws_caller_identity.current.arn))
    is_mfa_enabled  = can(regex("mfa", data.aws_caller_identity.current.arn))
    is_federated    = can(regex("federated-user", data.aws_caller_identity.current.arn))
    
    # Security configuration
    encryption_at_rest    = var.encryption_at_rest
    encryption_in_transit = var.encryption_in_transit
    
    # Compliance information
    data_classification     = var.data_classification
    compliance_requirements = var.compliance_requirements
  }
  
  sensitive = true
}

# =============================================================================
# INFRASTRUCTURE RESOURCE OUTPUTS
# =============================================================================

output "terraform_state_bucket" {
  description = "Terraform state bucket configuration and details"
  value = {
    # Bucket identification
    bucket_name = aws_s3_bucket.terraform_state.bucket
    bucket_arn  = aws_s3_bucket.terraform_state.arn
    bucket_id   = aws_s3_bucket.terraform_state.id
    
    # Regional information
    region = aws_s3_bucket.terraform_state.region
    
    # Security configuration
    versioning_enabled = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status
    encryption_enabled = true
    public_access_blocked = true
    
    # Lifecycle configuration
    lifecycle_configured = true
    retention_days      = var.backup_retention_days
    
    # Usage information
    purpose = "Terraform state storage"
    created_date = formatdate("YYYY-MM-DD", timestamp())
  }
}

output "state_locking_table" {
  description = "DynamoDB table for Terraform state locking"
  value = {
    # Table identification
    table_name = aws_dynamodb_table.terraform_state_lock.name
    table_arn  = aws_dynamodb_table.terraform_state_lock.arn
    table_id   = aws_dynamodb_table.terraform_state_lock.id
    
    # Configuration details
    billing_mode = aws_dynamodb_table.terraform_state_lock.billing_mode
    hash_key     = aws_dynamodb_table.terraform_state_lock.hash_key
    
    # Security features
    encryption_enabled = var.encryption_at_rest
    point_in_time_recovery = var.enable_backup
    
    # Usage information
    purpose = "Terraform state locking"
    created_date = formatdate("YYYY-MM-DD", timestamp())
  }
}

output "iam_execution_role" {
  description = "IAM role for Terraform execution"
  value = {
    # Role identification
    role_name = aws_iam_role.terraform_execution.name
    role_arn  = aws_iam_role.terraform_execution.arn
    role_id   = aws_iam_role.terraform_execution.id
    
    # Configuration details
    assume_role_policy = aws_iam_role.terraform_execution.assume_role_policy
    
    # Security information
    external_id_required = var.external_id != null
    
    # Usage information
    purpose = "Terraform execution permissions"
    created_date = formatdate("YYYY-MM-DD", timestamp())
  }
}

# =============================================================================
# SECURITY AND ENCRYPTION OUTPUTS
# =============================================================================

output "encryption_configuration" {
  description = "Encryption configuration and KMS key details"
  value = var.encryption_at_rest ? {
    # KMS key information
    kms_key_id    = aws_kms_key.terraform_key[0].key_id
    kms_key_arn   = aws_kms_key.terraform_key[0].arn
    kms_alias     = aws_kms_alias.terraform_key[0].name
    
    # Key configuration
    key_rotation_enabled = aws_kms_key.terraform_key[0].enable_key_rotation
    deletion_window     = aws_kms_key.terraform_key[0].deletion_window_in_days
    
    # Usage information
    purpose = "Terraform resource encryption"
    created_date = formatdate("YYYY-MM-DD", timestamp())
  } : {
    encryption_enabled = false
    message = "Encryption at rest is disabled"
  }
}

# =============================================================================
# MONITORING AND LOGGING OUTPUTS
# =============================================================================

output "monitoring_configuration" {
  description = "Monitoring and logging configuration details"
  value = {
    # CloudWatch log group (if enabled)
    log_group_name = var.feature_flags.enable_logging ? aws_cloudwatch_log_group.terraform_operations[0].name : null
    log_group_arn  = var.feature_flags.enable_logging ? aws_cloudwatch_log_group.terraform_operations[0].arn : null
    
    # Monitoring features
    detailed_monitoring_enabled = var.enable_detailed_monitoring
    logging_enabled            = var.feature_flags.enable_logging
    metrics_enabled            = var.feature_flags.enable_metrics
    tracing_enabled            = var.feature_flags.enable_tracing
    
    # Retention configuration
    log_retention_days = var.backup_retention_days
    
    # Budget monitoring
    budget_name  = aws_budgets_budget.terraform_budget.name
    budget_limit = var.budget_limit
  }
}

# =============================================================================
# COST MANAGEMENT OUTPUTS
# =============================================================================

output "cost_management" {
  description = "Cost management and budget configuration"
  value = {
    # Budget configuration
    budget_name   = aws_budgets_budget.terraform_budget.name
    budget_limit  = var.budget_limit
    budget_unit   = "USD"
    time_unit     = "MONTHLY"
    
    # Cost allocation
    cost_center           = var.cost_center
    cost_allocation_tags  = var.cost_allocation_tags
    
    # Project information
    project_name = var.project_name
    environment  = var.environment
    owner        = var.owner
    
    # Tracking information
    created_date = formatdate("YYYY-MM-DD", timestamp())
  }
}

# =============================================================================
# PROVIDER VALIDATION OUTPUTS
# =============================================================================

output "provider_validation" {
  description = "Provider configuration validation results"
  value = {
    # Default provider test
    default_provider_bucket = aws_s3_bucket.provider_test_default.bucket
    default_provider_region = aws_s3_bucket.provider_test_default.region
    
    # Development provider test
    dev_provider_bucket = aws_s3_bucket.provider_test_dev.bucket
    dev_provider_region = aws_s3_bucket.provider_test_dev.region
    
    # Multi-region provider test
    multi_region_bucket = aws_s3_bucket.multi_region_test.bucket
    multi_region_region = aws_s3_bucket.multi_region_test.region
    
    # Validation summary
    all_providers_working = true
    test_resources_created = 3
    validation_timestamp = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  }
}

# =============================================================================
# ENVIRONMENT CONFIGURATION OUTPUTS
# =============================================================================

output "environment_configuration" {
  description = "Environment-specific configuration and feature flags"
  value = {
    # Environment details
    environment = var.environment
    env_config  = local.env_config
    
    # Feature flags
    feature_flags = var.feature_flags
    
    # Security configuration
    security_config = local.security_config
    
    # Tagging strategy
    common_tags = local.common_tags
    
    # Naming convention
    name_prefix = local.name_prefix
    timestamp   = local.timestamp
  }
}

# =============================================================================
# INTEGRATION OUTPUTS FOR EXTERNAL SYSTEMS
# =============================================================================

output "backend_configuration" {
  description = "Backend configuration for remote state setup"
  value = {
    # S3 backend configuration
    backend_type   = "s3"
    bucket         = aws_s3_bucket.terraform_state.bucket
    key_prefix     = "environments/${var.environment}"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
    
    # Workspace configuration
    workspace_key_prefix = "workspaces"
    
    # Configuration template
    backend_config_template = {
      bucket         = aws_s3_bucket.terraform_state.bucket
      key            = "path/to/terraform.tfstate"
      region         = var.aws_region
      encrypt        = true
      dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
    }
  }
}

output "cli_commands" {
  description = "Useful Terraform CLI commands for this configuration"
  value = {
    # Initialization commands
    init_command = "terraform init"
    init_with_backend = "terraform init -backend-config=\"bucket=${aws_s3_bucket.terraform_state.bucket}\""
    
    # Validation commands
    validate_command = "terraform validate"
    format_command   = "terraform fmt -recursive"
    
    # Planning and applying
    plan_command  = "terraform plan -var-file=\"terraform.tfvars\""
    apply_command = "terraform apply -var-file=\"terraform.tfvars\""
    
    # State management
    state_list_command = "terraform state list"
    state_show_command = "terraform state show aws_s3_bucket.terraform_state"
    
    # Workspace management
    workspace_list_command = "terraform workspace list"
    workspace_new_command  = "terraform workspace new ${var.environment}"
    
    # Debugging
    debug_command = "TF_LOG=DEBUG terraform plan"
  }
}

# =============================================================================
# SUMMARY OUTPUT
# =============================================================================

output "lab_summary" {
  description = "Comprehensive summary of Lab 2 implementation"
  value = {
    # Lab information
    lab_name    = "Terraform CLI & AWS Provider Configuration"
    lab_version = "2.1"
    completed_date = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
    
    # Configuration summary
    terraform_version    = var.terraform_version
    aws_provider_version = var.aws_provider_version
    aws_region          = var.aws_region
    environment         = var.environment
    
    # Resources created
    resources_created = {
      s3_buckets      = 4
      dynamodb_tables = 1
      iam_roles       = 1
      kms_keys        = var.encryption_at_rest ? 1 : 0
      log_groups      = var.feature_flags.enable_logging ? 1 : 0
      budgets         = 1
    }
    
    # Security features
    security_features = {
      encryption_at_rest     = var.encryption_at_rest
      encryption_in_transit  = var.encryption_in_transit
      public_access_blocked  = true
      versioning_enabled     = true
      state_locking_enabled  = true
      mfa_support           = var.mfa_device_arn != null
    }
    
    # Learning objectives achieved
    learning_objectives = {
      terraform_cli_installation = "✅ Completed"
      aws_provider_configuration = "✅ Completed"
      authentication_methods     = "✅ Completed"
      cli_workflow_execution     = "✅ Completed"
      enterprise_configuration   = "✅ Completed"
    }
  }
}
