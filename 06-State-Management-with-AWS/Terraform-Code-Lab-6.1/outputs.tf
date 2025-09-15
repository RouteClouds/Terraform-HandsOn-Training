# =============================================================================
# AWS Terraform Training - Topic 6: State Management with AWS
# Output Values for State Management Infrastructure
# =============================================================================

# =============================================================================
# State Backend Configuration Outputs
# =============================================================================

output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state storage"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform state storage"
  value       = aws_s3_bucket.terraform_state.arn
}

output "state_bucket_region" {
  description = "AWS region where the state bucket is located"
  value       = aws_s3_bucket.terraform_state.region
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for state encryption"
  value       = var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].key_id, null)
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for state encryption"
  value       = var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].arn, null)
}

# =============================================================================
# Backend Configuration Template
# =============================================================================

output "backend_configuration" {
  description = "Complete backend configuration for use in other Terraform configurations"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "path/to/your/terraform.tfstate"
    region         = data.aws_region.current.name
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    encrypt        = true
    kms_key_id     = var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].key_id, null)
  }
}

output "backend_configuration_hcl" {
  description = "HCL formatted backend configuration for copy-paste into terraform block"
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.bucket}"
        key            = "path/to/your/terraform.tfstate"
        region         = "${data.aws_region.current.name}"
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
        encrypt        = true
        kms_key_id     = "${var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].key_id, "")}"
      }
    }
  EOT
}

# =============================================================================
# Workspace and Environment Outputs
# =============================================================================

output "current_workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

output "workspace_state_key" {
  description = "State key pattern for current workspace"
  value       = "env:/${terraform.workspace}/terraform.tfstate"
}

output "environment_config" {
  description = "Environment configuration for current workspace"
  value       = try(var.workspace_environments[terraform.workspace], null)
}

# =============================================================================
# Backup and Disaster Recovery Outputs
# =============================================================================

output "backup_bucket_name" {
  description = "Name of the backup S3 bucket (if enabled)"
  value       = var.enable_backup_region_resources ? aws_s3_bucket.terraform_state_backup[0].bucket : null
}

output "backup_bucket_region" {
  description = "Region of the backup S3 bucket (if enabled)"
  value       = var.enable_backup_region_resources ? var.backup_region : null
}

output "replication_enabled" {
  description = "Whether cross-region replication is enabled"
  value       = var.enable_cross_region_replication
}

# =============================================================================
# Demo Infrastructure Outputs
# =============================================================================

output "demo_vpc_id" {
  description = "ID of the demo VPC"
  value       = aws_vpc.demo.id
}

output "demo_vpc_cidr" {
  description = "CIDR block of the demo VPC"
  value       = aws_vpc.demo.cidr_block
}

output "demo_subnet_ids" {
  description = "IDs of the demo public subnets"
  value       = aws_subnet.public[*].id
}

output "demo_security_group_id" {
  description = "ID of the demo security group"
  value       = aws_security_group.demo.id
}

# =============================================================================
# Security and Compliance Outputs
# =============================================================================

output "encryption_enabled" {
  description = "Whether state encryption is enabled"
  value       = var.enable_state_encryption
}

output "versioning_enabled" {
  description = "Whether state versioning is enabled"
  value       = var.enable_state_versioning
}

output "public_access_blocked" {
  description = "Whether public access to state bucket is blocked"
  value       = true
}

output "point_in_time_recovery_enabled" {
  description = "Whether point-in-time recovery is enabled for DynamoDB"
  value       = aws_dynamodb_table.terraform_locks.point_in_time_recovery[0].enabled
}

# =============================================================================
# Operational Outputs
# =============================================================================

output "deployment_timestamp" {
  description = "Timestamp when the infrastructure was deployed"
  value       = time_static.deployment_time.rfc3339
}

output "account_id" {
  description = "AWS account ID where resources are deployed"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "ARN of the caller who deployed the infrastructure"
  value       = data.aws_caller_identity.current.arn
  sensitive   = true
}

output "available_zones" {
  description = "Available availability zones in the current region"
  value       = data.aws_availability_zones.available.names
}

