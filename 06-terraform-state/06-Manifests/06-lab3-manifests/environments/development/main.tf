provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    # These values must be provided via backend configuration
    # bucket         = "terraform-state-xxxxx"
    # key            = "development/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-locks"
    # encrypt        = true
  }
}

locals {
  environment = terraform.workspace
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = "State-Management-Lab3"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment          = local.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  common_tags         = local.common_tags
} 