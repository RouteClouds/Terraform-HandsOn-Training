# Topic 12 Lab: Advanced Security & Compliance
# providers.tf - AWS Provider Configuration with Security

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Uncomment for secure remote state
  # backend "s3" {
  #   bucket         = "terraform-state-prod"
  #   key            = "prod/terraform.tfstate"
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
      Topic       = "Topic-12-Security"
      ManagedBy   = "Terraform"
      Compliance  = "PCI-DSS"
    }
  }
}

