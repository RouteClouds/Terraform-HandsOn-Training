# AWS Terraform Training - Variables and Outputs
# Lab 5.1: Advanced Variable Management and Output Patterns
# File: outputs.tf - Comprehensive Output Patterns for Module Integration and Automation

# ============================================================================
# INFRASTRUCTURE ENDPOINTS OUTPUT
# ============================================================================

output "infrastructure_endpoints" {
  description = "Complete infrastructure endpoint information for downstream modules and automation"
  value = {
    # Network endpoints
    networking = {
      vpc_id                = aws_vpc.main.id
      vpc_cidr_block       = aws_vpc.main.cidr_block
      internet_gateway_id  = aws_internet_gateway.main.id
      nat_gateway_ids      = aws_nat_gateway.main[*].id
      
      public_subnets = {
        ids          = aws_subnet.public[*].id
        cidr_blocks  = aws_subnet.public[*].cidr_block
        route_table_id = aws_route_table.public.id
      }
      
      private_subnets = {
        ids          = aws_subnet.private[*].id
        cidr_blocks  = aws_subnet.private[*].cidr_block
        route_table_ids = aws_route_table.private[*].id
      }
      
      security_groups = {
        web_sg_id = aws_security_group.web.id
        app_sg_id = aws_security_group.app.id
        db_sg_id  = aws_security_group.db.id
      }
    }
    
    # Storage endpoints
    storage = {
      s3_buckets = {
        for bucket_name, bucket in aws_s3_bucket.main :
        bucket_name => {
          bucket_name = bucket.bucket
          bucket_arn  = bucket.arn
          domain_name = bucket.bucket_domain_name
          region      = bucket.region
        }
      }
    }
    
    # IAM resources
    iam = {
      ec2_role_arn = aws_iam_role.ec2.arn
      ec2_instance_profile_name = aws_iam_instance_profile.ec2.name
    }
  }
  
  depends_on = [
    aws_vpc.main,
    aws_subnet.public,
    aws_subnet.private,
    aws_s3_bucket.main
  ]
}

# ============================================================================
# SECURITY CONFIGURATION OUTPUT
# ============================================================================

output "security_configuration" {
  description = "Security configuration details for compliance and auditing"
  value = {
    # Encryption configuration
    encryption = {
      kms_keys = local.security_context.kms_key_ids
      
      # Encryption status by service
      encryption_status = {
        ebs_encrypted = local.security_config.encryption_config.ebs_encrypted
        s3_encrypted  = local.security_config.encryption_config.s3_encrypted
        rds_encrypted = local.security_config.encryption_config.rds_encrypted
      }
    }
    
    # Access control
    access_control = {
      iam_roles = local.security_context.iam_policy_arns
      
      security_groups = {
        web_sg_rules = length(aws_security_group.web.ingress)
        app_sg_rules = length(aws_security_group.app.ingress)
        db_sg_rules  = length(aws_security_group.db.ingress)
      }
      
      # SSL certificates
      ssl_certificates = local.security_context.ssl_certificate_arns
    }
    
    # Compliance configuration
    compliance = {
      framework = var.compliance_framework
      data_classification = var.data_classification
      audit_logging_enabled = local.security_config.compliance_settings.audit_logging_required
      encryption_required = local.security_config.compliance_settings.backup_encryption_required
    }
    
    # Network security
    network_security = {
      vpc_flow_logs_enabled = local.network_security.enable_flow_logs
      waf_enabled = local.security_config.enable_waf
      ssl_policy = local.security_config.ssl_policy
    }
  }
  
  sensitive = false
}

# ============================================================================
# SENSITIVE CONFIGURATION OUTPUT
# ============================================================================

