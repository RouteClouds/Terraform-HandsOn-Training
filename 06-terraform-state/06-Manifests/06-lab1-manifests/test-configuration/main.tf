# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure Remote Backend
terraform {
  backend "s3" {
    # These values must be provided via backend configuration
    # bucket         = "terraform-state-xxxxx"
    # key            = "lab1/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-locks"
    # encrypt        = true
  }
}

# Test VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "state-management-test-vpc"
    }
  )
}

# Test Subnet Resource
resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  tags = merge(
    var.common_tags,
    {
      Name = "state-management-test-subnet"
    }
  )
} 