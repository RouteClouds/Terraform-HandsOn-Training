aws_region = "us-east-1"
project_name = "terraform-resource-lab"
environment = "dev"

# S3 Configuration
enable_versioning = true

# IAM Role Configuration
role_name_prefix = "demo-role"

# Security Group Configuration
allowed_ports = [80, 443]
allowed_cidr_blocks = ["0.0.0.0/0"]

# Additional Tags
tags = {
  Owner       = "DevOps Team"
  Environment = "Development"
  Terraform   = "true"
  Project     = "Resource Lab"
} 