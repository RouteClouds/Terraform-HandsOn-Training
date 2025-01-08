# VPC Outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.dev_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.dev_vpc.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.dev_vpc.arn
}

# Subnet Outputs
output "subnet_id" {
  description = "ID of the created subnet"
  value       = aws_subnet.dev_subnet.id
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = aws_subnet.dev_subnet.cidr_block
}

output "subnet_arn" {
  description = "ARN of the subnet"
  value       = aws_subnet.dev_subnet.arn
}

# Additional Information
output "vpc_details" {
  description = "Complete VPC information"
  value = {
    id                  = aws_vpc.dev_vpc.id
    cidr_block         = aws_vpc.dev_vpc.cidr_block
    enable_dns         = aws_vpc.dev_vpc.enable_dns_support
    enable_dns_hostnames = aws_vpc.dev_vpc.enable_dns_hostnames
    tags               = aws_vpc.dev_vpc.tags
  }
}

output "environment_details" {
  description = "Environment configuration details"
  value = {
    environment = var.environment
    region      = var.aws_region
    project     = var.project_name
  }
} 