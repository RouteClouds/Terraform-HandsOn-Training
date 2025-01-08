# Application Load Balancer Module - Variables

variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "instance_ids" {
  description = "List of instance IDs to attach to target group"
  type        = list(string)
}

# Optional variables with defaults
variable "internal" {
  description = "Whether ALB is internal"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Protocol for target group"
  type        = string
  default     = "HTTP"
}

variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "certificate_arn" {
  description = "ARN of SSL certificate"
  type        = string
  default     = null
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout"
  type        = number
  default     = 5
}

variable "health_check_threshold" {
  description = "Health check threshold"
  type        = number
  default     = 2
}

variable "health_check_codes" {
  description = "Health check success codes"
  type        = string
  default     = "200"
}

variable "enable_access_logs" {
  description = "Enable access logs"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
} 