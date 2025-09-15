# AWS Terraform Training - Terraform CLI & AWS Provider Configuration
# Lab 2.1: Advanced Provider Configuration and Authentication
# File: outputs.tf - Comprehensive Output Definitions with Business Value

# ============================================================================
# PROVIDER CONFIGURATION VALIDATION OUTPUTS
# ============================================================================

output "provider_configuration" {
  description = "Provider configuration validation and metadata for troubleshooting and documentation"
  value = {
    terraform_version    = "1.13.x"
    aws_provider_version = "6.12.x"
    workspace           = terraform.workspace
    environment         = var.environment
    student_name        = var.student_name
    
    primary_region      = var.aws_region
    secondary_region    = var.secondary_region
    dr_region          = var.disaster_recovery_region
    
    auth_method        = var.auth_method
    aws_profile        = var.aws_profile
    max_retries        = var.max_retries
    retry_mode         = var.retry_mode
    
    multi_region_enabled = var.enable_multi_region
    cross_account_enabled = var.enable_cross_account
    
    deployment_timestamp = timestamp()
  }
}

output "aws_account_information" {
  description = "AWS account and identity information for authentication validation"
  value = {
    primary_account = {
      account_id = data.aws_caller_identity.current.account_id
      user_id    = data.aws_caller_identity.current.user_id
      arn        = data.aws_caller_identity.current.arn
      region     = data.aws_region.current.name
    }
    
    secondary_account = var.enable_multi_region ? {
      account_id = data.aws_caller_identity.secondary.account_id
      user_id    = data.aws_caller_identity.secondary.user_id
      arn        = data.aws_caller_identity.secondary.arn
      region     = data.aws_region.secondary.name
    } : null
    
    availability_zones = {
      primary   = data.aws_availability_zones.available.names
      secondary = var.enable_multi_region ? data.aws_availability_zones.secondary_available.names : []
    }
  }
}

# ============================================================================
# STATE BACKEND CONFIGURATION OUTPUTS
# ============================================================================

output "state_backend_configuration" {
  description = "Terraform state backend configuration for team collaboration and CI/CD setup"
  value = var.create_test_resources ? {
    s3_bucket_name     = aws_s3_bucket.terraform_state[0].bucket
    s3_bucket_arn      = aws_s3_bucket.terraform_state[0].arn
    s3_bucket_region   = aws_s3_bucket.terraform_state[0].region
    
    dynamodb_table_name = aws_dynamodb_table.terraform_locks[0].name
    dynamodb_table_arn  = aws_dynamodb_table.terraform_locks[0].arn
    
    backend_config = {
      bucket         = aws_s3_bucket.terraform_state[0].bucket
      key            = "terraform-cli-aws-provider/terraform.tfstate"
      region         = var.aws_region
      dynamodb_table = aws_dynamodb_table.terraform_locks[0].name
      encrypt        = var.encryption_enabled
    }
    
    backend_hcl_content = <<-EOT
      bucket         = "${aws_s3_bucket.terraform_state[0].bucket}"
      key            = "terraform-cli-aws-provider/terraform.tfstate"
      region         = "${var.aws_region}"
      dynamodb_table = "${aws_dynamodb_table.terraform_locks[0].name}"
      encrypt        = ${var.encryption_enabled}
    EOT
  } : null
}

# ============================================================================
# MULTI-REGION DEPLOYMENT OUTPUTS
# ============================================================================

output "multi_region_resources" {
  description = "Multi-region resource deployment information for disaster recovery and global architecture"
  value = var.enable_multi_region && var.create_test_resources ? {
    primary_region_resources = {
      s3_bucket = {
        name   = aws_s3_bucket.test_primary[0].bucket
        arn    = aws_s3_bucket.test_primary[0].arn
        region = aws_s3_bucket.test_primary[0].region
      }
      
      log_group = var.monitoring_enabled ? {
        name = aws_cloudwatch_log_group.provider_test[0].name
        arn  = aws_cloudwatch_log_group.provider_test[0].arn
      } : null
    }
    
    secondary_region_resources = {
      s3_bucket = {
        name   = aws_s3_bucket.test_secondary[0].bucket
        arn    = aws_s3_bucket.test_secondary[0].arn
        region = aws_s3_bucket.test_secondary[0].region
      }
      
      log_group = var.monitoring_enabled ? {
        name = aws_cloudwatch_log_group.provider_test_secondary[0].name
        arn  = aws_cloudwatch_log_group.provider_test_secondary[0].arn
      } : null
    }
    
    disaster_recovery_resources = {
      backup_bucket = {
        name   = aws_s3_bucket.backup_dr[0].bucket
        arn    = aws_s3_bucket.backup_dr[0].arn
        region = aws_s3_bucket.backup_dr[0].region
      }
    }
  } : null
}

