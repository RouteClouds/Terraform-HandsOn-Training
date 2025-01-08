# S3 Backend Configuration
terraform {
  backend "s3" {
    bucket         = "terraform-state-${local.account_id}"
    key            = "terraform-setup/lab3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
} 