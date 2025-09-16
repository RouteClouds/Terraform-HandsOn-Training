# Terraform Code Lab 5.1: Advanced Variables and Outputs
# Comprehensive Output Definitions
#
# This file demonstrates sophisticated output patterns including hierarchical
# structures, cross-module integration, sensitive data handling, computed
# transformations, and enterprise governance support.

# Basic Infrastructure Outputs
output "vpc_information" {
  description = "Complete VPC information and metadata for cross-module integration"
  value = {
    # Basic VPC details
    id         = aws_vpc.main.id
    arn        = aws_vpc.main.arn
    cidr_block = aws_vpc.main.cidr_block
    
    # DNS configuration
    dns_configuration = {
      enable_dns_hostnames = aws_vpc.main.enable_dns_hostnames
      enable_dns_support   = aws_vpc.main.enable_dns_support
      dhcp_options_id     = aws_vpc.main.dhcp_options_id
    }
    
    # Network details
    network_details = {
      instance_tenancy     = aws_vpc.main.instance_tenancy
      ipv6_cidr_block     = aws_vpc.main.ipv6_cidr_block
      ipv6_association_id = aws_vpc.main.ipv6_association_id
      default_network_acl_id = aws_vpc.main.default_network_acl_id
      default_route_table_id = aws_vpc.main.default_route_table_id
      default_security_group_id = aws_vpc.main.default_security_group_id
    }
    
    # Metadata and governance
    metadata = {
      owner_id = aws_vpc.main.owner_id
      tags     = aws_vpc.main.tags
      tags_all = aws_vpc.main.tags_all
    }
  }
}

