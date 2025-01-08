# Lab 5: Multiple Provider Configurations

## Overview
Working with multiple provider configurations and aliases.

## Files
- `main.tf` - Provider configurations
- `variables.tf` - Regional variables
- `outputs.tf` - Multi-region outputs
- `terraform.tfvars` - Variable values

## Prerequisites
- Completed Labs 1-4
- Multi-region AWS knowledge
- Advanced Terraform skills

## Provider Configurations
1. Primary Region
   - Default provider
   - Base configuration
   - Resource defaults

2. Secondary Regions
   - Provider aliases
   - Region-specific settings
   - Cross-region references

## Multi-Region Resources
1. VPC Setup
   - Regional VPCs
   - Network configuration
   - Cross-region connectivity

2. Compute Resources
   - Regional instances
   - Resource distribution
   - Cross-region dependencies

## Validation Steps
- [ ] Multiple providers configured
- [ ] Resources created in all regions
- [ ] Cross-region features working
- [ ] Proper provider references

## Best Practices
1. Use clear provider aliases
2. Implement regional tagging
3. Handle cross-region dependencies
4. Document regional configurations 

## Troubleshooting Guide

### 1. Multiple Provider Issues
- **Problem**: Provider alias not found
  ```bash
  Error: Provider configuration not present
  ```
  **Solution**:
  - Verify provider alias
  - Check provider block
  - Confirm provider reference

- **Problem**: Cross-region resource access
  ```bash
  Error: Reference to resource in different region
  ```
  **Solution**:
  - Use correct provider alias
  - Verify region settings
  - Check resource ARNs

### 2. Resource Distribution Problems
- **Problem**: Region-specific service unavailable
  ```bash
  Error: Service not available in region
  ```
  **Solution**:
  - Check service availability
  - Use alternative region
  - Update resource configuration

### 3. Cross-Region Dependencies
- **Problem**: Inter-region communication fails
  ```bash
  Error: Unable to establish connection between regions
  ```
  **Solution**:
  - Verify VPC peering
  - Check routing tables
  - Configure proper IAM permissions

### Recovery Steps
1. Validate provider configurations:
```bash
terraform providers
```

2. Check resources by region:
```bash
terraform state list | grep "aws.region1"
terraform state list | grep "aws.region2"
```

3. Clean up regional resources:
```bash
terraform destroy -target='module.region1'
terraform destroy -target='module.region2'
```

### Best Practices for Multi-Region
1. Use consistent naming across regions
2. Implement regional tags
3. Document provider configurations
4. Test failover scenarios