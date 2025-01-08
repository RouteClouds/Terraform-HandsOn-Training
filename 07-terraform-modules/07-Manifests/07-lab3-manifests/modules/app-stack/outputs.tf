# App Stack Module - Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "instance_ids" {
  description = "List of instance IDs"
  value       = module.instances[*].instance_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.security_group.security_group_id
}

output "alb_dns_name" {
  description = "DNS name of the ALB (if created)"
  value       = var.environment == "production" ? module.alb[0].alb_dns_name : null
} 