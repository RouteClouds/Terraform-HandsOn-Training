# Outputs Configuration for Infrastructure as Code Lab 1.1
# Topic 1: Infrastructure as Code Concepts & AWS Integration
#
# This file defines comprehensive outputs that provide visibility into
# the deployed infrastructure, enable integration with other systems,
# and support operational monitoring and troubleshooting.
#
# Output Categories:
# 1. Network Infrastructure Outputs
# 2. Security Configuration Outputs
# 3. Compute Infrastructure Outputs
# 4. Storage and Database Outputs
# 5. Monitoring and Logging Outputs
# 6. Cost and Management Outputs
# 7. Integration and Connectivity Outputs
# 8. Operational and Troubleshooting Outputs
#
# Last Updated: January 2025

# =============================================================================
# 1. NETWORK INFRASTRUCTURE OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC - Virtual Private Cloud for network isolation"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC for network planning and security group configuration"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC for IAM policies and cross-account access"
  value       = aws_vpc.main.arn
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway for public internet access"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets for load balancers and public-facing resources"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets for application servers and internal resources"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets for RDS instances and data storage"
  value       = aws_subnet.database[*].id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways for private subnet internet access"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
}

output "nat_gateway_public_ips" {
  description = "Public IP addresses of the NAT Gateways for firewall configuration"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

output "availability_zones" {
  description = "Availability zones used for multi-AZ deployment and disaster recovery"
  value       = local.azs
}

# =============================================================================
# 2. SECURITY CONFIGURATION OUTPUTS
# =============================================================================

output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group"
  value       = aws_security_group.alb.id
}

output "web_security_group_id" {
  description = "ID of the web server security group for application tier"
  value       = aws_security_group.web.id
}

output "database_security_group_id" {
  description = "ID of the database security group for data tier"
  value       = aws_security_group.database.id
}

output "ec2_iam_role_arn" {
  description = "ARN of the IAM role for EC2 instances"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "security_configuration" {
  description = "Summary of security configuration for compliance reporting"
  value = {
    encryption_at_rest    = var.encryption_at_rest
    encryption_in_transit = var.encryption_in_transit
    data_classification   = var.data_classification
    compliance_scope      = var.compliance_scope
    backup_required       = var.backup_required
  }
}

# =============================================================================
# 3. COMPUTE INFRASTRUCTURE OUTPUTS
# =============================================================================

output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer for application access"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the Application Load Balancer for Route53 alias records"
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer for monitoring and policies"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group for health check monitoring"
  value       = aws_lb_target_group.web.arn
}

output "launch_template_id" {
  description = "ID of the launch template for Auto Scaling Group configuration"
  value       = aws_launch_template.web.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template for deployment tracking"
  value       = aws_launch_template.web.latest_version
}

output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group for scaling operations"
  value       = aws_autoscaling_group.web.name
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group for monitoring and policies"
  value       = aws_autoscaling_group.web.arn
}

output "application_url" {
  description = "Complete URL to access the deployed application"
  value       = "http://${aws_lb.main.dns_name}"
}

# =============================================================================
# 4. STORAGE AND DATABASE OUTPUTS
# =============================================================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket for application data and logs"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for IAM policies and cross-account access"
  value       = aws_s3_bucket.app_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket for direct access"
  value       = aws_s3_bucket.app_bucket.bucket_domain_name
}

output "database_endpoint" {
  description = "RDS instance endpoint for database connections"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "database_port" {
  description = "Port number for database connections"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Name of the database for application configuration"
  value       = aws_db_instance.main.db_name
}

output "database_username" {
  description = "Username for database connections"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "database_password" {
  description = "Password for database connections (sensitive)"
  value       = random_password.db_password.result
  sensitive   = true
}

# =============================================================================
# 5. MONITORING AND LOGGING OUTPUTS
# =============================================================================

output "cloudwatch_log_group_names" {
  description = "Names of CloudWatch log groups for log monitoring"
  value = {
    application_logs = aws_cloudwatch_log_group.app_logs.name
    alb_logs        = aws_cloudwatch_log_group.alb_logs.name
  }
}

output "monitoring_configuration" {
  description = "Summary of monitoring configuration for operational visibility"
  value = {
    monitoring_level        = var.monitoring_level
    detailed_monitoring     = var.enable_detailed_monitoring
    performance_insights    = var.enable_performance_insights
    log_retention_days      = var.log_retention_days
    cloudtrail_enabled      = var.enable_cloudtrail
    config_enabled          = var.enable_config
  }
}

# =============================================================================
# 6. COST AND MANAGEMENT OUTPUTS
# =============================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown in USD for budget planning"
  value = {
    ec2_instances = {
      count = var.desired_capacity
      type  = var.instance_type
      cost  = "$${var.desired_capacity * 8.50}"
    }
    load_balancer = {
      type = "Application Load Balancer"
      cost = "$16.20"
    }
    nat_gateways = {
      count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.azs)) : 0
      cost  = "$${var.enable_nat_gateway ? (var.single_nat_gateway ? 32.40 : length(local.azs) * 32.40) : 0}"
    }
    rds_database = {
      type = var.db_instance_class
      cost = "$${var.db_instance_class == "db.t3.micro" ? 12.50 : 25.00}"
    }
    s3_storage = {
      type = "Standard storage and requests"
      cost = "$2.00"
    }
    data_transfer = {
      type = "Internet and inter-AZ transfer"
      cost = "$5.00"
    }
    total_estimated = "$${var.desired_capacity * 8.50 + 16.20 + (var.enable_nat_gateway ? (var.single_nat_gateway ? 32.40 : length(local.azs) * 32.40) : 0) + (var.db_instance_class == "db.t3.micro" ? 12.50 : 25.00) + 2.00 + 5.00}"
  }
}

