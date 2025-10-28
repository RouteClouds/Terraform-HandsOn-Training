# Compute Resources (EC2, Auto Scaling)
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# Launch Template
# ========================================

resource "aws_launch_template" "main" {
  name_prefix   = "${local.launch_template_name}-"
  description   = "Launch template for ${local.name_prefix} web servers"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null
  
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }
  
  vpc_security_group_ids = [aws_security_group.ec2.id]
  
  # User data script
  user_data = base64encode(templatefile("${path.module}/user-data.sh.tpl", {
    environment    = var.environment
    project_name   = var.project_name
    region         = var.aws_region
    db_endpoint    = aws_db_instance.main.endpoint
    db_name        = var.db_name
    s3_bucket      = aws_s3_bucket.static_assets.id
  }))
  
  # Block device mappings
  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      encrypted             = true
      kms_key_id            = aws_kms_key.main.arn
      delete_on_termination = true
    }
  }
  
  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  # Monitoring
  monitoring {
    enabled = true
  }
  
  # Network interfaces
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.ec2.id]
  }
  
  tag_specifications {
    resource_type = "instance"
    
    tags = merge(
      local.common_tags,
      {
        Name = "${local.name_prefix}-instance"
      }
    )
  }
  
  tag_specifications {
    resource_type = "volume"
    
    tags = merge(
      local.common_tags,
      {
        Name = "${local.name_prefix}-volume"
      }
    )
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = local.launch_template_name
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# Auto Scaling Group
# ========================================

resource "aws_autoscaling_group" "main" {
  name                = local.asg_name
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
  
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  
  # Instance refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  
  # Termination policies
  termination_policies = ["OldestInstance"]
  
  # Metrics collection
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
  
  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
  
  depends_on = [
    aws_lb.main,
    aws_db_instance.main
  ]
}

# ========================================
# Auto Scaling Policies
# ========================================

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${local.name_prefix}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${local.name_prefix}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# ========================================
# CloudWatch Alarms for Auto Scaling
# ========================================

# High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
  
  tags = local.common_tags
}

# Low CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${local.name_prefix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
  
  tags = local.common_tags
}

# ========================================
# Auto Scaling Schedule (Optional)
# ========================================

# Scale up during business hours
resource "aws_autoscaling_schedule" "scale_up_morning" {
  scheduled_action_name  = "${local.name_prefix}-scale-up-morning"
  min_size               = var.asg_min_size
  max_size               = var.asg_max_size
  desired_capacity       = var.asg_desired_capacity
  recurrence             = "0 8 * * MON-FRI"
  time_zone              = "America/New_York"
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Scale down after business hours
resource "aws_autoscaling_schedule" "scale_down_evening" {
  scheduled_action_name  = "${local.name_prefix}-scale-down-evening"
  min_size               = 1
  max_size               = var.asg_max_size
  desired_capacity       = 1
  recurrence             = "0 18 * * MON-FRI"
  time_zone              = "America/New_York"
  autoscaling_group_name = aws_autoscaling_group.main.name
}

