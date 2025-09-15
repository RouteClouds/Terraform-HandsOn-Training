# AWS Terraform Training - Resource Management & Dependencies
# Lab 4.1: Advanced Resource Dependencies and Meta-Arguments
# File: outputs.tf - Comprehensive Output Definitions for Dependency Analysis

# ============================================================================
# INFRASTRUCTURE OVERVIEW OUTPUTS
# ============================================================================

output "infrastructure_summary" {
  description = "Complete infrastructure summary for dependency analysis and validation"
  value = {
    lab_name         = "resource-management-dependencies"
    lab_version      = "4.1"
    student_name     = var.student_name
    environment      = var.environment
    aws_region       = var.aws_region
    deployment_time  = timestamp()
    terraform_workspace = terraform.workspace
    
    dependency_complexity = var.dependency_complexity_level
    
    resource_counts = {
      vpc_resources        = 1
      subnets             = length(aws_subnet.public) + length(aws_subnet.private) + length(aws_subnet.database)
      security_groups     = length(aws_security_group.app_tiers) + (var.enable_rds ? 1 : 0) + (var.load_balancer_configuration.enable_application_lb ? 1 : 0)
      database_instances  = var.enable_rds ? 1 : 0
      launch_templates    = length(aws_launch_template.app_tiers)
      auto_scaling_groups = length(aws_autoscaling_group.app_tiers)
      load_balancers      = var.load_balancer_configuration.enable_application_lb ? 1 : 0
      nat_gateways        = var.enable_nat_gateway ? length(aws_subnet.public) : 0
    }
    
    meta_arguments_used = {
      count_resources = ["subnets", "route_tables", "nat_gateways", "eips"]
      for_each_resources = ["security_groups", "launch_templates", "autoscaling_groups"]
      lifecycle_managed = ["database", "launch_templates", "security_groups"]
      explicit_dependencies = ["database", "load_balancer", "autoscaling_groups"]
    }
  }
}

# ============================================================================
# DEPENDENCY ANALYSIS OUTPUTS
# ============================================================================

output "dependency_analysis" {
  description = "Detailed dependency analysis for educational purposes"
  value = {
    dependency_tiers = {
      tier_1_foundation = {
        description = "Foundation resources with no dependencies"
        resources = [
          "aws_vpc.main",
          "random_id.suffix",
          "time_static.deployment_time"
        ]
      }
      
      tier_2_network = {
        description = "Network resources depending on VPC"
        resources = [
          "aws_subnet.public[*]",
          "aws_subnet.private[*]",
          "aws_subnet.database[*]",
          "aws_internet_gateway.main"
        ]
        depends_on = ["aws_vpc.main"]
      }
      
      tier_3_routing = {
        description = "Routing resources depending on network components"
        resources = [
          "aws_route_table.public",
          "aws_route_table.private[*]",
          "aws_route_table_association.public[*]",
          "aws_route_table_association.private[*]"
        ]
        depends_on = ["aws_subnet.*", "aws_internet_gateway.main"]
      }
      
      tier_4_security = {
        description = "Security groups with inter-dependencies"
        resources = [
          "aws_security_group.app_tiers[*]",
          "aws_security_group.database",
          "aws_security_group.alb[*]"
        ]
        depends_on = ["aws_vpc.main"]
      }
      
      tier_5_data = {
        description = "Database tier with complex dependencies"
        resources = [
          "aws_db_subnet_group.main[*]",
          "aws_db_instance.main[*]"
        ]
        depends_on = ["aws_subnet.database[*]", "aws_security_group.database"]
      }
      
      tier_6_application = {
        description = "Application tier depending on data tier"
        resources = [
          "aws_launch_template.app_tiers[*]",
          "aws_autoscaling_group.app_tiers[*]"
        ]
        depends_on = ["aws_db_instance.main[*]", "aws_security_group.app_tiers[*]"]
      }
      
      tier_7_presentation = {
        description = "Load balancer tier with complex dependencies"
        resources = [
          "aws_lb.main[*]",
          "aws_lb_target_group.web[*]",
          "aws_lb_listener.web[*]"
        ]
        depends_on = ["aws_autoscaling_group.app_tiers[*]", "aws_internet_gateway.main"]
      }
      
      tier_8_monitoring = {
        description = "Monitoring resources depending on infrastructure"
        resources = [
          "aws_cloudwatch_log_group.app_logs[*]",
          "aws_flow_log.vpc[*]"
        ]
        depends_on = ["aws_vpc.main", "aws_iam_role.flow_log[*]"]
      }
    }
    
    implicit_dependencies = {
      description = "Dependencies automatically detected by Terraform"
      examples = [
        "aws_subnet.public[*] -> aws_vpc.main (via vpc_id)",
        "aws_security_group.app_tiers[*] -> aws_vpc.main (via vpc_id)",
        "aws_db_instance.main[*] -> aws_db_subnet_group.main[*] (via db_subnet_group_name)",
        "aws_autoscaling_group.app_tiers[*] -> aws_launch_template.app_tiers[*] (via launch_template)",
        "aws_lb.main[*] -> aws_security_group.alb[*] (via security_groups)"
      ]
    }
    
    explicit_dependencies = {
      description = "Dependencies manually declared with depends_on"
      examples = [
        "aws_eip.nat[*] -> aws_internet_gateway.main",
        "aws_nat_gateway.main[*] -> aws_internet_gateway.main",
        "aws_db_instance.main[*] -> aws_route_table_association.private[*]",
        "aws_launch_template.app_tiers[*] -> aws_db_instance.main[*]",
        "aws_lb.main[*] -> aws_autoscaling_group.app_tiers[*]"
      ]
    }
  }
}

