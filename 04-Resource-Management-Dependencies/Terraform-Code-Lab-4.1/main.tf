# AWS Terraform Training - Resource Management & Dependencies
# Lab 4.1: Advanced Resource Dependencies and Meta-Arguments
# File: main.tf - Complex Multi-Tier Infrastructure with Advanced Dependencies

# ============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING AND DEPENDENCY TESTING
# ============================================================================

resource "random_id" "suffix" {
  byte_length = 4
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_password" "database_password" {
  length  = 16
  special = true
}

# Time resource for dependency timing
resource "time_static" "deployment_time" {}

# ============================================================================
# DATA SOURCES FOR DEPENDENCY RESOLUTION
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

# Get available availability zones for dependency mapping
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current AWS caller identity for dependency tracking
data "aws_caller_identity" "current" {}

# Get current AWS region for cross-region dependency patterns
data "aws_region" "current" {}

# ============================================================================
# VPC AND FOUNDATION RESOURCES (DEPENDENCY TIER 1)
# ============================================================================

# VPC - Foundation resource for all dependencies
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_configuration.cidr_block
  enable_dns_hostnames = var.vpc_configuration.enable_dns_hostnames
  enable_dns_support   = var.vpc_configuration.enable_dns_support
  
  tags = {
    Name           = "${var.resource_prefix}-vpc-${random_id.suffix.hex}"
    DependencyTier = "foundation"
    ResourceType   = "vpc"
  }
}

# Internet Gateway - Implicit dependency on VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Creates implicit dependency
  
  tags = {
    Name           = "${var.resource_prefix}-igw-${random_id.suffix.hex}"
    DependencyTier = "foundation"
    ResourceType   = "internet-gateway"
  }
}

# ============================================================================
# SUBNET RESOURCES WITH COUNT META-ARGUMENT (DEPENDENCY TIER 2)
# ============================================================================

# Public Subnets using count meta-argument
resource "aws_subnet" "public" {
  count = length(var.subnet_configurations.public.cidr_blocks)
  
  vpc_id                  = aws_vpc.main.id  # Implicit dependency on VPC
  cidr_block              = var.subnet_configurations.public.cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = var.subnet_configurations.public.map_public_ip_on_launch
  
  tags = {
    Name           = "${var.resource_prefix}-public-subnet-${count.index + 1}-${random_id.suffix.hex}"
    DependencyTier = "network"
    ResourceType   = "subnet"
    SubnetType     = "public"
    AZ             = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  }
}

# Private Subnets using count meta-argument
resource "aws_subnet" "private" {
  count = length(var.subnet_configurations.private.cidr_blocks)
  
  vpc_id            = aws_vpc.main.id  # Implicit dependency on VPC
  cidr_block        = var.subnet_configurations.private.cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  
  tags = {
    Name           = "${var.resource_prefix}-private-subnet-${count.index + 1}-${random_id.suffix.hex}"
    DependencyTier = "network"
    ResourceType   = "subnet"
    SubnetType     = "private"
    AZ             = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  }
}

# Database Subnets using count meta-argument
resource "aws_subnet" "database" {
  count = length(var.subnet_configurations.database.cidr_blocks)
  
  vpc_id            = aws_vpc.main.id  # Implicit dependency on VPC
  cidr_block        = var.subnet_configurations.database.cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  
  tags = {
    Name           = "${var.resource_prefix}-database-subnet-${count.index + 1}-${random_id.suffix.hex}"
    DependencyTier = "data"
    ResourceType   = "subnet"
    SubnetType     = "database"
    AZ             = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  }
}

# ============================================================================
# ROUTING INFRASTRUCTURE (DEPENDENCY TIER 3)
# ============================================================================

# Public Route Table - Implicit dependencies on VPC and IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  # Implicit dependency on VPC
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id  # Implicit dependency on IGW
  }
  
  tags = {
    Name           = "${var.resource_prefix}-public-rt-${random_id.suffix.hex}"
    DependencyTier = "routing"
    ResourceType   = "route-table"
    RouteType      = "public"
  }
}

# Public Route Table Associations - Implicit dependencies on subnets and route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id      # Implicit dependency on subnet
  route_table_id = aws_route_table.public.id              # Implicit dependency on route table
}

