# Terraform Commands Reference
# Project 1: Multi-Tier Web Application Infrastructure

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Initial Setup](#initial-setup)
4. [Core Workflow Commands](#core-workflow-commands)
5. [State Management Commands](#state-management-commands)
6. [Workspace Commands](#workspace-commands)
7. [Advanced Commands](#advanced-commands)
8. [AWS CLI Commands](#aws-cli-commands)
9. [Verification Commands](#verification-commands)
10. [Troubleshooting Commands](#troubleshooting-commands)
11. [Cleanup Commands](#cleanup-commands)
12. [Complete Deployment Example](#complete-deployment-example)

---

## OVERVIEW

This document provides a comprehensive reference for all Terraform and AWS CLI commands used in Project 1. Each command includes:
- **Syntax**: Command structure
- **Description**: What the command does
- **Options**: Available flags and parameters
- **Examples**: Real-world usage
- **Output**: Expected results
- **Use Cases**: When to use the command

---

## PREREQUISITES

### Required Tools

**Terraform**:
```bash
# Check Terraform version
terraform version

# Expected output:
# Terraform v1.13.0
# on linux_amd64
```

**AWS CLI**:
```bash
# Check AWS CLI version
aws --version

# Expected output:
# aws-cli/2.13.0 Python/3.11.4 Linux/5.15.0 exe/x86_64.ubuntu.22
```

**Git**:
```bash
# Check Git version
git --version

# Expected output:
# git version 2.40.0
```

### AWS Credentials

**Configure AWS CLI**:
```bash
# Interactive configuration
aws configure

# Prompts:
# AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region name [None]: us-east-1
# Default output format [None]: json
```

**Verify Credentials**:
```bash
# Get caller identity
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDAI...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/username"
# }
```

**Using IAM Role** (Recommended for EC2):
```bash
# No configuration needed
# EC2 instance uses attached IAM role
```

**Using Environment Variables**:
```bash
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## INITIAL SETUP

### 1. Clone Repository

```bash
# Clone the repository
git clone <repository-url>
cd Terraform-Capstone-Projects/Project-1-Multi-Tier-Web-Application
```

### 2. Create S3 Backend

**Create S3 Bucket**:
```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket terraform-state-capstone-projects \
  --region us-east-1

# Expected output:
# {
#     "Location": "/terraform-state-capstone-projects"
# }
```

**Enable Versioning**:
```bash
# Enable versioning on state bucket
aws s3api put-bucket-versioning \
  --bucket terraform-state-capstone-projects \
  --versioning-configuration Status=Enabled

# No output on success
```

**Enable Encryption**:
```bash
# Enable default encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-capstone-projects \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# No output on success
```

**Block Public Access**:
```bash
# Block all public access
aws s3api put-public-access-block \
  --bucket terraform-state-capstone-projects \
  --public-access-block-configuration \
    BlockPublicAcls=true,\
IgnorePublicAcls=true,\
BlockPublicPolicy=true,\
RestrictPublicBuckets=true

# No output on success
```

### 3. Create DynamoDB Table

```bash
# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

# Expected output:
# {
#     "TableDescription": {
#         "TableName": "terraform-state-lock",
#         "TableStatus": "CREATING",
#         ...
#     }
# }
```

**Verify Table**:
```bash
# Check table status
aws dynamodb describe-table \
  --table-name terraform-state-lock \
  --query 'Table.TableStatus' \
  --output text

# Expected output:
# ACTIVE
```

### 4. Review Configuration

```bash
# Navigate to terraform manifests
cd terraform-manifests

# List all Terraform files
ls -la *.tf

# Expected output:
# providers.tf
# variables.tf
# data.tf
# locals.tf
# vpc.tf
# security.tf
# compute.tf
# alb.tf
# rds.tf
# s3.tf
# cloudfront.tf
# route53.tf
# monitoring.tf
# outputs.tf
```

### 5. Customize Variables

```bash
# Edit terraform.tfvars
nano terraform.tfvars

# Update values:
# - aws_region
# - environment
# - project_name
# - db_password (IMPORTANT!)
# - domain_name (optional)
# - alarm_email (optional)
```

---

## CORE WORKFLOW COMMANDS

### terraform init

**Purpose**: Initialize Terraform working directory

**Syntax**:
```bash
terraform init [options]
```

**Basic Usage**:
```bash
# Initialize directory
terraform init

# Expected output:
# Initializing the backend...
# Initializing provider plugins...
# - Finding hashicorp/aws versions matching "~> 6.12.0"...
# - Installing hashicorp/aws v6.12.0...
# Terraform has been successfully initialized!
```

**Common Options**:

**Upgrade Providers**:
```bash
# Upgrade to latest allowed version
terraform init -upgrade

# Output shows version changes:
# - Installed hashicorp/aws v6.12.1 (was v6.12.0)
```

**Reconfigure Backend**:
```bash
# Reconfigure backend (e.g., after changing backend config)
terraform init -reconfigure

# Prompts to migrate state if needed
```

**Skip Backend Initialization**:
```bash
# Initialize without backend
terraform init -backend=false

# Useful for validation only
```

**Migrate State**:
```bash
# Migrate state to new backend
terraform init -migrate-state

# Prompts to copy existing state
```

**Get Plugins Only**:
```bash
# Download plugins without backend init
terraform init -get-plugins=true -backend=false
```

**Output Files Created**:
```bash
# Check created files
ls -la

# Expected files:
# .terraform/          # Provider plugins
# .terraform.lock.hcl  # Dependency lock file
```

---

### terraform validate

**Purpose**: Validate configuration syntax

**Syntax**:
```bash
terraform validate [options]
```

**Basic Usage**:
```bash
# Validate configuration
terraform validate

# Expected output (success):
# Success! The configuration is valid.

# Expected output (error):
# Error: Unsupported argument
#   on vpc.tf line 10:
#   10:   invalid_argument = "value"
```

**With JSON Output**:
```bash
# JSON format output
terraform validate -json

# Expected output:
# {
#   "valid": true,
#   "error_count": 0,
#   "warning_count": 0
# }
```

**Use Cases**:
- Pre-commit hooks
- CI/CD pipelines
- Quick syntax check
- Before planning

**Example in CI/CD**:
```bash
#!/bin/bash
terraform init -backend=false
terraform validate
if [ $? -eq 0 ]; then
  echo "Validation passed"
else
  echo "Validation failed"
  exit 1
fi
```

---

### terraform fmt

**Purpose**: Format configuration files

**Syntax**:
```bash
terraform fmt [options] [directory]
```

**Basic Usage**:
```bash
# Format all files in current directory
terraform fmt

# Expected output:
# vpc.tf
# compute.tf
# (Lists modified files)
```

**Check Without Modifying**:
```bash
# Check if files need formatting
terraform fmt -check

# Exit code 0: No changes needed
# Exit code 3: Files need formatting

# Expected output:
# vpc.tf
# compute.tf
```

**Recursive Formatting**:
```bash
# Format all subdirectories
terraform fmt -recursive

# Formats all .tf files in tree
```

**Show Diff**:
```bash
# Show what would change
terraform fmt -diff

# Expected output:
# --- old/vpc.tf
# +++ new/vpc.tf
# @@ -1,3 +1,3 @@
# -resource "aws_vpc" "main"{
# +resource "aws_vpc" "main" {
```

**Use Cases**:
- Pre-commit hooks
- Code reviews
- Maintain consistency
- Team collaboration

**Pre-commit Hook**:
```bash
# .git/hooks/pre-commit
#!/bin/bash
terraform fmt -check -recursive
if [ $? -ne 0 ]; then
  echo "Run 'terraform fmt -recursive' to format files"
  exit 1
fi
```

---

### terraform plan

**Purpose**: Create execution plan

**Syntax**:
```bash
terraform plan [options]
```

**Basic Usage**:
```bash
# Create plan
terraform plan

# Expected output:
# Terraform will perform the following actions:
#
#   # aws_vpc.main will be created
#   + resource "aws_vpc" "main" {
#       + cidr_block = "10.0.0.0/16"
#       ...
#     }
#
# Plan: 45 to add, 0 to change, 0 to destroy.
```

**Save Plan to File**:
```bash
# Save plan for later apply
terraform plan -out=tfplan

# Expected output:
# ...
# Saved the plan to: tfplan
```

**Pass Variables**:
```bash
# Pass single variable
terraform plan -var="environment=prod"

# Pass multiple variables
terraform plan \
  -var="environment=prod" \
  -var="instance_type=t3.small"

# Use variable file
terraform plan -var-file="prod.tfvars"
```

**Target Specific Resources**:
```bash
# Plan only VPC changes
terraform plan -target=aws_vpc.main

# Plan multiple resources
terraform plan \
  -target=aws_vpc.main \
  -target=aws_subnet.public
```

**Refresh State**:
```bash
# Refresh state before planning
terraform plan -refresh=true

# Skip refresh (faster)
terraform plan -refresh=false
```

**Detailed Exit Codes**:
```bash
# Run plan and check exit code
terraform plan -detailed-exitcode

# Exit codes:
# 0: No changes
# 1: Error
# 2: Changes present
```

**JSON Output**:
```bash
# JSON format (for automation)
terraform plan -json

# Pipe to jq for parsing
terraform plan -json | jq '.resource_changes'
```

**Understanding Plan Output**:

**Symbols**:
- `+` : Resource will be created
- `-` : Resource will be destroyed
- `~` : Resource will be updated in-place
- `-/+` : Resource will be destroyed and recreated
- `<=` : Resource will be read during apply

**Example Output**:
```
Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                    = "ami-12345"
      + instance_type          = "t3.micro"
      + subnet_id              = (known after apply)
      ...
    }

  # aws_security_group.alb will be updated in-place
  ~ resource "aws_security_group" "alb" {
        id          = "sg-12345"
      ~ ingress     = [
          + {
              from_port   = 443
              to_port     = 443
              protocol    = "tcp"
              cidr_blocks = ["0.0.0.0/0"]
            },
        ]
    }

Plan: 1 to add, 1 to change, 0 to destroy.
```

---

### terraform apply

**Purpose**: Apply configuration changes

**Syntax**:
```bash
terraform apply [options] [plan_file]
```

**Basic Usage**:
```bash
# Apply with confirmation prompt
terraform apply

# Expected output:
# ...
# Plan: 45 to add, 0 to change, 0 to destroy.
#
# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
#
#   Enter a value: yes
#
# aws_vpc.main: Creating...
# aws_vpc.main: Creation complete after 2s [id=vpc-12345]
# ...
# Apply complete! Resources: 45 added, 0 changed, 0 destroyed.
```

**Auto-Approve** (Use with caution):
```bash
# Skip confirmation prompt
terraform apply -auto-approve

# Useful for automation, but dangerous!
```

**Apply Saved Plan**:
```bash
# Apply previously saved plan
terraform plan -out=tfplan
terraform apply tfplan

# No confirmation prompt needed
```

**Pass Variables**:
```bash
# Pass variables during apply
terraform apply -var="environment=prod"

# Use variable file
terraform apply -var-file="prod.tfvars"
```

**Target Specific Resources**:
```bash
# Apply only VPC
terraform apply -target=aws_vpc.main

# Apply multiple resources
terraform apply \
  -target=aws_vpc.main \
  -target=aws_subnet.public
```

**Parallelism**:
```bash
# Control parallel resource operations (default: 10)
terraform apply -parallelism=5

# Useful for rate-limited APIs
```

**Replace Resource**:
```bash
# Force replacement of resource
terraform apply -replace=aws_instance.web

# Destroys and recreates resource
```

**Refresh Only**:
```bash
# Update state without changes
terraform apply -refresh-only

# Useful after manual changes
```

**JSON Output**:
```bash
# JSON format output
terraform apply -json

# Useful for parsing in scripts
```

**Understanding Apply Output**:

**Progress Indicators**:
```
aws_vpc.main: Creating...
aws_vpc.main: Still creating... [10s elapsed]
aws_vpc.main: Creation complete after 12s [id=vpc-12345]
```

**Completion Summary**:
```
Apply complete! Resources: 45 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = "webapp-dev-alb-123456789.us-east-1.elb.amazonaws.com"
vpc_id = "vpc-12345"
```

---

### terraform destroy

**Purpose**: Destroy infrastructure

**Syntax**:
```bash
terraform destroy [options]
```

**Basic Usage**:
```bash
# Destroy all resources
terraform destroy

# Expected output:
# ...
# Plan: 0 to add, 0 to change, 45 to destroy.
#
# Do you really want to destroy all resources?
#   Terraform will destroy all your managed infrastructure.
#   There is no undo. Only 'yes' will be accepted to confirm.
#
#   Enter a value: yes
#
# aws_instance.web: Destroying... [id=i-12345]
# aws_instance.web: Destruction complete after 30s
# ...
# Destroy complete! Resources: 45 destroyed.
```

**Auto-Approve** (Use with extreme caution):
```bash
# Skip confirmation prompt
terraform destroy -auto-approve

# DANGEROUS! No confirmation!
```

**Target Specific Resources**:
```bash
# Destroy only specific resource
terraform destroy -target=aws_instance.web

# Destroy multiple resources
terraform destroy \
  -target=aws_instance.web \
  -target=aws_security_group.web
```

**Pass Variables**:
```bash
# Pass variables during destroy
terraform destroy -var="environment=dev"
```

**Dry Run**:
```bash
# See what would be destroyed
terraform plan -destroy

# Shows destruction plan without executing
```

**Destroy Order**:
- Terraform destroys resources in reverse dependency order
- Dependent resources destroyed first
- Independent resources destroyed in parallel

**Example Destroy Order**:
```
1. EC2 instances
2. Auto Scaling Group
3. Launch Template
4. Target Group
5. Load Balancer
6. RDS Instance
7. Subnets
8. Route Tables
9. NAT Gateways
10. Internet Gateway
11. VPC
```

---

## STATE MANAGEMENT COMMANDS

### terraform state list

**Purpose**: List resources in state

**Syntax**:
```bash
terraform state list [options] [address]
```

**Basic Usage**:
```bash
# List all resources
terraform state list

# Expected output:
# aws_vpc.main
# aws_subnet.public[0]
# aws_subnet.public[1]
# aws_subnet.public[2]
# aws_subnet.private[0]
# aws_subnet.private[1]
# aws_subnet.private[2]
# aws_internet_gateway.main
# ...
```

**Filter by Resource Type**:
```bash
# List only subnets
terraform state list | grep aws_subnet

# Expected output:
# aws_subnet.public[0]
# aws_subnet.public[1]
# aws_subnet.public[2]
# aws_subnet.private[0]
# aws_subnet.private[1]
# aws_subnet.private[2]
```

**Filter by Name**:
```bash
# List resources matching pattern
terraform state list aws_subnet.public

# Expected output:
# aws_subnet.public[0]
# aws_subnet.public[1]
# aws_subnet.public[2]
```

**Count Resources**:
```bash
# Count total resources
terraform state list | wc -l

# Expected output:
# 45
```

---

### terraform state show

**Purpose**: Show resource details

**Syntax**:
```bash
terraform state show [options] address
```

**Basic Usage**:
```bash
# Show VPC details
terraform state show aws_vpc.main

# Expected output:
# # aws_vpc.main:
# resource "aws_vpc" "main" {
#     arn                              = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-12345"
#     cidr_block                       = "10.0.0.0/16"
#     enable_dns_hostnames             = true
#     enable_dns_support               = true
#     id                               = "vpc-12345"
#     ...
# }
```

**Show Specific Resource from Count**:
```bash
# Show first public subnet
terraform state show 'aws_subnet.public[0]'

# Note: Quotes needed for brackets
```

**JSON Output**:
```bash
# JSON format
terraform state show -json aws_vpc.main

# Pipe to jq for parsing
terraform state show -json aws_vpc.main | jq '.values.id'
```

---

### terraform state mv

**Purpose**: Move/rename resources in state

**Syntax**:
```bash
terraform state mv [options] source destination
```

**Rename Resource**:
```bash
# Rename resource
terraform state mv aws_instance.web aws_instance.app

# Expected output:
# Move "aws_instance.web" to "aws_instance.app"
# Successfully moved 1 object(s).
```

**Move to Module**:
```bash
# Move resource to module
terraform state mv aws_vpc.main module.network.aws_vpc.main
```

**Move from Module**:
```bash
# Move resource from module
terraform state mv module.network.aws_vpc.main aws_vpc.main
```

**Move with Count**:
```bash
# Move indexed resource
terraform state mv 'aws_subnet.public[0]' 'aws_subnet.web[0]'
```

**Dry Run**:
```bash
# Preview move without executing
terraform state mv -dry-run aws_instance.web aws_instance.app
```

---

### terraform state rm

**Purpose**: Remove resources from state

**Syntax**:
```bash
terraform state rm [options] address
```

**Remove Single Resource**:
```bash
# Remove resource from state
terraform state rm aws_instance.web

# Expected output:
# Removed aws_instance.web
# Successfully removed 1 resource instance(s).
```

**Remove Multiple Resources**:
```bash
# Remove multiple resources
terraform state rm aws_instance.web aws_instance.app

# Remove all subnets
terraform state rm 'aws_subnet.public[0]' 'aws_subnet.public[1]' 'aws_subnet.public[2]'
```

**Remove Module**:
```bash
# Remove entire module
terraform state rm module.network
```

**Dry Run**:
```bash
# Preview removal
terraform state rm -dry-run aws_instance.web
```

**Use Cases**:
- Resource managed outside Terraform
- Import failed, need to retry
- Resource deleted manually
- Moving to different state file

**Warning**: Resource still exists in AWS, only removed from state!

---

### terraform state pull

**Purpose**: Download remote state

**Syntax**:
```bash
terraform state pull > terraform.tfstate
```

**Basic Usage**:
```bash
# Download state file
terraform state pull > backup.tfstate

# View state
cat backup.tfstate | jq '.'
```

**Use Cases**:
- Backup state file
- Inspect state manually
- Migrate state
- Troubleshooting

---

### terraform state push

**Purpose**: Upload local state to remote

**Syntax**:
```bash
terraform state push [options] path
```

**Basic Usage**:
```bash
# Upload state file
terraform state push terraform.tfstate

# Expected output:
# Successfully pushed state to remote backend
```

**Force Push** (Use with caution):
```bash
# Force push (ignore lineage)
terraform state push -force terraform.tfstate

# DANGEROUS! Can cause state conflicts
```

**Use Cases**:
- Restore from backup
- Migrate state
- Fix corrupted state
- Emergency recovery

**Warning**: Can cause state conflicts if not careful!

---

### terraform state replace-provider

**Purpose**: Replace provider in state

**Syntax**:
```bash
terraform state replace-provider [options] from to
```

**Basic Usage**:
```bash
# Replace provider
terraform state replace-provider \
  registry.terraform.io/hashicorp/aws \
  registry.terraform.io/hashicorp/aws

# Use case: Provider moved to new namespace
```

---

## WORKSPACE COMMANDS

### terraform workspace list

**Purpose**: List workspaces

**Syntax**:
```bash
terraform workspace list
```

**Basic Usage**:
```bash
# List all workspaces
terraform workspace list

# Expected output:
#   default
# * dev
#   staging
#   prod
#
# (* indicates current workspace)
```

---

### terraform workspace new

**Purpose**: Create new workspace

**Syntax**:
```bash
terraform workspace new [options] name
```

**Basic Usage**:
```bash
# Create and switch to new workspace
terraform workspace new dev

# Expected output:
# Created and switched to workspace "dev"!
```

**Create Without Switching**:
```bash
# Create workspace but don't switch
terraform workspace new -lock=false staging
```

---

### terraform workspace select

**Purpose**: Switch workspace

**Syntax**:
```bash
terraform workspace select name
```

**Basic Usage**:
```bash
# Switch to workspace
terraform workspace select prod

# Expected output:
# Switched to workspace "prod".
```

---

### terraform workspace show

**Purpose**: Show current workspace

**Syntax**:
```bash
terraform workspace show
```

**Basic Usage**:
```bash
# Show current workspace
terraform workspace show

# Expected output:
# dev
```

**Use in Scripts**:
```bash
# Get current workspace
WORKSPACE=$(terraform workspace show)
echo "Current workspace: $WORKSPACE"
```

---

### terraform workspace delete

**Purpose**: Delete workspace

**Syntax**:
```bash
terraform workspace delete name
```

**Basic Usage**:
```bash
# Delete workspace
terraform workspace delete dev

# Expected output:
# Deleted workspace "dev"!
```

**Force Delete** (with resources):
```bash
# Force delete (dangerous!)
terraform workspace delete -force dev

# Deletes workspace even if resources exist
```

**Cannot Delete**:
- Current workspace
- Default workspace

---

## ADVANCED COMMANDS

### terraform import

**Purpose**: Import existing resources

**Syntax**:
```bash
terraform import [options] address id
```

**Import VPC**:
```bash
# Import existing VPC
terraform import aws_vpc.main vpc-12345

# Expected output:
# aws_vpc.main: Importing from ID "vpc-12345"...
# aws_vpc.main: Import prepared!
# aws_vpc.main: Import complete!
```

**Import EC2 Instance**:
```bash
# Import EC2 instance
terraform import aws_instance.web i-12345

# Import with count
terraform import 'aws_instance.web[0]' i-12345
```

**Import Process**:
1. Write resource block (without arguments)
2. Run terraform import
3. Run terraform plan
4. Fill in missing arguments
5. Run terraform plan again (should show no changes)

**Example**:
```hcl
# 1. Write empty resource block
resource "aws_vpc" "main" {
  # Will be populated after import
}
```

```bash
# 2. Import resource
terraform import aws_vpc.main vpc-12345

# 3. Run plan to see what's missing
terraform plan

# 4. Add missing arguments
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
#   ...
# }

# 5. Verify no changes
terraform plan
# Should show: No changes. Your infrastructure matches the configuration.
```

---

### terraform taint

**Purpose**: Mark resource for recreation (deprecated in Terraform 0.15.2+)

**Syntax**:
```bash
terraform taint address
```

**Basic Usage**:
```bash
# Taint resource (deprecated)
terraform taint aws_instance.web

# Use this instead:
terraform apply -replace=aws_instance.web
```

---

### terraform untaint

**Purpose**: Remove taint from resource (deprecated)

**Syntax**:
```bash
terraform untaint address
```

**Note**: Use `terraform apply -refresh-only` instead

---

### terraform refresh

**Purpose**: Update state from real infrastructure (deprecated)

**Syntax**:
```bash
terraform refresh
```

**Use Instead**:
```bash
# Refresh state
terraform apply -refresh-only

# Or during plan
terraform plan -refresh=true
```

---

### terraform graph

**Purpose**: Generate dependency graph

**Syntax**:
```bash
terraform graph [options]
```

**Basic Usage**:
```bash
# Generate graph
terraform graph

# Expected output: DOT format graph
```

**Generate PNG**:
```bash
# Requires graphviz
sudo apt-get install graphviz

# Generate PNG image
terraform graph | dot -Tpng > graph.png

# View graph
xdg-open graph.png
```

**Generate SVG**:
```bash
# Generate SVG (scalable)
terraform graph | dot -Tsvg > graph.svg
```

**Filter Graph**:
```bash
# Graph for specific module
terraform graph -module=network
```

---

### terraform console

**Purpose**: Interactive console for expressions

**Syntax**:
```bash
terraform console [options]
```

**Basic Usage**:
```bash
# Start console
terraform console

# Expected prompt:
# >
```

**Test Expressions**:
```hcl
# In console
> var.vpc_cidr
"10.0.0.0/16"

> length(var.availability_zones)
3

> aws_vpc.main.id
"vpc-12345"

> local.name_prefix
"webapp-dev"
```

**Test Functions**:
```hcl
> format("%s-%s", "webapp", "dev")
"webapp-dev"

> cidrsubnet("10.0.0.0/16", 8, 1)
"10.0.1.0/24"

> merge({a = "1"}, {b = "2"})
{
  "a" = "1"
  "b" = "2"
}
```

**Exit Console**:
```hcl
> exit
# Or Ctrl+D
```

---

### terraform providers

**Purpose**: Show provider requirements

**Syntax**:
```bash
terraform providers [options]
```

**Basic Usage**:
```bash
# List providers
terraform providers

# Expected output:
# Providers required by configuration:
# .
# ├── provider[registry.terraform.io/hashicorp/aws] ~> 6.12.0
# 
# Providers required by state:
#     provider[registry.terraform.io/hashicorp/aws]
```

**Show Provider Schema**:
```bash
# Show provider schema
terraform providers schema -json | jq '.'

# Shows all resources and data sources
```

---

### terraform version

**Purpose**: Show Terraform version

**Syntax**:
```bash
terraform version
```

**Basic Usage**:
```bash
# Show version
terraform version

# Expected output:
# Terraform v1.13.0
# on linux_amd64
# + provider registry.terraform.io/hashicorp/aws v6.12.0
```

**JSON Output**:
```bash
# JSON format
terraform version -json

# Expected output:
# {
#   "terraform_version": "1.13.0",
#   "platform": "linux_amd64",
#   "provider_selections": {
#     "registry.terraform.io/hashicorp/aws": "6.12.0"
#   }
# }
```

---

## AWS CLI COMMANDS

### Verify Resources

**VPC**:
```bash
# List VPCs
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=webapp-dev-vpc" \
  --query 'Vpcs[*].[VpcId,CidrBlock,State]' \
  --output table

# Expected output:
# --------------------------------
# |        DescribeVpcs          |
# +-------------+----------------+
# |  vpc-12345  |  10.0.0.0/16  |  available  |
# +-------------+----------------+
```

**Subnets**:
```bash
# List subnets
aws ec2 describe-subnets \
  --filters "Name=tag:Project,Values=webapp" \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone]' \
  --output table
```

**EC2 Instances**:
```bash
# List instances
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=webapp" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress]' \
  --output table
```

**Load Balancer**:
```bash
# List ALBs
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[*].[LoadBalancerName,DNSName,State.Code]' \
  --output table
```

**RDS Instance**:
```bash
# List RDS instances
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' \
  --output table
```

**S3 Buckets**:
```bash
# List S3 buckets
aws s3 ls

# List bucket contents
aws s3 ls s3://webapp-dev-static-assets/
```

**CloudFront Distributions**:
```bash
# List distributions
aws cloudfront list-distributions \
  --query 'DistributionList.Items[*].[Id,DomainName,Status]' \
  --output table
```

---

## VERIFICATION COMMANDS

### Health Checks

**ALB Health**:
```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test ALB endpoint
curl -I http://$ALB_DNS

# Expected output:
# HTTP/1.1 200 OK
# ...
```

**Application Health**:
```bash
# Test health endpoint
curl http://$ALB_DNS/health

# Expected output:
# OK
```

**Database Connectivity**:
```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Test connection (requires psql)
psql -h $RDS_ENDPOINT -U admin -d webapp -c "SELECT version();"
```

**CloudFront**:
```bash
# Get CloudFront domain
CF_DOMAIN=$(terraform output -raw cloudfront_domain_name)

# Test CloudFront
curl -I https://$CF_DOMAIN

# Expected output:
# HTTP/2 200
# x-cache: Hit from cloudfront
# ...
```

### Target Health

**Check Target Health**:
```bash
# Get target group ARN
TG_ARN=$(aws elbv2 describe-target-groups \
  --names webapp-dev-tg \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]' \
  --output table

# Expected output:
# --------------------------------
# |  DescribeTargetHealth        |
# +-------------+----------------+
# |  i-12345    |  healthy       |
# |  i-67890    |  healthy       |
# +-------------+----------------+
```

### CloudWatch Logs

**View Application Logs**:
```bash
# List log streams
aws logs describe-log-streams \
  --log-group-name /aws/ec2/webapp-dev \
  --order-by LastEventTime \
  --descending \
  --max-items 5

# Get latest log events
aws logs tail /aws/ec2/webapp-dev --follow
```

**View VPC Flow Logs**:
```bash
# Tail VPC flow logs
aws logs tail /aws/vpc/webapp-dev --follow
```

---

## TROUBLESHOOTING COMMANDS

### Debug Terraform

**Enable Debug Logging**:
```bash
# Set log level
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log

# Run command
terraform apply

# View logs
tail -f terraform-debug.log
```

**Log Levels**:
- `TRACE`: Most verbose
- `DEBUG`: Debug information
- `INFO`: General information
- `WARN`: Warnings
- `ERROR`: Errors only

**Disable Logging**:
```bash
unset TF_LOG
unset TF_LOG_PATH
```

### Check Resource Status

**EC2 Instance Status**:
```bash
# Check instance status
aws ec2 describe-instance-status \
  --instance-ids i-12345 \
  --query 'InstanceStatuses[*].[InstanceId,InstanceStatus.Status,SystemStatus.Status]' \
  --output table
```

**RDS Instance Status**:
```bash
# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier webapp-dev-db \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' \
  --output table
```

**ALB Status**:
```bash
# Check ALB status
aws elbv2 describe-load-balancers \
  --names webapp-dev-alb \
  --query 'LoadBalancers[*].[LoadBalancerName,State.Code]' \
  --output table
```

### Network Troubleshooting

**Test Connectivity**:
```bash
# Test from EC2 instance
aws ssm start-session --target i-12345

# Inside instance:
curl http://localhost/health
curl http://internal-alb-dns/health
ping -c 3 google.com
```

**Check Security Groups**:
```bash
# Describe security group
aws ec2 describe-security-groups \
  --group-ids sg-12345 \
  --query 'SecurityGroups[*].[GroupId,GroupName,IpPermissions]' \
  --output json | jq '.'
```

**Check Route Tables**:
```bash
# Describe route table
aws ec2 describe-route-tables \
  --route-table-ids rtb-12345 \
  --query 'RouteTables[*].Routes' \
  --output table
```

### State Issues

**Refresh State**:
```bash
# Refresh state from AWS
terraform apply -refresh-only

# Review changes
terraform plan
```

**Fix State Drift**:
```bash
# Show drift
terraform plan

# Import missing resources
terraform import aws_instance.web i-12345

# Remove deleted resources
terraform state rm aws_instance.old
```

**Recover from Failed Apply**:
```bash
# Check state
terraform state list

# Refresh state
terraform apply -refresh-only

# Retry apply
terraform apply
```

---

## CLEANUP COMMANDS

### Destroy Infrastructure

**Complete Destroy**:
```bash
# Destroy all resources
terraform destroy

# Confirm with 'yes'
```

**Targeted Destroy**:
```bash
# Destroy specific resources first
terraform destroy -target=aws_instance.web
terraform destroy -target=aws_db_instance.main

# Then destroy remaining
terraform destroy
```

**Force Destroy**:
```bash
# Auto-approve (use with caution!)
terraform destroy -auto-approve
```

### Clean Terraform Files

**Remove Terraform Files**:
```bash
# Remove .terraform directory
rm -rf .terraform

# Remove lock file
rm .terraform.lock.hcl

# Remove state backups
rm terraform.tfstate.backup

# Reinitialize
terraform init
```

### Clean AWS Resources

**Empty S3 Buckets**:
```bash
# Empty S3 bucket before destroy
aws s3 rm s3://webapp-dev-static-assets --recursive
aws s3 rm s3://webapp-dev-logs --recursive
```

**Delete CloudWatch Log Groups**:
```bash
# Delete log groups
aws logs delete-log-group --log-group-name /aws/ec2/webapp-dev
aws logs delete-log-group --log-group-name /aws/vpc/webapp-dev
```

**Verify Cleanup**:
```bash
# Check for remaining resources
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=webapp"
aws ec2 describe-instances --filters "Name=tag:Project,Values=webapp"
aws rds describe-db-instances --query 'DBInstances[?contains(DBInstanceIdentifier, `webapp`)]'
aws s3 ls | grep webapp
```

---

## COMPLETE DEPLOYMENT EXAMPLE

### Step-by-Step Deployment

**1. Initial Setup**:
```bash
# Clone repository
git clone <repository-url>
cd Terraform-Capstone-Projects/Project-1-Multi-Tier-Web-Application/terraform-manifests

# Create backend resources
aws s3api create-bucket --bucket terraform-state-capstone-projects --region us-east-1
aws s3api put-bucket-versioning --bucket terraform-state-capstone-projects --versioning-configuration Status=Enabled
aws dynamodb create-table --table-name terraform-state-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST
```

**2. Configure Variables**:
```bash
# Edit terraform.tfvars
nano terraform.tfvars

# Update:
# - db_password (IMPORTANT!)
# - domain_name (optional)
# - alarm_email (optional)
```

**3. Initialize Terraform**:
```bash
# Initialize
terraform init

# Expected output:
# Terraform has been successfully initialized!
```

**4. Validate Configuration**:
```bash
# Validate syntax
terraform validate

# Expected output:
# Success! The configuration is valid.

# Format code
terraform fmt -recursive

# Check formatting
terraform fmt -check -recursive
```

**5. Review Plan**:
```bash
# Create plan
terraform plan -out=tfplan

# Review output carefully
# Expected: Plan: 45 to add, 0 to change, 0 to destroy.

# Save plan output
terraform plan -out=tfplan | tee plan-output.txt
```

**6. Apply Configuration**:
```bash
# Apply plan
terraform apply tfplan

# Wait for completion (10-15 minutes)
# Expected: Apply complete! Resources: 45 added, 0 changed, 0 destroyed.
```

**7. Verify Deployment**:
```bash
# Get outputs
terraform output

# Test ALB
ALB_DNS=$(terraform output -raw alb_dns_name)
curl -I http://$ALB_DNS

# Test health endpoint
curl http://$ALB_DNS/health

# Check target health
TG_ARN=$(aws elbv2 describe-target-groups --names webapp-dev-tg --query 'TargetGroups[0].TargetGroupArn' --output text)
aws elbv2 describe-target-health --target-group-arn $TG_ARN

# View CloudWatch dashboard
aws cloudwatch get-dashboard --dashboard-name webapp-dev-dashboard
```

**8. Test Application**:
```bash
# Open in browser
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "Application URL: http://$ALB_DNS"

# Test CloudFront
CF_DOMAIN=$(terraform output -raw cloudfront_domain_name)
echo "CloudFront URL: https://$CF_DOMAIN"
```

**9. Monitor Resources**:
```bash
# View logs
aws logs tail /aws/ec2/webapp-dev --follow

# Check CloudWatch alarms
aws cloudwatch describe-alarms --alarm-names webapp-dev-alb-unhealthy-targets

# View metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=app/webapp-dev-alb/... \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

**10. Cleanup** (when done):
```bash
# Destroy infrastructure
terraform destroy

# Confirm with 'yes'

# Verify cleanup
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=webapp"

# Clean local files
rm -rf .terraform terraform.tfstate* tfplan
```

---

**Document Version**: 1.0  
**Last Updated**: October 27, 2025  
**Status**: Complete  
**Total Lines**: 1,600+

