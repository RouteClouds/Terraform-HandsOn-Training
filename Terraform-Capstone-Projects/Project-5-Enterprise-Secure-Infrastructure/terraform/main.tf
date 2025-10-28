# Main Terraform Configuration - Enterprise-Grade Secure Infrastructure

terraform {
  required_version = ">= 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  
  # Backend configuration (uncomment for remote state)
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "enterprise-secure/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   kms_key_id     = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
      CostCenter  = var.cost_center
    }
  }
}

# ============================================================================
# Local Variables
# ============================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================================
# Secrets Module (Create First - Provides KMS Key)
# ============================================================================

module "secrets" {
  source = "./modules/secrets"
  
  project_name           = var.project_name
  environment            = var.environment
  kms_deletion_window    = var.kms_deletion_window
  secret_recovery_window = var.secret_recovery_window
  db_username            = var.db_username
  db_name                = var.db_name
  
  tags = local.common_tags
}

# ============================================================================
# VPC Module
# ============================================================================

module "vpc" {
  source = "./modules/vpc"
  
  project_name              = var.project_name
  aws_region                = var.aws_region
  vpc_cidr                  = var.vpc_cidr
  private_subnet_count      = var.private_subnet_count
  enable_nat_gateway        = var.enable_nat_gateway
  flow_logs_retention_days  = var.flow_logs_retention_days
  kms_key_arn               = module.secrets.kms_key_arn
  
  tags = local.common_tags
}

# ============================================================================
# Monitoring Module
# ============================================================================

module "monitoring" {
  source = "./modules/monitoring"
  
  project_name       = var.project_name
  aws_region         = var.aws_region
  kms_key_arn        = module.secrets.kms_key_arn
  log_retention_days = var.log_retention_days
  
  tags = local.common_tags
}

# ============================================================================
# Security Groups
# ============================================================================

# Application Security Group
resource "aws_security_group" "application" {
  name_prefix = "${var.project_name}-app-"
  description = "Security group for application tier"
  vpc_id      = module.vpc.vpc_id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-application-sg"
      Tier = "application"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Application ingress from ALB only (port 8080)
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id = aws_security_group.application.id
  description       = "Allow traffic from ALB"
  
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
  
  tags = {
    Name = "allow-alb"
  }
}

# Application egress (HTTPS to VPC endpoints)
resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.application.id
  description       = "Allow HTTPS to VPC endpoints"
  
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = module.vpc.vpc_cidr
  
  tags = {
    Name = "allow-https-vpc"
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-alb-sg"
      Tier = "load-balancer"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# ALB ingress (HTTPS only)
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from internet"
  
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
  
  tags = {
    Name = "allow-https"
  }
}

# ALB egress to application
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow traffic to application"
  
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.application.id
  
  tags = {
    Name = "allow-app"
  }
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-db-"
  description = "Security group for database tier"
  vpc_id      = module.vpc.vpc_id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-database-sg"
      Tier = "database"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Database ingress from application only
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id = aws_security_group.database.id
  description       = "Allow PostgreSQL from application"
  
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.application.id
  
  tags = {
    Name = "allow-app-postgres"
  }
}

# No egress rules for database (deny all outbound)

# ============================================================================
# IAM Roles
# ============================================================================

# EC2 Instance Role
resource "aws_iam_role" "ec2_instance" {
  name = "${var.project_name}-ec2-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = local.common_tags
}

# Attach SSM policy for Session Manager
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach secrets read policy
resource "aws_iam_role_policy_attachment" "ec2_secrets" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = module.secrets.read_secrets_policy_arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance.name
  
  tags = local.common_tags
}

