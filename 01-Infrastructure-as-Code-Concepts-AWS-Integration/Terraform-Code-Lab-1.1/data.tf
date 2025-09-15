# ============================================================================
# DATA SOURCES
# Topic 1: Infrastructure as Code Concepts & AWS Integration
# ============================================================================

# ============================================================================
# AWS ACCOUNT AND IDENTITY INFORMATION
# ============================================================================

# Get current AWS account information
data "aws_caller_identity" "current" {}

# Get current AWS region information
data "aws_region" "current" {}

# Get current AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {}

# ============================================================================
# AVAILABILITY ZONES AND NETWORKING
# ============================================================================

# Get available availability zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Get default VPC information (for reference and validation)
data "aws_vpc" "default" {
  default = true
}

# Get default security group (for reference)
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# ============================================================================
# AMI AND COMPUTE RESOURCES
# ============================================================================

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Get the latest Ubuntu 22.04 LTS AMI (alternative option)
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

# Get EC2 instance type offerings in the current region
data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = ["t3.micro", "t3.small", "t3.medium", "t3.large"]
  }
  
  location_type = "availability-zone"
}

# ============================================================================
# RDS AND DATABASE INFORMATION
# ============================================================================

# Get available RDS engine versions for MySQL
data "aws_rds_engine_versions" "mysql" {
  engine = "mysql"
  
  filter {
    name   = "engine-mode"
    values = ["provisioned"]
  }
}

# Get RDS instance class offerings
data "aws_rds_orderable_db_instance" "mysql" {
  engine         = "mysql"
  engine_version = data.aws_rds_engine_versions.mysql.latest_version
  instance_class = var.db_instance_class
  
  preferred_instance_classes = [
    "db.t3.micro",
    "db.t3.small", 
    "db.t3.medium"
  ]
}

# ============================================================================
# ELASTIC LOAD BALANCER INFORMATION
# ============================================================================

# Get available load balancer types
data "aws_lb_hosted_zone_id" "main" {
  region = data.aws_region.current.name
}

# Get SSL policy for load balancers
data "aws_elb_service_account" "main" {}

# ============================================================================
# IAM POLICIES AND ROLES
# ============================================================================

# Get AWS managed policy for EC2 instance role
data "aws_iam_policy" "ec2_role_policy" {
  name = "AmazonEC2RoleforAWSCodeDeploy"
}

# Get AWS managed policy for CloudWatch agent
data "aws_iam_policy" "cloudwatch_agent" {
  name = "CloudWatchAgentServerPolicy"
}

# Get AWS managed policy for S3 access
data "aws_iam_policy" "s3_access" {
  name = "AmazonS3ReadOnlyAccess"
}

# IAM policy document for EC2 instance assume role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.name]
    }
  }
}

# IAM policy document for S3 bucket access
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "AllowEC2Access"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.name_prefix}-ec2-role"]
    }
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.name_prefix}-app-data-*",
      "arn:${data.aws_partition.current.partition}:s3:::${local.name_prefix}-app-data-*/*"
    ]
  }
  
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    
    actions = ["s3:*"]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.name_prefix}-app-data-*",
      "arn:${data.aws_partition.current.partition}:s3:::${local.name_prefix}-app-data-*/*"
    ]
    
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# ============================================================================
# PRICING AND COST INFORMATION
# ============================================================================

# Get current AWS pricing for EC2 instances
data "aws_pricing_product" "ec2_pricing" {
  service_code = "AmazonEC2"
  
  filters {
    field = "instanceType"
    value = var.instance_type
  }
  
  filters {
    field = "location"
    value = data.aws_region.current.description
  }
  
  filters {
    field = "tenancy"
    value = "Shared"
  }
  
  filters {
    field = "operating-system"
    value = "Linux"
  }
}

# Get current AWS pricing for RDS
data "aws_pricing_product" "rds_pricing" {
  service_code = "AmazonRDS"
  
  filters {
    field = "instanceType"
    value = var.db_instance_class
  }
  
  filters {
    field = "location"
    value = data.aws_region.current.description
  }
  
  filters {
    field = "databaseEngine"
    value = "MySQL"
  }
}

# ============================================================================
# SECURITY AND COMPLIANCE INFORMATION
# ============================================================================

