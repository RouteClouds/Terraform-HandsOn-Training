# AWS Terraform Training - Topic 3: Core Terraform Operations
# Terraform Code Lab 3.1 - Local Values and Computed Configurations
#
# This file demonstrates advanced local value patterns for core Terraform
# operations, including complex data transformations, conditional logic,
# resource organization, and enterprise configuration management.
#
# Learning Objectives:
# 1. Complex local value computations and transformations
# 2. Conditional logic and dynamic configuration
# 3. Resource naming and organization patterns
# 4. Environment-specific configuration management
# 5. Data processing and validation patterns

# =============================================================================
# CORE CONFIGURATION LOCALS
# =============================================================================

locals {
  # Timestamp and deployment tracking
  timestamp = timestamp()
  date_stamp = formatdate("YYYY-MM-DD", local.timestamp)
  datetime_stamp = formatdate("YYYY-MM-DD-hhmm", local.timestamp)
  
  # Environment and project configuration
  environment = var.environment
  project = var.project_name
  region = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
  
  # Resource naming conventions
  name_prefix = "${local.environment}-${local.project}"
  resource_suffix = random_id.deployment.hex
  
  # Environment classification
  is_production = contains(["prod", "production"], local.environment)
  is_development = contains(["dev", "development"], local.environment)
  is_staging = contains(["staging", "stage"], local.environment)
  
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
  region_code = lookup(local.region_short, local.region, "unknown")
}

# =============================================================================
# NETWORK CONFIGURATION LOCALS
# =============================================================================

locals {
  # Availability zone processing
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 3)
  az_count = length(local.availability_zones)
  
  # VPC and subnet CIDR calculations
  vpc_cidr = var.vpc_cidr
  
  # Calculate subnet CIDRs dynamically
  public_subnet_cidrs = [
    for i in range(local.az_count) :
    cidrsubnet(local.vpc_cidr, 8, i)
  ]
  
  private_subnet_cidrs = [
    for i in range(local.az_count) :
    cidrsubnet(local.vpc_cidr, 8, i + 10)
  ]
  
  database_subnet_cidrs = [
    for i in range(local.az_count) :
    cidrsubnet(local.vpc_cidr, 8, i + 20)
  ]
  
  # Network configuration summary
  network_config = {
    vpc_cidr = local.vpc_cidr
    az_count = local.az_count
    availability_zones = local.availability_zones
    public_subnets = local.public_subnet_cidrs
    private_subnets = local.private_subnet_cidrs
    database_subnets = local.database_subnet_cidrs
    nat_gateway_enabled = var.enable_nat_gateway
    flow_logs_enabled = var.enable_flow_logs
  }
}

# =============================================================================
# RESOURCE NAMING CONVENTIONS
# =============================================================================

locals {
  # Standardized naming patterns
  naming = {
    # Network resources
    vpc = "${local.name_prefix}-vpc"
    internet_gateway = "${local.name_prefix}-igw"
    nat_gateway = "${local.name_prefix}-nat"
    public_subnet = "${local.name_prefix}-public-subnet"
    private_subnet = "${local.name_prefix}-private-subnet"
    database_subnet = "${local.name_prefix}-database-subnet"
    public_route_table = "${local.name_prefix}-public-rt"
    private_route_table = "${local.name_prefix}-private-rt"
    
    # Security resources
    security_group = "${local.name_prefix}-sg"
    iam_role = "${local.name_prefix}-role"
    iam_policy = "${local.name_prefix}-policy"
    
    # Compute resources
    ec2_instance = "${local.name_prefix}-instance"
    launch_template = "${local.name_prefix}-lt"
    auto_scaling_group = "${local.name_prefix}-asg"
    
    # Load balancer resources
    application_load_balancer = "${local.name_prefix}-alb"
    target_group = "${local.name_prefix}-tg"
    listener = "${local.name_prefix}-listener"
    
    # Database resources
    db_instance = "${local.name_prefix}-db"
    db_subnet_group = "${local.name_prefix}-db-subnet-group"
    db_parameter_group = "${local.name_prefix}-db-params"
    
    # Storage resources
    s3_bucket = "${local.name_prefix}-bucket"
    ebs_volume = "${local.name_prefix}-volume"
    
    # Monitoring resources
    cloudwatch_log_group = "${local.name_prefix}-logs"
    cloudwatch_alarm = "${local.name_prefix}-alarm"
    sns_topic = "${local.name_prefix}-alerts"
  }
  
  # Resource tags with naming integration
  resource_tags = {
    vpc = merge(local.common_tags, { Name = local.naming.vpc, Type = "network" })
    subnet = merge(local.common_tags, { Type = "network" })
    security_group = merge(local.common_tags, { Type = "security" })
    instance = merge(local.common_tags, { Type = "compute" })
    database = merge(local.common_tags, { Type = "database", Critical = "true" })
    load_balancer = merge(local.common_tags, { Type = "load-balancer" })
    monitoring = merge(local.common_tags, { Type = "monitoring" })
  }
}

