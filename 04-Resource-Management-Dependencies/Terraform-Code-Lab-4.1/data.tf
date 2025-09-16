# AWS Terraform Training - Topic 4: Resource Management & Dependencies
# Terraform Code Lab 4.1 - Data Sources and External Integration
#
# This file defines comprehensive data sources for dynamic configuration,
# dependency resolution, and integration with existing AWS infrastructure.
# Data sources provide read-only access to information and help establish
# implicit dependencies in complex infrastructure scenarios.

# AWS Account and Region Information
data "aws_caller_identity" "current" {
  # Provides current AWS account ID for resource ARN construction
  # and cross-account access patterns
}

data "aws_region" "current" {
  # Provides current AWS region for resource configuration
  # and region-specific service availability
}

data "aws_partition" "current" {
  # Provides AWS partition (aws, aws-cn, aws-us-gov) for
  # correct ARN construction in different AWS environments
}

# Availability Zone Information
data "aws_availability_zones" "available" {
  state = "available"
  
  # Filter out Local Zones and Wavelength Zones for standard deployments
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_availability_zones" "all" {
  # Get all availability zones including opted-in zones
  # for comprehensive zone analysis
}

# AMI Information for EC2 Instances
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
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

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

# EC2 Instance Type Information
data "aws_ec2_instance_types" "available" {
  filter {
    name   = "instance-type"
    values = ["t3.*", "t2.*", "m5.*", "c5.*"]
  }
  
  filter {
    name   = "current-generation"
    values = ["true"]
  }
}

data "aws_ec2_instance_type" "selected" {
  for_each = toset(["t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge"])
  
  instance_type = each.value
}

# VPC and Networking Information
data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"
}

data "aws_route53_zone" "main" {
  count = var.feature_flags.enable_cdn ? 1 : 0
  
  name         = "example.com"
  private_zone = false
}

# RDS Information
data "aws_rds_engine_version" "mysql" {
  engine  = "mysql"
  version = var.database_config.engine_version
}

data "aws_rds_engine_version" "postgres" {
  engine  = "postgres"
  version = "14.9"
}

data "aws_db_instance" "existing" {
  count = 0  # Set to 1 if importing existing database
  
  db_instance_identifier = "${local.name_prefix}-existing-db"
}

# ElastiCache Information
data "aws_elasticache_engine_version" "redis" {
  engine = "redis"
}

# IAM Information
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

data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    
    actions = ["s3:*"]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.name_prefix}-*",
      "arn:${data.aws_partition.current.partition}:s3:::${local.name_prefix}-*/*"
    ]
    
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# KMS Information
data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_kms_alias" "rds" {
  name = "alias/aws/rds"
}

data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}

# CloudWatch Information
data "aws_cloudwatch_log_group" "existing" {
  count = 0  # Set to 1 if using existing log group
  
  name = "/aws/ec2/${local.name_prefix}"
}

# S3 Information
data "aws_s3_bucket" "existing" {
  count = 0  # Set to 1 if using existing bucket
  
  bucket = "${local.name_prefix}-existing-bucket"
}

data "aws_canonical_user_id" "current" {
  # Used for S3 bucket ACL configuration
}

# Load Balancer Information
data "aws_lb_hosted_zone_id" "main" {
  # Get the hosted zone ID for the load balancer region
  # Used for Route53 alias records
}

# Certificate Information (if using HTTPS)
data "aws_acm_certificate" "main" {
  count = var.feature_flags.enable_cdn ? 1 : 0
  
  domain   = "*.example.com"
  statuses = ["ISSUED"]
}

# Parameter Store Information
data "aws_ssm_parameter" "database_password" {
  count = var.feature_flags.enable_parameter_store ? 1 : 0
  
  name            = "/${local.environment}/${local.project}/database/password"
  with_decryption = true
}

data "aws_ssm_parameters_by_path" "app_config" {
  count = var.feature_flags.enable_parameter_store ? 1 : 0
  
  path            = "/${local.environment}/${local.project}/app"
  recursive       = true
  with_decryption = true
}

# Secrets Manager Information
data "aws_secretsmanager_secret" "database_credentials" {
  count = var.feature_flags.enable_secrets_manager ? 1 : 0
  
  name = "${local.environment}/${local.project}/database/credentials"
}

data "aws_secretsmanager_secret_version" "database_credentials" {
  count = var.feature_flags.enable_secrets_manager ? 1 : 0
  
  secret_id = data.aws_secretsmanager_secret.database_credentials[0].id
}

# External Data Sources for Dynamic Configuration
data "external" "environment_info" {
  program = ["bash", "-c", <<-EOT
    echo '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","environment":"${var.environment}","region":"${var.aws_region}"}'
  EOT
  ]
}

data "http" "ip_address" {
  url = "https://ipv4.icanhazip.com"
}

# Template Files for User Data
data "template_file" "web_user_data" {
  template = file("${path.module}/templates/web_user_data.sh.tpl")
  
  vars = {
    environment     = local.environment
    project_name    = local.project
    region          = local.region
    log_group_name  = local.monitoring_config.log_group_name
  }
}

data "template_file" "api_user_data" {
  template = file("${path.module}/templates/api_user_data.sh.tpl")
  
  vars = {
    environment     = local.environment
    project_name    = local.project
    region          = local.region
    database_endpoint = "placeholder"  # Will be replaced after database creation
    log_group_name  = local.monitoring_config.log_group_name
  }
}

data "template_file" "worker_user_data" {
  template = file("${path.module}/templates/worker_user_data.sh.tpl")
  
  vars = {
    environment     = local.environment
    project_name    = local.project
    region          = local.region
    queue_url       = "placeholder"  # Will be replaced after queue creation
    log_group_name  = local.monitoring_config.log_group_name
  }
}

# Local File Data Sources
data "local_file" "ssh_public_key" {
  count = fileexists("~/.ssh/id_rsa.pub") ? 1 : 0
  
  filename = "~/.ssh/id_rsa.pub"
}

# Archive Data Sources for Lambda Functions (if needed)
data "archive_file" "lambda_function" {
  count = var.feature_flags.enable_monitoring ? 1 : 0
  
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

# Data Source Dependencies and Usage Notes:
#
# 1. Account and Region Data:
#    - Used for ARN construction and resource identification
#    - Provides dynamic configuration based on deployment context
#
# 2. AMI Data Sources:
#    - Automatically select latest AMIs for consistent deployments
#    - Filter by architecture and virtualization type for compatibility
#
# 3. Networking Data:
#    - VPC endpoint services for private connectivity
#    - Route53 zones for DNS management
#
# 4. IAM Policy Documents:
#    - Define trust relationships and permissions
#    - Support least-privilege access patterns
#
# 5. External Data Sources:
#    - Integrate with external systems and APIs
#    - Provide dynamic configuration based on external state
#
# 6. Template Files:
#    - Generate dynamic user data scripts
#    - Support environment-specific configuration
#
# Best Practices:
# - Use data sources to avoid hardcoding values
# - Filter data sources for specific requirements
# - Handle optional data sources with count parameters
# - Document data source dependencies and usage
# - Use template files for complex configuration generation
