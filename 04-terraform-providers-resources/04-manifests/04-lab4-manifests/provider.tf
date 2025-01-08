# AWS Provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Environment = "meta-arguments"
        Project     = var.project_name
        Terraform   = "true"
        Lab         = "Meta-Arguments and Lifecycle"
      }
    )
  }
}

# Random provider configuration
provider "random" {}

# Provider configuration validation
data "aws_availability_zones" "available" {
  state = "available"
}

# AMI validation
data "aws_ami" "validate_ami" {
  owners = ["amazon"]
  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

locals {
  # Validate instance types
  validate_instance_types = {
    for k, v in var.instance_config :
    k => contains(["t2.micro", "t2.small", "t2.medium"], v.instance_type)
  }

  # Validate environments
  validate_environments = {
    for k, v in var.instance_config :
    k => contains(["development", "staging", "production"], v.environment)
  }

  # Validate bucket names
  validate_bucket_names = {
    for name in var.bucket_names :
    name => (
      length(name) >= 3 &&
      length(name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", name))
    )
  }

  # Validate instance count
  validate_instance_count = var.instance_count > 0 && var.instance_count <= 5

  # Validate project name format
  validate_project_name = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))

  # Validate required tags
  required_tags = ["Owner", "Environment", "Project"]
  validate_tags = alltrue([
    for tag in local.required_tags : contains(keys(var.tags), tag)
  ])

  # Validate AWS region
  validate_region = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))

  # Validate environment naming consistency
  environment_consistency = alltrue([
    for k, v in var.instance_config :
    v.environment == lower(v.environment)
  ])

  # Validate instance type progression
  instance_type_sizes = {
    "t2.micro"  = 1
    "t2.small"  = 2
    "t2.medium" = 3
  }
  validate_instance_progression = alltrue([
    for k, v in var.instance_config :
    k == "dev" ? true : (
      k == "staging" ? local.instance_type_sizes[v.instance_type] >= local.instance_type_sizes[var.instance_config["dev"].instance_type] : (
        k == "prod" ? local.instance_type_sizes[v.instance_type] >= local.instance_type_sizes[var.instance_config["staging"].instance_type] : true
      )
    )
  ])

  # Ensure all validations pass
  validations_pass = alltrue([
    alltrue([for v in local.validate_instance_types : v]),
    alltrue([for v in local.validate_environments : v]),
    alltrue([for v in local.validate_bucket_names : v]),
    local.validate_instance_count,
    local.validate_project_name,
    local.validate_tags,
    local.validate_region,
    local.environment_consistency,
    local.validate_instance_progression
  ])
}

# Validation checks
resource "null_resource" "validations" {
  lifecycle {
    precondition {
      condition     = local.validations_pass
      error_message = "One or more validation checks failed. Please check your configuration."
    }
  }
}

# Additional validation messages
output "validation_warnings" {
  value = {
    instance_types = {
      for k, v in local.validate_instance_types :
      k => v ? "Valid" : "Invalid instance type specified"
    }
    environments = {
      for k, v in local.validate_environments :
      k => v ? "Valid" : "Invalid environment specified"
    }
    bucket_names = {
      for k, v in local.validate_bucket_names :
      k => v ? "Valid" : "Invalid bucket name format"
    }
    project_name    = local.validate_project_name ? "Valid" : "Invalid project name format"
    tags           = local.validate_tags ? "All required tags present" : "Missing required tags"
    region         = local.validate_region ? "Valid region format" : "Invalid region format"
    instance_sizes = local.validate_instance_progression ? "Valid instance size progression" : "Invalid instance size progression"
  }
} 