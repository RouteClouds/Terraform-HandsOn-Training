# Root Module - Provider Configuration

terraform {
  required_version = ">= 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
  
  # Optional: Configure remote backend
  # backend "s3" {
  #   bucket         = "terraform-state-modular-infrastructure"
  #   key            = "project-2/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Modular Infrastructure"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

