# Lab 2: Variable Types and Validation

## Overview
Master different variable types and implement validation rules using AWS EC2 and Security Groups.

## Files
- `c1-versions.tf` - Provider and version configurations
- `c2-variables.tf` - Complex variable definitions with validation
- `c3-security-groups.tf` - Security group with dynamic blocks
- `c4-ec2-instance.tf` - EC2 instances using count
- `c5-outputs.tf` - Output configurations
- `terraform.tfvars` - Variable values

## Prerequisites
1. Completed Lab 1
2. Understanding of variable types
3. Knowledge of AWS security groups

## Lab Steps

### 1. Complex Variable Types
```hcl
# Object type with validation
variable "instance_config" {
  type = object({
    instance_type = string
    environment   = string
    count        = number
  })
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.instance_config.environment)
    error_message = "Invalid environment specified."
  }
}
```

### 2. Dynamic Blocks
```hcl
# Security group with dynamic block
dynamic "ingress" {
  for_each = var.allowed_ports
  content {
    from_port = ingress.value
    to_port   = ingress.value
    protocol  = "tcp"
  }
}
```

### 3. Resource Count
```hcl
# Multiple instances using count
resource "aws_instance" "web_servers" {
  count = var.instance_config.count
  # ... configuration ...
}
```

## Execution Steps
```bash
# Validate configurations
terraform validate

# Test variable values
terraform console
> var.instance_config.environment

# Apply configuration
terraform apply
```

## Validation Checklist
- [ ] Complex types working correctly
- [ ] Validation rules enforced
- [ ] Dynamic blocks functioning
- [ ] Multiple instances created

## Common Issues and Solutions
1. Validation failures
   ```bash
   # Check validation rules
   terraform validate
   ```

2. Type constraints
   ```bash
   # Verify object structure
   terraform console
   > var.instance_config
   ```

3. Count issues
   ```bash
   # Check instance count
   terraform state list | grep aws_instance
   ``` 