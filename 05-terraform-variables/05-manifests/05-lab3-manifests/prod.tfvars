# Production Environment
environment = "prod"

vpc_cidr = "172.16.0.0/16"
public_subnet_cidrs = [
  "172.16.1.0/24",
  "172.16.2.0/24",
  "172.16.3.0/24"
]
availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

common_tags = {
  Environment = "production"
  Project     = "terraform-labs"
  ManagedBy   = "terraform"
  Team        = "Production"
  CostCenter  = "PROD-123"
} 