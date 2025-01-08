# Lab 2: State Operations and Manipulation

## Overview
This lab demonstrates various Terraform state operations including moving resources, importing existing resources, and handling state conflicts.

## Files
- `main.tf` - Main infrastructure configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output definitions
- `resource_import.tf` - Import configuration

## Usage

### 1. Initialize and Apply Base Configuration
```bash
terraform init -backend-config=backend.hcl
terraform apply
```

### 2. State Move Operations
```bash
# Rename a subnet resource
terraform state mv \
  'aws_subnet.subnets[0]' \
  'aws_subnet.primary'

# Move resource to different state file
terraform state mv \
  -state-out=../other_config/terraform.tfstate \
  'aws_subnet.subnets[1]' \
  'aws_subnet.secondary'
```

### 3. Import Existing Resource
```bash
# Import existing security group
terraform import \
  aws_security_group.imported \
  sg-1234567
```

### 4. State Operations
```bash
# List state resources
terraform state list

# Show resource details
terraform state show aws_vpc.main

# Remove resource from state
terraform state rm aws_route_table.main
```

## State Commands Reference
- `terraform state list` - List resources in state
- `terraform state show` - Show resource details
- `terraform state mv` - Move resources in state
- `terraform state rm` - Remove resources from state
- `terraform state pull` - Download remote state
- `terraform state push` - Upload state file
- `terraform import` - Import existing resources

## Notes
- Always backup state before operations
- Use state commands with caution
- Verify state after operations
- Document all state changes 