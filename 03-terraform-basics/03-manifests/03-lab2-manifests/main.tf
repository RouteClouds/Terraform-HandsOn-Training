# ==========================================================================
# Lab 2: Working with Variables and VPC Resources
# ==========================================================================
# Purpose: Demonstrate variable usage and VPC configuration
# Features:
# - Advanced variable usage
# - VPC and subnet creation
# - Resource tagging strategies
# - Network configuration
# ==========================================================================

# Provider Configuration
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
# Creates a Virtual Private Cloud with DNS support
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr            # CIDR from variables
  enable_dns_hostnames = true                    # Enable DNS hostnames
  enable_dns_support   = true                    # Enable DNS support

  tags = {
    Name        = "${var.environment}-vpc"       # Dynamic naming
    Environment = var.environment               # Environment tag
    Project     = var.project_name              # Project tag
  }
}

# Public Subnet
# Creates a public subnet within the VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id      # Reference to VPC
  cidr_block              = var.subnet_cidr      # CIDR from variables
  map_public_ip_on_launch = true                # Auto-assign public IPs

  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
    Project     = var.project_name
  }
} 