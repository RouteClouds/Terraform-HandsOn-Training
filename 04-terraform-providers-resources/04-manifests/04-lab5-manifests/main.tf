# Multiple Provider Configurations Lab

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Primary Provider (us-east-1)
provider "aws" {
  region = var.primary_region
}

# Secondary Provider (us-west-2)
provider "aws" {
  alias  = "west"
  region = var.secondary_region
}

# VPC in Primary Region
resource "aws_vpc" "primary" {
  cidr_block           = var.primary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-primary-vpc"
  }
}

# VPC in Secondary Region
resource "aws_vpc" "secondary" {
  provider             = aws.west
  cidr_block           = var.secondary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-secondary-vpc"
  }
}

# S3 Bucket in Primary Region
resource "aws_s3_bucket" "primary" {
  bucket = "${var.project_name}-primary-${random_string.suffix.result}"

  tags = {
    Name = "${var.project_name}-primary-bucket"
  }
}

# S3 Bucket in Secondary Region
resource "aws_s3_bucket" "secondary" {
  provider = aws.west
  bucket   = "${var.project_name}-secondary-${random_string.suffix.result}"

  tags = {
    Name = "${var.project_name}-secondary-bucket"
  }
}

# EC2 Instance in Primary Region
resource "aws_instance" "primary" {
  ami           = var.primary_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-primary-instance"
  }
}

# EC2 Instance in Secondary Region
resource "aws_instance" "secondary" {
  provider      = aws.west
  ami           = var.secondary_ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-secondary-instance"
  }
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "primary_to_secondary" {
  vpc_id      = aws_vpc.primary.id
  peer_vpc_id = aws_vpc.secondary.id
  peer_region = var.secondary_region
  auto_accept = false

  tags = {
    Name = "${var.project_name}-peering-connection"
  }
}

# VPC Peering Connection Accepter
resource "aws_vpc_peering_connection_accepter" "secondary_accepter" {
  provider                  = aws.west
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept              = true

  tags = {
    Name = "${var.project_name}-peering-accepter"
  }
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
} 