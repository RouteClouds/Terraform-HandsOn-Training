# Output Values
output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.my_ec2.id
}

output "public_ip" {
  description = "EC2 Instance Public IP"
  value       = aws_instance.my_ec2.public_ip
}

output "private_ip" {
  description = "EC2 Instance Private IP"
  value       = aws_instance.my_ec2.private_ip
} 