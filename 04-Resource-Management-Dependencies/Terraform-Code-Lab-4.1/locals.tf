# AWS Terraform Training - Resource Management & Dependencies
# Lab 4.1: Advanced Resource Lifecycle and Dependency Management
# File: locals.tf - Local Values for Resource Management and Dependency Patterns

# ============================================================================
# RESOURCE DEPENDENCY MANAGEMENT CONFIGURATION
# ============================================================================

locals {
  # Resource dependency patterns and strategies
  dependency_management = {
    # Implicit dependency patterns (automatic through resource references)
    implicit_dependencies = {
      vpc_to_subnets = {
        description = "VPC automatically creates dependency for subnets"
        pattern = "aws_subnet.*.vpc_id = aws_vpc.main.id"
        benefits = ["automatic_ordering", "error_prevention", "simplified_configuration"]
      }
      
      security_groups_to_instances = {
        description = "Security groups create dependencies for EC2 instances"
        pattern = "aws_instance.*.security_groups = [aws_security_group.web.id]"
        benefits = ["network_security", "proper_ordering", "cleanup_sequence"]
      }
      
      load_balancer_to_target_groups = {
        description = "Load balancer dependencies on target groups and subnets"
        pattern = "aws_lb.*.subnets = aws_subnet.public[*].id"
        benefits = ["network_connectivity", "resource_availability", "proper_sequencing"]
      }
    }
    
    # Explicit dependency patterns (manual using depends_on)
    explicit_dependencies = {
      database_before_application = {
        description = "Ensure database is ready before application deployment"
        pattern = "depends_on = [aws_rds_instance.main]"
        use_cases = ["application_startup", "data_migration", "service_readiness"]
      }
      
      monitoring_before_production = {
        description = "Ensure monitoring is active before production resources"
        pattern = "depends_on = [aws_cloudwatch_dashboard.main]"
        use_cases = ["observability", "alerting", "compliance"]
      }
      
      networking_before_compute = {
        description = "Ensure network infrastructure before compute resources"
        pattern = "depends_on = [aws_nat_gateway.main, aws_route_table.private]"
        use_cases = ["connectivity", "security", "proper_routing"]
      }
    }
    
    # Dependency ordering strategies
    ordering_strategies = {
      # Layer-based ordering for complex infrastructures
      infrastructure_layers = [
        "foundation",    # VPC, subnets, gateways
        "security",      # Security groups, NACLs, IAM roles
        "storage",       # EBS volumes, S3 buckets, RDS instances
        "compute",       # EC2 instances, Auto Scaling Groups
        "networking",    # Load balancers, target groups
        "monitoring",    # CloudWatch, alarms, dashboards
        "applications"   # Application-specific resources
      ]
      
      # Service-based ordering for microservices
      service_layers = [
        "shared_services",    # Shared databases, caches
        "core_services",      # Authentication, authorization
        "business_services",  # Business logic services
        "api_gateway",        # API management and routing
        "frontend_services",  # Web applications, CDN
        "monitoring_services" # Logging, metrics, tracing
      ]
    }
  }
  
  # Current environment dependency configuration
  environment_dependencies = {
    development = {
      strict_ordering = false
      parallel_creation = true
      dependency_validation = "warning"
      cleanup_order = "reverse"
    }
    staging = {
      strict_ordering = true
      parallel_creation = true
      dependency_validation = "error"
      cleanup_order = "reverse"
    }
    production = {
      strict_ordering = true
      parallel_creation = false
      dependency_validation = "error"
      cleanup_order = "reverse"
    }
  }
  
  # Current environment settings
  current_dependency_config = local.environment_dependencies[var.environment]
}

# ============================================================================
# META-ARGUMENTS CONFIGURATION
# ============================================================================

