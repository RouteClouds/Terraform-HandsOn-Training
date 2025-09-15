# AWS Terraform Training - Variables and Outputs
# Lab 5.1: Advanced Variable Management and Output Patterns
# File: data.tf - Data Sources for Variable Validation and Dynamic Configuration

# ============================================================================
# AWS ACCOUNT AND REGION INFORMATION
# ============================================================================

# Get current AWS caller identity
data "aws_caller_identity" "current" {
  # Provides account_id, arn, and user_id for variable validation
}

# Get current AWS region
data "aws_region" "current" {
  # Provides region information for variable validation
}

# Get AWS partition information
data "aws_partition" "current" {
  # Provides partition information for ARN construction
}

# Get available availability zones for validation
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# ============================================================================
# AMI DATA SOURCES FOR VARIABLE-DRIVEN INSTANCE CONFIGURATION
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

# ============================================================================
# INSTANCE TYPE VALIDATION DATA SOURCES
# ============================================================================

# Validate web tier instance type
data "aws_ec2_instance_type" "web" {
  instance_type = local.current_env_config.instance_types.web
}

# Validate app tier instance type
data "aws_ec2_instance_type" "app" {
  instance_type = local.current_env_config.instance_types.app
}

# Get EC2 instance type offerings in current region
data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = [
      local.current_env_config.instance_types.web,
      local.current_env_config.instance_types.app
    ]
  }
  
  filter {
    name   = "location"
    values = [data.aws_region.current.name]
  }
  
  location_type = "region"
}

# ============================================================================
# PARAMETER STORE DATA SOURCES FOR DYNAMIC CONFIGURATION
# ============================================================================

# Get application configuration from Parameter Store
data "aws_ssm_parameter" "app_config" {
  for_each = toset([
    "app_version",
    "feature_flags",
    "cache_config",
    "api_endpoints"
  ])
  
  name = "/${var.project_name}/${var.environment}/app/${each.key}"
  
  # Use default values if parameters don't exist
  depends_on = []
}

# Get database configuration from Parameter Store
data "aws_ssm_parameter" "database_config" {
  for_each = toset([
    "backup_window",
    "maintenance_window",
    "parameter_group_family"
  ])
  
  name = "/${var.project_name}/${var.environment}/database/${each.key}"
  
  # Use default values if parameters don't exist
  depends_on = []
}

# Get monitoring configuration from Parameter Store
data "aws_ssm_parameter" "monitoring_config" {
  for_each = toset([
    "log_level",
    "metric_collection_interval",
    "alert_thresholds"
  ])
  
  name = "/${var.project_name}/${var.environment}/monitoring/${each.key}"
  
  # Use default values if parameters don't exist
  depends_on = []
}

# ============================================================================
# SECRETS MANAGER DATA SOURCES FOR SENSITIVE CONFIGURATION
# ============================================================================

# Get existing database credentials (if they exist)
data "aws_secretsmanager_secret" "existing_database_credentials" {
  count = var.database_credentials.password == "" ? 1 : 0
  name  = "${local.resource_prefix}/database/credentials"
  
  # This will fail if the secret doesn't exist, which is expected
  depends_on = []
}

data "aws_secretsmanager_secret_version" "existing_database_credentials" {
  count     = var.database_credentials.password == "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.existing_database_credentials[0].id
  
  depends_on = []
}

# ============================================================================
# NETWORKING DATA SOURCES FOR VALIDATION
# ============================================================================

# Get current public IP for security group configuration
data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
  
  request_headers = {
    Accept = "text/plain"
  }
}

# Get VPC endpoints available in the region
data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

data "aws_vpc_endpoint_service" "ec2" {
  service      = "ec2"
  service_type = "Interface"
}

data "aws_vpc_endpoint_service" "ssm" {
  service      = "ssm"
  service_type = "Interface"
}

# ============================================================================
# SECURITY AND COMPLIANCE DATA SOURCES
# ============================================================================

# Get AWS managed KMS keys
data "aws_kms_key" "ebs" {
  key_id = "alias/aws/ebs"
}

data "aws_kms_key" "s3" {
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}

# Get AWS managed IAM policies
data "aws_iam_policy" "ec2_ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloudwatch_agent" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "s3_readonly" {
  name = "AmazonS3ReadOnlyAccess"
}

# Get SSL certificate (if domain is provided)
data "aws_acm_certificate" "main" {
  for_each = var.ssl_certificates
  
  domain   = each.value.domain_name
  statuses = ["ISSUED"]
  
  most_recent = true
}

# ============================================================================
# COST AND BILLING DATA SOURCES
# ============================================================================

# Get AWS billing service account
data "aws_billing_service_account" "main" {}