# =============================================================================
# Cost and Resource Management Outputs
# =============================================================================

output "resource_tags" {
  description = "Common tags applied to all resources"
  value = {
    Project             = var.project_name
    Environment         = var.environment
    Owner               = var.owner
    CostCenter          = var.cost_center
    ManagedBy           = "Terraform"
    TrainingModule      = "Topic-6-State-Management"
    Workspace           = terraform.workspace
    DeploymentTime      = time_static.deployment_time.rfc3339
  }
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (USD)"
  value = {
    s3_storage      = "~$0.50-2.00 (depending on state file size)"
    dynamodb_table  = "~$0.25-1.00 (depending on operations)"
    kms_key         = "~$1.00 (if using custom KMS key)"
    data_transfer   = "~$0.10-0.50 (depending on usage)"
    total_estimated = "~$2.00-5.00 per month"
    note           = "Costs may vary based on usage patterns and region"
  }
}

# =============================================================================
# Troubleshooting and Debugging Outputs
# =============================================================================

output "state_management_commands" {
  description = "Useful Terraform state management commands"
  value = {
    list_workspaces    = "terraform workspace list"
    create_workspace   = "terraform workspace new <name>"
    select_workspace   = "terraform workspace select <name>"
    show_state         = "terraform state list"
    pull_state         = "terraform state pull"
    backup_state       = "terraform state pull > backup.tfstate"
    force_unlock       = "terraform force-unlock <lock-id>"
    refresh_state      = "terraform refresh"
    import_resource    = "terraform import <resource> <id>"
  }
}

output "backend_migration_commands" {
  description = "Commands for backend migration scenarios"
  value = {
    init_migrate       = "terraform init -migrate-state"
    reconfigure        = "terraform init -reconfigure"
    backend_config     = "terraform init -backend-config=backend.hcl"
    copy_state         = "terraform init -migrate-state -force-copy"
  }
}

# =============================================================================
# Integration and Automation Outputs
# =============================================================================

output "ci_cd_environment_variables" {
  description = "Environment variables for CI/CD integration"
  value = {
    TF_VAR_state_bucket_name    = aws_s3_bucket.terraform_state.bucket
    TF_VAR_dynamodb_table_name  = aws_dynamodb_table.terraform_locks.name
    TF_VAR_aws_region          = data.aws_region.current.name
    TF_VAR_kms_key_id          = var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].key_id, "")
  }
  sensitive = true
}

output "terraform_cloud_integration" {
  description = "Configuration for Terraform Cloud integration"
  value = {
    organization = "your-terraform-cloud-org"
    workspace    = "${var.project_name}-${var.environment}"
    backend_type = "remote"
    note         = "Replace with actual Terraform Cloud organization name"
  }
}

# =============================================================================
# Monitoring and Alerting Integration
# =============================================================================

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for monitoring"
  value = {
    vpc_flow_logs = var.enable_vpc_flow_logs ? "/aws/vpc/flowlogs" : null
    cloudtrail    = var.enable_cloudtrail ? "/aws/cloudtrail/${var.project_name}" : null
  }
}

output "sns_topic_arn" {
  description = "SNS topic ARN for notifications (if created)"
  value       = null # Would be populated if SNS topic is created
}

# =============================================================================
# Output Configuration Notes:
# 
# 1. State Backend Information:
#    - Complete backend configuration for reuse
#    - HCL formatted configuration for easy copy-paste
#    - Security and encryption details
#    - Backup and disaster recovery information
#
# 2. Operational Data:
#    - Current workspace and environment details
#    - Deployment timestamps and caller information
#    - Resource tags and cost estimates
#    - Troubleshooting commands and procedures
#
# 3. Integration Support:
#    - CI/CD environment variables
#    - Terraform Cloud configuration
#    - Monitoring and alerting setup
#    - Cross-region and backup details
#
# 4. Security and Compliance:
#    - Encryption status and key information
#    - Access control and public access blocking
#    - Audit trail and compliance features
#    - Sensitive data handling
# =============================================================================
