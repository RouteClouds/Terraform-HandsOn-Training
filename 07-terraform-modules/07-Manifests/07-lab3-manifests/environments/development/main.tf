# Development Environment Configuration

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Terraform-Modules"
      Environment = "development"
      Terraform   = "true"
    }
  }
}

module "app_stack" {
  source = "../../modules/app-stack"

  environment         = "development"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

  instance_count = 1
  instance_type  = "t2.micro"
  key_name       = var.key_name
  admin_cidr     = var.admin_cidr

  tags = {
    Owner = "DevTeam"
  }
} 