# Get current AWS account password policy
data "aws_iam_account_password_policy" "current" {}

# Get current AWS account summary
data "aws_iam_account_summary" "current" {}

# Get AWS Organizations information (if applicable)
data "aws_organizations_organization" "current" {
  count = var.enable_organizations_integration ? 1 : 0
}

# ============================================================================
# CLOUDWATCH AND MONITORING
# ============================================================================

# Get existing CloudWatch log groups (for reference)
data "aws_cloudwatch_log_groups" "existing" {
  log_group_name_prefix = "/aws/"
}

# Get CloudWatch metric filters
data "aws_cloudwatch_log_metric_filter" "existing" {
  count           = var.enable_monitoring ? 1 : 0
  log_group_name  = "/aws/ec2"
  metric_name     = "ErrorCount"
}

# ============================================================================
# ROUTE53 AND DNS INFORMATION
# ============================================================================

# Get Route53 hosted zones (if any exist)
data "aws_route53_zone" "existing" {
  count        = var.enable_custom_domain ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

# ============================================================================
# CERTIFICATE MANAGER
# ============================================================================

# Get existing ACM certificates
data "aws_acm_certificate" "existing" {
  count    = var.enable_ssl ? 1 : 0
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

# ============================================================================
# BACKUP AND DISASTER RECOVERY
# ============================================================================

# Get existing backup vaults
data "aws_backup_vault" "existing" {
  count = var.enable_backup ? 1 : 0
  name  = "default"
}

# Get backup plans
data "aws_backup_plan" "existing" {
  count   = var.enable_backup ? 1 : 0
  plan_id = "default-plan"
}

# ============================================================================
# SYSTEMS MANAGER PARAMETERS
# ============================================================================

# Get Systems Manager parameters for configuration
data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# Get Systems Manager parameters for database configuration
data "aws_ssm_parameter" "db_password" {
  count           = var.use_ssm_for_secrets ? 1 : 0
  name            = "/${var.project_name}/${var.environment}/database/password"
  with_decryption = false
}

# ============================================================================
# VALIDATION DATA SOURCES
# ============================================================================

# Validate Terraform version
data "external" "terraform_version" {
  program = ["bash", "-c", "terraform version -json | jq -r '{version: .terraform_version}'"]
}

# Validate AWS CLI version
data "external" "aws_cli_version" {
  program = ["bash", "-c", "aws --version 2>&1 | head -1 | awk '{print $1}' | cut -d'/' -f2 | jq -R '{version: .}'"]
}

# ============================================================================
# COMPUTED LOCAL VALUES FROM DATA SOURCES
# ============================================================================

locals {
  # Account and region information
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition
  
  # Availability zone information
  azs = data.aws_availability_zones.available.names
  
  # AMI information
  selected_ami = var.use_ubuntu ? data.aws_ami.ubuntu.id : data.aws_ami.amazon_linux.id
  ami_name     = var.use_ubuntu ? data.aws_ami.ubuntu.name : data.aws_ami.amazon_linux.name
  
  # Database information
  mysql_version = data.aws_rds_engine_versions.mysql.latest_version
  
  # Validation results
  terraform_version_valid = can(regex("^1\\.13\\.", try(data.external.terraform_version.result.version, "")))
  aws_cli_available      = try(data.external.aws_cli_version.result.version, "") != ""
  
  # Cost information
  estimated_ec2_hourly_cost = try(tonumber(regex("([0-9.]+)", data.aws_pricing_product.ec2_pricing.terms.OnDemand[keys(data.aws_pricing_product.ec2_pricing.terms.OnDemand)[0]].priceDimensions[keys(data.aws_pricing_product.ec2_pricing.terms.OnDemand[keys(data.aws_pricing_product.ec2_pricing.terms.OnDemand)[0]].priceDimensions)[0]].pricePerUnit.USD)[0]), 0.0116)
  
  # Security validation
  account_has_password_policy = try(data.aws_iam_account_password_policy.current.minimum_password_length > 0, false)
  
  # Infrastructure validation
  region_has_multiple_azs = length(local.azs) >= 2
  instance_type_available = contains(data.aws_ec2_instance_type_offerings.available.instance_types, var.instance_type)
}