# Private Route Tables (one per AZ) - Implicit dependency on VPC
resource "aws_route_table" "private" {
  count = length(aws_subnet.private)
  
  vpc_id = aws_vpc.main.id  # Implicit dependency on VPC
  
  tags = {
    Name           = "${var.resource_prefix}-private-rt-${count.index + 1}-${random_id.suffix.hex}"
    DependencyTier = "routing"
    ResourceType   = "route-table"
    RouteType      = "private"
    AZ             = aws_subnet.private[count.index].availability_zone
  }
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# NAT Gateway with conditional creation and complex dependencies
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(aws_subnet.public) : 0
  
  domain = "vpc"
  
  # Explicit dependency on IGW to ensure proper setup order
  depends_on = [aws_internet_gateway.main]
  
  tags = {
    Name           = "${var.resource_prefix}-nat-eip-${count.index + 1}-${random_id.suffix.hex}"
    DependencyTier = "routing"
    ResourceType   = "elastic-ip"
  }
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(aws_subnet.public) : 0
  
  allocation_id = aws_eip.nat[count.index].id           # Implicit dependency on EIP
  subnet_id     = aws_subnet.public[count.index].id    # Implicit dependency on public subnet
  
  tags = {
    Name           = "${var.resource_prefix}-nat-gw-${count.index + 1}-${random_id.suffix.hex}"
    DependencyTier = "routing"
    ResourceType   = "nat-gateway"
    AZ             = aws_subnet.public[count.index].availability_zone
  }
  
  # Explicit dependency on IGW
  depends_on = [aws_internet_gateway.main]
}

# Add NAT Gateway routes to private route tables
resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? length(aws_route_table.private) : 0
  
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# ============================================================================
# SECURITY GROUPS WITH FOR_EACH META-ARGUMENT (DEPENDENCY TIER 4)
# ============================================================================

