# Lab 1: Basic Variable Usage

## Overview
Learn to work with basic input variables and outputs in Terraform using AWS EC2 instance.

## Files
- `c1-versions.tf` - Provider and version configurations
- `c2-variables.tf` - Variable definitions
- `c3-ec2-instance.tf` - EC2 instance resource
- `c4-outputs.tf` - Output configurations
- `terraform.tfvars` - Variable values

## Prerequisites
1. AWS CLI configured
2. Terraform installed (>= 1.0.0)
3. Basic understanding of EC2

## Lab Steps

### 1. Variable Definition
```hcl
# Define variables in c2-variables.tf
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
```

### 2. Resource Creation
```hcl
# Create EC2 instance using variables
resource "aws_instance" "my_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

### 3. Output Configuration
```hcl
# Define outputs
output "instance_public_ip" {
  value = aws_instance.my_ec2.public_ip
}
```

## Execution Steps
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan the changes
terraform plan

# Apply the configuration
terraform apply

# Verify outputs
terraform output
```

## Validation Checklist
- [ ] All variables properly defined
- [ ] EC2 instance created successfully
- [ ] Outputs displaying correctly
- [ ] Resource tags applied

## Common Issues and Solutions
1. Variable not defined
   ```bash
   terraform validate
   ```

2. Invalid variable type
   ```bash
   terraform console
   > var.instance_type
   ```

3. Resource creation failure
   ```bash
   terraform plan -debug
   ```