# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS instance"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-rds-sg"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier        = "${var.environment}-db"
  engine            = "mysql"
  engine_version    = var.db_config.engine_version
  instance_class    = var.db_config.instance_class
  allocated_storage = var.db_config.allocated_storage

  db_name  = var.db_config.db_name
  username = var.db_username
  password = var.db_password

  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-rds"
    }
  )
}

# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.environment}/database/credentials"
  tags = var.common_tags
}

# AWS Secrets Manager Secret Version
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "mysql"
    host     = aws_db_instance.main.endpoint
    port     = 3306
    dbname   = var.db_config.db_name
  })
} 