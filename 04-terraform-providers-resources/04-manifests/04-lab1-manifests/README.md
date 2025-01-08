# Lab 1: Provider Configuration and Authentication

## Overview
This lab focuses on configuring the AWS provider and implementing different authentication methods.

## Files
- `main.tf` - Provider and version configurations
- `variables.tf` - Variable definitions
- `outputs.tf` - Output configurations
- `terraform.tfvars` - Variable values

## Prerequisites
- AWS CLI installed and configured
- Terraform installed
- Basic understanding of AWS IAM

## Lab Steps
1. Provider Configuration
   - Configure AWS provider
   - Set version constraints
   - Define region settings

2. Authentication Methods
   - Static credentials (demo only)
   - Environment variables
   - Shared credentials file
   - IAM role authentication

## Validation Steps
- [ ] Provider successfully initialized
- [ ] Authentication working
- [ ] Version constraints applied
- [ ] Region correctly configured

## Common Issues
1. Authentication Failures
   - Check AWS credentials
   - Verify IAM permissions
   - Validate configuration

2. Version Conflicts
   - Check provider version
   - Verify Terraform version
   - Update constraints if needed

## Troubleshooting Guide

### 1. Provider Initialization Issues
- **Problem**: Provider download fails
  ```bash
  Error: Failed to query available provider packages
  ```
  **Solution**:
  - Check internet connectivity
  - Verify registry.terraform.io access
  - Clear provider cache: `rm -rf .terraform`

- **Problem**: Version constraints not met
  ```bash
  Error: Incompatible provider version
  ```
  **Solution**:
  - Update version constraints
  - Check Terraform version compatibility
  - Use `terraform init -upgrade`

### 2. Authentication Problems
- **Problem**: Invalid credentials
  ```bash
  Error: error configuring Terraform AWS Provider: no valid credential sources found
  ```
  **Solution**:
  - Verify AWS credentials file
  - Check environment variables
  - Validate IAM permissions

### 3. Region Configuration
- **Problem**: Region not available
  ```bash
  Error: error configuring Terraform AWS Provider: region not found
  ```
  **Solution**:
  - Verify region spelling
  - Check region availability
  - Confirm service availability in region

### Recovery Steps
1. Clean provider cache:
```bash
rm -rf .terraform
terraform init
```

2. Verify credentials:
```bash
aws configure list
aws sts get-caller-identity
```

3. Test provider configuration:
```bash
terraform validate
terraform plan
``` 