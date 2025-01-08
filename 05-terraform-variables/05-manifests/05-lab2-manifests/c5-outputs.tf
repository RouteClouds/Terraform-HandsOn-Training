# Output Values
output "instance_ids" {
  description = "IDs of created EC2 instances"
  value       = aws_instance.web_servers[*].id
}

output "instance_public_ips" {
  description = "Public IPs of created EC2 instances"
  value       = aws_instance.web_servers[*].public_ip
}

output "security_group_id" {
  description = "ID of created security group"
  value       = aws_security_group.web_server.id
}

output "instance_tags" {
  description = "Tags of the instances"
  value       = aws_instance.web_servers[*].tags
} 