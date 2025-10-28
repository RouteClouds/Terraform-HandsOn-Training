# Terraform and Provider Configuration
# Project 1: Multi-Tier Web Application Infrastructure

terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
  
  # Remote State Backend Configuration
  # Note: Create S3 bucket and DynamoDB table manually before using this backend
  backend "s3" {
    bucket         = "terraform-state-capstone-projects"  # Change this to your bucket name
    key            = "project-1/multi-tier-web-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"  # Change this to your table name
    
    # Optional: Enable versioning on the S3 bucket for state history
    # Optional: Enable server-side encryption with KMS
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
  
  # Default tags applied to all resources
  default_tags {
    tags = {
      Project     = "Terraform-Capstone-Project-1"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = "DevOps-Team"
      CostCenter  = "Training"
      Repository  = "Terraform-HandsOn-Training"
    }
  }
}

