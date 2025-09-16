# AWS Terraform Training - Topic 3: Core Terraform Operations
# Terraform Code Lab 3.1 - Main Infrastructure Configuration
#
# This file demonstrates comprehensive core Terraform operations including
# resource lifecycle management, data sources, provisioners, meta-arguments,
# and enterprise resource organization patterns.
#
# Learning Objectives:
# 1. Resource lifecycle management and state operations
# 2. Data source integration and external data handling
# 3. Meta-argument implementation (count, for_each, depends_on, lifecycle)
# 4. Provisioner usage and configuration management
# 5. Enterprise resource organization and governance

# =============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# =============================================================================

resource "random_id" "deployment" {
  byte_length = 4
  
  keepers = {
    environment = var.environment
    project     = var.project_name
    timestamp   = timestamp()
  }
}

resource "random_password" "database_password" {
  length  = 16
  special = true
  
  keepers = {
    environment = var.environment
  }
}

# =============================================================================
# VPC AND NETWORKING INFRASTRUCTURE
# =============================================================================

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
    Type = "network"
    Component = "foundation"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
    Type = "network"
    Component = "foundation"
  })
}

# Public Subnets (using count meta-argument)
resource "aws_subnet" "public" {
  count = local.az_count
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    Type = "public"
    AZ   = local.availability_zones[count.index]
    Tier = "public"
  })
}

# Private Subnets (using count meta-argument)
resource "aws_subnet" "private" {
  count = local.az_count
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
    Type = "private"
    AZ   = local.availability_zones[count.index]
    Tier = "private"
  })
}

# Database Subnets (using count meta-argument)
resource "aws_subnet" "database" {
  count = local.az_count
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.database_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-subnet-${count.index + 1}"
    Type = "database"
    AZ   = local.availability_zones[count.index]
    Tier = "database"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.az_count : 0
  
  domain = "vpc"
  
  depends_on = [aws_internet_gateway.main]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    Type = "network"
    AZ   = local.availability_zones[count.index]
  })
}

# NAT Gateways (conditional creation)
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? local.az_count : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  depends_on = [aws_internet_gateway.main]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-gateway-${count.index + 1}"
    Type = "network"
    AZ   = local.availability_zones[count.index]
  })
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
    Type = "network"
    Tier = "public"
  })
}

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? local.az_count : 1
  
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
    Type = "network"
    Tier = "private"
    AZ   = var.enable_nat_gateway ? local.availability_zones[count.index] : "shared"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = local.az_count
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = local.az_count
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

# =============================================================================
# SECURITY GROUPS (using for_each meta-argument)
# =============================================================================

resource "aws_security_group" "main" {
  for_each = { for sg in var.security_groups : sg.name => sg }
  
  name_prefix = "${local.name_prefix}-${each.key}-"
  description = each.value.description
  vpc_id      = aws_vpc.main.id
  
  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  
  # Dynamic egress rules
  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}-sg"
    Type = "security"
    Tier = each.key
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# DATABASE INFRASTRUCTURE
# =============================================================================

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
    Type = "database"
    Component = "infrastructure"
  })
}

# RDS Instance with lifecycle protection
resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-main-db"
  
  # Engine configuration
  engine         = var.database_config.engine
  engine_version = var.database_config.engine_version
  instance_class = var.database_config.instance_class
  
  # Storage configuration
  allocated_storage     = var.database_config.allocated_storage
  max_allocated_storage = var.database_config.max_allocated_storage
  storage_encrypted     = var.database_config.storage_encrypted
  
  # Database configuration
  db_name  = var.database_credentials.database_name
  username = var.database_credentials.username
  password = var.database_credentials.password
  
  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main["database"].id]
  
  # Backup configuration
  backup_retention_period = var.database_config.backup_retention_period
  backup_window          = var.database_config.backup_window
  maintenance_window     = var.database_config.maintenance_window
  
  # High availability
  multi_az = var.database_config.multi_az
  
  # For lab purposes - in production, enable final snapshot
  skip_final_snapshot = true
  
  # Lifecycle management
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      password,
      latest_restorable_time
    ]
  }
  
  # Explicit dependencies
  depends_on = [
    aws_db_subnet_group.main,
    aws_security_group.main
  ]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-main-database"
    Type = "database"
    Critical = "true"
    Component = "data"
  })
}

# =============================================================================
# LOAD BALANCER INFRASTRUCTURE
# =============================================================================

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = var.load_balancer_config.type
  security_groups    = [aws_security_group.main["web"].id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection       = var.load_balancer_config.enable_deletion_protection
  idle_timeout                    = var.load_balancer_config.idle_timeout
  enable_cross_zone_load_balancing = var.load_balancer_config.enable_cross_zone_load_balancing

  # Lifecycle management for smooth updates
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
    Type = "load-balancer"
    Component = "networking"
  })
}

