variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-meta-args-lab"
}

# Count Example Variables
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 3

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

# For_Each Example Variables
variable "instance_config" {
  description = "Configuration for instances using for_each"
  type = map(object({
    instance_type = string
    environment   = string
  }))
  default = {
    "dev" = {
      instance_type = "t2.micro"
      environment   = "development"
    },
    "staging" = {
      instance_type = "t2.small"
      environment   = "staging"
    },
    "prod" = {
      instance_type = "t2.medium"
      environment   = "production"
    }
  }
}

variable "bucket_names" {
  description = "List of bucket names for for_each example"
  type        = list(string)
  default     = ["logs", "backups", "data"]
}

# Common Variables
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
}

variable "instance_type" {
  description = "Default instance type"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
} 