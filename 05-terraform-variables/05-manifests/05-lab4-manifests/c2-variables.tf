# Input Variables
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Database Variables (Sensitive)
variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

# Database Configuration
variable "db_config" {
  description = "Database configuration"
  type = object({
    instance_class    = string
    allocated_storage = number
    engine_version    = string
    db_name          = string
  })
  default = {
    instance_class    = "db.t3.micro"
    allocated_storage = 20
    engine_version    = "8.0.28"
    db_name          = "myappdb"
  }
}

# Tag Variables
variable "common_tags" {
  description = "Common Tags for Resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Project   = "terraform-labs"
  }
} 