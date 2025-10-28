# Security Groups and IAM Resources
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# ALB Security Group
# ========================================

resource "aws_security_group" "alb" {
  name        = local.alb_sg_name
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    {
      Name = local.alb_sg_name
    }
  )
}

# Allow HTTP from anywhere
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  description = "Allow HTTP from anywhere"
}

# Allow HTTPS from anywhere
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  description = "Allow HTTPS from anywhere"
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all outbound traffic"
}

# ========================================
# EC2 Security Group
# ========================================

resource "aws_security_group" "ec2" {
  name        = local.ec2_sg_name
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    {
      Name = local.ec2_sg_name
    }
  )
}

# Allow HTTP from ALB
resource "aws_vpc_security_group_ingress_rule" "ec2_http_from_alb" {
  security_group_id = aws_security_group.ec2.id
  
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allow HTTP from ALB"
}

# Allow HTTPS from ALB
resource "aws_vpc_security_group_ingress_rule" "ec2_https_from_alb" {
  security_group_id = aws_security_group.ec2.id
  
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow HTTPS from ALB"
}

# Allow SSH from specific CIDR (optional)
resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  count = var.key_name != "" ? 1 : 0
  
  security_group_id = aws_security_group.ec2.id
  
  cidr_ipv4   = var.vpc_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  description = "Allow SSH from VPC"
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all outbound traffic"
}

# ========================================
# RDS Security Group
# ========================================

resource "aws_security_group" "rds" {
  name        = local.rds_sg_name
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    {
      Name = local.rds_sg_name
    }
  )
}

# Allow PostgreSQL from EC2
resource "aws_vpc_security_group_ingress_rule" "rds_postgres_from_ec2" {
  security_group_id = aws_security_group.rds.id
  
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow PostgreSQL from EC2"
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all outbound traffic"
}

# ========================================
# IAM Role for EC2 Instances
# ========================================

resource "aws_iam_role" "ec2" {
  name = local.ec2_role_name
  
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

# Attach SSM managed policy
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core.arn
}

# Attach CloudWatch Agent policy
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_server_policy.arn
}

# Custom policy for S3 access
resource "aws_iam_role_policy" "ec2_s3_access" {
  name = "${local.name_prefix}-ec2-s3-policy"
  role = aws_iam_role.ec2.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.static_assets.arn,
          "${aws_s3_bucket.static_assets.arn}/*"
        ]
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
  
  tags = local.common_tags
}

# ========================================
# KMS Key for Encryption (Optional)
# ========================================

resource "aws_kms_key" "main" {
  description             = "KMS key for ${local.name_prefix} encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-kms-key"
    }
  )
}

resource "aws_kms_alias" "main" {
  name          = "alias/${local.name_prefix}"
  target_key_id = aws_kms_key.main.key_id
}

# KMS Key Policy
resource "aws_kms_key_policy" "main" {
  key_id = aws_kms_key.main.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      },
      {
        Sid    = "Allow RDS"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