# ============================================================================
# META-ARGUMENTS DEMONSTRATION OUTPUTS
# ============================================================================

output "meta_arguments_demonstration" {
  description = "Examples of meta-arguments usage for educational purposes"
  value = {
    count_examples = {
      description = "Resources using count meta-argument"
      public_subnets = {
        count = length(aws_subnet.public)
        addresses = [for i, subnet in aws_subnet.public : "aws_subnet.public[${i}]"]
        ids = aws_subnet.public[*].id
      }
      private_subnets = {
        count = length(aws_subnet.private)
        addresses = [for i, subnet in aws_subnet.private : "aws_subnet.private[${i}]"]
        ids = aws_subnet.private[*].id
      }
      database_subnets = {
        count = length(aws_subnet.database)
        addresses = [for i, subnet in aws_subnet.database : "aws_subnet.database[${i}]"]
        ids = aws_subnet.database[*].id
      }
    }
    
    for_each_examples = {
      description = "Resources using for_each meta-argument"
      security_groups = {
        keys = keys(aws_security_group.app_tiers)
        addresses = [for k, v in aws_security_group.app_tiers : "aws_security_group.app_tiers[\"${k}\"]"]
        ids = {for k, v in aws_security_group.app_tiers : k => v.id}
      }
      launch_templates = {
        keys = keys(aws_launch_template.app_tiers)
        addresses = [for k, v in aws_launch_template.app_tiers : "aws_launch_template.app_tiers[\"${k}\"]"]
        ids = {for k, v in aws_launch_template.app_tiers : k => v.id}
      }
      autoscaling_groups = {
        keys = keys(aws_autoscaling_group.app_tiers)
        addresses = [for k, v in aws_autoscaling_group.app_tiers : "aws_autoscaling_group.app_tiers[\"${k}\"]"]
        names = {for k, v in aws_autoscaling_group.app_tiers : k => v.name}
      }
    }
    
    lifecycle_examples = {
      description = "Resources with lifecycle management"
      create_before_destroy = [
        "aws_security_group.app_tiers[*]",
        "aws_security_group.database",
        "aws_launch_template.app_tiers[*]",
        "aws_autoscaling_group.app_tiers[*]"
      ]
      prevent_destroy = var.database_configuration.deletion_protection ? [
        "aws_db_instance.main[*]"
      ] : []
      ignore_changes = [
        "aws_db_instance.main[*] (password, snapshot_identifier)",
        "aws_autoscaling_group.app_tiers[*] (desired_capacity)"
      ]
    }
    
    depends_on_examples = {
      description = "Resources with explicit dependencies"
      examples = [
        {
          resource = "aws_eip.nat[*]"
          depends_on = ["aws_internet_gateway.main"]
          reason = "EIP requires IGW for proper allocation"
        },
        {
          resource = "aws_db_instance.main[*]"
          depends_on = ["aws_db_subnet_group.main[*]", "aws_security_group.database"]
          reason = "Database requires subnet group and security group"
        },
        {
          resource = "aws_launch_template.app_tiers[*]"
          depends_on = ["aws_db_instance.main[*]"]
          reason = "Application tier requires database to be ready"
        },
        {
          resource = "aws_lb.main[*]"
          depends_on = ["aws_autoscaling_group.app_tiers[*]"]
          reason = "Load balancer requires application tier to be ready"
        }
      ]
    }
  }
}

# ============================================================================
# NETWORKING CONFIGURATION OUTPUTS
# ============================================================================

