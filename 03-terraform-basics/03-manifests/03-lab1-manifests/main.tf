# ==========================================================================
# Lab 1: Basic Terraform Commands and S3 Bucket Creation
# ==========================================================================
# Purpose: Demonstrate basic Terraform usage with AWS S3
# Features:
# - Basic provider configuration
# - Simple resource creation
# - Random string generation
# - Resource tagging
# ==========================================================================

# Provider and Version Configuration
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"      # Official AWS provider
      version = "~> 4.0"             # Using version 4.x
    }
    random = {
      source  = "hashicorp/random"   # For generating unique names
      version = "~> 3.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region            # Region from variables
}

# Random String Generator
# Used to ensure globally unique S3 bucket names
resource "random_string" "random" {
  length  = 8                        # 8 characters for uniqueness
  special = false                    # No special characters
  upper   = false                    # No uppercase for S3 compatibility
}

# S3 Bucket Creation
# Demonstrates basic resource creation and tagging
resource "aws_s3_bucket" "demo" {
  bucket = "${var.project_name}-${var.environment}-${random_string.random.result}"

  tags = {
    Environment = var.environment    # From variables
    Project     = var.project_name   # From variables
    Created_By  = "Terraform"        # Static tag
  }
}

# S3 Bucket Versioning
# Demonstrates additional resource configuration
resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id     # Reference to bucket
  versioning_configuration {
    status = "Enabled"               # Enable versioning
  }
} 