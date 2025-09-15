# ============================================================================
# VARIABLE DEFINITIONS
# Topic 8: Advanced State Management with AWS
# ============================================================================

# ============================================================================
# BASIC CONFIGURATION VARIABLES
# ============================================================================

variable "student_name" {
  description = "Name of the student or practitioner completing this lab"
  type        = string
  
  validation {
    condition     = length(var.student_name) > 0 && length(var.student_name) <= 50
    error_message = "Student name must be between 1 and 50 characters."
  }
}

variable "organization" {
  description = "Organization name for resource naming and tagging"
  type        = string
  default     = "terraform-training"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.organization))
    error_message = "Organization name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project_name" {
  description = "Name of the project for resource identification and cost tracking"
  type        = string
  default     = "advanced-state-management"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "lab"
  
  validation {
    condition     = contains(["development", "staging", "production", "lab", "test"], var.environment)
    error_message = "Environment must be one of: development, staging, production, lab, test."
  }
}

variable "owner" {
  description = "Owner of the resources for accountability and contact information"
  type        = string
  default     = "terraform-student"
  
  validation {
    condition     = length(var.owner) > 0 && length(var.owner) <= 100
    error_message = "Owner must be between 1 and 100 characters."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation tracking"
  type        = string
  default     = "training"
  
  validation {
    condition     = length(var.cost_center) > 0 && length(var.cost_center) <= 50
    error_message = "Cost center must be between 1 and 50 characters."
  }
}

# ============================================================================
# AWS REGION AND PROVIDER CONFIGURATION
# ============================================================================

variable "aws_region" {
  description = "Primary AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid AWS region."
  }
}

variable "dr_region" {
  description = "Disaster recovery AWS region for state replication"
  type        = string
  default     = "us-west-2"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.dr_region)
    error_message = "DR region must be a valid AWS region."
  }
}

variable "monitoring_region" {
  description = "AWS region for centralized monitoring and logging"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.monitoring_region)
    error_message = "Monitoring region must be a valid AWS region."
  }
}

variable "max_retries" {
  description = "Maximum number of retries for AWS API calls"
  type        = number
  default     = 3
  
  validation {
    condition     = var.max_retries >= 1 && var.max_retries <= 10
    error_message = "Max retries must be between 1 and 10."
  }
}

variable "retry_mode" {
  description = "Retry mode for AWS API calls (standard, adaptive)"
  type        = string
  default     = "adaptive"
  
  validation {
    condition     = contains(["standard", "adaptive"], var.retry_mode)
    error_message = "Retry mode must be either 'standard' or 'adaptive'."
  }
}

# ============================================================================
# SECURITY AND COMPLIANCE CONFIGURATION
# ============================================================================

variable "security_level" {
  description = "Security level for the deployment (low, medium, high, critical)"
  type        = string
  default     = "high"
  
  validation {
    condition     = contains(["low", "medium", "high", "critical"], var.security_level)
    error_message = "Security level must be one of: low, medium, high, critical."
  }
}

variable "compliance_scope" {
  description = "Compliance frameworks that apply to this deployment"
  type        = list(string)
  default     = ["SOC2", "PCI-DSS", "HIPAA"]
  
  validation {
    condition = alltrue([
      for framework in var.compliance_scope :
      contains(["SOC2", "PCI-DSS", "HIPAA", "GDPR", "FedRAMP", "ISO27001"], framework)
    ])
    error_message = "Compliance scope must contain valid compliance frameworks."
  }
}

variable "data_classification" {
  description = "Data classification level (public, internal, confidential, restricted)"
  type        = string
  default     = "confidential"
  
  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "encryption_algorithm" {
  description = "Encryption algorithm for state storage (AES256, aws:kms)"
  type        = string
  default     = "aws:kms"
  
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Encryption algorithm must be either 'AES256' or 'aws:kms'."
  }
}

# ============================================================================
# CROSS-ACCOUNT ACCESS CONFIGURATION
# ============================================================================

