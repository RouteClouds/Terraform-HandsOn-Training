# Application Load Balancer Resources
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# Application Load Balancer
# ========================================

resource "aws_lb" "main" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  
  enable_deletion_protection = false
  enable_http2              = true
  enable_cross_zone_load_balancing = true
  
  # Access logs (optional - requires S3 bucket)
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "alb"
    enabled = true
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = local.alb_name
    }
  )
}

# ========================================
# S3 Bucket for ALB Access Logs
# ========================================

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${local.name_prefix}-alb-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-logs"
    }
  )
}

# S3 Bucket Policy for ALB Logs
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/alb/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/alb/*"
      }
    ]
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  
  rule {
    id     = "delete-old-logs"
    status = "Enabled"
    
    expiration {
      days = 90
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# ========================================
# Target Group
# ========================================

resource "aws_lb_target_group" "main" {
  name     = local.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  # Health check configuration
  health_check {
    enabled             = local.health_check.enabled
    healthy_threshold   = local.health_check.healthy_threshold
    unhealthy_threshold = local.health_check.unhealthy_threshold
    timeout             = local.health_check.timeout
    interval            = local.health_check.interval
    path                = local.health_check.path
    protocol            = local.health_check.protocol
    matcher             = local.health_check.matcher
  }
  
  # Deregistration delay
  deregistration_delay = 30
  
  # Stickiness
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = local.target_group_name
    }
  )
}

# ========================================
# HTTP Listener (Port 80)
# ========================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  # Default action - redirect to HTTPS if certificate exists, otherwise forward
  default_action {
    type = var.domain_name != "" ? "redirect" : "forward"
    
    dynamic "redirect" {
      for_each = var.domain_name != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    
    target_group_arn = var.domain_name != "" ? null : aws_lb_target_group.main.arn
  }
  
  tags = local.common_tags
}

# ========================================
# HTTPS Listener (Port 443) - Optional
# ========================================

resource "aws_lb_listener" "https" {
  count = var.domain_name != "" ? 1 : 0
  
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.main[0].arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  
  tags = local.common_tags
}

# ========================================
# Listener Rules (Optional)
# ========================================

# Rule for /api/* paths
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
  
  tags = local.common_tags
}

# Rule for /health path
resource "aws_lb_listener_rule" "health" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 50
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  
  condition {
    path_pattern {
      values = ["/health"]
    }
  }
  
  tags = local.common_tags
}

# ========================================
# WAF Web ACL Association (Optional)
# ========================================

# Uncomment to enable WAF
# resource "aws_wafv2_web_acl_association" "main" {
#   resource_arn = aws_lb.main.arn
#   web_acl_arn  = aws_wafv2_web_acl.main.arn
# }

