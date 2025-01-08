# Terraform Variables - Lab Manifests

## Overview
This directory contains all the lab configurations for the Terraform Variables topic.

## Lab Structure

### Lab 1: Basic Variable Usage
```plaintext
lab1/
├── c1-versions.tf      # Provider and version configurations
├── c2-variables.tf     # Basic variable definitions
├── c3-ec2-instance.tf  # EC2 instance resource
├── c4-outputs.tf       # Basic outputs
└── terraform.tfvars    # Variable values
```

### Lab 2: Variable Types and Validation
```plaintext
lab2/
├── c1-versions.tf         # Provider and version configurations
├── c2-variables.tf        # Complex variable types and validation
├── c3-security-groups.tf  # Security group with dynamic blocks
├── c4-ec2-instance.tf     # EC2 instances with count
├── c5-outputs.tf          # Output configurations
└── terraform.tfvars       # Variable values
```

### Lab 3: Variable Files and Precedence
```plaintext
lab3/
├── c1-versions.tf      # Provider and version configurations
├── c2-variables.tf     # Network variable definitions
├── c3-vpc.tf          # VPC and networking resources
├── c4-outputs.tf      # Network outputs
├── terraform.tfvars   # Default variable values
└── prod.tfvars        # Production environment values
```

### Lab 4: Sensitive Variables
```plaintext
lab4/
├── c1-versions.tf      # Provider and version configurations
├── c2-variables.tf     # Sensitive variable definitions
├── c3-rds.tf          # RDS and Secrets Manager resources
├── c4-outputs.tf      # Secure outputs
├── terraform.tfvars   # Non-sensitive values
├── secrets.tfvars     # Sensitive values (not committed)
└── .gitignore         # Git ignore patterns
```

## Common Configurations

### Provider Configuration (c1-versions.tf)
```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

### Variable Structure
- Basic variables (Lab 1)
- Complex types (Lab 2)
- File-based variables (Lab 3)
- Sensitive variables (Lab 4)

### Output Pattern
- Resource identifiers
- Resource attributes
- Computed values
- Sensitive outputs

## Usage Instructions

1. Navigate to specific lab directory
```bash
cd lab1/
```

2. Initialize Terraform
```bash
terraform init
```

3. Review and modify variables
```bash
# Edit terraform.tfvars or use -var-file
```

4. Apply configuration
```bash
terraform apply
```

## Security Notes
1. Never commit sensitive files
2. Use .gitignore properly
3. Secure state files
4. Follow least privilege principle 