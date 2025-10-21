# Topic 11 Lab: Terraform Troubleshooting & Debugging
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
      Topic       = "Topic-11-Troubleshooting"
      ManagedBy   = "Terraform"
    }
  }
}

