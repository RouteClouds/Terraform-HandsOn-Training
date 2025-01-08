# Lab 1: Basic Environment Setup

## Overview
This lab provides the initial setup for testing Terraform configurations with AWS. It creates a basic S3 bucket to verify AWS connectivity and Terraform functionality.

## Resources Created
- S3 Bucket with basic configuration
- Associated bucket tags for resource management

## Prerequisites
- AWS CLI installed and configured
- Terraform installed (version >= 1.0.0)
- Basic understanding of S3 service

## Configuration Files

### main.tf
Contains the primary configuration:
- AWS provider setup
- S3 bucket resource definition
- Basic tagging structure

### variables.tf
Defines all required variables:
- AWS region configuration
- Environment settings
- Project naming conventions
- AWS profile settings

### outputs.tf
Provides essential resource information:
- Bucket name and ARN
- Resource identifiers

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the plan:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Variable Definitions
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| aws_region | AWS region for deployment | us-east-1 | No |
| environment | Environment name | dev | No |
| project_name | Project identifier | terraform-setup | No |
| aws_profile | AWS credentials profile | default | No |

## Outputs
| Output | Description |
|--------|-------------|
| test_bucket_name | Name of created S3 bucket |
| test_bucket_arn | ARN of created S3 bucket |

## Best Practices
1. Always use meaningful tags
2. Follow naming conventions
3. Use version control
4. Review access permissions

## Troubleshooting
Common issues and solutions:
1. Bucket name conflicts
   - Solution: Modify project_name variable
2. Permission issues
   - Solution: Verify AWS credentials 