# Comprehensive Subnet Configuration
output "subnet_configuration" {
  description = "Complete subnet configuration with computed values and cross-references"
  value = {
    # Public subnets with detailed information
    public_subnets = {
      for subnet_name, subnet in aws_subnet.public : subnet_name => {
        # Basic subnet information
        id                = subnet.id
        arn               = subnet.arn
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        
        # Network configuration
        network_config = {
          map_public_ip_on_launch = subnet.map_public_ip_on_launch
          assign_ipv6_address_on_creation = subnet.assign_ipv6_address_on_creation
          ipv6_cidr_block = subnet.ipv6_cidr_block
          outpost_arn     = subnet.outpost_arn
        }
        
        # Capacity and utilization
        capacity = {
          available_ip_address_count = subnet.available_ip_address_count
          ipv6_native               = subnet.ipv6_native
        }
        
        # Cross-references
        references = {
          vpc_id           = subnet.vpc_id
          route_table_id   = aws_route_table.public.id
          internet_gateway = var.network_configuration.gateways.internet_gateway.enabled ? aws_internet_gateway.main[0].id : null
        }
        
        # Metadata
        metadata = {
          owner_id = subnet.owner_id
          tags     = subnet.tags
          index    = local.subnet_configurations.public[subnet_name].index
        }
      }
    }
    
    # Private subnets with detailed information
    private_subnets = {
      for subnet_name, subnet in aws_subnet.private : subnet_name => {
        # Basic subnet information
        id                = subnet.id
        arn               = subnet.arn
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        
        # Network configuration
        network_config = {
          map_public_ip_on_launch = subnet.map_public_ip_on_launch
          assign_ipv6_address_on_creation = subnet.assign_ipv6_address_on_creation
          ipv6_cidr_block = subnet.ipv6_cidr_block
          outpost_arn     = subnet.outpost_arn
        }
        
        # Capacity and utilization
        capacity = {
          available_ip_address_count = subnet.available_ip_address_count
          ipv6_native               = subnet.ipv6_native
        }
        
        # Cross-references
        references = {
          vpc_id         = subnet.vpc_id
          route_table_id = var.network_configuration.gateways.nat_gateway.enabled ? 
            aws_route_table.private[local.subnet_configurations.private[subnet_name].index].id : 
            aws_route_table.private[0].id
          nat_gateway_id = var.network_configuration.gateways.nat_gateway.enabled ? 
            aws_nat_gateway.main[local.subnet_configurations.private[subnet_name].index].id : null
        }
        
        # Metadata
        metadata = {
          owner_id = subnet.owner_id
          tags     = subnet.tags
          index    = local.subnet_configurations.private[subnet_name].index
        }
      }
    }
    
    # Database subnets with detailed information
    database_subnets = {
      for subnet_name, subnet in aws_subnet.database : subnet_name => {
        # Basic subnet information
        id                = subnet.id
        arn               = subnet.arn
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        
        # Network configuration
        network_config = {
          map_public_ip_on_launch = subnet.map_public_ip_on_launch
          assign_ipv6_address_on_creation = subnet.assign_ipv6_address_on_creation
          ipv6_cidr_block = subnet.ipv6_cidr_block
          outpost_arn     = subnet.outpost_arn
        }
        
        # Capacity and utilization
        capacity = {
          available_ip_address_count = subnet.available_ip_address_count
          ipv6_native               = subnet.ipv6_native
        }
        
        # Cross-references
        references = {
          vpc_id = subnet.vpc_id
        }
        
        # Metadata
        metadata = {
          owner_id = subnet.owner_id
          tags     = subnet.tags
          index    = local.subnet_configurations.database[subnet_name].index
        }
      }
    }
    
    # Summary and aggregated information
    summary = {
      total_subnets = length(aws_subnet.public) + length(aws_subnet.private) + length(aws_subnet.database)
      subnet_counts = {
        public   = length(aws_subnet.public)
        private  = length(aws_subnet.private)
        database = length(aws_subnet.database)
      }
      
      # Availability zone distribution
      availability_zones = distinct(concat(
        [for subnet in aws_subnet.public : subnet.availability_zone],
        [for subnet in aws_subnet.private : subnet.availability_zone],
        [for subnet in aws_subnet.database : subnet.availability_zone]
      ))
      
      # CIDR allocation summary
      cidr_allocation = {
        vpc_cidr       = aws_vpc.main.cidr_block
        public_cidrs   = [for subnet in aws_subnet.public : subnet.cidr_block]
        private_cidrs  = [for subnet in aws_subnet.private : subnet.cidr_block]
        database_cidrs = [for subnet in aws_subnet.database : subnet.cidr_block]
      }
      
      # Network capacity analysis
      capacity_analysis = {
        total_ip_addresses = sum([
          for subnet in concat(
            values(aws_subnet.public),
            values(aws_subnet.private),
            values(aws_subnet.database)
          ) : subnet.available_ip_address_count
        ])
        
        capacity_by_tier = {
          public   = sum([for subnet in aws_subnet.public : subnet.available_ip_address_count])
          private  = sum([for subnet in aws_subnet.private : subnet.available_ip_address_count])
          database = sum([for subnet in aws_subnet.database : subnet.available_ip_address_count])
        }
      }
    }
  }
}

# Security Group Information
output "security_group_configuration" {
  description = "Security group configurations with rules and cross-references"
  value = {
    for sg_name, sg in aws_security_group.main : sg_name => {
      # Basic security group information
      id          = sg.id
      arn         = sg.arn
      name        = sg.name
      description = sg.description
      vpc_id      = sg.vpc_id
      
      # Rules information
      rules = {
        ingress_count = length(sg.ingress)
        egress_count  = length(sg.egress)
        ingress_rules = sg.ingress
        egress_rules  = sg.egress
      }
      
      # Cross-references
      references = {
        vpc_id = sg.vpc_id
        associated_resources = {
          load_balancers = [
            for app_name, app_config in local.application_configs :
            aws_lb.main[app_name].arn
            if contains(app_config.security_groups, sg_name)
          ]
          launch_templates = [
            for app_name, app_config in local.application_configs :
            aws_launch_template.main[app_name].id
            if contains(app_config.security_groups, sg_name)
          ]
        }
      }
      
      # Metadata
      metadata = {
        owner_id = sg.owner_id
        tags     = sg.tags
      }
    }
  }
}

