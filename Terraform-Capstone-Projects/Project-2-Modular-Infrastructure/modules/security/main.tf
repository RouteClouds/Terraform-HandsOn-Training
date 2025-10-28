# Security Module - Main Configuration

# Local values for common tags
locals {
  common_tags = merge(
    var.tags,
    {
      Module = "security"
    }
  )
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for current region
data "aws_region" "current" {}

# ============================================================================
# SECURITY GROUPS
# ============================================================================

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id
  
  tags = merge(
    local.common_tags,
    {
      Name = "alb-sg"
      Tier = "public"
    }
  )
}

# ALB Security Group Rules - Ingress
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  
  description = "Allow HTTP from allowed CIDR blocks"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_cidr_blocks[0]
  
  tags = merge(
    local.common_tags,
    {
      Name = "alb-http-ingress"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  
  description = "Allow HTTPS from allowed CIDR blocks"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_cidr_blocks[0]
  
  tags = merge(
    local.common_tags,
    {
      Name = "alb-https-ingress"
    }
  )
}

# ALB Security Group Rules - Egress
resource "aws_vpc_security_group_egress_rule" "alb_to_ec2" {
  security_group_id = aws_security_group.alb.id
  
  description                  = "Allow traffic to EC2 instances"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "alb-to-ec2-egress"
    }
  )
}

# EC2 Security Group
resource "aws_security_group" "ec2" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id
  
  tags = merge(
    local.common_tags,
    {
      Name = "ec2-sg"
      Tier = "private"
    }
  )
}

# EC2 Security Group Rules - Ingress
resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  security_group_id = aws_security_group.ec2.id
  
  description                  = "Allow HTTP from ALB"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "ec2-from-alb-ingress"
    }
  )
}

# EC2 Security Group Rules - Egress
resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  
  description = "Allow all outbound traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
  
  tags = merge(
    local.common_tags,
    {
      Name = "ec2-all-egress"
    }
  )
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id
  
  tags = merge(
    local.common_tags,
    {
      Name = "rds-sg"
      Tier = "database"
    }
  )
}

# RDS Security Group Rules - Ingress
resource "aws_vpc_security_group_ingress_rule" "rds_from_ec2" {
  security_group_id = aws_security_group.rds.id
  
  description                  = "Allow PostgreSQL from EC2"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "rds-from-ec2-ingress"
    }
  )
}

# ============================================================================
# IAM ROLES AND POLICIES
# ============================================================================

# EC2 IAM Role
resource "aws_iam_role" "ec2" {
  name = "ec2-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = merge(
    local.common_tags,
    {
      Name = "ec2-instance-role"
    }
  )
}

# EC2 IAM Policy for S3 Access
resource "aws_iam_role_policy" "ec2_s3" {
  name = "ec2-s3-access-policy"
  role = aws_iam_role.ec2.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::*"
        ]
      }
    ]
  })
}

# EC2 IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy" "ec2_cloudwatch" {
  name = "ec2-cloudwatch-logs-policy"
  role = aws_iam_role.ec2.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
      }
    ]
  })
}

# EC2 IAM Policy for Systems Manager (optional)
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  count = var.enable_ec2_ssm ? 1 : 0
  
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 IAM Policy for KMS (if encryption enabled)
resource "aws_iam_role_policy" "ec2_kms" {
  count = var.enable_kms_encryption ? 1 : 0
  
  name = "ec2-kms-access-policy"
  role = aws_iam_role.ec2.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = var.enable_kms_encryption ? aws_kms_key.main[0].arn : "*"
      }
    ]
  })
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2.name
  
  tags = merge(
    local.common_tags,
    {
      Name = "ec2-instance-profile"
    }
  )
}

# ============================================================================
# KMS ENCRYPTION
# ============================================================================

# KMS Key for Encryption
resource "aws_kms_key" "main" {
  count = var.enable_kms_encryption ? 1 : 0
  
  description             = "KMS key for infrastructure encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true
  
  tags = merge(
    local.common_tags,
    {
      Name = "infrastructure-kms-key"
    }
  )
}

# KMS Key Alias
resource "aws_kms_alias" "main" {
  count = var.enable_kms_encryption ? 1 : 0
  
  name          = "alias/infrastructure-key"
  target_key_id = aws_kms_key.main[0].key_id
}

