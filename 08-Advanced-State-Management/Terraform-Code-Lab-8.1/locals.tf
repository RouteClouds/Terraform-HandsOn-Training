# ============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# Topic 8: Advanced State Management with AWS
# ============================================================================

locals {
  # ============================================================================
  # RESOURCE NAMING AND IDENTIFICATION
  # ============================================================================
  
  # Generate consistent resource prefix
  resource_prefix = var.resource_prefix != "" ? var.resource_prefix : "${var.organization}-${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = {
    Project              = var.project_name
    Environment          = var.environment
    Owner                = var.owner
    CostCenter           = var.cost_center
    ManagedBy            = "Terraform"
    TrainingModule       = "Topic-8-Advanced-State-Management"
    CreatedDate          = formatdate("YYYY-MM-DD", timestamp())
    LastModified         = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
    Workspace            = terraform.workspace
    TerraformVersion     = "~> 1.13.0"
    ProviderVersion      = "~> 6.12.0"
    StateManagement      = "Advanced"
    SecurityLevel        = var.security_level
    ComplianceScope      = join(",", var.compliance_scope)
    DataClassification   = var.data_classification
    Student              = var.student_name
    Organization         = var.organization
  }

  # Security-specific tags
  security_tags = {
    EncryptionRequired   = "true"
    BackupRequired       = "true"
    MonitoringEnabled    = "true"
    AuditingEnabled      = "true"
    AccessControlLevel   = "Strict"
    DataRetention        = "${var.versioning_retention_days}days"
    ComplianceValidated  = "true"
  }

  # Cost optimization tags
  cost_tags = {
    CostOptimization     = var.enable_cost_optimization ? "enabled" : "disabled"
    IntelligentTiering   = var.enable_cost_optimization ? "enabled" : "disabled"
    LifecyclePolicies    = "enabled"
    BudgetTracking       = "enabled"
    CostAnomalyDetection = var.enable_cost_anomaly_detection ? "enabled" : "disabled"
  }

  # Operational tags
  operational_tags = {
    DisasterRecovery     = var.enable_cross_region_replication ? "enabled" : "disabled"
    CrossRegionReplication = var.enable_cross_region_replication ? "enabled" : "disabled"
    AutomatedBackup      = var.enable_versioning ? "enabled" : "disabled"
    PerformanceMonitoring = var.enable_performance_monitoring ? "enabled" : "disabled"
    StateValidation      = var.enable_state_validation ? "enabled" : "disabled"
    DriftDetection       = var.enable_drift_detection ? "enabled" : "disabled"
  }

  # ============================================================================
  # ENVIRONMENT-SPECIFIC CONFIGURATIONS
  # ============================================================================
  
  # Environment-specific settings
  environment_config = {
    development = {
      retention_days        = 30
      backup_frequency     = "daily"
      monitoring_level     = "basic"
      cost_optimization    = true
      security_level       = "medium"
      performance_tier     = "standard"
    }
    staging = {
      retention_days        = 60
      backup_frequency     = "daily"
      monitoring_level     = "enhanced"
      cost_optimization    = true
      security_level       = "high"
      performance_tier     = "standard"
    }
    production = {
      retention_days        = 90
      backup_frequency     = "continuous"
      monitoring_level     = "comprehensive"
      cost_optimization    = false
      security_level       = "critical"
      performance_tier     = "high"
    }
    lab = {
      retention_days        = 7
      backup_frequency     = "daily"
      monitoring_level     = "basic"
      cost_optimization    = true
      security_level       = "high"
      performance_tier     = "standard"
    }
  }

  # Current environment configuration
  current_env_config = local.environment_config[var.environment]

  # ============================================================================
  # SECURITY CONFIGURATIONS
  # ============================================================================
  
  # Security level configurations
  security_config = {
    low = {
      encryption_required    = false
      mfa_delete            = false
      access_logging        = false
      audit_trail           = false
      vpc_endpoints         = false
      advanced_monitoring   = false
    }
    medium = {
      encryption_required    = true
      mfa_delete            = false
      access_logging        = true
      audit_trail           = true
      vpc_endpoints         = false
      advanced_monitoring   = true
    }
    high = {
      encryption_required    = true
      mfa_delete            = true
      access_logging        = true
      audit_trail           = true
      vpc_endpoints         = true
      advanced_monitoring   = true
    }
    critical = {
      encryption_required    = true
      mfa_delete            = true
      access_logging        = true
      audit_trail           = true
      vpc_endpoints         = true
      advanced_monitoring   = true
    }
  }

  # Current security configuration
  current_security_config = local.security_config[var.security_level]

  # ============================================================================
  # COMPLIANCE CONFIGURATIONS
  # ============================================================================
  
  # Compliance framework requirements
  compliance_requirements = {
    "SOC2" = {
      encryption_required     = true
      access_logging         = true
      audit_trail           = true
      data_retention_min    = 90
      monitoring_required   = true
      backup_required       = true
    }
    "PCI-DSS" = {
      encryption_required     = true
      access_logging         = true
      audit_trail           = true
      data_retention_min    = 365
      monitoring_required   = true
      backup_required       = true
    }
    "HIPAA" = {
      encryption_required     = true
      access_logging         = true
      audit_trail           = true
      data_retention_min    = 2555  # 7 years
      monitoring_required   = true
      backup_required       = true
    }
    "GDPR" = {
      encryption_required     = true
      access_logging         = true
      audit_trail           = true
      data_retention_min    = 1095  # 3 years
      monitoring_required   = true
      backup_required       = true
    }
    "FedRAMP" = {
      encryption_required     = true
      access_logging         = true
      audit_trail           = true
      data_retention_min    = 2555  # 7 years
      monitoring_required   = true
      backup_required       = true
    }
    "ISO27001" = {
      encryption_required     = true
      access_logging         = true
      audit_trail           = true
      data_retention_min    = 1095  # 3 years
      monitoring_required   = true
      backup_required       = true
    }
  }

  # Aggregate compliance requirements
  aggregated_compliance = {
    encryption_required  = alltrue([for framework in var.compliance_scope : local.compliance_requirements[framework].encryption_required])
    access_logging      = alltrue([for framework in var.compliance_scope : local.compliance_requirements[framework].access_logging])
    audit_trail        = alltrue([for framework in var.compliance_scope : local.compliance_requirements[framework].audit_trail])
    data_retention_min = max([for framework in var.compliance_scope : local.compliance_requirements[framework].data_retention_min]...)
    monitoring_required = alltrue([for framework in var.compliance_scope : local.compliance_requirements[framework].monitoring_required])
    backup_required    = alltrue([for framework in var.compliance_scope : local.compliance_requirements[framework].backup_required])
  }

  # ============================================================================
  # COST OPTIMIZATION CONFIGURATIONS
  # ============================================================================
  
  # Cost optimization settings based on environment
  cost_optimization_config = {
    s3_intelligent_tiering = var.enable_cost_optimization
    lifecycle_policies     = true
    storage_class_analysis = var.enable_cost_optimization
    cost_allocation_tags   = true
    budget_alerts         = true
    cost_anomaly_detection = var.enable_cost_anomaly_detection
  }

  # Storage lifecycle configuration
  lifecycle_rules = var.enable_cost_optimization ? [
    {
      id     = "terraform-state-optimization"
      status = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
    }
  ] : []

  # ============================================================================
  # PERFORMANCE CONFIGURATIONS
  # ============================================================================
  
  # Performance optimization settings
  performance_config = {
    standard = {
      s3_transfer_acceleration = false
      dynamodb_auto_scaling   = false
      cloudwatch_detailed     = false
      request_payer          = "BucketOwner"
    }
    high = {
      s3_transfer_acceleration = true
      dynamodb_auto_scaling   = true
      cloudwatch_detailed     = true
      request_payer          = "BucketOwner"
    }
  }

  # Current performance configuration
  current_performance_config = local.performance_config[local.current_env_config.performance_tier]

  # ============================================================================
  # MONITORING CONFIGURATIONS
  # ============================================================================
  
  # Monitoring level configurations
  monitoring_config = {
    basic = {
      cloudwatch_metrics     = ["BucketSizeBytes", "NumberOfObjects"]
      cloudwatch_alarms     = ["HighStorageUsage"]
      log_retention_days    = 7
      detailed_monitoring   = false
    }
    enhanced = {
      cloudwatch_metrics     = ["BucketSizeBytes", "NumberOfObjects", "BucketRequests"]
      cloudwatch_alarms     = ["HighStorageUsage", "UnusualAccess"]
      log_retention_days    = 30
      detailed_monitoring   = true
    }
    comprehensive = {
      cloudwatch_metrics     = ["BucketSizeBytes", "NumberOfObjects", "BucketRequests", "DataRetrievals"]
      cloudwatch_alarms     = ["HighStorageUsage", "UnusualAccess", "FailedRequests", "HighLatency"]
      log_retention_days    = 90
      detailed_monitoring   = true
    }
  }

  # Current monitoring configuration
  current_monitoring_config = local.monitoring_config[local.current_env_config.monitoring_level]

  # ============================================================================
  # DISASTER RECOVERY CONFIGURATIONS
  # ============================================================================
  
  # Disaster recovery settings
  dr_config = {
    enabled                = var.enable_cross_region_replication
    primary_region        = var.aws_region
    dr_region             = var.dr_region
    rto_minutes           = var.rto_minutes
    rpo_minutes           = var.rpo_minutes
    automated_failover    = var.enable_automated_failover
    backup_frequency      = local.current_env_config.backup_frequency
    retention_days        = max(var.versioning_retention_days, local.aggregated_compliance.data_retention_min)
  }

  # ============================================================================
  # WORKSPACE CONFIGURATIONS
  # ============================================================================
  
  # Workspace-specific configurations
  workspace_config = {
    isolated = {
      state_key_pattern = "${terraform.workspace}/${var.project_name}/terraform.tfstate"
      lock_table_suffix = terraform.workspace
      separate_buckets  = true
    }
    shared = {
      state_key_pattern = "shared/${var.project_name}/${terraform.workspace}/terraform.tfstate"
      lock_table_suffix = "shared"
      separate_buckets  = false
    }
  }

  # Current workspace configuration
  current_workspace_config = local.workspace_config[var.workspace_strategy]

  # ============================================================================
  # VALIDATION AND TESTING CONFIGURATIONS
  # ============================================================================
  
  # Validation settings
  validation_config = {
    enabled              = var.enable_state_validation
    schedule            = var.validation_schedule
    drift_detection     = var.enable_drift_detection
    integrity_checks    = true
    performance_testing = var.enable_performance_monitoring
  }

  # ============================================================================
  # COMPUTED VALUES
  # ============================================================================
  
  # Computed bucket names with uniqueness
  primary_bucket_name = "${var.state_bucket_prefix}-${var.organization}-${random_id.bucket_suffix.hex}"
  dr_bucket_name      = "${var.state_bucket_prefix}-${var.organization}-dr-${random_id.bucket_suffix.hex}"
  
  # Computed table names
  primary_table_name = "${local.resource_prefix}-terraform-locks"
  dr_table_name      = "${local.resource_prefix}-terraform-locks-dr"
  
  # Computed KMS key descriptions
  primary_kms_description = "Terraform state encryption key for ${var.aws_region} (${var.environment})"
  dr_kms_description      = "Terraform state encryption key for ${var.dr_region} (${var.environment}-dr)"

  # Final retention period (compliance-aware)
  final_retention_days = max(
    var.versioning_retention_days,
    local.aggregated_compliance.data_retention_min,
    local.current_env_config.retention_days
  )

  # Resource count for cost estimation
  resource_count = {
    s3_buckets      = var.enable_cross_region_replication ? 2 : 1
    dynamodb_tables = var.enable_cross_region_replication ? 2 : 1
    kms_keys        = var.enable_cross_region_replication ? 2 : 1
    iam_roles       = var.enable_cross_region_replication ? 1 : 0
    total           = (var.enable_cross_region_replication ? 2 : 1) * 3 + (var.enable_cross_region_replication ? 1 : 0)
  }
}
