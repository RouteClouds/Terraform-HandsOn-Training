# Outputs for State Backend

output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "backup_bucket_name" {
  description = "Name of the S3 bucket for state backups"
  value       = aws_s3_bucket.state_backups.id
}

output "dynamodb_table_names" {
  description = "Names of DynamoDB tables for state locking"
  value = {
    for env, table in aws_dynamodb_table.terraform_locks : env => table.name
  }
}

output "sns_topic_arn" {
  description = "ARN of SNS topic for state notifications"
  value       = aws_sns_topic.state_notifications.arn
}

output "backend_config_dev" {
  description = "Backend configuration for dev environment"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "dev/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks["dev"].name
  }
}

output "backend_config_staging" {
  description = "Backend configuration for staging environment"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "staging/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks["staging"].name
  }
}

output "backend_config_prod" {
  description = "Backend configuration for prod environment"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "prod/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks["prod"].name
  }
}

