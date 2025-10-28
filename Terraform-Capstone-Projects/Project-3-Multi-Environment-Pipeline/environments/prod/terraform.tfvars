# Production Environment Configuration

# General
aws_region   = "us-east-1"
project_name = "multi-env-pipeline"
environment  = "prod"

# VPC Configuration
vpc_cidr           = "10.2.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs = [
  "10.2.1.0/24",
  "10.2.2.0/24",
  "10.2.3.0/24"
]

private_subnet_cidrs = [
  "10.2.11.0/24",
  "10.2.12.0/24",
  "10.2.13.0/24"
]

enable_nat_gateway = true
single_nat_gateway = false  # Full HA for production

# Compute Configuration
instance_type    = "t3.medium"
min_size         = 2
max_size         = 6
desired_capacity = 3

# Database Configuration
db_engine                   = "postgres"
db_engine_version           = "16.3"
db_instance_class           = "db.t3.medium"
db_allocated_storage        = 100
db_name                     = "proddb"
db_username                 = "dbadmin"
db_password                 = "ChangeMe123!"  # Change this!
db_multi_az                 = true
db_backup_retention_period  = 30

# Monitoring
enable_enhanced_monitoring = true
enable_cloudwatch_logs     = true

# Tags
tags = {
  CostCenter = "Production"
  Owner      = "Platform"
  Compliance = "Required"
}

