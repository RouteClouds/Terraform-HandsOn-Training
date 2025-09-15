# =============================================================================
# AWS Terraform Training - Topic 7: Modules and Module Development
# Output Values for Module Development Infrastructure
# =============================================================================

# =============================================================================
# Module Development Environment Outputs
# =============================================================================

output "module_development_environment" {
  description = "Module development environment information"
  value = {
    project_name         = var.project_name
    environment          = var.environment
    aws_region          = data.aws_region.current.name
    account_id          = data.aws_caller_identity.current.account_id
    deployment_time     = time_static.deployment_time.rfc3339
    module_version      = var.module_version
    development_mode    = var.module_development_mode
    testing_enabled     = var.enable_module_testing
  }
}

# =============================================================================
# VPC Module Outputs
# =============================================================================

output "vpc_module_outputs" {
  description = "Outputs from the VPC module example"
  value = var.module_examples["vpc_module"].enabled ? {
    vpc_id               = module.vpc_example[0].vpc_id
    vpc_cidr_block      = module.vpc_example[0].vpc_cidr_block
    public_subnet_ids   = module.vpc_example[0].public_subnet_ids
    private_subnet_ids  = module.vpc_example[0].private_subnet_ids
    internet_gateway_id = module.vpc_example[0].internet_gateway_id
    nat_gateway_ids     = module.vpc_example[0].nat_gateway_ids
    route_table_ids     = module.vpc_example[0].route_table_ids
  } : null
}

output "vpc_module_metadata" {
  description = "Metadata for the VPC module"
  value = var.module_examples["vpc_module"].enabled ? {
    module_source      = "./modules/vpc"
    module_version     = var.module_version
    creation_time      = time_static.deployment_time.rfc3339
    configuration      = var.module_examples["vpc_module"]
    resource_count     = module.vpc_example[0].resource_count
    estimated_cost_usd = module.vpc_example[0].estimated_monthly_cost
  } : null
}

# =============================================================================
# Security Group Module Outputs
# =============================================================================

output "security_group_module_outputs" {
  description = "Outputs from the Security Group module example"
  value = var.module_examples["compute_module"].enabled ? {
    security_group_id   = module.security_group_example[0].security_group_id
    security_group_arn  = module.security_group_example[0].security_group_arn
    security_group_name = module.security_group_example[0].security_group_name
    ingress_rules       = module.security_group_example[0].ingress_rules
    egress_rules        = module.security_group_example[0].egress_rules
  } : null
}

# =============================================================================
# EC2 Instance Module Outputs
# =============================================================================

output "ec2_instance_module_outputs" {
  description = "Outputs from the EC2 Instance module example"
  value = var.module_examples["compute_module"].enabled ? {
    auto_scaling_group_arn  = module.ec2_instance_example[0].auto_scaling_group_arn
    auto_scaling_group_name = module.ec2_instance_example[0].auto_scaling_group_name
    launch_template_id      = module.ec2_instance_example[0].launch_template_id
    launch_template_version = module.ec2_instance_example[0].launch_template_version
    instance_ids           = module.ec2_instance_example[0].instance_ids
    instance_public_ips    = module.ec2_instance_example[0].instance_public_ips
    instance_private_ips   = module.ec2_instance_example[0].instance_private_ips
  } : null
}

# =============================================================================
# S3 Bucket Module Outputs
# =============================================================================

output "s3_bucket_module_outputs" {
  description = "Outputs from the S3 Bucket module example"
  value = var.module_examples["storage_module"].enabled ? {
    bucket_id                = module.s3_bucket_example[0].bucket_id
    bucket_arn               = module.s3_bucket_example[0].bucket_arn
    bucket_domain_name       = module.s3_bucket_example[0].bucket_domain_name
    bucket_regional_domain_name = module.s3_bucket_example[0].bucket_regional_domain_name
    bucket_hosted_zone_id    = module.s3_bucket_example[0].bucket_hosted_zone_id
    versioning_enabled       = module.s3_bucket_example[0].versioning_enabled
    encryption_enabled       = module.s3_bucket_example[0].encryption_enabled
  } : null
}

