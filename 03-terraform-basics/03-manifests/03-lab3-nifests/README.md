# Lab 3: Resource Dependencies

## Overview
Understanding and implementing resource dependencies in AWS infrastructure.

## Files
- `main.tf` - Infrastructure configuration
- `variables.tf` - Network and instance variables
- `outputs.tf` - Resource outputs
- `terraform.tfvars` - Variable values

## Prerequisites
- Completed Labs 1 and 2
- Understanding of AWS networking
- Knowledge of EC2 instances

## Resources Created
1. VPC with Internet Gateway
2. Public subnet with routing
3. Security group configuration
4. EC2 instance deployment

## Instructions
1. Review dependency structure
2. Plan infrastructure creation
3. Apply configuration in order
4. Validate connectivity
5. Test dependencies
6. Clean up resources

## Validation Steps
- [ ] VPC created successfully
- [ ] Internet Gateway attached
- [ ] Subnet routing configured
- [ ] Security group rules applied
- [ ] EC2 instance accessible
- [ ] Dependencies verified

## Troubleshooting Guide

### 1. VPC and Network Issues
- **Problem**: VPC creation fails
  - Check CIDR block overlap
  - Verify region settings
  - Confirm IAM permissions

- **Problem**: Internet Gateway won't attach
  - Ensure VPC exists
  - Check VPC state
  - Verify IGW resource dependencies

### 2. Subnet Configuration
- **Problem**: Subnet creation fails
  - Verify CIDR is within VPC range
  - Check availability zone
  - Confirm VPC exists and is ready

### 3. Security Group Issues
- **Problem**: Security group rules not applying
  - Check VPC reference
  - Verify CIDR notations
  - Confirm protocol settings

### 4. EC2 Instance Problems
- **Problem**: Instance launch fails
  - Verify AMI ID in region
  - Check subnet has internet access
  - Confirm security group allows traffic

### Common Error Messages
```bash
# VPC Dependency Error
Error: Error creating VPC: VPCLimitExceeded
Solution: Delete unused VPCs or request limit increase

# Subnet CIDR Error
Error: Error creating subnet: InvalidSubnet.Range
Solution: Verify CIDR is within VPC range

# Security Group Error
Error: Error creating Security Group: InvalidVPCID
Solution: Ensure VPC exists before creating security group
```

## Best Practices
1. Always verify resource dependencies
2. Use explicit dependencies when needed
3. Follow proper resource ordering
4. Implement proper error handling
5. Test infrastructure changes incrementally