# Get pricing information for cost estimation
data "aws_pricing_product" "ec2_web" {
  service_code = "AmazonEC2"
  
  filters = [
    {
      field = "instanceType"
      value = local.current_env_config.instance_types.web
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

data "aws_pricing_product" "ec2_app" {
  service_code = "AmazonEC2"
  
  filters = [
    {
      field = "instanceType"
      value = local.current_env_config.instance_types.app
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
# VALIDATION AND COMPUTED DATA
# ============================================================================

locals {
  # Variable validation results
  variable_validation = {
    # AWS environment validation
    account_accessible = data.aws_caller_identity.current.account_id != ""
    region_valid = data.aws_region.current.name == var.aws_region
    partition_correct = data.aws_partition.current.partition == "aws"
    
    # Availability zone validation
    az_count_sufficient = length(data.aws_availability_zones.available.names) >= length(var.infrastructure_config.networking.availability_zones)
    az_names_valid = alltrue([
      for az in var.infrastructure_config.networking.availability_zones :
      contains(data.aws_availability_zones.available.names, az)
    ])
    
    # Instance type validation
    web_instance_type_available = contains(data.aws_ec2_instance_type_offerings.available.instance_types, local.current_env_config.instance_types.web)
    app_instance_type_available = contains(data.aws_ec2_instance_type_offerings.available.instance_types, local.current_env_config.instance_types.app)
    
    # AMI validation
    ami_available = data.aws_ami.amazon_linux_2023.id != ""
    
    # Security validation
    kms_keys_available = data.aws_kms_key.ebs.id != "" && data.aws_kms_key.s3.id != "" && data.aws_kms_key.rds.id != ""
    iam_policies_available = data.aws_iam_policy.ec2_ssm.arn != ""
    
    # SSL certificate validation (if configured)
    ssl_certificates_valid = length(var.ssl_certificates) == 0 || alltrue([
      for cert_name, cert in data.aws_acm_certificate.main :
      cert.status == "ISSUED"
    ])
  }
  
  # All variable validations passed
  all_variable_validations_passed = alltrue([
    local.variable_validation.account_accessible,
    local.variable_validation.region_valid,
    local.variable_validation.partition_correct,
    local.variable_validation.az_count_sufficient,
    local.variable_validation.az_names_valid,
    local.variable_validation.web_instance_type_available,
    local.variable_validation.app_instance_type_available,
    local.variable_validation.ami_available,
    local.variable_validation.kms_keys_available,
    local.variable_validation.iam_policies_available,
    local.variable_validation.ssl_certificates_valid
  ])
  
  # Parameter Store configuration (with defaults)
  parameter_store_config = {
    app_version = try(data.aws_ssm_parameter.app_config["app_version"].value, "1.0.0")
    feature_flags = try(jsondecode(data.aws_ssm_parameter.app_config["feature_flags"].value), {
      enable_new_ui = false
      enable_analytics = false
    })
    cache_config = try(jsondecode(data.aws_ssm_parameter.app_config["cache_config"].value), {
      ttl_seconds = 3600
      max_size_mb = 256
    })
    api_endpoints = try(jsondecode(data.aws_ssm_parameter.app_config["api_endpoints"].value), {})
    
    # Database configuration
    backup_window = try(data.aws_ssm_parameter.database_config["backup_window"].value, "03:00-04:00")
    maintenance_window = try(data.aws_ssm_parameter.database_config["maintenance_window"].value, "sun:04:00-sun:05:00")
    parameter_group_family = try(data.aws_ssm_parameter.database_config["parameter_group_family"].value, "mysql8.0")
    
    # Monitoring configuration
    log_level = try(data.aws_ssm_parameter.monitoring_config["log_level"].value, "INFO")
    metric_collection_interval = try(tonumber(data.aws_ssm_parameter.monitoring_config["metric_collection_interval"].value), 60)
    alert_thresholds = try(jsondecode(data.aws_ssm_parameter.monitoring_config["alert_thresholds"].value), {
      cpu = 80
      memory = 85
      disk = 90
    })
  }
  
  # Cost estimation data
  cost_estimation = {
    web_instance_hourly_cost = try(tonumber(regex("([0-9.]+)", data.aws_pricing_product.ec2_web.result)), 0.0116)
    app_instance_hourly_cost = try(tonumber(regex("([0-9.]+)", data.aws_pricing_product.ec2_app.result)), 0.0232)
    
    # Monthly cost estimation
    estimated_monthly_cost = (
      local.cost_estimation.web_instance_hourly_cost * local.web_instance_config.desired_size * 24 * 30 +
      local.cost_estimation.app_instance_hourly_cost * local.app_instance_config.desired_size * 24 * 30
    )
    
    # Cost optimization potential
    spot_savings_potential = local.current_env_config.cost_config.enable_spot_instances ? 
      local.cost_estimation.estimated_monthly_cost * 0.7 : 0  # 70% savings with spot instances
  }
  
  # Security context
  security_context = {
    current_ip_cidr = "${chomp(data.http.current_ip.response_body)}/32"
    kms_key_ids = {
      ebs = data.aws_kms_key.ebs.id
      s3  = data.aws_kms_key.s3.id
      rds = data.aws_kms_key.rds.id
    }
    iam_policy_arns = {
      ec2_ssm = data.aws_iam_policy.ec2_ssm.arn
      cloudwatch_agent = data.aws_iam_policy.cloudwatch_agent.arn
      s3_readonly = data.aws_iam_policy.s3_readonly.arn
    }
    ssl_certificate_arns = {
      for cert_name, cert in data.aws_acm_certificate.main :
      cert_name => cert.arn
    }
  }
}
