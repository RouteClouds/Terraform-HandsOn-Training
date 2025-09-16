# Main Infrastructure Configuration for Infrastructure as Code Lab 1.1
# Topic 1: Infrastructure as Code Concepts & AWS Integration
#
# This file contains the core infrastructure resources implementing a
# three-tier web application architecture with security best practices,
# cost optimization, and enterprise-grade standards.
#
# Architecture Components:
# 1. Networking Layer (VPC, Subnets, Gateways)
# 2. Security Layer (Security Groups, IAM Roles)
# 3. Compute Layer (EC2, Auto Scaling, Load Balancer)
# 4. Storage Layer (S3, EBS)
# 5. Database Layer (RDS)
# 6. Monitoring Layer (CloudWatch, CloudTrail)
#
# Last Updated: January 2025

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get current AWS account information
data "aws_caller_identity" "current" {}

# Get current AWS region information
data "aws_region" "current" {}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# =============================================================================
# LOCAL VALUES
# =============================================================================

locals {
  # Common naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Account and region information
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  
  # Availability zones (use first 2 from available list)
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  
  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedBy   = var.created_by
    CostCenter  = var.cost_center
    Owner       = var.owner_email
  }
  
  # Security tags
  security_tags = {
    DataClass       = var.data_classification
    BackupRequired  = var.backup_required
    MonitoringLevel = var.monitoring_level
    ComplianceScope = var.compliance_scope
  }
  
  # Operational tags
  operational_tags = {
    AutoShutdown      = var.auto_shutdown_enabled
    LifecycleStage    = var.lifecycle_stage
    MaintenanceWindow = var.maintenance_window
    SupportLevel      = var.support_level
  }
}

# =============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# =============================================================================

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

# =============================================================================
# NETWORKING LAYER
# =============================================================================

# VPC - Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
    Type = "networking"
    Tier = "infrastructure"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
    Type = "networking"
    Tier = "infrastructure"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(local.azs)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    Type = "public"
    Tier = "web"
    AZ   = local.azs[count.index]
  })
}

# Private Subnets for Application Tier
resource "aws_subnet" "private" {
  count = length(local.azs)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = local.azs[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
    Type = "private"
    Tier = "application"
    AZ   = local.azs[count.index]
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(local.azs)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  availability_zone = local.azs[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-subnet-${count.index + 1}"
    Type = "private"
    Tier = "database"
    AZ   = local.azs[count.index]
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.azs)) : 0
  
  domain = "vpc"
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    Type = "networking"
    Tier = "infrastructure"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.azs)) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-gateway-${count.index + 1}"
    Type = "networking"
    Tier = "infrastructure"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# Route Tables - Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
    Type = "networking"
    Tier = "infrastructure"
  })
}

# Route Tables - Private
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? length(local.azs) : 1
  
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
    }
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
    Type = "networking"
    Tier = "infrastructure"
  })
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

# Route Table Associations - Database
resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)
  
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

# =============================================================================
# SECURITY LAYER
# =============================================================================

# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Application Load Balancer"
  
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(local.common_tags, local.security_tags, {
    Name = "${local.name_prefix}-alb-sg"
    Type = "security"
    Tier = "web"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Web Servers
resource "aws_security_group" "web" {
  name_prefix = "${local.name_prefix}-web-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for web servers"
  
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(local.common_tags, local.security_tags, {
    Name = "${local.name_prefix}-web-sg"
    Type = "security"
    Tier = "application"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Database
resource "aws_security_group" "database" {
  name_prefix = "${local.name_prefix}-db-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for database servers"
  
  ingress {
    description     = "MySQL from web servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  
  tags = merge(local.common_tags, local.security_tags, {
    Name = "${local.name_prefix}-database-sg"
    Type = "security"
    Tier = "database"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# IAM ROLES AND POLICIES
# =============================================================================

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-ec2-role"
  
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
  
  tags = merge(local.common_tags, local.security_tags, {
    Name = "${local.name_prefix}-ec2-role"
    Type = "security"
    Tier = "application"
  })
}

# IAM Policy for EC2 instances
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${local.name_prefix}-ec2-policy"
  role = aws_iam_role.ec2_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.app_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.app_bucket.arn
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
  
  tags = merge(local.common_tags, local.security_tags, {
    Name = "${local.name_prefix}-ec2-profile"
    Type = "security"
    Tier = "application"
  })
}

# =============================================================================
# STORAGE LAYER
# =============================================================================

# S3 Bucket for application data and logs
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${local.name_prefix}-app-data-${random_id.bucket_suffix.hex}"
  
  tags = merge(local.common_tags, local.security_tags, {
    Name        = "${local.name_prefix}-app-bucket"
    Type        = "storage"
    Tier        = "application"
    Purpose     = "application-data"
    Environment = var.environment
  })
}

# S3 Bucket Encryption
resource "aws_s3_bucket_encryption" "app_bucket_encryption" {
  bucket = aws_s3_bucket.app_bucket.id
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.encryption_at_rest ? "AES256" : "AES256"
      }
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = aws_s3_bucket.app_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "app_bucket_lifecycle" {
  bucket = aws_s3_bucket.app_bucket.id
  
  rule {
    id     = "log_lifecycle"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# =============================================================================
# COMPUTE LAYER
# =============================================================================

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
    Type = "load-balancer"
    Tier = "web"
  })
}

# Target Group for Web Servers
resource "aws_lb_target_group" "web" {
  name     = "${local.name_prefix}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-target-group"
    Type = "load-balancer"
    Tier = "web"
  })
}

# Load Balancer Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-listener"
    Type = "load-balancer"
    Tier = "web"
  })
}

# Launch Template for Web Servers
resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  key_name = var.key_pair_name

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    bucket_name = aws_s3_bucket.app_bucket.bucket
    region      = local.region
    project     = var.project_name
    environment = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, local.operational_tags, {
      Name = "${local.name_prefix}-web-server"
      Type = "compute"
      Tier = "application"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-launch-template"
    Type = "compute"
    Tier = "application"
  })
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "${local.name_prefix}-web-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Auto Scaling Policies
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-web-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Type"
    value               = "auto-scaling"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# DATABASE LAYER
# =============================================================================

# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
    Type = "database"
    Tier = "database"
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-database"

  # Engine configuration
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Storage configuration
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2
  storage_type          = "gp2"
  storage_encrypted     = var.encryption_at_rest

  # Database configuration
  db_name  = "appdb"
  username = "admin"
  password = random_password.db_password.result

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  # Backup configuration
  backup_retention_period = var.db_backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = var.maintenance_window

  # High availability
  multi_az = var.db_multi_az

  # Monitoring
  performance_insights_enabled = var.enable_performance_insights
  monitoring_interval         = var.enable_detailed_monitoring ? 60 : 0

  # Deletion protection
  deletion_protection = false
  skip_final_snapshot = true

  tags = merge(local.common_tags, local.security_tags, {
    Name = "${local.name_prefix}-database"
    Type = "database"
    Tier = "database"
  })
}

# =============================================================================
# MONITORING AND LOGGING
# =============================================================================

# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${local.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-logs"
    Type = "monitoring"
    Tier = "infrastructure"
  })
}

# CloudWatch Log Group for Load Balancer Logs
resource "aws_cloudwatch_log_group" "alb_logs" {
  name              = "/aws/elasticloadbalancing/${local.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-logs"
    Type = "monitoring"
    Tier = "infrastructure"
  })
}
