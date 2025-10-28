variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN"
  type        = string
  default     = null
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  type        = string
  default     = null
}

variable "db_instance_id" {
  description = "DB instance ID"
  type        = string
  default     = null
}

variable "alarm_email" {
  description = "Email for alarm notifications"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

