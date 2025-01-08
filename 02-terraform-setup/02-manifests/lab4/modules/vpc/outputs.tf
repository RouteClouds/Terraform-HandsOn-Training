# VPC Module Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.public.cidr_block
}

output "network_details" {
  description = "Complete network configuration details"
  value = {
    vpc = {
      id         = aws_vpc.main.id
      cidr_block = aws_vpc.main.cidr_block
      dns_support = aws_vpc.main.enable_dns_support
      tags       = aws_vpc.main.tags
    }
    public_subnet = {
      id         = aws_subnet.public.id
      cidr_block = aws_subnet.public.cidr_block
      tags       = aws_subnet.public.tags
    }
  }
} 