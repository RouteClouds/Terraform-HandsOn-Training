output "docs_bucket_name" {
  description = "Name of the documentation S3 bucket"
  value       = aws_s3_bucket.docs.id
}

output "docs_bucket_arn" {
  description = "ARN of the documentation S3 bucket"
  value       = aws_s3_bucket.docs.arn
}

output "bucket_versioning_status" {
  description = "Versioning status of the S3 bucket"
  value       = aws_s3_bucket_versioning.docs.versioning_configuration[0].status
}

output "bucket_region" {
  description = "Region where the bucket is created"
  value       = aws_s3_bucket.docs.region
}

output "iam_role_arn" {
  description = "ARN of IAM role for docs access"
  value       = aws_iam_role.docs_access.arn
}

output "encryption_status" {
  description = "Encryption configuration of the bucket"
  value       = aws_s3_bucket_server_side_encryption_configuration.docs.rule[0].apply_server_side_encryption_by_default.sse_algorithm
}

output "public_access_block_status" {
  description = "Public access block configuration"
  value       = {
    block_public_acls       = aws_s3_bucket_public_access_block.docs.block_public_acls
    block_public_policy     = aws_s3_bucket_public_access_block.docs.block_public_policy
    ignore_public_acls      = aws_s3_bucket_public_access_block.docs.ignore_public_acls
    restrict_public_buckets = aws_s3_bucket_public_access_block.docs.restrict_public_buckets
  }
} 