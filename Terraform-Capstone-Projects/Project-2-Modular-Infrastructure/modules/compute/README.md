# Compute Module

This module creates EC2 instances with Auto Scaling Group and Launch Template.

## Features

- ✅ Launch Template with user data
- ✅ Auto Scaling Group with configurable capacity
- ✅ CPU-based scaling policies
- ✅ CloudWatch alarms for scaling
- ✅ IMDSv2 enforcement
- ✅ EBS encryption
- ✅ Configurable instance type and AMI
- ✅ Health checks
- ✅ Customizable tags

## Usage

### Basic Example

```hcl
module "compute" {
  source = "./modules/compute"
  
  name_prefix         = "web"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.ec2_security_group_id]
  instance_profile_name = module.security.ec2_instance_profile_name
  
  instance_type    = "t3.micro"
  min_size         = 2
  max_size         = 6
  desired_capacity = 2
  
  tags = {
    Environment = "dev"
    Project     = "modular-infrastructure"
  }
}
```

### Production Example with Scaling

```hcl
module "compute" {
  source = "./modules/compute"
  
  name_prefix         = "prod-web"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.ec2_security_group_id]
  instance_profile_name = module.security.ec2_instance_profile_name
  
  instance_type    = "t3.small"
  min_size         = 3
  max_size         = 10
  desired_capacity = 3
  
  enable_scaling = true
  scale_up_cpu_threshold   = 70
  scale_down_cpu_threshold = 30
  
  enable_monitoring = true
  
  user_data = file("${path.module}/user-data.sh")
  
  tags = {
    Environment = "production"
    Project     = "modular-infrastructure"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.0 |
| aws | >= 6.12.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Name prefix for resources | `string` | n/a | yes |
| vpc_id | VPC ID | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for instances | `list(string)` | n/a | yes |
| security_group_ids | List of security group IDs | `list(string)` | n/a | yes |
| instance_profile_name | IAM instance profile name | `string` | n/a | yes |
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |
| ami_id | AMI ID (uses latest Amazon Linux 2023 if not specified) | `string` | `null` | no |
| min_size | Minimum number of instances | `number` | `2` | no |
| max_size | Maximum number of instances | `number` | `6` | no |
| desired_capacity | Desired number of instances | `number` | `2` | no |
| enable_scaling | Enable auto scaling policies | `bool` | `true` | no |
| scale_up_cpu_threshold | CPU threshold for scaling up | `number` | `75` | no |
| scale_down_cpu_threshold | CPU threshold for scaling down | `number` | `25` | no |
| enable_monitoring | Enable detailed monitoring | `bool` | `false` | no |
| user_data | User data script | `string` | `""` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling_group_id | Auto Scaling Group ID |
| autoscaling_group_name | Auto Scaling Group name |
| autoscaling_group_arn | Auto Scaling Group ARN |
| launch_template_id | Launch Template ID |
| launch_template_latest_version | Launch Template latest version |

## Resources Created

- 1 Launch Template
- 1 Auto Scaling Group
- 2 Auto Scaling Policies (scale up/down)
- 2 CloudWatch Alarms (CPU high/low)

## Examples

### Example 1: Development Environment

```hcl
module "dev_compute" {
  source = "./modules/compute"
  
  name_prefix         = "dev-web"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.ec2_security_group_id]
  instance_profile_name = module.security.ec2_instance_profile_name
  
  instance_type    = "t3.micro"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1
  
  enable_scaling = false
  
  tags = {
    Environment = "dev"
  }
}
```

### Example 2: Attach to Load Balancer

```hcl
module "compute" {
  source = "./modules/compute"
  
  name_prefix         = "web"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.ec2_security_group_id]
  instance_profile_name = module.security.ec2_instance_profile_name
  
  instance_type    = "t3.micro"
  min_size         = 2
  max_size         = 6
  desired_capacity = 2
  
  tags = {
    Environment = "production"
  }
}

# Attach ASG to ALB target group
resource "aws_autoscaling_attachment" "asg_alb" {
  autoscaling_group_name = module.compute.autoscaling_group_name
  lb_target_group_arn    = module.load_balancer.target_group_arn
}
```

## Notes

- **Instance Type**: Choose appropriate instance type based on workload
- **Scaling**: Enable auto scaling for production workloads
- **Monitoring**: Enable detailed monitoring for better metrics
- **User Data**: Provide custom user data for application setup
- **AMI**: Module uses latest Amazon Linux 2023 if AMI not specified

## Version History

- **v1.0.0** (2025-10-27): Initial release

## Authors

RouteCloud Training Team

