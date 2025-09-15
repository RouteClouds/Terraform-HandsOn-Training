# AWS Terraform Training - Core Terraform Operations
# Lab 3.1: Mastering Core Workflow and Resource Lifecycle
# File: data.tf - Data Sources for Core Operations and Resource Discovery

# ============================================================================
# TERRAFORM CORE OPERATION DATA SOURCES
# ============================================================================

# Generate unique operation ID for tracking
resource "random_uuid" "operation_id" {
  # This creates a unique identifier for each Terraform operation
  # Useful for tracking operations across logs and monitoring systems
}

# Get current timestamp for operation tracking
data "external" "current_timestamp" {
  program = ["bash", "-c", "echo '{\"timestamp\":\"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'\"}'"]
}

# Get Terraform version information
data "external" "terraform_version" {
  program = ["bash", "-c", "terraform version -json 2>/dev/null || echo '{\"terraform_version\":\"unknown\"}'"]
}

# Get current working directory for operation context
data "external" "working_directory" {
  program = ["bash", "-c", "echo '{\"pwd\":\"'$(pwd)'\"}'"]
}

# ============================================================================
# AWS ACCOUNT AND REGION INFORMATION
# ============================================================================

# Get current AWS caller identity
data "aws_caller_identity" "current" {
  # Provides account_id, arn, and user_id for the current AWS credentials
}

# Get current AWS region
data "aws_region" "current" {
  # Provides name, description, and endpoint for the current region
}

# Get AWS partition information
data "aws_partition" "current" {
  # Provides partition (aws, aws-cn, aws-us-gov), dns_suffix, etc.
}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Get AWS service endpoints for the region
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

# ============================================================================
# RESOURCE DISCOVERY AND VALIDATION
# ============================================================================

# Get latest Amazon Linux 2023 AMI
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
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu_22_04" {
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

# Get EC2 instance type information
data "aws_ec2_instance_type" "selected" {
  instance_type = var.instance_type
}

# Get EC2 instance type offerings in current region
data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
  
  filter {
    name   = "location"
    values = [data.aws_region.current.name]
  }
  
  location_type = "region"
}

# ============================================================================
# NETWORKING DATA SOURCES
# ============================================================================

# Get default VPC (for reference and validation)
data "aws_vpc" "default" {
  default = true
}

# Get default security group
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Get route tables for the default VPC
data "aws_route_tables" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Get internet gateway for default VPC
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get current public IP for security group configuration
data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
  
  request_headers = {
    Accept = "text/plain"
  }
}

# ============================================================================
# EXISTING INFRASTRUCTURE DISCOVERY
# ============================================================================

# Discover existing VPCs in the account
data "aws_vpcs" "existing" {
  tags = {
    Environment = var.environment
  }
}

# Discover existing subnets
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.existing.ids
  }
  
  tags = {
    Environment = var.environment
  }
}

# Discover existing security groups
data "aws_security_groups" "existing" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.existing.ids
  }
  
  tags = {
    Environment = var.environment
  }
}

# Discover existing EC2 instances
data "aws_instances" "existing" {
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
  
  filter {
    name   = "tag:Project"
    values = [var.project_name]
  }
  
  filter {
    name   = "instance-state-name"
    values = ["running", "stopped"]
  }
}

# ============================================================================
# TERRAFORM STATE AND WORKSPACE INFORMATION
# ============================================================================

# Get current Terraform workspace
data "external" "current_workspace" {
  program = ["bash", "-c", "echo '{\"workspace\":\"'$(terraform workspace show)'\"}'"]
}

# Get Terraform state information
data "external" "state_info" {
  program = ["bash", "-c", <<-EOT
    if [ -f terraform.tfstate ]; then
      echo '{"state_exists":"true","state_size":"'$(stat -f%z terraform.tfstate 2>/dev/null || stat -c%s terraform.tfstate 2>/dev/null || echo 0)'"}'
    else
      echo '{"state_exists":"false","state_size":"0"}'
    fi
  EOT
  ]
}

# Get list of resources in current state
data "external" "state_resources" {
  program = ["bash", "-c", <<-EOT
    if terraform state list >/dev/null 2>&1; then
      count=$(terraform state list | wc -l | tr -d ' ')
      echo '{"resource_count":"'$count'"}'
    else
      echo '{"resource_count":"0"}'
    fi
  EOT
  ]
}

# ============================================================================
# PERFORMANCE AND MONITORING DATA
# ============================================================================

# Get AWS CloudWatch log groups for monitoring
data "aws_cloudwatch_log_groups" "terraform_logs" {
  log_group_name_prefix = "/terraform/${var.project_name}"
}

# Get AWS Config configuration recorder status
data "aws_config_configuration_recorder_status" "current" {
  count = var.enable_aws_config ? 1 : 0
  name  = var.config_recorder_name
}

# Get CloudTrail information
data "aws_cloudtrail_service_account" "current" {}

