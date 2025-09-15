# AWS Terraform Training - Variables and Outputs
# Lab 5.1: Advanced Variable Management and Output Patterns
# File: locals.tf - Local Values for Variable Processing and Configuration Management

# ============================================================================
# CORE LOCAL VALUES AND VARIABLE PROCESSING
# ============================================================================

locals {
  # Resource naming and prefixing
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Current environment configuration from variable map
  current_env_config = var.environment_configs[var.environment]
  
  # Merged common tags from multiple sources
  common_tags = merge(
    var.default_tags,
    var.additional_tags,
    {
      # Core identification tags
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner_email
      CostCenter  = var.cost_center
      
      # Operational tags
      BackupRequired    = var.enable_backup ? "true" : "false"
      MonitoringEnabled = var.enable_monitoring ? "true" : "false"
      AutoShutdown      = var.enable_auto_shutdown ? "true" : "false"
      
      # Compliance and security tags
      DataClassification  = var.data_classification
      ComplianceFramework = var.compliance_framework
      RetentionPeriod     = var.data_retention_period
      
      # Environment-specific tags
      EnvironmentTier = local.current_env_config.security_config.encryption_level
      CostOptimized   = local.current_env_config.cost_config.enable_spot_instances ? "true" : "false"
      
      # Timestamp tags
      CreatedDate = timestamp()
      LastUpdated = timestamp()
    }
  )
  
  # Environment-specific resource configurations
  web_instance_config = {
    instance_type    = local.current_env_config.instance_types.web
    min_size        = local.current_env_config.scaling_config.web_min
    max_size        = local.current_env_config.scaling_config.web_max
    desired_size    = local.current_env_config.scaling_config.web_min
    enable_spot     = local.current_env_config.cost_config.enable_spot_instances
    monitoring      = local.current_env_config.performance_config.cloudwatch_detailed_monitoring
  }
  
  app_instance_config = {
    instance_type    = local.current_env_config.instance_types.app
    min_size        = local.current_env_config.scaling_config.app_min
    max_size        = local.current_env_config.scaling_config.app_max
    desired_size    = local.current_env_config.scaling_config.app_min
    enable_spot     = local.current_env_config.cost_config.enable_spot_instances
    monitoring      = local.current_env_config.performance_config.cloudwatch_detailed_monitoring
  }
  
  database_config = {
    instance_class   = local.current_env_config.instance_types.db
    engine          = var.infrastructure_config.database.engine
    engine_version  = var.infrastructure_config.database.engine_version
    allocated_storage = var.infrastructure_config.database.allocated_storage
    backup_retention = var.infrastructure_config.database.backup_retention
    multi_az        = var.infrastructure_config.database.multi_az
    encryption      = local.current_env_config.compliance_config.encryption_required
    monitoring      = local.current_env_config.performance_config.enable_enhanced_monitoring
  }
}

# ============================================================================
# SECURITY AND COMPLIANCE CONFIGURATION
# ============================================================================

locals {
  # Security configuration based on environment and compliance requirements
  security_config = {
    # WAF configuration
    enable_waf = local.current_env_config.security_config.enable_waf
    waf_rules = var.environment == "production" ? [
      "AWSManagedRulesCommonRuleSet",
      "AWSManagedRulesKnownBadInputsRuleSet",
      "AWSManagedRulesSQLiRuleSet",
      "AWSManagedRulesLinuxRuleSet"
    ] : [
      "AWSManagedRulesCommonRuleSet"
    ]
    
    # SSL/TLS configuration
    ssl_policy = local.current_env_config.security_config.ssl_policy
    ssl_certificate_required = var.environment != "development"
    
    # Encryption configuration
    encryption_config = {
      ebs_encrypted = local.current_env_config.compliance_config.encryption_required
      s3_encrypted  = local.current_env_config.compliance_config.encryption_required
      rds_encrypted = local.current_env_config.compliance_config.encryption_required
      kms_key_rotation = var.infrastructure_config.security.kms_key_rotation
    }
    
    # Access control configuration
    access_control = {
      enable_mfa = var.environment == "production"
      session_duration = var.environment == "production" ? 3600 : 28800  # 1 hour prod, 8 hours dev
      ip_restrictions = var.environment == "production" ? ["10.0.0.0/8", "172.16.0.0/12"] : []
    }
    
    # Compliance-specific settings
    compliance_settings = var.compliance_framework != "" ? {
      audit_logging_required = true
      data_residency_enforced = true
      backup_encryption_required = true
      network_segmentation_required = true
    } : {
      audit_logging_required = false
      data_residency_enforced = false
      backup_encryption_required = false
      network_segmentation_required = false
    }
  }
  
  # Network security configuration
  network_security = {
    # Security group rules based on environment
    web_ingress_rules = var.environment == "production" ? [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS from internet"
      }
    ] : [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP from internet"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS from internet"
      }
    ]
    
    # VPC Flow Logs configuration
    enable_flow_logs = var.infrastructure_config.networking.enable_flow_logs
    flow_logs_retention = local.current_env_config.compliance_config.audit_logging_required ? 90 : 7
    
    # Network ACL configuration
    enable_network_acls = var.environment == "production"
    default_network_acl_deny = var.environment == "production"
  }
}

