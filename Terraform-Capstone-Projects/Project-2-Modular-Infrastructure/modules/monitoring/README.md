# Monitoring Module

This module creates CloudWatch dashboards, alarms, and log groups.

## Features

- ✅ CloudWatch dashboards
- ✅ CloudWatch alarms
- ✅ CloudWatch log groups
- ✅ SNS topics for notifications
- ✅ Customizable metrics
- ✅ Customizable tags

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  name_prefix             = "myapp"
  alb_arn                 = module.load_balancer.alb_arn
  autoscaling_group_name  = module.compute.autoscaling_group_name
  db_instance_id          = module.database.db_instance_id
  
  alarm_email = "alerts@example.com"
  
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