# Get pricing information for cost estimation
data "aws_pricing_product" "ec2_instance" {
  service_code = "AmazonEC2"
  
  filters = [
    {
      field = "instanceType"
      value = var.instance_type
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

# ============================================================================
# SECURITY AND COMPLIANCE DATA
# ============================================================================

# Get AWS managed KMS keys
data "aws_kms_key" "ebs" {
  key_id = "alias/aws/ebs"
}

data "aws_kms_key" "s3" {
  key_id = "alias/aws/s3"
}

# Get AWS managed IAM policies
data "aws_iam_policy" "ec2_readonly" {
  name = "AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy" "s3_readonly" {
  name = "AmazonS3ReadOnlyAccess"
}

# Get AWS Organizations information (if applicable)
data "aws_organizations_organization" "current" {
  count = var.check_organizations ? 1 : 0
}

# ============================================================================
# OPERATION VALIDATION AND CONTEXT
# ============================================================================

locals {
  # Core operation validation results
  operation_validation = {
    # Basic environment validation
    aws_credentials_valid = data.aws_caller_identity.current.account_id != ""
    region_accessible = data.aws_region.current.name != ""
    availability_zones_sufficient = length(data.aws_availability_zones.available.names) >= 2
    
    # Service availability validation
    ec2_service_available = data.aws_service.ec2.service_name == "ec2"
    s3_service_available = data.aws_service.s3.service_name == "s3"
    
    # Resource validation
    ami_available = data.aws_ami.amazon_linux_2023.id != ""
    instance_type_available = length(data.aws_ec2_instance_type_offerings.available.instance_types) > 0
    instance_type_supported = data.aws_ec2_instance_type.selected.instance_type == var.instance_type
    
    # Network validation
    default_vpc_exists = data.aws_vpc.default.id != ""
    internet_gateway_exists = length(data.aws_internet_gateway.default.internet_gateway_id) > 0
    
    # State validation
    terraform_initialized = jsondecode(data.external.state_info.result).state_exists == "true"
    workspace_valid = jsondecode(data.external.current_workspace.result).workspace != ""
  }
  
  # All validations passed
  all_validations_passed = alltrue([
    local.operation_validation.aws_credentials_valid,
    local.operation_validation.region_accessible,
    local.operation_validation.availability_zones_sufficient,
    local.operation_validation.ec2_service_available,
    local.operation_validation.s3_service_available,
    local.operation_validation.ami_available,
    local.operation_validation.instance_type_available,
    local.operation_validation.instance_type_supported,
    local.operation_validation.default_vpc_exists
  ])
  
  # Operation context information
  operation_context = {
    # Terraform context
    terraform_version = try(jsondecode(data.external.terraform_version.result).terraform_version, "unknown")
    workspace = jsondecode(data.external.current_workspace.result).workspace
    working_directory = jsondecode(data.external.working_directory.result).pwd
    operation_timestamp = jsondecode(data.external.current_timestamp.result).timestamp
    operation_id = random_uuid.operation_id.result
    
    # AWS context
    account_id = data.aws_caller_identity.current.account_id
    region = data.aws_region.current.name
    partition = data.aws_partition.current.partition
    availability_zones = data.aws_availability_zones.available.names
    
    # Resource context
    selected_ami = data.aws_ami.amazon_linux_2023.id
    selected_instance_type = var.instance_type
    current_ip = chomp(data.http.current_ip.response_body)
    
    # State context
    state_exists = jsondecode(data.external.state_info.result).state_exists == "true"
    state_size_bytes = tonumber(jsondecode(data.external.state_info.result).state_size)
    resource_count = tonumber(jsondecode(data.external.state_resources.result).resource_count)
  }
  
  # Performance metrics
  performance_context = {
    # Expected operation times (baseline)
    expected_operation_times = {
      init_time_seconds = 30
      plan_time_seconds = 60
      apply_time_seconds = 300
      destroy_time_seconds = 180
    }
    
    # Resource creation estimates
    resource_creation_estimates = {
      vpc_creation_time = 10
      subnet_creation_time = 5
      security_group_creation_time = 3
      instance_creation_time = 60
      ebs_volume_creation_time = 30
    }
    
    # Cost estimates
    cost_estimates = {
      hourly_cost = try(tonumber(regex("([0-9.]+)", data.aws_pricing_product.ec2_instance.result)), 0.0116)
      daily_cost = try(tonumber(regex("([0-9.]+)", data.aws_pricing_product.ec2_instance.result)) * 24, 0.28)
      monthly_cost = try(tonumber(regex("([0-9.]+)", data.aws_pricing_product.ec2_instance.result)) * 24 * 30, 8.40)
    }
  }
  
  # Security context
  security_context = {
    # Current IP for security group rules
    current_ip_cidr = "${chomp(data.http.current_ip.response_body)}/32"
    
    # KMS key information
    ebs_kms_key_id = data.aws_kms_key.ebs.id
    s3_kms_key_id = data.aws_kms_key.s3.id
    
    # IAM policy references
    ec2_readonly_policy_arn = data.aws_iam_policy.ec2_readonly.arn
    s3_readonly_policy_arn = data.aws_iam_policy.s3_readonly.arn
    
    # Compliance context
    organizations_enabled = var.check_organizations ? length(data.aws_organizations_organization.current) > 0 : false
    config_enabled = var.enable_aws_config ? length(data.aws_config_configuration_recorder_status.current) > 0 : false
    cloudtrail_account = data.aws_cloudtrail_service_account.current.id
  }
}