locals {
  # Count meta-argument patterns
  count_patterns = {
    # Simple count for multiple similar resources
    simple_count = {
      description = "Create multiple identical resources"
      pattern = "count = var.instance_count"
      use_cases = ["web_servers", "worker_nodes", "cache_instances"]
      best_practices = [
        "use_for_identical_resources",
        "avoid_for_complex_configurations",
        "consider_for_each_for_flexibility"
      ]
    }
    
    # Conditional count for optional resources
    conditional_count = {
      description = "Create resources based on conditions"
      pattern = "count = var.enable_monitoring ? 1 : 0"
      use_cases = ["optional_features", "environment_specific", "cost_optimization"]
      best_practices = [
        "use_boolean_variables",
        "document_conditions_clearly",
        "test_both_scenarios"
      ]
    }
    
    # Dynamic count based on data sources
    dynamic_count = {
      description = "Count based on discovered resources"
      pattern = "count = length(data.aws_availability_zones.available.names)"
      use_cases = ["multi_az_deployment", "region_adaptation", "dynamic_scaling"]
      best_practices = [
        "validate_data_availability",
        "handle_empty_results",
        "consider_limits"
      ]
    }
  }
  
  # For_each meta-argument patterns
  for_each_patterns = {
    # Set-based for_each for unique resources
    set_based = {
      description = "Create resources from a set of values"
      pattern = "for_each = toset(var.availability_zones)"
      use_cases = ["multi_az_subnets", "regional_resources", "unique_configurations"]
      benefits = ["stable_addressing", "flexible_management", "clear_identification"]
    }
    
    # Map-based for_each for complex configurations
    map_based = {
      description = "Create resources with complex configurations"
      pattern = "for_each = var.instance_configurations"
      use_cases = ["different_instance_types", "varied_configurations", "role_based_resources"]
      benefits = ["configuration_flexibility", "maintainable_code", "clear_mapping"]
    }
    
    # Object-based for_each for structured data
    object_based = {
      description = "Create resources from structured objects"
      pattern = "for_each = { for k, v in var.environments : k => v if v.enabled }"
      use_cases = ["environment_management", "service_configuration", "conditional_deployment"]
      benefits = ["structured_approach", "conditional_logic", "data_validation"]
    }
  }
  
  # Current meta-argument configuration
  meta_argument_config = {
    # Preferred patterns for different resource types
    resource_patterns = {
      aws_subnet = "for_each"          # Better for multi-AZ subnets
      aws_instance = "for_each"        # Better for different configurations
      aws_security_group_rule = "count" # Simple repetition
      aws_route53_record = "for_each"  # Better for DNS management
    }
    
    # Performance considerations
    performance_settings = {
      max_count_resources = 50
      max_for_each_items = 100
      parallel_creation = var.enable_parallel_creation
      batch_size = var.resource_batch_size
    }
  }
}

# ============================================================================
# LIFECYCLE MANAGEMENT CONFIGURATION
# ============================================================================

locals {
  # Lifecycle rule patterns
  lifecycle_patterns = {
    # Standard lifecycle for most resources
    standard_lifecycle = {
      create_before_destroy = false
      prevent_destroy = false
      ignore_changes = []
      replace_triggered_by = []
    }
    
    # Zero-downtime lifecycle for critical resources
    zero_downtime_lifecycle = {
      create_before_destroy = true
      prevent_destroy = false
      ignore_changes = ["tags.LastModified"]
      replace_triggered_by = []
    }
    
    # Protected lifecycle for production resources
    protected_lifecycle = {
      create_before_destroy = true
      prevent_destroy = true
      ignore_changes = ["tags.LastModified", "tags.DeploymentTime"]
      replace_triggered_by = []
    }
    
    # Development lifecycle for flexible resources
    development_lifecycle = {
      create_before_destroy = false
      prevent_destroy = false
      ignore_changes = ["tags"]
      replace_triggered_by = []
    }
  }
  
  # Resource-specific lifecycle configurations
  resource_lifecycle_config = {
    # Database lifecycle (critical, protected)
    database_lifecycle = {
      aws_rds_instance = local.lifecycle_patterns.protected_lifecycle
      aws_rds_cluster = local.lifecycle_patterns.protected_lifecycle
      aws_elasticache_cluster = local.lifecycle_patterns.zero_downtime_lifecycle
    }
    
    # Compute lifecycle (flexible, performance-focused)
    compute_lifecycle = {
      aws_instance = var.environment == "production" ? 
        local.lifecycle_patterns.zero_downtime_lifecycle : 
        local.lifecycle_patterns.development_lifecycle
      aws_autoscaling_group = local.lifecycle_patterns.zero_downtime_lifecycle
      aws_launch_template = local.lifecycle_patterns.zero_downtime_lifecycle
    }
    
    # Network lifecycle (stable, foundational)
    network_lifecycle = {
      aws_vpc = local.lifecycle_patterns.protected_lifecycle
      aws_subnet = local.lifecycle_patterns.protected_lifecycle
      aws_security_group = local.lifecycle_patterns.standard_lifecycle
      aws_route_table = local.lifecycle_patterns.standard_lifecycle
    }
    
    # Storage lifecycle (protected, persistent)
    storage_lifecycle = {
      aws_ebs_volume = local.lifecycle_patterns.protected_lifecycle
      aws_s3_bucket = local.lifecycle_patterns.protected_lifecycle
      aws_efs_file_system = local.lifecycle_patterns.protected_lifecycle
    }
  }
  
  # Environment-specific lifecycle settings
  environment_lifecycle = {
    development = {
      default_prevent_destroy = false
      default_create_before_destroy = false
      ignore_tag_changes = true
      allow_force_destroy = true
    }
    staging = {
      default_prevent_destroy = false
      default_create_before_destroy = true
      ignore_tag_changes = true
      allow_force_destroy = false
    }
    production = {
      default_prevent_destroy = true
      default_create_before_destroy = true
      ignore_tag_changes = false
      allow_force_destroy = false
    }
  }
  
  # Current environment lifecycle settings
  current_lifecycle_config = local.environment_lifecycle[var.environment]
}

