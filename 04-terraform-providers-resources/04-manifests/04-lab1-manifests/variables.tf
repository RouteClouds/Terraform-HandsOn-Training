variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-provider-lab"
}

variable "aws_access_key" {
  description = "AWS Access Key (for demo only)"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key (for demo only)"
  type        = string
  sensitive   = true
}

variable "assume_role_arn" {
  description = "ARN of role to assume"
  type        = string
} 