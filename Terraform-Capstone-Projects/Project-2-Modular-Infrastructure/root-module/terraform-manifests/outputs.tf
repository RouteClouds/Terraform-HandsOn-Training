# Root Module - Outputs

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.vpc.nat_gateway_public_ips
}

# Security Outputs
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security.alb_security_group_id
}

output "ec2_security_group_id" {
  description = "EC2 security group ID"
  value       = module.security.ec2_security_group_id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.security.rds_security_group_id
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = module.security.kms_key_id
}

# Compute Outputs
output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN"
  value       = module.compute.autoscaling_group_arn
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = module.compute.launch_template_id
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.load_balancer.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.load_balancer.alb_arn
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = module.load_balancer.alb_zone_id
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = module.load_balancer.target_group_arn
}

# Database Outputs
output "db_instance_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "db_instance_address" {
  description = "Database address"
  value       = module.database.db_instance_address
  sensitive   = true
}

output "db_instance_port" {
  description = "Database port"
  value       = module.database.db_instance_port
}

output "db_instance_name" {
  description = "Database name"
  value       = module.database.db_instance_name
}

# Storage Outputs
output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = module.storage.bucket_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.storage.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = module.storage.bucket_domain_name
}

# Monitoring Outputs
output "cloudwatch_dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = module.monitoring.dashboard_arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = module.monitoring.log_group_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = module.monitoring.sns_topic_arn
}

# DNS Outputs
output "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = var.domain_name != null ? module.dns[0].hosted_zone_id : null
}

output "hosted_zone_name_servers" {
  description = "Route53 hosted zone name servers"
  value       = var.domain_name != null && var.create_hosted_zone ? module.dns[0].hosted_zone_name_servers : null
}

output "dns_records" {
  description = "DNS record FQDNs"
  value       = var.domain_name != null ? module.dns[0].record_fqdns : null
}

# Application URL
output "application_url" {
  description = "Application URL"
  value       = var.domain_name != null ? "http://${var.domain_name}" : "http://${module.load_balancer.alb_dns_name}"
}

