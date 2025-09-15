# =============================================================================
# Terraform Workspace Configuration Template
# Environment-Specific Variable Configuration
# =============================================================================

# Project Configuration
project_name = "${project_name}"
environment  = "${environment}"
owner        = "${owner}"
cost_center  = "${cost_center}"

# AWS Configuration
aws_region    = "${aws_region}"
backup_region = "${backup_region}"

# Network Configuration
vpc_cidr = "${vpc_cidr}"
availability_zones = ${jsonencode(availability_zones)}

# Security Configuration
enable_vpc_flow_logs      = ${enable_vpc_flow_logs}
enable_cloudtrail         = ${enable_cloudtrail}
cloudtrail_retention_days = ${cloudtrail_retention_days}

# Monitoring Configuration
enable_detailed_monitoring = ${enable_detailed_monitoring}
notification_email         = "${notification_email}"

# Cost Management
enable_cost_allocation_tags = ${enable_cost_allocation_tags}
budget_limit               = ${budget_limit}

# State Management Configuration
enable_state_encryption    = ${enable_state_encryption}
enable_state_versioning    = ${enable_state_versioning}
state_version_retention    = ${state_version_retention}

# Feature Flags
enable_backup_region_resources  = ${enable_backup_region_resources}
enable_cross_region_replication = ${enable_cross_region_replication}

# Environment-Specific Workspace Configuration
workspace_environments = {
  ${environment} = {
    environment_type  = "${environment_type}"
    instance_types    = ${jsonencode(instance_types)}
    min_capacity      = ${min_capacity}
    max_capacity      = ${max_capacity}
    enable_monitoring = ${enable_monitoring}
    backup_retention  = ${backup_retention}
  }
}

# =============================================================================
# Workspace Configuration Notes:
# 
# This template generates environment-specific variable files for Terraform
# workspaces. Each environment (development, staging, production) can have
# its own configuration while maintaining consistency.
#
# Usage:
# 1. Generate workspace-specific .tfvars files using this template
# 2. Apply with: terraform apply -var-file="${environment}.tfvars"
# 3. Or use workspace selection: terraform workspace select ${environment}
#
# Environment Patterns:
# - Development: Cost-optimized, minimal monitoring, no backup
# - Staging: Production-like, moderate monitoring, basic backup
# - Production: Full monitoring, encryption, cross-region backup
# =============================================================================
