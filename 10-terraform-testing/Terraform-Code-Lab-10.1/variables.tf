# Topic 10 Lab: Terraform Testing & Validation
# variables.tf - Input Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "lab"], var.environment)
    error_message = "Environment must be dev, staging, prod, or lab."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring (required for testing)"
  type        = bool
  default     = true
  
  validation {
    condition     = var.enable_monitoring == true
    error_message = "Monitoring must be enabled for compliance."
  }
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default = {
    Owner       = "Terraform-Training"
    CostCenter  = "Engineering"
  }
}

