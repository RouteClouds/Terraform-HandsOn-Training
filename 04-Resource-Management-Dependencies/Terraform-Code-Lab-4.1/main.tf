# AWS Terraform Training - Topic 4: Resource Management & Dependencies
# Terraform Code Lab 4.1 - Main Infrastructure Configuration
#
# This file implements comprehensive infrastructure with advanced dependency
# management, lifecycle patterns, meta-arguments, and enterprise-scale
# resource organization demonstrating Topic 4 concepts.

# Random ID for unique resource naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ============================================================================
# NETWORK INFRASTRUCTURE (Foundation Tier)
# ============================================================================

# VPC - Foundation resource for all networking
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-vpc"
    Type = "network"
    Tier = "foundation"
  })
}

# Internet Gateway - Implicit dependency on VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Implicit dependency
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-igw"
    Type = "network"
    Tier = "foundation"
  })
}

# Public Subnets - Implicit dependency on VPC
resource "aws_subnet" "public" {
  count = local.az_count
  
  vpc_id                  = aws_vpc.main.id  # Implicit dependency
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    Type = "public"
    AZ   = local.availability_zones[count.index]
    Tier = "network"
  })
}

# Private Subnets - Implicit dependency on VPC
resource "aws_subnet" "private" {
  count = local.az_count
  
  vpc_id            = aws_vpc.main.id  # Implicit dependency
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
    Type = "private"
    AZ   = local.availability_zones[count.index]
    Tier = "network"
  })
}

# Database Subnets - Implicit dependency on VPC
resource "aws_subnet" "database" {
  count = local.az_count
  
  vpc_id            = aws_vpc.main.id  # Implicit dependency
  cidr_block        = local.database_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-database-subnet-${count.index + 1}"
    Type = "database"
    AZ   = local.availability_zones[count.index]
    Tier = "data"
  })
}

# Elastic IPs for NAT Gateways - Explicit dependency on IGW
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.az_count : 0
  
  domain = "vpc"
  
  depends_on = [aws_internet_gateway.main]  # Explicit dependency
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    Type = "network"
    AZ   = local.availability_zones[count.index]
  })
}

# NAT Gateways - Multiple implicit dependencies
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? local.az_count : 0
  
  allocation_id = aws_eip.nat[count.index].id      # Implicit dependency
  subnet_id     = aws_subnet.public[count.index].id # Implicit dependency
  
  depends_on = [aws_internet_gateway.main]  # Explicit dependency
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-nat-gateway-${count.index + 1}"
    Type = "network"
    AZ   = local.availability_zones[count.index]
  })
}

# Route Tables for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  # Implicit dependency
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id  # Implicit dependency
  }
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-public-rt"
    Type = "routing"
    Tier = "network"
  })
}

# Route Tables for Private Subnets
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? local.az_count : 1
  
  vpc_id = aws_vpc.main.id  # Implicit dependency
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.enable_nat_gateway ? aws_nat_gateway.main[count.index].id : null
    }
  }
  
  tags = merge(local.network_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
    Type = "routing"
    Tier = "network"
  })
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  count = local.az_count
  
  subnet_id      = aws_subnet.public[count.index].id   # Implicit dependency
  route_table_id = aws_route_table.public.id           # Implicit dependency
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  count = local.az_count
  
  subnet_id      = aws_subnet.private[count.index].id  # Implicit dependency
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

# ============================================================================
# SECURITY INFRASTRUCTURE (Security Tier)
# ============================================================================

