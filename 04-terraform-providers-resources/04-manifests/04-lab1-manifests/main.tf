# Provider Configuration Lab

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Default provider configuration
provider "aws" {
  region = var.aws_region
}

# Provider with static credentials (demo only)
provider "aws" {
  alias  = "static"
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Provider with assume role
provider "aws" {
  alias  = "assumed_role"
  region = var.aws_region
  assume_role {
    role_arn = var.assume_role_arn
  }
}

# Test resource using default provider
resource "aws_s3_bucket" "default_provider" {
  bucket = "${var.project_name}-default-${random_string.suffix.result}"
}

# Test resource using static credentials
resource "aws_s3_bucket" "static_provider" {
  provider = aws.static
  bucket   = "${var.project_name}-static-${random_string.suffix.result}"
}

# Test resource using assumed role
resource "aws_s3_bucket" "assumed_role_provider" {
  provider = aws.assumed_role
  bucket   = "${var.project_name}-assumed-${random_string.suffix.result}"
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
} 