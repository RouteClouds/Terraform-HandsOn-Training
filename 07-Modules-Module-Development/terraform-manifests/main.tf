# Terraform Modules and Module Development - Main Configuration
# This demonstrates advanced module composition and enterprise patterns

terraform {
  required_version = ">= 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "modules-demo"
      Owner       = var.owner
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# Local values for computed configurations
locals {
  # Environment-specific configurations
  environment_config = {
    dev = {
      instance_type     = "t3.micro"
      min_instances     = 1
      max_instances     = 2
      db_instance_class = "db.t3.micro"
      enable_multi_az   = false
      backup_retention  = 1
      enable_monitoring = false
    }
    staging = {
      instance_type     = "t3.small"
      min_instances     = 1
      max_instances     = 3
      db_instance_class = "db.t3.small"
      enable_multi_az   = false
      backup_retention  = 7
      enable_monitoring = true
    }
    prod = {
      instance_type     = "t3.medium"
      min_instances     = 2
      max_instances     = 10
      db_instance_class = "db.t3.medium"
      enable_multi_az   = true
      backup_retention  = 30
      enable_monitoring = true
    }
  }
  
  config = local.environment_config[var.environment]
  
  # Availability zones (limit to 3 for cost optimization)
  availability_zones = slice(data.aws_availability_zones.available.names, 0, min(3, length(data.aws_availability_zones.available.names)))
  
  # Common tags
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Region      = data.aws_region.current.name
    AccountId   = data.aws_caller_identity.current.account_id
  }
}

# VPC Module - Foundation Layer
module "vpc" {
  source = "./modules/aws-vpc"
  
  name               = "${var.project_name}-${var.environment}"
  cidr_block         = var.vpc_cidr
  availability_zones = local.availability_zones
  environment        = var.environment
  
  # Cost optimization for non-production
  single_nat_gateway = var.environment != "prod"
  enable_nat_gateway = true
  
  # DNS configuration
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = local.common_tags
}

# Security Module - Security Layer
module "security" {
  source = "./modules/aws-security"
  
  name        = "${var.project_name}-${var.environment}"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = module.vpc.vpc_cidr_block
  environment = var.environment
  
  # Security group configurations
  web_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from anywhere"
    }
  ]
  
  app_ingress_rules = [
    {
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      source_sg_id    = null  # Will be set by module
      description     = "Application port from web tier"
    }
  ]
  
  db_ingress_rules = [
    {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      source_sg_id    = null  # Will be set by module
      description     = "MySQL from application tier"
    }
  ]
  
  tags = local.common_tags
}

# Compute Module - Application Layer
module "compute" {
  source = "./modules/aws-compute"
  
  name               = "${var.project_name}-${var.environment}"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  environment        = var.environment
  
  # Instance configuration
  instance_type = local.config.instance_type
  key_name      = var.key_pair_name
  
  # Auto Scaling configuration
  min_size         = local.config.min_instances
  max_size         = local.config.max_instances
  desired_capacity = local.config.min_instances
  
  # Security groups
  web_security_group_id = module.security.web_security_group_id
  app_security_group_id = module.security.app_security_group_id
  
  # Load balancer configuration
  enable_ssl      = var.enable_ssl
  certificate_arn = var.ssl_certificate_arn
  
  # Monitoring
  enable_detailed_monitoring = local.config.enable_monitoring
  
  tags = local.common_tags
  
  depends_on = [module.vpc, module.security]
}

# Database Module - Data Layer
module "database" {
  source = "./modules/aws-database"
  
  name                = "${var.project_name}-${var.environment}"
  vpc_id              = module.vpc.vpc_id
  database_subnet_ids = module.vpc.database_subnet_ids
  environment         = var.environment
  
  # Database configuration
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = local.config.db_instance_class
  
  # Storage configuration
  allocated_storage     = var.db_storage_size
  max_allocated_storage = var.db_max_storage_size
  storage_encrypted     = true
  
  # High availability
  multi_az               = local.config.enable_multi_az
  backup_retention_period = local.config.backup_retention
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Security
  db_security_group_id = module.security.database_security_group_id
  deletion_protection  = var.environment == "prod"
  skip_final_snapshot  = var.environment != "prod"
  
  # Monitoring
  performance_insights_enabled = local.config.enable_monitoring
  monitoring_interval         = local.config.enable_monitoring ? 60 : 0
  
  tags = local.common_tags
  
  depends_on = [module.vpc, module.security]
}

# Storage Module - Supporting Services
module "storage" {
  source = "./modules/aws-storage"
  
  name        = "${var.project_name}-${var.environment}"
  environment = var.environment
  
  # S3 configuration
  enable_versioning = var.environment == "prod"
  enable_encryption = true
  
  # Lifecycle management
  transition_to_ia_days      = 30
  transition_to_glacier_days = 90
  expiration_days           = var.environment == "prod" ? 2555 : 365  # 7 years for prod, 1 year for others
  
  tags = local.common_tags
}

# Monitoring Module - Observability Layer
module "monitoring" {
  source = "./modules/aws-monitoring"
  
  name        = "${var.project_name}-${var.environment}"
  environment = var.environment
  
  # Resources to monitor
  vpc_id                    = module.vpc.vpc_id
  load_balancer_arn_suffix  = module.compute.load_balancer_arn_suffix
  auto_scaling_group_name   = module.compute.auto_scaling_group_name
  rds_instance_id          = module.database.db_instance_id
  
  # Alerting configuration
  sns_topic_arn = var.sns_topic_arn
  
  # Monitoring thresholds
  cpu_threshold_high    = 80
  memory_threshold_high = 85
  disk_threshold_high   = 90
  
  # Enable detailed monitoring for production
  enable_detailed_monitoring = local.config.enable_monitoring
  
  tags = local.common_tags
  
  depends_on = [module.compute, module.database]
}

# Application Configuration Module
module "app_config" {
  source = "./modules/aws-app-config"

  name        = "${var.project_name}-${var.environment}"
  environment = var.environment

  # Application configuration
  app_settings = {
    database_endpoint = module.database.db_instance_endpoint
    database_port     = module.database.db_instance_port
    redis_endpoint    = ""  # Would be populated if Redis module was added
    s3_bucket_name    = module.storage.s3_bucket_name
    environment       = var.environment
    region           = data.aws_region.current.name
  }

  # Security configuration
  kms_key_arn = module.storage.kms_key_arn

  tags = local.common_tags

  depends_on = [module.database, module.storage]
}

# Example of Module Composition Pattern
module "web_application" {
  source = "./modules/aws-web-app-composite"

  # High-level configuration
  application_name = var.project_name
  environment     = var.environment

  # Infrastructure configuration
  vpc_cidr           = var.vpc_cidr
  availability_zones = local.availability_zones

  # Compute configuration
  instance_type    = local.config.instance_type
  min_instances    = local.config.min_instances
  max_instances    = local.config.max_instances
  key_pair_name    = var.key_pair_name

  # Database configuration
  db_instance_class = local.config.db_instance_class
  db_storage_size   = var.db_storage_size
  enable_multi_az   = local.config.enable_multi_az

  # Feature flags
  enable_monitoring = local.config.enable_monitoring
  enable_ssl       = var.enable_ssl
  enable_backups   = var.environment == "prod"

  # Security configuration
  allowed_cidr_blocks = var.allowed_cidr_blocks
  ssl_certificate_arn = var.ssl_certificate_arn

  tags = local.common_tags
}
