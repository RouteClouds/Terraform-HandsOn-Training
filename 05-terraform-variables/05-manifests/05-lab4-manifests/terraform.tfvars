aws_region = "us-east-1"
environment = "dev"

db_config = {
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  engine_version    = "8.0.28"
  db_name          = "myappdb"
}

common_tags = {
  Environment = "dev"
  Project     = "terraform-labs"
  ManagedBy   = "terraform"
  Team        = "DevOps"
} 