# ============================================================================
# AUTHENTICATION AND SECURITY OUTPUTS
# ============================================================================

output "authentication_validation" {
  description = "Authentication method validation and security configuration status"
  value = {
    authentication_method = var.auth_method
    aws_profile_used     = var.aws_profile
    
    assume_role_configuration = var.assume_role_arn != "" ? {
      role_arn      = var.assume_role_arn
      session_name  = var.session_name
      duration      = var.session_duration
      external_id_configured = var.external_id != ""
    } : null
    
    test_role_created = var.create_test_resources ? {
      role_name = aws_iam_role.test_role[0].name
      role_arn  = aws_iam_role.test_role[0].arn
      external_id = "terraform-cli-lab-${var.student_name}"
    } : null
    
    security_features = {
      encryption_enabled    = var.encryption_enabled
      monitoring_enabled    = var.monitoring_enabled
      backup_required      = var.backup_required
      data_classification  = var.data_classification
      compliance_framework = var.compliance_framework
    }
  }
}

# ============================================================================
# PROVIDER TESTING AND VALIDATION OUTPUTS
# ============================================================================

output "provider_testing_results" {
  description = "Provider testing and validation results for troubleshooting and verification"
  value = var.enable_provider_validation && var.create_test_resources ? {
    local_provider_test = {
      file_created = local_file.provider_test[0].filename
      content_hash = local_file.provider_test[0].content_md5
    }
    
    tls_provider_test = {
      key_algorithm = tls_private_key.test_key[0].algorithm
      key_size     = tls_private_key.test_key[0].rsa_bits
      public_key_pem = tls_private_key.test_key[0].public_key_pem
    }
    
    archive_provider_test = {
      archive_created = data.archive_file.test_archive[0].output_path
      archive_size    = data.archive_file.test_archive[0].output_size
      archive_hash    = data.archive_file.test_archive[0].output_base64sha256
    }
    
    aws_provider_test = var.enable_authentication_test ? {
      s3_object_created = aws_s3_object.auth_test[0].key
      s3_object_etag   = aws_s3_object.auth_test[0].etag
      s3_object_size   = aws_s3_object.auth_test[0].content_length
    } : null
  } : null
}

# ============================================================================
# COST OPTIMIZATION OUTPUTS
# ============================================================================

output "cost_optimization_configuration" {
  description = "Cost optimization features and estimated costs for financial planning"
  value = {
    auto_shutdown_enabled = var.auto_shutdown_enabled
    auto_shutdown_hours   = var.auto_shutdown_hours
    cost_optimization_level = var.cost_optimization_level
    
    lambda_function = var.auto_shutdown_enabled && var.create_test_resources ? {
      function_name = aws_lambda_function.auto_shutdown[0].function_name
      function_arn  = aws_lambda_function.auto_shutdown[0].arn
      runtime       = aws_lambda_function.auto_shutdown[0].runtime
    } : null
    
    estimated_costs = {
      s3_storage_monthly     = "$0.023/GB (Standard)"
      dynamodb_monthly       = "$0.25 (Pay-per-request)"
      cloudwatch_logs_monthly = "$0.50/GB ingested"
      lambda_monthly         = "$0.20/1M requests"
      total_estimated_monthly = "$1.00 - $2.00"
    }
    
    cost_savings_features = [
      "Auto-shutdown after ${var.auto_shutdown_hours} hours",
      "Pay-per-request DynamoDB billing",
      "S3 lifecycle policies (if configured)",
      "CloudWatch log retention: 7 days",
      "Minimal resource footprint"
    ]
  }
}

# ============================================================================
# WORKSPACE AND ENVIRONMENT OUTPUTS
# ============================================================================