# Security Groups for each application tier using for_each
resource "aws_security_group" "app_tiers" {
  for_each = var.application_tiers
  
  name_prefix = "${var.resource_prefix}-${each.key}-sg-"
  vpc_id      = aws_vpc.main.id  # Implicit dependency on VPC
  description = "Security group for ${each.key} tier"
  
  # Dynamic ingress rules based on tier configuration
  dynamic "ingress" {
    for_each = each.key == "web" ? [each.value.target_group_port, 443] : [each.value.target_group_port]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = each.key == "web" ? var.security_configuration.allowed_http_cidrs : [var.vpc_configuration.cidr_block]
    }
  }
  
  # SSH access from VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.security_configuration.allowed_ssh_cidrs
  }
  
  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name           = "${var.resource_prefix}-${each.key}-sg-${random_id.suffix.hex}"
    DependencyTier = "security"
    ResourceType   = "security-group"
    ApplicationTier = each.key
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Database Security Group with explicit dependencies
resource "aws_security_group" "database" {
  name_prefix = "${var.resource_prefix}-database-sg-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for database tier"
  
  # MySQL/Aurora access from application tiers
  dynamic "ingress" {
    for_each = var.application_tiers
    content {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [aws_security_group.app_tiers[ingress.key].id]  # Implicit dependency on app SGs
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name           = "${var.resource_prefix}-database-sg-${random_id.suffix.hex}"
    DependencyTier = "security"
    ResourceType   = "security-group"
    ApplicationTier = "database"
  }
  
  lifecycle {
    create_before_destroy = true
  }
  
  # Explicit dependency on application security groups
  depends_on = [aws_security_group.app_tiers]
}

# Load Balancer Security Group
resource "aws_security_group" "alb" {
  count = var.load_balancer_configuration.enable_application_lb ? 1 : 0
  
  name_prefix = "${var.resource_prefix}-alb-sg-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Application Load Balancer"
  
  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.security_configuration.allowed_http_cidrs
  }
  
  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.security_configuration.allowed_https_cidrs
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name           = "${var.resource_prefix}-alb-sg-${random_id.suffix.hex}"
    DependencyTier = "security"
    ResourceType   = "security-group"
    ApplicationTier = "load-balancer"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# DATABASE TIER WITH LIFECYCLE MANAGEMENT (DEPENDENCY TIER 5)
# ============================================================================

# Database Subnet Group - Implicit dependency on database subnets
resource "aws_db_subnet_group" "main" {
  count = var.enable_rds ? 1 : 0

  name       = "${var.resource_prefix}-db-subnet-group-${random_id.suffix.hex}"
  subnet_ids = aws_subnet.database[*].id  # Implicit dependency on database subnets

  tags = {
    Name           = "${var.resource_prefix}-db-subnet-group-${random_id.suffix.hex}"
    DependencyTier = "data"
    ResourceType   = "db-subnet-group"
  }
}

# RDS Instance with complex dependencies and lifecycle management
resource "aws_db_instance" "main" {
  count = var.enable_rds ? 1 : 0

  identifier = "${var.resource_prefix}-database-${random_id.suffix.hex}"

  # Engine configuration
  engine         = var.database_configuration.engine
  engine_version = var.database_configuration.engine_version
  instance_class = var.database_configuration.instance_class

  # Storage configuration
  allocated_storage     = var.database_configuration.allocated_storage
  max_allocated_storage = var.database_configuration.max_allocated_storage
  storage_type          = var.database_configuration.storage_type
  storage_encrypted     = var.database_configuration.storage_encrypted

  # Database configuration
  db_name  = "labdb"
  username = var.database_configuration.username
  password = var.database_configuration.password

  # Network configuration with implicit dependencies
  db_subnet_group_name   = aws_db_subnet_group.main[0].name      # Implicit dependency
  vpc_security_group_ids = [aws_security_group.database.id]     # Implicit dependency

  # Backup configuration
  backup_retention_period = var.database_configuration.backup_retention_period
  backup_window          = var.database_configuration.backup_window
  maintenance_window     = var.database_configuration.maintenance_window

  # High availability
  multi_az = var.database_configuration.multi_az

  # Deletion protection
  deletion_protection = var.database_configuration.deletion_protection
  skip_final_snapshot = !var.backup_required

  # Performance insights
  performance_insights_enabled = var.enable_detailed_monitoring

  # Explicit dependencies to ensure proper setup order
  depends_on = [
    aws_db_subnet_group.main,
    aws_security_group.database,
    aws_route_table_association.private
  ]

  lifecycle {
    prevent_destroy = false  # Set to true in production
    ignore_changes = [
      password,  # Ignore password changes to prevent unnecessary updates
      snapshot_identifier  # Ignore snapshot changes
    ]
  }

  tags = {
    Name           = "${var.resource_prefix}-database-${random_id.suffix.hex}"
    DependencyTier = "data"
    ResourceType   = "rds-instance"
    Engine         = var.database_configuration.engine
  }
}

# ============================================================================
# APPLICATION TIER WITH LAUNCH TEMPLATES (DEPENDENCY TIER 6)
# ============================================================================

# Launch Templates for each application tier using for_each
resource "aws_launch_template" "app_tiers" {
  for_each = var.enable_auto_scaling ? var.application_tiers : {}

  name_prefix   = "${var.resource_prefix}-${each.key}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type

  # Security group configuration with implicit dependency
  vpc_security_group_ids = [aws_security_group.app_tiers[each.key].id]

  # User data with template rendering
  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    tier_name         = each.key
    tier_port         = each.value.target_group_port
    database_endpoint = var.enable_rds ? aws_db_instance.main[0].endpoint : "localhost"
    student_name      = var.student_name
    project_name      = var.project_name
  }))

  # Monitoring configuration
  monitoring {
    enabled = each.value.enable_monitoring
  }

  # Block device mapping
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = var.encryption_enabled
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name           = "${var.resource_prefix}-${each.key}-instance-${random_id.suffix.hex}"
      DependencyTier = "application"
      ResourceType   = "ec2-instance"
      ApplicationTier = each.key
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  # Explicit dependency on database for application tiers
  depends_on = var.enable_rds ? [aws_db_instance.main] : []
}

