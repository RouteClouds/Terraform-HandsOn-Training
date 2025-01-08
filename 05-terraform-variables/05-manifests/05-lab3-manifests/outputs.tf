output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "environment_info" {
  description = "Environment information"
  value = {
    name = var.environment
    vpc  = aws_vpc.main.id
    tags = var.common_tags
  }
} 