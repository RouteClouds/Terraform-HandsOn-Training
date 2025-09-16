# AWS Terraform Training - Topic 4: Resource Management & Dependencies
# Terraform Code Lab 4.1 - Output Definitions
#
# This file defines comprehensive outputs for the Resource Management & Dependencies
# lab, demonstrating advanced output patterns, dependency relationships, and
# structured data for integration with other systems and modules.

# ============================================================================
# ENVIRONMENT AND PROJECT INFORMATION
# ============================================================================

output "environment_info" {
  description = "Environment and project information"
  value = {
    environment = local.environment
    project     = local.project
    region      = local.region
    account_id  = local.account_id
    name_prefix = local.name_prefix
  }
}

output "deployment_metadata" {
  description = "Deployment metadata and timestamps"
  value = {
    terraform_version = "~> 1.13.0"
    provider_version  = "~> 6.12.0"
    deployment_time   = timestamp()
    lab_version       = "4.1"
    lab_topic         = "resource-management-dependencies"
  }
}

# ============================================================================
# NETWORK INFRASTRUCTURE OUTPUTS
# ============================================================================

output "network_configuration" {
  description = "Complete network infrastructure configuration"
  value = {
    vpc = {
      id         = aws_vpc.main.id
      arn        = aws_vpc.main.arn
      cidr_block = aws_vpc.main.cidr_block
      dns_support = aws_vpc.main.enable_dns_support
      dns_hostnames = aws_vpc.main.enable_dns_hostnames
    }
    
    internet_gateway = {
      id  = aws_internet_gateway.main.id
      arn = aws_internet_gateway.main.arn
    }
    
    subnets = {
      public = [
        for i, subnet in aws_subnet.public : {
          id                = subnet.id
          arn               = subnet.arn
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
          index             = i
        }
      ]
      private = [
        for i, subnet in aws_subnet.private : {
          id                = subnet.id
          arn               = subnet.arn
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
          index             = i
        }
      ]
      database = [
        for i, subnet in aws_subnet.database : {
          id                = subnet.id
          arn               = subnet.arn
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
          index             = i
        }
      ]
    }
    
    nat_gateways = var.enable_nat_gateway ? [
      for i, nat in aws_nat_gateway.main : {
        id                = nat.id
        allocation_id     = nat.allocation_id
        subnet_id         = nat.subnet_id
        availability_zone = local.availability_zones[i]
        public_ip         = aws_eip.nat[i].public_ip
      }
    ] : []
    
    route_tables = {
      public = {
        id     = aws_route_table.public.id
        arn    = aws_route_table.public.arn
        routes = aws_route_table.public.route
      }
      private = [
        for i, rt in aws_route_table.private : {
          id     = rt.id
          arn    = rt.arn
          routes = rt.route
          index  = i
        }
      ]
    }
  }
}

# ============================================================================
# SECURITY INFRASTRUCTURE OUTPUTS
# ============================================================================

output "security_configuration" {
  description = "Security groups and rules configuration"
  value = {
    security_groups = {
      for sg_name, sg in aws_security_group.main : sg_name => {
        id          = sg.id
        arn         = sg.arn
        name        = sg.name
        description = sg.description
        vpc_id      = sg.vpc_id
        ingress     = sg.ingress
        egress      = sg.egress
      }
    }
    
    cross_sg_rules = {
      web_from_alb = {
        id                       = aws_security_group_rule.web_from_alb.id
        type                     = aws_security_group_rule.web_from_alb.type
        from_port                = aws_security_group_rule.web_from_alb.from_port
        to_port                  = aws_security_group_rule.web_from_alb.to_port
        protocol                 = aws_security_group_rule.web_from_alb.protocol
        source_security_group_id = aws_security_group_rule.web_from_alb.source_security_group_id
        security_group_id        = aws_security_group_rule.web_from_alb.security_group_id
      }
      api_from_worker = {
        id                       = aws_security_group_rule.api_from_worker.id
        type                     = aws_security_group_rule.api_from_worker.type
        from_port                = aws_security_group_rule.api_from_worker.from_port
        to_port                  = aws_security_group_rule.api_from_worker.to_port
        protocol                 = aws_security_group_rule.api_from_worker.protocol
        source_security_group_id = aws_security_group_rule.api_from_worker.source_security_group_id
        security_group_id        = aws_security_group_rule.api_from_worker.security_group_id
      }
    }
  }
}

