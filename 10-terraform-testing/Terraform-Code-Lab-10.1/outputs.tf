# Topic 10 Lab: Terraform Testing & Validation
# outputs.tf - Output Values for Testing

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.testing[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of instances"
  value       = aws_instance.testing[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of instances"
  value       = aws_instance.testing[*].private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.testing.id
}

output "security_group_name" {
  description = "Security group name"
  value       = aws_security_group.testing.name
}

output "instance_monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = aws_instance.testing[*].monitoring
}

output "instance_ebs_optimized" {
  description = "Whether EBS optimization is enabled"
  value       = aws_instance.testing[*].ebs_optimized
}

output "cloudwatch_alarm_names" {
  description = "CloudWatch alarm names"
  value       = aws_cloudwatch_metric_alarm.cpu[*].alarm_name
}

output "test_results" {
  description = "Summary of test results"
  value = {
    instances_created      = length(aws_instance.testing)
    monitoring_enabled     = all(aws_instance.testing[*].monitoring)
    ebs_optimized          = all(aws_instance.testing[*].ebs_optimized)
    security_group_created = aws_security_group.testing.id != ""
    alarms_created         = length(aws_cloudwatch_metric_alarm.cpu)
  }
}

