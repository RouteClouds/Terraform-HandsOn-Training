# Lab 3: Advanced Module Composition and Environment Management

## Overview
This lab demonstrates advanced Terraform module composition techniques, focusing on creating a scalable application infrastructure with environment-specific configurations.

## Architecture
`plaintext
Root Module
├── VPC Module (from Lab 1)
├── Security Group Module
├── ALB Module
└── App Stack Module
    ├── EC2 Instances (from Lab 2)
    ├── Security Groups
    └── Load Balancer (Production only)
```

## Module Structure
```plaintext
.
├── modules/
│   ├── alb/                    # Application Load Balancer Module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security-group/         # Security Group Module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── app-stack/             # Application Stack Module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── development/           # Development Environment
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── production/           # Production Environment
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Features

### 1. Environment-Specific Configurations
- Different instance counts per environment
- Environment-specific security rules
- Production-only load balancer
- Environment-based tagging

### 2. Module Composition
- Hierarchical module structure
- Inter-module dependencies
- Conditional resource creation
- Resource sharing between modules

### 3. Security Features
- Dynamic security group rules
- Environment-specific access controls
- SSL/TLS configuration for production
- Security group chaining

## Implementation Guide

### 1. Module Configuration

#### ALB Module
- Configures Application Load Balancer
- Manages target groups and listeners
- Handles SSL/TLS termination
- Implements health checks

#### Security Group Module
- Creates dynamic security group rules
- Manages ingress/egress rules
- Implements rule dependencies
- Provides flexible rule configuration

#### App Stack Module
- Orchestrates application components
- Manages instance deployment
- Handles load balancer integration
- Implements environment-specific logic

### 2. Environment Setup

#### Development Environment
```hcl
module "app_stack" {
  source = "../../modules/app-stack"

  environment     = "development"
  instance_count  = 1
  instance_type   = "t2.micro"
  enable_https    = false
}
```

#### Production Environment
```hcl
module "app_stack" {
  source = "../../modules/app-stack"

  environment     = "production"
  instance_count  = 2
  instance_type   = "t2.small"
  enable_https    = true
  certificate_arn = var.ssl_certificate_arn
}
```

## Best Practices

### 1. Module Design
- Keep modules focused and single-purpose
- Use consistent variable naming
- Implement proper validation
- Provide comprehensive documentation

### 2. Environment Management
- Use workspace-based isolation
- Implement proper state management
- Use environment-specific variables
- Maintain configuration consistency

### 3. Security Implementation
- Follow least privilege principle
- Implement proper encryption
- Use security group chaining
- Enable proper logging

## Troubleshooting Guide

### Common Issues

1. **Module Dependencies**
```bash
# Verify module outputs
terraform output -json

# Check module state
terraform state list | grep module
```

2. **Load Balancer Issues**
```bash
# Verify target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# Check listener configuration
aws elbv2 describe-listeners \
  --load-balancer-arn <alb-arn>
```

3. **Security Group Problems**
```bash
# Verify security group rules
aws ec2 describe-security-groups \
  --group-ids <security-group-id>

# Check security group associations
aws ec2 describe-network-interfaces \
  --filters Name=group-id,Values=<security-group-id>
```

## Validation Steps

### 1. Infrastructure Validation
```bash
# Verify all resources
terraform show

# Check specific module
terraform state show 'module.app_stack'
```

### 2. Application Testing
```bash
# Test load balancer
curl http://<alb-dns-name>

# Verify SSL (Production)
curl -k https://<alb-dns-name>
```

### 3. Security Validation
```bash
# Check security groups
terraform state show 'module.security_group'

# Verify ALB security
aws elbv2 describe-load-balancer-attributes \
  --load-balancer-arn <alb-arn>
```

## Clean Up
```bash
# Destroy environment-specific resources
terraform destroy -var-file=environments/development/terraform.tfvars

# Remove workspace
terraform workspace select default
terraform workspace delete development
```

## Additional Resources
- [Terraform Module Composition](https://www.terraform.io/docs/modules/composition.html)
- [AWS ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Security Group Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html)
``
```