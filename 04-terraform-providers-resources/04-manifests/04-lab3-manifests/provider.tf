# AWS Provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Environment = var.environment
        Project     = var.project_name
        Terraform   = "true"
        Lab         = "Dependencies"
      }
    )
  }
}

# Provider configuration validation
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Validate availability zone exists in region
  validate_az = index(data.aws_availability_zones.available.names, var.availability_zone) >= 0
} 