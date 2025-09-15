# AWS Terraform Training - Variables and Outputs
# Lab 5.1: Advanced Variable Management and Output Patterns
# File: main.tf - Infrastructure Implementation with Variable-Driven Configuration

# ============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# ============================================================================

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "random_password" "database_password" {
  count   = var.database_credentials.password == "" ? 1 : 0
  length  = 16
  special = true
}

# ============================================================================
# VPC AND NETWORKING RESOURCES
# ============================================================================

# VPC with variable-driven configuration
resource "aws_vpc" "main" {
  cidr_block           = var.infrastructure_config.networking.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-vpc"
    Type = "networking"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-igw"
    Type = "networking"
  })
}

# Public Subnets (variable-driven count and configuration)
resource "aws_subnet" "public" {
  count = length(var.infrastructure_config.networking.public_subnet_cidrs)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.infrastructure_config.networking.public_subnet_cidrs[count.index]
  availability_zone       = var.infrastructure_config.networking.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-public-subnet-${count.index + 1}"
    Type = "public-subnet"
    AZ   = var.infrastructure_config.networking.availability_zones[count.index]
  })
}

# Private Subnets (variable-driven count and configuration)
resource "aws_subnet" "private" {
  count = length(var.infrastructure_config.networking.private_subnet_cidrs)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.infrastructure_config.networking.private_subnet_cidrs[count.index]
  availability_zone = var.infrastructure_config.networking.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-private-subnet-${count.index + 1}"
    Type = "private-subnet"
    AZ   = var.infrastructure_config.networking.availability_zones[count.index]
  })
}

# NAT Gateways (conditional based on variable)
resource "aws_eip" "nat" {
  count = var.infrastructure_config.networking.enable_nat_gateway ? length(aws_subnet.public) : 0
  
  domain = "vpc"
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-nat-eip-${count.index + 1}"
    Type = "networking"
  })
  
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.infrastructure_config.networking.enable_nat_gateway ? length(aws_subnet.public) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-nat-gateway-${count.index + 1}"
    Type = "networking"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-public-rt"
    Type = "networking"
  })
}

resource "aws_route_table" "private" {
  count = length(aws_subnet.private)
  
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.infrastructure_config.networking.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-private-rt-${count.index + 1}"
    Type = "networking"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ============================================================================
# SECURITY GROUPS
# ============================================================================

# Web tier security group
resource "aws_security_group" "web" {
  name_prefix = "${local.resource_prefix}-web-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for web tier"
  
  # Dynamic ingress rules based on environment
  dynamic "ingress" {
    for_each = local.current_env_config.security_config.enable_waf ? [
      { port = 443, protocol = "tcp", description = "HTTPS" }
    ] : [
      { port = 80, protocol = "tcp", description = "HTTP" },
      { port = 443, protocol = "tcp", description = "HTTPS" }
    ]
    
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value.description
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-web-sg"
    Type = "security"
    Tier = "web"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# Application tier security group
resource "aws_security_group" "app" {
  name_prefix = "${local.resource_prefix}-app-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for application tier"
  
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "Application port from web tier"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-app-sg"
    Type = "security"
    Tier = "application"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# Database tier security group
resource "aws_security_group" "db" {
  name_prefix = "${local.resource_prefix}-db-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for database tier"
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "MySQL port from application tier"
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-db-sg"
    Type = "security"
    Tier = "database"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# IAM ROLES AND POLICIES
# ============================================================================

# EC2 instance role
resource "aws_iam_role" "ec2" {
  name = "${local.resource_prefix}-ec2-role"
  
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
  
  tags = local.common_tags
}

# EC2 instance profile
resource "aws_iam_instance_profile" "ec2" {
  name = "${local.resource_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
  
  tags = local.common_tags
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ============================================================================
# S3 BUCKETS (VARIABLE-DRIVEN)
# ============================================================================

# S3 buckets based on variable configuration
resource "aws_s3_bucket" "main" {
  for_each = var.infrastructure_config.storage.s3_buckets
  
  bucket = "${local.resource_prefix}-${each.key}-${random_id.bucket_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-${each.key}-bucket"
    Type    = "storage"
    Purpose = each.key
  })
}

# S3 bucket versioning (variable-driven)
resource "aws_s3_bucket_versioning" "main" {
  for_each = {
    for k, v in var.infrastructure_config.storage.s3_buckets : k => v
    if v.versioning_enabled
  }
  
  bucket = aws_s3_bucket.main[each.key].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption (variable-driven)
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  for_each = {
    for k, v in var.infrastructure_config.storage.s3_buckets : k => v
    if v.encryption_enabled
  }
  
  bucket = aws_s3_bucket.main[each.key].id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block (variable-driven)
resource "aws_s3_bucket_public_access_block" "main" {
  for_each = {
    for k, v in var.infrastructure_config.storage.s3_buckets : k => v
    if v.public_access_block
  }
  
  bucket = aws_s3_bucket.main[each.key].id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# SECRETS MANAGER (SENSITIVE VARIABLES)
# ============================================================================

# Database credentials secret
resource "aws_secretsmanager_secret" "database_credentials" {
  name        = "${local.resource_prefix}/database/credentials"
  description = "Database master credentials"
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-db-credentials"
    Type = "security"
  })
}

resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    username = var.database_credentials.username
    password = var.database_credentials.password != "" ? var.database_credentials.password : random_password.database_password[0].result
  })
}

# API credentials secret (if provided)
resource "aws_secretsmanager_secret" "api_credentials" {
  count = length(var.api_credentials) > 0 ? 1 : 0
  
  name        = "${local.resource_prefix}/api/credentials"
  description = "External API credentials"
  
  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-api-credentials"
    Type = "security"
  })
}

resource "aws_secretsmanager_secret_version" "api_credentials" {
  count = length(var.api_credentials) > 0 ? 1 : 0
  
  secret_id     = aws_secretsmanager_secret.api_credentials[0].id
  secret_string = jsonencode(var.api_credentials)
}