# =============================================================================
# TAGGING STRATEGY
# =============================================================================

locals {
  # Base tags applied to all resources
  base_tags = {
    Environment = local.environment
    Project = local.project
    ManagedBy = "terraform"
    Owner = var.owner
    CostCenter = var.cost_center
    CreatedDate = local.date_stamp
    LastModified = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", local.timestamp)
    TerraformTopic = "core-terraform-operations"
    LabVersion = "3.1"
    Region = local.region
    RegionCode = local.region_code
  }
  
  # Security and compliance tags
  security_tags = {
    DataClassification = var.data_classification
    BackupRequired = var.backup_required ? "true" : "false"
    MonitoringEnabled = var.monitoring_enabled ? "true" : "false"
    EncryptionRequired = "true"
    ComplianceScope = local.is_production ? "high" : "standard"
  }
  
  # Operational tags
  operational_tags = {
    AutoShutdown = local.is_development ? "enabled" : "disabled"
    MaintenanceWindow = local.is_production ? "sunday-02:00-04:00" : "daily-01:00-02:00"
    SupportLevel = local.is_production ? "24x7" : "business-hours"
    DisasterRecovery = local.is_production ? "required" : "optional"
    Criticality = local.is_production ? "high" : "medium"
  }
  
  # Deployment metadata tags
  deployment_tags = {
    DeployedBy = data.external.environment_info.result.user
    DeployedFrom = data.external.environment_info.result.hostname
    DeploymentTimestamp = data.external.environment_info.result.timestamp
    GitBranch = data.external.git_info.result.branch
    GitCommit = data.external.git_info.result.commit
    PublicIP = chomp(data.http.public_ip.response_body)
    Platform = data.external.system_info.result.operating_system
  }
  
  # Combined common tags
  common_tags = merge(
    local.base_tags,
    local.security_tags,
    local.operational_tags,
    local.deployment_tags,
    var.cost_allocation_tags
  )
}

# =============================================================================
# INSTANCE CONFIGURATION
# =============================================================================

