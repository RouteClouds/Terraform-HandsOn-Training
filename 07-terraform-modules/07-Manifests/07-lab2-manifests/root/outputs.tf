# Root Configuration - Outputs

output "instance_id" {
  description = "ID of the web server instance"
  value       = module.web_server.instance_id
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.public_ip
}

output "private_ip" {
  description = "Private IP of the web server"
  value       = module.web_server.private_ip
}

output "security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web.id
}

output "instance_state" {
  description = "Current state of the instance"
  value       = module.web_server.instance_state
} 