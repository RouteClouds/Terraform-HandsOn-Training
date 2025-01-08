# Production Environment Configuration

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Terraform-Modules"
      Environment = "production"
      Terraform   = "true"
    }
  }
}

module "app_stack" {
  source = "../../modules/app-stack"

  environment         = "production"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

  instance_count = 2
  instance_type  = "t2.small"
  key_name       = var.key_name
  admin_cidr     = var.admin_cidr

  certificate_arn    = var.certificate_arn
  access_logs_bucket = var.access_logs_bucket

  tags = {
    Owner = "ProdTeam"
  }
} 