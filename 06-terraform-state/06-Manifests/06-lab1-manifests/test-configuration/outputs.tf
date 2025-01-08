output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the created VPC"
  value       = aws_vpc.main.cidr_block
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = aws_subnet.example.id
}

output "subnet_cidr" {
  description = "CIDR block of the created subnet"
  value       = aws_subnet.example.cidr_block
} 