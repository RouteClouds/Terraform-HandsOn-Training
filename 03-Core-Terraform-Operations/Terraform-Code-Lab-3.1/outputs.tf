# AWS Terraform Training - Core Terraform Operations
# Lab 3.1: Core Workflow and Resource Lifecycle Management
# File: outputs.tf - Output Definitions

# ============================================================================
# INFRASTRUCTURE OVERVIEW OUTPUTS
# ============================================================================

output "infrastructure_summary" {
  description = "Complete infrastructure summary for lab validation and documentation"
  value = {
    lab_name         = "core-terraform-operations"
    lab_version      = "3.1"
    student_name     = var.student_name
    environment      = var.environment
    aws_region       = var.aws_region
    deployment_time  = timestamp()
    terraform_workspace = terraform.workspace
    
    resource_counts = {
      ec2_instances    = var.instance_count
      public_subnets   = length(var.public_subnet_cidrs)
      private_subnets  = length(var.private_subnet_cidrs)
      security_groups  = var.enable_load_balancer ? 2 : 1
      load_balancers   = var.enable_load_balancer ? 1 : 0
      s3_buckets      = var.create_s3_bucket ? 1 : 0
    }
  }
}

# ============================================================================
# NETWORKING OUTPUTS
# ============================================================================

output "networking_configuration" {
  description = "VPC and networking configuration details for connectivity and troubleshooting"
  value = {
    vpc = {
      id         = aws_vpc.main.id
      cidr_block = aws_vpc.main.cidr_block
      arn        = aws_vpc.main.arn
    }
    
    internet_gateway = {
      id  = aws_internet_gateway.main.id
      arn = aws_internet_gateway.main.arn
    }
    
    public_subnets = [
      for i, subnet in aws_subnet.public : {
        id                = subnet.id
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        arn              = subnet.arn
      }
    ]
    
    private_subnets = [
      for i, subnet in aws_subnet.private : {
        id                = subnet.id
        cidr_block        = subnet.cidr_block
        availability_zone = subnet.availability_zone
        arn              = subnet.arn
      }
    ]
    
    route_tables = {
      public = {
        id  = aws_route_table.public.id
        arn = aws_route_table.public.arn
      }
      private = {
        id  = aws_route_table.private.id
        arn = aws_route_table.private.arn
      }
    }
  }
}

# ============================================================================
# COMPUTE OUTPUTS
# ============================================================================

output "compute_resources" {
  description = "EC2 instances and compute resource information for access and management"
  value = {
    instances = [
      for i, instance in aws_instance.web : {
        id                = instance.id
        instance_type     = instance.instance_type
        ami_id           = instance.ami
        public_ip        = instance.public_ip
        private_ip       = instance.private_ip
        public_dns       = instance.public_dns
        availability_zone = instance.availability_zone
        subnet_id        = instance.subnet_id
        security_groups  = instance.vpc_security_group_ids
        state           = instance.instance_state
        arn             = instance.arn
      }
    ]
    
    security_groups = {
      web = {
        id          = aws_security_group.web.id
        name        = aws_security_group.web.name
        description = aws_security_group.web.description
        arn         = aws_security_group.web.arn
      }
      alb = var.enable_load_balancer ? {
        id          = aws_security_group.alb[0].id
        name        = aws_security_group.alb[0].name
        description = aws_security_group.alb[0].description
        arn         = aws_security_group.alb[0].arn
      } : null
    }
  }
}

# ============================================================================
# LOAD BALANCER OUTPUTS
# ============================================================================

output "load_balancer_configuration" {
  description = "Application Load Balancer configuration for traffic distribution and access"
  value = var.enable_load_balancer ? {
    load_balancer = {
      id           = aws_lb.main[0].id
      arn          = aws_lb.main[0].arn
      dns_name     = aws_lb.main[0].dns_name
      zone_id      = aws_lb.main[0].zone_id
      type         = aws_lb.main[0].load_balancer_type
      scheme       = aws_lb.main[0].scheme
    }
    
    target_group = {
      id   = aws_lb_target_group.web[0].id
      arn  = aws_lb_target_group.web[0].arn
      name = aws_lb_target_group.web[0].name
      port = aws_lb_target_group.web[0].port
    }
    
    listener = {
      id       = aws_lb_listener.web[0].id
      arn      = aws_lb_listener.web[0].arn
      port     = aws_lb_listener.web[0].port
      protocol = aws_lb_listener.web[0].protocol
    }
    
    health_check_url = "http://${aws_lb.main[0].dns_name}/"
  } : null
}

