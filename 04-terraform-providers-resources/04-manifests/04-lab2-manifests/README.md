# Lab 2: Resource Creation and Attributes

## Overview
Learn to create AWS resources and work with their attributes.

## Files
- `main.tf` - Resource configurations
- `variables.tf` - Resource variables
- `outputs.tf` - Resource outputs
- `terraform.tfvars` - Variable values

## Prerequisites
- Completed Lab 1
- Understanding of AWS services
- Basic Terraform knowledge

## Resources Created
1. S3 Bucket
   - Versioning enabled
   - Tags applied
   - Access configuration

2. IAM Role
   - Trust policy
   - Permission policy
   - Role relationships

3. Security Group
   - Inbound rules
   - Outbound rules
   - VPC association

## Validation Steps
- [ ] Resources created successfully
- [ ] Attributes accessible
- [ ] Tags properly applied
- [ ] Outputs displayed correctly

## Best Practices
1. Use meaningful names
2. Implement proper tagging
3. Follow security guidelines
4. Document configurations 

## Troubleshooting Guide

### 1. Resource Creation Issues
- **Problem**: S3 bucket creation fails
  ```bash
  Error: Error creating S3 bucket: BucketAlreadyExists
  ```
  **Solution**:
  - Use unique bucket names
  - Check existing buckets
  - Implement random suffix

- **Problem**: IAM role conflicts
  ```bash
  Error: Error creating IAM role: EntityAlreadyExists
  ```
  **Solution**:
  - Verify role name uniqueness
  - Check existing roles
  - Update role name

### 2. Attribute Reference Issues
- **Problem**: Invalid attribute reference
  ```bash
  Error: Reference to undeclared resource
  ```
  **Solution**:
  - Check resource names
  - Verify attribute exists
  - Confirm resource creation order

### 3. Tag Application Problems
- **Problem**: Invalid tag format
  ```bash
  Error: Invalid tag value
  ```
  **Solution**:
  - Check tag syntax
  - Verify tag values
  - Update tag format

### Recovery Steps
1. Validate resource configuration:
```bash
terraform validate
```

2. Check resource state:
```bash
terraform state list
terraform state show RESOURCE_NAME
```

3. Force resource recreation:
```bash
terraform taint RESOURCE_NAME
terraform apply
```