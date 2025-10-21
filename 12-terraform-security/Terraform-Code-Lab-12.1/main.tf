# Topic 12 Lab: Advanced Security & Compliance
# main.tf - Secure Infrastructure Configuration

# VPC with security best practices
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.compliance_tags,
    {
      Name = "secure-vpc"
    }
  )
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = merge(
    var.compliance_tags,
    {
      Name = "public-subnet"
      Type = "Public"
    }
  )
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = merge(
    var.compliance_tags,
    {
      Name = "private-subnet"
      Type = "Private"
    }
  )
}

# Security Group for ALB (Public)
resource "aws_security_group" "alb" {
  name        = "secure-alb-sg"
  description = "Security group for ALB with least privilege"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from internet (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(
    var.compliance_tags,
    {
      Name = "alb-security-group"
    }
  )
}

# Security Group for Application (Private)
resource "aws_security_group" "app" {
  name        = "secure-app-sg"
  description = "Security group for application with least privilege"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.compliance_tags,
    {
      Name = "app-security-group"
    }
  )
}

# Security Group for Database (Private)
resource "aws_security_group" "database" {
  name        = "secure-db-sg"
  description = "Security group for database with least privilege"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from app only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "No outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(
    var.compliance_tags,
    {
      Name = "database-security-group"
    }
  )
}

# KMS Key for encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.compliance_tags,
    {
      Name = "encryption-key"
    }
  )
}

resource "aws_kms_alias" "main" {
  name          = "alias/terraform-security"
  target_key_id = aws_kms_key.main.key_id
}

