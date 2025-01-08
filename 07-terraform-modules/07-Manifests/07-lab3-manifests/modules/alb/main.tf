# Application Load Balancer Module - Main Configuration

# Create Application Load Balancer
resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  # Enable deletion protection for production
  enable_deletion_protection = var.environment == "production"

  # Access logs configuration (optional)
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = "alb-logs/${var.name}"
      enabled = true
    }
  }

  tags = merge(
    {
      Name        = var.name
      Environment = var.environment
    },
    var.tags
  )
}

# Create Target Group
resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_threshold
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = "traffic-port"
    timeout             = var.health_check_timeout
    matcher             = var.health_check_codes
    unhealthy_threshold = var.health_check_threshold
  }

  tags = merge(
    {
      Name        = "${var.name}-tg"
      Environment = var.environment
    },
    var.tags
  )
}

# Register instances with target group
resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.instance_ids[count.index]
  port             = var.target_port
}

# Create HTTPS Listener (if SSL is enabled)
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Create HTTP Listener (with optional redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = var.enable_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.enable_https ? [] : [1]
      content {
        target_group_arn = aws_lb_target_group.this.arn
      }
    }
  }
}
