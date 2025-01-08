# Sensitive Variables Lab
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# RDS Instance with sensitive information
resource "aws_db_instance" "example" {
  identifier           = "${var.environment}-db"
  allocated_storage    = 20
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t3.micro"
  db_name             = var.database_name
  username            = var.database_user
  password            = var.database_password
  skip_final_snapshot = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-database"
    }
  )
}

# Secrets Manager for storing sensitive data
resource "aws_secretsmanager_secret" "database" {
  name = "${var.environment}-db-credentials"
  
  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    username = var.database_user
    password = var.database_password
    host     = aws_db_instance.example.endpoint
    dbname   = var.database_name
  })
} 