# Auto Scaling Groups for each application tier
resource "aws_autoscaling_group" "app_tiers" {
  for_each = var.enable_auto_scaling ? var.application_tiers : {}

  name                = "${var.resource_prefix}-${each.key}-asg-${random_id.suffix.hex}"
  vpc_zone_identifier = aws_subnet.private[*].id  # Implicit dependency on private subnets
  target_group_arns   = each.key == "web" && var.load_balancer_configuration.enable_application_lb ? [aws_lb_target_group.web[0].arn] : []
  health_check_type   = each.value.health_check_type
  health_check_grace_period = each.value.health_check_grace_period

  min_size         = each.value.min_size
  max_size         = each.value.max_size
  desired_capacity = each.value.desired_capacity

  launch_template {
    id      = aws_launch_template.app_tiers[each.key].id
    version = "$Latest"
  }

  # Instance refresh configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  # Explicit dependencies for proper ordering
  depends_on = [
    aws_launch_template.app_tiers,
    aws_route_table_association.private
  ]

  tag {
    key                 = "Name"
    value               = "${var.resource_prefix}-${each.key}-asg-${random_id.suffix.hex}"
    propagate_at_launch = false
  }

  tag {
    key                 = "DependencyTier"
    value               = "application"
    propagate_at_launch = true
  }

  tag {
    key                 = "ApplicationTier"
    value               = each.key
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity  # Allow auto scaling to manage capacity
    ]
  }
}

# ============================================================================
# LOAD BALANCER TIER WITH COMPLEX DEPENDENCIES (DEPENDENCY TIER 7)
# ============================================================================

# Application Load Balancer with complex explicit dependencies
resource "aws_lb" "main" {
  count = var.load_balancer_configuration.enable_application_lb ? 1 : 0

  name               = "${var.resource_prefix}-alb-${random_id.suffix.hex}"
  internal           = var.load_balancer_configuration.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.load_balancer_configuration.enable_deletion_protection
  idle_timeout              = var.load_balancer_configuration.idle_timeout

  # Complex explicit dependencies to ensure proper setup order
  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.public,
    aws_autoscaling_group.app_tiers
  ]

  tags = {
    Name           = "${var.resource_prefix}-alb-${random_id.suffix.hex}"
    DependencyTier = "presentation"
    ResourceType   = "application-load-balancer"
  }
}

# Target Group for web tier
resource "aws_lb_target_group" "web" {
  count = var.load_balancer_configuration.enable_application_lb ? 1 : 0

  name     = "${var.resource_prefix}-web-tg-${random_id.suffix.hex}"
  port     = var.application_tiers.web.target_group_port
  protocol = var.application_tiers.web.target_group_protocol
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name           = "${var.resource_prefix}-web-tg-${random_id.suffix.hex}"
    DependencyTier = "presentation"
    ResourceType   = "target-group"
    ApplicationTier = "web"
  }
}

# ALB Listener
resource "aws_lb_listener" "web" {
  count = var.load_balancer_configuration.enable_application_lb ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web[0].arn
  }

  # Explicit dependency on target group
  depends_on = [aws_lb_target_group.web]

  tags = {
    Name           = "${var.resource_prefix}-web-listener-${random_id.suffix.hex}"
    DependencyTier = "presentation"
    ResourceType   = "lb-listener"
  }
}

# ============================================================================
# MONITORING AND LOGGING RESOURCES (DEPENDENCY TIER 8)
# ============================================================================

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  count = var.monitoring_enabled ? 1 : 0

  name              = "/aws/ec2/${var.resource_prefix}-${random_id.suffix.hex}"
  retention_in_days = var.log_retention_days

  tags = {
    Name           = "${var.resource_prefix}-logs-${random_id.suffix.hex}"
    DependencyTier = "monitoring"
    ResourceType   = "cloudwatch-log-group"
  }
}

# VPC Flow Logs (optional)
resource "aws_flow_log" "vpc" {
  count = var.vpc_configuration.enable_flow_logs && var.monitoring_enabled ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name           = "${var.resource_prefix}-vpc-flow-logs-${random_id.suffix.hex}"
    DependencyTier = "monitoring"
    ResourceType   = "vpc-flow-log"
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.vpc_configuration.enable_flow_logs && var.monitoring_enabled ? 1 : 0

  name              = "/aws/vpc/flowlogs-${random_id.suffix.hex}"
  retention_in_days = var.log_retention_days

  tags = {
    Name           = "${var.resource_prefix}-vpc-flow-logs-${random_id.suffix.hex}"
    DependencyTier = "monitoring"
    ResourceType   = "cloudwatch-log-group"
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log" {
  count = var.vpc_configuration.enable_flow_logs && var.monitoring_enabled ? 1 : 0

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
    Name           = "${var.resource_prefix}-flow-log-role-${random_id.suffix.hex}"
    DependencyTier = "monitoring"
    ResourceType   = "iam-role"
  }
}

# IAM Role Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_log" {
  count = var.vpc_configuration.enable_flow_logs && var.monitoring_enabled ? 1 : 0

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
