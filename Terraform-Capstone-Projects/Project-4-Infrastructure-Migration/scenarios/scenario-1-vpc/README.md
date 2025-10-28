# Scenario 1: VPC and Subnets Import

## 📋 Overview

**Complexity**: Beginner  
**Duration**: 1-2 hours  
**Resources**: VPC, Subnets, Route Tables, Internet Gateway

This scenario demonstrates how to import a manually-created VPC with all its networking components into Terraform management.

---

## 🎯 Learning Objectives

- Import VPC resources into Terraform
- Generate configuration from existing resources
- Validate imported configuration
- Understand resource dependencies during import

---

## 🏗️ Resources to Import

1. **VPC** - Main VPC (10.100.0.0/16)
2. **Internet Gateway** - IGW attached to VPC
3. **Public Subnets** - 2 public subnets in different AZs
4. **Private Subnets** - 2 private subnets in different AZs
5. **Route Table** - Public route table with IGW route
6. **Route Table Associations** - Associations for public subnets

---

## 📝 Step-by-Step Import Process

### Step 1: Get Resource IDs

First, get the IDs of existing resources:

```bash
cd ../../existing-infrastructure
terraform output
```

Note down the following IDs:
- `vpc_id`
- `internet_gateway_id`
- `public_subnet_1_id`
- `public_subnet_2_id`
- `private_subnet_1_id`
- `private_subnet_2_id`
- `public_route_table_id`

### Step 2: Initialize Terraform

```bash
cd ../scenarios/scenario-1-vpc/imported
terraform init
```

### Step 3: Import VPC

```bash
terraform import aws_vpc.main <vpc_id>
```

### Step 4: Import Internet Gateway

```bash
terraform import aws_internet_gateway.main <igw_id>
```

### Step 5: Import Subnets

```bash
terraform import 'aws_subnet.public[0]' <public_subnet_1_id>
terraform import 'aws_subnet.public[1]' <public_subnet_2_id>
terraform import 'aws_subnet.private[0]' <private_subnet_1_id>
terraform import 'aws_subnet.private[1]' <private_subnet_2_id>
```

### Step 6: Import Route Table

```bash
terraform import aws_route_table.public <route_table_id>
```

### Step 7: Import Route Table Associations

```bash
terraform import 'aws_route_table_association.public[0]' <association_1_id>
terraform import 'aws_route_table_association.public[1]' <association_2_id>
```

### Step 8: Validate Import

```bash
terraform plan
```

Expected output: `No changes. Your infrastructure matches the configuration.`

---

## 🔍 Verification Steps

### 1. Check State

```bash
terraform state list
```

Should show all imported resources.

### 2. Show Resource Details

```bash
terraform state show aws_vpc.main
```

### 3. Validate Configuration

```bash
terraform validate
```

### 4. Plan (No Changes)

```bash
terraform plan
```

Should show zero changes.

---

## 🛠️ Troubleshooting

### Issue: Import fails with "resource not found"

**Solution**: Verify the resource ID is correct:
```bash
aws ec2 describe-vpcs --vpc-ids <vpc_id>
```

### Issue: Plan shows changes after import

**Solution**: Adjust configuration to match existing resource attributes. Common mismatches:
- `enable_dns_hostnames`
- `enable_dns_support`
- `map_public_ip_on_launch`
- Tags

### Issue: Route table import fails

**Solution**: Import the route table first, then import associations separately.

---

## 📊 Import Order

Import resources in this order to respect dependencies:

1. VPC (no dependencies)
2. Internet Gateway (depends on VPC)
3. Subnets (depend on VPC)
4. Route Table (depends on VPC and IGW)
5. Route Table Associations (depend on subnets and route table)

---

## 🎓 Key Concepts

### Resource Addressing

For resources with `count` or `for_each`:
```bash
# Count-based
terraform import 'aws_subnet.public[0]' subnet-xxxxx

# For_each-based
terraform import 'aws_subnet.public["us-east-1a"]' subnet-xxxxx
```

### Configuration Generation

After import, you need to write the configuration. Tips:
1. Use `terraform state show` to see current attributes
2. Copy relevant attributes to your `.tf` file
3. Remove computed attributes (like `id`, `arn`)
4. Add required arguments

### Import Blocks (Terraform 1.5+)

Modern approach using import blocks:

```hcl
import {
  to = aws_vpc.main
  id = "vpc-xxxxx"
}

resource "aws_vpc" "main" {
  cidr_block = "10.100.0.0/16"
  # ... other attributes
}
```

Then run:
```bash
terraform plan -generate-config-out=generated.tf
```

---

## ✅ Success Criteria

- [ ] All VPC resources imported successfully
- [ ] `terraform plan` shows no changes
- [ ] `terraform state list` shows all resources
- [ ] Configuration is properly formatted
- [ ] All resources have appropriate tags

---

## 📝 Notes

- Always backup state before importing
- Import one resource at a time
- Verify each import before proceeding
- Document any configuration adjustments made

---

**Scenario Status**: Ready for Implementation  
**Last Updated**: October 27, 2025