# Application Infrastructure Outputs
output "application_infrastructure" {
  description = "Complete application infrastructure configuration and endpoints"
  value = {
    for app_name, app_config in local.application_configs : app_name => {
      # Application metadata
      metadata = {
        name         = app_config.metadata.name
        version      = app_config.metadata.version
        full_name    = app_config.full_name
        dns_name     = app_config.dns_name
        team_email   = app_config.metadata.team_email
        business_unit = app_config.metadata.business_unit
      }
      
      # Load balancer information
      load_balancer = {
        arn      = aws_lb.main[app_name].arn
        dns_name = aws_lb.main[app_name].dns_name
        zone_id  = aws_lb.main[app_name].zone_id
        
        # Endpoint URLs
        endpoints = {
          base_url         = "http://${aws_lb.main[app_name].dns_name}"
          health_check_url = "http://${aws_lb.main[app_name].dns_name}${app_config.network.health_check_path}"
          application_url  = "http://${aws_lb.main[app_name].dns_name}/"
        }
        
        # Configuration details
        configuration = {
          type                = aws_lb.main[app_name].load_balancer_type
          scheme             = aws_lb.main[app_name].scheme
          ip_address_type    = aws_lb.main[app_name].ip_address_type
          deletion_protection = aws_lb.main[app_name].enable_deletion_protection
        }
      }
      
      # Target group information
      target_group = {
        arn  = aws_lb_target_group.main[app_name].arn
        name = aws_lb_target_group.main[app_name].name
        
        # Health check configuration
        health_check = {
          enabled             = aws_lb_target_group.main[app_name].health_check[0].enabled
          healthy_threshold   = aws_lb_target_group.main[app_name].health_check[0].healthy_threshold
          unhealthy_threshold = aws_lb_target_group.main[app_name].health_check[0].unhealthy_threshold
          timeout             = aws_lb_target_group.main[app_name].health_check[0].timeout
          interval            = aws_lb_target_group.main[app_name].health_check[0].interval
          path                = aws_lb_target_group.main[app_name].health_check[0].path
          matcher             = aws_lb_target_group.main[app_name].health_check[0].matcher
        }
      }
      
      # Auto Scaling Group information
      auto_scaling_group = {
        name = aws_autoscaling_group.main[app_name].name
        arn  = aws_autoscaling_group.main[app_name].arn
        
        # Capacity configuration
        capacity = {
          min_size         = aws_autoscaling_group.main[app_name].min_size
          max_size         = aws_autoscaling_group.main[app_name].max_size
          desired_capacity = aws_autoscaling_group.main[app_name].desired_capacity
        }
        
        # Configuration details
        configuration = {
          health_check_type         = aws_autoscaling_group.main[app_name].health_check_type
          health_check_grace_period = aws_autoscaling_group.main[app_name].health_check_grace_period
          vpc_zone_identifier       = aws_autoscaling_group.main[app_name].vpc_zone_identifier
        }
      }
      
      # Launch template information
      launch_template = {
        id           = aws_launch_template.main[app_name].id
        name         = aws_launch_template.main[app_name].name
        latest_version = aws_launch_template.main[app_name].latest_version
        
        # Instance configuration
        instance_config = {
          image_id      = aws_launch_template.main[app_name].image_id
          instance_type = aws_launch_template.main[app_name].instance_type
        }
      }
      
      # Scaling policies
      scaling_policies = {
        scale_up = {
          arn  = aws_autoscaling_policy.scale_up[app_name].arn
          name = aws_autoscaling_policy.scale_up[app_name].name
        }
        scale_down = {
          arn  = aws_autoscaling_policy.scale_down[app_name].arn
          name = aws_autoscaling_policy.scale_down[app_name].name
        }
      }
      
      # CloudWatch alarms
      cloudwatch_alarms = {
        cpu_high = {
          arn  = aws_cloudwatch_metric_alarm.cpu_high[app_name].arn
          name = aws_cloudwatch_metric_alarm.cpu_high[app_name].alarm_name
        }
        cpu_low = {
          arn  = aws_cloudwatch_metric_alarm.cpu_low[app_name].arn
          name = aws_cloudwatch_metric_alarm.cpu_low[app_name].alarm_name
        }
      }
    }
  }
}