# ============================================================================
# COST OPTIMIZATION CONFIGURATION
# ============================================================================

locals {
  # Cost optimization settings based on environment and variables
  cost_optimization = {
    # Instance optimization
    instance_optimization = {
      enable_spot_instances = local.current_env_config.cost_config.enable_spot_instances
      spot_max_price = local.current_env_config.cost_config.enable_spot_instances ? "0.05" : null
      reserved_capacity_target = local.current_env_config.cost_config.reserved_capacity
      
      # Right-sizing recommendations
      web_instance_type = local.current_env_config.cost_config.enable_spot_instances ? 
        "t3.small" : local.current_env_config.instance_types.web
      app_instance_type = local.current_env_config.cost_config.enable_spot_instances ? 
        "t3.medium" : local.current_env_config.instance_types.app
    }
    
    # Storage optimization
    storage_optimization = {
      s3_intelligent_tiering = var.environment != "development"
      s3_lifecycle_enabled = true
      ebs_gp3_enabled = true
      ebs_volume_optimization = var.environment == "production"
    }
    
    # Network optimization
    network_optimization = {
      single_nat_gateway = var.environment == "development"
      vpc_endpoints_enabled = var.enable_vpc_endpoints
      cloudfront_enabled = var.environment == "production"
    }
    
    # Monitoring and alerting for cost
    cost_monitoring = {
      budget_limit = local.current_env_config.cost_config.budget_limit_usd
      alert_thresholds = [50, 80, 100]  # Percentage of budget
      daily_cost_reports = var.environment == "production"
      cost_anomaly_detection = var.environment == "production"
    }
    
    # Auto-shutdown configuration
    auto_shutdown = local.current_env_config.cost_config.auto_shutdown_enabled ? {
      enabled = true
      schedule = "cron(0 20 * * MON-FRI)"  # Shutdown at 8 PM weekdays
      startup_schedule = "cron(0 8 * * MON-FRI)"   # Start at 8 AM weekdays
      exclude_tags = {
        "AutoShutdown" = "disabled"
        "Environment"  = "production"
      }
    } : null
  }
  
  # Resource tagging for cost allocation
  cost_allocation_tags = {
    CostCenter = var.cost_center
    Project = var.project_name
    Environment = var.environment
    Owner = var.owner_email
    BudgetCategory = var.environment == "production" ? "production-workloads" : "non-production-workloads"
    CostOptimized = local.current_env_config.cost_config.enable_spot_instances ? "true" : "false"
  }
}

# ============================================================================
# MONITORING AND OBSERVABILITY CONFIGURATION
# ============================================================================

