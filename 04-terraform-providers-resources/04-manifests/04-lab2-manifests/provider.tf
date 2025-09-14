# AWS Provider configuration
provider "aws" {
  region = "us-east-1"

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