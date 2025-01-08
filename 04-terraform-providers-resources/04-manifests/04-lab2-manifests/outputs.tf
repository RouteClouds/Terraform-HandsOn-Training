# S3 Bucket Outputs
output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.demo.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.demo.arn
}

output "bucket_versioning_status" {
  description = "The versioning status of the bucket"
  value       = aws_s3_bucket_versioning.demo.versioning_configuration[0].status
}

# IAM Role Outputs
output "role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.demo.name
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.demo.arn
}

# Security Group Outputs
output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.demo.id
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = aws_security_group.demo.arn
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.demo.name
} 