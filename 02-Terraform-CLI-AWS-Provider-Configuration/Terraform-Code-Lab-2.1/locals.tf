# AWS Terraform Training - Topic 2: Terraform CLI & AWS Provider Configuration
# Terraform Code Lab 2.1 - Local Values and Computed Configurations
#
# This file demonstrates the use of local values for computed configurations,
# data transformations, and complex expressions in Terraform.
#
# Learning Objectives:
# 1. Local value definition and usage patterns
# 2. Complex data transformations and computations
# 3. Conditional logic and dynamic configurations
# 4. Resource naming and tagging strategies
# 5. Environment-specific configuration management

# =============================================================================
# CORE LOCAL VALUES
# =============================================================================

locals {
  # Timestamp for resource tracking and audit trails
  timestamp = timestamp()
  date_stamp = formatdate("YYYY-MM-DD", local.timestamp)
  datetime_stamp = formatdate("YYYY-MM-DD-hhmm", local.timestamp)
  
  # Resource naming conventions
  name_prefix = "${var.environment}-${var.project_name}"
  resource_suffix = random_id.bucket_suffix.hex
  
  # Environment-specific configuration
  env_config = var.environment_config[var.environment]
  is_production = contains(["prod", "production"], var.environment)
  is_development = contains(["dev", "development"], var.environment)
  
  # Regional configuration
  region_short = {
    "us-east-1"      = "use1"
    "us-east-2"      = "use2"
    "us-west-1"      = "usw1"
    "us-west-2"      = "usw2"
    "eu-west-1"      = "euw1"
    "eu-central-1"   = "euc1"
    "ap-southeast-1" = "apse1"
    "ap-northeast-1" = "apne1"
  }
  region_code = lookup(local.region_short, var.aws_region, "unknown")
}

# =============================================================================
# TAGGING STRATEGY
# =============================================================================