# ============================================================================
# STORAGE OUTPUTS
# ============================================================================

output "storage_configuration" {
  description = "S3 bucket and storage configuration for application data management"
  value = var.create_s3_bucket ? {
    s3_bucket = {
      id                    = aws_s3_bucket.app_data[0].id
      arn                   = aws_s3_bucket.app_data[0].arn
      bucket_domain_name    = aws_s3_bucket.app_data[0].bucket_domain_name
      bucket_regional_domain_name = aws_s3_bucket.app_data[0].bucket_regional_domain_name
      region               = aws_s3_bucket.app_data[0].region
      versioning_enabled   = var.s3_bucket_versioning
      encryption_enabled   = var.encryption_enabled
    }
  } : null
}

# ============================================================================
# MONITORING OUTPUTS
# ============================================================================

output "monitoring_configuration" {
  description = "CloudWatch and monitoring configuration for observability and troubleshooting"
  value = var.monitoring_enabled ? {
    cloudwatch_log_group = {
      name = aws_cloudwatch_log_group.app_logs[0].name
      arn  = aws_cloudwatch_log_group.app_logs[0].arn
    }
    
    vpc_flow_logs = var.enable_vpc_flow_logs ? {
      log_group_name = aws_cloudwatch_log_group.vpc_flow_logs[0].name
      log_group_arn  = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
      flow_log_id    = aws_flow_log.vpc[0].id
    } : null
    
    monitoring_urls = {
      cloudwatch_console = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups"
      ec2_console       = "https://${var.aws_region}.console.aws.amazon.com/ec2/home?region=${var.aws_region}#Instances:"
      vpc_console       = "https://${var.aws_region}.console.aws.amazon.com/vpc/home?region=${var.aws_region}#vpcs:"
    }
  } : null
}

# ============================================================================
# ACCESS AND CONNECTIVITY OUTPUTS
# ============================================================================

output "access_information" {
  description = "Access URLs and connection information for testing and validation"
  value = {
    web_application_urls = [
      for instance in aws_instance.web : "http://${instance.public_ip}/"
    ]
    
    load_balancer_url = var.enable_load_balancer ? "http://${aws_lb.main[0].dns_name}/" : null
    
    ssh_commands = var.key_pair_name != "" ? [
      for instance in aws_instance.web : "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${instance.public_ip}"
    ] : ["Key pair not configured - SSH access not available"]
    
    aws_console_links = {
      ec2_instances = "https://${var.aws_region}.console.aws.amazon.com/ec2/home?region=${var.aws_region}#Instances:tag:Project=${var.project_name}"
      load_balancer = var.enable_load_balancer ? "https://${var.aws_region}.console.aws.amazon.com/ec2/home?region=${var.aws_region}#LoadBalancers:" : null
      s3_bucket     = var.create_s3_bucket ? "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.app_data[0].id}" : null
    }
  }
}

# ============================================================================
# COST OPTIMIZATION OUTPUTS
# ============================================================================

output "cost_optimization_info" {
  description = "Cost optimization features and estimated costs for financial planning"
  value = {
    auto_shutdown_enabled = var.auto_shutdown_enabled
    auto_shutdown_hours   = var.auto_shutdown_hours
    cost_optimization_level = var.cost_optimization_level
    
    estimated_costs = {
      ec2_instances_hourly = "${var.instance_count * 0.0116}"  # t3.micro pricing
      ec2_instances_daily  = "${var.instance_count * 0.0116 * 24}"
      s3_storage_monthly   = "~$0.023/GB"
      cloudwatch_monthly   = "~$0.50/GB ingested"
      total_daily_estimate = "$${var.instance_count * 0.0116 * 24 + 0.10}"
    }
    
    cost_savings_features = [
      "Auto-shutdown after ${var.auto_shutdown_hours} hours",
      "t3.micro instances for cost efficiency",
      "EBS GP3 volumes for better price/performance",
      "CloudWatch log retention: ${var.log_retention_days} days",
      var.enable_nat_gateway ? "NAT Gateway enabled (additional cost)" : "NAT Gateway disabled for cost savings"
    ]
  }
}

# ============================================================================
# TERRAFORM OPERATIONS OUTPUTS
# ============================================================================

