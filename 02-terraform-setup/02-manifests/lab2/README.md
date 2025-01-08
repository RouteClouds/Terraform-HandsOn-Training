# Lab 2: Development Environment Configuration

## Overview
This lab sets up a basic development environment infrastructure using AWS VPC and associated networking components. It demonstrates the creation of a basic network structure suitable for development workloads.

## Resources Created
- VPC with DNS support enabled
- Public subnet
- Network configurations
- Associated tags and identifiers

## Prerequisites
- Completed Lab 1
- AWS CLI configured with appropriate permissions
- Understanding of basic networking concepts
- Terraform CLI installed

## Configuration Files

### main.tf
Contains the core infrastructure configuration:
- VPC resource definition
- Subnet configuration
- DNS settings
- Tagging structure

### variables.tf
Defines network-related variables:
- AWS region settings
- CIDR block configurations
- Environment parameters
- Project naming

### outputs.tf
Provides comprehensive network information:
- VPC identifiers and details
- Subnet configurations
- Environment information
- Complete network state

## Usage

1. Initialize the working directory:
```bash
terraform init
```

2. Validate the configuration:
```bash
terraform validate
```

3. Review the execution plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Variable Definitions
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| aws_region | AWS region | us-east-1 | No |
| vpc_cidr | VPC CIDR block | 10.0.0.0/16 | No |
| subnet_cidr | Subnet CIDR block | 10.0.1.0/24 | No |
| environment | Environment name | dev | No |
| project_name | Project identifier | terraform-dev | No |

## Outputs
| Output | Description |
|--------|-------------|
| vpc_id | ID of the created VPC |
| vpc_cidr | CIDR block of the VPC |
| subnet_id | ID of the created subnet |
| vpc_details | Complete VPC configuration |
| environment_details | Environment information |

## Network Architecture
```plaintext
VPC (10.0.0.0/16)
└── Public Subnet (10.0.1.0/24)
    └── DNS Support Enabled
```

## Best Practices
1. Use meaningful CIDR ranges
2. Implement proper tagging
3. Follow naming conventions
4. Document network design
5. Use consistent environment names

## Troubleshooting
Common issues and solutions:

1. CIDR Range Conflicts
   - Solution: Modify CIDR blocks in variables.tf
   - Check existing VPC ranges

2. Subnet Creation Failures
   - Solution: Verify VPC CIDR compatibility
   - Check availability zone settings

3. DNS Configuration Issues
   - Solution: Verify DNS settings in VPC
   - Check enableDnsSupport parameter

## Security Considerations
1. Network Access Control
   - Implement proper CIDR ranges
   - Plan for security groups

2. Environment Isolation
   - Use separate VPCs for different environments
   - Implement network boundaries

## Maintenance
1. Regular Tasks:
   - Review network configurations
   - Update tags if needed
   - Verify DNS settings

2. Backup Considerations:
   - Document network configurations
   - Maintain state files
   - Version control all changes 