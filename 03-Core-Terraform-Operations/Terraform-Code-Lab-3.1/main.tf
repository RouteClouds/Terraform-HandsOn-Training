# AWS Terraform Training - Core Terraform Operations
# Lab 3.1: Core Workflow and Resource Lifecycle Management
# File: main.tf - Main Infrastructure Resources

# ============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# ============================================================================

resource "random_id" "suffix" {
  byte_length = 4
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# ============================================================================
# DATA SOURCES
# ============================================================================

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
}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# ============================================================================
# VPC AND NETWORKING RESOURCES
# ============================================================================

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.resource_prefix}-vpc-${random_id.suffix.hex}"
    Type = "vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.resource_prefix}-igw-${random_id.suffix.hex}"
    Type = "internet-gateway"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.resource_prefix}-public-subnet-${count.index + 1}-${random_id.suffix.hex}"
    Type = "public-subnet"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.resource_prefix}-private-subnet-${count.index + 1}-${random_id.suffix.hex}"
    Type = "private-subnet"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${var.resource_prefix}-public-rt-${random_id.suffix.hex}"
    Type = "public-route-table"
  }
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.resource_prefix}-private-rt-${random_id.suffix.hex}"
    Type = "private-route-table"
  }
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ============================================================================
# SECURITY GROUPS
# ============================================================================

# Web Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.resource_prefix}-web-sg-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for web servers"
  
  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }
  
  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }
  
  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }
  
  # All outbound traffic
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.resource_prefix}-web-sg-${random_id.suffix.hex}"
    Type = "security-group"
    Role = "web"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  count = var.enable_load_balancer ? 1 : 0
  
  name_prefix = "${var.resource_prefix}-alb-sg-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Application Load Balancer"
  
  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # All outbound traffic
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.resource_prefix}-alb-sg-${random_id.suffix.hex}"
    Type = "security-group"
    Role = "load-balancer"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# EC2 INSTANCES
# ============================================================================

# EC2 Instances with count meta-argument
resource "aws_instance" "web" {
  count = var.instance_count
  
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null
  
  monitoring = var.enable_detailed_monitoring
  
  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    instance_number = count.index + 1
    student_name    = var.student_name
    project_name    = var.project_name
    environment     = var.environment
  }))
  
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = var.encryption_enabled
    delete_on_termination = true
    
    tags = {
      Name = "${var.resource_prefix}-web-${count.index + 1}-root-${random_id.suffix.hex}"
      Type = "ebs-volume"
    }
  }
  
  tags = {
    Name = "${var.resource_prefix}-web-${count.index + 1}-${random_id.suffix.hex}"
    Type = "ec2-instance"
    Role = "web-server"
    AZ   = aws_subnet.public[count.index % length(aws_subnet.public)].availability_zone
  }
  
  lifecycle {
    create_before_destroy = true
    
    ignore_changes = [
      ami,  # Ignore AMI changes to prevent unnecessary replacements
      user_data  # Ignore user_data changes after initial creation
    ]
  }
  
  # Explicit dependency on internet gateway for proper ordering
  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# APPLICATION LOAD BALANCER
# ============================================================================

# Application Load Balancer
resource "aws_lb" "main" {
  count = var.enable_load_balancer ? 1 : 0
  
  name               = "${var.resource_prefix}-alb-${random_id.suffix.hex}"
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = aws_subnet.public[*].id
  
  enable_deletion_protection = false
  
  tags = {
    Name = "${var.resource_prefix}-alb-${random_id.suffix.hex}"
    Type = "application-load-balancer"
  }
  
  # Explicit dependency on internet gateway
  depends_on = [aws_internet_gateway.main]
}

# ALB Target Group
resource "aws_lb_target_group" "web" {
  count = var.enable_load_balancer ? 1 : 0
  
  name     = "${var.resource_prefix}-web-tg-${random_id.suffix.hex}"
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
  
  tags = {
    Name = "${var.resource_prefix}-web-tg-${random_id.suffix.hex}"
    Type = "target-group"
  }
}

# ALB Listener
resource "aws_lb_listener" "web" {
  count = var.enable_load_balancer ? 1 : 0
  
  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web[0].arn
  }
  
  tags = {
    Name = "${var.resource_prefix}-web-listener-${random_id.suffix.hex}"
    Type = "lb-listener"
  }
}

# ALB Target Group Attachments
resource "aws_lb_target_group_attachment" "web" {
  count = var.enable_load_balancer ? var.instance_count : 0
  
  target_group_arn = aws_lb_target_group.web[0].arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# ============================================================================
# S3 BUCKET FOR APPLICATION DATA
# ============================================================================

# S3 Bucket
resource "aws_s3_bucket" "app_data" {
  count = var.create_s3_bucket ? 1 : 0
  
  bucket = "${var.resource_prefix}-app-data-${var.student_name}-${random_string.bucket_suffix.result}"
  
  tags = {
    Name = "${var.resource_prefix}-app-data-${random_id.suffix.hex}"
    Type = "s3-bucket"
    Role = "application-data"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "app_data" {
  count = var.create_s3_bucket && var.s3_bucket_versioning ? 1 : 0
  
  bucket = aws_s3_bucket.app_data[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  count = var.create_s3_bucket && var.encryption_enabled ? 1 : 0
  
  bucket = aws_s3_bucket.app_data[0].id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "app_data" {
  count = var.create_s3_bucket ? 1 : 0
  
  bucket = aws_s3_bucket.app_data[0].id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# CLOUDWATCH RESOURCES
# ============================================================================

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app_logs" {
  count = var.monitoring_enabled ? 1 : 0
  
  name              = "/aws/ec2/${var.resource_prefix}-${random_id.suffix.hex}"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name = "${var.resource_prefix}-logs-${random_id.suffix.hex}"
    Type = "cloudwatch-log-group"
  }
}

# VPC Flow Logs (optional)
resource "aws_flow_log" "vpc" {
  count = var.enable_vpc_flow_logs && var.monitoring_enabled ? 1 : 0
  
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  
  tags = {
    Name = "${var.resource_prefix}-vpc-flow-logs-${random_id.suffix.hex}"
    Type = "vpc-flow-log"
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs && var.monitoring_enabled ? 1 : 0
  
  name              = "/aws/vpc/flowlogs-${random_id.suffix.hex}"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name = "${var.resource_prefix}-vpc-flow-logs-${random_id.suffix.hex}"
    Type = "cloudwatch-log-group"
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log" {
  count = var.enable_vpc_flow_logs && var.monitoring_enabled ? 1 : 0
  
  name = "${var.resource_prefix}-flow-log-role-${random_id.suffix.hex}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name = "${var.resource_prefix}-flow-log-role-${random_id.suffix.hex}"
    Type = "iam-role"
  }
}

# IAM Role Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_vpc_flow_logs && var.monitoring_enabled ? 1 : 0
  
  name = "${var.resource_prefix}-flow-log-policy"
  role = aws_iam_role.flow_log[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
