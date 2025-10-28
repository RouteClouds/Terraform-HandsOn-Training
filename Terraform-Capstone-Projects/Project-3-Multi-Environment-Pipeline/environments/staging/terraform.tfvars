# Staging Environment Configuration

# General
aws_region   = "us-east-1"
project_name = "multi-env-pipeline"
environment  = "staging"

# VPC Configuration
vpc_cidr           = "10.1.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs = [
  "10.1.1.0/24",
  "10.1.2.0/24",
  "10.1.3.0/24"
]

private_subnet_cidrs = [
  "10.1.11.0/24",
  "10.1.12.0/24",
  "10.1.13.0/24"
]

enable_nat_gateway = true
single_nat_gateway = false  # HA for staging

# Compute Configuration
instance_type    = "t3.small"
min_size         = 2
max_size         = 4
desired_capacity = 2

# Database Configuration
db_engine                   = "postgres"
db_engine_version           = "16.3"
db_instance_class           = "db.t3.small"
db_allocated_storage        = 50
db_name                     = "stagingdb"
db_username                 = "dbadmin"
db_password                 = "ChangeMe123!"  # Change this!
db_multi_az                 = true
db_backup_retention_period  = 7

# Monitoring
enable_enhanced_monitoring = false
enable_cloudwatch_logs     = true

# Tags
tags = {
  CostCenter = "Staging"
  Owner      = "DevOps"
}

