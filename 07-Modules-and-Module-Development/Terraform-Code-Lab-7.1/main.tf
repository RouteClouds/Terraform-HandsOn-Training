# =============================================================================
# AWS Terraform Training - Topic 7: Modules and Module Development
# Main Infrastructure Configuration with Module Examples
# =============================================================================

# Random ID for unique resource naming
resource "random_id" "module_suffix" {
  byte_length = 4
}

# Random password for demonstration purposes
resource "random_password" "demo_password" {
  length  = 16
  special = true
}

# =============================================================================
# Module Development Infrastructure
# =============================================================================

# Module 1: VPC Module Example
module "vpc_example" {
  source = "./modules/vpc"
  
  # Module inputs
  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  
  # Module-specific configuration
  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
  
  # Tagging
  tags = merge(local.common_tags, {
    ModuleType = "networking"
    ModuleName = "vpc_example"
    Version    = var.module_version
  })
  
  # Conditional creation based on module examples configuration
  count = var.module_examples["vpc_module"].enabled ? 1 : 0
}

# Module 2: Security Group Module Example
module "security_group_example" {
  source = "./modules/security-group"
  
  # Dependencies
  vpc_id = var.module_examples["vpc_module"].enabled ? module.vpc_example[0].vpc_id : data.aws_vpc.default.id
  
  # Module inputs
  project_name = var.project_name
  environment  = var.environment
  
  # Security group rules
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "SSH access from VPC"
    }
  ]
  
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
  
  # Tagging
  tags = merge(local.common_tags, {
    ModuleType = "security"
    ModuleName = "security_group_example"
    Version    = var.module_version
  })
  
  # Conditional creation
  count = var.module_examples["compute_module"].enabled ? 1 : 0
}

# Module 3: EC2 Instance Module Example
module "ec2_instance_example" {
  source = "./modules/ec2-instance"
  
  # Dependencies
  vpc_id            = var.module_examples["vpc_module"].enabled ? module.vpc_example[0].vpc_id : data.aws_vpc.default.id
  subnet_ids        = var.module_examples["vpc_module"].enabled ? module.vpc_example[0].private_subnet_ids : data.aws_subnets.default.ids
  security_group_id = var.module_examples["compute_module"].enabled ? module.security_group_example[0].security_group_id : null
  
  # Module inputs
  project_name    = var.project_name
  environment     = var.environment
  instance_type   = var.module_examples["compute_module"].instance_type
  
  # Auto Scaling configuration
  min_size         = var.module_examples["compute_module"].min_size
  max_size         = var.module_examples["compute_module"].max_size
  desired_capacity = var.module_examples["compute_module"].desired_capacity
  
  # Monitoring
  enable_detailed_monitoring = var.module_examples["compute_module"].enable_monitoring
  
  # User data script
  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))
  
  # Tagging
  tags = merge(local.common_tags, var.module_examples["compute_module"].tags, {
    ModuleName = "ec2_instance_example"
    Version    = var.module_version
  })
  
  # Conditional creation
  count = var.module_examples["compute_module"].enabled ? 1 : 0
}

# Module 4: S3 Bucket Module Example
module "s3_bucket_example" {
  source = "./modules/s3-bucket"
  
  # Module inputs
  project_name = var.project_name
  environment  = var.environment
  bucket_name  = "${var.project_name}-${var.environment}-example-${random_id.module_suffix.hex}"
  
  # S3 configuration
  enable_versioning     = true
  enable_encryption     = true
  enable_public_access_block = true
  enable_lifecycle_policy    = true
  
  # Lifecycle configuration
  lifecycle_rules = [
    {
      id     = "transition_to_ia"
      status = "Enabled"
      
      transition = {
        days          = 30
        storage_class = "STANDARD_IA"
      }
    },
    {
      id     = "transition_to_glacier"
      status = "Enabled"
      
      transition = {
        days          = 90
        storage_class = "GLACIER"
      }
    }
  ]
  
  # Tagging
  tags = merge(local.common_tags, var.module_examples["storage_module"].tags, {
    ModuleName = "s3_bucket_example"
    Version    = var.module_version
  })
  
  # Conditional creation
  count = var.module_examples["storage_module"].enabled ? 1 : 0
}

