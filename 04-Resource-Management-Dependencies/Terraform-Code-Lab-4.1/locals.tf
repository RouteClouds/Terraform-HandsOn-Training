# AWS Terraform Training - Topic 4: Resource Management & Dependencies
# Terraform Code Lab 4.1 - Local Values and Computed Configurations
#
# This file defines comprehensive local values for dependency management,
# resource organization, and computed configurations that support complex
# infrastructure patterns and enterprise-scale deployments.

locals {
  # Environment and Project Configuration
  environment = var.environment
  project     = var.project_name
  region      = data.aws_region.current.name
  account_id  = data.aws_caller_identity.current.account_id
  
  # Availability zones (use first 3 available)
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  az_count          = length(local.availability_zones)
  
  # Resource naming conventions
  name_prefix = "${local.environment}-${local.project}"
  
  # Network configuration with calculated CIDRs
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
  
  # Security group configurations with dependency-aware rules
  security_groups = {
    web = {
      name        = "web"
      description = "Security group for web servers"
      ingress_rules = [
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
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    }
    api = {
      name        = "api"
      description = "Security group for API servers"
      ingress_rules = [
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "API port from VPC"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    }
    worker = {
      name        = "worker"
      description = "Security group for worker servers"
      ingress_rules = [
        {
          from_port   = 9090
          to_port     = 9090
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "Worker port from VPC"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    }
    database = {
      name        = "database"
      description = "Security group for database servers"
      ingress_rules = [
        {
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "MySQL from VPC"
        }
      ]
      egress_rules = []
    }
    queue = {
      name        = "queue"
      description = "Security group for queue services"
      ingress_rules = [
        {
          from_port   = 5672
          to_port     = 5672
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "RabbitMQ from VPC"
        },
        {
          from_port   = 6379
          to_port     = 6379
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "Redis from VPC"
        }
      ]
      egress_rules = []
    }
    common = {
      name        = "common"
      description = "Common security group for all servers"
      ingress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "SSH from VPC"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    }
  }
  
  # Dependency analysis and ordering
  dependency_order = [
    "network",     # VPC, subnets, gateways (foundation)
    "security",    # Security groups and rules
    "storage",     # S3 buckets, EBS volumes
    "encryption",  # KMS keys and aliases
    "database",    # RDS, ElastiCache, DynamoDB
    "queue",       # SQS, SNS, EventBridge
    "compute",     # EC2, Lambda, ECS
    "application", # ALB, ASG, Target Groups
    "monitoring",  # CloudWatch, X-Ray
    "backup"       # AWS Backup, snapshots
  ]
  
  # Environment-specific configuration
  environment_config = {
    dev = {
      instance_types = {
        web    = "t3.micro"
        api    = "t3.small"
        worker = "t3.medium"
      }
      database_instance_class = "db.t3.micro"
      enable_multi_az        = false
      backup_retention       = 7
      monitoring_enabled     = false
      deletion_protection    = false
    }
    staging = {
      instance_types = {
        web    = "t3.small"
        api    = "t3.medium"
        worker = "t3.large"
      }
      database_instance_class = "db.t3.small"
      enable_multi_az        = false
      backup_retention       = 14
      monitoring_enabled     = true
      deletion_protection    = false
    }
    prod = {
      instance_types = {
        web    = "t3.medium"
        api    = "t3.large"
        worker = "t3.xlarge"
      }
      database_instance_class = "db.t3.medium"
      enable_multi_az        = true
      backup_retention       = 30
      monitoring_enabled     = true
      deletion_protection    = true
    }
  }
  
  # Current environment configuration
  current_config = local.environment_config[local.environment]
  
  # Application configuration with dependency resolution
  resolved_applications = {
    for app_name, app_config in var.applications :
    app_name => merge(app_config, {
      # Override instance type based on environment
      instance_type = lookup(local.current_config.instance_types, app_name, app_config.instance_type)
      
      # Resolve security group IDs (will be populated after creation)
      resolved_security_groups = app_config.security_groups
      
      # Resolve subnet IDs based on subnet type
      resolved_subnets = app_config.subnets == "public" ? "public" : "private"
      
      # Add environment-specific monitoring
      enable_monitoring = local.current_config.monitoring_enabled && app_config.enable_monitoring
    })
  }
  
  # Load balancer configuration
  load_balancer_config = {
    name               = "${local.name_prefix}-alb"
    internal           = false
    load_balancer_type = "application"
    enable_deletion_protection = local.current_config.deletion_protection
    
    # Access logs configuration
    access_logs = {
      bucket  = "${local.name_prefix}-alb-logs-${random_id.bucket_suffix.hex}"
      enabled = local.current_config.monitoring_enabled
      prefix  = "alb-access-logs"
    }
  }
  
  # Database configuration with environment overrides
  resolved_database_config = merge(var.database_config, {
    instance_class         = local.current_config.database_instance_class
    multi_az              = local.current_config.enable_multi_az
    backup_retention_period = local.current_config.backup_retention
    deletion_protection   = local.current_config.deletion_protection
    performance_insights  = local.current_config.monitoring_enabled
    monitoring_interval   = local.current_config.monitoring_enabled ? 60 : 0
  })
  
  # Monitoring configuration
  monitoring_config = {
    enable_detailed_monitoring = local.current_config.monitoring_enabled
    dashboard_name            = "${local.name_prefix}-dashboard"
    log_group_name           = "/aws/ec2/${local.name_prefix}"
    log_retention_days       = var.monitoring_config.log_retention_days
    
    # CloudWatch alarms configuration
    alarms = {
      high_cpu = {
        metric_name         = "CPUUtilization"
        threshold          = 80
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        period             = 300
      }
      high_memory = {
        metric_name         = "MemoryUtilization"
        threshold          = 85
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        period             = 300
      }
    }
  }
  
  # Backup configuration
  backup_config = merge(var.backup_config, {
    vault_name = "${local.name_prefix}-backup-vault"
    plan_name  = "${local.name_prefix}-backup-plan"
    role_name  = "${local.name_prefix}-backup-role"
    
    # Backup selection configuration
    selection_name = "${local.name_prefix}-backup-selection"
    resources = [
      "arn:aws:rds:${local.region}:${local.account_id}:db:${local.name_prefix}-*",
      "arn:aws:ec2:${local.region}:${local.account_id}:volume/*"
    ]
  })
  
  # Common tags applied to all resources
  common_tags = {
    Environment      = local.environment
    Project          = local.project
    ManagedBy        = "terraform"
    Region           = local.region
    AccountId        = local.account_id
    CreatedDate      = formatdate("YYYY-MM-DD", timestamp())
    LabTopic         = "resource-management-dependencies"
    LabVersion       = "4.1"
    Owner            = var.owner_email
    CostCenter       = var.cost_center
    
    # Dependency tracking tags
    DependencyTier   = "computed"
    ResourceGroup    = local.name_prefix
    
    # Compliance and governance tags
    Compliance       = "required"
    DataClass        = "internal"
    BackupRequired   = "true"
    MonitoringLevel  = local.current_config.monitoring_enabled ? "detailed" : "basic"
  }
  
  # Resource-specific tag overrides
  network_tags = merge(local.common_tags, {
    Type           = "network"
    DependencyTier = "foundation"
    Critical       = "true"
  })
  
  security_tags = merge(local.common_tags, {
    Type           = "security"
    DependencyTier = "security"
    Critical       = "true"
  })
  
  database_tags = merge(local.common_tags, {
    Type           = "database"
    DependencyTier = "data"
    Critical       = "true"
    BackupRequired = "true"
    Encrypted      = "true"
  })
  
  application_tags = merge(local.common_tags, {
    Type           = "application"
    DependencyTier = "application"
    Scalable       = "true"
  })
  
  # Feature flag resolution
  resolved_feature_flags = merge(var.feature_flags, {
    # Disable certain features in development
    enable_backup = local.environment == "dev" ? false : var.feature_flags.enable_backup
    enable_monitoring = local.current_config.monitoring_enabled && var.feature_flags.enable_monitoring
    enable_cloudtrail = local.environment == "prod" ? true : var.feature_flags.enable_cloudtrail
  })
}