variable "assume_role_arn" {
  description = "ARN of the IAM role to assume for primary region operations"
  type        = string
  default     = ""
  
  validation {
    condition = var.assume_role_arn == "" || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.assume_role_arn))
    error_message = "Assume role ARN must be a valid IAM role ARN or empty string."
  }
}

variable "dr_assume_role_arn" {
  description = "ARN of the IAM role to assume for disaster recovery region operations"
  type        = string
  default     = ""
  
  validation {
    condition = var.dr_assume_role_arn == "" || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.dr_assume_role_arn))
    error_message = "DR assume role ARN must be a valid IAM role ARN or empty string."
  }
}

variable "external_id" {
  description = "External ID for assume role operations (additional security)"
  type        = string
  default     = ""
  sensitive   = true
  
  validation {
    condition     = var.external_id == "" || length(var.external_id) >= 8
    error_message = "External ID must be at least 8 characters long or empty."
  }
}

# ============================================================================
# STATE MANAGEMENT CONFIGURATION
# ============================================================================

variable "state_bucket_prefix" {
  description = "Prefix for state bucket naming"
  type        = string
  default     = "terraform-state"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.state_bucket_prefix))
    error_message = "State bucket prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "enable_versioning" {
  description = "Enable versioning on state buckets for backup and recovery"
  type        = bool
  default     = true
}

variable "enable_mfa_delete" {
  description = "Enable MFA delete protection on state buckets"
  type        = bool
  default     = false
}

variable "versioning_retention_days" {
  description = "Number of days to retain old versions of state files"
  type        = number
  default     = 90
  
  validation {
    condition     = var.versioning_retention_days >= 1 && var.versioning_retention_days <= 365
    error_message = "Versioning retention days must be between 1 and 365."
  }
}

variable "enable_cross_region_replication" {
  description = "Enable cross-region replication for disaster recovery"
  type        = bool
  default     = true
}

variable "replication_storage_class" {
  description = "Storage class for replicated objects in DR region"
  type        = string
  default     = "STANDARD_IA"
  
  validation {
    condition = contains([
      "STANDARD", "STANDARD_IA", "ONEZONE_IA", "REDUCED_REDUNDANCY",
      "GLACIER", "DEEP_ARCHIVE", "INTELLIGENT_TIERING"
    ], var.replication_storage_class)
    error_message = "Replication storage class must be a valid S3 storage class."
  }
}

# ============================================================================
# DYNAMODB LOCKING CONFIGURATION
# ============================================================================

variable "lock_table_billing_mode" {
  description = "Billing mode for DynamoDB lock table (PROVISIONED, PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
  
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.lock_table_billing_mode)
    error_message = "Lock table billing mode must be either 'PROVISIONED' or 'PAY_PER_REQUEST'."
  }
}

variable "lock_table_read_capacity" {
  description = "Read capacity units for DynamoDB lock table (only used with PROVISIONED billing)"
  type        = number
  default     = 5
  
  validation {
    condition     = var.lock_table_read_capacity >= 1 && var.lock_table_read_capacity <= 1000
    error_message = "Lock table read capacity must be between 1 and 1000."
  }
}

