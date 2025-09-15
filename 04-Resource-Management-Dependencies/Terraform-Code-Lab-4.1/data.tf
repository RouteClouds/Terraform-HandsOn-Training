# AWS Terraform Training - Resource Management & Dependencies
# Lab 4.1: Advanced Resource Lifecycle and Dependency Management
# File: data.tf - Data Sources for Resource Discovery and Dependency Validation

# ============================================================================
# AWS ACCOUNT AND REGION INFORMATION
# ============================================================================

# Get current AWS caller identity
data "aws_caller_identity" "current" {
  # Provides account_id, arn, and user_id for dependency validation
}

# Get current AWS region
data "aws_region" "current" {
  # Provides region information for resource placement and dependencies
}

# Get AWS partition information
data "aws_partition" "current" {
  # Provides partition information for ARN construction
}

# Get available availability zones for multi-AZ dependencies
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# ============================================================================
# EXISTING INFRASTRUCTURE DISCOVERY
# ============================================================================

# Discover existing VPCs for dependency analysis
data "aws_vpcs" "existing" {
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Discover existing subnets and their dependencies
data "aws_subnets" "existing_public" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.existing.ids
  }
  
  tags = {
    Type = "public"
  }
}

data "aws_subnets" "existing_private" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.existing.ids
  }
  
  tags = {
    Type = "private"
  }
}

# Discover existing security groups and their dependencies
data "aws_security_groups" "existing" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.existing.ids
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Discover existing EC2 instances and their dependencies
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
    values = ["running", "stopped", "pending"]
  }
}

# ============================================================================
# AMI AND INSTANCE TYPE DATA FOR RESOURCE DEPENDENCIES
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

# Get EC2 instance type information for dependency validation
data "aws_ec2_instance_type" "web" {
  instance_type = var.web_instance_type
}

data "aws_ec2_instance_type" "app" {
  instance_type = var.app_instance_type
}

data "aws_ec2_instance_type" "db" {
  instance_type = var.db_instance_type
}

# Get EC2 instance type offerings in current region
data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = [var.web_instance_type, var.app_instance_type, var.db_instance_type]
  }
  
  filter {
    name   = "location"
    values = [data.aws_region.current.name]
  }
  
  location_type = "region"
}

# ============================================================================
# NETWORKING DATA FOR DEPENDENCY VALIDATION
# ============================================================================

# Get default VPC for reference
data "aws_vpc" "default" {
  default = true
}

# Get default security group for dependency analysis
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Get route tables for dependency understanding
data "aws_route_tables" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Get internet gateway for dependency validation
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get current public IP for security group dependencies
data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
  
  request_headers = {
    Accept = "text/plain"
  }
}

# ============================================================================
# LOAD BALANCER AND TARGET GROUP DATA
# ============================================================================