output "networking_configuration" {
  description = "VPC and networking configuration with dependency information"
  value = {
    vpc = {
      id         = aws_vpc.main.id
      cidr_block = aws_vpc.main.cidr_block
      arn        = aws_vpc.main.arn
      dependency_tier = "foundation"
    }
    
    internet_gateway = {
      id  = aws_internet_gateway.main.id
      arn = aws_internet_gateway.main.arn
      dependency_tier = "foundation"
      depends_on_vpc = true
    }
    
    subnets_by_type = {
      public = [
        for i, subnet in aws_subnet.public : {
          id                = subnet.id
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
          arn              = subnet.arn
          dependency_tier  = "network"
          index           = i
        }
      ]
      private = [
        for i, subnet in aws_subnet.private : {
          id                = subnet.id
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
          arn              = subnet.arn
          dependency_tier  = "network"
          index           = i
        }
      ]
      database = [
        for i, subnet in aws_subnet.database : {
          id                = subnet.id
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
          arn              = subnet.arn
          dependency_tier  = "data"
          index           = i
        }
      ]
    }
    
    routing = {
      public_route_table = {
        id  = aws_route_table.public.id
        arn = aws_route_table.public.arn
        dependency_tier = "routing"
      }
      private_route_tables = [
        for i, rt in aws_route_table.private : {
          id  = rt.id
          arn = rt.arn
          dependency_tier = "routing"
          index = i
        }
      ]
    }
    
    nat_gateways = var.enable_nat_gateway ? [
      for i, nat in aws_nat_gateway.main : {
        id  = nat.id
        allocation_id = nat.allocation_id
        subnet_id = nat.subnet_id
        dependency_tier = "routing"
        index = i
      }
    ] : []
  }
}

# ============================================================================
# APPLICATION TIER OUTPUTS
# ============================================================================

output "application_tier_configuration" {
  description = "Application tier configuration with dependency relationships"
  value = {
    database = var.enable_rds ? {
      endpoint = aws_db_instance.main[0].endpoint
      port     = aws_db_instance.main[0].port
      engine   = aws_db_instance.main[0].engine
      id       = aws_db_instance.main[0].id
      arn      = aws_db_instance.main[0].arn
      dependency_tier = "data"
      depends_on = ["subnet_group", "security_group", "route_associations"]
    } : null

    launch_templates = {
      for k, v in aws_launch_template.app_tiers : k => {
        id           = v.id
        name         = v.name
        image_id     = v.image_id
        instance_type = v.instance_type
        dependency_tier = "application"
        depends_on_database = var.enable_rds
        tier_configuration = var.application_tiers[k]
      }
    }

    autoscaling_groups = {
      for k, v in aws_autoscaling_group.app_tiers : k => {
        id               = v.id
        name             = v.name
        min_size         = v.min_size
        max_size         = v.max_size
        desired_capacity = v.desired_capacity
        dependency_tier  = "application"
        launch_template_dependency = aws_launch_template.app_tiers[k].id
        tier_configuration = var.application_tiers[k]
      }
    }

    security_groups = {
      for k, v in aws_security_group.app_tiers : k => {
        id          = v.id
        name        = v.name
        description = v.description
        arn         = v.arn
        dependency_tier = "security"
        tier_type = k
      }
    }
  }
}

# ============================================================================
# LOAD BALANCER CONFIGURATION OUTPUTS
# ============================================================================

output "load_balancer_configuration" {
  description = "Load balancer configuration with complex dependency information"
  value = var.load_balancer_configuration.enable_application_lb ? {
    load_balancer = {
      id           = aws_lb.main[0].id
      arn          = aws_lb.main[0].arn
      dns_name     = aws_lb.main[0].dns_name
      zone_id      = aws_lb.main[0].zone_id
      type         = aws_lb.main[0].load_balancer_type
      scheme       = aws_lb.main[0].scheme
      dependency_tier = "presentation"
      explicit_dependencies = ["internet_gateway", "route_associations", "autoscaling_groups"]
    }

    target_group = {
      id   = aws_lb_target_group.web[0].id
      arn  = aws_lb_target_group.web[0].arn
      name = aws_lb_target_group.web[0].name
      port = aws_lb_target_group.web[0].port
      protocol = aws_lb_target_group.web[0].protocol
      dependency_tier = "presentation"
    }

    listener = {
      id       = aws_lb_listener.web[0].id
      arn      = aws_lb_listener.web[0].arn
      port     = aws_lb_listener.web[0].port
      protocol = aws_lb_listener.web[0].protocol
      dependency_tier = "presentation"
      depends_on_target_group = true
    }

    health_check_url = "http://${aws_lb.main[0].dns_name}/health"
    application_url = "http://${aws_lb.main[0].dns_name}/"
  } : null
}

# ============================================================================
# MONITORING CONFIGURATION OUTPUTS
# ============================================================================

