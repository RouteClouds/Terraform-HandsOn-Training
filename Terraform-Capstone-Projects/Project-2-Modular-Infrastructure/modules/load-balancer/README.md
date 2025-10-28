# Load Balancer Module

This module creates an Application Load Balancer with target groups and listeners.

## Features

- ✅ Application Load Balancer
- ✅ Target groups with health checks
- ✅ HTTP and HTTPS listeners
- ✅ SSL/TLS certificate support
- ✅ Access logs to S3 (optional)
- ✅ Customizable tags

## Usage

```hcl
module "load_balancer" {
  source = "./modules/load-balancer"
  
  name               = "main-alb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security.alb_security_group_id]
  
  enable_https    = false
  certificate_arn = null
  
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

