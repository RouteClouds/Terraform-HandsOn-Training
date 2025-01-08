# Primary Region Outputs
output "primary_vpc_id" {
  description = "ID of the VPC in primary region"
  value       = aws_vpc.primary.id
}

output "primary_vpc_cidr" {
  description = "CIDR block of the VPC in primary region"
  value       = aws_vpc.primary.cidr_block
}

output "primary_instance_id" {
  description = "ID of EC2 instance in primary region"
  value       = aws_instance.primary.id
}

output "primary_bucket_name" {
  description = "Name of S3 bucket in primary region"
  value       = aws_s3_bucket.primary.id
}

# Secondary Region Outputs
output "secondary_vpc_id" {
  description = "ID of the VPC in secondary region"
  value       = aws_vpc.secondary.id
}

output "secondary_vpc_cidr" {
  description = "CIDR block of the VPC in secondary region"
  value       = aws_vpc.secondary.cidr_block
}

output "secondary_instance_id" {
  description = "ID of EC2 instance in secondary region"
  value       = aws_instance.secondary.id
}

output "secondary_bucket_name" {
  description = "Name of S3 bucket in secondary region"
  value       = aws_s3_bucket.secondary.id
}

# VPC Peering Outputs
output "peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.primary_to_secondary.id
}

output "peering_connection_status" {
  description = "Status of the VPC peering connection"
  value       = aws_vpc_peering_connection.primary_to_secondary.accept_status
} 