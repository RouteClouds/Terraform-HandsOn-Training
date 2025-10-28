locals {
  common_tags = merge(
    var.tags,
    {
      Module = "dns"
    }
  )
  
  hosted_zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.hosted_zone_id
}

# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  
  name = var.domain_name
  
  tags = merge(
    local.common_tags,
    {
      Name = var.domain_name
    }
  )
}

# A Record for ALB
resource "aws_route53_record" "alb" {
  count = var.alb_dns_name != null ? 1 : 0
  
  zone_id = local.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# WWW Record
resource "aws_route53_record" "www" {
  count = var.create_www_record && var.alb_dns_name != null ? 1 : 0
  
  zone_id = local.hosted_zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

