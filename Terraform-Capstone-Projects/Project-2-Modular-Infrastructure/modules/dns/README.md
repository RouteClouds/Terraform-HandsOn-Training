# DNS Module

This module creates Route53 hosted zone and DNS records.

## Features

- ✅ Route53 hosted zone creation
- ✅ A records for ALB
- ✅ Health checks
- ✅ Customizable TTL
- ✅ Customizable tags

## Usage

```hcl
module "dns" {
  source = "./modules/dns"
  
  domain_name         = "example.com"
  create_hosted_zone  = true
  
  alb_dns_name = module.load_balancer.alb_dns_name
  alb_zone_id  = module.load_balancer.alb_zone_id
  
  tags = {
    Environment = "dev"
    Project     = "modular-infrastructure"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.0 |
| aws | >= 6.12.0 |

## Version History

- **v1.0.0** (2025-10-27): Initial release

## Authors

RouteCloud Training Team

