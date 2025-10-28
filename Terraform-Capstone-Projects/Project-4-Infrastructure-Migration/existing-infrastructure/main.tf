# Existing Infrastructure - Simulates Manually Created Resources
# This creates resources that we'll later import into Terraform management

terraform {
  required_version = ">= 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Infrastructure-Migration"
      Environment = "existing"
      ManagedBy   = "manual"
      Purpose     = "import-demo"
    }
  }
}

# ============================================================================
# SCENARIO 1: VPC and Networking Resources
# ============================================================================

resource "aws_vpc" "existing" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "existing-vpc"
  }
}

resource "aws_internet_gateway" "existing" {
  vpc_id = aws_vpc.existing.id
  
  tags = {
    Name = "existing-igw"
  }
}

resource "aws_subnet" "existing_public_1" {
  vpc_id                  = aws_vpc.existing.id
  cidr_block              = "10.100.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "existing-public-subnet-1"
    Type = "public"
  }
}

resource "aws_subnet" "existing_public_2" {
  vpc_id                  = aws_vpc.existing.id
  cidr_block              = "10.100.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "existing-public-subnet-2"
    Type = "public"
  }
}

resource "aws_subnet" "existing_private_1" {
  vpc_id            = aws_vpc.existing.id
  cidr_block        = "10.100.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  
  tags = {
    Name = "existing-private-subnet-1"
    Type = "private"
  }
}

resource "aws_subnet" "existing_private_2" {
  vpc_id            = aws_vpc.existing.id
  cidr_block        = "10.100.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  
  tags = {
    Name = "existing-private-subnet-2"
    Type = "private"
  }
}

resource "aws_route_table" "existing_public" {
  vpc_id = aws_vpc.existing.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.existing.id
  }
  
  tags = {
    Name = "existing-public-rt"
  }
}

resource "aws_route_table_association" "existing_public_1" {
  subnet_id      = aws_subnet.existing_public_1.id
  route_table_id = aws_route_table.existing_public.id
}

resource "aws_route_table_association" "existing_public_2" {
  subnet_id      = aws_subnet.existing_public_2.id
  route_table_id = aws_route_table.existing_public.id
}

# ============================================================================
# SCENARIO 2: EC2 Instances (to be converted to ASG)
# ============================================================================

resource "aws_security_group" "existing_web" {
  name        = "existing-web-sg"
  description = "Security group for existing web servers"
  vpc_id      = aws_vpc.existing.id
  
  tags = {
    Name = "existing-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "existing_web_http" {
  security_group_id = aws_security_group.existing_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  
  tags = {
    Name = "allow-http"
  }
}

resource "aws_vpc_security_group_egress_rule" "existing_web_all" {
  security_group_id = aws_security_group.existing_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  
  tags = {
    Name = "allow-all-outbound"
  }
}

resource "aws_instance" "existing_web_1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.existing_public_1.id
  vpc_security_group_ids = [aws_security_group.existing_web.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Existing Web Server 1</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "existing-web-1"
  }
}

resource "aws_instance" "existing_web_2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.existing_public_2.id
  vpc_security_group_ids = [aws_security_group.existing_web.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Existing Web Server 2</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "existing-web-2"
  }
}

# ============================================================================
# SCENARIO 3: RDS Database
# ============================================================================

resource "aws_db_subnet_group" "existing" {
  name       = "existing-db-subnet-group"
  subnet_ids = [aws_subnet.existing_private_1.id, aws_subnet.existing_private_2.id]
  
  tags = {
    Name = "existing-db-subnet-group"
  }
}

resource "aws_security_group" "existing_db" {
  name        = "existing-db-sg"
  description = "Security group for existing database"
  vpc_id      = aws_vpc.existing.id
  
  tags = {
    Name = "existing-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "existing_db_postgres" {
  security_group_id            = aws_security_group.existing_db.id
  referenced_security_group_id = aws_security_group.existing_web.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  
  tags = {
    Name = "allow-postgres-from-web"
  }
}

resource "aws_db_instance" "existing" {
  identifier             = "existing-database"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = "existingdb"
  username               = "dbadmin"
  password               = "ChangeMe123!"  # In real scenario, use secrets manager
  db_subnet_group_name   = aws_db_subnet_group.existing.name
  vpc_security_group_ids = [aws_security_group.existing_db.id]
  skip_final_snapshot    = true
  
  tags = {
    Name = "existing-database"
  }
}

# ============================================================================
# SCENARIO 4: S3 Buckets
# ============================================================================

resource "aws_s3_bucket" "existing_data" {
  bucket = "existing-data-bucket-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name = "existing-data-bucket"
  }
}

resource "aws_s3_bucket_versioning" "existing_data" {
  bucket = aws_s3_bucket.existing_data.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "existing_logs" {
  bucket = "existing-logs-bucket-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name = "existing-logs-bucket"
  }
}

# ============================================================================
# SCENARIO 5: IAM Roles and Policies
# ============================================================================

resource "aws_iam_role" "existing_app" {
  name = "existing-app-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name = "existing-app-role"
  }
}

resource "aws_iam_policy" "existing_app" {
  name        = "existing-app-policy"
  description = "Policy for existing application"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.existing_data.arn}/*"
      }
    ]
  })
  
  tags = {
    Name = "existing-app-policy"
  }
}

resource "aws_iam_role_policy_attachment" "existing_app" {
  role       = aws_iam_role.existing_app.name
  policy_arn = aws_iam_policy.existing_app.arn
}

# ============================================================================
# Data Sources
# ============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}

