# Topic 9 Lab: Terraform Import & State Manipulation
# providers.tf - AWS Provider Configuration

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Uncomment for remote state (optional)
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "topic-9/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "Terraform-Training"
      Topic       = "Topic-9-Import"
      ManagedBy   = "Terraform"
    }
  }
}