# Performance and Cost Analysis Outputs
output "performance_analysis" {
  description = "Performance metrics and analysis for infrastructure optimization"
  value = {
    # Computed performance metrics from locals
    performance_metrics = local.performance_metrics

    # Resource utilization analysis
    resource_utilization = {
      # Compute utilization
      compute = {
        total_instances = sum([
          for app_name, app_config in local.application_configs :
          app_config.adjusted_capacity.desired
        ])

        instance_distribution = {
          for app_name, app_config in local.application_configs :
          app_name => {
            instance_type = app_config.adjusted_instance_type
            count        = app_config.adjusted_capacity.desired
            cpu_units    = app_config.adjusted_capacity.desired * lookup({
              "t3.micro"  = 2, "t3.small"  = 2, "t3.medium" = 2, "t3.large"  = 2, "t3.xlarge" = 4,
              "m5.large"  = 2, "m5.xlarge" = 4, "c5.large"  = 2, "c5.xlarge" = 4
            }, app_config.adjusted_instance_type, 2)
            memory_gb = app_config.adjusted_capacity.desired * lookup({
              "t3.micro"  = 1, "t3.small"  = 2, "t3.medium" = 4, "t3.large"  = 8, "t3.xlarge" = 16,
              "m5.large"  = 8, "m5.xlarge" = 16, "c5.large" = 4, "c5.xlarge" = 8
            }, app_config.adjusted_instance_type, 4)
          }
        }
      }

      # Network utilization
      network = {
        total_subnets = length(aws_subnet.public) + length(aws_subnet.private) + length(aws_subnet.database)
        availability_zones_used = length(distinct(concat(
          [for subnet in aws_subnet.public : subnet.availability_zone],
          [for subnet in aws_subnet.private : subnet.availability_zone],
          [for subnet in aws_subnet.database : subnet.availability_zone]
        )))

        load_balancers = {
          count = length(aws_lb.main)
          types = distinct([for lb in aws_lb.main : lb.load_balancer_type])
        }
      }

      # Security utilization
      security = {
        security_groups_count = length(aws_security_group.main)
        total_security_rules = sum([
          for sg in aws_security_group.main :
          length(sg.ingress) + length(sg.egress)
        ])
      }
    }

    # Capacity planning recommendations
    capacity_planning = {
      for app_name, app_config in local.application_configs :
      app_name => {
        current_capacity = app_config.adjusted_capacity.desired
        recommended_capacity = {
          min_recommended = max(1, app_config.adjusted_capacity.min)
          max_recommended = local.environment == "prod" ?
            app_config.adjusted_capacity.max :
            min(5, app_config.adjusted_capacity.max)
        }

        scaling_recommendations = {
          enable_predictive_scaling = local.environment == "prod"
          target_cpu_utilization = local.environment == "prod" ? 70 : 80
          scale_up_threshold = "Consider scaling up when CPU > 80% for 5 minutes"
          scale_down_threshold = "Consider scaling down when CPU < 30% for 10 minutes"
        }
      }
    }
  }
}

# Cost Analysis and Optimization Outputs
output "cost_analysis" {
  description = "Comprehensive cost analysis and optimization recommendations"
  value = {
    # Cost analysis from locals
    cost_breakdown = local.cost_analysis

    # Monthly cost projections
    monthly_projections = {
      current_month = {
        total_cost = local.cost_analysis.total_monthly_cost
        cost_by_category = local.cost_analysis.cost_breakdown
        cost_per_application = {
          for app_name, costs in local.cost_analysis.application_costs :
          app_name => costs.total_monthly_cost
        }
      }

      # Projected costs for different scenarios
      scenarios = {
        scale_up_20_percent = {
          description = "20% increase in capacity"
          projected_cost = local.cost_analysis.total_monthly_cost * 1.2
          impact = "Moderate cost increase with improved performance"
        }

        scale_down_30_percent = {
          description = "30% reduction in capacity"
          projected_cost = local.cost_analysis.total_monthly_cost * 0.7
          impact = "Significant cost savings with potential performance impact"
        }

        production_upgrade = {
          description = "Upgrade to production-grade instances"
          projected_cost = local.cost_analysis.total_monthly_cost * 2.5
          impact = "Higher costs but production-ready performance and reliability"
        }
      }
    }

    # Cost optimization recommendations
    optimization_recommendations = {
      immediate_actions = compact([
        local.environment == "dev" && var.network_configuration.gateways.nat_gateway.enabled ?
          "Disable NAT Gateway in development to save $45/month" : null,

        length([for app_name, app_config in local.application_configs : app_name if app_config.adjusted_instance_type == "t3.micro"]) > 0 && local.environment == "prod" ?
          "Upgrade t3.micro instances to t3.small for production workloads" : null,

        "Consider using Spot Instances for non-critical workloads to save 50-90%"
      ])

      medium_term_actions = [
        "Implement auto-scaling policies to optimize capacity utilization",
        "Consider Reserved Instances for predictable workloads (up to 75% savings)",
        "Evaluate storage types and sizes for cost optimization"
      ]

      long_term_actions = [
        "Implement cost allocation tags for detailed cost tracking",
        "Consider multi-region deployment for disaster recovery",
        "Evaluate containerization for improved resource utilization"
      ]
    }

    # Budget and alerting recommendations
    budget_recommendations = {
      monthly_budget_limit = local.cost_analysis.total_monthly_cost * 1.2
      alert_thresholds = {
        warning = local.cost_analysis.total_monthly_cost * 0.8
        critical = local.cost_analysis.total_monthly_cost * 1.0
      }

      cost_controls = {
        enable_budget_alerts = true
        enable_cost_anomaly_detection = local.environment == "prod"
        enable_rightsizing_recommendations = true
      }
    }
  }
}

