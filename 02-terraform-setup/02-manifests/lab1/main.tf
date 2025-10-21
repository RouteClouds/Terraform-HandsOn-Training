# Basic Environment Setup - Main Configuration
terraform {
  required_version = "~> 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  # Optional: Specify profile if using AWS profiles
  # profile = var.aws_profile
  default_tags {
    tags = {
      Environment      = var.environment
      Project          = var.project_name
      ManagedBy        = "terraform"
      TerraformVersion = "1.13.x"
      ProviderVersion  = "6.12.x"
      TrainingModule   = "02-terraform-setup"
    }
  }
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