variable "lock_table_write_capacity" {
  description = "Write capacity units for DynamoDB lock table (only used with PROVISIONED billing)"
  type        = number
  default     = 5
  
  validation {
    condition     = var.lock_table_write_capacity >= 1 && var.lock_table_write_capacity <= 1000
    error_message = "Lock table write capacity must be between 1 and 1000."
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB lock table"
  type        = bool
  default     = true
}

# ============================================================================
# MONITORING AND ALERTING CONFIGURATION
# ============================================================================

variable "enable_cloudwatch_monitoring" {
  description = "Enable CloudWatch monitoring for state management resources"
  type        = bool
  default     = true
}

variable "enable_cloudtrail_logging" {
  description = "Enable CloudTrail logging for state access auditing"
  type        = bool
  default     = true
}

variable "cloudtrail_retention_days" {
  description = "Number of days to retain CloudTrail logs"
  type        = number
  default     = 90
  
  validation {
    condition     = var.cloudtrail_retention_days >= 1 && var.cloudtrail_retention_days <= 3653
    error_message = "CloudTrail retention days must be between 1 and 3653 (10 years)."
  }
}

variable "enable_sns_notifications" {
  description = "Enable SNS notifications for state management alerts"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email address for state management notifications"
  type        = string
  default     = ""
  
  validation {
    condition = var.notification_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Notification email must be a valid email address or empty string."
  }
}

# ============================================================================
# ADVANCED FEATURES CONFIGURATION
# ============================================================================

variable "enable_advanced_security" {
  description = "Enable advanced security features (VPC endpoints, additional encryption)"
  type        = bool
  default     = false
}

variable "enable_cost_optimization" {
  description = "Enable cost optimization features (intelligent tiering, lifecycle policies)"
  type        = bool
  default     = true
}

variable "enable_performance_monitoring" {
  description = "Enable detailed performance monitoring and metrics"
  type        = bool
  default     = true
}

variable "workspace_strategy" {
  description = "Workspace strategy for multi-environment management (isolated, shared)"
  type        = string
  default     = "isolated"
  
  validation {
    condition     = contains(["isolated", "shared"], var.workspace_strategy)
    error_message = "Workspace strategy must be either 'isolated' or 'shared'."
  }
}

# ============================================================================
# TESTING AND VALIDATION CONFIGURATION
# ============================================================================

variable "enable_state_validation" {
  description = "Enable automated state validation and integrity checks"
  type        = bool
  default     = true
}

variable "validation_schedule" {
  description = "Cron expression for automated state validation schedule"
  type        = string
  default     = "cron(0 2 * * ? *)"  # Daily at 2 AM UTC
  
  validation {
    condition     = can(regex("^cron\\(.+\\)$", var.validation_schedule))
    error_message = "Validation schedule must be a valid cron expression."
  }
}

variable "enable_drift_detection" {
  description = "Enable automated drift detection for state management resources"
  type        = bool
  default     = true
}

# ============================================================================
# DISASTER RECOVERY CONFIGURATION
# ============================================================================

variable "rto_minutes" {
  description = "Recovery Time Objective in minutes for disaster recovery"
  type        = number
  default     = 15
  
  validation {
    condition     = var.rto_minutes >= 5 && var.rto_minutes <= 1440
    error_message = "RTO must be between 5 minutes and 24 hours (1440 minutes)."
  }
}

variable "rpo_minutes" {
  description = "Recovery Point Objective in minutes for disaster recovery"
  type        = number
  default     = 5
  
  validation {
    condition     = var.rpo_minutes >= 1 && var.rpo_minutes <= 60
    error_message = "RPO must be between 1 and 60 minutes."
  }
}

variable "enable_automated_failover" {
  description = "Enable automated failover to disaster recovery region"
  type        = bool
  default     = false
}

# ============================================================================
# COST MANAGEMENT CONFIGURATION
# ============================================================================

variable "budget_amount" {
  description = "Monthly budget amount for state management resources (USD)"
  type        = number
  default     = 50
  
  validation {
    condition     = var.budget_amount >= 1 && var.budget_amount <= 10000
    error_message = "Budget amount must be between $1 and $10,000."
  }
}

variable "budget_threshold_percentage" {
  description = "Budget threshold percentage for alerts (e.g., 80 for 80%)"
  type        = number
  default     = 80
  
  validation {
    condition     = var.budget_threshold_percentage >= 50 && var.budget_threshold_percentage <= 100
    error_message = "Budget threshold percentage must be between 50 and 100."
  }
}

variable "enable_cost_anomaly_detection" {
  description = "Enable AWS Cost Anomaly Detection for state management resources"
  type        = bool
  default     = true
}

# ============================================================================
# RESOURCE NAMING CONFIGURATION
# ============================================================================

variable "resource_prefix" {
  description = "Prefix for all resource names to ensure uniqueness"
  type        = string
  default     = ""

  validation {
    condition     = var.resource_prefix == "" || can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Resource prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "random_suffix_length" {
  description = "Length of random suffix for resource names"
  type        = number
  default     = 8

  validation {
    condition     = var.random_suffix_length >= 4 && var.random_suffix_length <= 16
    error_message = "Random suffix length must be between 4 and 16."
  }
}