locals {
  # Monitoring configuration based on environment requirements
  monitoring_config = {
    # CloudWatch configuration
    cloudwatch = {
      log_retention_days = var.infrastructure_config.monitoring.log_retention_days
      detailed_monitoring = local.current_env_config.performance_config.cloudwatch_detailed_monitoring
      custom_metrics_enabled = var.environment != "development"
      
      # Log groups configuration
      log_groups = {
        application = "/aws/ec2/${local.resource_prefix}/application"
        access = "/aws/ec2/${local.resource_prefix}/access"
        error = "/aws/ec2/${local.resource_prefix}/error"
        security = "/aws/ec2/${local.resource_prefix}/security"
      }
      
      # Metric filters
      metric_filters = var.environment == "production" ? [
        "ERROR",
        "WARN",
        "CRITICAL",
        "SECURITY"
      ] : ["ERROR", "CRITICAL"]
    }
    
    # Alerting configuration
    alerting = {
      sns_topic_name = "${local.resource_prefix}-alerts"
      alert_email = var.infrastructure_config.monitoring.alert_email
      
      # Alert thresholds based on environment
      cpu_threshold = var.environment == "production" ? 70 : 80
      memory_threshold = var.environment == "production" ? 80 : 85
      disk_threshold = var.environment == "production" ? 85 : 90
      
      # Alert frequency
      evaluation_periods = var.environment == "production" ? 2 : 3
      datapoints_to_alarm = var.environment == "production" ? 2 : 2
    }
    
    # Dashboard configuration
    dashboard = {
      enabled = var.infrastructure_config.monitoring.dashboard_enabled
      name = "${local.resource_prefix}-dashboard"
      
      # Widgets based on environment
      widgets = var.environment == "production" ? [
        "cpu_utilization",
        "memory_utilization",
        "disk_utilization",
        "network_in",
        "network_out",
        "application_errors",
        "response_time",
        "request_count"
      ] : [
        "cpu_utilization",
        "memory_utilization",
        "application_errors"
      ]
    }
    
    # Performance Insights (RDS)
    performance_insights = {
      enabled = local.current_env_config.performance_config.enable_performance_insights
      retention_period = var.environment == "production" ? 731 : 7  # 2 years for prod, 7 days for others
    }
  }
  
  # Compliance monitoring
  compliance_monitoring = var.compliance_framework != "" ? {
    config_rules_enabled = true
    cloudtrail_enabled = true
    guardduty_enabled = var.infrastructure_config.monitoring.enable_guardduty
    security_hub_enabled = var.environment == "production"
    
    # Compliance-specific rules
    config_rules = var.compliance_framework == "pci-dss" ? [
      "encrypted-volumes",
      "rds-encryption-enabled",
      "s3-bucket-ssl-requests-only",
      "cloudtrail-enabled"
    ] : var.compliance_framework == "hipaa" ? [
      "encrypted-volumes",
      "rds-encryption-enabled",
      "s3-bucket-ssl-requests-only",
      "cloudtrail-enabled",
      "access-keys-rotated"
    ] : [
      "encrypted-volumes",
      "cloudtrail-enabled"
    ]
  } : null
}

# ============================================================================
# COMPUTED VALUES AND VALIDATION
# ============================================================================

locals {
  # Computed networking values
  computed_networking = {
    # Calculate subnet sizes
    public_subnet_size = length(var.infrastructure_config.networking.public_subnet_cidrs)
    private_subnet_size = length(var.infrastructure_config.networking.private_subnet_cidrs)
    az_count = length(var.infrastructure_config.networking.availability_zones)
    
    # Validate subnet configuration
    subnets_balanced = local.computed_networking.public_subnet_size == local.computed_networking.private_subnet_size
    subnets_match_azs = local.computed_networking.public_subnet_size == local.computed_networking.az_count
    
    # NAT Gateway configuration
    nat_gateway_count = var.infrastructure_config.networking.enable_nat_gateway ? (
      local.cost_optimization.network_optimization.single_nat_gateway ? 1 : local.computed_networking.az_count
    ) : 0
  }
  
  # Computed storage values
  computed_storage = {
    # S3 bucket count and configuration
    s3_bucket_count = length(var.infrastructure_config.storage.s3_buckets)
    encrypted_buckets = length([
      for k, v in var.infrastructure_config.storage.s3_buckets : k
      if v.encryption_enabled
    ])
    versioned_buckets = length([
      for k, v in var.infrastructure_config.storage.s3_buckets : k
      if v.versioning_enabled
    ])
    
    # EFS configuration
    efs_count = length(var.infrastructure_config.storage.efs_file_systems)
    encrypted_efs = length([
      for k, v in var.infrastructure_config.storage.efs_file_systems : k
      if v.encrypted
    ])
  }
  
  # Configuration validation
  config_validation = {
    # Network validation
    network_valid = local.computed_networking.subnets_balanced && local.computed_networking.subnets_match_azs
    
    # Security validation
    security_valid = var.environment == "production" ? (
      local.security_config.encryption_config.ebs_encrypted &&
      local.security_config.encryption_config.s3_encrypted &&
      local.security_config.encryption_config.rds_encrypted
    ) : true
    
    # Cost validation
    cost_valid = local.current_env_config.cost_config.budget_limit_usd > 0
    
    # Compliance validation
    compliance_valid = var.compliance_framework != "" ? (
      local.security_config.compliance_settings.audit_logging_required &&
      local.security_config.compliance_settings.backup_encryption_required
    ) : true
  }
  
  # All validations passed
  all_validations_passed = alltrue([
    local.config_validation.network_valid,
    local.config_validation.security_valid,
    local.config_validation.cost_valid,
    local.config_validation.compliance_valid
  ])
}
