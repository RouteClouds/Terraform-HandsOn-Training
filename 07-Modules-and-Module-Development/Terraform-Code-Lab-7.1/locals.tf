# =============================================================================
# AWS Terraform Training - Topic 7: Modules and Module Development
# Local Values for Complex Calculations and Module Development
# =============================================================================

locals {
  # =============================================================================
  # Environment and Module Development Configuration
  # =============================================================================
  
  # Environment type detection
  is_development = contains(["development", "dev"], var.environment)
  is_staging     = contains(["staging", "stage"], var.environment)
  is_production  = contains(["production", "prod"], var.environment)
  
  # Module development environment settings
  module_development_settings = {
    testing_enabled        = var.enable_module_testing && (local.is_development || local.is_staging)
    security_level        = local.is_production ? "high" : local.is_staging ? "medium" : "low"
    cost_optimization     = local.is_development ? "aggressive" : local.is_staging ? "moderate" : "conservative"
    automation_level      = local.is_production ? "full" : local.is_staging ? "partial" : "minimal"
    monitoring_level      = local.is_production ? "detailed" : local.is_staging ? "standard" : "basic"
  }
  
  # Module versioning and tagging
  module_metadata = {
    version           = var.module_version
    development_mode  = var.module_development_mode
    creation_time     = timestamp()
    terraform_version = "~> 1.13.0"
    provider_version  = "~> 6.12.0"
  }
  
  # =============================================================================
  # Resource Naming and Tagging
  # =============================================================================
  
  # Standardized naming convention for modules
  name_prefix = "${var.project_name}-${var.environment}"
  name_suffix = random_id.module_suffix.hex
  
  # Module-specific resource names
  module_resource_names = {
    vpc_module           = "${local.name_prefix}-vpc-${local.name_suffix}"
    security_group       = "${local.name_prefix}-sg-${local.name_suffix}"
    ec2_instance         = "${local.name_prefix}-ec2-${local.name_suffix}"
    s3_bucket           = "${local.name_prefix}-s3-${local.name_suffix}"
    rds_database        = "${local.name_prefix}-rds-${local.name_suffix}"
    testing_bucket      = "${local.name_prefix}-testing-${local.name_suffix}"
    registry_bucket     = "${local.name_prefix}-registry-${local.name_suffix}"
  }
  
  # Common tags applied to all module resources
  common_tags = merge(
    {
      Project             = var.project_name
      Environment         = var.environment
      Owner               = var.owner
      CostCenter          = var.cost_center
      ManagedBy           = "Terraform"
      TrainingModule      = "Topic-7-Modules-Development"
      CreatedDate         = formatdate("YYYY-MM-DD", timestamp())
      ModuleVersion       = var.module_version
      ModuleDevelopment   = "true"
      TerraformVersion    = "~> 1.13.0"
      ProviderVersion     = "~> 6.12.0"
      Region              = data.aws_region.current.name
      AccountId           = data.aws_caller_identity.current.account_id
    },
    var.enable_cost_allocation_tags ? {
      BillingProject      = var.project_name
      BillingOwner        = var.owner
      BillingCostCenter   = var.cost_center
      BillingEnvironment  = var.environment
      BillingModuleType   = "development"
    } : {}
  )
  
  # Module-specific tags
  module_tags = {
    vpc_module = merge(local.common_tags, {
      ModuleType    = "networking"
      ModuleName    = "vpc"
      ModulePurpose = "network-infrastructure"
    })
    
    security_group_module = merge(local.common_tags, {
      ModuleType    = "security"
      ModuleName    = "security-group"
      ModulePurpose = "network-security"
    })
    
    ec2_instance_module = merge(local.common_tags, {
      ModuleType    = "compute"
      ModuleName    = "ec2-instance"
      ModulePurpose = "compute-infrastructure"
    })
    
    s3_bucket_module = merge(local.common_tags, {
      ModuleType    = "storage"
      ModuleName    = "s3-bucket"
      ModulePurpose = "object-storage"
    })
    
    rds_database_module = merge(local.common_tags, {
      ModuleType    = "database"
      ModuleName    = "rds-database"
      ModulePurpose = "data-persistence"
    })
  }
  
  # =============================================================================
  # Network Configuration for Modules
  # =============================================================================
  
  # VPC and subnet calculations for module development
  vpc_cidr_block = var.vpc_cidr
  
  # Calculate subnet CIDRs for different module scenarios
  subnet_cidrs = {
    # Public subnets for web-facing modules
    public = [
      for i in range(min(length(var.availability_zones), 3)) :
      cidrsubnet(local.vpc_cidr_block, 8, i)
    ]
    
    # Private subnets for application modules
    private = [
      for i in range(min(length(var.availability_zones), 3)) :
      cidrsubnet(local.vpc_cidr_block, 8, i + 10)
    ]
    
    # Database subnets for data modules
    database = [
      for i in range(min(length(var.availability_zones), 3)) :
      cidrsubnet(local.vpc_cidr_block, 8, i + 20)
    ]
    
    # Testing subnets for module testing
    testing = [
      for i in range(min(length(var.availability_zones), 2)) :
      cidrsubnet(local.vpc_cidr_block, 8, i + 30)
    ]
  }
  
  # Availability zones (limited for cost optimization)
  availability_zones = slice(var.availability_zones, 0, min(length(var.availability_zones), 3))
  
  # =============================================================================
  # Module Configuration and Composition
  # =============================================================================
  
  # Enabled modules based on configuration
  enabled_modules = {
    for module_name, config in var.module_examples : module_name => config
    if config.enabled
  }
  
  # Module dependencies and composition
  module_dependencies = {
    vpc_module = []  # No dependencies
    security_group_module = ["vpc_module"]  # Depends on VPC
    ec2_instance_module = ["vpc_module", "security_group_module"]  # Depends on VPC and Security Group
    s3_bucket_module = []  # No dependencies
    rds_database_module = ["vpc_module"]  # Depends on VPC
  }
  
  # Module composition patterns
  module_compositions = {
    # Basic web application stack
    web_application = {
      modules = ["vpc_module", "security_group_module", "ec2_instance_module", "s3_bucket_module"]
      pattern = "web-tier"
    }
    
    # Data processing stack
    data_processing = {
      modules = ["vpc_module", "security_group_module", "ec2_instance_module", "rds_database_module"]
      pattern = "data-tier"
    }
    
    # Full stack application
    full_stack = {
      modules = ["vpc_module", "security_group_module", "ec2_instance_module", "s3_bucket_module", "rds_database_module"]
      pattern = "full-stack"
    }
  }
  
  # =============================================================================
  # Module Testing Configuration
  # =============================================================================
  
  # Testing environments configuration
  testing_config = {
    for env_name, config in var.testing_environments : env_name => merge(config, {
      enabled_modules = local.enabled_modules
      test_duration_seconds = config.test_duration_hours * 3600
      cost_estimate = config.test_duration_hours * 2.5  # USD per hour estimate
    })
    if config.enabled
  }
  
  # Module testing scenarios
  testing_scenarios = {
    unit_testing = {
      scope = "individual_modules"
      modules = keys(local.enabled_modules)
      test_types = ["syntax", "validation", "basic_functionality"]
      duration_minutes = 15
    }
    
    integration_testing = {
      scope = "module_composition"
      modules = local.module_compositions.web_application.modules
      test_types = ["module_interaction", "dependency_resolution", "data_flow"]
      duration_minutes = 45
    }
    
    end_to_end_testing = {
      scope = "complete_infrastructure"
      modules = local.module_compositions.full_stack.modules
      test_types = ["deployment", "functionality", "performance", "security"]
      duration_minutes = 90
    }
  }
  
  # =============================================================================
  # Security and Compliance Configuration
  # =============================================================================
  
  # Security configuration based on environment
  security_config = {
    encryption_required = local.is_production || local.is_staging
    access_logging_enabled = true
    versioning_enabled = true
    public_access_blocked = true
    
    # Security scanning configuration
    security_scanning = {
      enabled = var.enable_security_scanning
      schedule = var.security_scan_schedule
      tools = ["tfsec", "checkov", "terrascan"]
      severity_threshold = local.is_production ? "low" : "medium"
    }
    
    # Compliance requirements
    compliance = {
      enabled = var.enable_compliance_checking
      frameworks = local.is_production ? ["soc2", "hipaa"] : ["basic"]
      audit_logging = true
      data_classification = local.is_production ? "confidential" : "internal"
    }
  }
  
  # IAM roles and policies for module development
  iam_config = {
    module_developer_role = {
      name = "${local.name_prefix}-module-developer"
      policies = ["ec2:*", "s3:*", "rds:*", "vpc:*", "iam:PassRole"]
    }
    
    module_tester_role = {
      name = "${local.name_prefix}-module-tester"
      policies = ["ec2:Describe*", "s3:Get*", "s3:List*", "rds:Describe*"]
    }
    
    module_publisher_role = {
      name = "${local.name_prefix}-module-publisher"
      policies = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
    }
  }
  
  # =============================================================================
  # Cost Management and Optimization
  # =============================================================================
  
  # Cost estimation for module development
  cost_estimation = {
    # Base infrastructure costs (USD per month)
    vpc_module = 0  # VPC is free
    security_group_module = 0  # Security groups are free
    ec2_instance_module = {
      for module_name, config in local.enabled_modules : module_name => (
        module_name == "compute_module" ? (
          config.desired_capacity * (
            config.instance_type == "t3.micro" ? 8.5 :
            config.instance_type == "t3.small" ? 17 :
            config.instance_type == "t3.medium" ? 34 :
            config.instance_type == "t3.large" ? 67 : 0
          )
        ) : 0
      )
    }
    s3_bucket_module = 5  # Estimated storage and requests
    rds_database_module = 15  # db.t3.micro MySQL instance
    
    # Testing infrastructure costs
    testing_infrastructure = var.enable_module_testing ? 10 : 0
    
    # Total estimated monthly cost
    total_estimated = sum([
      0,  # VPC
      0,  # Security groups
      sum([for k, v in local.cost_estimation.ec2_instance_module : v]),
      local.cost_estimation.s3_bucket_module,
      local.cost_estimation.rds_database_module,
      local.cost_estimation.testing_infrastructure
    ])
  }
  
  # Cost optimization strategies
  cost_optimization = {
    # Development environment optimizations
    development = {
      instance_types = ["t3.micro", "t3.small"]
      storage_classes = ["STANDARD"]
      backup_retention = 1
      monitoring_level = "basic"
    }
    
    # Staging environment optimizations
    staging = {
      instance_types = ["t3.small", "t3.medium"]
      storage_classes = ["STANDARD", "STANDARD_IA"]
      backup_retention = 7
      monitoring_level = "standard"
    }
    
    # Production environment settings
    production = {
      instance_types = ["t3.medium", "t3.large", "m5.large"]
      storage_classes = ["STANDARD", "STANDARD_IA", "GLACIER"]
      backup_retention = 30
      monitoring_level = "detailed"
    }
  }
  
  # =============================================================================
  # Module Registry and Distribution
  # =============================================================================
  
  # Module registry configuration
  registry_config = {
    private_registry_enabled = var.module_registry_url == null && var.enable_module_testing
    public_registry_enabled = var.module_registry_url != null
    
    # Module sources and versions
    module_sources = {
      vpc = {
        source = "./modules/vpc"
        version = var.module_version
        registry = "private"
      }
      security_group = {
        source = "./modules/security-group"
        version = var.module_version
        registry = "private"
      }
      ec2_instance = {
        source = "./modules/ec2-instance"
        version = var.module_version
        registry = "private"
      }
      s3_bucket = {
        source = "./modules/s3-bucket"
        version = var.module_version
        registry = "private"
      }
      rds_database = {
        source = "./modules/rds-database"
        version = var.module_version
        registry = "private"
      }
    }
    
    # Distribution channels
    distribution = {
      git_repository = true
      private_registry = local.registry_config.private_registry_enabled
      terraform_registry = false  # Set to true for public modules
      artifact_storage = var.enable_module_testing
    }
  }
  
  # =============================================================================
  # CI/CD and Automation Configuration
  # =============================================================================
  
  # CI/CD pipeline configuration
  cicd_config = {
    terraform_version = "~> 1.13.0"
    aws_provider_version = "~> 6.12.0"
    
    # Pipeline stages
    stages = {
      validate = {
        commands = ["terraform validate", "terraform fmt -check"]
        timeout_minutes = 5
      }
      test = {
        commands = ["terraform test", "tfsec .", "checkov -d ."]
        timeout_minutes = 15
      }
      plan = {
        commands = ["terraform plan"]
        timeout_minutes = 10
      }
      apply = {
        commands = ["terraform apply -auto-approve"]
        timeout_minutes = 30
      }
    }
    
    # Environment variables for CI/CD
    environment_variables = {
      TF_VAR_project_name = var.project_name
      TF_VAR_environment = var.environment
      TF_VAR_aws_region = data.aws_region.current.name
      TF_VAR_module_version = var.module_version
      TF_VAR_enable_module_testing = var.enable_module_testing
      TF_VAR_enable_security_scanning = var.enable_security_scanning
    }
  }
}

# =============================================================================
# Local Values Configuration Notes:
# 
# 1. Module Development Focus:
#    - Environment-aware module configuration
#    - Module dependency and composition management
#    - Testing scenario definitions
#    - Registry and distribution settings
#
# 2. Resource Organization:
#    - Standardized naming for module resources
#    - Comprehensive tagging strategy
#    - Cost allocation and tracking
#    - Security and compliance alignment
#
# 3. Testing and Quality:
#    - Multi-level testing configuration
#    - Security scanning integration
#    - Compliance framework support
#    - Performance optimization settings
#
# 4. Operational Excellence:
#    - CI/CD pipeline configuration
#    - Cost estimation and optimization
#    - Monitoring and alerting setup
#    - Multi-environment support
#
# 5. Module Ecosystem:
#    - Registry integration patterns
#    - Version management strategies
#    - Distribution channel configuration
#    - Automation and tooling support
# =============================================================================
