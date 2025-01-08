# AWS Region Configuration
variable "aws_region" {
  description = "AWS Region for resource creation. Ensure this matches your backend configuration."
  type        = string
  default     = "us-east-1"
}

# Environment Settings
variable "environment" {
  description = <<-EOT
    Environment name for resource tagging and naming.
    Allowed values: dev, staging, prod
    This helps maintain consistency across resources.
  EOT
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Project Identification
variable "project_name" {
  description = <<-EOT
    Project name used for resource naming and tagging.
    This should be consistent across all related resources.
    Format: lowercase with hyphens
  EOT
  type        = string
  default     = "terraform-basics"
}

# State Management Configuration
variable "state_bucket_name" {
  description = <<-EOT
    Name of the S3 bucket for Terraform state storage.
    Requirements:
    - Must be globally unique
    - Should follow naming conventions
    - Should reflect environment and purpose
  EOT
  type        = string
  default     = "terraform-state-management-lab"
}

variable "dynamodb_table_name" {
  description = <<-EOT
    Name of the DynamoDB table used for state locking.
    This table prevents concurrent state modifications.
    Format: project-environment-state-lock
  EOT
  type        = string
  default     = "terraform-state-lock"
}

# Network Configuration
variable "vpc_cidr" {
  description = <<-EOT
    CIDR block for VPC creation.
    Format: x.x.x.x/16
    Example: 10.0.0.0/16
    Ensure this doesn't overlap with existing VPCs.
  EOT
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "subnet_cidr" {
  description = <<-EOT
    CIDR block for subnet creation.
    Must be within VPC CIDR range.
    Format: x.x.x.x/24
    Example: 10.0.1.0/24
  EOT
  type        = string
  default     = "10.0.1.0/24"
  
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
} 