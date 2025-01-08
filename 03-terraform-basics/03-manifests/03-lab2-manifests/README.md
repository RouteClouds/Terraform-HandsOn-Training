# Lab 2: Variables and VPC

## Overview
Working with variables and creating VPC resources.

## Files
- `main.tf` - VPC configuration
- `variables.tf` - Network variables
- `outputs.tf` - Network outputs
- `terraform.tfvars` - Variable values

## Prerequisites
- Completed Lab 1
- Understanding of VPC concepts
- Knowledge of CIDR notation

## Resources Created
1. VPC
2. Public subnet
3. Resource tags

## Instructions
1. Review variable definitions
2. Plan VPC creation
3. Apply configuration
4. Validate network setup
5. Clean up resources

## Validation Steps
- [ ] VPC created successfully
- [ ] Subnet properly configured
- [ ] DNS settings enabled
- [ ] Tags applied correctly

## Troubleshooting Guide

### 1. Variable Issues
- **Problem**: Variable validation fails
  - Check variable types
  - Verify value constraints
  - Confirm variable definitions

- **Problem**: Variable interpolation errors
  - Check syntax
  - Verify variable exists
  - Confirm value type matches usage

### 2. VPC Configuration
- **Problem**: CIDR validation fails
  - Verify CIDR format
  - Check CIDR range
  - Confirm no overlapping ranges

- **Problem**: DNS settings issues
  - Check DNS flags
  - Verify VPC attributes
  - Confirm region support

### Common Error Messages
```bash
# Variable Type Error
Error: Invalid value for variable
Solution: Ensure value matches defined type constraints

# CIDR Error
Error: invalid CIDR address: "invalid-cidr"
Solution: Use valid CIDR notation (e.g., 10.0.0.0/16)

# VPC Creation Error
Error: Error creating VPC: InvalidVpcRange
Solution: Use valid VPC CIDR range
```

### Recovery Steps
1. Validate variable values:
```bash
terraform validate
```

2. Check variable definitions:
```bash
terraform console
> var.vpc_cidr
```

3. Format configuration:
```bash
terraform fmt
```

## Best Practices
1. Use clear variable names
2. Implement variable validation
3. Document variable usage
4. Use consistent CIDR ranges
5. Test variable combinations