# Discover existing load balancers and their dependencies
data "aws_lbs" "existing" {
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Discover existing target groups
data "aws_lb_target_groups" "existing" {
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Get SSL certificate for HTTPS load balancer dependencies
data "aws_acm_certificate" "main" {
  count  = var.enable_ssl ? 1 : 0
  domain = var.domain_name
  
  statuses = ["ISSUED"]
  
  most_recent = true
}

# ============================================================================
# DATABASE AND STORAGE DATA
# ============================================================================

# Get RDS subnet groups for database dependencies
data "aws_db_subnet_groups" "existing" {
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Get RDS parameter groups for database configuration
data "aws_db_parameter_group" "mysql" {
  count = var.database_engine == "mysql" ? 1 : 0
  name  = "default.mysql8.0"
}

data "aws_db_parameter_group" "postgres" {
  count = var.database_engine == "postgres" ? 1 : 0
  name  = "default.postgres14"
}

# Get ElastiCache subnet groups for cache dependencies
data "aws_elasticache_subnet_group" "existing" {
  count = var.enable_cache ? 1 : 0
  name  = "${var.project_name}-${var.environment}-cache-subnet-group"
}

# ============================================================================
# SECURITY AND IAM DATA
# ============================================================================

# Get AWS managed KMS keys for encryption dependencies
data "aws_kms_key" "ebs" {
  key_id = "alias/aws/ebs"
}

data "aws_kms_key" "s3" {
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}

# Get AWS managed IAM policies for role dependencies
data "aws_iam_policy" "ec2_ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloudwatch_agent" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "s3_readonly" {
  name = "AmazonS3ReadOnlyAccess"
}

# Get IAM policy documents for role creation
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

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.environment}-*/*"
    ]
  }
  
  statement {
    effect = "Allow"
    
    actions = [
      "s3:ListBucket"
    ]
    
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.environment}-*"
    ]
  }
}

# ============================================================================
# MONITORING AND LOGGING DATA
# ============================================================================

# Get CloudWatch log groups for dependency analysis
data "aws_cloudwatch_log_groups" "existing" {
  log_group_name_prefix = "/aws/ec2/${var.project_name}"
}

# Get SNS topics for alerting dependencies
data "aws_sns_topics" "existing" {
  name_contains = "${var.project_name}-${var.environment}"
}

# Get CloudWatch dashboards
data "aws_cloudwatch_dashboard" "existing" {
  count          = var.enable_monitoring ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"
}

# ============================================================================
# DEPENDENCY VALIDATION AND ANALYSIS
# ============================================================================

locals {
  # Resource dependency validation
  dependency_validation = {
    # Basic infrastructure validation
    vpc_available = length(data.aws_vpcs.existing.ids) > 0
    subnets_available = length(data.aws_subnets.existing_public.ids) > 0 && length(data.aws_subnets.existing_private.ids) > 0
    security_groups_available = length(data.aws_security_groups.existing.ids) > 0
    
    # Compute resource validation
    ami_available = data.aws_ami.amazon_linux_2023.id != ""
    instance_types_available = length(data.aws_ec2_instance_type_offerings.available.instance_types) >= 3
    
    # Network dependency validation
    internet_gateway_available = length(data.aws_internet_gateway.default.internet_gateway_id) > 0
    route_tables_available = length(data.aws_route_tables.default.ids) > 0
    
    # Security dependency validation
    kms_keys_available = data.aws_kms_key.ebs.id != "" && data.aws_kms_key.s3.id != ""
    iam_policies_available = data.aws_iam_policy.ec2_ssm.arn != ""
    
    # SSL certificate validation (if enabled)
    ssl_certificate_available = var.enable_ssl ? length(data.aws_acm_certificate.main) > 0 : true
  }
  
  # All dependency validations passed
  all_dependencies_valid = alltrue([
    local.dependency_validation.vpc_available,
    local.dependency_validation.subnets_available,
    local.dependency_validation.ami_available,
    local.dependency_validation.instance_types_available,
    local.dependency_validation.internet_gateway_available,
    local.dependency_validation.kms_keys_available,
    local.dependency_validation.ssl_certificate_available
  ])
  
  # Resource discovery results
  discovered_resources = {
    # Existing infrastructure
    existing_vpcs = data.aws_vpcs.existing.ids
    existing_public_subnets = data.aws_subnets.existing_public.ids
    existing_private_subnets = data.aws_subnets.existing_private.ids
    existing_security_groups = data.aws_security_groups.existing.ids
    existing_instances = data.aws_instances.existing.ids
    
    # Available resources
    available_azs = data.aws_availability_zones.available.names
    available_instance_types = data.aws_ec2_instance_type_offerings.available.instance_types
    
    # Security resources
    kms_keys = {
      ebs = data.aws_kms_key.ebs.id
      s3 = data.aws_kms_key.s3.id
      rds = data.aws_kms_key.rds.id
    }
    
    # IAM resources
    iam_policies = {
      ec2_ssm = data.aws_iam_policy.ec2_ssm.arn
      cloudwatch_agent = data.aws_iam_policy.cloudwatch_agent.arn
      s3_readonly = data.aws_iam_policy.s3_readonly.arn
    }
  }
  
  # Dependency mapping for resource creation
  dependency_mapping = {
    # Network dependencies
    network_dependencies = {
      vpc_id = length(local.discovered_resources.existing_vpcs) > 0 ? local.discovered_resources.existing_vpcs[0] : null
      public_subnet_ids = local.discovered_resources.existing_public_subnets
      private_subnet_ids = local.discovered_resources.existing_private_subnets
      availability_zones = local.discovered_resources.available_azs
    }
    
    # Security dependencies
    security_dependencies = {
      kms_key_ebs = local.discovered_resources.kms_keys.ebs
      kms_key_s3 = local.discovered_resources.kms_keys.s3
      kms_key_rds = local.discovered_resources.kms_keys.rds
      current_ip_cidr = "${chomp(data.http.current_ip.response_body)}/32"
    }
    
    # Compute dependencies
    compute_dependencies = {
      ami_id = data.aws_ami.amazon_linux_2023.id
      instance_types = {
        web = var.web_instance_type
        app = var.app_instance_type
        db = var.db_instance_type
      }
      iam_instance_profile = var.create_iam_instance_profile
    }
    
    # Storage dependencies
    storage_dependencies = {
      db_parameter_group = var.database_engine == "mysql" ? 
        (length(data.aws_db_parameter_group.mysql) > 0 ? data.aws_db_parameter_group.mysql[0].name : null) :
        (length(data.aws_db_parameter_group.postgres) > 0 ? data.aws_db_parameter_group.postgres[0].name : null)
      
      cache_subnet_group = var.enable_cache ? 
        (length(data.aws_elasticache_subnet_group.existing) > 0 ? data.aws_elasticache_subnet_group.existing[0].name : null) : null
    }
    
    # Monitoring dependencies
    monitoring_dependencies = {
      log_groups = data.aws_cloudwatch_log_groups.existing.log_group_names
      sns_topics = data.aws_sns_topics.existing.topic_arns
      dashboard_exists = var.enable_monitoring ? length(data.aws_cloudwatch_dashboard.existing) > 0 : false
    }
  }
  
  # Resource creation order based on dependencies
  creation_order = {
    layer_1_foundation = [
      "aws_vpc",
      "aws_internet_gateway",
      "aws_subnet"
    ]
    
    layer_2_security = [
      "aws_security_group",
      "aws_network_acl",
      "aws_iam_role",
      "aws_iam_instance_profile"
    ]
    
    layer_3_routing = [
      "aws_route_table",
      "aws_route",
      "aws_nat_gateway"
    ]
    
    layer_4_storage = [
      "aws_ebs_volume",
      "aws_s3_bucket",
      "aws_db_subnet_group",
      "aws_rds_instance"
    ]
    
    layer_5_compute = [
      "aws_instance",
      "aws_launch_template",
      "aws_autoscaling_group"
    ]
    
    layer_6_load_balancing = [
      "aws_lb_target_group",
      "aws_lb",
      "aws_lb_listener"
    ]
    
    layer_7_monitoring = [
      "aws_cloudwatch_log_group",
      "aws_cloudwatch_dashboard",
      "aws_cloudwatch_alarm",
      "aws_sns_topic"
    ]
  }
}
