# Standard Provider Configuration Template
# Use this template for all Terraform configurations

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"  # MANDATORY: Latest stable version
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"   # Latest stable version
    }
  }
  required_version = "~> 1.13.0"  # MANDATORY: Latest stable version
}

# Provider configuration with authentication and standardized region
provider "aws" {
  region = "us-east-1"  # MANDATORY: Standardized region for all labs

  default_tags {
    tags = {
      Environment      = var.environment
      Project          = var.project_name
      ManagedBy        = "terraform"
      TerraformVersion = "1.13.x"
      ProviderVersion  = "6.12.x"
      CreatedDate      = timestamp()
      TrainingModule   = var.training_module
    }
  }
}

# Standard variables that should be included in all configurations
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-training"
}

variable "training_module" {
  description = "Training module identifier"
  type        = string
  default     = "aws-terraform-training"
}

variable "aws_region" {
  description = "AWS region for creating resources"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "All training resources must be created in us-east-1 region for consistency."
  }
}
