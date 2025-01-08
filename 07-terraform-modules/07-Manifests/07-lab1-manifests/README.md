# Lab 1: Basic Module Usage - AWS VPC Module

## Overview
This lab demonstrates how to use a public registry module (AWS VPC) with proper configuration and best practices.

## Module Source
- Registry: Terraform Registry
- Module: terraform-aws-modules/vpc/aws
- Version: 5.0.0

## Files Structure
plaintext
.
├── README.md
├── main.tf           # Main configuration with VPC module
├── variables.tf      # Input variables
├── outputs.tf        # Output definitions
└── backend.tf        # Backend configuration
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the plan:
```bash
terraform plan
```

3. Apply configuration:
```bash
terraform apply -auto-approve
```

## Configuration Details
- VPC CIDR: 10.0.0.0/16
- Public Subnets: 10.0.101.0/24, 10.0.102.0/24
- Private Subnets: 10.0.1.0/24, 10.0.2.0/24
- NAT Gateway: Enabled (Single NAT Gateway)
- DNS Support: Enabled

## Clean Up
```bash
terraform destroy -auto-approve
```
```