locals {
  # Instance type selection based on environment
  instance_types = {
    web = var.instance_types[local.environment].web
    app = var.instance_types[local.environment].app
    database = var.instance_types[local.environment].database
  }
  
  # Instance configuration by tier
  instance_config = {
    web = {
      count = var.instance_count.web
      type = local.instance_types.web
      subnet_type = "public"
      security_groups = ["web"]
      monitoring = var.monitoring_enabled
      user_data_script = var.user_data_scripts.web_server
    }
    app = {
      count = var.instance_count.app
      type = local.instance_types.app
      subnet_type = "private"
      security_groups = ["app"]
      monitoring = var.monitoring_enabled
      user_data_script = var.user_data_scripts.app_server
    }
  }
  
  # Auto Scaling configuration
  auto_scaling_config = {
    web = {
      min_size = local.is_production ? 2 : 1
      max_size = local.is_production ? 10 : 3
      desired_capacity = var.instance_count.web
    }
    app = {
      min_size = local.is_production ? 2 : 1
      max_size = local.is_production ? 8 : 3
      desired_capacity = var.instance_count.app
    }
  }
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

locals {
  # Security configuration based on environment
  security_config = {
    # Encryption settings
    encryption_at_rest = true
    encryption_in_transit = true
    kms_key_rotation = local.is_production
    
    # Access control
    public_access_blocked = true
    versioning_enabled = true
    mfa_required = local.is_production
    
    # Network security
    vpc_flow_logs = var.enable_flow_logs
    security_group_strict = local.is_production
    
    # Monitoring and logging
    cloudwatch_logs = var.feature_flags.enable_cloudwatch_logs
    detailed_monitoring = var.monitoring_enabled
    
    # Backup and recovery
    automated_backups = var.backup_required
    backup_retention = local.is_production ? 30 : 7
    point_in_time_recovery = local.is_production
  }
  
  # Security group rule processing
  security_group_rules = {
    for sg in var.security_groups : sg.name => {
      name = sg.name
      description = sg.description
      ingress_rules = [
        for rule in sg.ingress_rules : {
          from_port = rule.from_port
          to_port = rule.to_port
          protocol = rule.protocol
          cidr_blocks = rule.cidr_blocks
          description = rule.description
        }
      ]
      egress_rules = length(sg.egress_rules) > 0 ? [
        for rule in sg.egress_rules : {
          from_port = rule.from_port
          to_port = rule.to_port
          protocol = rule.protocol
          cidr_blocks = rule.cidr_blocks
          description = rule.description
        }
      ] : [
        {
          from_port = 0
          to_port = 0
          protocol = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    }
  }
}

# =============================================================================
# COST OPTIMIZATION CONFIGURATION
# =============================================================================

locals {
  # Cost optimization settings
  cost_optimization = {
    # Instance right-sizing
    instance_types = local.instance_types
    spot_instances = local.is_development
    
    # Storage optimization
    storage_class = local.is_production ? "STANDARD" : "STANDARD_IA"
    lifecycle_policies = true
    
    # Network optimization
    nat_gateway_count = var.enable_nat_gateway ? local.az_count : 0
    
    # Monitoring optimization
    detailed_monitoring = local.is_production ? true : var.monitoring_enabled
    log_retention = local.is_production ? 30 : 7
    
    # Backup optimization
    backup_frequency = local.is_production ? "daily" : "weekly"
    backup_retention = local.security_config.backup_retention
  }
  
  # Budget configuration
  budget_config = {
    limit_amount = var.budget_config.limit_amount
    time_unit = var.budget_config.time_unit
    budget_type = var.budget_config.budget_type
    threshold_percentage = var.budget_config.threshold_percentage
    notification_emails = ["${var.owner}@example.com"]
  }
}

# =============================================================================
# FEATURE FLAG PROCESSING
# =============================================================================

locals {
  # Process feature flags
  enabled_features = {
    auto_scaling = var.feature_flags.enable_auto_scaling
    cloudwatch_logs = var.feature_flags.enable_cloudwatch_logs
    ssl_termination = var.feature_flags.enable_ssl_termination
    waf = var.feature_flags.enable_waf
    backup_automation = var.feature_flags.enable_backup_automation
    cost_optimization = var.feature_flags.enable_cost_optimization
  }
  
  # Feature-specific configuration
  feature_config = {
    auto_scaling = local.enabled_features.auto_scaling ? local.auto_scaling_config : {}
    monitoring = local.enabled_features.cloudwatch_logs ? {
      log_groups = ["application", "system", "security"]
      retention_days = local.cost_optimization.log_retention
    } : {}
    backup = local.enabled_features.backup_automation ? {
      frequency = local.cost_optimization.backup_frequency
      retention = local.cost_optimization.backup_retention
    } : {}
  }
}

# =============================================================================
# VALIDATION AND ERROR CHECKING
# =============================================================================

locals {
  # Configuration validation
  validation_checks = {
    vpc_cidr_valid = can(cidrhost(var.vpc_cidr, 0))
    az_count_sufficient = local.az_count >= 2
    instance_counts_valid = var.instance_count.web >= 1 && var.instance_count.app >= 1
    environment_valid = contains(["dev", "development", "staging", "stage", "prod", "production"], var.environment)
    region_supported = contains(keys(local.region_short), local.region)
  }
  
  # Warning conditions
  warnings = [
    for warning in [
      local.is_production && !var.backup_required ? "Production environment should have backup enabled" : "",
      local.is_production && !var.monitoring_enabled ? "Production environment should have monitoring enabled" : "",
      local.az_count < 3 ? "Consider using at least 3 availability zones for high availability" : "",
      !var.enable_nat_gateway ? "Private subnets will not have internet access without NAT Gateway" : "",
      var.budget_config.limit_amount > 500 ? "Budget limit is quite high - ensure this is intentional" : ""
    ] : warning if warning != ""
  ]
  
  # Configuration summary
  config_summary = {
    environment = local.environment
    region = local.region
    az_count = local.az_count
    vpc_cidr = local.vpc_cidr
    instance_counts = var.instance_count
    features_enabled = length([for k, v in local.enabled_features : k if v])
    security_level = local.is_production ? "high" : "standard"
    cost_optimization_enabled = local.enabled_features.cost_optimization
    validation_passed = alltrue(values(local.validation_checks))
    warning_count = length(local.warnings)
  }
}