output "encryption_configuration" {
  description = "KMS keys and encryption configuration"
  value = {
    database_kms = {
      key_id     = aws_kms_key.database.key_id
      arn        = aws_kms_key.database.arn
      alias_name = aws_kms_alias.database.name
      alias_arn  = aws_kms_alias.database.arn
    }
    
    backup_kms = local.resolved_feature_flags.enable_backup ? {
      key_id     = aws_kms_key.backup[0].key_id
      arn        = aws_kms_key.backup[0].arn
      alias_name = aws_kms_alias.backup[0].name
      alias_arn  = aws_kms_alias.backup[0].arn
    } : null
  }
}

# ============================================================================
# DATABASE INFRASTRUCTURE OUTPUTS
# ============================================================================

output "database_configuration" {
  description = "Database infrastructure configuration"
  value = {
    rds_instance = {
      id                = aws_db_instance.main.id
      arn               = aws_db_instance.main.arn
      endpoint          = aws_db_instance.main.endpoint
      port              = aws_db_instance.main.port
      engine            = aws_db_instance.main.engine
      engine_version    = aws_db_instance.main.engine_version
      instance_class    = aws_db_instance.main.instance_class
      allocated_storage = aws_db_instance.main.allocated_storage
      multi_az          = aws_db_instance.main.multi_az
      encrypted         = aws_db_instance.main.storage_encrypted
      kms_key_id        = aws_db_instance.main.kms_key_id
    }
    
    subnet_group = {
      id         = aws_db_subnet_group.main.id
      arn        = aws_db_subnet_group.main.arn
      name       = aws_db_subnet_group.main.name
      subnet_ids = aws_db_subnet_group.main.subnet_ids
    }
    
    connection = {
      endpoint = aws_db_instance.main.endpoint
      port     = aws_db_instance.main.port
      database = aws_db_instance.main.db_name
      username = aws_db_instance.main.username
    }
  }
  
  sensitive = true  # Mark as sensitive due to connection information
}

output "cache_configuration" {
  description = "ElastiCache configuration (if enabled)"
  value = local.resolved_feature_flags.enable_redis_cache ? {
    cluster = {
      id                = aws_elasticache_cluster.main[0].cluster_id
      arn               = aws_elasticache_cluster.main[0].arn
      engine            = aws_elasticache_cluster.main[0].engine
      node_type         = aws_elasticache_cluster.main[0].node_type
      port              = aws_elasticache_cluster.main[0].port
      cache_nodes       = aws_elasticache_cluster.main[0].cache_nodes
    }
    
    subnet_group = {
      name       = aws_elasticache_subnet_group.main[0].name
      subnet_ids = aws_elasticache_subnet_group.main[0].subnet_ids
    }
    
    connection = {
      endpoint = aws_elasticache_cluster.main[0].cache_nodes[0].address
      port     = aws_elasticache_cluster.main[0].port
    }
  } : null
}

# ============================================================================
# APPLICATION INFRASTRUCTURE OUTPUTS
# ============================================================================

output "application_configuration" {
  description = "Application infrastructure configuration"
  value = {
    launch_templates = {
      for app_name, template in aws_launch_template.apps : app_name => {
        id            = template.id
        arn           = template.arn
        name          = template.name
        latest_version = template.latest_version
        image_id      = template.image_id
        instance_type = template.instance_type
      }
    }
    
    auto_scaling_groups = {
      for app_name, asg in aws_autoscaling_group.apps : app_name => {
        id               = asg.id
        arn              = asg.arn
        name             = asg.name
        min_size         = asg.min_size
        max_size         = asg.max_size
        desired_capacity = asg.desired_capacity
        vpc_zone_identifier = asg.vpc_zone_identifier
        target_group_arns = asg.target_group_arns
      }
    }
    
    target_groups = {
      for app_name, tg in aws_lb_target_group.apps : app_name => {
        id       = tg.id
        arn      = tg.arn
        name     = tg.name
        port     = tg.port
        protocol = tg.protocol
        vpc_id   = tg.vpc_id
      }
    }
  }
}

