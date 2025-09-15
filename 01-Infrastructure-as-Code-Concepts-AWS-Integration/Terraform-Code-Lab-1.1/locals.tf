# ============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# Topic 1: Infrastructure as Code Concepts & AWS Integration
# ============================================================================

locals {
  # ============================================================================
  # RESOURCE NAMING AND IDENTIFICATION
  # ============================================================================
  
  # Generate consistent resource prefix for all resources
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources for governance and cost tracking
  common_tags = {
    Project              = var.project_name
    Environment          = var.environment
    ManagedBy            = "terraform"
    CreatedBy            = var.created_by
    CostCenter           = var.cost_center
    Owner                = var.owner_email
    BusinessUnit         = var.business_unit
    StudentGroup         = var.student_group
    TrainingModule       = "Topic-1-Infrastructure-as-Code-Concepts"
    CreatedDate          = formatdate("YYYY-MM-DD", timestamp())
    LastModified         = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
    TerraformVersion     = "~> 1.13.0"
    ProviderVersion      = "~> 6.12.0"
    Region               = var.aws_region
  }

  # Security-specific tags for compliance and governance
  security_tags = {
    DataClassification   = var.data_classification
    BackupRequired       = var.backup_required ? "true" : "false"
    MonitoringLevel      = var.monitoring_level
    ComplianceScope      = var.compliance_scope
    EncryptionRequired   = "true"
    AccessControlLevel   = "strict"
    AuditingEnabled      = "true"
    SecurityReview       = "completed"
  }

  # Cost optimization tags for financial management
  cost_tags = {
    CostOptimization     = var.enable_cost_optimization ? "enabled" : "disabled"
    AutoShutdown         = var.enable_auto_shutdown ? "enabled" : "disabled"
    BudgetAlert          = var.budget_alert_threshold > 0 ? "enabled" : "disabled"
    ResourceOptimization = "enabled"
    CostAllocation       = var.cost_center
  }

  # Operational tags for management and automation
  operational_tags = {
    AutoScaling          = var.enable_auto_scaling ? "enabled" : "disabled"
    LoadBalancing        = var.enable_load_balancer ? "enabled" : "disabled"
    HighAvailability     = var.enable_multi_az ? "enabled" : "disabled"
    DisasterRecovery     = var.enable_backup ? "enabled" : "disabled"
    MaintenanceWindow    = var.maintenance_window
    SupportLevel         = var.support_level
  }

  # ============================================================================
  # NETWORK CONFIGURATION
  # ============================================================================
  
  # VPC CIDR calculation and subnet distribution
  vpc_cidr = var.vpc_cidr
  
  # Calculate subnet CIDRs dynamically based on availability zones
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)
  
  # Public subnet CIDRs (for load balancers and NAT gateways)
  public_subnet_cidrs = [
    for i, az in local.availability_zones :
    cidrsubnet(local.vpc_cidr, 8, i + 1)
  ]
  
  # Private subnet CIDRs (for application servers)
  private_subnet_cidrs = [
    for i, az in local.availability_zones :
    cidrsubnet(local.vpc_cidr, 8, i + 10)
  ]
  
  # Database subnet CIDRs (for RDS instances)
  database_subnet_cidrs = [
    for i, az in local.availability_zones :
    cidrsubnet(local.vpc_cidr, 8, i + 20)
  ]

  # ============================================================================
  # SECURITY CONFIGURATION
  # ============================================================================
  
  # Security group rules for web tier
  web_ingress_rules = [
    {
      description = "HTTP from Load Balancer"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    },
    {
      description = "HTTPS from Load Balancer"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    },
    {
      description = "SSH from Bastion (if enabled)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.enable_ssh_access ? [local.vpc_cidr] : []
    }
  ]
  
  # Security group rules for database tier
  database_ingress_rules = [
    {
      description = "MySQL from Application Tier"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = local.private_subnet_cidrs
    }
  ]
  
  # Load balancer ingress rules
  alb_ingress_rules = [
    {
      description = "HTTP from Internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS from Internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # ============================================================================
  # COMPUTE CONFIGURATION
  # ============================================================================
  
  # Auto Scaling Group configuration based on environment
  asg_config = {
    development = {
      min_size         = 1
      max_size         = 2
      desired_capacity = 1
      instance_type    = "t3.micro"
    }
    staging = {
      min_size         = 1
      max_size         = 4
      desired_capacity = 2
      instance_type    = "t3.small"
    }
    production = {
      min_size         = 2
      max_size         = 10
      desired_capacity = 3
      instance_type    = "t3.medium"
    }
    lab = {
      min_size         = 1
      max_size         = 2
      desired_capacity = 1
      instance_type    = "t3.micro"
    }
  }
  
  # Current environment configuration
  current_asg_config = local.asg_config[var.environment]

  # ============================================================================
  # DATABASE CONFIGURATION
  # ============================================================================
  
  # RDS configuration based on environment
  rds_config = {
    development = {
      instance_class    = "db.t3.micro"
      allocated_storage = 20
      multi_az         = false
      backup_retention = 1
    }
    staging = {
      instance_class    = "db.t3.small"
      allocated_storage = 50
      multi_az         = true
      backup_retention = 7
    }
    production = {
      instance_class    = "db.t3.medium"
      allocated_storage = 100
      multi_az         = true
      backup_retention = 30
    }
    lab = {
      instance_class    = "db.t3.micro"
      allocated_storage = 20
      multi_az         = false
      backup_retention = 1
    }
  }
  
  # Current RDS configuration
  current_rds_config = local.rds_config[var.environment]

  # ============================================================================
  # MONITORING AND LOGGING CONFIGURATION
  # ============================================================================
  
  # CloudWatch log groups configuration
  log_groups = {
    application = "/aws/ec2/${local.name_prefix}/application"
    system      = "/aws/ec2/${local.name_prefix}/system"
    security    = "/aws/ec2/${local.name_prefix}/security"
    access      = "/aws/ec2/${local.name_prefix}/access"
  }
  
  # CloudWatch alarms configuration
  cloudwatch_alarms = var.enable_monitoring ? [
    {
      name               = "${local.name_prefix}-high-cpu"
      metric_name        = "CPUUtilization"
      threshold          = 80
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
    },
    {
      name               = "${local.name_prefix}-high-memory"
      metric_name        = "MemoryUtilization"
      threshold          = 85
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
    },
    {
      name               = "${local.name_prefix}-low-disk-space"
      metric_name        = "DiskSpaceUtilization"
      threshold          = 90
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 1
    }
  ] : []

  # ============================================================================
  # COST OPTIMIZATION CONFIGURATION
  # ============================================================================
  
  # Cost optimization settings based on environment
  cost_optimization = {
    enable_spot_instances = var.environment != "production" ? var.enable_spot_instances : false
    enable_scheduled_scaling = var.enable_auto_shutdown
    enable_rightsizing = var.enable_cost_optimization
    enable_reserved_instances = var.environment == "production"
  }
  
  # Estimated monthly costs (USD)
  estimated_costs = {
    ec2_instances = {
      count = local.current_asg_config.desired_capacity
      type  = local.current_asg_config.instance_type
      cost  = local.current_asg_config.desired_capacity * (
        local.current_asg_config.instance_type == "t3.micro" ? 8.50 :
        local.current_asg_config.instance_type == "t3.small" ? 17.00 :
        local.current_asg_config.instance_type == "t3.medium" ? 34.00 : 50.00
      )
    }
    load_balancer = {
      type = "Application Load Balancer"
      cost = 16.20
    }
    nat_gateways = {
      count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.availability_zones)) : 0
      cost  = var.enable_nat_gateway ? (var.single_nat_gateway ? 32.40 : length(local.availability_zones) * 32.40) : 0
    }
    rds_database = {
      type = local.current_rds_config.instance_class
      cost = local.current_rds_config.instance_class == "db.t3.micro" ? 12.50 :
             local.current_rds_config.instance_class == "db.t3.small" ? 25.00 :
             local.current_rds_config.instance_class == "db.t3.medium" ? 50.00 : 75.00
    }
    s3_storage = {
      type = "Standard storage and requests"
      cost = 5.00
    }
    cloudwatch = {
      type = "Logs and metrics"
      cost = var.enable_monitoring ? 10.00 : 2.00
    }
  }
  
  # Total estimated monthly cost
  total_estimated_cost = (
    local.estimated_costs.ec2_instances.cost +
    local.estimated_costs.load_balancer.cost +
    local.estimated_costs.nat_gateways.cost +
    local.estimated_costs.rds_database.cost +
    local.estimated_costs.s3_storage.cost +
    local.estimated_costs.cloudwatch.cost
  )

  # ============================================================================
  # BUSINESS VALUE CALCULATIONS
  # ============================================================================
  
  # Infrastructure as Code business value metrics
  iac_business_value = {
    deployment_time_reduction = "85%"  # From hours to minutes
    configuration_consistency = "99%"  # Elimination of configuration drift
    operational_cost_reduction = "40%" # Through automation and optimization
    security_incident_reduction = "75%" # Through standardized security
    team_productivity_increase = "60%" # Through automation and self-service
    infrastructure_reliability = "99.9%" # Through tested, repeatable deployments
  }
  
  # ROI calculations (annual basis)
  roi_calculations = {
    traditional_infrastructure_cost = 120000  # Annual cost of manual management
    iac_infrastructure_cost = 72000          # Annual cost with IaC automation
    annual_savings = 48000                   # Direct cost savings
    productivity_gains = 80000               # Value from increased productivity
    total_annual_value = 128000              # Total annual value creation
    implementation_cost = 25000              # One-time implementation cost
    roi_percentage = 412                     # ROI percentage (first year)
  }

  # ============================================================================
  # VALIDATION AND COMPLIANCE
  # ============================================================================
  
  # Compliance validation checks
  compliance_checks = {
    encryption_at_rest = true
    encryption_in_transit = true
    access_logging = var.enable_monitoring
    backup_enabled = var.enable_backup
    multi_az_deployment = var.enable_multi_az
    security_groups_restrictive = true
    iam_least_privilege = true
    resource_tagging_complete = true
  }
  
  # Security best practices validation
  security_validation = {
    no_public_database_access = true
    private_subnets_for_apps = true
    load_balancer_in_public_subnets = true
    security_groups_principle_least_privilege = true
    encryption_keys_managed = true
    audit_logging_enabled = var.enable_monitoring
    backup_strategy_implemented = var.enable_backup
  }

  # ============================================================================
  # INTEGRATION POINTS
  # ============================================================================
  
  # Integration endpoints and connection strings
  integration_config = {
    vpc_id = "aws_vpc.main.id"
    private_subnet_ids = "aws_subnet.private[*].id"
    public_subnet_ids = "aws_subnet.public[*].id"
    database_subnet_group = "aws_db_subnet_group.main.name"
    security_group_web = "aws_security_group.web.id"
    security_group_database = "aws_security_group.database.id"
    load_balancer_dns = "aws_lb.main.dns_name"
    s3_bucket_name = "aws_s3_bucket.app_bucket.bucket"
  }
  
  # Cross-topic learning integration
  learning_integration = {
    next_topics = [
      "Topic-2-Terraform-CLI-AWS-Provider-Configuration",
      "Topic-3-Core-Terraform-Operations",
      "Topic-6-State-Management-with-AWS"
    ]
    prerequisite_knowledge = [
      "Basic AWS services understanding",
      "Command line interface familiarity",
      "Infrastructure concepts"
    ]
    learning_outcomes = [
      "IaC principles mastery",
      "AWS integration patterns",
      "Security best practices",
      "Cost optimization strategies"
    ]
  }
}
