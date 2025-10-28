# Outputs for Enterprise-Grade Secure Infrastructure

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP"
  value       = module.vpc.nat_gateway_public_ip
}

# Security Outputs
output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = module.secrets.kms_key_id
  sensitive   = true
}

output "db_password_secret_arn" {
  description = "ARN of database password secret"
  value       = module.secrets.db_password_secret_arn
}

output "api_key_secret_arn" {
  description = "ARN of API key secret"
  value       = module.secrets.api_key_secret_arn
}

# Monitoring Outputs
output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = module.monitoring.cloudtrail_id
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.monitoring.guardduty_detector_id
}

output "alarms_topic_arn" {
  description = "SNS topic ARN for alarms"
  value       = module.monitoring.alarms_topic_arn
}

# Security Group Outputs
output "application_security_group_id" {
  description = "Application security group ID"
  value       = aws_security_group.application.id
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.database.id
}

# IAM Outputs
output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_role_arn" {
  description = "EC2 instance role ARN"
  value       = aws_iam_role.ec2_instance.arn
}

# Summary Output
output "deployment_summary" {
  description = "Deployment summary"
  value = {
    project_name = var.project_name
    environment  = var.environment
    region       = var.aws_region
    vpc_cidr     = var.vpc_cidr
    subnets      = length(module.vpc.private_subnet_ids)
    security     = "Enterprise-grade security enabled"
    monitoring   = "CloudTrail, GuardDuty, Security Hub enabled"
    encryption   = "All data encrypted with KMS"
  }
}