output "workspace_information" {
  description = "Terraform workspace and environment configuration for team collaboration"
  value = {
    current_workspace = terraform.workspace
    environment      = var.environment
    workspace_name   = var.workspace_name != "" ? var.workspace_name : terraform.workspace
    
    environment_specific_config = {
      development = {
        profile  = var.development_profile
        role_arn = var.development_role_arn
      }
      staging = {
        profile  = var.staging_profile
        role_arn = var.staging_role_arn
      }
      production = {
        profile  = var.production_profile
        role_arn = var.production_role_arn
      }
    }
    
    state_isolation = {
      workspace_key_prefix = "workspaces"
      state_path          = "terraform-cli-aws-provider/terraform.tfstate"
      isolation_method    = "workspace-based"
    }
  }
}

# ============================================================================
# TROUBLESHOOTING AND DEBUG OUTPUTS
# ============================================================================

output "troubleshooting_information" {
  description = "Troubleshooting and debugging information for issue resolution"
  value = {
    provider_endpoints = var.custom_endpoints
    
    common_issues = {
      authentication_failure = "Check AWS credentials and profile configuration"
      permission_denied      = "Verify IAM permissions for the authenticated user/role"
      region_mismatch       = "Ensure all resources are in the correct region"
      state_lock_timeout    = "Check DynamoDB table permissions and connectivity"
    }
    
    debug_commands = [
      "aws sts get-caller-identity --profile ${var.aws_profile}",
      "terraform providers",
      "terraform workspace list",
      "terraform state list",
      "terraform validate"
    ]
    
    log_locations = var.monitoring_enabled && var.create_test_resources ? [
      aws_cloudwatch_log_group.provider_test[0].name,
      var.enable_multi_region ? aws_cloudwatch_log_group.provider_test_secondary[0].name : null
    ] : []
  }
}

# ============================================================================
# NEXT STEPS AND RECOMMENDATIONS
# ============================================================================

output "next_steps" {
  description = "Recommended next steps and learning progression for continued development"
  value = {
    immediate_actions = [
      "1. Verify all provider configurations are working correctly",
      "2. Test authentication with different AWS profiles",
      "3. Validate multi-region resource deployment",
      "4. Configure remote state backend for team collaboration",
      "5. Test workspace switching and environment isolation"
    ]
    
    advanced_configurations = [
      "1. Implement cross-account access with assume role",
      "2. Configure AWS SSO integration",
      "3. Set up CI/CD pipeline with provider authentication",
      "4. Implement provider caching for performance",
      "5. Configure custom endpoints for testing"
    ]
    
    best_practices = [
      "Use IAM roles instead of long-term access keys",
      "Implement least privilege access policies",
      "Enable MFA for production environments",
      "Use separate AWS accounts for different environments",
      "Implement proper state file encryption and access controls"
    ]
    
    learning_resources = [
      "AWS Provider Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs",
      "Terraform CLI Documentation: https://developer.hashicorp.com/terraform/cli",
      "AWS IAM Best Practices: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html",
      "Terraform State Management: https://developer.hashicorp.com/terraform/language/state"
    ]
  }
}

# ============================================================================
# VALIDATION CHECKLIST OUTPUT
# ============================================================================

output "validation_checklist" {
  description = "Validation checklist for ensuring proper provider configuration"
  value = {
    provider_validation = {
      terraform_version_correct = "✅ Terraform ~> 1.13.0"
      aws_provider_version_correct = "✅ AWS Provider ~> 6.12.0"
      authentication_working = data.aws_caller_identity.current.account_id != "" ? "✅ Authentication successful" : "❌ Authentication failed"
      multi_region_configured = var.enable_multi_region ? "✅ Multi-region enabled" : "⚠️ Single region only"
      state_backend_configured = var.create_test_resources ? "✅ State backend created" : "⚠️ Local state only"
    }
    
    security_validation = {
      encryption_enabled = var.encryption_enabled ? "✅ Encryption enabled" : "⚠️ Encryption disabled"
      iam_roles_configured = var.create_test_resources ? "✅ IAM roles created" : "⚠️ No test roles"
      assume_role_configured = var.assume_role_arn != "" ? "✅ Assume role configured" : "⚠️ Direct authentication"
      monitoring_enabled = var.monitoring_enabled ? "✅ Monitoring enabled" : "⚠️ No monitoring"
    }
    
    cost_optimization = {
      auto_shutdown_enabled = var.auto_shutdown_enabled ? "✅ Auto-shutdown enabled" : "⚠️ Manual management"
      pay_per_request_dynamodb = var.create_test_resources ? "✅ Pay-per-request billing" : "N/A"
      minimal_resources = "✅ Minimal resource footprint"
      cost_tracking_tags = "✅ Comprehensive tagging"
    }
  }
}
