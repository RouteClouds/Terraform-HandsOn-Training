# Region Configuration
primary_region   = "us-east-1"
secondary_region = "us-west-2"

# Project Configuration
project_name = "terraform-multi-provider-lab"

# Network Configuration
primary_vpc_cidr   = "10.0.0.0/16"
secondary_vpc_cidr = "172.16.0.0/16"

# Instance Configuration
primary_ami_id   = "ami-0c55b159cbfafe1f0"   # Amazon Linux 2 AMI in us-east-1
secondary_ami_id = "ami-0cb4e786f15603b0d"   # Amazon Linux 2 AMI in us-west-2
instance_type    = "t2.micro"

# Tags
tags = {
  Owner       = "DevOps Team"
  Environment = "Development"
  Terraform   = "true"
  Project     = "Multi-Provider Lab"
  ManagedBy   = "Terraform"
} 