output "sensitive_configuration" {
  description = "Sensitive configuration data for secure access and automation"
  value = {
    # Secrets Manager references
    secrets_manager = {
      database_secret_arn = aws_secretsmanager_secret.database_credentials.arn
      api_secret_arn = length(aws_secretsmanager_secret.api_credentials) > 0 ? aws_secretsmanager_secret.api_credentials[0].arn : null
    }
    
    # Parameter Store references
    parameter_store = {
      app_config_prefix    = "/${var.project_name}/${var.environment}/app/"
      database_config_prefix = "/${var.project_name}/${var.environment}/database/"
      monitoring_config_prefix = "/${var.project_name}/${var.environment}/monitoring/"
    }
    
    # Database connection information
    database_connection = {
      endpoint = "Use Secrets Manager: ${aws_secretsmanager_secret.database_credentials.arn}"
      port     = 3306
      engine   = var.infrastructure_config.database.engine
    }
    
    # API credentials references
    api_credentials = length(var.api_credentials) > 0 ? {
      secret_arn = aws_secretsmanager_secret.api_credentials[0].arn
      services = keys(var.api_credentials)
    } : null
  }
  
  sensitive = true
}

# ============================================================================
# VARIABLE CONFIGURATION SUMMARY OUTPUT
# ============================================================================

output "variable_configuration_summary" {
  description = "Summary of variable-driven configuration for documentation and validation"
  value = {
    # Environment configuration
    environment = {
      name = var.environment
      tier = var.infrastructure_config.environment.tier
      region = var.aws_region
      multi_region_enabled = var.enable_multi_region
    }
    
    # Instance configuration
    compute_configuration = {
      web_tier = local.web_instance_config
      app_tier = local.app_instance_config
      database = local.database_config
    }
    
    # Cost optimization settings
    cost_optimization = {
      spot_instances_enabled = local.current_env_config.cost_config.enable_spot_instances
      auto_shutdown_enabled = local.current_env_config.cost_config.auto_shutdown_enabled
      budget_limit_usd = local.current_env_config.cost_config.budget_limit_usd
      reserved_capacity_percentage = local.current_env_config.cost_config.reserved_capacity
    }
    
    # Security settings
    security_settings = {
      waf_enabled = local.current_env_config.security_config.enable_waf
      ssl_policy = local.current_env_config.security_config.ssl_policy
      encryption_level = local.current_env_config.security_config.encryption_level
      compliance_framework = var.compliance_framework
    }
    
    # Feature flags
    feature_flags = {
      backup_enabled = var.enable_backup
      monitoring_enabled = var.enable_monitoring
      auto_shutdown_enabled = var.enable_auto_shutdown
      vpc_endpoints_enabled = var.enable_vpc_endpoints
      cross_region_backup_enabled = var.enable_cross_region_backup
      compliance_monitoring_enabled = var.enable_compliance_monitoring
    }
    
    # Validation results
    validation_results = {
      all_validations_passed = local.all_validations_passed
      variable_validations_passed = local.all_variable_validations_passed
      config_validations = local.config_validation
    }
  }
  
  sensitive = false
}

# ============================================================================
# COST ESTIMATION OUTPUT
# ============================================================================

output "cost_estimation" {
  description = "Cost estimation and optimization information based on variable configuration"
  value = {
    # Monthly cost estimates
    estimated_costs = {
      web_tier_monthly = local.cost_estimation.web_instance_hourly_cost * local.web_instance_config.desired_size * 24 * 30
      app_tier_monthly = local.cost_estimation.app_instance_hourly_cost * local.app_instance_config.desired_size * 24 * 30
      total_monthly_estimate = local.cost_estimation.estimated_monthly_cost
    }
    
    # Cost optimization potential
    optimization_potential = {
      spot_savings_monthly = local.cost_estimation.spot_savings_potential
      spot_enabled = local.current_env_config.cost_config.enable_spot_instances
      reserved_capacity_target = local.current_env_config.cost_config.reserved_capacity
    }
    
    # Budget configuration
    budget_configuration = {
      monthly_limit = local.current_env_config.cost_config.budget_limit_usd
      alert_thresholds = local.cost_optimization.cost_monitoring.alert_thresholds
      cost_allocation_tags = local.cost_allocation_tags
    }
    
    # Resource optimization
    resource_optimization = {
      storage_optimization_enabled = local.cost_optimization.storage_optimization.s3_intelligent_tiering
      network_optimization_enabled = local.cost_optimization.network_optimization.single_nat_gateway
      auto_shutdown_configured = local.cost_optimization.auto_shutdown != null
    }
  }
  
  sensitive = false
}

# ============================================================================
# MONITORING CONFIGURATION OUTPUT
# ============================================================================