# ============================================================================
# RESOURCE TARGETING AND MANAGEMENT
# ============================================================================

locals {
  # Resource targeting strategies
  targeting_strategies = {
    # Layer-based targeting for infrastructure updates
    infrastructure_targets = {
      networking = [
        "aws_vpc.main",
        "aws_subnet.public",
        "aws_subnet.private",
        "aws_internet_gateway.main",
        "aws_nat_gateway.main",
        "aws_route_table.public",
        "aws_route_table.private"
      ]
      
      security = [
        "aws_security_group.web",
        "aws_security_group.app",
        "aws_security_group.db",
        "aws_network_acl.main"
      ]
      
      compute = [
        "aws_instance.web",
        "aws_instance.app",
        "aws_autoscaling_group.web",
        "aws_launch_template.web"
      ]
      
      storage = [
        "aws_ebs_volume.data",
        "aws_s3_bucket.assets",
        "aws_rds_instance.main"
      ]
      
      monitoring = [
        "aws_cloudwatch_dashboard.main",
        "aws_cloudwatch_alarm.cpu",
        "aws_sns_topic.alerts"
      ]
    }
    
    # Service-based targeting for application updates
    service_targets = {
      web_tier = [
        "aws_instance.web",
        "aws_autoscaling_group.web",
        "aws_lb.web",
        "aws_lb_target_group.web"
      ]
      
      app_tier = [
        "aws_instance.app",
        "aws_autoscaling_group.app",
        "aws_lb.app",
        "aws_lb_target_group.app"
      ]
      
      data_tier = [
        "aws_rds_instance.main",
        "aws_elasticache_cluster.main",
        "aws_s3_bucket.data"
      ]
    }
    
    # Environment-based targeting
    environment_targets = {
      shared_resources = [
        "aws_vpc.main",
        "aws_subnet.public",
        "aws_subnet.private"
      ]
      
      environment_specific = [
        "aws_instance.web",
        "aws_instance.app",
        "aws_rds_instance.main"
      ]
    }
  }
  
  # Resource management patterns
  management_patterns = {
    # Blue-green deployment pattern
    blue_green = {
      description = "Deploy new version alongside existing"
      resources = ["aws_instance", "aws_autoscaling_group", "aws_lb_target_group"]
      lifecycle = local.lifecycle_patterns.zero_downtime_lifecycle
      strategy = "create_before_destroy"
    }
    
    # Rolling update pattern
    rolling_update = {
      description = "Update resources incrementally"
      resources = ["aws_autoscaling_group", "aws_ecs_service"]
      lifecycle = local.lifecycle_patterns.standard_lifecycle
      strategy = "in_place_update"
    }
    
    # Immutable infrastructure pattern
    immutable = {
      description = "Replace entire infrastructure"
      resources = ["aws_instance", "aws_launch_template"]
      lifecycle = local.lifecycle_patterns.zero_downtime_lifecycle
      strategy = "full_replacement"
    }
  }
}

# ============================================================================
# DEPENDENCY TROUBLESHOOTING AND VALIDATION
# ============================================================================

