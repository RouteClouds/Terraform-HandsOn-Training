# AWS Terraform Training - Terraform CLI & AWS Provider Configuration
# Lab 2.1: Advanced CLI Setup and Provider Configuration
# File: data.tf - Data Sources for Provider Validation and Configuration Discovery

# ============================================================================
# AWS ACCOUNT AND IDENTITY INFORMATION
# ============================================================================

# Get current AWS caller identity for validation
data "aws_caller_identity" "current" {
  # This data source provides:
  # - account_id: AWS account ID
  # - arn: ARN of the calling entity
  # - user_id: Unique identifier of the calling entity
}

# Get current AWS region information
data "aws_region" "current" {
  # This data source provides:
  # - name: Region name (e.g., us-east-1)
  # - description: Human-readable region description
  # - endpoint: Region endpoint URL
}

# Get AWS partition information (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {
  # This data source provides:
  # - partition: AWS partition (aws, aws-cn, aws-us-gov)
  # - dns_suffix: DNS suffix for the partition
  # - reverse_dns_prefix: Reverse DNS prefix
}

# Get available availability zones for provider validation
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# ============================================================================
# AWS PROVIDER CAPABILITIES AND FEATURES
# ============================================================================

# Get AWS provider version information
data "aws_provider" "current" {
  # This data source provides information about the current AWS provider
}

# Get supported AWS services in the current region
data "aws_service" "ec2" {
  region           = data.aws_region.current.name
  service_name     = "ec2"
  reverse_dns_name = "com.amazonaws.${data.aws_region.current.name}.ec2"
}

data "aws_service" "s3" {
  region           = data.aws_region.current.name
  service_name     = "s3"
  reverse_dns_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_service" "iam" {
  region           = data.aws_region.current.name
  service_name     = "iam"
  reverse_dns_name = "com.amazonaws.iam"
}

data "aws_service" "sts" {
  region           = data.aws_region.current.name
  service_name     = "sts"
  reverse_dns_name = "com.amazonaws.${data.aws_region.current.name}.sts"
}

# ============================================================================
# AUTHENTICATION AND CREDENTIALS VALIDATION
# ============================================================================

# Get current AWS credentials information (when using IAM user)
data "aws_iam_user" "current" {
  count     = var.authentication_method == "iam_user" ? 1 : 0
  user_name = var.iam_username
}

# Get IAM role information (when using assume role)
data "aws_iam_role" "assume_role" {
  count = var.authentication_method == "assume_role" ? 1 : 0
  name  = var.assume_role_name
}

# Get instance profile information (when using EC2 instance profile)
data "aws_iam_instance_profile" "ec2_profile" {
  count = var.authentication_method == "instance_profile" ? 1 : 0
  name  = var.instance_profile_name
}

# Get SSO account information (when using AWS SSO)
data "aws_ssoadmin_instances" "sso" {
  count = var.authentication_method == "sso" ? 1 : 0
}

# ============================================================================
# PROVIDER CONFIGURATION VALIDATION DATA
# ============================================================================

# Get AWS endpoints for the current region
data "aws_regions" "all" {
  all_regions = true
}

# Get specific region information for multi-region setup
data "aws_region" "backup" {
  count = var.enable_multi_region ? 1 : 0
  name  = var.backup_region
}

# Get VPC endpoints available in the region (for private connectivity)
data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

data "aws_vpc_endpoint_service" "ec2" {
  service      = "ec2"
  service_type = "Interface"
}

data "aws_vpc_endpoint_service" "sts" {
  service      = "sts"
  service_type = "Interface"
}

# ============================================================================
# SECURITY AND COMPLIANCE DATA SOURCES
# ============================================================================

# Get AWS managed policies for reference
data "aws_iam_policy" "power_user" {
  name = "PowerUserAccess"
}

data "aws_iam_policy" "read_only" {
  name = "ReadOnlyAccess"
}

data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}

# Get AWS Organizations information (if applicable)
data "aws_organizations_organization" "current" {
  count = var.check_organizations ? 1 : 0
}

# Get AWS Config configuration status
data "aws_config_configuration_recorder_status" "current" {
  count = var.check_config_status ? 1 : 0
  name  = var.config_recorder_name
}

# Get CloudTrail status
data "aws_cloudtrail_service_account" "current" {}

# ============================================================================
# COST AND BILLING DATA SOURCES
# ============================================================================

# Get AWS billing service account
data "aws_billing_service_account" "main" {}

# Get pricing information for cost estimation
data "aws_pricing_product" "ec2" {
  service_code = "AmazonEC2"
  
  filters = [
    {
      field = "instanceType"
      value = "t3.micro"
    },
    {
      field = "operatingSystem"
      value = "Linux"
    },
    {
      field = "tenancy"
      value = "Shared"
    },
    {
      field = "preInstalledSw"
      value = "NA"
    },
    {
      field = "location"
      value = data.aws_region.current.description
    }
  ]
}

