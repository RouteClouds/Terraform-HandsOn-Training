# State Storage Outputs
output "state_bucket_id" {
  description = "ID of the state bucket"
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the state bucket"
  value       = aws_s3_bucket.state.arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB lock table"
  value       = aws_dynamodb_table.state_lock.id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB lock table"
  value       = aws_dynamodb_table.state_lock.arn
}

# Example Resource Outputs
output "vpc_id" {
  description = "ID of the example VPC"
  value       = aws_vpc.example.id
}

output "subnet_id" {
  description = "ID of the example subnet"
  value       = aws_subnet.example.id
}

# State Configuration Details
output "state_config" {
  description = "State configuration details"
  value = {
    backend = {
      bucket         = aws_s3_bucket.state.id
      dynamodb_table = aws_dynamodb_table.state_lock.id
      region         = var.aws_region
    }
    versioning = {
      enabled = true
      type    = "S3"
    }
    encryption = {
      enabled    = true
      algorithm  = "AES256"
    }
  }
} 