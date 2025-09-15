# AWS Terraform Training - Core Terraform Operations
# Lab 3.1: Mastering Core Workflow and Resource Lifecycle
# File: locals.tf - Local Values for Core Operations and Workflow Management

# ============================================================================
# CORE TERRAFORM WORKFLOW CONFIGURATION
# ============================================================================

locals {
  # Terraform core workflow configuration
  workflow_configuration = {
    # Core operations sequence
    operations_sequence = [
      "init",      # Initialize working directory
      "validate",  # Validate configuration syntax
      "plan",      # Create execution plan
      "apply",     # Execute the plan
      "destroy"    # Clean up resources
    ]
    
    # Workflow best practices
    best_practices = {
      always_plan_before_apply = true
      save_plans_to_files     = true
      use_auto_approve_carefully = false
      enable_state_locking    = true
      backup_state_files      = true
      validate_before_commit  = true
    }
    
    # Performance optimization settings
    performance_settings = {
      parallelism = var.terraform_parallelism
      plugin_cache_enabled = true
      provider_cache_dir = "~/.terraform.d/plugin-cache"
      refresh_before_plan = true
      detailed_exitcode = true
    }
    
    # Logging and debugging configuration
    logging_config = {
      log_level = var.terraform_log_level
      log_path = "./terraform-operations.log"
      enable_crash_log = true
      crash_log_path = "./crash.log"
    }
  }
  
  # Environment-specific workflow settings
  environment_workflow = {
    development = {
      auto_approve_allowed = true
      parallelism = 5
      refresh_interval = "30s"
      plan_timeout = "10m"
      apply_timeout = "30m"
    }
    staging = {
      auto_approve_allowed = false
      parallelism = 10
      refresh_interval = "60s"
      plan_timeout = "15m"
      apply_timeout = "45m"
    }
    production = {
      auto_approve_allowed = false
      parallelism = 20
      refresh_interval = "120s"
      plan_timeout = "30m"
      apply_timeout = "90m"
    }
  }
  
  # Current environment workflow settings
  current_workflow = local.environment_workflow[var.environment]
}

# ============================================================================
# RESOURCE LIFECYCLE MANAGEMENT
# ============================================================================

locals {
  # Resource lifecycle configuration
  lifecycle_management = {
    # Standard lifecycle rules
    standard_lifecycle = {
      create_before_destroy = var.enable_zero_downtime_updates
      prevent_destroy = var.environment == "production"
      ignore_changes = var.lifecycle_ignore_changes
    }
    
    # Critical resource lifecycle (production databases, etc.)
    critical_lifecycle = {
      create_before_destroy = true
      prevent_destroy = true
      ignore_changes = [
        "tags.LastModified",
        "tags.DeploymentTime"
      ]
    }
    
    # Development resource lifecycle (more flexible)
    development_lifecycle = {
      create_before_destroy = false
      prevent_destroy = false
      ignore_changes = []
    }
    
    # Resource replacement triggers
    replacement_triggers = {
      instance_type_change = var.instance_type
      ami_change = var.ami_id
      security_group_change = var.security_group_ids
      subnet_change = var.subnet_ids
    }
  }
  
  # Resource dependency management
  dependency_management = {
    # Implicit dependencies (automatic)
    implicit_dependencies = {
      vpc_to_subnets = true
      subnets_to_instances = true
      security_groups_to_instances = true
      load_balancer_to_target_group = true
    }
    
    # Explicit dependencies (manual)
    explicit_dependencies = {
      database_before_application = var.database_dependency_required
      monitoring_before_application = var.monitoring_dependency_required
      logging_before_application = var.logging_dependency_required
    }
    
    # Dependency ordering
    creation_order = [
      "networking",     # VPC, subnets, gateways
      "security",       # Security groups, NACLs
      "storage",        # EBS volumes, S3 buckets
      "compute",        # EC2 instances, ASGs
      "load_balancing", # ALB, NLB, target groups
      "monitoring",     # CloudWatch, alarms
      "applications"    # Application-specific resources
    ]
  }
}

# ============================================================================
# PERFORMANCE OPTIMIZATION CONFIGURATION
# ============================================================================

