# Route53 DNS Resources
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# Route53 Hosted Zone
# ========================================

resource "aws_route53_zone" "main" {
  count = var.create_route53_zone && var.domain_name != "" ? 1 : 0
  
  name    = var.domain_name
  comment = "Hosted zone for ${local.name_prefix}"
  
  tags = merge(
    local.common_tags,
    {
      Name = var.domain_name
    }
  )
}

# ========================================
# A Record for ALB
# ========================================

resource "aws_route53_record" "alb" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"
  
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# ========================================
# A Record for CloudFront
# ========================================

resource "aws_route53_record" "cloudfront" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = "cdn.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

# ========================================
# CNAME Record for www
# ========================================

resource "aws_route53_record" "www" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.domain_name]
}

# ========================================
# AAAA Record for ALB (IPv6)
# ========================================

resource "aws_route53_record" "alb_ipv6" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "AAAA"
  
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# ========================================
# AAAA Record for CloudFront (IPv6)
# ========================================

resource "aws_route53_record" "cloudfront_ipv6" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = "cdn.${var.domain_name}"
  type    = "AAAA"
  
  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

# ========================================
# MX Records (Email)
# ========================================

resource "aws_route53_record" "mx" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 300
  records = [
    "10 mail.${var.domain_name}"
  ]
}

# ========================================
# TXT Records (SPF, DKIM, DMARC)
# ========================================

# SPF Record
resource "aws_route53_record" "spf" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 include:_spf.${var.domain_name} ~all"
  ]
}

# DMARC Record
resource "aws_route53_record" "dmarc" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DMARC1; p=quarantine; rua=mailto:dmarc@${var.domain_name}"
  ]
}

# ========================================
# CAA Records (Certificate Authority Authorization)
# ========================================

resource "aws_route53_record" "caa" {
  count = var.domain_name != "" ? 1 : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "CAA"
  ttl     = 300
  records = [
    "0 issue \"amazon.com\"",
    "0 issuewild \"amazon.com\""
  ]
}

# ========================================
# Health Check for ALB
# ========================================

resource "aws_route53_health_check" "alb" {
  count = var.domain_name != "" ? 1 : 0
  
  fqdn              = aws_lb.main.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-health-check"
    }
  )
}

# ========================================
# CloudWatch Alarm for Health Check
# ========================================

resource "aws_cloudwatch_metric_alarm" "route53_health_check" {
  count = var.domain_name != "" ? 1 : 0
  
  alarm_name          = "${local.name_prefix}-route53-health-check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "This metric monitors Route53 health check status"
  alarm_actions       = local.alarm_actions
  
  dimensions = {
    HealthCheckId = aws_route53_health_check.alb[0].id
  }
  
  tags = local.common_tags
}

# ========================================
# Route53 Query Logging (Optional)
# ========================================

resource "aws_cloudwatch_log_group" "route53_query_logs" {
  count = var.domain_name != "" && var.create_route53_zone ? 1 : 0
  
  name              = "/aws/route53/${var.domain_name}"
  retention_in_days = 7
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-route53-query-logs"
    }
  )
}

resource "aws_route53_query_log" "main" {
  count = var.domain_name != "" && var.create_route53_zone ? 1 : 0
  
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_query_logs[0].arn
  zone_id                  = aws_route53_zone.main[0].zone_id
  
  depends_on = [
    aws_cloudwatch_log_group.route53_query_logs
  ]
}

# ========================================
# Route53 Resolver Endpoint (Optional)
# ========================================

# Uncomment to enable Route53 Resolver for hybrid DNS
# resource "aws_route53_resolver_endpoint" "inbound" {
#   name      = "${local.name_prefix}-resolver-inbound"
#   direction = "INBOUND"
#   
#   security_group_ids = [aws_security_group.resolver.id]
#   
#   dynamic "ip_address" {
#     for_each = aws_subnet.private[*].id
#     content {
#       subnet_id = ip_address.value
#     }
#   }
#   
#   tags = local.common_tags
# }

