# Custom EC2 Instance Module - Outputs

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "ebs_volume_id" {
  description = "ID of the additional EBS volume"
  value       = var.create_ebs_volume ? aws_ebs_volume.this[0].id : null
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.this.instance_state
} 