locals {
  # Performance optimization settings
  performance_optimization = {
    # Parallelism configuration
    parallelism_config = {
      default_parallelism = 10
      max_parallelism = var.max_parallelism
      resource_specific = {
        aws_instance = 5        # Limit EC2 instance creation parallelism
        aws_rds_instance = 2    # Limit RDS instance creation parallelism
        aws_s3_bucket = 20      # S3 buckets can be created in parallel
        aws_iam_role = 15       # IAM roles can be created quickly
      }
    }
    
    # Resource targeting strategies
    targeting_strategies = {
      # Infrastructure layers for targeted deployments
      infrastructure_layers = {
        networking = [
          "aws_vpc.main",
          "aws_subnet.public",
          "aws_subnet.private",
          "aws_internet_gateway.main",
          "aws_nat_gateway.main"
        ]
        security = [
          "aws_security_group.web",
          "aws_security_group.app",
          "aws_security_group.db"
        ]
        compute = [
          "aws_instance.web",
          "aws_instance.app"
        ]
        storage = [
          "aws_ebs_volume.data",
          "aws_s3_bucket.assets"
        ]
      }
      
      # Component-based targeting
      component_targeting = {
        web_tier = "aws_instance.web"
        app_tier = "aws_instance.app"
        data_tier = "aws_rds_instance.main"
      }
    }
    
    # Provider optimization
    provider_optimization = {
      # AWS provider optimization
      aws_optimization = {
        max_retries = var.aws_max_retries
        retry_mode = "adaptive"
        skip_credentials_validation = false
        skip_metadata_api_check = false
        skip_region_validation = false
        
        # Endpoint optimization for VPC endpoints
        use_vpc_endpoints = var.enable_vpc_endpoints
        custom_endpoints = var.custom_aws_endpoints
      }
      
      # Plugin cache configuration
      plugin_cache = {
        enabled = true
        directory = "~/.terraform.d/plugin-cache"
        max_size_gb = 5
        cleanup_interval = "7d"
      }
    }
  }
  
  # Resource creation batching
  resource_batching = {
    # Batch size for different resource types
    batch_sizes = {
      small_resources = 50    # Security group rules, tags
      medium_resources = 20   # EC2 instances, EBS volumes
      large_resources = 5     # RDS instances, EKS clusters
      critical_resources = 1  # Production databases
    }
    
    # Batch timing
    batch_timing = {
      delay_between_batches = "30s"
      max_batch_duration = "10m"
      retry_failed_batches = true
      max_batch_retries = 3
    }
  }
}

# ============================================================================
# ERROR HANDLING AND RECOVERY CONFIGURATION
# ============================================================================

locals {
  # Error handling strategies
  error_handling = {
    # Common error scenarios and responses
    error_scenarios = {
      resource_already_exists = {
        action = "import_existing"
        retry_count = 3
        retry_delay = "30s"
      }
      
      insufficient_permissions = {
        action = "check_iam_policies"
        escalation_required = true
        documentation_link = "https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot.html"
      }
      
      resource_limit_exceeded = {
        action = "request_limit_increase"
        alternative_regions = ["us-west-2", "eu-west-1"]
        contact_support = true
      }
      
      network_timeout = {
        action = "retry_with_backoff"
        max_retries = 5
        backoff_multiplier = 2
        max_backoff = "300s"
      }
      
      state_lock_conflict = {
        action = "wait_and_retry"
        max_wait_time = "15m"
        force_unlock_threshold = "30m"
        notification_required = true
      }
    }
    
    # Recovery procedures
    recovery_procedures = {
      partial_apply_failure = {
        steps = [
          "assess_current_state",
          "identify_failed_resources",
          "determine_rollback_strategy",
          "execute_targeted_operations",
          "validate_recovery"
        ]
        automation_available = true
        manual_intervention_required = false
      }
      
      state_corruption = {
        steps = [
          "stop_all_operations",
          "backup_current_state",
          "restore_from_backup",
          "validate_state_integrity",
          "resume_operations"
        ]
        automation_available = false
        manual_intervention_required = true
      }
      
      provider_unavailability = {
        steps = [
          "check_provider_status",
          "switch_to_backup_region",
          "notify_stakeholders",
          "implement_workaround",
          "monitor_for_resolution"
        ]
        automation_available = true
        escalation_required = true
      }
    }
  }
  
  # Monitoring and alerting for operations
  operations_monitoring = {
    # Metrics to track
    key_metrics = {
      operation_duration = {
        init_time = "< 2m"
        plan_time = "< 5m"
        apply_time = "< 30m"
        destroy_time = "< 15m"
      }
      
      success_rates = {
        target_success_rate = "99.5%"
        acceptable_failure_rate = "0.5%"
        critical_failure_threshold = "5%"
      }
      
      resource_metrics = {
        resources_per_apply = var.expected_resource_count
        average_resource_creation_time = "30s"
        resource_failure_rate = "< 1%"
      }
    }
    
    # Alerting configuration
    alerting = {
      operation_failure = {
        enabled = true
        severity = "high"
        notification_channels = var.alert_notification_channels
      }
      
      long_running_operations = {
        enabled = true
        threshold = "45m"
        severity = "medium"
      }
      
      state_lock_timeout = {
        enabled = true
        threshold = "15m"
        severity = "high"
      }
    }
  }
}

