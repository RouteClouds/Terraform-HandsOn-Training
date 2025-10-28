# Variables for State Backend

variable "aws_region" {
  description = "AWS region for state backend"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "Multi-Environment-Pipeline"
}

variable "notification_email" {
  description = "Email address for state change notifications"
  type        = string
  default     = ""
}

