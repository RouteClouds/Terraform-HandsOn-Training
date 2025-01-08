output "instance_ids" {
  description = "IDs of created EC2 instances"
  value       = aws_instance.example[*].id
}

output "instance_public_ips" {
  description = "Public IPs of created EC2 instances"
  value       = aws_instance.example[*].public_ip
}

output "security_group_id" {
  description = "ID of created security group"
  value       = aws_security_group.example.id
} 