# Get S3 pricing information
data "aws_pricing_product" "s3" {
  service_code = "AmazonS3"
  
  filters = [
    {
      field = "storageClass"
      value = "General Purpose"
    },
    {
      field = "location"
      value = data.aws_region.current.description
    }
  ]
}

# ============================================================================
# TERRAFORM CLI AND PROVIDER VERSION DATA
# ============================================================================

# Get Terraform version information
data "external" "terraform_version" {
  program = ["bash", "-c", "terraform version -json"]
}

# Get provider registry information
data "http" "provider_versions" {
  url = "https://registry.terraform.io/v1/providers/hashicorp/aws/versions"
  
  request_headers = {
    Accept = "application/json"
  }
}

# Get latest Terraform version information
data "http" "terraform_releases" {
  url = "https://api.releases.hashicorp.com/v1/releases/terraform"
  
  request_headers = {
    Accept = "application/json"
  }
}

# ============================================================================
# NETWORK AND CONNECTIVITY DATA SOURCES
# ============================================================================

# Get current public IP for security group configuration
data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
  
  request_headers = {
    Accept = "text/plain"
  }
}

# Get default VPC information (for reference)
data "aws_vpc" "default" {
  default = true
}

# Get default security group
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# ============================================================================
# AMI AND INSTANCE DATA SOURCES
# ============================================================================

# Get latest Amazon Linux 2023 AMI for testing
data "aws_ami" "amazon_linux_2023" {
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
}

# Get EC2 instance type information for validation
data "aws_ec2_instance_type" "test_instance" {
  instance_type = "t3.micro"
}

# Get EC2 instance type offerings in current region
data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = ["t3.micro", "t3.small", "t3.medium"]
  }
  
  filter {
    name   = "location"
    values = [data.aws_region.current.name]
  }
  
  location_type = "region"
}

# ============================================================================
# PROVIDER CONFIGURATION VALIDATION LOCALS
# ============================================================================

locals {
  # Provider validation results
  provider_validation = {
    # Account and region validation
    account_accessible = data.aws_caller_identity.current.account_id != ""
    region_valid = data.aws_region.current.name == var.primary_region
    partition_correct = data.aws_partition.current.partition == "aws"
    
    # Service availability validation
    ec2_available = data.aws_service.ec2.service_name == "ec2"
    s3_available = data.aws_service.s3.service_name == "s3"
    iam_available = data.aws_service.iam.service_name == "iam"
    sts_available = data.aws_service.sts.service_name == "sts"
    
    # Availability zones validation
    sufficient_azs = length(data.aws_availability_zones.available.names) >= 2
    
    # Instance type validation
    instance_type_available = length(data.aws_ec2_instance_type_offerings.available.instance_types) > 0
    
    # Authentication validation
    credentials_valid = data.aws_caller_identity.current.arn != ""
  }
  
  # All provider validations passed
  provider_ready = alltrue([
    local.provider_validation.account_accessible,
    local.provider_validation.region_valid,
    local.provider_validation.partition_correct,
    local.provider_validation.ec2_available,
    local.provider_validation.s3_available,
    local.provider_validation.iam_available,
    local.provider_validation.sts_available,
    local.provider_validation.sufficient_azs,
    local.provider_validation.instance_type_available,
    local.provider_validation.credentials_valid
  ])
  
  # Authentication method detection
  detected_auth_method = (
    can(regex("^arn:aws:iam::", data.aws_caller_identity.current.arn)) ? "iam_user" :
    can(regex("^arn:aws:sts::", data.aws_caller_identity.current.arn)) ? "assumed_role" :
    "unknown"
  )
  
  # Current IP CIDR for security groups
  current_ip_cidr = "${chomp(data.http.current_ip.response_body)}/32"
  
  # Provider capabilities summary
  provider_capabilities = {
    terraform_version = try(jsondecode(data.external.terraform_version.result.stdout).terraform_version, "unknown")
    aws_provider_version = try(local.aws_provider_info.current_version, "unknown")
    
    # Available services
    available_services = [
      data.aws_service.ec2.service_name,
      data.aws_service.s3.service_name,
      data.aws_service.iam.service_name,
      data.aws_service.sts.service_name
    ]
    
    # Region information
    region_info = {
      name = data.aws_region.current.name
      description = data.aws_region.current.description
      endpoint = data.aws_region.current.endpoint
      availability_zones = data.aws_availability_zones.available.names
    }
    
    # Account information
    account_info = {
      account_id = data.aws_caller_identity.current.account_id
      user_id = data.aws_caller_identity.current.user_id
      arn = data.aws_caller_identity.current.arn
      partition = data.aws_partition.current.partition
    }
  }
  
  # Cost estimation data
  cost_estimation = {
    ec2_pricing = try(jsondecode(data.aws_pricing_product.ec2.result), {})
    s3_pricing = try(jsondecode(data.aws_pricing_product.s3.result), {})
    billing_account = data.aws_billing_service_account.main.id
  }
}
