# AWS Terraform Training - Topic 3: Core Terraform Operations
# Terraform Code Lab 3.1 - Variable Values Configuration
#
# This file provides example variable values for the core Terraform operations
# lab, demonstrating enterprise-grade configuration management, environment-specific
# settings, and best practices for variable organization and security.
#
# IMPORTANT: This file contains example values for training purposes.
# In production environments:
# 1. Never commit sensitive values to version control
# 2. Use environment variables or secure secret management
# 3. Implement proper access controls and encryption
# 4. Follow your organization's security policies

# =============================================================================
# CORE CONFIGURATION VALUES
# =============================================================================

# AWS region for resource deployment
# Standardized to us-east-1 for training consistency
aws_region = "us-east-1"

# Environment designation for resource organization
# Valid values: dev, development, staging, stage, prod, production
environment = "dev"

# Project name for resource identification and organization
project_name = "core-terraform-operations"

# AWS CLI profile for local development authentication
# Ensure this profile is configured with appropriate permissions
aws_profile = "default"

# =============================================================================
# AUTHENTICATION AND SECURITY VALUES
# =============================================================================

# Data classification level for compliance and security
data_classification = "internal"

# Resource owner for accountability and contact information
owner = "platform-team"

# Cost center for billing allocation and chargeback
cost_center = "engineering"

# Enable backup for applicable resources
backup_required = true

# Enable monitoring for resources
monitoring_enabled = true

# External ID for role assumption (additional security layer)
# In production, use a secure random value and store securely
# external_id = "unique-external-id-12345"

# Production role ARN for cross-account access
# Uncomment and configure for production deployments
# production_role_arn = "arn:aws:iam::123456789012:role/TerraformProductionRole"

# =============================================================================
# NETWORK CONFIGURATION VALUES
# =============================================================================

# VPC CIDR block for network isolation
vpc_cidr = "10.0.0.0/16"

# Availability zones for multi-AZ deployment
# Empty list means use all available AZs in the region (up to 3)
availability_zones = []

# Enable NAT Gateway for private subnet internet access
enable_nat_gateway = true

# Enable VPN Gateway for hybrid connectivity
enable_vpn_gateway = false

# Enable VPC Flow Logs for network monitoring
enable_flow_logs = true

# =============================================================================
# COMPUTE CONFIGURATION VALUES
# =============================================================================

# Instance types by environment for cost optimization
instance_types = {
  dev = {
    web      = "t3.micro"
    app      = "t3.micro"
    database = "db.t3.micro"
  }
  staging = {
    web      = "t3.small"
    app      = "t3.small"
    database = "db.t3.small"
  }
  prod = {
    web      = "t3.medium"
    app      = "t3.large"
    database = "db.t3.medium"
  }
}

# Number of instances per tier
instance_count = {
  web = 2
  app = 2
}

# EC2 Key Pair name for SSH access
# Ensure this key pair exists in your AWS account
key_pair_name = "terraform-lab-key"

# =============================================================================
# DATABASE CONFIGURATION VALUES
# =============================================================================

# Database configuration parameters
database_config = {
  engine                  = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  backup_retention_period = 7
  backup_window         = "03:00-04:00"
  maintenance_window    = "sun:04:00-sun:05:00"
  multi_az              = false
  storage_encrypted     = true
}

# Database credentials (for lab purposes only)
# In production, use AWS Secrets Manager or similar
database_credentials = {
  username      = "admin"
  password      = "changeme123!"
  database_name = "appdb"
}

# =============================================================================
# LOAD BALANCER CONFIGURATION VALUES
# =============================================================================

# Load balancer configuration
load_balancer_config = {
  type                            = "application"
  scheme                         = "internet-facing"
  enable_deletion_protection     = false
  idle_timeout                   = 60
  enable_cross_zone_load_balancing = true
}

# Target group configuration
target_group_config = {
  port                    = 80
  protocol               = "HTTP"
  health_check_path      = "/"
  health_check_interval  = 30
  health_check_timeout   = 5
  healthy_threshold      = 2
  unhealthy_threshold    = 2
}