# =============================================================================
# RDS Database Module Outputs
# =============================================================================

output "rds_database_module_outputs" {
  description = "Outputs from the RDS Database module example"
  value = var.module_examples["storage_module"].enabled ? {
    db_instance_id       = module.rds_database_example[0].db_instance_id
    db_instance_arn      = module.rds_database_example[0].db_instance_arn
    db_instance_endpoint = module.rds_database_example[0].db_instance_endpoint
    db_instance_port     = module.rds_database_example[0].db_instance_port
    db_subnet_group_id   = module.rds_database_example[0].db_subnet_group_id
    db_parameter_group_id = module.rds_database_example[0].db_parameter_group_id
    db_security_group_id = module.rds_database_example[0].db_security_group_id
  } : null
  sensitive = true
}

# =============================================================================
# Module Testing Infrastructure Outputs
# =============================================================================

output "module_testing_infrastructure" {
  description = "Module testing infrastructure details"
  value = var.enable_module_testing ? {
    testing_bucket_name    = aws_s3_bucket.module_testing[0].bucket
    testing_bucket_arn     = aws_s3_bucket.module_testing[0].arn
    registry_bucket_name   = var.module_registry_url == null ? aws_s3_bucket.module_registry[0].bucket : null
    registry_bucket_arn    = var.module_registry_url == null ? aws_s3_bucket.module_registry[0].arn : null
    testing_environments   = var.testing_environments
  } : null
}

# =============================================================================
# Multi-Region Testing Outputs
# =============================================================================

output "multi_region_testing" {
  description = "Multi-region testing infrastructure details"
  value = var.enable_multi_region_testing ? {
    secondary_region       = var.secondary_region
    secondary_vpc_id       = module.vpc_secondary_region[0].vpc_id
    secondary_vpc_cidr     = module.vpc_secondary_region[0].vpc_cidr_block
    secondary_subnet_ids   = module.vpc_secondary_region[0].public_subnet_ids
  } : null
}

# =============================================================================
# Module Development Metrics
# =============================================================================

output "module_development_metrics" {
  description = "Metrics and statistics for module development"
  value = {
    total_modules_created = length([
      for module_name, config in var.module_examples : module_name
      if config.enabled
    ])
    
    enabled_modules = [
      for module_name, config in var.module_examples : module_name
      if config.enabled
    ]
    
    module_configurations = {
      for module_name, config in var.module_examples : module_name => config
      if config.enabled
    }
    
    testing_configurations = {
      for env_name, config in var.testing_environments : env_name => config
      if config.enabled
    }
    
    estimated_monthly_cost = sum([
      for module_name, config in var.module_examples : (
        config.enabled ? (
          module_name == "vpc_module" ? 50 :
          module_name == "compute_module" ? (config.desired_capacity * 15) :
          module_name == "storage_module" ? 25 : 0
        ) : 0
      )
    ])
  }
}

# =============================================================================
# Module Registry Integration
# =============================================================================

output "module_registry_integration" {
  description = "Module registry integration information"
  value = {
    registry_url           = var.module_registry_url
    private_registry_enabled = var.module_registry_url == null && var.enable_module_testing
    module_versioning_enabled = var.enable_module_versioning
    current_module_version = var.module_version
    
    module_sources = {
      vpc_module           = "./modules/vpc"
      security_group_module = "./modules/security-group"
      ec2_instance_module  = "./modules/ec2-instance"
      s3_bucket_module     = "./modules/s3-bucket"
      rds_database_module  = "./modules/rds-database"
    }
  }
}

# =============================================================================
# Security and Compliance Outputs
# =============================================================================