locals {
  # Base tags applied to all resources
  base_tags = {
    Environment        = var.environment
    Project           = var.project_name
    ManagedBy         = "terraform"
    Owner             = var.owner
    CostCenter        = var.cost_center
    CreatedDate       = local.date_stamp
    LastModified      = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", local.timestamp)
    TrainingTopic     = "terraform-cli-aws-provider-configuration"
    TerraformVersion  = var.terraform_version
    AWSProviderVersion = var.aws_provider_version
  }
  
  # Security and compliance tags
  security_tags = {
    DataClassification = var.data_classification
    EncryptionAtRest   = var.encryption_at_rest ? "enabled" : "disabled"
    EncryptionInTransit = var.encryption_in_transit ? "enabled" : "disabled"
    BackupRequired     = var.enable_backup ? "true" : "false"
    MonitoringEnabled  = var.enable_detailed_monitoring ? "true" : "false"
    ComplianceScope    = join(",", var.compliance_requirements)
  }
  
  # Operational tags
  operational_tags = {
    AutoShutdown      = local.is_development ? "enabled" : "disabled"
    BackupRetention   = "${var.backup_retention_days}days"
    MaintenanceWindow = local.is_production ? "sunday-02:00-04:00" : "daily-01:00-02:00"
    SupportLevel      = local.is_production ? "24x7" : "business-hours"
    DisasterRecovery  = local.is_production ? "required" : "optional"
  }
  
  # Combined common tags
  common_tags = merge(
    local.base_tags,
    local.security_tags,
    local.operational_tags,
    var.cost_allocation_tags
  )
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

locals {
  # Security configuration based on environment and requirements
  security_config = {
    # Encryption settings
    encryption_at_rest    = var.encryption_at_rest
    encryption_in_transit = var.encryption_in_transit
    kms_key_rotation     = local.is_production
    
    # Access control settings
    public_access_blocked = true
    versioning_enabled   = true
    mfa_required        = local.is_production
    
    # Monitoring and logging
    access_logging      = var.feature_flags.enable_logging
    cloudtrail_enabled  = local.is_production
    config_enabled      = local.is_production
    guardduty_enabled   = local.is_production
    
    # Network security
    vpc_endpoints_enabled = var.enable_vpc_endpoints
    private_subnets_only = local.is_production
    
    # Compliance settings
    compliance_monitoring = length(var.compliance_requirements) > 0
    audit_logging        = local.is_production
    data_retention_days  = local.is_production ? 2555 : var.backup_retention_days # 7 years for prod
  }
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

locals {
  # Availability zone configuration
  available_azs = data.aws_availability_zones.available.names
  selected_azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(local.available_azs, 0, min(3, length(local.available_azs)))
  
  # Network CIDR calculations
  vpc_cidr = "10.${local.is_production ? 0 : 10}.0.0/16"
  
  # Subnet configurations
  subnet_config = {
    public_subnets = [
      for i, az in local.selected_azs : {
        cidr = cidrsubnet(local.vpc_cidr, 8, i)
        az   = az
        name = "${local.name_prefix}-public-${substr(az, -1, 1)}"
      }
    ]
    private_subnets = [
      for i, az in local.selected_azs : {
        cidr = cidrsubnet(local.vpc_cidr, 8, i + 10)
        az   = az
        name = "${local.name_prefix}-private-${substr(az, -1, 1)}"
      }
    ]
    database_subnets = [
      for i, az in local.selected_azs : {
        cidr = cidrsubnet(local.vpc_cidr, 8, i + 20)
        az   = az
        name = "${local.name_prefix}-database-${substr(az, -1, 1)}"
      }
    ]
  }
}

# =============================================================================
# RESOURCE NAMING CONVENTIONS
# =============================================================================

locals {
  # Naming patterns for different resource types
  naming = {
    # Storage resources
    s3_bucket_state = "${local.name_prefix}-terraform-state-${local.resource_suffix}"
    s3_bucket_logs  = "${local.name_prefix}-logs-${local.resource_suffix}"
    s3_bucket_artifacts = "${local.name_prefix}-artifacts-${local.resource_suffix}"
    
    # Database resources
    dynamodb_state_lock = "${local.name_prefix}-terraform-state-lock"
    
    # Security resources
    iam_role_terraform = "${local.name_prefix}-terraform-execution-role"
    iam_policy_terraform = "${local.name_prefix}-terraform-execution-policy"
    kms_key_terraform = "${local.name_prefix}-terraform-key"
    kms_alias_terraform = "alias/${local.name_prefix}-terraform-key"
    
    # Monitoring resources
    log_group_terraform = "/aws/terraform/${local.name_prefix}"
    cloudwatch_dashboard = "${local.name_prefix}-terraform-dashboard"
    
    # Budget and cost management
    budget_terraform = "${local.name_prefix}-terraform-budget"
    
    # Network resources
    vpc_main = "${local.name_prefix}-vpc"
    igw_main = "${local.name_prefix}-igw"
    nat_gateway = "${local.name_prefix}-nat"
    
    # Security groups
    sg_default = "${local.name_prefix}-default-sg"
    sg_web = "${local.name_prefix}-web-sg"
    sg_app = "${local.name_prefix}-app-sg"
    sg_database = "${local.name_prefix}-database-sg"
  }
}

# =============================================================================
# FEATURE FLAG PROCESSING
# =============================================================================

locals {
  # Process feature flags and determine enabled features
  enabled_features = {
    logging           = var.feature_flags.enable_logging
    metrics          = var.feature_flags.enable_metrics
    tracing          = var.feature_flags.enable_tracing
    auto_scaling     = var.feature_flags.enable_auto_scaling
    load_balancing   = var.feature_flags.enable_load_balancing
    ssl_termination  = var.feature_flags.enable_ssl_termination
  }
  
  # Count enabled features for reporting
  feature_count = length([for k, v in local.enabled_features : k if v])
  
  # Feature-specific configurations
  monitoring_config = {
    cloudwatch_enabled = local.enabled_features.logging || local.enabled_features.metrics
    xray_enabled      = local.enabled_features.tracing
    detailed_monitoring = var.enable_detailed_monitoring
    log_retention     = var.backup_retention_days
  }
}

# =============================================================================
# COST OPTIMIZATION CONFIGURATION
# =============================================================================

locals {
  # Cost optimization settings based on environment
  cost_optimization = {
    # Instance sizing
    instance_type = local.env_config.instance_type
    min_capacity  = local.env_config.min_capacity
    max_capacity  = local.env_config.max_capacity
    
    # Storage optimization
    storage_class = local.is_production ? "STANDARD" : "STANDARD_IA"
    lifecycle_enabled = true
    
    # Backup optimization
    backup_enabled = var.enable_backup
    backup_retention = local.env_config.backup_retention
    
    # Monitoring optimization
    detailed_monitoring = local.env_config.enable_monitoring
    
    # Scheduling (for development environments)
    auto_shutdown = local.is_development
    shutdown_schedule = local.is_development ? "cron(0 18 * * MON-FRI)" : null
    startup_schedule = local.is_development ? "cron(0 8 * * MON-FRI)" : null
  }
  
  # Budget configuration
  budget_config = {
    limit_amount = var.budget_limit
    threshold_warning = 80
    threshold_critical = 100
    notification_emails = ["${var.owner}@example.com"]
  }
}

# =============================================================================
# PROVIDER CONFIGURATION HELPERS
# =============================================================================

locals {
  # Provider configuration validation
  provider_validation = {
    terraform_version_valid = can(regex("^~> [0-9]+\\.[0-9]+\\.[0-9]+$", var.terraform_version))
    aws_provider_version_valid = can(regex("^~> [0-9]+\\.[0-9]+\\.[0-9]+$", var.aws_provider_version))
    region_valid = contains(keys(local.region_short), var.aws_region)
    environment_valid = contains(["dev", "development", "staging", "stage", "prod", "production"], var.environment)
  }
  
  # Authentication method detection
  auth_method = {
    profile_based = var.aws_profile != null && var.aws_profile != ""
    role_based = var.assume_role_arn != null
    oidc_based = var.web_identity_token_file != null
    environment_based = var.aws_profile == null && var.assume_role_arn == null
  }
  
  # Multi-account configuration
  multi_account = {
    enabled = var.staging_account_id != null || var.production_account_id != null
    staging_configured = var.staging_account_id != null
    production_configured = var.production_account_id != null
    cross_account_roles = var.assume_role_arn != null
  }
}

# =============================================================================
# VALIDATION AND ERROR CHECKING
# =============================================================================

locals {
  # Configuration validation
  validation_errors = [
    for error in [
      !local.provider_validation.terraform_version_valid ? "Invalid Terraform version format" : "",
      !local.provider_validation.aws_provider_version_valid ? "Invalid AWS provider version format" : "",
      !local.provider_validation.region_valid ? "Invalid AWS region" : "",
      !local.provider_validation.environment_valid ? "Invalid environment value" : "",
      var.budget_limit <= 0 ? "Budget limit must be greater than 0" : "",
      length(var.owner) == 0 ? "Owner cannot be empty" : ""
    ] : error if error != ""
  ]
  
  # Warning conditions
  warnings = [
    for warning in [
      local.is_production && !var.encryption_at_rest ? "Production environment should have encryption at rest enabled" : "",
      local.is_production && !var.enable_backup ? "Production environment should have backup enabled" : "",
      local.is_production && var.backup_retention_days < 30 ? "Production environment should have longer backup retention" : "",
      !local.enabled_features.logging ? "Logging is disabled - consider enabling for audit trails" : "",
      var.budget_limit > 1000 ? "Budget limit is quite high - ensure this is intentional" : ""
    ] : warning if warning != ""
  ]
  
  # Configuration summary
  config_summary = {
    environment = var.environment
    region = var.aws_region
    encryption_enabled = var.encryption_at_rest
    backup_enabled = var.enable_backup
    monitoring_enabled = var.enable_detailed_monitoring
    features_enabled = local.feature_count
    validation_errors = length(local.validation_errors)
    warnings = length(local.warnings)
    multi_account_enabled = local.multi_account.enabled
    compliance_requirements = length(var.compliance_requirements)
  }
}
