# Root Configuration - Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "web_server_instance_id" {
  description = "ID of the web server instance"
  value       = module.web_server.instance_id
}

output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Private IP of the web server"
  value       = module.web_server.private_ip
}

output "security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web.id
}