# Security Groups with for_each meta-argument
resource "aws_security_group" "main" {
  for_each = local.security_groups
  
  name_prefix = "${local.name_prefix}-${each.key}-"
  description = each.value.description
  vpc_id      = aws_vpc.main.id  # Implicit dependency
  
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
  
  tags = merge(local.security_tags, {
    Name = "${local.name_prefix}-${each.key}-sg"
    Type = "security"
    Tier = each.key
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# Cross-security group rules for complex dependencies
resource "aws_security_group_rule" "web_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.main["web"].id
  security_group_id        = aws_security_group.main["api"].id
  description              = "API access from web tier"
}

resource "aws_security_group_rule" "api_from_worker" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.main["worker"].id
  security_group_id        = aws_security_group.main["api"].id
  description              = "API access from worker tier"
}

# ============================================================================
# ENCRYPTION INFRASTRUCTURE (Security Tier)
# ============================================================================

# KMS Key for Database Encryption
resource "aws_kms_key" "database" {
  description             = "KMS key for database encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
  
  tags = merge(local.security_tags, {
    Name    = "${local.name_prefix}-database-kms-key"
    Type    = "encryption"
    Purpose = "database-encryption"
  })
}

resource "aws_kms_alias" "database" {
  name          = "alias/${local.name_prefix}-database"
  target_key_id = aws_kms_key.database.key_id
}

# KMS Key for Backup Encryption
resource "aws_kms_key" "backup" {
  count = local.resolved_feature_flags.enable_backup ? 1 : 0
  
  description             = "KMS key for backup encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(local.security_tags, {
    Name    = "${local.name_prefix}-backup-kms-key"
    Type    = "encryption"
    Purpose = "backup-encryption"
  })
}

resource "aws_kms_alias" "backup" {
  count = local.resolved_feature_flags.enable_backup ? 1 : 0
  
  name          = "alias/${local.name_prefix}-backup"
  target_key_id = aws_kms_key.backup[0].key_id
}

# ============================================================================
# DATABASE INFRASTRUCTURE (Data Tier)
# ============================================================================

# Database Subnet Group - Implicit dependency on database subnets
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id  # Implicit dependency
  
  tags = merge(local.database_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
    Type = "database"
    Tier = "data"
  })
}

# RDS Instance with comprehensive lifecycle management
resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-main-db"
  
  # Engine configuration
  engine         = local.resolved_database_config.engine
  engine_version = local.resolved_database_config.engine_version
  instance_class = local.resolved_database_config.instance_class
  
  # Storage configuration
  allocated_storage     = local.resolved_database_config.allocated_storage
  max_allocated_storage = local.resolved_database_config.max_allocated_storage
  storage_encrypted     = local.resolved_database_config.storage_encrypted
  kms_key_id           = aws_kms_key.database.arn
  
  # Database configuration
  db_name  = "fintech_db"
  username = "admin"
  password = "changeme123!"  # In production, use AWS Secrets Manager
  
  # Network configuration - Multiple implicit dependencies
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main["database"].id]
  
  # Backup and maintenance
  backup_retention_period = local.resolved_database_config.backup_retention_period
  backup_window          = local.resolved_database_config.backup_window
  maintenance_window     = local.resolved_database_config.maintenance_window
  
  # High availability
  multi_az = local.resolved_database_config.multi_az
  
  # Monitoring
  performance_insights_enabled = local.resolved_database_config.performance_insights
  monitoring_interval         = local.resolved_database_config.monitoring_interval
  
  # Deletion protection
  deletion_protection = local.resolved_database_config.deletion_protection
  skip_final_snapshot = false
  final_snapshot_identifier = "${local.name_prefix}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # Advanced lifecycle management
  lifecycle {
    prevent_destroy = true  # Prevent accidental destruction
    ignore_changes = [
      password,              # Ignore password changes
      latest_restorable_time,
      final_snapshot_identifier
    ]
  }
  
  # Explicit dependencies for proper ordering
  depends_on = [
    aws_db_subnet_group.main,
    aws_security_group.main,
    aws_kms_key.database
  ]
  
  tags = merge(local.database_tags, {
    Name = "${local.name_prefix}-main-database"
    Type = "database"
    Critical = "true"
    Tier = "data"
  })
}

# ============================================================================
# CACHE INFRASTRUCTURE (Data Tier) - Conditional Resources
# ============================================================================

# ElastiCache Subnet Group - Conditional creation
resource "aws_elasticache_subnet_group" "main" {
  count = local.resolved_feature_flags.enable_redis_cache ? 1 : 0

  name       = "${local.name_prefix}-cache-subnet"
  subnet_ids = aws_subnet.private[*].id  # Implicit dependency

  tags = merge(local.database_tags, {
    Name = "${local.name_prefix}-cache-subnet-group"
    Type = "cache"
    Tier = "data"
  })
}