# Cross-Module Integration Outputs
output "module_integration" {
  description = "Structured outputs for cross-module integration and external system connectivity"
  value = {
    # Network module outputs for other modules
    network = {
      vpc_id             = aws_vpc.main.id
      vpc_cidr_block     = aws_vpc.main.cidr_block
      public_subnet_ids  = [for subnet in aws_subnet.public : subnet.id]
      private_subnet_ids = [for subnet in aws_subnet.private : subnet.id]
      database_subnet_ids = [for subnet in aws_subnet.database : subnet.id]

      # Security group IDs for reference
      security_group_ids = {
        for sg_name, sg in aws_security_group.main :
        sg_name => sg.id
      }

      # Route table IDs
      route_table_ids = {
        public = aws_route_table.public.id
        private = var.network_configuration.gateways.nat_gateway.enabled ?
          [for rt in aws_route_table.private : rt.id] :
          [aws_route_table.private[0].id]
      }

      # Gateway information
      gateways = {
        internet_gateway_id = var.network_configuration.gateways.internet_gateway.enabled ? aws_internet_gateway.main[0].id : null
        nat_gateway_ids = var.network_configuration.gateways.nat_gateway.enabled ?
          [for nat in aws_nat_gateway.main : nat.id] : []
      }
    }

    # Application module outputs for monitoring and logging
    applications = {
      for app_name, app_config in local.application_configs : app_name => {
        # Load balancer information for DNS and CDN configuration
        load_balancer = {
          dns_name = aws_lb.main[app_name].dns_name
          zone_id  = aws_lb.main[app_name].zone_id
          arn      = aws_lb.main[app_name].arn
        }

        # Auto Scaling Group for monitoring integration
        auto_scaling_group = {
          name = aws_autoscaling_group.main[app_name].name
          arn  = aws_autoscaling_group.main[app_name].arn
        }

        # Target group for health monitoring
        target_group = {
          arn  = aws_lb_target_group.main[app_name].arn
          name = aws_lb_target_group.main[app_name].name
        }

        # CloudWatch alarms for external monitoring systems
        alarms = {
          cpu_high_arn = aws_cloudwatch_metric_alarm.cpu_high[app_name].arn
          cpu_low_arn  = aws_cloudwatch_metric_alarm.cpu_low[app_name].arn
        }
      }
    }

    # Security module inputs
    security = {
      vpc_cidr_block = aws_vpc.main.cidr_block
      subnet_cidrs = {
        public   = [for subnet in aws_subnet.public : subnet.cidr_block]
        private  = [for subnet in aws_subnet.private : subnet.cidr_block]
        database = [for subnet in aws_subnet.database : subnet.cidr_block]
      }

      # Security group configurations for compliance checking
      security_groups = {
        for sg_name, sg in aws_security_group.main :
        sg_name => {
          id = sg.id
          ingress_rules_count = length(sg.ingress)
          egress_rules_count = length(sg.egress)
        }
      }
    }

    # Monitoring module inputs
    monitoring = {
      # Resources to monitor
      resources_to_monitor = {
        load_balancers = [for lb in aws_lb.main : lb.arn]
        auto_scaling_groups = [for asg in aws_autoscaling_group.main : asg.arn]
        target_groups = [for tg in aws_lb_target_group.main : tg.arn]
      }

      # Existing alarms
      existing_alarms = {
        for app_name in keys(local.application_configs) : app_name => {
          cpu_high = aws_cloudwatch_metric_alarm.cpu_high[app_name].arn
          cpu_low  = aws_cloudwatch_metric_alarm.cpu_low[app_name].arn
        }
      }
    }
  }
}

