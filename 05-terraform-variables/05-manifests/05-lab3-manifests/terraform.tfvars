# Default Development Environment
aws_region = "us-east-1"
environment = "dev"

vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

common_tags = {
  Environment = "dev"
  Project     = "terraform-labs"
  ManagedBy   = "terraform"
  Team        = "DevOps"
} 