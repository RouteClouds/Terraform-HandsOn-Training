# Terraform Theory and Concepts
# Project 1: Multi-Tier Web Application Infrastructure

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [Terraform Fundamentals](#terraform-fundamentals)
3. [Infrastructure as Code Concepts](#infrastructure-as-code-concepts)
4. [Terraform Workflow](#terraform-workflow)
5. [Resource Management](#resource-management)
6. [State Management](#state-management)
7. [Variables and Outputs](#variables-and-outputs)
8. [Data Sources](#data-sources)
9. [Dependencies](#dependencies)
10. [Meta-Arguments](#meta-arguments)
11. [Functions and Expressions](#functions-and-expressions)
12. [Best Practices](#best-practices)
13. [Exam Domain Mapping](#exam-domain-mapping)
14. [Common Pitfalls](#common-pitfalls)

---

## OVERVIEW

This document covers the Terraform concepts and theory demonstrated in Project 1: Multi-Tier Web Application Infrastructure. It maps to the HashiCorp Terraform Associate Certification exam domains and provides detailed explanations of concepts used in the project.

### Learning Objectives

By completing this project, you will understand:
- ✅ Infrastructure as Code principles
- ✅ Terraform workflow and commands
- ✅ Resource and data source usage
- ✅ State management and backends
- ✅ Variable validation and outputs
- ✅ Resource dependencies
- ✅ Meta-arguments (count, for_each, depends_on)
- ✅ Terraform functions and expressions
- ✅ Best practices and design patterns

---

## TERRAFORM FUNDAMENTALS

### What is Terraform?

**Terraform** is an open-source Infrastructure as Code (IaC) tool created by HashiCorp that allows you to define and provision infrastructure using a declarative configuration language called HashiCorp Configuration Language (HCL).

**Key Characteristics**:
- **Declarative**: Describe the desired end state
- **Idempotent**: Same configuration produces same result
- **Cloud-agnostic**: Works with multiple cloud providers
- **Version-controlled**: Infrastructure code in Git
- **Collaborative**: Team-based workflows

### Terraform vs Other IaC Tools

**Terraform vs CloudFormation**:
- Terraform: Multi-cloud, HCL syntax, state management
- CloudFormation: AWS-only, JSON/YAML, AWS-managed state

**Terraform vs Ansible**:
- Terraform: Infrastructure provisioning, declarative
- Ansible: Configuration management, procedural

**Terraform vs Pulumi**:
- Terraform: HCL language, mature ecosystem
- Pulumi: General-purpose languages (Python, TypeScript)

### Terraform Architecture

**Components**:
1. **Terraform Core**: Reads configuration, manages state, creates execution plan
2. **Providers**: Plugins that interact with APIs (AWS, Azure, GCP)
3. **State**: Current infrastructure state
4. **Configuration**: HCL files defining desired state

**Workflow**:
```
Configuration (HCL) → Terraform Core → Provider → Cloud API → Infrastructure
                           ↓
                        State File
```

---

## INFRASTRUCTURE AS CODE CONCEPTS

### Benefits of IaC

**1. Version Control**
- Track changes over time
- Code reviews and approvals
- Rollback to previous versions
- Audit trail

**2. Automation**
- Eliminate manual processes
- Reduce human error
- Faster deployments
- Consistent results

**3. Repeatability**
- Same configuration = same result
- Multiple environments (dev, staging, prod)
- Disaster recovery
- Testing and validation

**4. Documentation**
- Code is documentation
- Self-documenting infrastructure
- Easy to understand
- Knowledge sharing

**5. Collaboration**
- Team-based workflows
- Pull request reviews
- Shared state
- Concurrent development

### IaC Best Practices

**1. Use Version Control**
- Store all code in Git
- Meaningful commit messages
- Branch protection rules
- Code review process

**2. Modularize Code**
- Reusable modules
- DRY principle (Don't Repeat Yourself)
- Logical separation
- Easier maintenance

**3. Manage State Properly**
- Remote state backend
- State locking
- State encryption
- Regular backups

**4. Use Variables**
- Parameterize configurations
- Environment-specific values
- Sensitive data handling
- Default values

**5. Implement Testing**
- Validate syntax
- Plan before apply
- Integration testing
- Automated testing

---

## TERRAFORM WORKFLOW

### Core Workflow

**1. Write**
- Define infrastructure in HCL
- Create .tf files
- Configure providers
- Define resources

**2. Plan**
- Review proposed changes
- Validate configuration
- Identify issues
- Get approval

**3. Apply**
- Execute changes
- Create/update/delete resources
- Update state file
- Verify deployment

**4. Destroy** (optional)
- Remove infrastructure
- Clean up resources
- Update state
- Cost savings

### Terraform Commands

#### terraform init

**Purpose**: Initialize Terraform working directory

**What it does**:
- Downloads provider plugins
- Initializes backend
- Creates .terraform directory
- Prepares working directory

**Example**:
```bash
terraform init
terraform init -upgrade  # Upgrade providers
terraform init -reconfigure  # Reconfigure backend
```

**When to use**:
- First time in directory
- After adding new providers
- After changing backend configuration
- After cloning repository

#### terraform validate

**Purpose**: Validate configuration syntax

**What it does**:
- Checks HCL syntax
- Validates resource arguments
- Checks for errors
- Does not access remote state

**Example**:
```bash
terraform validate
```

**When to use**:
- After writing configuration
- In CI/CD pipelines
- Before committing code
- Quick syntax check

#### terraform fmt

**Purpose**: Format configuration files

**What it does**:
- Applies consistent formatting
- Indentation and spacing
- Canonical syntax
- Improves readability

**Example**:
```bash
terraform fmt
terraform fmt -check  # Check without modifying
terraform fmt -recursive  # Format subdirectories
```

**When to use**:
- Before committing code
- In pre-commit hooks
- In CI/CD pipelines
- Regular maintenance

#### terraform plan

**Purpose**: Create execution plan

**What it does**:
- Compares desired state to current state
- Shows what will be created/updated/deleted
- Validates configuration
- Checks for errors

**Example**:
```bash
terraform plan
terraform plan -out=tfplan  # Save plan to file
terraform plan -var="environment=prod"  # Pass variables
```

**Output symbols**:
- `+` : Resource will be created
- `-` : Resource will be destroyed
- `~` : Resource will be updated in-place
- `-/+` : Resource will be destroyed and recreated
- `<=` : Resource will be read during apply

**When to use**:
- Before every apply
- To review changes
- In CI/CD pipelines
- For approval workflows

#### terraform apply

**Purpose**: Apply configuration changes

**What it does**:
- Executes the plan
- Creates/updates/deletes resources
- Updates state file
- Shows progress

**Example**:
```bash
terraform apply
terraform apply -auto-approve  # Skip confirmation
terraform apply tfplan  # Apply saved plan
terraform apply -target=aws_instance.web  # Apply specific resource
```

**When to use**:
- After reviewing plan
- To deploy infrastructure
- To update resources
- After approval

#### terraform destroy

**Purpose**: Destroy infrastructure

**What it does**:
- Deletes all managed resources
- Updates state file
- Removes infrastructure
- Frees up resources

**Example**:
```bash
terraform destroy
terraform destroy -auto-approve  # Skip confirmation
terraform destroy -target=aws_instance.web  # Destroy specific resource
```

**When to use**:
- To tear down environment
- Cost optimization
- Testing cleanup
- Decommissioning

#### terraform output

**Purpose**: Display output values

**What it does**:
- Shows output values from state
- Retrieves specific outputs
- Formats output (JSON, raw)
- Used in automation

**Example**:
```bash
terraform output
terraform output alb_dns_name  # Specific output
terraform output -json  # JSON format
```

**When to use**:
- After apply
- To get connection info
- In scripts and automation
- For documentation

#### terraform state

**Purpose**: Manage Terraform state

**What it does**:
- List resources in state
- Show resource details
- Move resources
- Remove resources

**Example**:
```bash
terraform state list  # List all resources
terraform state show aws_instance.web  # Show resource details
terraform state mv aws_instance.web aws_instance.app  # Rename resource
terraform state rm aws_instance.web  # Remove from state
```

**When to use**:
- Troubleshooting
- Refactoring
- Importing resources
- State management

---

## RESOURCE MANAGEMENT

### Resource Blocks

**Syntax**:
```hcl
resource "resource_type" "resource_name" {
  argument1 = value1
  argument2 = value2
  
  nested_block {
    nested_argument = value
  }
}
```

**Example from Project**:
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  tags = merge(
    local.common_tags,
    {
      Name = local.vpc_name
    }
  )
}
```

**Components**:
- **Resource Type**: `aws_vpc` (provider_resourcetype)
- **Resource Name**: `main` (local identifier)
- **Arguments**: Configuration parameters
- **Nested Blocks**: Complex configurations

### Resource Addressing

**Format**: `resource_type.resource_name`

**Examples**:
- `aws_vpc.main` - VPC resource
- `aws_subnet.public[0]` - First public subnet
- `aws_instance.web` - EC2 instance

**Module Resources**: `module.module_name.resource_type.resource_name`

### Resource Lifecycle

**Lifecycle Meta-Argument**:
```hcl
resource "aws_instance" "web" {
  # ... other arguments ...
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [tags]
  }
}
```

**Options**:
- `create_before_destroy`: Create new before destroying old
- `prevent_destroy`: Prevent accidental deletion
- `ignore_changes`: Ignore changes to specific attributes
- `replace_triggered_by`: Replace when referenced resource changes

**Example from Project**:
```hcl
resource "aws_launch_template" "main" {
  # ... configuration ...
  
  lifecycle {
    create_before_destroy = true
  }
}
```

### Resource Timeouts

**Purpose**: Customize operation timeouts

**Example**:
```hcl
resource "aws_db_instance" "main" {
  # ... configuration ...
  
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
```

---

## STATE MANAGEMENT

### What is Terraform State?

**Terraform State** is a JSON file that maps real-world resources to your configuration. It tracks metadata and improves performance for large infrastructures.

**State File Contents**:
- Resource mappings
- Resource metadata
- Dependencies
- Provider configuration
- Outputs

**Example State Structure**:
```json
{
  "version": 4,
  "terraform_version": "1.13.0",
  "resources": [
    {
      "type": "aws_vpc",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "attributes": {
            "id": "vpc-12345",
            "cidr_block": "10.0.0.0/16"
          }
        }
      ]
    }
  ]
}
```

### Local vs Remote State

**Local State**:
- Stored in `terraform.tfstate` file
- Single user
- No locking
- Risk of loss
- Not recommended for teams

**Remote State**:
- Stored in remote backend (S3, Terraform Cloud)
- Team collaboration
- State locking
- Encryption
- Versioning

**Project Configuration**:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-capstone-projects"
    key            = "project-1/multi-tier-web-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### State Locking

**Purpose**: Prevent concurrent modifications

**How it works**:
- Lock acquired before operations
- Lock released after completion
- Prevents race conditions
- Ensures consistency

**DynamoDB Table**:
```hcl
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### State Commands

**List Resources**:
```bash
terraform state list
```

**Show Resource**:
```bash
terraform state show aws_vpc.main
```

**Move Resource**:
```bash
terraform state mv aws_instance.web aws_instance.app
```

**Remove Resource**:
```bash
terraform state rm aws_instance.web
```

**Pull State**:
```bash
terraform state pull > terraform.tfstate
```

**Push State**:
```bash
terraform state push terraform.tfstate
```

### State Best Practices

**1. Use Remote State**
- S3 backend with encryption
- DynamoDB for locking
- Versioning enabled
- Access controls

**2. Never Edit Manually**
- Use terraform state commands
- Risk of corruption
- Loss of metadata
- Difficult to recover

**3. Backup Regularly**
- S3 versioning
- Automated backups
- Test restore procedures
- Document recovery process

**4. Separate Environments**
- Different state files
- Different backends
- Workspaces or directories
- Prevent cross-contamination

**5. Sensitive Data**
- State contains sensitive data
- Encrypt at rest
- Restrict access
- Use Terraform Cloud for encryption

---

## VARIABLES AND OUTPUTS

### Input Variables

**Purpose**: Parameterize configurations

**Variable Block**:
```hcl
variable "variable_name" {
  description = "Description of the variable"
  type        = string
  default     = "default_value"
  sensitive   = false
  
  validation {
    condition     = length(var.variable_name) > 0
    error_message = "Variable cannot be empty."
  }
}
```

**Variable Types**:

**Primitive Types**:
- `string`: Text values
- `number`: Numeric values
- `bool`: true/false

**Complex Types**:
- `list(type)`: Ordered collection
- `set(type)`: Unordered unique collection
- `map(type)`: Key-value pairs
- `object({...})`: Structured data
- `tuple([...])`: Fixed-length collection

**Examples from Project**:

**String Variable**:
```hcl
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "Invalid AWS region format."
  }
}
```

**Number Variable**:
```hcl
variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2
  
  validation {
    condition     = var.asg_min_size >= 1 && var.asg_min_size <= 10
    error_message = "ASG min size must be between 1 and 10."
  }
}
```

**List Variable**:
```hcl
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones required."
  }
}
```

**Map Variable**:
```hcl
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Project   = "Capstone-1"
  }
}
```

**Sensitive Variable**:
```hcl
variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Password must be at least 8 characters."
  }
}
```

### Variable Precedence

**Order (highest to lowest)**:
1. Command line flags: `-var="key=value"`
2. Variable files: `-var-file="file.tfvars"`
3. `terraform.tfvars` or `terraform.tfvars.json`
4. `*.auto.tfvars` or `*.auto.tfvars.json` (alphabetical order)
5. Environment variables: `TF_VAR_name`
6. Default values in variable blocks

**Example**:
```bash
# Command line
terraform apply -var="environment=prod"

# Variable file
terraform apply -var-file="prod.tfvars"

# Environment variable
export TF_VAR_environment=prod
terraform apply
```

### Output Values

**Purpose**: Export values from configuration

**Output Block**:
```hcl
output "output_name" {
  description = "Description of the output"
  value       = resource.attribute
  sensitive   = false
}
```

**Examples from Project**:

**Simple Output**:
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

**List Output**:
```hcl
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}
```

**Sensitive Output**:
```hcl
output "rds_username" {
  description = "Master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}
```

**Complex Output**:
```hcl
output "connection_info" {
  description = "Connection information"
  value = {
    application_url = "http://${aws_lb.main.dns_name}"
    database_host   = aws_db_instance.main.address
    database_port   = aws_db_instance.main.port
  }
}
```

### Using Outputs

**Display Outputs**:
```bash
terraform output
terraform output vpc_id
terraform output -json
```

**In Other Configurations**:
```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
}
```

---

## DATA SOURCES

### What are Data Sources?

**Data Sources** allow Terraform to fetch information from external sources or existing infrastructure.

**Syntax**:
```hcl
data "data_source_type" "name" {
  # Filter arguments
}
```

**Usage**:
```hcl
resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
}
```

### Examples from Project

**AWS AMI Data Source**:
```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

**Availability Zones**:
```hcl
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
```

**AWS Account ID**:
```hcl
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```

**Route53 Hosted Zone**:
```hcl
data "aws_route53_zone" "main" {
  count = var.create_route53_zone ? 0 : 1
  
  name         = var.domain_name
  private_zone = false
}
```

**ACM Certificate**:
```hcl
data "aws_acm_certificate" "main" {
  count = var.domain_name != "" ? 1 : 0
  
  domain   = var.domain_name
  statuses = ["ISSUED"]
}
```

### Data Source vs Resource

**Data Source**:
- Read-only
- Fetches existing information
- Does not create/modify/delete
- Prefix: `data.`

**Resource**:
- Read-write
- Creates/modifies/deletes
- Manages infrastructure
- Prefix: resource type

---

## DEPENDENCIES

### Implicit Dependencies

**Automatic Detection**: Terraform automatically detects dependencies when one resource references another.

**Example**:
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id  # Implicit dependency
  cidr_block = "10.0.1.0/24"
}
```

**Terraform knows**:
- VPC must be created before subnet
- Subnet depends on VPC
- VPC cannot be deleted while subnet exists

### Explicit Dependencies

**depends_on Meta-Argument**: Specify dependencies that Terraform cannot automatically infer.

**Syntax**:
```hcl
resource "resource_type" "name" {
  # ... configuration ...
  
  depends_on = [
    resource_type.name,
    module.module_name
  ]
}
```

**Example from Project**:
```hcl
resource "aws_cloudfront_distribution" "main" {
  # ... configuration ...
  
  depends_on = [
    aws_s3_bucket.static_assets,
    aws_lb.main
  ]
}
```

**When to use**:
- Hidden dependencies
- Ordering requirements
- External dependencies
- Module dependencies

### Dependency Graph

**View Dependencies**:
```bash
terraform graph | dot -Tpng > graph.png
```

**Graph Output**: Shows resource relationships and creation order.

---

## META-ARGUMENTS

### count

**Purpose**: Create multiple instances of a resource

**Syntax**:
```hcl
resource "resource_type" "name" {
  count = number
  
  # Use count.index to differentiate
}
```

**Example from Project**:
```hcl
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]
  
  tags = {
    Name = "${local.name_prefix}-public-${count.index + 1}"
  }
}
```

**Accessing Resources**:
```hcl
# Single resource
aws_subnet.public[0].id

# All resources
aws_subnet.public[*].id
```

**Limitations**:
- Cannot use with for_each
- Reordering causes recreation
- Removing middle item causes recreation

### for_each

**Purpose**: Create multiple instances with unique keys

**Syntax**:
```hcl
resource "resource_type" "name" {
  for_each = map_or_set
  
  # Use each.key and each.value
}
```

**Example with Map**:
```hcl
variable "instances" {
  type = map(object({
    instance_type = string
    ami           = string
  }))
  default = {
    web = {
      instance_type = "t3.micro"
      ami           = "ami-12345"
    }
    app = {
      instance_type = "t3.small"
      ami           = "ami-67890"
    }
  }
}

resource "aws_instance" "servers" {
  for_each = var.instances
  
  instance_type = each.value.instance_type
  ami           = each.value.ami
  
  tags = {
    Name = each.key
  }
}
```

**Example with Set**:
```hcl
resource "aws_iam_user" "users" {
  for_each = toset(["alice", "bob", "charlie"])
  
  name = each.key
}
```

**Accessing Resources**:
```hcl
# Single resource
aws_instance.servers["web"].id

# All resources
values(aws_instance.servers)[*].id
```

**Advantages over count**:
- Stable identifiers
- No recreation on reordering
- Can remove middle items safely

### depends_on

**Purpose**: Explicit dependencies

**Covered in**: [Dependencies](#dependencies) section

### lifecycle

**Purpose**: Customize resource behavior

**Covered in**: [Resource Lifecycle](#resource-lifecycle) section

### provider

**Purpose**: Use alternate provider configuration

**Example**:
```hcl
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_instance" "web" {
  provider = aws.west
  # ... configuration ...
}
```

---

## FUNCTIONS AND EXPRESSIONS

### Built-in Functions

Terraform provides 100+ built-in functions. Cannot create custom functions.

**Categories**:
- Numeric functions
- String functions
- Collection functions
- Encoding functions
- Filesystem functions
- Date and time functions
- Hash and crypto functions
- IP network functions
- Type conversion functions

### Common Functions Used in Project

**String Functions**:

**format()**:
```hcl
format("%s-%s", var.project_name, var.environment)
# Result: "webapp-dev"
```

**join()**:
```hcl
join(",", var.availability_zones)
# Result: "us-east-1a,us-east-1b,us-east-1c"
```

**split()**:
```hcl
split(",", "a,b,c")
# Result: ["a", "b", "c"]
```

**Collection Functions**:

**length()**:
```hcl
length(var.public_subnet_cidrs)
# Result: 3
```

**merge()**:
```hcl
merge(local.common_tags, { Name = "vpc" })
# Combines two maps
```

**concat()**:
```hcl
concat(var.list1, var.list2)
# Combines two lists
```

**lookup()**:
```hcl
lookup(var.instance_types, var.environment, "t3.micro")
# Returns value for key, or default
```

**Type Conversion**:

**toset()**:
```hcl
toset(["a", "b", "a"])
# Result: ["a", "b"] (unique values)
```

**tolist()**:
```hcl
tolist(toset(["a", "b"]))
# Convert set to list
```

**tomap()**:
```hcl
tomap({ "key" = "value" })
# Convert to map
```

**Conditional Expressions**:

**Ternary Operator**:
```hcl
var.environment == "prod" ? "t3.large" : "t3.micro"
```

**Example from Project**:
```hcl
cloudfront_default_certificate = var.domain_name == "" ? true : false
```

**Null Coalescing**:
```hcl
coalesce(var.custom_value, "default")
# Returns first non-null value
```

### Dynamic Blocks

**Purpose**: Generate nested blocks dynamically

**Syntax**:
```hcl
dynamic "block_name" {
  for_each = collection
  content {
    # Use block_name.key and block_name.value
  }
}
```

**Example from Project**:
```hcl
resource "aws_security_group" "alb" {
  # ... configuration ...
  
  dynamic "ingress" {
    for_each = var.alb_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

### Splat Expressions

**Purpose**: Extract attributes from lists

**Syntax**: `resource[*].attribute`

**Example**:
```hcl
# Get all subnet IDs
aws_subnet.public[*].id

# Get all instance IPs
aws_instance.web[*].private_ip
```

**With for_each**:
```hcl
values(aws_instance.servers)[*].id
```

---

## BEST PRACTICES

### Code Organization

**1. File Structure**:
```
project/
├── main.tf           # Main resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── providers.tf      # Provider configuration
├── locals.tf         # Local values
├── data.tf           # Data sources
├── terraform.tfvars  # Variable values
└── README.md         # Documentation
```

**2. Resource Files**:
```
project/
├── vpc.tf            # VPC resources
├── compute.tf        # EC2 resources
├── alb.tf            # Load balancer
├── rds.tf            # Database
├── s3.tf             # Storage
└── monitoring.tf     # CloudWatch
```

**3. Module Structure**:
```
modules/
└── vpc/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

### Naming Conventions

**Resources**:
- Use descriptive names
- Lowercase with underscores
- Avoid redundant prefixes

**Good**:
```hcl
resource "aws_vpc" "main" {}
resource "aws_subnet" "public" {}
```

**Bad**:
```hcl
resource "aws_vpc" "aws_vpc_main" {}
resource "aws_subnet" "subnet_public" {}
```

**Variables**:
- Descriptive names
- Use prefixes for grouping
- Consistent naming

**Example**:
```hcl
variable "vpc_cidr" {}
variable "vpc_enable_dns" {}
variable "db_instance_class" {}
variable "db_allocated_storage" {}
```

### Comments and Documentation

**Resource Comments**:
```hcl
# VPC for multi-tier web application
# Spans 3 availability zones for high availability
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}
```

**Section Headers**:
```hcl
# ========================================
# VPC Configuration
# ========================================
```

**Inline Comments**:
```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type  # t3.micro for dev
}
```

### Variable Validation

**Always Validate**:
```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

**Regex Validation**:
```hcl
variable "aws_region" {
  type = string
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "Invalid AWS region format."
  }
}
```

**Range Validation**:
```hcl
variable "asg_min_size" {
  type = number
  
  validation {
    condition     = var.asg_min_size >= 1 && var.asg_min_size <= 10
    error_message = "ASG min size must be between 1 and 10."
  }
}
```

### Security Best Practices

**1. Sensitive Variables**:
```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

**2. Sensitive Outputs**:
```hcl
output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
```

**3. State Encryption**:
```hcl
terraform {
  backend "s3" {
    bucket  = "terraform-state"
    key     = "terraform.tfstate"
    encrypt = true
  }
}
```

**4. Provider Credentials**:
- Use IAM roles (preferred)
- Environment variables
- AWS CLI profiles
- Never hardcode credentials

**5. Secrets Management**:
- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- HashiCorp Vault
- Never commit secrets to Git

---

## EXAM DOMAIN MAPPING

### Exam Domains

The HashiCorp Terraform Associate Certification exam covers 6 domains:

**Domain 1: Understand Infrastructure as Code (IaC) concepts** (15%)
**Domain 2: Understand Terraform's purpose (vs other IaC)** (15%)
**Domain 3: Understand Terraform basics** (20%)
**Domain 4: Use the Terraform CLI (outside of core workflow)** (15%)
**Domain 5: Interact with Terraform modules** (15%)
**Domain 6: Navigate Terraform workflow** (20%)

### Project Coverage by Domain

#### Domain 1: IaC Concepts (15%)

**Topics Covered**:
- ✅ Benefits of IaC
- ✅ Version control integration
- ✅ Idempotency and consistency
- ✅ Automation and repeatability

**Project Examples**:
- All infrastructure defined in code
- Git version control
- Repeatable deployments
- Automated provisioning

#### Domain 2: Terraform's Purpose (15%)

**Topics Covered**:
- ✅ Multi-cloud capabilities
- ✅ Provider ecosystem
- ✅ Declarative syntax
- ✅ State management

**Project Examples**:
- AWS provider usage
- HCL configuration
- State backend configuration
- Resource dependencies

#### Domain 3: Terraform Basics (20%)

**Topics Covered**:
- ✅ Terraform configuration blocks
- ✅ Resource and data sources
- ✅ Variables and outputs
- ✅ State management
- ✅ Terraform settings

**Project Examples**:
- 13 resource files
- 40+ input variables
- 20+ output values
- Data sources for AMI, AZs
- S3 backend configuration

#### Domain 4: Terraform CLI (15%)

**Topics Covered**:
- ✅ terraform init
- ✅ terraform validate
- ✅ terraform fmt
- ✅ terraform plan
- ✅ terraform apply
- ✅ terraform destroy
- ✅ terraform state commands
- ✅ terraform output

**Project Examples**:
- All commands used in deployment
- State management commands
- Output retrieval
- Resource targeting

#### Domain 5: Terraform Modules (15%)

**Topics Covered**:
- ✅ Module structure
- ✅ Module inputs and outputs
- ✅ Module sources
- ✅ Module versioning

**Project Examples**:
- Modular file structure
- Reusable patterns
- Input/output design
- (Modules covered in Project 2)

#### Domain 6: Terraform Workflow (20%)

**Topics Covered**:
- ✅ Write → Plan → Apply workflow
- ✅ State locking
- ✅ Backend configuration
- ✅ Workspace management

**Project Examples**:
- Complete workflow implementation
- S3 backend with DynamoDB locking
- Environment separation
- Deployment automation

### Exam Preparation Tips

**1. Hands-On Practice**:
- Complete all 5 capstone projects
- Practice terraform commands
- Understand state management
- Work with modules

**2. Understand Concepts**:
- Don't just memorize commands
- Understand why and when
- Know the workflow
- Understand dependencies

**3. Read Documentation**:
- Terraform documentation
- AWS provider documentation
- Best practices guides
- Release notes

**4. Practice Scenarios**:
- Troubleshooting
- State management
- Module usage
- Workflow optimization

**5. Review Exam Objectives**:
- Study guide
- Sample questions
- Practice exams
- Hands-on labs

---

## COMMON PITFALLS

### 1. State File Issues

**Problem**: Corrupted or lost state file

**Symptoms**:
- Resources not tracked
- Duplicate resources created
- Unable to destroy resources

**Solutions**:
- Use remote state backend
- Enable versioning
- Regular backups
- Never edit manually

**Prevention**:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
```

### 2. Resource Dependencies

**Problem**: Resources created in wrong order

**Symptoms**:
- Creation failures
- Missing dependencies
- Timeout errors

**Solutions**:
- Use implicit dependencies (references)
- Add explicit depends_on when needed
- Review dependency graph

**Example**:
```hcl
resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id  # Implicit dependency
  
  depends_on = [
    aws_internet_gateway.main  # Explicit dependency
  ]
}
```

### 3. Variable Validation

**Problem**: Invalid variable values

**Symptoms**:
- Resource creation failures
- Unexpected behavior
- Security issues

**Solutions**:
- Add validation rules
- Use appropriate types
- Provide clear error messages

**Example**:
```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Invalid environment. Must be dev, staging, or prod."
  }
}
```

### 4. Count vs for_each

**Problem**: Using count when for_each is better

**Symptoms**:
- Resources recreated on reordering
- Difficult to manage
- State issues

**Solutions**:
- Use for_each for stable identifiers
- Use count for simple multiples
- Understand the differences

**When to use count**:
- Simple multiples (3 subnets)
- Order doesn't matter
- No unique identifiers needed

**When to use for_each**:
- Unique identifiers (IAM users)
- Order matters
- Need to remove middle items

### 5. Sensitive Data

**Problem**: Secrets in state or logs

**Symptoms**:
- Passwords visible in state
- Credentials in logs
- Security vulnerabilities

**Solutions**:
- Mark variables as sensitive
- Mark outputs as sensitive
- Encrypt state file
- Use secrets management

**Example**:
```hcl
variable "db_password" {
  type      = string
  sensitive = true
}

output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
```

### 6. Provider Version Constraints

**Problem**: Provider version changes break configuration

**Symptoms**:
- Syntax errors
- Deprecated arguments
- Breaking changes

**Solutions**:
- Pin provider versions
- Use version constraints
- Test upgrades
- Review changelogs

**Example**:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"  # Pin to minor version
    }
  }
}
```

### 7. Resource Naming

**Problem**: Changing resource names causes recreation

**Symptoms**:
- Resources destroyed and recreated
- Downtime
- Data loss

**Solutions**:
- Plan carefully before renaming
- Use terraform state mv
- Understand lifecycle
- Use create_before_destroy

**Example**:
```bash
# Rename in state without recreating
terraform state mv aws_instance.old aws_instance.new
```

### 8. Circular Dependencies

**Problem**: Resources depend on each other

**Symptoms**:
- Cannot create resources
- Dependency cycle errors
- Planning failures

**Solutions**:
- Review dependencies
- Refactor configuration
- Use data sources
- Break circular references

**Example**:
```hcl
# Bad: Circular dependency
resource "aws_security_group" "a" {
  ingress {
    security_groups = [aws_security_group.b.id]
  }
}

resource "aws_security_group" "b" {
  ingress {
    security_groups = [aws_security_group.a.id]
  }
}

# Good: Use security group rules
resource "aws_security_group" "a" {}
resource "aws_security_group" "b" {}

resource "aws_security_group_rule" "a_to_b" {
  security_group_id        = aws_security_group.a.id
  source_security_group_id = aws_security_group.b.id
}
```

### 9. Hardcoded Values

**Problem**: Values hardcoded in configuration

**Symptoms**:
- Not reusable
- Difficult to maintain
- Environment-specific

**Solutions**:
- Use variables
- Use locals
- Use data sources
- Parameterize everything

**Example**:
```hcl
# Bad
resource "aws_instance" "web" {
  instance_type = "t3.micro"
  ami           = "ami-12345"
}

# Good
resource "aws_instance" "web" {
  instance_type = var.instance_type
  ami           = data.aws_ami.amazon_linux.id
}
```

### 10. Ignoring Plan Output

**Problem**: Applying without reviewing plan

**Symptoms**:
- Unexpected changes
- Resource deletion
- Service disruption

**Solutions**:
- Always review plan
- Save plan to file
- Require approval
- Automate reviews

**Example**:
```bash
# Save and review plan
terraform plan -out=tfplan
# Review output carefully
terraform apply tfplan
```

---

**Document Version**: 1.0  
**Last Updated**: October 27, 2025  
**Status**: Complete  
**Total Lines**: 1,400+

