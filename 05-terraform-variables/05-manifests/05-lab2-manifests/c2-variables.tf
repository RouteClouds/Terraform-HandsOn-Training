# Input Variables
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# Complex type with validation
variable "instance_config" {
  description = "EC2 instance configuration"
  type = object({
    instance_type = string
    environment   = string
    count        = number
    ami_id       = string
  })

  validation {
    condition     = contains(["dev", "staging", "prod"], var.instance_config.environment)
    error_message = "Environment must be dev, staging, or prod."
  }

  validation {
    condition     = can(regex("^t2\\.", var.instance_config.instance_type))
    error_message = "Instance type must be t2 series."
  }
}

# List type with validation
variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(number)
  default     = [80, 443, 22]

  validation {
    condition     = alltrue([for port in var.allowed_ports : port > 0 && port < 65536])
    error_message = "Port numbers must be between 1 and 65535."
  }
}

# Map type
variable "instance_tags" {
  description = "Tags for EC2 instances"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-labs"
    ManagedBy   = "terraform"
  }
} 