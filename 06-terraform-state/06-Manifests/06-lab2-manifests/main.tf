# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure Remote Backend
terraform {
  backend "s3" {
    # These values must be provided via backend configuration
    # bucket         = "terraform-state-xxxxx"
    # key            = "lab2/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-locks"
    # encrypt        = true
  }
}

# Base VPC for testing state operations
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "state-ops-test-vpc"
    }
  )
}

# Multiple subnets to demonstrate state operations
resource "aws_subnet" "subnets" {
  count             = length(var.subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "subnet-${count.index + 1}"
    }
  )
}

# Internet Gateway for state operation testing
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "state-ops-igw"
    }
  )
}

# Route table for demonstrating state moves
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "state-ops-rt"
    }
  )
} 