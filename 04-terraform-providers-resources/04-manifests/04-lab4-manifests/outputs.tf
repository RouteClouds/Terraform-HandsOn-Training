# Count Example Outputs
output "count_instance_ids" {
  description = "IDs of instances created using count"
  value       = aws_instance.count_example[*].id
}

output "count_instance_ips" {
  description = "Public IPs of instances created using count"
  value       = aws_instance.count_example[*].public_ip
}

# For_Each Map Example Outputs
output "foreach_map_instance_ids" {
  description = "IDs of instances created using for_each map"
  value       = {
    for k, v in aws_instance.foreach_map_example : k => v.id
  }
}

output "foreach_map_instance_ips" {
  description = "Public IPs of instances created using for_each map"
  value       = {
    for k, v in aws_instance.foreach_map_example : k => v.public_ip
  }
}

# For_Each Set Example Outputs
output "bucket_names" {
  description = "Names of created S3 buckets"
  value       = {
    for k, v in aws_s3_bucket.foreach_set_example : k => v.id
  }
}

# Dependent Instance Outputs
output "dependent_instance_ids" {
  description = "IDs of dependent instances"
  value       = aws_instance.dependent_example[*].id
}

# Lifecycle Example Output
output "lifecycle_instance_id" {
  description = "ID of lifecycle example instance"
  value       = aws_instance.lifecycle_example.id
} 