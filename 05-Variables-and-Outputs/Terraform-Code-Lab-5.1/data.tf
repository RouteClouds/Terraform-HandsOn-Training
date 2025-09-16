# Terraform Code Lab 5.1: Advanced Variables and Outputs
# Data Sources
#
# This file defines data sources used throughout the configuration.
# Data sources provide access to existing AWS resources and computed values
# that are used in variable validation, local value computation, and resource creation.

# Current AWS region information
data "aws_region" "current" {
  # Provides information about the current AWS region
  # Used in local values and outputs for region-specific configurations
}

# Current AWS caller identity
data "aws_caller_identity" "current" {
  # Provides information about the AWS account and user/role
  # Used for account-specific configurations and security policies
}

# Current AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {
  # Provides information about the AWS partition
  # Used for constructing ARNs and partition-specific configurations
}

# Available Availability Zones
data "aws_availability_zones" "available" {
  # Filter to only include available AZs
  state = "available"
  
  # Exclude AZs that don't support all required services
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
  
  # Exclude Local Zones and Wavelength Zones for standard deployments
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# AMI data for EC2 instances
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

# Ubuntu AMI for alternative OS option
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

# VPC Endpoints for secure AWS service access
data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
  
  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}

data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"
  
  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}

# EC2 instance type offerings in current region
data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = ["t3.micro", "t3.small", "t3.medium", "t3.large", "m5.large", "m5.xlarge"]
  }
  
  location_type = "availability-zone"
}

# RDS engine versions
data "aws_rds_engine_versions" "mysql" {
  engine = "mysql"
  
  filter {
    name   = "engine-mode"
    values = ["provisioned"]
  }
  
  preferred_versions = ["8.0.35", "8.0.34", "8.0.33"]
}

data "aws_rds_engine_versions" "postgres" {
  engine = "postgres"
  
  filter {
    name   = "engine-mode"
    values = ["provisioned"]
  }
  
  preferred_versions = ["15.4", "15.3", "14.9"]
}

# KMS key for encryption (if using existing key)
data "aws_kms_key" "default" {
  key_id = "alias/aws/ebs"
}

# Route53 hosted zone (if using existing domain)
# Uncomment if you have an existing hosted zone
# data "aws_route53_zone" "main" {
#   name         = var.domain_name
#   private_zone = false
# }

# ACM certificate (if using existing certificate)
# Uncomment if you have an existing certificate
# data "aws_acm_certificate" "main" {
#   domain   = var.domain_name
#   statuses = ["ISSUED"]
# }

# IAM policy documents for common policies
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
      "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_name}/*"
    ]
  }
  
  statement {
    effect = "Allow"
    
    actions = [
      "s3:ListBucket"
    ]
    
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_name}"
    ]
  }
}

# CloudWatch log groups (if using existing log groups)
# data "aws_cloudwatch_log_group" "application" {
#   name = "/aws/application/${var.application_name}"
# }

# Systems Manager parameters (for retrieving configuration values)
# Uncomment if using Parameter Store for configuration
# data "aws_ssm_parameter" "database_password" {
#   name            = "/app/${var.environment}/database/password"
#   with_decryption = true
# }

# data "aws_ssm_parameter" "api_key" {
#   name            = "/app/${var.environment}/api/key"
#   with_decryption = true
# }

# Secrets Manager secrets (for retrieving sensitive values)
# Uncomment if using Secrets Manager
# data "aws_secretsmanager_secret" "database_credentials" {
#   name = "${var.environment}/database/credentials"
# }

# data "aws_secretsmanager_secret_version" "database_credentials" {
#   secret_id = data.aws_secretsmanager_secret.database_credentials.id
# }

# Network ACL rules for security compliance
data "aws_network_acls" "default" {
  vpc_id = aws_vpc.main.id
  
  depends_on = [aws_vpc.main]
}

# Security group rules for compliance checking
# This can be used to validate existing security group configurations
# data "aws_security_groups" "existing" {
#   filter {
#     name   = "vpc-id"
#     values = [aws_vpc.main.id]
#   }
# }
