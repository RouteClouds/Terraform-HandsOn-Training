# =============================================================================
# AWS Terraform Training - Topic 7: Modules and Module Development
# Data Sources for Dynamic Configuration and Module Development
# =============================================================================

# =============================================================================
# AWS Account and Identity Information
# =============================================================================

# Current AWS caller identity
data "aws_caller_identity" "current" {
  # No configuration required - provides account ID, user ID, and ARN
}

# Current AWS region
data "aws_region" "current" {
  # No configuration required - provides current region name
}

# Current AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {
  # No configuration required - provides partition information
}

# =============================================================================
# Availability Zone Information
# =============================================================================

# Available availability zones in current region
data "aws_availability_zones" "available" {
  state = "available"
  
  # Exclude zones that might not support all services
  exclude_zone_ids = []
  
  # Filter for zones that support EC2 instances
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Specific availability zone information for module testing
data "aws_availability_zone" "selected" {
  count = length(var.availability_zones)
  name  = var.availability_zones[count.index]
}

# =============================================================================
# AMI Information for Module Development
# =============================================================================

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Latest Windows Server 2022 AMI
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# =============================================================================
# Network Information for Module Development
# =============================================================================

# Default VPC (fallback for module testing)
data "aws_vpc" "default" {
  default = true
}

# Default subnets (fallback for module testing)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Default security group
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# =============================================================================
# IAM Policy Documents for Module Development
# =============================================================================

# EC2 instance assume role policy
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

# S3 bucket policy for module testing
data "aws_iam_policy_document" "s3_module_testing_policy" {
  # Allow access from current account
  statement {
    sid    = "AllowCurrentAccount"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.project_name}-module-testing-*",
      "arn:${data.aws_partition.current.partition}:s3:::${var.project_name}-module-testing-*/*"
    ]
  }
  
  # Deny insecure connections
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    
    actions = ["s3:*"]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.project_name}-module-testing-*",
      "arn:${data.aws_partition.current.partition}:s3:::${var.project_name}-module-testing-*/*"
    ]
    
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# Module registry access policy
data "aws_iam_policy_document" "module_registry_policy" {
  # Allow read access for module consumption
  statement {
    sid    = "AllowModuleRead"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.project_name}-module-registry-*",
      "arn:${data.aws_partition.current.partition}:s3:::${var.project_name}-module-registry-*/*"
    ]
  }
  
  # Allow write access for module publishing
  statement {
    sid    = "AllowModulePublish"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
    
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.project_name}-module-registry-*/*"
    ]
  }
}

# =============================================================================
# Service Information for Module Development
# =============================================================================

# AWS service endpoints for current region
data "aws_service" "s3" {
  region     = data.aws_region.current.name
  service_id = "s3"
}

data "aws_service" "ec2" {
  region     = data.aws_region.current.name
  service_id = "ec2"
}

data "aws_service" "rds" {
  region     = data.aws_region.current.name
  service_id = "rds"
}

# =============================================================================
# Pricing Information for Module Cost Estimation
# =============================================================================

# EC2 instance type information for cost calculation
data "aws_ec2_instance_type" "module_instances" {
  for_each = toset([
    for module_name, config in var.module_examples : config.instance_type
    if config.enabled
  ])
  
  instance_type = each.value
}

# RDS instance type information
data "aws_rds_engine_version" "mysql" {
  engine  = "mysql"
  version = "8.0"
}

# =============================================================================
# Module Development Specific Data Sources
# =============================================================================

# Terraform Registry modules (for reference)
data "external" "terraform_registry_modules" {
  count = var.module_development_mode ? 1 : 0
  
  program = ["python3", "-c", <<-EOT
import json
import sys

# Simulate module registry data
modules = {
    "vpc": {
        "source": "terraform-aws-modules/vpc/aws",
        "version": "~> 5.0",
        "description": "Terraform module to create VPC resources on AWS"
    },
    "security-group": {
        "source": "terraform-aws-modules/security-group/aws", 
        "version": "~> 5.0",
        "description": "Terraform module to create security group resources on AWS"
    },
    "ec2-instance": {
        "source": "terraform-aws-modules/ec2-instance/aws",
        "version": "~> 5.0", 
        "description": "Terraform module to create EC2 instance resources on AWS"
    }
}

print(json.dumps(modules))
EOT
  ]
}

# Module testing configuration
data "external" "module_testing_config" {
  count = var.enable_module_testing ? 1 : 0
  
  program = ["python3", "-c", <<-EOT
import json
import sys

# Generate testing configuration
config = {
    "test_environments": ["unit", "integration", "e2e"],
    "test_frameworks": ["terratest", "kitchen-terraform", "terraform-compliance"],
    "test_scenarios": ["basic", "advanced", "error-handling", "performance"],
    "supported_regions": ["us-east-1", "us-west-2", "eu-west-1"],
    "test_duration_minutes": 30
}

print(json.dumps(config))
EOT
  ]
}

# =============================================================================
# Template Files for Module Development
# =============================================================================

# User data template for EC2 instances
data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")
  
  vars = {
    project_name = var.project_name
    environment  = var.environment
    region       = data.aws_region.current.name
    account_id   = data.aws_caller_identity.current.account_id
  }
}

# Module README template
data "template_file" "module_readme" {
  template = file("${path.module}/templates/module_readme.md")
  
  vars = {
    module_name    = "example-module"
    module_version = var.module_version
    project_name   = var.project_name
    author         = var.owner
    creation_date  = formatdate("YYYY-MM-DD", timestamp())
  }
}

# Module variables template
data "template_file" "module_variables" {
  template = file("${path.module}/templates/module_variables.tf")
  
  vars = {
    module_name = "example-module"
    project_name = var.project_name
  }
}

# =============================================================================
# Workspace and Environment Specific Data
# =============================================================================

# Current workspace configuration
locals {
  # Module development environment settings
  is_development = contains(["development", "dev"], var.environment)
  is_staging     = contains(["staging", "stage"], var.environment)
  is_production  = contains(["production", "prod"], var.environment)
  
  # Module testing settings
  testing_enabled = var.enable_module_testing && (local.is_development || local.is_staging)
  
  # Security settings based on environment
  security_level = local.is_production ? "high" : local.is_staging ? "medium" : "low"
  
  # Cost optimization settings
  cost_optimization = local.is_development ? "aggressive" : local.is_staging ? "moderate" : "conservative"
  
  # Module development settings
  module_development_features = {
    versioning_enabled     = var.enable_module_versioning
    testing_enabled       = local.testing_enabled
    security_scanning     = var.enable_security_scanning
    compliance_checking   = var.enable_compliance_checking
    multi_region_testing  = var.enable_multi_region_testing
    automated_testing     = var.enable_automated_testing
  }
}

# =============================================================================
# Data Source Configuration Notes:
# 
# 1. Module Development Focus:
#    - AMI data sources for different operating systems
#    - Network information for module testing
#    - IAM policies for module security
#    - Service endpoints for module integration
#
# 2. Template Integration:
#    - User data templates for EC2 modules
#    - Module documentation templates
#    - Variable definition templates
#    - Configuration file templates
#
# 3. Testing Support:
#    - External data sources for testing configuration
#    - Module registry simulation
#    - Cost estimation data
#    - Environment-specific settings
#
# 4. Security and Compliance:
#    - IAM policy documents for secure module access
#    - Service endpoint information
#    - Environment-based security levels
#    - Compliance framework integration
#
# 5. Operational Excellence:
#    - Workspace-aware configuration
#    - Cost optimization settings
#    - Feature flag management
#    - Multi-region support
# =============================================================================
