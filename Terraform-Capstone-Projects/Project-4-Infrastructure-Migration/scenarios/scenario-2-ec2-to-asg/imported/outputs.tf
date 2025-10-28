# Outputs for Scenario 2: EC2 to ASG Conversion

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.web.arn
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.web.id
}

output "launch_template_latest_version" {
  description = "Launch Template latest version"
  value       = aws_launch_template.web.latest_version
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.web.id
}

output "migration_status" {
  description = "Migration status message"
  value       = "EC2 instances successfully converted to Auto Scaling Group"
}