output "monitoring_configuration" {
  description = "Monitoring and logging configuration for dependency tracking"
  value = var.monitoring_enabled ? {
    cloudwatch_log_group = {
      name = aws_cloudwatch_log_group.app_logs[0].name
      arn  = aws_cloudwatch_log_group.app_logs[0].arn
      retention_days = aws_cloudwatch_log_group.app_logs[0].retention_in_days
      dependency_tier = "monitoring"
    }

    vpc_flow_logs = var.vpc_configuration.enable_flow_logs ? {
      log_group_name = aws_cloudwatch_log_group.vpc_flow_logs[0].name
      log_group_arn  = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
      flow_log_id    = aws_flow_log.vpc[0].id
      iam_role_arn   = aws_iam_role.flow_log[0].arn
      dependency_tier = "monitoring"
    } : null

    monitoring_urls = {
      cloudwatch_console = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups"
      ec2_console       = "https://${var.aws_region}.console.aws.amazon.com/ec2/home?region=${var.aws_region}#Instances:"
      rds_console       = var.enable_rds ? "https://${var.aws_region}.console.aws.amazon.com/rds/home?region=${var.aws_region}#databases:" : null
      vpc_console       = "https://${var.aws_region}.console.aws.amazon.com/vpc/home?region=${var.aws_region}#vpcs:"
    }
  } : null
}

# ============================================================================
# TESTING AND VALIDATION OUTPUTS
# ============================================================================

output "testing_and_validation" {
  description = "Testing commands and validation information for dependency management"
  value = {
    dependency_testing_commands = [
      "# Generate dependency graph:",
      "terraform graph | dot -Tpng > dependencies.png",
      "",
      "# Test resource targeting by dependency tier:",
      "terraform plan -target=aws_vpc.main",
      "terraform plan -target=aws_subnet.public",
      "terraform plan -target=aws_db_instance.main",
      "terraform plan -target=aws_autoscaling_group.app_tiers",
      "",
      "# Test meta-arguments:",
      "terraform state show 'aws_subnet.public[0]'",
      "terraform state show 'aws_security_group.app_tiers[\"web\"]'",
      "",
      "# Test lifecycle behavior:",
      "terraform apply -replace=aws_launch_template.app_tiers[\"web\"]",
      "",
      "# Test dependency resolution:",
      "terraform apply -target=aws_vpc.main",
      "terraform apply -target=aws_subnet.database",
      "terraform apply -target=aws_db_instance.main",
      "terraform apply"
    ]

    validation_checklist = {
      dependency_validation = {
        vpc_created = aws_vpc.main.id != "" ? "✅ VPC created successfully" : "❌ VPC creation failed"
        subnets_created = length(aws_subnet.public) + length(aws_subnet.private) + length(aws_subnet.database) > 0 ? "✅ All subnets created" : "❌ Subnet creation failed"
        database_ready = var.enable_rds ? (length(aws_db_instance.main) > 0 ? "✅ Database ready" : "❌ Database not ready") : "⚠️ Database disabled"
        autoscaling_groups_ready = length(aws_autoscaling_group.app_tiers) > 0 ? "✅ Auto Scaling Groups ready" : "❌ ASG creation failed"
        load_balancer_ready = var.load_balancer_configuration.enable_application_lb ? (length(aws_lb.main) > 0 ? "✅ Load balancer ready" : "❌ Load balancer not ready") : "⚠️ Load balancer disabled"
      }

      meta_arguments_validation = {
        count_working = length(aws_subnet.public) > 0 ? "✅ Count meta-argument working" : "❌ Count meta-argument failed"
        for_each_working = length(aws_security_group.app_tiers) > 0 ? "✅ For_each meta-argument working" : "❌ For_each meta-argument failed"
        lifecycle_applied = "✅ Lifecycle rules applied to critical resources"
        explicit_dependencies = "✅ Explicit dependencies configured"
      }

      connectivity_validation = {
        internet_gateway_attached = aws_internet_gateway.main.vpc_id == aws_vpc.main.id ? "✅ Internet gateway attached" : "❌ Internet gateway not attached"
        routing_configured = length(aws_route_table_association.public) > 0 ? "✅ Public routing configured" : "❌ Routing configuration issue"
        security_groups_configured = length(aws_security_group.app_tiers) > 0 ? "✅ Security groups configured" : "❌ Security group configuration failed"
      }
    }

    troubleshooting_commands = [
      "# Check Terraform state for dependencies:",
      "terraform state list",
      "terraform state show aws_db_instance.main[0]",
      "",
      "# Validate configuration:",
      "terraform validate",
      "terraform plan",
      "",
      "# AWS CLI debugging:",
      "aws ec2 describe-vpcs --filters 'Name=tag:Project,Values=${var.project_name}'",
      "aws rds describe-db-instances",
      "aws autoscaling describe-auto-scaling-groups",
      "aws elbv2 describe-load-balancers",
      "",
      "# Dependency analysis:",
      "terraform graph | grep -E '(vpc|subnet|database|autoscaling|lb)'",
      "terraform state list | sort"
    ]
  }
}
