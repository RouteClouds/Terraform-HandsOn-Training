# Development Environment Configuration

# General
aws_region   = "us-east-1"
project_name = "multi-env-pipeline"
environment  = "dev"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24"
]

enable_nat_gateway = true
single_nat_gateway = true  # Cost savings for dev

# Compute Configuration
instance_type    = "t3.micro"
min_size         = 1
max_size         = 2
desired_capacity = 1

# Database Configuration
db_engine                   = "postgres"
db_engine_version           = "16.3"
db_instance_class           = "db.t3.micro"
db_allocated_storage        = 20
db_name                     = "devdb"
db_username                 = "dbadmin"
db_password                 = "ChangeMe123!"  # Change this!
db_multi_az                 = false
db_backup_retention_period  = 1

# Monitoring
enable_enhanced_monitoring = false
enable_cloudwatch_logs     = true

# Tags
tags = {
  CostCenter = "Development"
  Owner      = "DevTeam"
}

