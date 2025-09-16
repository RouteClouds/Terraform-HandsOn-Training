# Terraform Code Lab 5.1: Advanced Variables and Outputs
# Main Infrastructure Resources
#
# This file demonstrates the implementation of enterprise-scale infrastructure
# using advanced variable patterns, local value optimizations, and sophisticated
# output strategies. It creates a complete multi-tier architecture with proper
# security, monitoring, and governance controls.

# VPC - Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = var.network_configuration.vpc.cidr_block
  enable_dns_hostnames = var.network_configuration.vpc.enable_dns_hostnames
  enable_dns_support   = var.network_configuration.vpc.enable_dns_support
  instance_tenancy     = var.network_configuration.vpc.instance_tenancy
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
    Type = "vpc"
    CIDR = var.network_configuration.vpc.cidr_block
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  count = var.network_configuration.gateways.internet_gateway.enabled ? 1 : 0
  
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
    Type = "internet-gateway"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = local.subnet_configurations.public
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip
  
  tags = each.value.tags
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = local.subnet_configurations.private
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  
  tags = each.value.tags
}

# Database Subnets
resource "aws_subnet" "database" {
  for_each = local.subnet_configurations.database
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  
  tags = each.value.tags
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.network_configuration.gateways.nat_gateway.enabled ? length(local.subnet_configurations.public) : 0
  
  domain = "vpc"
  
  depends_on = [aws_internet_gateway.main]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    Type = "elastic-ip"
    Purpose = "nat-gateway"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.network_configuration.gateways.nat_gateway.enabled ? length(local.subnet_configurations.public) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = values(aws_subnet.public)[count.index].id
  
  depends_on = [aws_internet_gateway.main]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-gateway-${count.index + 1}"
    Type = "nat-gateway"
    AZ   = values(aws_subnet.public)[count.index].availability_zone
  })
}

# Route Tables - Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
    Type = "route-table"
    Tier = "public"
  })
}

# Route Tables - Private
resource "aws_route_table" "private" {
  count = var.network_configuration.gateways.nat_gateway.enabled ? length(local.subnet_configurations.private) : 1
  
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.network_configuration.gateways.nat_gateway.enabled ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
    Type = "route-table"
    Tier = "private"
  })
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  
  subnet_id      = each.value.id
  route_table_id = var.network_configuration.gateways.nat_gateway.enabled ? 
    aws_route_table.private[each.value.tags.index].id : 
    aws_route_table.private[0].id
}

# Security Groups
resource "aws_security_group" "main" {
  for_each = local.security_group_configs
  
  name        = each.value.name
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
  
  tags = each.value.tags
}

# Application Load Balancer
resource "aws_lb" "main" {
  for_each = local.application_configs
  
  name               = "${each.value.full_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [for sg_name in each.value.security_groups : aws_security_group.main[sg_name].id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  
  enable_deletion_protection = local.environment == "prod"
  
  tags = merge(each.value.tags, {
    Name = "${each.value.full_name}-alb"
    Type = "application-load-balancer"
  })
}

# Target Groups
resource "aws_lb_target_group" "main" {
  for_each = local.application_configs
  
  name     = "${each.value.full_name}-tg"
  port     = each.value.application.port
  protocol = each.value.application.protocol
  vpc_id   = aws_vpc.main.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = each.value.network.health_check_timeout
    interval            = each.value.network.health_check_interval
    path                = each.value.network.health_check_path
    matcher             = "200"
    port                = "traffic-port"
    protocol            = each.value.application.protocol
  }
  
  tags = merge(each.value.tags, {
    Name = "${each.value.full_name}-tg"
    Type = "target-group"
  })
}

# Load Balancer Listeners
resource "aws_lb_listener" "main" {
  for_each = local.application_configs
  
  load_balancer_arn = aws_lb.main[each.key].arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }
  
  tags = merge(each.value.tags, {
    Name = "${each.value.full_name}-listener"
    Type = "load-balancer-listener"
  })
}

# Launch Template
resource "aws_launch_template" "main" {
  for_each = local.application_configs
  
  name_prefix   = "${each.value.full_name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = each.value.adjusted_instance_type
  
  vpc_security_group_ids = [for sg_name in each.value.security_groups : aws_security_group.main[sg_name].id]
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value.infrastructure.storage.root_volume_size
      volume_type           = each.value.infrastructure.storage.root_volume_type
      encrypted             = each.value.infrastructure.storage.root_volume_encrypted
      delete_on_termination = true
    }
  }
  
  monitoring {
    enabled = each.value.monitoring_config.detailed_monitoring
  }
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    app_name = each.value.metadata.name
    app_port = each.value.application.port
    environment = local.environment
  }))
  
  tag_specifications {
    resource_type = "instance"
    tags = merge(each.value.tags, {
      Name = "${each.value.full_name}-instance"
      Type = "ec2-instance"
    })
  }
  
  tags = merge(each.value.tags, {
    Name = "${each.value.full_name}-lt"
    Type = "launch-template"
  })
}

# Auto Scaling Groups
resource "aws_autoscaling_group" "main" {
  for_each = local.application_configs
  
  name                = "${each.value.full_name}-asg"
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]
  target_group_arns   = [aws_lb_target_group.main[each.key].arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  min_size         = each.value.adjusted_capacity.min
  max_size         = each.value.adjusted_capacity.max
  desired_capacity = each.value.adjusted_capacity.desired
  
  launch_template {
    id      = aws_launch_template.main[each.key].id
    version = "$Latest"
  }
  
  dynamic "tag" {
    for_each = merge(each.value.tags, {
      Name = "${each.value.full_name}-asg"
      Type = "auto-scaling-group"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  for_each = local.application_configs
  
  name                   = "${each.value.full_name}-scale-up"
  scaling_adjustment     = each.value.infrastructure.auto_scaling.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = each.value.infrastructure.auto_scaling.scale_up_cooldown
  autoscaling_group_name = aws_autoscaling_group.main[each.key].name
}

resource "aws_autoscaling_policy" "scale_down" {
  for_each = local.application_configs
  
  name                   = "${each.value.full_name}-scale-down"
  scaling_adjustment     = each.value.infrastructure.auto_scaling.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = each.value.infrastructure.auto_scaling.scale_down_cooldown
  autoscaling_group_name = aws_autoscaling_group.main[each.key].name
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each = local.application_configs
  
  alarm_name          = "${each.value.full_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = each.value.infrastructure.auto_scaling.target_cpu_utilization
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up[each.key].arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main[each.key].name
  }
  
  tags = merge(each.value.tags, {
    Name = "${each.value.full_name}-cpu-high-alarm"
    Type = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  for_each = local.application_configs
  
  alarm_name          = "${each.value.full_name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = each.value.infrastructure.auto_scaling.target_cpu_utilization - 20
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down[each.key].arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main[each.key].name
  }
  
  tags = merge(each.value.tags, {
    Name = "${each.value.full_name}-cpu-low-alarm"
    Type = "cloudwatch-alarm"
  })
}
