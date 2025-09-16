# Terraform Code Lab 5.1: Advanced Variables and Outputs
# Local Values and Computed Expressions
#
# This file demonstrates advanced local value patterns including performance
# optimization, complex data transformations, conditional logic, and enterprise
# governance patterns for large-scale infrastructure deployments.

locals {
  # Basic computed values for reuse across configuration
  environment = var.environment
  region      = data.aws_region.current.name
  account_id  = data.aws_caller_identity.current.account_id
  partition   = data.aws_partition.current.partition
  
  # Resource naming conventions
  name_prefix = "${local.environment}-${replace(lower(var.organization_config.name), " ", "-")}"
  
  # Common tags applied to all resources
  common_tags = {
    Environment = local.environment
    Project     = var.organization_config.name
    ManagedBy   = "terraform"
    Region      = local.region
    Account     = local.account_id
    
    # Governance tags
    CostCenter         = var.organization_config.cost_center_default
    DataClassification = var.organization_config.data_classification
    ComplianceLevel    = var.organization_config.compliance_level
    
    # Operational tags
    CreatedDate        = formatdate("YYYY-MM-DD", timestamp())
    TerraformConfig    = "variables-outputs-lab"
    LabVersion         = "5.1"
    
    # Change management tags
    ChangeApprovalRequired = tostring(var.organization_config.governance.change_approval_required)
    AuditLoggingEnabled   = tostring(var.organization_config.governance.audit_logging_enabled)
  }
  
  # Network configuration with computed values
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  az_count          = length(local.availability_zones)
  
  # Computed subnet configurations
  subnet_configurations = {
    # Public subnets with computed CIDRs
    public = {
      for i, subnet in var.network_configuration.subnets.public :
      subnet.name => merge(subnet, {
        index             = i
        computed_cidr     = cidrsubnet(var.network_configuration.vpc.cidr_block, 8, i)
        route_table_type  = "public"
        nat_gateway_required = false
        
        # Tags for subnet
        tags = merge(local.common_tags, {
          Name = "${local.name_prefix}-${subnet.name}"
          Type = "public"
          Tier = "web"
          AZ   = subnet.availability_zone
        })
      })
    }
    
    # Private subnets with computed CIDRs
    private = {
      for i, subnet in var.network_configuration.subnets.private :
      subnet.name => merge(subnet, {
        index             = i
        computed_cidr     = cidrsubnet(var.network_configuration.vpc.cidr_block, 8, i + 10)
        route_table_type  = "private"
        nat_gateway_required = var.network_configuration.gateways.nat_gateway.enabled
        
        # Tags for subnet
        tags = merge(local.common_tags, {
          Name = "${local.name_prefix}-${subnet.name}"
          Type = "private"
          Tier = "application"
          AZ   = subnet.availability_zone
        })
      })
    }
    
    # Database subnets with computed CIDRs
    database = {
      for i, subnet in var.network_configuration.subnets.database :
      subnet.name => merge(subnet, {
        index             = i
        computed_cidr     = cidrsubnet(var.network_configuration.vpc.cidr_block, 8, i + 20)
        route_table_type  = "private"
        nat_gateway_required = false
        
        # Tags for subnet
        tags = merge(local.common_tags, {
          Name = "${local.name_prefix}-${subnet.name}"
          Type = "database"
          Tier = "data"
          AZ   = subnet.availability_zone
        })
      })
    }
  }
  
  # Application configurations with environment-specific overrides
  application_configs = {
    for app_name, app_config in var.applications :
    app_name => merge(app_config, {
      # Computed application metadata
      full_name = "${local.name_prefix}-${app_config.metadata.name}"
      dns_name  = lower(replace(replace(app_config.metadata.name, "_", "-"), " ", "-"))
      
      # Environment-specific instance type adjustments
      adjusted_instance_type = lookup({
        dev     = "t3.micro"
        staging = "t3.small"
        prod    = app_config.infrastructure.instance_type
      }, local.environment, app_config.infrastructure.instance_type)
      
      # Environment-specific capacity adjustments
      adjusted_capacity = {
        min     = local.environment == "prod" ? app_config.infrastructure.min_capacity : max(1, app_config.infrastructure.min_capacity - 1)
        max     = local.environment == "prod" ? app_config.infrastructure.max_capacity : min(5, app_config.infrastructure.max_capacity)
        desired = local.environment == "prod" ? app_config.infrastructure.desired_capacity : max(1, app_config.infrastructure.desired_capacity - 1)
      }
      
      # Security group assignments based on environment
      security_groups = concat(
        app_config.network.security_groups,
        local.environment == "prod" ? ["monitoring", "backup", "compliance"] : [],
        var.organization_config.security_baseline.security_monitoring ? ["security-monitoring"] : []
      )
      
      # Monitoring configuration based on environment
      monitoring_config = merge(app_config.monitoring, {
        detailed_monitoring = local.environment == "prod" ? true : app_config.monitoring.enable_detailed_monitoring
        log_retention      = local.environment == "prod" ? 90 : app_config.monitoring.log_retention_days
        alerting_enabled   = local.environment != "dev"
      })
      
      # Backup configuration based on environment and compliance
      backup_config = {
        enabled = local.environment == "prod" || var.organization_config.compliance_level == "high"
        retention_days = local.environment == "prod" ? 30 : 7
        cross_region = local.environment == "prod" && var.organization_config.compliance_level == "critical"
      }
      
      # Compliance configuration
      compliance_config = merge(app_config.compliance, {
        audit_required = local.environment == "prod" || var.organization_config.compliance_level != "low"
        encryption_required = var.organization_config.security_baseline.encryption_required || app_config.security.enable_encryption
        monitoring_required = var.organization_config.security_baseline.security_monitoring
      })
      
      # Resource tags
      tags = merge(local.common_tags, {
        Application = app_config.metadata.name
        Version     = app_config.metadata.version
        Team        = app_config.metadata.team_email
        BusinessUnit = app_config.metadata.business_unit
        Component   = "application"
      })
    })
  }
  
  # Security group configurations with dynamic rules
  security_group_configs = {
    # Web security group
    web = {
      name        = "${local.name_prefix}-web-sg"
      description = "Security group for web tier"
      
      ingress_rules = concat(
        # Standard web traffic
        [
          {
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "HTTP traffic"
          },
          {
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "HTTPS traffic"
          }
        ],
        # Development-specific rules
        local.environment == "dev" ? [
          {
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["10.0.0.0/16"]
            description = "SSH access for development"
          }
        ] : []
      )
      
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
      
      tags = merge(local.common_tags, {
        Name = "${local.name_prefix}-web-sg"
        Tier = "web"
        Type = "security-group"
      })
    }
    
    # Common security group for shared services
    common = {
      name        = "${local.name_prefix}-common-sg"
      description = "Common security group for shared services"
      
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = [var.network_configuration.vpc.cidr_block]
          description = "Internal HTTP traffic"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = [var.network_configuration.vpc.cidr_block]
          description = "Internal HTTPS traffic"
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
      
      tags = merge(local.common_tags, {
        Name = "${local.name_prefix}-common-sg"
        Tier = "common"
        Type = "security-group"
      })
    }
  }
  
  # Performance and cost optimization calculations
  performance_metrics = {
    # Total compute capacity across all applications
    total_cpu_units = sum([
      for app_name, app_config in local.application_configs :
      app_config.adjusted_capacity.desired * lookup({
        "t3.micro"  = 2
        "t3.small"  = 2
        "t3.medium" = 2
        "t3.large"  = 2
        "t3.xlarge" = 4
        "m5.large"  = 2
        "m5.xlarge" = 4
        "c5.large"  = 2
        "c5.xlarge" = 4
      }, app_config.adjusted_instance_type, 2)
    ])
    
    # Total memory capacity
    total_memory_gb = sum([
      for app_name, app_config in local.application_configs :
      app_config.adjusted_capacity.desired * lookup({
        "t3.micro"  = 1
        "t3.small"  = 2
        "t3.medium" = 4
        "t3.large"  = 8
        "t3.xlarge" = 16
        "m5.large"  = 8
        "m5.xlarge" = 16
        "c5.large"  = 4
        "c5.xlarge" = 8
      }, app_config.adjusted_instance_type, 4)
    ])
    
    # Network bandwidth estimation
    estimated_bandwidth_mbps = sum([
      for app_name, app_config in local.application_configs :
      app_config.adjusted_capacity.desired * lookup({
        "t3.micro"  = 100
        "t3.small"  = 200
        "t3.medium" = 400
        "t3.large"  = 800
        "t3.xlarge" = 1600
        "m5.large"  = 800
        "m5.xlarge" = 1600
        "c5.large"  = 800
        "c5.xlarge" = 1600
      }, app_config.adjusted_instance_type, 400)
    ])
  }
  
  # Cost analysis and optimization
  cost_analysis = {
    # Per-application monthly cost estimates
    application_costs = {
      for app_name, app_config in local.application_configs :
      app_name => {
        # Compute costs
        monthly_compute_cost = app_config.adjusted_capacity.desired * lookup({
          "t3.micro"  = 8.76
          "t3.small"  = 17.52
          "t3.medium" = 35.04
          "t3.large"  = 70.08
          "t3.xlarge" = 140.16
          "m5.large"  = 96.00
          "m5.xlarge" = 192.00
          "c5.large"  = 85.50
          "c5.xlarge" = 171.00
        }, app_config.adjusted_instance_type, 35.04)
        
        # Storage costs
        monthly_storage_cost = app_config.infrastructure.storage.root_volume_size * 0.10
        
        # Load balancer costs
        monthly_lb_cost = app_config.network.load_balancer_type == "application" ? 22.50 : 18.00
        
        # Monitoring costs (if enabled)
        monthly_monitoring_cost = app_config.monitoring_config.detailed_monitoring ? 10.00 : 0.00
        
        # Total monthly cost
        total_monthly_cost = (
          app_config.adjusted_capacity.desired * lookup({
            "t3.micro"  = 8.76
            "t3.small"  = 17.52
            "t3.medium" = 35.04
            "t3.large"  = 70.08
            "t3.xlarge" = 140.16
            "m5.large"  = 96.00
            "m5.xlarge" = 192.00
            "c5.large"  = 85.50
            "c5.xlarge" = 171.00
          }, app_config.adjusted_instance_type, 35.04) +
          app_config.infrastructure.storage.root_volume_size * 0.10 +
          (app_config.network.load_balancer_type == "application" ? 22.50 : 18.00) +
          (app_config.monitoring_config.detailed_monitoring ? 10.00 : 0.00)
        )
      }
    }
    
    # Total infrastructure costs
    total_monthly_cost = sum([
      for app_name, costs in local.cost_analysis.application_costs :
      costs.total_monthly_cost
    ])
    
    # Cost breakdown by category
    cost_breakdown = {
      compute = sum([
        for app_name, costs in local.cost_analysis.application_costs :
        costs.monthly_compute_cost
      ])
      storage = sum([
        for app_name, costs in local.cost_analysis.application_costs :
        costs.monthly_storage_cost
      ])
      load_balancers = sum([
        for app_name, costs in local.cost_analysis.application_costs :
        costs.monthly_lb_cost
      ])
      monitoring = sum([
        for app_name, costs in local.cost_analysis.application_costs :
        costs.monthly_monitoring_cost
      ])
    }
    
    # Cost optimization recommendations
    optimization_recommendations = {
      for app_name, app_config in local.application_configs :
      app_name => {
        # Instance type optimization
        instance_optimization = app_config.adjusted_instance_type == "t3.micro" && local.environment == "prod" ? 
          "Consider upgrading to t3.small for production workloads" : 
          "Instance type appropriate for environment"
        
        # Capacity optimization
        capacity_optimization = app_config.adjusted_capacity.desired > app_config.adjusted_capacity.min + 2 ?
          "Consider reducing desired capacity to optimize costs" :
          "Capacity configuration is optimal"
        
        # Storage optimization
        storage_optimization = app_config.infrastructure.storage.root_volume_size > 50 ?
          "Consider using separate data volumes for large storage requirements" :
          "Storage configuration is optimal"
      }
    }
  }
  
  # Feature flags based on environment and configuration
  feature_flags = {
    # Monitoring features
    enable_detailed_monitoring = local.environment != "dev"
    enable_container_insights  = local.environment == "prod"
    enable_xray_tracing       = local.environment != "dev"
    
    # Security features
    enable_waf                = local.environment == "prod"
    enable_ddos_protection    = local.environment == "prod" && var.organization_config.compliance_level == "critical"
    enable_guardduty          = var.organization_config.security_baseline.security_monitoring
    enable_config             = local.environment != "dev"
    
    # Backup and recovery features
    enable_automated_backups  = local.environment != "dev"
    enable_cross_region_backup = local.environment == "prod"
    enable_point_in_time_recovery = local.environment == "prod"
    
    # Performance features
    enable_auto_scaling       = true
    enable_predictive_scaling = local.environment == "prod"
    enable_performance_insights = local.environment != "dev"
    
    # Compliance features
    enable_audit_logging      = var.organization_config.governance.audit_logging_enabled
    enable_compliance_scanning = var.organization_config.governance.compliance_scanning
    enable_policy_enforcement = var.organization_config.governance.policy_enforcement
  }
}
