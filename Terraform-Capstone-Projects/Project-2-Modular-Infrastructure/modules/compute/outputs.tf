# Compute Module Outputs

# Auto Scaling Group Outputs
output "autoscaling_group_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.main.id
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.main.arn
}

output "autoscaling_group_min_size" {
  description = "Auto Scaling Group minimum size"
  value       = aws_autoscaling_group.main.min_size
}

output "autoscaling_group_max_size" {
  description = "Auto Scaling Group maximum size"
  value       = aws_autoscaling_group.main.max_size
}

output "autoscaling_group_desired_capacity" {
  description = "Auto Scaling Group desired capacity"
  value       = aws_autoscaling_group.main.desired_capacity
}

# Launch Template Outputs
output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.main.id
}

output "launch_template_arn" {
  description = "Launch Template ARN"
  value       = aws_launch_template.main.arn
}

output "launch_template_latest_version" {
  description = "Launch Template latest version"
  value       = aws_launch_template.main.latest_version
}

output "launch_template_name" {
  description = "Launch Template name"
  value       = aws_launch_template.main.name
}

# Scaling Policy Outputs
output "scale_up_policy_arn" {
  description = "Scale up policy ARN"
  value       = var.enable_scaling ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "Scale down policy ARN"
  value       = var.enable_scaling ? aws_autoscaling_policy.scale_down[0].arn : null
}

# CloudWatch Alarm Outputs
output "cpu_high_alarm_arn" {
  description = "CPU high alarm ARN"
  value       = var.enable_scaling ? aws_cloudwatch_metric_alarm.cpu_high[0].arn : null
}

output "cpu_low_alarm_arn" {
  description = "CPU low alarm ARN"
  value       = var.enable_scaling ? aws_cloudwatch_metric_alarm.cpu_low[0].arn : null
}