locals {
  # Common dependency issues and solutions
  dependency_troubleshooting = {
    # Circular dependency detection
    circular_dependencies = {
      common_scenarios = [
        "security_group_cross_references",
        "route_table_subnet_associations",
        "load_balancer_target_group_loops"
      ]
      
      solutions = [
        "break_circular_references",
        "use_separate_resources",
        "implement_staged_deployment"
      ]
      
      prevention = [
        "design_clear_hierarchy",
        "avoid_bidirectional_references",
        "use_data_sources_for_existing_resources"
      ]
    }
    
    # Missing dependency detection
    missing_dependencies = {
      symptoms = [
        "resource_creation_failures",
        "timing_issues",
        "inconsistent_deployments"
      ]
      
      solutions = [
        "add_explicit_depends_on",
        "use_resource_references",
        "implement_proper_ordering"
      ]
      
      validation = [
        "terraform_plan_review",
        "dependency_graph_analysis",
        "integration_testing"
      ]
    }
    
    # Performance optimization
    performance_optimization = {
      parallel_creation = {
        enabled = var.enable_parallel_creation
        max_parallelism = var.max_parallelism
        resource_batching = var.enable_resource_batching
      }
      
      dependency_minimization = {
        avoid_unnecessary_depends_on = true
        use_implicit_dependencies = true
        optimize_resource_references = true
      }
      
      resource_grouping = {
        group_by_layer = true
        group_by_service = true
        minimize_cross_dependencies = true
      }
    }
  }
  
  # Dependency validation rules
  validation_rules = {
    # Required dependencies
    required_dependencies = {
      vpc_before_subnets = "aws_subnet.*.vpc_id must reference aws_vpc"
      security_groups_before_instances = "aws_instance.*.security_groups must reference aws_security_group"
      subnets_before_instances = "aws_instance.*.subnet_id must reference aws_subnet"
    }
    
    # Forbidden dependencies
    forbidden_dependencies = {
      no_circular_security_groups = "Security groups cannot reference each other circularly"
      no_cross_region_dependencies = "Resources cannot depend on resources in different regions"
      no_cross_account_direct_dependencies = "Direct dependencies across accounts not allowed"
    }
    
    # Best practice validations
    best_practice_validations = {
      explicit_critical_dependencies = "Critical path dependencies should be explicit"
      minimize_depends_on_usage = "Prefer implicit dependencies over explicit depends_on"
      document_complex_dependencies = "Complex dependency chains should be documented"
    }
  }
}

# ============================================================================
# RESOURCE ORGANIZATION AND NAMING
# ============================================================================

locals {
  # Resource naming conventions
  naming_conventions = {
    # Standard naming pattern
    standard_pattern = "${var.project_name}-${var.environment}-${var.component}-${var.resource_type}"
    
    # Resource-specific naming
    resource_naming = {
      vpc = "${var.project_name}-${var.environment}-vpc"
      subnet = "${var.project_name}-${var.environment}-${each.key}-subnet"
      security_group = "${var.project_name}-${var.environment}-${var.component}-sg"
      instance = "${var.project_name}-${var.environment}-${var.component}-${count.index + 1}"
      load_balancer = "${var.project_name}-${var.environment}-${var.component}-lb"
      database = "${var.project_name}-${var.environment}-${var.component}-db"
    }
    
    # Tag-based organization
    tag_organization = {
      required_tags = {
        Project = var.project_name
        Environment = var.environment
        Component = var.component
        ManagedBy = "terraform"
        Owner = var.owner_email
      }
      
      dependency_tags = {
        DependsOn = "comma-separated list of dependencies"
        Layer = "infrastructure layer (foundation, security, compute, etc.)"
        Service = "service name for service-based grouping"
      }
      
      lifecycle_tags = {
        LifecyclePolicy = "standard|zero-downtime|protected|development"
        BackupRequired = "true|false"
        MonitoringLevel = "basic|standard|enhanced"
      }
    }
  }
  
  # Resource organization patterns
  organization_patterns = {
    # File-based organization
    file_organization = {
      main_tf = "Core infrastructure resources"
      networking_tf = "VPC, subnets, gateways, routing"
      security_tf = "Security groups, NACLs, IAM"
      compute_tf = "EC2, ASG, launch templates"
      storage_tf = "EBS, S3, RDS, ElastiCache"
      monitoring_tf = "CloudWatch, SNS, alarms"
    }
    
    # Module-based organization
    module_organization = {
      networking_module = "VPC and related networking resources"
      security_module = "Security groups and IAM resources"
      compute_module = "EC2 and Auto Scaling resources"
      storage_module = "Storage and database resources"
      monitoring_module = "Monitoring and alerting resources"
    }
    
    # Workspace-based organization
    workspace_organization = {
      shared_workspace = "Shared infrastructure (VPC, subnets)"
      app_workspace = "Application-specific resources"
      data_workspace = "Data and storage resources"
      monitoring_workspace = "Monitoring and logging resources"
    }
  }
}
