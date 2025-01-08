# Lab 1: Basic Infrastructure Setup

This lab demonstrates basic Infrastructure as Code concepts using Terraform.

## Resources Created
- VPC with basic networking setup

## Prerequisites
- AWS Account
- Terraform installed
- AWS CLI configured

## Usage
1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Variables
- aws_region: AWS region for deployment
- vpc_cidr: CIDR block for VPC
- environment: Environment name
- project_name: Project name 