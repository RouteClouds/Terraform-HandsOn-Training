# Lab 4: Meta-Arguments and Lifecycle

## Overview
Master resource meta-arguments and lifecycle configurations.

## Files
- `main.tf` - Resource configurations
- `variables.tf` - Meta-argument variables
- `outputs.tf` - Resource outputs
- `terraform.tfvars` - Variable values

## Prerequisites
- Completed Labs 1-3
- Understanding of resource creation
- Knowledge of Terraform functions

## Meta-Arguments
1. Count
   - Multiple resource creation
   - Index usage
   - Resource management

2. For_Each
   - Map iterations
   - Set usage
   - Dynamic creation

3. Lifecycle Rules
   - Create before destroy
   - Prevent destroy
   - Ignore changes

## Validation Steps
- [ ] Count resources created
- [ ] For_each working correctly
- [ ] Lifecycle rules applied
- [ ] Updates handling properly

## Best Practices
1. Use appropriate meta-arguments
2. Implement proper lifecycle rules
3. Handle updates gracefully
4. Document configurations 

## Troubleshooting Guide

### 1. Count Meta-Argument Issues
- **Problem**: Index out of bounds
  ```bash
  Error: Invalid index: index must be less than count value
  ```
  **Solution**:
  - Verify count value
  - Check index references
  - Update count calculation

- **Problem**: Count modification
  ```bash
  Error: Index change requires resource recreation
  ```
  **Solution**:
  - Plan count changes carefully
  - Use for_each instead if needed
  - Handle state migrations

### 2. For_Each Problems
- **Problem**: Invalid for_each argument
  ```bash
  Error: Invalid for_each argument
  ```
  **Solution**:
  - Verify map/set structure
  - Check variable types
  - Validate input values

### 3. Lifecycle Rule Issues
- **Problem**: Prevent_destroy blocks deletion
  ```bash
  Error: Resource has prevent_destroy lifecycle flag set
  ```
  **Solution**:
  - Remove prevent_destroy flag
  - Update lifecycle rules
  - Handle protected resources

### Recovery Steps
1. Check resource instances:
```bash
terraform state list | grep RESOURCE_TYPE
```

2. Inspect specific instance:
```bash
terraform state show 'RESOURCE_TYPE[0]'
```

3. Remove specific instance:
```bash
terraform state rm 'RESOURCE_TYPE[0]'
```

### Best Practices for Meta-Arguments
1. Choose between count and for_each carefully
2. Document lifecycle rules
3. Test scaling scenarios
4. Plan state changes