output "security_compliance_status" {
  description = "Security and compliance status for module development"
  value = {
    security_scanning_enabled   = var.enable_security_scanning
    compliance_checking_enabled = var.enable_compliance_checking
    security_scan_schedule      = var.security_scan_schedule
    
    security_features = {
      encryption_enabled        = true
      access_logging_enabled    = true
      versioning_enabled        = true
      public_access_blocked     = true
      iam_roles_configured      = true
    }
    
    compliance_frameworks = {
      aws_config_rules    = var.enable_compliance_checking
      cloudtrail_logging  = true
      vpc_flow_logs      = true
      security_groups    = true
    }
  }
}

# =============================================================================
# Operational Outputs
# =============================================================================

output "operational_information" {
  description = "Operational information for module management"
  value = {
    deployment_timestamp = time_static.deployment_time.rfc3339
    rotation_timestamp   = time_rotating.monthly_rotation.rfc3339
    account_id          = data.aws_caller_identity.current.account_id
    caller_arn          = data.aws_caller_identity.current.arn
    region              = data.aws_region.current.name
    available_zones     = data.aws_availability_zones.available.names
    
    resource_tags = {
      Project             = var.project_name
      Environment         = var.environment
      Owner               = var.owner
      CostCenter          = var.cost_center
      ManagedBy           = "Terraform"
      TrainingModule      = "Topic-7-Modules-Development"
      ModuleVersion       = var.module_version
    }
  }
  sensitive = true
}

# =============================================================================
# Module Development Commands
# =============================================================================

output "module_development_commands" {
  description = "Useful commands for module development and testing"
  value = {
    module_validation = {
      validate_syntax    = "terraform validate"
      format_code       = "terraform fmt -recursive"
      plan_modules      = "terraform plan -target=module.vpc_example"
      apply_modules     = "terraform apply -target=module.vpc_example"
    }
    
    module_testing = {
      run_tests         = "terraform test"
      validate_modules  = "terraform validate modules/"
      check_formatting  = "terraform fmt -check -recursive modules/"
      security_scan     = "tfsec modules/"
    }
    
    module_publishing = {
      tag_version       = "git tag v${var.module_version}"
      create_release    = "gh release create v${var.module_version}"
      publish_registry  = "terraform login && terraform publish"
    }
  }
}

# =============================================================================
# Integration and Automation Outputs
# =============================================================================

output "ci_cd_integration" {
  description = "CI/CD integration information for module development"
  value = {
    environment_variables = {
      TF_VAR_project_name         = var.project_name
      TF_VAR_environment          = var.environment
      TF_VAR_aws_region           = data.aws_region.current.name
      TF_VAR_module_version       = var.module_version
      TF_VAR_enable_module_testing = var.enable_module_testing
    }
    
    testing_matrix = {
      for env_name, config in var.testing_environments : env_name => {
        enabled              = config.enabled
        test_scenarios       = config.test_scenarios
        duration_hours       = config.test_duration_hours
        notification_email   = config.notification_email
      }
    }
    
    automation_triggers = {
      on_push              = "terraform plan"
      on_pull_request      = "terraform plan && terraform test"
      on_release           = "terraform apply && terraform test"
      scheduled_tests      = var.security_scan_schedule
    }
  }
  sensitive = true
}

# =============================================================================
# Output Configuration Notes:
# 
# 1. Module Development Focus:
#    - Comprehensive module outputs for integration
#    - Module metadata and versioning information
#    - Testing infrastructure details
#    - Development environment configuration
#
# 2. Operational Data:
#    - Deployment timestamps and caller information
#    - Resource tags and cost estimates
#    - Security and compliance status
#    - Multi-region testing capabilities
#
# 3. Integration Support:
#    - CI/CD environment variables
#    - Module development commands
#    - Testing matrix configuration
#    - Registry integration details
#
# 4. Security and Compliance:
#    - Security scanning status
#    - Compliance framework alignment
#    - Access control information
#    - Sensitive data handling
# =============================================================================