# ElastiCache Redis Cluster - Conditional creation with dependencies
resource "aws_elasticache_cluster" "main" {
  count = local.resolved_feature_flags.enable_redis_cache ? 1 : 0

  cluster_id           = "${local.name_prefix}-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main[0].name
  security_group_ids   = [aws_security_group.main["queue"].id]

  tags = merge(local.database_tags, {
    Name = "${local.name_prefix}-cache"
    Type = "cache"
    Tier = "data"
  })
}

# ============================================================================
# APPLICATION INFRASTRUCTURE (Application Tier)
# ============================================================================

# Launch Templates for each application tier - for_each meta-argument
resource "aws_launch_template" "apps" {
  for_each = local.resolved_applications

  name_prefix   = "${local.name_prefix}-${each.key}-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type
  key_name      = var.key_pair_name

  # Security group assignment - Implicit dependencies
  vpc_security_group_ids = [
    for sg_name in each.value.security_groups :
    aws_security_group.main[sg_name].id
  ]

  # User data with template rendering
  user_data = base64encode(templatefile("${path.module}/templates/${each.key}_user_data.sh.tpl", {
    environment_vars = each.value.environment_vars
    app_name        = each.key
    database_endpoint = aws_db_instance.main.endpoint
    region          = local.region
    log_group_name  = local.monitoring_config.log_group_name
  }))

  # Instance metadata service configuration
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 1
  }

  # Monitoring configuration
  monitoring {
    enabled = each.value.enable_monitoring
  }

  # Block device mapping
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
      delete_on_termination = true
    }
  }

  # Lifecycle management for rolling updates
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.application_tags, {
      Name        = "${local.name_prefix}-${each.key}-instance"
      Application = each.key
      Tier        = each.key
      Monitoring  = each.value.enable_monitoring ? "enabled" : "disabled"
    })
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = local.load_balancer_config.name
  internal           = local.load_balancer_config.internal
  load_balancer_type = local.load_balancer_config.load_balancer_type
  security_groups    = [aws_security_group.main["web"].id]
  subnets            = aws_subnet.public[*].id  # Implicit dependency

  enable_deletion_protection = local.load_balancer_config.enable_deletion_protection

  # Lifecycle management for smooth updates
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.application_tags, {
    Name = "${local.name_prefix}-alb"
    Type = "load-balancer"
    Tier = "network"
  })
}

# Target Groups for each application - for_each with complex dependencies
resource "aws_lb_target_group" "apps" {
  for_each = local.resolved_applications

  name     = "${local.name_prefix}-${each.key}-tg"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = aws_vpc.main.id  # Implicit dependency

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = each.value.health_check_path
    matcher             = "200"
    protocol            = each.value.protocol
  }

  tags = merge(local.application_tags, {
    Name        = "${local.name_prefix}-${each.key}-target-group"
    Application = each.key
    Type        = "load-balancer"
  })
}

# Auto Scaling Groups with advanced lifecycle management
resource "aws_autoscaling_group" "apps" {
  for_each = local.resolved_applications

  name                = "${local.name_prefix}-${each.key}-asg"
  vpc_zone_identifier = each.value.subnets == "public" ? aws_subnet.public[*].id : aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.apps[each.key].arn]

  min_size         = each.value.min_capacity
  max_size         = each.value.max_capacity
  desired_capacity = each.value.desired_capacity

  # Health check configuration
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.apps[each.key].id
    version = "$Latest"
  }

  # Instance refresh for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup       = 300
      checkpoint_delay       = 600
    }
    triggers = ["tag"]
  }

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity  # Allow auto scaling to manage capacity
    ]
  }

  # Complex explicit dependencies
  depends_on = [
    aws_db_instance.main,  # Ensure database is ready
    aws_lb_target_group.apps,
    aws_launch_template.apps
  ]

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-${each.key}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = each.key
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = each.key
    propagate_at_launch = true
  }

  tag {
    key                 = "BackupRequired"
    value               = each.value.backup_required ? "true" : "false"
    propagate_at_launch = true
  }
}
