# Outputs for Monitoring Module

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = aws_cloudtrail.main.id
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.id
}

output "application_log_group_name" {
  description = "CloudWatch Log Group name for application logs"
  value       = aws_cloudwatch_log_group.application.name
}

output "security_log_group_name" {
  description = "CloudWatch Log Group name for security logs"
  value       = aws_cloudwatch_log_group.security.name
}

output "alarms_topic_arn" {
  description = "SNS topic ARN for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "Security Hub account ID"
  value       = aws_securityhub_account.main.id
}

output "config_recorder_id" {
  description = "AWS Config recorder ID"
  value       = aws_config_configuration_recorder.main.id
}

output "config_bucket_name" {
  description = "S3 bucket name for Config logs"
  value       = aws_s3_bucket.config.id
}

