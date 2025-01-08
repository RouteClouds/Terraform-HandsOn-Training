variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-setup"
}

# Optional: for AWS profile configuration
variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "default"
} 