output "load_balancer_configuration" {
  description = "Load balancer configuration and endpoints"
  value = {
    load_balancer = {
      id               = aws_lb.main.id
      arn              = aws_lb.main.arn
      name             = aws_lb.main.name
      dns_name         = aws_lb.main.dns_name
      zone_id          = aws_lb.main.zone_id
      type             = aws_lb.main.load_balancer_type
      scheme           = aws_lb.main.internal ? "internal" : "internet-facing"
      security_groups  = aws_lb.main.security_groups
      subnets          = aws_lb.main.subnets
    }
    
    endpoints = {
      public_url = "http://${aws_lb.main.dns_name}"
      health_check_urls = {
        for app_name, app_config in local.resolved_applications :
        app_name => "http://${aws_lb.main.dns_name}${app_config.health_check_path}"
      }
    }
  }
}

# ============================================================================
# DEPENDENCY ANALYSIS OUTPUTS
# ============================================================================

output "dependency_analysis" {
  description = "Dependency relationships and analysis"
  value = {
    dependency_order = local.dependency_order
    
    resource_counts = {
      total_resources = length([
        aws_vpc.main,
        aws_internet_gateway.main,
        aws_subnet.public,
        aws_subnet.private,
        aws_subnet.database,
        aws_security_group.main,
        aws_db_instance.main,
        aws_launch_template.apps,
        aws_autoscaling_group.apps,
        aws_lb.main
      ])
      
      by_tier = {
        foundation  = 1 + length(aws_subnet.public) + length(aws_subnet.private) + length(aws_subnet.database)
        security    = length(aws_security_group.main)
        data        = 1 + (local.resolved_feature_flags.enable_redis_cache ? 1 : 0)
        application = length(aws_launch_template.apps) + length(aws_autoscaling_group.apps) + 1
      }
    }
    
    implicit_dependencies = {
      vpc_dependencies = [
        "aws_subnet.public",
        "aws_subnet.private", 
        "aws_subnet.database",
        "aws_security_group.main"
      ]
      
      subnet_dependencies = [
        "aws_nat_gateway.main",
        "aws_db_subnet_group.main",
        "aws_autoscaling_group.apps"
      ]
      
      security_group_dependencies = [
        "aws_launch_template.apps",
        "aws_lb.main"
      ]
    }
    
    explicit_dependencies = {
      database = [
        "aws_db_subnet_group.main",
        "aws_security_group.main",
        "aws_kms_key.database"
      ]
      
      auto_scaling_groups = [
        "aws_db_instance.main",
        "aws_lb_target_group.apps",
        "aws_launch_template.apps"
      ]
    }
  }
}

# ============================================================================
# FEATURE FLAGS AND CONDITIONAL OUTPUTS
# ============================================================================

output "feature_flags_status" {
  description = "Status of feature flags and conditional resources"
  value = {
    resolved_flags = local.resolved_feature_flags
    
    conditional_resources = {
      nat_gateway_enabled    = var.enable_nat_gateway
      redis_cache_created    = local.resolved_feature_flags.enable_redis_cache
      backup_resources_created = local.resolved_feature_flags.enable_backup
      monitoring_enabled     = local.current_config.monitoring_enabled
    }
    
    environment_overrides = {
      original_flags = var.feature_flags
      environment_config = local.current_config
      resolved_flags = local.resolved_feature_flags
    }
  }
}

# ============================================================================
# INTEGRATION AND CONNECTIVITY OUTPUTS
# ============================================================================

output "integration_endpoints" {
  description = "Endpoints and connection information for integration"
  value = {
    database_endpoint = aws_db_instance.main.endpoint
    cache_endpoint    = local.resolved_feature_flags.enable_redis_cache ? aws_elasticache_cluster.main[0].cache_nodes[0].address : null
    load_balancer_dns = aws_lb.main.dns_name
    
    application_urls = {
      for app_name, app_config in local.resolved_applications :
      app_name => "http://${aws_lb.main.dns_name}${app_config.health_check_path}"
    }
    
    vpc_endpoints = {
      vpc_id = aws_vpc.main.id
      public_subnet_ids = aws_subnet.public[*].id
      private_subnet_ids = aws_subnet.private[*].id
      database_subnet_ids = aws_subnet.database[*].id
    }
  }
  
  sensitive = true  # Mark as sensitive due to endpoint information
}
