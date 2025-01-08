# ==========================================================================
# Lab 3: Resource Dependencies and Network Infrastructure
# ==========================================================================
# Purpose: Demonstrate resource dependencies and network setup
# Features:
# - Explicit and implicit dependencies
# - Complete VPC networking
# - Security group configuration
# - EC2 instance deployment
# ==========================================================================

# Configure Terraform and Providers
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Resource
# Primary network container for all resources
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Internet Gateway
# Enables internet connectivity for the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Public Subnet
# Network segment for public-facing resources
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table
# Defines routing rules for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table Association
# Links the public subnet with the route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
# Firewall rules for the web server
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.main]

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# EC2 Instance
# Web server instance
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.web.id]

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==========================================================================
# Resource Dependencies Overview:
# 1. VPC must exist before:
#    - Internet Gateway
#    - Subnet
#    - Route Table
#    - Security Group
# 2. Internet Gateway must exist before:
#    - Route Table (for routes)
#    - EC2 Instance (for internet access)
# 3. Subnet must exist before:
#    - EC2 Instance
# 4. Security Group must exist before:
#    - EC2 Instance
# ========================================================================== 