output "monitoring_configuration" {
  description = "Monitoring and observability configuration based on variables"
  value = {
    # CloudWatch configuration
    cloudwatch = {
      log_groups = local.monitoring_config.cloudwatch.log_groups
      log_retention_days = local.monitoring_config.cloudwatch.log_retention_days
      detailed_monitoring_enabled = local.monitoring_config.cloudwatch.detailed_monitoring
      custom_metrics_enabled = local.monitoring_config.cloudwatch.custom_metrics_enabled
    }
    
    # Alerting configuration
    alerting = {
      sns_topic_name = local.monitoring_config.alerting.sns_topic_name
      alert_email = local.monitoring_config.alerting.alert_email
      thresholds = {
        cpu = local.monitoring_config.alerting.cpu_threshold
        memory = local.monitoring_config.alerting.memory_threshold
        disk = local.monitoring_config.alerting.disk_threshold
      }
    }
    
    # Dashboard configuration
    dashboard = {
      enabled = local.monitoring_config.dashboard.enabled
      name = local.monitoring_config.dashboard.name
      widgets = local.monitoring_config.dashboard.widgets
    }
    
    # Performance monitoring
    performance_monitoring = {
      enhanced_monitoring_enabled = local.current_env_config.performance_config.enable_enhanced_monitoring
      performance_insights_enabled = local.current_env_config.performance_config.enable_performance_insights
      detailed_monitoring_enabled = local.current_env_config.performance_config.cloudwatch_detailed_monitoring
    }
    
    # Compliance monitoring
    compliance_monitoring = local.compliance_monitoring
  }
  
  sensitive = false
}

# ============================================================================
# PARAMETER STORE CONFIGURATION OUTPUT
# ============================================================================

output "parameter_store_configuration" {
  description = "Parameter Store configuration and retrieved values"
  value = {
    # Retrieved configuration
    retrieved_config = local.parameter_store_config
    
    # Parameter paths
    parameter_paths = {
      app_config = "/${var.project_name}/${var.environment}/app/"
      database_config = "/${var.project_name}/${var.environment}/database/"
      monitoring_config = "/${var.project_name}/${var.environment}/monitoring/"
    }
    
    # Configuration status
    configuration_status = {
      app_config_available = length(data.aws_ssm_parameter.app_config) > 0
      database_config_available = length(data.aws_ssm_parameter.database_config) > 0
      monitoring_config_available = length(data.aws_ssm_parameter.monitoring_config) > 0
    }
  }
  
  sensitive = false
}

# ============================================================================
# MODULE INTEGRATION OUTPUT
# ============================================================================

output "module_integration" {
  description = "Structured output for seamless module integration and chaining"
  value = {
    # For networking modules
    networking_module_inputs = {
      vpc_id = aws_vpc.main.id
      public_subnet_ids = aws_subnet.public[*].id
      private_subnet_ids = aws_subnet.private[*].id
      security_group_ids = [
        aws_security_group.web.id,
        aws_security_group.app.id,
        aws_security_group.db.id
      ]
    }
    
    # For compute modules
    compute_module_inputs = {
      subnet_ids = aws_subnet.private[*].id
      security_group_ids = [aws_security_group.app.id]
      instance_profile_name = aws_iam_instance_profile.ec2.name
      ami_id = data.aws_ami.amazon_linux_2023.id
      instance_type = local.current_env_config.instance_types.app
    }
    
    # For storage modules
    storage_module_inputs = {
      vpc_id = aws_vpc.main.id
      subnet_ids = aws_subnet.private[*].id
      security_group_ids = [aws_security_group.db.id]
      kms_key_id = local.security_context.kms_key_ids.rds
    }
    
    # For monitoring modules
    monitoring_module_inputs = {
      log_group_names = values(local.monitoring_config.cloudwatch.log_groups)
      sns_topic_name = local.monitoring_config.alerting.sns_topic_name
      dashboard_name = local.monitoring_config.dashboard.name
    }
    
    # Common tags for all modules
    common_tags = local.common_tags
    
    # Environment configuration for modules
    environment_config = {
      environment = var.environment
      project_name = var.project_name
      region = var.aws_region
    }
  }
  
  sensitive = false
}