output "cost_optimization_features" {
  description = "Cost optimization features enabled for financial efficiency"
  value = {
    auto_shutdown_enabled  = var.auto_shutdown_enabled
    auto_shutdown_schedule = var.auto_shutdown_schedule
    s3_lifecycle_policies  = "Enabled (IA after 30 days, Glacier after 90 days)"
    right_sizing_enabled   = "Instance type optimized for workload"
    reserved_instances     = "Consider for production workloads"
    spot_instances         = "Consider for fault-tolerant workloads"
  }
}

output "resource_tags" {
  description = "Common tags applied to all resources for governance and cost allocation"
  value = {
    Project          = var.project_name
    Environment      = var.environment
    ManagedBy        = "terraform"
    CreatedBy        = var.created_by
    CostCenter       = var.cost_center
    Owner            = var.owner_email
    BusinessUnit     = var.business_unit
    DataClass        = var.data_classification
    BackupRequired   = var.backup_required
    MonitoringLevel  = var.monitoring_level
    AutoShutdown     = var.auto_shutdown_enabled
    LifecycleStage   = var.lifecycle_stage
    MaintenanceWindow = var.maintenance_window
    SupportLevel     = var.support_level
  }
}

# =============================================================================
# 7. INTEGRATION AND CONNECTIVITY OUTPUTS
# =============================================================================

output "integration_endpoints" {
  description = "Key endpoints for system integration and external connectivity"
  value = {
    application_url    = "http://${aws_lb.main.dns_name}"
    load_balancer_dns  = aws_lb.main.dns_name
    s3_bucket_url      = "s3://${aws_s3_bucket.app_bucket.bucket}"
    database_endpoint  = aws_db_instance.main.endpoint
    vpc_cidr          = aws_vpc.main.cidr_block
    region            = local.region
    account_id        = local.account_id
  }
  sensitive = true
}

output "dns_configuration" {
  description = "DNS configuration for custom domain setup"
  value = {
    load_balancer_dns_name = aws_lb.main.dns_name
    load_balancer_zone_id  = aws_lb.main.zone_id
    vpc_dns_hostnames      = var.enable_dns_hostnames
    vpc_dns_support        = var.enable_dns_support
  }
}

# =============================================================================
# 8. OPERATIONAL AND TROUBLESHOOTING OUTPUTS
# =============================================================================

output "operational_information" {
  description = "Operational information for troubleshooting and maintenance"
  value = {
    terraform_version    = "~> 1.13.0"
    aws_provider_version = "~> 6.12.0"
    deployment_region    = local.region
    deployment_account   = local.account_id
    deployment_timestamp = timestamp()
    name_prefix         = local.name_prefix
    availability_zones  = local.azs
  }
}

output "health_check_endpoints" {
  description = "Health check endpoints for monitoring and alerting"
  value = {
    application_health = "http://${aws_lb.main.dns_name}/"
    load_balancer_health = aws_lb_target_group.web.arn
    database_health = aws_db_instance.main.endpoint
  }
  sensitive = true
}

output "troubleshooting_commands" {
  description = "Useful commands for troubleshooting and validation"
  value = {
    test_application = "curl -I http://${aws_lb.main.dns_name}"
    check_asg_health = "aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${aws_autoscaling_group.web.name}"
    view_logs = "aws logs describe-log-groups --log-group-name-prefix /aws/ec2/${local.name_prefix}"
    check_s3_bucket = "aws s3 ls s3://${aws_s3_bucket.app_bucket.bucket}"
  }
}

output "next_steps" {
  description = "Recommended next steps after deployment"
  value = {
    verify_deployment = "Access the application at http://${aws_lb.main.dns_name}"
    monitor_costs = "Set up billing alerts and monitor AWS Cost Explorer"
    configure_dns = "Set up custom domain name using Route53"
    enable_ssl = "Configure SSL certificate using AWS Certificate Manager"
    setup_monitoring = "Configure CloudWatch dashboards and alarms"
    backup_strategy = "Implement automated backup and disaster recovery"
  }
}
