# AWS Terraform Training - Topic 2: Terraform CLI & AWS Provider Configuration
# Terraform Code Lab 2.1 - Variable Values Configuration
#
# This file provides default variable values for the Terraform configuration,
# demonstrating best practices for variable management and environment-specific settings.
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

# AWS CLI profile for local development authentication
# Ensure this profile is configured with appropriate permissions
aws_profile = "default"

# =============================================================================
# PROJECT AND ORGANIZATIONAL VALUES
# =============================================================================

# Project name for resource identification and organization
project_name = "terraform-training-lab-2"

# Resource owner for accountability and contact information
owner = "platform-team"

# Cost center for billing allocation and chargeback
cost_center = "training"

# =============================================================================
# SECURITY AND AUTHENTICATION VALUES
# =============================================================================

# Data classification level for compliance and security
data_classification = "internal"

# Compliance requirements for the project
compliance_requirements = ["SOC2"]

# Enable encryption at rest for all applicable resources
encryption_at_rest = true

# Enable encryption in transit for all applicable resources
encryption_in_transit = true

# External ID for role assumption (additional security layer)
# In production, use a secure random value and store securely
# external_id = "unique-external-id-12345"

# =============================================================================
# MULTI-ACCOUNT CONFIGURATION VALUES
# =============================================================================

# AWS account IDs for multi-account deployments
# Uncomment and configure for cross-account scenarios
# staging_account_id = "123456789012"
# production_account_id = "123456789013"

# IAM role ARNs for cross-account access
# assume_role_arn = "arn:aws:iam::123456789012:role/TerraformExecutionRole"
# cicd_role_arn = "arn:aws:iam::123456789012:role/GitHubActionsRole"

# MFA device ARN for enhanced security
# mfa_device_arn = "arn:aws:iam::123456789012:mfa/username"

# Web identity token file for OIDC authentication
# web_identity_token_file = "/var/run/secrets/eks.amazonaws.com/serviceaccount/token"

# =============================================================================
# INFRASTRUCTURE CONFIGURATION VALUES
# =============================================================================

# Enable detailed CloudWatch monitoring for resources
enable_detailed_monitoring = true

# Enable automated backup for applicable resources
enable_backup = true

# Number of days to retain automated backups
backup_retention_days = 7

# List of availability zones for multi-AZ deployments
# Empty list means use all available AZs in the region
availability_zones = []

# Enable VPC endpoints for AWS services
enable_vpc_endpoints = false

# =============================================================================
# COST MANAGEMENT VALUES
# =============================================================================

# Monthly budget limit in USD for cost control
budget_limit = 50

# Additional tags for cost allocation and tracking
cost_allocation_tags = {
  Department = "Engineering"
  Team       = "Platform"
  Purpose    = "Training"
}

# =============================================================================
# FEATURE FLAGS
# =============================================================================

# Feature flags for enabling/disabling specific functionality
feature_flags = {
  enable_logging          = true
  enable_metrics         = true
  enable_tracing         = false
  enable_auto_scaling    = false
  enable_load_balancing  = false
  enable_ssl_termination = true
}

# =============================================================================
# ADVANCED CONFIGURATION VALUES
# =============================================================================

# Terraform version requirement for validation
terraform_version = "~> 1.13.0"

# AWS provider version requirement for validation
aws_provider_version = "~> 6.12.0"

# Enable experimental Terraform features (use with caution)
enable_experimental_features = false

# =============================================================================
# ENVIRONMENT-SPECIFIC CONFIGURATION OVERRIDES
# =============================================================================

# Environment-specific configuration map
# These values override defaults based on the selected environment
environment_config = {
  dev = {
    instance_type     = "t3.micro"
    min_capacity      = 1
    max_capacity      = 2
    enable_monitoring = false
    backup_retention  = 3
  }
  staging = {
    instance_type     = "t3.small"
    min_capacity      = 1
    max_capacity      = 3
    enable_monitoring = true
    backup_retention  = 7
  }
  prod = {
    instance_type     = "t3.medium"
    min_capacity      = 2
    max_capacity      = 10
    enable_monitoring = true
    backup_retention  = 30
  }
}

# =============================================================================
# TRAINING-SPECIFIC CONFIGURATION
# =============================================================================

# Training context and metadata
# These values help identify resources created during training exercises

# Training session identifier
# training_session_id = "2025-01-terraform-training"

# Instructor information
# instructor = "aws-terraform-trainer"

# Training group or cohort
# training_group = "january-2025-cohort"

# Lab exercise number
# lab_exercise = "lab-2-cli-provider-configuration"

# =============================================================================
# VALIDATION AND TESTING VALUES
# =============================================================================

# Values used for configuration validation and testing

# Test resource naming
# test_resource_prefix = "terraform-test"

# Validation flags
# enable_validation_resources = true
# enable_test_resources = false

# =============================================================================
# COMMENTS AND DOCUMENTATION
# =============================================================================

# Variable File Usage Instructions:
#
# 1. Local Development:
#    - Copy this file to terraform.tfvars.local
#    - Modify values as needed for your environment
#    - Add terraform.tfvars.local to .gitignore
#
# 2. Environment-Specific Deployment:
#    - Create separate files: dev.tfvars, staging.tfvars, prod.tfvars
#    - Use: terraform apply -var-file="dev.tfvars"
#    - Store sensitive values in environment variables
#
# 3. CI/CD Pipeline:
#    - Use environment variables for sensitive values
#    - Example: TF_VAR_external_id=$EXTERNAL_ID
#    - Implement secure secret management
#
# 4. Security Best Practices:
#    - Never commit sensitive values to version control
#    - Use AWS Secrets Manager or similar for production secrets
#    - Implement proper IAM policies and access controls
#    - Enable CloudTrail for audit logging
#
# 5. Variable Precedence (highest to lowest):
#    - Command line flags: -var="key=value"
#    - Environment variables: TF_VAR_key=value
#    - terraform.tfvars file
#    - terraform.tfvars.json file
#    - *.auto.tfvars files (alphabetical order)
#    - Variable defaults in configuration files
#
# 6. Validation:
#    - Run terraform validate to check syntax
#    - Run terraform plan to preview changes
#    - Use terraform fmt to format configuration files
#
# 7. Troubleshooting:
#    - Enable debug logging: TF_LOG=DEBUG
#    - Check AWS credentials: aws sts get-caller-identity
#    - Verify region configuration: aws configure get region
#    - Test provider authentication: terraform providers
#
# For additional help and documentation:
# - Terraform Variable Documentation: https://www.terraform.io/docs/language/values/variables.html
# - AWS Provider Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# - Training Materials: See README.md and Concept.md files
