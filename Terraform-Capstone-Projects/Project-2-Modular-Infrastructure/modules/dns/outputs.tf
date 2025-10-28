output "hosted_zone_id" {
  description = "Hosted zone ID"
  value       = local.hosted_zone_id
}

output "hosted_zone_name_servers" {
  description = "Hosted zone name servers"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : null
}

output "record_fqdns" {
  description = "Record FQDNs"
  value = concat(
    var.alb_dns_name != null ? [aws_route53_record.alb[0].fqdn] : [],
    var.create_www_record && var.alb_dns_name != null ? [aws_route53_record.www[0].fqdn] : []
  )
}

