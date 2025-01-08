# State Bucket Outputs
output "state_bucket_id" {
  description = "ID of the Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "state_bucket_domain_name" {
  description = "Domain name of the state bucket"
  value       = aws_s3_bucket.terraform_state.bucket_domain_name
}

# Versioning Status
output "bucket_versioning_status" {
  description = "Versioning status of the state bucket"
  value       = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status
}

# DynamoDB Outputs
output "dynamodb_table_id" {
  description = "ID of the DynamoDB lock table"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB lock table"
  value       = aws_dynamodb_table.terraform_locks.arn
}

# Backend Configuration
output "backend_config" {
  description = "Backend configuration details"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    region         = var.aws_region
  }
}

# Account Information
output "account_info" {
  description = "AWS account information"
  value = {
    account_id = local.account_id
    region     = var.aws_region
  }
} 