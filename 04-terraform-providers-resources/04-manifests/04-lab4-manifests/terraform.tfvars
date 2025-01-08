# General Configuration
aws_region   = "us-east-1"
project_name = "terraform-meta-args-lab"

# Count Configuration
instance_count = 3

# For_Each Map Configuration
instance_config = {
  "dev" = {
    instance_type = "t2.micro"
    environment   = "development"
  },
  "staging" = {
    instance_type = "t2.small"
    environment   = "staging"
  },
  "prod" = {
    instance_type = "t2.medium"
    environment   = "production"
  }
}

# For_Each Set Configuration
bucket_names = [
  "logs",
  "backups",
  "data"
]

# Instance Configuration
ami_id        = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
instance_type = "t2.micro"

# Additional Tags
tags = {
  Owner       = "DevOps Team"
  Environment = "Development"
  Terraform   = "true"
  Project     = "Meta-Arguments Lab"
  ManagedBy   = "Terraform"
} 