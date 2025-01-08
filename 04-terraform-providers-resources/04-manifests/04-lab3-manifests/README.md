# Lab 3: Resource Dependencies

## Overview
Understanding and implementing resource dependencies in AWS infrastructure.

## Files
- `main.tf` - Infrastructure configuration
- `variables.tf` - Network variables
- `outputs.tf` - Resource outputs
- `terraform.tfvars` - Variable values

## Prerequisites
- Completed Labs 1 and 2
- VPC knowledge
- Understanding of AWS networking

## Infrastructure Components
1. VPC Configuration
   - CIDR block
   - DNS settings
   - Network ACLs

2. Network Resources
   - Subnet creation
   - Internet Gateway
   - Route Tables

## Dependencies
1. Implicit Dependencies
   - Resource references
   - Attribute dependencies
   - Auto-detection

2. Explicit Dependencies
   - depends_on blocks
   - Dependency chains
   - Circular dependencies

## Validation Steps
- [ ] VPC created successfully
- [ ] Dependencies resolved correctly
- [ ] Network connectivity working
- [ ] Resources properly linked

## Troubleshooting Guide

### 1. VPC Configuration Issues
- **Problem**: CIDR block overlap
  ```bash
  Error: Error creating VPC: The CIDR '10.0.0.0/16' conflicts with another VPC
  ```
  **Solution**:
  - Check existing VPC CIDRs
  - Use different CIDR range
  - Verify CIDR calculations

- **Problem**: Resource limit exceeded
  ```bash
  Error: VPC quota exceeded
  ```
  **Solution**:
  - Check VPC limits in region
  - Delete unused VPCs
  - Request limit increase

### 2. Dependency Chain Issues
- **Problem**: Circular dependency detected
  ```bash
  Error: Cycle: aws_route_table -> aws_route -> aws_internet_gateway
  ```
  **Solution**:
  - Review resource dependencies
  - Restructure configuration
  - Use depends_on where needed

### 3. Network Configuration Problems
- **Problem**: Subnet creation fails
  ```bash
  Error: Invalid CIDR block: subnet size too large
  ```
  **Solution**:
  - Verify subnet CIDR
  - Check VPC CIDR range
  - Adjust subnet size

### Recovery Steps
1. Validate network configuration:
```bash
terraform validate
aws ec2 describe-vpcs
```

2. Check resource dependencies:
```bash
terraform graph | dot -Tsvg > graph.svg
```

3. Force resource recreation:
```bash
terraform destroy -target=aws_vpc.main
terraform apply
```

### Best Practices for Dependencies
1. Document dependency chains
2. Use explicit dependencies when unclear
3. Test infrastructure changes
4. Maintain clean state