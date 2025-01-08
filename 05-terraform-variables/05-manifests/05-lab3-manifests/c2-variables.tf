# Input Variables
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Network Variables
variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR Blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}

# Tag Variables
variable "common_tags" {
  description = "Common Tags for Resources"
  type        = map(string)
} 