# Module 5: RDS Database Module Example
module "rds_database_example" {
  source = "./modules/rds-database"
  
  # Dependencies
  vpc_id     = var.module_examples["vpc_module"].enabled ? module.vpc_example[0].vpc_id : data.aws_vpc.default.id
  subnet_ids = var.module_examples["vpc_module"].enabled ? module.vpc_example[0].private_subnet_ids : data.aws_subnets.default.ids
  
  # Module inputs
  project_name = var.project_name
  environment  = var.environment
  
  # Database configuration
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  storage_encrypted    = true
  
  # Database settings
  database_name = "exampledb"
  username      = "admin"
  password      = random_password.demo_password.result
  
  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Security
  deletion_protection = false  # Set to true for production
  skip_final_snapshot = true   # Set to false for production
  
  # Tagging
  tags = merge(local.common_tags, {
    ModuleType = "database"
    ModuleName = "rds_database_example"
    Version    = var.module_version
  })
  
  # Conditional creation
  count = var.module_examples["storage_module"].enabled ? 1 : 0
}

# =============================================================================
# Module Testing Infrastructure
# =============================================================================

# Module Testing Environment
resource "aws_s3_bucket" "module_testing" {
  count = var.enable_module_testing ? 1 : 0
  
  bucket = "${var.project_name}-module-testing-${random_id.module_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Purpose = "module-testing"
    Type    = "testing-infrastructure"
  })
}

# Module Testing Results Storage
resource "aws_s3_bucket_versioning" "module_testing" {
  count = var.enable_module_testing ? 1 : 0
  
  bucket = aws_s3_bucket.module_testing[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Module Registry Simulation (for private registry testing)
resource "aws_s3_bucket" "module_registry" {
  count = var.module_registry_url == null && var.enable_module_testing ? 1 : 0
  
  bucket = "${var.project_name}-module-registry-${random_id.module_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Purpose = "module-registry"
    Type    = "registry-infrastructure"
  })
}

# =============================================================================
# Multi-Region Testing (Optional)
# =============================================================================

# Secondary region VPC for multi-region testing
module "vpc_secondary_region" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws.secondary_region
  }
  
  # Module inputs
  project_name        = var.project_name
  environment         = "${var.environment}-secondary"
  vpc_cidr           = "10.1.0.0/16"  # Different CIDR for secondary region
  availability_zones = ["${var.secondary_region}a", "${var.secondary_region}b"]
  
  # Module-specific configuration
  enable_nat_gateway     = false  # Cost optimization for testing
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
  
  # Tagging
  tags = merge(local.common_tags, {
    ModuleType = "networking"
    ModuleName = "vpc_secondary_region"
    Version    = var.module_version
    Region     = "secondary"
  })
  
  # Conditional creation
  count = var.enable_multi_region_testing ? 1 : 0
}

# =============================================================================
# Data Sources
# =============================================================================

# Default VPC (fallback)
data "aws_vpc" "default" {
  default = true
}

# Default subnets (fallback)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Current AWS caller identity
data "aws_caller_identity" "current" {}

# Current AWS region
data "aws_region" "current" {}

# Available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

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
}

# =============================================================================
# Time-based resources for demonstration
# =============================================================================

resource "time_static" "deployment_time" {}

resource "time_rotating" "monthly_rotation" {
  rotation_days = 30
}

# =============================================================================
# Configuration Notes:
# 
# 1. Module Development Focus:
#    - Multiple module examples demonstrating different patterns
#    - Module composition and dependency management
#    - Conditional module creation based on configuration
#    - Module testing infrastructure
#
# 2. Module Examples:
#    - VPC module for networking infrastructure
#    - Security group module for security controls
#    - EC2 instance module for compute resources
#    - S3 bucket module for storage solutions
#    - RDS database module for data persistence
#
# 3. Testing Infrastructure:
#    - Module testing environment setup
#    - Registry simulation for private modules
#    - Multi-region testing capabilities
#    - Automated testing support
#
# 4. Best Practices:
#    - Module versioning and tagging
#    - Dependency management between modules
#    - Conditional resource creation
#    - Comprehensive data source usage
#    - Security and compliance considerations
# =============================================================================
