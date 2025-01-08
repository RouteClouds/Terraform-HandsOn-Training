# AWS Provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Terraform   = "true"
      Lab         = "Resource Creation"
    }
  }
}

# Random provider configuration
provider "random" {} 