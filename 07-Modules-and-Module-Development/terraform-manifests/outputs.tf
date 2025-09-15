# Outputs for Terraform Modules and Module Development Demo

# VPC Module Outputs
output "vpc_id" {
  description = "ID of the VPC created by the VPC module"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs from VPC module"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs from VPC module"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs from VPC module"
  value       = module.vpc.database_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs from VPC module"
  value       = module.vpc.nat_gateway_ids
}

# Security Module Outputs
output "web_security_group_id" {
  description = "ID of the web tier security group"
  value       = module.security.web_security_group_id
}

output "app_security_group_id" {
  description = "ID of the application tier security group"
  value       = module.security.app_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database tier security group"
  value       = module.security.database_security_group_id
}

# Compute Module Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.compute.load_balancer_zone_id
}

output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.auto_scaling_group_name
}

output "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.compute.auto_scaling_group_arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.compute.launch_template_id
}

# Database Module Outputs
output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.database.db_instance_id
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = module.database.db_instance_port
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = module.database.db_instance_arn
}

output "db_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = module.database.db_subnet_group_name
}

# Storage Module Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.storage.s3_bucket_arn
}

output "kms_key_id" {
  description = "ID of the KMS key for encryption"
  value       = module.storage.kms_key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  value       = module.storage.kms_key_arn
}

# Monitoring Module Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.monitoring.cloudwatch_log_group_name
}

output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.monitoring.cloudwatch_dashboard_url
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}

# Application Configuration Outputs
output "app_config_parameter_names" {
  description = "List of SSM parameter names for application configuration"
  value       = module.app_config.parameter_names
}

output "app_config_secret_arn" {
  description = "ARN of the Secrets Manager secret for sensitive configuration"
  value       = module.app_config.secret_arn
  sensitive   = true
}

# Module Composition Example Outputs
output "web_application_url" {
  description = "URL of the web application (from composite module)"
  value       = module.web_application.application_url
}

output "web_application_health_check_url" {
  description = "Health check URL for the web application"
  value       = module.web_application.health_check_url
}

# Infrastructure Summary
output "infrastructure_summary" {
  description = "Summary of the deployed infrastructure"
  value = {
    project_name = var.project_name
    environment  = var.environment
    region       = data.aws_region.current.name
    account_id   = data.aws_caller_identity.current.account_id
    
    vpc = {
      id         = module.vpc.vpc_id
      cidr_block = module.vpc.vpc_cidr_block
      azs        = local.availability_zones
    }
    
    compute = {
      load_balancer_dns = module.compute.load_balancer_dns_name
      asg_name         = module.compute.auto_scaling_group_name
      instance_type    = local.config.instance_type
      min_instances    = local.config.min_instances
      max_instances    = local.config.max_instances
    }
    
    database = {
      instance_id    = module.database.db_instance_id
      instance_class = local.config.db_instance_class
      multi_az       = local.config.enable_multi_az
      encrypted      = true
    }
    
    storage = {
      bucket_name = module.storage.s3_bucket_name
      encrypted   = true
      versioning  = var.environment == "prod"
    }
    
    monitoring = {
      enabled           = local.config.enable_monitoring
      log_group        = module.monitoring.cloudwatch_log_group_name
      dashboard_url    = module.monitoring.cloudwatch_dashboard_url
    }
  }
}

# Cost Estimation
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (informational)"
  value = {
    compute = {
      ec2_instances = "${local.config.min_instances}-${local.config.max_instances} x ${local.config.instance_type}"
      load_balancer = "1 x Application Load Balancer"
      nat_gateway   = var.environment != "prod" ? "1 x NAT Gateway" : "${length(local.availability_zones)} x NAT Gateway"
    }
    
    database = {
      rds_instance = "1 x ${local.config.db_instance_class}"
      multi_az     = local.config.enable_multi_az ? "Yes" : "No"
      storage      = "${var.db_storage_size}GB (expandable to ${var.db_max_storage_size}GB)"
    }
    
    storage = {
      s3_bucket = "Standard storage with lifecycle policies"
      kms_key   = "Customer managed KMS key"
    }
    
    monitoring = {
      cloudwatch_logs    = "Log ingestion and storage"
      cloudwatch_metrics = "Custom metrics and alarms"
      sns_notifications  = "Alert notifications"
    }
    
    note = "Actual costs depend on usage patterns, data transfer, and AWS pricing changes"
  }
}

# Module Usage Examples
output "module_usage_examples" {
  description = "Examples of how to use the created modules"
  value = var.include_usage_examples ? {
    vpc_module = {
      source = "./modules/aws-vpc"
      example = "module \"vpc\" { source = \"./modules/aws-vpc\"; name = \"my-app\"; cidr_block = \"10.0.0.0/16\"; availability_zones = [\"us-east-1a\", \"us-east-1b\"]; environment = \"dev\" }"
    }
    
    security_module = {
      source = "./modules/aws-security"
      example = "module \"security\" { source = \"./modules/aws-security\"; name = \"my-app\"; vpc_id = module.vpc.vpc_id; vpc_cidr = module.vpc.vpc_cidr_block; environment = \"dev\" }"
    }
    
    compute_module = {
      source = "./modules/aws-compute"
      example = "module \"compute\" { source = \"./modules/aws-compute\"; name = \"my-app\"; vpc_id = module.vpc.vpc_id; public_subnet_ids = module.vpc.public_subnet_ids; private_subnet_ids = module.vpc.private_subnet_ids }"
    }
  } : null
}

# Validation Results
output "validation_results" {
  description = "Results of input validation and configuration checks"
  value = {
    environment_valid = contains(["dev", "staging", "prod"], var.environment)
    vpc_cidr_valid    = can(cidrhost(var.vpc_cidr, 0))
    region_valid      = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    
    configuration_summary = {
      cost_optimized     = var.environment != "prod" ? "Single NAT Gateway" : "Multi-AZ NAT Gateways"
      high_availability  = local.config.enable_multi_az ? "Enabled" : "Disabled"
      monitoring_level   = local.config.enable_monitoring ? "Detailed" : "Basic"
      backup_retention   = "${local.config.backup_retention} days"
    }
  }
}

# Module Metadata
output "module_metadata" {
  description = "Metadata about the modules used in this deployment"
  value = {
    terraform_version = ">= 1.13.0"
    aws_provider_version = "~> 6.12.0"
    
    modules_used = [
      "aws-vpc",
      "aws-security", 
      "aws-compute",
      "aws-database",
      "aws-storage",
      "aws-monitoring",
      "aws-app-config",
      "aws-web-app-composite"
    ]
    
    composition_pattern = var.module_composition_pattern
    deployment_timestamp = timestamp()
    
    features_enabled = {
      ssl_termination      = var.enable_ssl
      detailed_monitoring  = local.config.enable_monitoring
      multi_az_database   = local.config.enable_multi_az
      encryption_at_rest  = var.enable_encryption
      automated_backups   = var.enable_backups
      cost_optimization   = var.enable_cost_optimization
    }
  }
}
