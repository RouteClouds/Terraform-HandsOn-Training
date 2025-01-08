# General Configuration
aws_region    = "us-east-1"
project_name  = "terraform-dependencies-lab"
environment   = "dev"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
availability_zone  = "us-east-1a"

# EC2 Configuration
ami_id        = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
instance_type = "t2.micro"

# Additional Tags
tags = {
  Owner       = "DevOps Team"
  Environment = "Development"
  Terraform   = "true"
  Project     = "Dependencies Lab"
  ManagedBy   = "Terraform"
} 