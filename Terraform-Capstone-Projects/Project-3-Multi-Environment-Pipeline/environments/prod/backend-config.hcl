# Backend Configuration for Production Environment
# Update the bucket name after creating the state backend

bucket         = "terraform-state-ACCOUNT_ID-us-east-1"
key            = "prod/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks-prod"

