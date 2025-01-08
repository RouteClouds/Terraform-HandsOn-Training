# Lab 1: Basic Terraform Commands

## Overview
Introduction to basic Terraform commands and S3 bucket creation.

## Files
- `main.tf` - Main configuration file
- `variables.tf` - Variable definitions
- `outputs.tf` - Output definitions
- `terraform.tfvars` - Variable values

## Prerequisites
- AWS CLI configured
- Terraform installed
- Basic understanding of S3

## Resources Created
1. Random string generator
2. S3 bucket with versioning
3. Resource tags

## Instructions
1. Initialize Terraform
2. Review and plan changes
3. Apply configuration
4. Verify resources
5. Clean up

## Validation Steps
- [ ] Terraform initialized successfully
- [ ] S3 bucket created
- [ ] Versioning enabled
- [ ] Tags applied correctly

## Troubleshooting Guide

### 1. Initialization Issues
- **Problem**: Provider download fails
  - Check internet connectivity
  - Verify provider version
  - Clear provider cache:
  ```bash
  rm -rf .terraform
  terraform init
  ```

- **Problem**: Version constraints
  - Verify Terraform version
  - Check provider compatibility
  - Update version constraints

### 2. S3 Bucket Issues
- **Problem**: Bucket creation fails
  - Check bucket name uniqueness
  - Verify region settings
  - Confirm IAM permissions

- **Problem**: Versioning configuration fails
  - Ensure bucket exists
  - Check bucket ownership
  - Verify versioning permissions

### Common Error Messages
```bash
# Provider Error
Error: Failed to query available provider packages
Solution: Check network connectivity and registry.terraform.io access

# Bucket Name Error
Error: Error creating S3 bucket: BucketAlreadyExists
Solution: Choose a different bucket name or use random string

# Permission Error
Error: Error creating S3 bucket: AccessDenied
Solution: Verify AWS credentials and IAM permissions
```

### Recovery Steps
1. Clean provider cache:
```bash
rm -rf .terraform
```

2. Reinitialize Terraform:
```bash
terraform init -upgrade
```

3. Force bucket recreation:
```bash
terraform taint aws_s3_bucket.demo
terraform apply
```

## Best Practices
1. Use unique bucket naming
2. Enable versioning by default
3. Implement proper tagging
4. Verify configurations before apply
5. Clean up resources after testing