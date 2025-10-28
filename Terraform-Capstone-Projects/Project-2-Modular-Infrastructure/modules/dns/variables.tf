variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "create_hosted_zone" {
  description = "Create hosted zone"
  type        = bool
  default     = true
}

variable "hosted_zone_id" {
  description = "Existing hosted zone ID (if not creating new)"
  type        = string
  default     = null
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
  default     = null
}

variable "alb_zone_id" {
  description = "ALB zone ID"
  type        = string
  default     = null
}

variable "create_www_record" {
  description = "Create www subdomain record"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

