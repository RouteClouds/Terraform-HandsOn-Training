# Lab 3: Variable Files and Precedence

## Overview
Learn to work with variable files and understand precedence order using AWS VPC infrastructure.

## Files
- `c1-versions.tf` - Provider and version configurations
- `c2-variables.tf` - Variable definitions
- `c3-vpc.tf` - VPC and networking resources
- `c4-outputs.tf` - Output configurations
- `terraform.tfvars` - Default variable values
- `prod.tfvars` - Production environment values

## Prerequisites
1. Completed Lab 2
2. Understanding of AWS VPC concepts
3. Knowledge of variable precedence in Terraform

## Lab Steps

### 1. Variable Files Structure
```hcl
# terraform.tfvars (Default values)
aws_region = "us-east-1"
environment = "dev"
vpc_cidr = "10.0.0.0/16"

# prod.tfvars (Production overrides)
environment = "prod"
vpc_cidr = "172.16.0.0/16"
```

### 2. Variable Precedence Order
1. Environment variables (TF_VAR_*)
2. terraform.tfvars
3. *.auto.tfvars (alphabetical order)
4. -var or -var-file (command line)

### 3. Testing Different Environments
```bash
# Development Environment
terraform plan

# Production Environment
terraform plan -var-file="prod.tfvars"

# Override with CLI
terraform plan -var="environment=staging"
```

## Execution Steps
```bash
# Test environment variables
export TF_VAR_environment="test"

# Validate configurations
terraform validate

# Plan with different var files
terraform plan -var-file="prod.tfvars"

# Apply configuration
terraform apply -var-file="prod.tfvars"
```

## Validation Checklist
- [ ] Default variables loaded correctly
- [ ] Production overrides working
- [ ] Environment variables recognized
- [ ] CLI variables taking precedence

## Common Issues and Solutions
1. Variable File Loading
   ```bash
   # Debug variable loading
   TF_LOG=DEBUG terraform plan
   ```

2. Precedence Conflicts
   ```bash
   # Check effective values
   terraform console
   > var.environment
   ```

3. CIDR Range Overlaps
   ```bash
   # Validate network ranges
   terraform plan -var-file="prod.tfvars"
   ```

## Troubleshooting Guide
1. File Loading Issues
   - Check file names and paths
   - Verify file permissions
   - Use absolute paths if needed

2. Value Override Problems
   - Check precedence order
   - Review all variable sources
   - Use `TF_LOG=TRACE` for detailed logs

3. Network Configuration
   - Validate CIDR ranges
   - Check subnet calculations
   - Verify availability zones