# ============================================================================
# ENTERPRISE WORKFLOW PATTERNS
# ============================================================================

locals {
  # Enterprise workflow configuration
  enterprise_patterns = {
    # CI/CD integration
    cicd_integration = {
      # Pipeline stages
      pipeline_stages = [
        "validate",
        "security_scan",
        "plan",
        "approval",
        "apply",
        "test",
        "promote"
      ]
      
      # Automation settings
      automation_config = {
        auto_validate = true
        auto_plan = true
        auto_apply = var.environment != "production"
        require_approval = var.environment == "production"
        parallel_environments = var.enable_parallel_deployments
      }
      
      # Quality gates
      quality_gates = {
        security_scan_required = true
        cost_analysis_required = var.environment == "production"
        compliance_check_required = var.compliance_framework != ""
        performance_test_required = var.environment != "development"
      }
    }
    
    # Team collaboration
    team_collaboration = {
      # Role-based access
      role_permissions = {
        developer = ["plan", "validate"]
        devops_engineer = ["plan", "apply", "destroy"]
        infrastructure_admin = ["*"]
        security_reviewer = ["plan", "validate", "security_scan"]
      }
      
      # Workflow approvals
      approval_workflow = {
        development = {
          required_approvers = 0
          auto_merge = true
        }
        staging = {
          required_approvers = 1
          auto_merge = false
        }
        production = {
          required_approvers = 2
          security_review_required = true
          auto_merge = false
        }
      }
    }
    
    # Compliance and governance
    compliance_patterns = {
      # Audit requirements
      audit_requirements = {
        log_all_operations = true
        retain_logs_days = 90
        encrypt_logs = true
        centralized_logging = var.enable_centralized_logging
      }
      
      # Change management
      change_management = {
        change_request_required = var.environment == "production"
        maintenance_window_required = var.environment == "production"
        rollback_plan_required = true
        communication_plan_required = var.environment == "production"
      }
    }
  }
  
  # Workspace management
  workspace_management = {
    # Workspace naming convention
    workspace_naming = {
      pattern = "${var.project_name}-${var.environment}-${var.region}"
      max_length = 50
      allowed_characters = "a-z0-9-"
    }
    
    # Workspace-specific settings
    workspace_settings = {
      development = {
        terraform_version = "~> 1.13.0"
        execution_mode = "local"
        auto_apply = true
      }
      staging = {
        terraform_version = "~> 1.13.0"
        execution_mode = "remote"
        auto_apply = false
      }
      production = {
        terraform_version = "~> 1.13.0"
        execution_mode = "remote"
        auto_apply = false
      }
    }
  }
}

# ============================================================================
# OPERATIONAL METRICS AND REPORTING
# ============================================================================

locals {
  # Operational metrics configuration
  operational_metrics = {
    # Performance metrics
    performance_metrics = {
      operation_times = {
        init_duration = "terraform_init_duration_seconds"
        plan_duration = "terraform_plan_duration_seconds"
        apply_duration = "terraform_apply_duration_seconds"
        destroy_duration = "terraform_destroy_duration_seconds"
      }
      
      resource_metrics = {
        resources_created = "terraform_resources_created_total"
        resources_updated = "terraform_resources_updated_total"
        resources_destroyed = "terraform_resources_destroyed_total"
        resources_failed = "terraform_resources_failed_total"
      }
    }
    
    # Business metrics
    business_metrics = {
      cost_metrics = {
        estimated_monthly_cost = var.estimated_monthly_cost
        cost_per_resource = var.cost_per_resource
        cost_optimization_savings = var.cost_optimization_savings
      }
      
      reliability_metrics = {
        uptime_percentage = "99.9%"
        mttr_minutes = 15
        mtbf_hours = 720
      }
    }
    
    # Reporting configuration
    reporting_config = {
      daily_reports = var.enable_daily_reports
      weekly_summaries = var.enable_weekly_summaries
      monthly_analysis = var.enable_monthly_analysis
      real_time_dashboards = var.enable_real_time_dashboards
    }
  }
  
  # Current operation context
  current_operation_context = {
    operation_id = random_uuid.operation_id.result
    timestamp = timestamp()
    operator = var.operator_name
    environment = var.environment
    project = var.project_name
    terraform_version = "~> 1.13.0"
    aws_provider_version = "~> 6.12.0"
  }
}
