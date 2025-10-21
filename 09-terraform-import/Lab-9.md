# Topic 9: Hands-On Labs - Terraform Import & State Manipulation

**Estimated Time**: 3-4 hours  
**Difficulty**: Intermediate  
**Prerequisites**: Topics 1-8 completed

---

## Lab Overview

This lab series covers three critical scenarios:
1. **Lab 9.1**: Import existing EC2 instance into Terraform
2. **Lab 9.2**: Migrate resources between state files
3. **Lab 9.3**: Recover from state file corruption

---

## Lab 9.1: Import Existing EC2 Instance

### Objective
Import an existing AWS EC2 instance into Terraform state and create matching configuration.

### Prerequisites
- AWS account with EC2 instance running
- AWS CLI configured
- Terraform installed
- IAM permissions for EC2 and state management

### Step 1: Identify Existing Resource

```bash
# List EC2 instances
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# Note the Instance ID (e.g., i-1234567890abcdef0)
```

### Step 2: Create Terraform Configuration

Create `main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "imported" {
  # Configuration will be populated after import
  tags = {
    Name = "imported-instance"
  }
}
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Import the Instance

```bash
terraform import aws_instance.imported i-1234567890abcdef0
```

### Step 5: Verify Import

```bash
# List state
terraform state list

# Show resource details
terraform state show aws_instance.imported

# Plan to verify no changes
terraform plan
```

### Step 6: Update Configuration

Update `main.tf` with actual resource attributes from state:

```hcl
resource "aws_instance" "imported" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "imported-instance"
  }
}
```

### Step 7: Verify Configuration

```bash
terraform plan
# Should show: No changes. Infrastructure is up-to-date.
```

---

## Lab 9.2: Migrate Resources Between State Files

### Objective
Move resources from one state file to another using state manipulation commands.

### Scenario
You have resources in `state-old` that need to move to `state-new`.

### Step 1: Create Two Workspaces

```bash
# Create workspaces
terraform workspace new state-old
terraform workspace new state-new

# Switch to state-old
terraform workspace select state-old
```

### Step 2: Create Resources in state-old

Create `main.tf`:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = { Name = "web-server" }
}

resource "aws_security_group" "web" {
  name = "web-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Step 3: Apply Configuration

```bash
terraform apply
```

### Step 4: Migrate Resources

```bash
# Move instance to new workspace
terraform state mv aws_instance.web aws_instance.web

# Switch to state-new
terraform workspace select state-new

# Verify resource is in new state
terraform state list
```

### Step 5: Verify Migration

```bash
# In state-new workspace
terraform state show aws_instance.web

# Plan should show no changes
terraform plan
```

---

## Lab 9.3: Recover from State File Corruption

### Objective
Recover from corrupted state file using backup and refresh.

### Step 1: Create Test Infrastructure

```bash
terraform apply
```

### Step 2: Simulate Corruption

```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.corrupted

# Corrupt the state file (for testing)
echo "corrupted data" > terraform.tfstate
```

### Step 3: Attempt Recovery

```bash
# Try to list resources (will fail)
terraform state list
# Error: Failed to read state

# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Verify recovery
terraform state list
terraform plan
```

### Step 4: Refresh State

```bash
# Refresh state from AWS
terraform refresh

# Verify state is current
terraform state show aws_instance.web
```

---

## Lab Verification Checklist

### Lab 9.1 Verification
- [ ] EC2 instance successfully imported
- [ ] `terraform state list` shows imported resource
- [ ] `terraform plan` shows no changes
- [ ] Configuration matches actual resource

### Lab 9.2 Verification
- [ ] Resources moved between workspaces
- [ ] Both workspaces have correct resources
- [ ] `terraform plan` shows no changes in both

### Lab 9.3 Verification
- [ ] State file successfully recovered
- [ ] Resources accessible after recovery
- [ ] `terraform plan` shows no changes

---

## Troubleshooting Guide

**Issue**: "Resource already exists in state"
- **Solution**: `terraform state rm aws_instance.imported`

**Issue**: "Resource not found in AWS"
- **Solution**: Verify resource ID with AWS CLI

**Issue**: "State file corrupted"
- **Solution**: Restore from `.backup` file

---

## Key Learnings

✅ Import brings existing resources under Terraform management  
✅ State manipulation requires careful planning  
✅ Always backup state before operations  
✅ Verify changes with `terraform plan`  
✅ Recovery procedures are essential for disaster scenarios  

---

**Lab Completion Time**: 3-4 hours  
**Difficulty**: Intermediate  
**Next**: Proceed to Topic 10 - Terraform Testing & Validation

