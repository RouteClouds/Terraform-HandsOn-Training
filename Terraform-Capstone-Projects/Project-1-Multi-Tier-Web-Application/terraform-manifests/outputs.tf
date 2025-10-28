# Output Values
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# VPC Outputs
# ========================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ips" {
  description = "Elastic IPs of NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# ========================================
# Load Balancer Outputs
# ========================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "alb_url" {
  description = "URL to access the application via ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

# ========================================
# Auto Scaling Outputs
# ========================================

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.main.latest_version
}

# ========================================
# RDS Outputs
# ========================================

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "Master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "rds_read_replica_endpoint" {
  description = "Endpoint of the RDS read replica"
  value       = var.environment == "prod" ? aws_db_instance.read_replica[0].endpoint : null
}

# ========================================
# S3 Outputs
# ========================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.static_assets.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.static_assets.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.static_assets.bucket_regional_domain_name
}

# ========================================
# CloudFront Outputs
# ========================================

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_url" {
  description = "URL to access the application via CloudFront"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}

# ========================================
# Route53 Outputs
# ========================================

output "route53_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = var.create_route53_zone && var.domain_name != "" ? aws_route53_zone.main[0].zone_id : null
}

output "route53_name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value       = var.create_route53_zone && var.domain_name != "" ? aws_route53_zone.main[0].name_servers : null
}

output "domain_name" {
  description = "Domain name configured for the application"
  value       = var.domain_name != "" ? var.domain_name : null
}

output "cdn_domain_name" {
  description = "CDN domain name"
  value       = var.domain_name != "" ? "cdn.${var.domain_name}" : null
}

# ========================================
# Security Outputs
# ========================================

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "ec2_iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.arn
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.main.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.main.arn
}

# ========================================
# Monitoring Outputs
# ========================================

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.application.name
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = var.alarm_email != "" ? aws_sns_topic.alarms[0].arn : null
}

# ========================================
# General Outputs
# ========================================

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "availability_zones" {
  description = "Availability zones used"
  value       = local.azs
}

output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

# ========================================
# Connection Information
# ========================================

output "connection_info" {
  description = "Connection information for the deployed infrastructure"
  value = {
    application_url = "http://${aws_lb.main.dns_name}"
    cdn_url         = "https://${aws_cloudfront_distribution.main.domain_name}"
    custom_domain   = var.domain_name != "" ? "https://${var.domain_name}" : "Not configured"
    cdn_domain      = var.domain_name != "" ? "https://cdn.${var.domain_name}" : "Not configured"
    database_host   = aws_db_instance.main.address
    database_port   = aws_db_instance.main.port
    database_name   = aws_db_instance.main.db_name
    s3_bucket       = aws_s3_bucket.static_assets.id
  }
}

# ========================================
# Resource Summary
# ========================================

output "resource_summary" {
  description = "Summary of deployed resources"
  value = {
    vpc_id                  = aws_vpc.main.id
    public_subnets          = length(aws_subnet.public)
    private_subnets         = length(aws_subnet.private)
    nat_gateways            = length(aws_nat_gateway.main)
    alb_name                = aws_lb.main.name
    asg_name                = aws_autoscaling_group.main.name
    asg_min_size            = var.asg_min_size
    asg_max_size            = var.asg_max_size
    rds_instance            = aws_db_instance.main.identifier
    rds_multi_az            = var.db_multi_az
    s3_bucket               = aws_s3_bucket.static_assets.id
    cloudfront_distribution = aws_cloudfront_distribution.main.id
  }
}