output "terraform_operations_info" {
  description = "Terraform operations information for workflow management and troubleshooting"
  value = {
    terraform_version = "1.13.x"
    aws_provider_version = "6.12.x"
    workspace = terraform.workspace
    
    resource_dependencies = {
      vpc_depends_on = ["random_id.suffix"]
      subnets_depend_on = ["aws_vpc.main"]
      instances_depend_on = ["aws_subnet.public", "aws_security_group.web", "aws_internet_gateway.main"]
      load_balancer_depends_on = var.enable_load_balancer ? ["aws_subnet.public", "aws_security_group.alb", "aws_internet_gateway.main"] : []
    }
    
    lifecycle_configurations = {
      instances_create_before_destroy = true
      security_groups_create_before_destroy = true
      instances_ignore_changes = ["ami", "user_data"]
    }
    
    meta_arguments_used = {
      count_resources = ["aws_subnet.public", "aws_subnet.private", "aws_instance.web"]
      conditional_resources = var.enable_load_balancer ? ["aws_lb.main", "aws_security_group.alb"] : []
      lifecycle_managed = ["aws_instance.web", "aws_security_group.web"]
    }
  }
}

# ============================================================================
# VALIDATION AND TESTING OUTPUTS
# ============================================================================

output "validation_checklist" {
  description = "Validation checklist for ensuring proper infrastructure deployment"
  value = {
    infrastructure_validation = {
      vpc_created = aws_vpc.main.id != "" ? "✅ VPC created successfully" : "❌ VPC creation failed"
      instances_running = length(aws_instance.web) == var.instance_count ? "✅ All instances created" : "❌ Instance count mismatch"
      load_balancer_ready = var.enable_load_balancer ? (aws_lb.main[0].dns_name != "" ? "✅ Load balancer ready" : "❌ Load balancer not ready") : "⚠️ Load balancer disabled"
      s3_bucket_created = var.create_s3_bucket ? (aws_s3_bucket.app_data[0].id != "" ? "✅ S3 bucket created" : "❌ S3 bucket creation failed") : "⚠️ S3 bucket disabled"
    }
    
    connectivity_validation = {
      internet_gateway_attached = aws_internet_gateway.main.vpc_id == aws_vpc.main.id ? "✅ Internet gateway attached" : "❌ Internet gateway not attached"
      public_subnets_routable = length(aws_route_table_association.public) == length(aws_subnet.public) ? "✅ Public subnets routable" : "❌ Routing configuration issue"
      security_groups_configured = aws_security_group.web.id != "" ? "✅ Security groups configured" : "❌ Security group configuration failed"
    }
    
    testing_commands = [
      "# Test web application access:",
      "curl http://${aws_instance.web[0].public_ip}/",
      var.enable_load_balancer ? "curl http://${aws_lb.main[0].dns_name}/" : "# Load balancer disabled",
      "",
      "# Test SSH access (if key pair configured):",
      var.key_pair_name != "" ? "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.web[0].public_ip}" : "# SSH key not configured",
      "",
      "# Terraform operations to test:",
      "terraform state list",
      "terraform state show aws_instance.web[0]",
      "terraform plan",
      "terraform apply -target=aws_instance.web[0]"
    ]
  }
}

# ============================================================================
# TROUBLESHOOTING OUTPUTS
# ============================================================================

output "troubleshooting_guide" {
  description = "Troubleshooting information and common issue resolution"
  value = {
    common_issues = {
      instance_not_accessible = {
        issue = "Cannot access EC2 instances via HTTP"
        checks = [
          "Verify security group allows HTTP (port 80) access",
          "Check if instances are in public subnets",
          "Ensure internet gateway is attached and routes configured",
          "Verify user data script executed successfully"
        ]
      }
      
      load_balancer_503_error = var.enable_load_balancer ? {
        issue = "Load balancer returns 503 Service Unavailable"
        checks = [
          "Check target group health status",
          "Verify instances are registered with target group",
          "Ensure security groups allow ALB to reach instances",
          "Check application is running on port 80"
        ]
      } : null
      
      terraform_state_issues = {
        issue = "Terraform state inconsistencies"
        resolution = [
          "Run 'terraform refresh' to sync state",
          "Use 'terraform state list' to see managed resources",
          "Check for manual changes in AWS console",
          "Consider 'terraform import' for orphaned resources"
        ]
      }
    }
    
    debugging_commands = [
      "# Check Terraform state:",
      "terraform state list",
      "terraform state show aws_instance.web[0]",
      "",
      "# Validate configuration:",
      "terraform validate",
      "terraform plan",
      "",
      "# AWS CLI debugging:",
      "aws ec2 describe-instances --filters 'Name=tag:Project,Values=${var.project_name}'",
      "aws elbv2 describe-load-balancers",
      "aws elbv2 describe-target-health --target-group-arn ${var.enable_load_balancer ? aws_lb_target_group.web[0].arn : "N/A"}"
    ]
  }
}
