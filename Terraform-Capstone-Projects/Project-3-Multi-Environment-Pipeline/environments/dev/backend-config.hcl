# Backend Configuration for Development Environment
# Update the bucket name after creating the state backend

bucket         = "terraform-state-ACCOUNT_ID-us-east-1"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks-dev"