# Target Group for Web Servers
resource "aws_lb_target_group" "web" {
  name     = "${local.name_prefix}-web-tg"
  port     = var.target_group_config.port
  protocol = var.target_group_config.protocol
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = var.target_group_config.healthy_threshold
    unhealthy_threshold = var.target_group_config.unhealthy_threshold
    timeout             = var.target_group_config.health_check_timeout
    interval            = var.target_group_config.health_check_interval
    path                = var.target_group_config.health_check_path
    matcher             = "200"
    protocol            = var.target_group_config.protocol
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-target-group"
    Type = "load-balancer"
    Component = "networking"
  })
}

# ALB Listener
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
  })
}

# =============================================================================
# EC2 INSTANCES (using for_each meta-argument)
# =============================================================================

# Web Server Instances
resource "aws_instance" "web" {
  for_each = {
    for i in range(var.instance_count.web) :
    "web-${i + 1}" => {
      subnet_id = aws_subnet.public[i % local.az_count].id
      az_index  = i % local.az_count
    }
  }

  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.instance_types.web
  key_name      = var.key_pair_name

  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [aws_security_group.main["web"].id]
  associate_public_ip_address = true

  monitoring = var.monitoring_enabled

  # User data for web server configuration
  user_data = base64encode(templatefile("${path.module}/scripts/web_server.sh", {
    instance_name = each.key
    environment   = var.environment
    database_endpoint = aws_db_instance.main.endpoint
  }))

  # Connection configuration for provisioners
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/${var.key_pair_name}.pem")
    host        = self.public_ip
    timeout     = var.provisioner_config.connection_timeout
  }

  # File provisioner for additional configuration
  provisioner "file" {
    count = var.provisioner_config.enable_file_provisioner ? 1 : 0

    content = templatefile("${path.module}/templates/nginx.conf.tpl", {
      server_name = each.key
      environment = var.environment
    })
    destination = "/tmp/nginx.conf"
  }

  # Remote provisioner for software installation
  provisioner "remote-exec" {
    count = var.provisioner_config.enable_remote_exec ? 1 : 0

    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "echo 'Web server ${each.key} configured at $(date)' | sudo tee -a /var/log/provisioning.log"
    ]
  }

  # Local provisioner for deployment tracking
  provisioner "local-exec" {
    count = var.provisioner_config.enable_local_exec ? 1 : 0

    command = "echo 'Web server ${each.key} (${self.id}) deployed at ${timestamp()}' >> ${path.module}/deployment.log"

    environment = {
      INSTANCE_ID = self.id
      PUBLIC_IP   = self.public_ip
      ENVIRONMENT = var.environment
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
    Type = "web-server"
    Tier = "web"
    Instance = each.key
    AZ = local.availability_zones[each.value.az_index]
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      ami,  # Ignore AMI changes to prevent unwanted replacements
      user_data  # Ignore user data changes after initial creation
    ]
  }
}

# Application Server Instances
resource "aws_instance" "app" {
  for_each = {
    for i in range(var.instance_count.app) :
    "app-${i + 1}" => {
      subnet_id = aws_subnet.private[i % local.az_count].id
      az_index  = i % local.az_count
    }
  }

  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.instance_types.app
  key_name      = var.key_pair_name

  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.main["app"].id]

  monitoring = var.monitoring_enabled

  # User data for application server configuration
  user_data = base64encode(templatefile("${path.module}/scripts/app_server.sh", {
    instance_name = each.key
    environment   = var.environment
    database_endpoint = aws_db_instance.main.endpoint
  }))

  # Explicit dependency on database
  depends_on = [aws_db_instance.main]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
    Type = "app-server"
    Tier = "application"
    Instance = each.key
    AZ = local.availability_zones[each.value.az_index]
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

# =============================================================================
# LOAD BALANCER TARGET GROUP ATTACHMENTS
# =============================================================================

# Attach web instances to target group
resource "aws_lb_target_group_attachment" "web" {
  for_each = aws_instance.web

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = each.value.id
  port             = var.target_group_config.port
}

# =============================================================================
# CLOUDWATCH LOG GROUPS (conditional creation)
# =============================================================================

resource "aws_cloudwatch_log_group" "application" {
  count = var.feature_flags.enable_cloudwatch_logs ? 1 : 0

  name              = "/aws/ec2/${local.name_prefix}"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-application-logs"
    Type = "monitoring"
    Component = "logging"
  })
}

# =============================================================================
# VPC FLOW LOGS (conditional creation)
# =============================================================================

resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc-flow-logs"
    Type = "monitoring"
    Component = "security"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/flowlogs/${local.name_prefix}"
  retention_in_days = 30

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc-flow-logs"
    Type = "monitoring"
    Component = "security"
  })
}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-flow-log-role"

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

  tags = local.common_tags
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-flow-log-policy"
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
