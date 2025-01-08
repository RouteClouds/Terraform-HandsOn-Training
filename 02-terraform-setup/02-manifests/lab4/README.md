# Lab 4: Environment Workspace Setup

## Overview
This lab demonstrates how to set up a modular Terraform environment using workspaces and reusable modules. It implements a structured approach to managing multiple environments using a common infrastructure code base.

## Resources Created
- Modular VPC infrastructure
- Environment-specific configurations
- Reusable network components
- Multi-environment workspace setup

## Prerequisites
- Completed Labs 1-3
- Understanding of Terraform modules
- Knowledge of workspace concepts
- AWS CLI and proper permissions

## Directory Structure
```plaintext
lab4/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── staging/
│   └── prod/
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Configuration Files

### Environment Configuration (environments/dev/main.tf)
- Terraform configuration
- Provider settings
- Module references
- Backend configuration

### Module Configuration (modules/vpc/main.tf)
- VPC resource definitions
- Subnet configurations
- Network settings
- Reusable components

## Implementation Steps

1. Initialize Module Structure:
```bash
# Create directory structure
mkdir -p environments/{dev,staging,prod} modules/vpc
```

2. Configure Development Environment:
```bash
cd environments/dev
terraform init
terraform workspace new dev
```

3. Apply Configuration:
```bash
terraform plan
terraform apply
```

## Variable Definitions
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| aws_region | AWS region | us-east-1 | No |
| environment | Environment name | dev | No |
| vpc_cidr | VPC CIDR range | 10.0.0.0/16 | No |
| project_name | Project identifier | terraform-workspace | No |

## Module Usage
```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment  = var.environment
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}
```

## Workspace Management

### 1. Creating Workspaces
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

### 2. Switching Workspaces
```bash
terraform workspace select dev
```

### 3. Listing Workspaces
```bash
terraform workspace list
```

## Best Practices

1. Module Organization
   - Keep modules focused
   - Use consistent interfaces
   - Document dependencies
   - Version modules appropriately

2. Environment Management
   - Use consistent naming
   - Separate state files
   - Implement proper tagging
   - Document configurations

3. Code Reusability
   - Abstract common patterns
   - Use variables effectively
   - Maintain backwards compatibility
   - Document module usage

## Troubleshooting Guide

1. Module Issues
   - Verify module source path
   - Check variable definitions
   - Validate module versions
   - Review module dependencies

2. Workspace Problems
   - Confirm workspace selection
   - Verify state file location
   - Check backend configuration
   - Review workspace-specific variables

3. Environment Conflicts
   - Check resource naming
   - Verify CIDR ranges
   - Review tag conflicts
   - Validate dependencies

## Security Considerations

1. Access Control
   - Implement workspace isolation
   - Use environment-specific roles
   - Restrict module access
   - Enforce least privilege

2. Resource Isolation
   - Separate state files
   - Use unique identifiers
   - Implement proper tagging
   - Control network boundaries

## Maintenance and Operations

1. Module Updates
   - Version control modules
   - Test changes thoroughly
   - Document modifications
   - Maintain backwards compatibility

2. Environment Management
   - Regular state backups
   - Monitor resource usage
   - Update documentation
   - Review access controls

3. Cleanup Procedures
   - Remove unused workspaces
   - Clean up state files
   - Archive old versions
   - Document changes

## Additional Resources
- [Terraform Workspace Documentation](https://www.terraform.io/docs/language/state/workspaces.html)
- [Module Development Guide](https://www.terraform.io/docs/modules/index.html)
- [Best Practices for Modules](https://www.terraform.io/docs/modules/best-practices.html)

## Validation Checklist
- [ ] Module structure created
- [ ] Environments configured
- [ ] Workspaces established
- [ ] Resources deployed
- [ ] Documentation updated
- [ ] Tests completed 