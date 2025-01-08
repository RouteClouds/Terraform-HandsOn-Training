# Basic Environment Setup - Main Configuration
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
  
  # Optional: Specify profile if using AWS profiles
  # profile = var.aws_profile
}

# Test resource to verify setup
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.project_name}-${var.environment}-test"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
} 