# =============================================================================
# AWS Terraform Training - Topic 6: State Management with AWS
# Local Values for Complex Calculations and Transformations
# =============================================================================

locals {
  # =============================================================================
  # Environment and Workspace Configuration
  # =============================================================================
  
  # Current workspace configuration with fallback
  workspace_config = try(
    var.workspace_environments[terraform.workspace],
    var.workspace_environments["development"]
  )
  
  # Environment type detection
  environment_type = local.workspace_config.environment_type
  is_production    = contains(["production", "prod"], terraform.workspace)
  is_staging       = contains(["staging", "stage"], terraform.workspace)
  is_development   = contains(["development", "dev"], terraform.workspace)
  
  # Environment-specific settings
  environment_settings = {
    backup_required      = local.is_production || local.is_staging
    monitoring_level     = local.is_production ? "detailed" : local.is_staging ? "standard" : "basic"
    compliance_required  = local.is_production
    audit_retention_days = local.is_production ? 2555 : local.is_staging ? 365 : 90
    encryption_required  = local.is_production || local.is_staging
    versioning_required  = true
    mfa_required        = local.is_production
  }
  
  # =============================================================================
  # Resource Naming and Tagging
  # =============================================================================
  
  # Standardized naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  name_suffix = random_id.bucket_suffix.hex
  
  # Resource names
  resource_names = {
    state_bucket     = "${local.name_prefix}-state-${local.name_suffix}"
    backup_bucket    = "${local.name_prefix}-state-backup-${local.name_suffix}"
    dynamodb_table   = var.dynamodb_table_name
    kms_key_alias    = "${local.name_prefix}-terraform-state"
    vpc_name         = "${local.name_prefix}-demo-vpc"
    security_group   = "${local.name_prefix}-demo-sg"
  }
  
  # Common tags applied to all resources
  common_tags = merge(
    {
      Project             = var.project_name
      Environment         = var.environment
      Owner               = var.owner
      CostCenter          = var.cost_center
      ManagedBy           = "Terraform"
      TrainingModule      = "Topic-6-State-Management"
      CreatedDate         = formatdate("YYYY-MM-DD", timestamp())
      Workspace           = terraform.workspace
      TerraformVersion    = "~> 1.13.0"
      ProviderVersion     = "~> 6.12.0"
      Region              = data.aws_region.current.name
      AccountId           = data.aws_caller_identity.current.account_id
    },
    var.enable_cost_allocation_tags ? {
      BillingProject    = var.project_name
      BillingOwner      = var.owner
      BillingCostCenter = var.cost_center
      BillingEnvironment = var.environment
    } : {}
  )
  
  # Environment-specific tags
  environment_tags = {
    EnvironmentType     = local.environment_type
    BackupRequired      = local.environment_settings.backup_required
    MonitoringLevel     = local.environment_settings.monitoring_level
    ComplianceRequired  = local.environment_settings.compliance_required
    EncryptionRequired  = local.environment_settings.encryption_required
  }
  
  # =============================================================================
  # Network Configuration
  # =============================================================================
  
  # VPC and subnet calculations
  vpc_cidr_block = var.vpc_cidr
  
  # Calculate subnet CIDRs
  subnet_cidrs = {
    public = [
      for i in range(min(length(var.availability_zones), 3)) :
      cidrsubnet(local.vpc_cidr_block, 8, i)
    ]
    private = [
      for i in range(min(length(var.availability_zones), 3)) :
      cidrsubnet(local.vpc_cidr_block, 8, i + 10)
    ]
    database = [
      for i in range(min(length(var.availability_zones), 3)) :
      cidrsubnet(local.vpc_cidr_block, 8, i + 20)
    ]
  }
  
  # Availability zones (limited to 3 for cost optimization)
  availability_zones = slice(var.availability_zones, 0, min(length(var.availability_zones), 3))
  
  # =============================================================================
  # Security Configuration
  # =============================================================================
  
  # KMS key configuration
  kms_key_config = {
    use_custom_key = var.kms_key_id == null && local.environment_settings.encryption_required
    key_id         = var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].key_id, null)
    key_arn        = var.kms_key_id != null ? var.kms_key_id : try(aws_kms_key.terraform_state[0].arn, null)
  }
  
  # Security group rules
  security_group_rules = {
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
        description = "SSH access from private networks"
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS access"
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    ]
  }
  
  # =============================================================================
  # Backend Configuration
  # =============================================================================
  
  # Backend configuration for different scenarios
  backend_configs = {
    # Standard S3 backend
    s3 = {
      bucket         = aws_s3_bucket.terraform_state.bucket
      key            = "terraform.tfstate"
      region         = data.aws_region.current.name
      dynamodb_table = aws_dynamodb_table.terraform_locks.name
      encrypt        = true
      kms_key_id     = local.kms_key_config.key_id
    }
    
    # Workspace-aware backend
    workspace = {
      bucket               = aws_s3_bucket.terraform_state.bucket
      key                  = "terraform.tfstate"
      region               = data.aws_region.current.name
      dynamodb_table       = aws_dynamodb_table.terraform_locks.name
      encrypt              = true
      kms_key_id           = local.kms_key_config.key_id
      workspace_key_prefix = "env"
    }
    
    # Cross-account backend
    cross_account = var.assume_role_arn != null ? {
      bucket         = aws_s3_bucket.terraform_state.bucket
      key            = "terraform.tfstate"
      region         = data.aws_region.current.name
      dynamodb_table = aws_dynamodb_table.terraform_locks.name
      encrypt        = true
      kms_key_id     = local.kms_key_config.key_id
      role_arn       = var.assume_role_arn
      external_id    = var.external_id
    } : null
  }
  
  # =============================================================================
  # Monitoring and Alerting Configuration
  # =============================================================================
  
  # CloudWatch configuration
  cloudwatch_config = {
    enable_detailed_monitoring = var.enable_detailed_monitoring || local.environment_settings.monitoring_level == "detailed"
    log_retention_days         = local.environment_settings.audit_retention_days
    metric_namespace           = "${var.project_name}/terraform-state"
    
    # Alarm thresholds based on environment
    alarm_thresholds = {
      state_lock_duration_minutes = local.is_production ? 5 : 15
      failed_operations_count     = local.is_production ? 1 : 5
      cost_threshold_usd          = var.budget_limit * 0.8
    }
  }
  
  # SNS topics for notifications
  notification_config = {
    email_endpoint = var.notification_email
    topics = {
      state_alerts     = "${local.name_prefix}-state-alerts"
      cost_alerts      = "${local.name_prefix}-cost-alerts"
      security_alerts  = "${local.name_prefix}-security-alerts"
    }
  }
  
  # =============================================================================
  # Cost Management
  # =============================================================================
  
  # Cost allocation and budgeting
  cost_config = {
    budget_limit_usd = var.budget_limit
    cost_center      = var.cost_center
    
    # Estimated monthly costs (USD)
    estimated_costs = {
      s3_storage_gb        = 0.1  # Estimated state file size
      s3_requests_1000     = 10   # Estimated API requests
      dynamodb_rcu         = 5    # Read capacity units
      dynamodb_wcu         = 5    # Write capacity units
      kms_key_monthly      = local.kms_key_config.use_custom_key ? 1.0 : 0.0
      data_transfer_gb     = 1.0  # Cross-region transfer
      
      # Total estimated monthly cost
      total_estimated = 2.5
    }
    
    # Cost optimization settings
    optimization = {
      s3_lifecycle_enabled     = true
      s3_intelligent_tiering   = local.is_production
      dynamodb_on_demand       = true  # More cost-effective for variable workloads
      kms_key_rotation         = local.is_production
    }
  }
  
  # =============================================================================
  # Backup and Disaster Recovery
  # =============================================================================
  
  # Backup configuration
  backup_config = {
    enabled                    = local.environment_settings.backup_required
    cross_region_replication   = var.enable_cross_region_replication && local.environment_settings.backup_required
    backup_region             = var.backup_region
    retention_days            = local.workspace_config.backup_retention
    
    # Backup schedule
    schedule = {
      daily_backup_time   = "03:00"  # UTC
      weekly_backup_day   = "Sunday"
      monthly_backup_day  = 1
    }
    
    # Recovery objectives
    rto_hours = local.is_production ? 4 : 24   # Recovery Time Objective
    rpo_hours = local.is_production ? 1 : 8    # Recovery Point Objective
  }
  
  # =============================================================================
  # Compliance and Governance
  # =============================================================================
  
  # Compliance configuration
  compliance_config = {
    required = local.environment_settings.compliance_required
    
    frameworks = {
      soc2_type2 = local.is_production
      hipaa      = false  # Set to true if handling PHI
      pci_dss    = false  # Set to true if handling payment data
      gdpr       = true   # Set based on data residency requirements
    }
    
    # Audit requirements
    audit = {
      cloudtrail_enabled     = var.enable_cloudtrail
      vpc_flow_logs_enabled  = var.enable_vpc_flow_logs
      access_logging_enabled = true
      retention_years        = local.environment_settings.audit_retention_days / 365
    }
    
    # Data governance
    data_governance = {
      encryption_at_rest     = true
      encryption_in_transit  = true
      data_classification    = local.is_production ? "confidential" : "internal"
      data_residency_region  = data.aws_region.current.name
    }
  }
  
  # =============================================================================
  # Integration Configuration
  # =============================================================================
  
  # CI/CD integration settings
  cicd_config = {
    terraform_version = "~> 1.13.0"
    aws_provider_version = "~> 6.12.0"
    
    # Environment variables for CI/CD
    environment_variables = {
      TF_VAR_project_name        = var.project_name
      TF_VAR_environment         = var.environment
      TF_VAR_aws_region          = data.aws_region.current.name
      TF_VAR_state_bucket_name   = aws_s3_bucket.terraform_state.bucket
      TF_VAR_dynamodb_table_name = aws_dynamodb_table.terraform_locks.name
    }
    
    # Backend configuration for CI/CD
    backend_config_file = templatefile("${path.module}/templates/backend.tpl", {
      bucket         = aws_s3_bucket.terraform_state.bucket
      dynamodb_table = aws_dynamodb_table.terraform_locks.name
      region         = data.aws_region.current.name
      kms_key_id     = local.kms_key_config.key_id
    })
  }
}

# =============================================================================
# Local Values Configuration Notes:
# 
# 1. Environment Awareness:
#    - Workspace-based configuration selection
#    - Environment-specific security and compliance settings
#    - Automatic detection of production vs non-production
#
# 2. Resource Organization:
#    - Standardized naming conventions
#    - Comprehensive tagging strategy
#    - Cost allocation and tracking
#
# 3. Security Configuration:
#    - KMS key management and selection
#    - Security group rule definitions
#    - Compliance framework alignment
#
# 4. Operational Excellence:
#    - Monitoring and alerting configuration
#    - Backup and disaster recovery settings
#    - CI/CD integration support
#
# 5. Cost Management:
#    - Budget tracking and alerting
#    - Cost estimation and optimization
#    - Resource lifecycle management
# =============================================================================
