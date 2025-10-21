# Topic 11 Lab: Terraform Troubleshooting & Debugging
# outputs.tf - Output Values

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.troubleshooting[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of instances"
  value       = aws_instance.troubleshooting[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of instances"
  value       = aws_instance.troubleshooting[*].private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.troubleshooting.id
}

output "cloudwatch_alarm_names" {
  description = "CloudWatch alarm names"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization[*].alarm_name
}

output "troubleshooting_info" {
  description = "Information for troubleshooting"
  value = {
    instances_created = length(aws_instance.troubleshooting)
    monitoring_enabled = aws_instance.troubleshooting[0].monitoring
    security_group_id = aws_security_group.troubleshooting.id
    alarms_created = length(aws_cloudwatch_metric_alarm.cpu_utilization)
  }
}

