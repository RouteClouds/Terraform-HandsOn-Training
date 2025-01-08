output "default_bucket_name" {
  description = "Name of bucket created with default provider"
  value       = aws_s3_bucket.default_provider.id
}

output "static_bucket_name" {
  description = "Name of bucket created with static credentials"
  value       = aws_s3_bucket.static_provider.id
}

output "assumed_role_bucket_name" {
  description = "Name of bucket created with assumed role"
  value       = aws_s3_bucket.assumed_role_provider.id
} 