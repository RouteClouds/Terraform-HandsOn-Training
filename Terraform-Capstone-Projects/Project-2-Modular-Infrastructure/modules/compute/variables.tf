# Compute Module Variables

# Required Variables
variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
  
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 50
    error_message = "Name prefix must be between 1 and 50 characters."
  }
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  
  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must be a valid VPC identifier."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for instances"
  type        = list(string)
  
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "Must specify at least one subnet ID."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  
  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "Must specify at least one security group ID."
  }
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

# Optional Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID (uses latest Amazon Linux 2023 if not specified)"
  type        = string
  default     = null
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
  
  validation {
    condition     = var.min_size >= 0 && var.min_size <= 100
    error_message = "Minimum size must be between 0 and 100."
  }
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 6
  
  validation {
    condition     = var.max_size >= 1 && var.max_size <= 100
    error_message = "Maximum size must be between 1 and 100."
  }
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
  
  validation {
    condition     = var.desired_capacity >= 0 && var.desired_capacity <= 100
    error_message = "Desired capacity must be between 0 and 100."
  }
}

variable "enable_scaling" {
  description = "Enable auto scaling policies"
  type        = bool
  default     = true
}

variable "scale_up_cpu_threshold" {
  description = "CPU threshold for scaling up (%)"
  type        = number
  default     = 75
  
  validation {
    condition     = var.scale_up_cpu_threshold >= 0 && var.scale_up_cpu_threshold <= 100
    error_message = "CPU threshold must be between 0 and 100."
  }
}

variable "scale_down_cpu_threshold" {
  description = "CPU threshold for scaling down (%)"
  type        = number
  default     = 25
  
  validation {
    condition     = var.scale_down_cpu_threshold >= 0 && var.scale_down_cpu_threshold <= 100
    error_message = "CPU threshold must be between 0 and 100."
  }
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

