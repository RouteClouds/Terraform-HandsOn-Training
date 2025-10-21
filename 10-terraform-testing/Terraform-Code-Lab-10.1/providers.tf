# Topic 10 Lab: Terraform Testing & Validation
# providers.tf - AWS Provider Configuration

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "Terraform-Training"
      Topic       = "Topic-10-Testing"
      ManagedBy   = "Terraform"
    }
  }
}