# =============================================================================
# SECURITY GROUP CONFIGURATION VALUES
# =============================================================================

# Security group configurations with detailed rules
security_groups = [
  {
    name        = "web"
    description = "Security group for web servers"
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access from internet"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS access from internet"
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "SSH access from VPC"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    ]
  },
  {
    name        = "app"
    description = "Security group for application servers"
    ingress_rules = [
      {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "Application port from VPC"
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "SSH access from VPC"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    ]
  },
  {
    name        = "database"
    description = "Security group for database servers"
    ingress_rules = [
      {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "MySQL access from VPC"
      }
    ]
    egress_rules = []
  }
]

# =============================================================================
# FEATURE FLAGS AND TOGGLES
# =============================================================================

# Feature flags for enabling/disabling functionality
feature_flags = {
  enable_auto_scaling      = false  # Disabled for lab simplicity
  enable_cloudwatch_logs   = true
  enable_ssl_termination   = false  # Disabled for lab simplicity
  enable_waf              = false  # Disabled for lab simplicity
  enable_backup_automation = true
  enable_cost_optimization = true
}

# =============================================================================
# PROVISIONER CONFIGURATION VALUES
# =============================================================================

# Provisioner configuration settings
provisioner_config = {
  enable_remote_exec      = true
  enable_file_provisioner = true
  enable_local_exec       = true
  connection_timeout      = "5m"
  retry_attempts         = 3
}

# User data script configurations
user_data_scripts = {
  web_server = "web_server.sh"
  app_server = "app_server.sh"
  database   = "database.sh"
}

# =============================================================================
# COST MANAGEMENT VALUES
# =============================================================================

# Budget configuration for cost control
budget_config = {
  limit_amount         = 100
  time_unit           = "MONTHLY"
  budget_type         = "COST"
  threshold_percentage = 80
}

# Additional tags for cost allocation and tracking
cost_allocation_tags = {
  Department = "Engineering"
  Team       = "Platform"
  Purpose    = "Training"
  Billable   = "true"
}

# =============================================================================
# ENVIRONMENT-SPECIFIC OVERRIDES
# =============================================================================

# Note: The following variables can be overridden for different environments
# by creating environment-specific .tfvars files:
#
# dev.tfvars:
# environment = "dev"
# instance_count = { web = 1, app = 1 }
# enable_nat_gateway = false
#
# staging.tfvars:
# environment = "staging"
# instance_count = { web = 2, app = 2 }
# enable_nat_gateway = true
#
# prod.tfvars:
# environment = "prod"
# instance_count = { web = 3, app = 3 }
# enable_nat_gateway = true
# monitoring_enabled = true
# backup_required = true

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================

# Variable File Usage Instructions:
#
# 1. Local Development:
#    terraform apply -var-file="terraform.tfvars"
#
# 2. Environment-Specific Deployment:
#    terraform apply -var-file="dev.tfvars"
#    terraform apply -var-file="staging.tfvars"
#    terraform apply -var-file="prod.tfvars"
#
# 3. Override Specific Variables:
#    terraform apply -var-file="terraform.tfvars" -var="environment=staging"
#
# 4. Environment Variables (for sensitive values):
#    export TF_VAR_database_password="secure-password"
#    export TF_VAR_external_id="secure-external-id"
#    terraform apply -var-file="terraform.tfvars"
#
# 5. Validation:
#    terraform validate
#    terraform plan -var-file="terraform.tfvars"
#
# 6. Security Best Practices:
#    - Never commit sensitive values to version control
#    - Use AWS Secrets Manager for production passwords
#    - Implement proper IAM policies and access controls
#    - Enable CloudTrail for audit logging
#    - Use MFA for administrative access
#
# For additional help and documentation:
# - Terraform Variable Documentation: https://www.terraform.io/docs/language/values/variables.html
# - AWS Provider Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# - Training Materials: See README.md and Concept.md files
