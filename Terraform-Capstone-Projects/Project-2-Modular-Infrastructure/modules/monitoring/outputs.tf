output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "log_group_name" {
  description = "Log group name"
  value       = aws_cloudwatch_log_group.main.name
}

output "log_group_arn" {
  description = "Log group ARN"
  value       = aws_cloudwatch_log_group.main.arn
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = var.alarm_email != null ? aws_sns_topic.alarms[0].arn : null
}