# Governance and Compliance Outputs
output "governance_compliance" {
  description = "Governance, compliance, and audit information for enterprise oversight"
  value = {
    # Resource inventory for compliance tracking
    resource_inventory = {
      total_resources = (
        1 + # VPC
        (var.network_configuration.gateways.internet_gateway.enabled ? 1 : 0) + # Internet Gateway
        length(aws_subnet.public) + length(aws_subnet.private) + length(aws_subnet.database) + # Subnets
        (var.network_configuration.gateways.nat_gateway.enabled ? length(aws_nat_gateway.main) : 0) + # NAT Gateways
        length(aws_security_group.main) + # Security Groups
        length(aws_lb.main) + # Load Balancers
        length(aws_autoscaling_group.main) + # Auto Scaling Groups
        length(aws_launch_template.main) # Launch Templates
      )

      resource_counts = {
        vpc_count                = 1
        internet_gateway_count   = var.network_configuration.gateways.internet_gateway.enabled ? 1 : 0
        subnet_count            = length(aws_subnet.public) + length(aws_subnet.private) + length(aws_subnet.database)
        nat_gateway_count       = var.network_configuration.gateways.nat_gateway.enabled ? length(aws_nat_gateway.main) : 0
        security_group_count    = length(aws_security_group.main)
        load_balancer_count     = length(aws_lb.main)
        auto_scaling_group_count = length(aws_autoscaling_group.main)
        launch_template_count   = length(aws_launch_template.main)
      }
    }

    # Compliance status
    compliance_status = {
      # Security compliance
      security_compliance = {
        encryption_enabled = alltrue([
          for app_name, app_config in local.application_configs :
          app_config.infrastructure.storage.root_volume_encrypted
        ])

        security_groups_configured = length(aws_security_group.main) > 0

        network_isolation = {
          private_subnets_exist = length(aws_subnet.private) > 0
          database_subnets_isolated = length(aws_subnet.database) > 0
        }
      }

      # Governance compliance
      governance_compliance = {
        resource_tagging = {
          all_resources_tagged = true # Enforced by default_tags
          required_tags_present = [
            "Environment", "Project", "ManagedBy", "CostCenter",
            "DataClassification", "ComplianceLevel"
          ]
        }

        change_management = {
          approval_required = var.organization_config.governance.change_approval_required
          audit_logging_enabled = var.organization_config.governance.audit_logging_enabled
        }
      }

      # Cost compliance
      cost_compliance = {
        budget_monitoring = var.organization_config.cost_management.budget_alerts_enabled
        cost_optimization = var.organization_config.cost_management.cost_optimization
        resource_rightsizing = var.organization_config.cost_management.rightsizing_enabled
      }
    }

    # Audit trail information
    audit_information = {
      deployment_metadata = {
        environment = local.environment
        region = local.region
        account_id = local.account_id
        deployment_time = timestamp()
        terraform_version = "~> 1.13.0"
        lab_version = "5.1"
      }

      configuration_summary = {
        organization_name = var.organization_config.name
        compliance_level = var.organization_config.compliance_level
        data_classification = var.organization_config.data_classification
        security_baseline_enabled = var.organization_config.security_baseline.encryption_required
      }

      change_tracking = {
        configuration_hash = md5(jsonencode({
          organization_config = var.organization_config
          network_configuration = var.network_configuration
          applications = var.applications
        }))

        last_modified = timestamp()
        change_approval_required = var.organization_config.governance.change_approval_required
      }
    }
  }

  # Mark as sensitive if contains compliance-sensitive information
  sensitive = var.organization_config.data_classification == "restricted"
}
