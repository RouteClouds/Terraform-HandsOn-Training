# Lab 7.1: Basic Module Development

## 🎯 **Objective**
Create your first reusable Terraform module for AWS VPC infrastructure with proper structure, documentation, and testing.

## 📋 **Prerequisites**
- Terraform ~> 1.13.0 installed
- AWS CLI configured with appropriate permissions
- Basic understanding of Terraform syntax and AWS networking

## 🏗️ **Lab Architecture**
You'll create a VPC module that provisions:
- VPC with configurable CIDR
- Public and private subnets across multiple AZs
- Internet Gateway and NAT Gateway
- Route tables and associations
- Security groups with configurable rules

## 📁 **Lab Structure**
```
lab-7.1-basic-module/
├── modules/
│   └── aws-vpc/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       └── README.md
├── examples/
│   ├── basic/
│   └── advanced/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

## 🚀 **Step 1: Create Module Structure**

### Create the VPC Module Directory
```bash
mkdir -p lab-7.1-basic-module/modules/aws-vpc
mkdir -p lab-7.1-basic-module/examples/{basic,advanced}
cd lab-7.1-basic-module
```

### Create Module Variables (`modules/aws-vpc/variables.tf`)
```hcl
# Core VPC Configuration
variable "name" {
  description = "Name prefix for all resources"
  type        = string
  
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 32
    error_message = "Name must be between 1 and 32 characters."
  }
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "CIDR block must be a valid IPv4 CIDR."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified."
  }
}

# Subnet Configuration
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = []
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = []
}

# Feature Flags
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

# Tagging
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Create Module Main Configuration (`modules/aws-vpc/main.tf`)
```hcl
# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Local values for computed configurations
locals {
  # Auto-generate subnet CIDRs if not provided
  public_subnet_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [
    for i in range(length(var.availability_zones)) : cidrsubnet(var.cidr_block, 8, i)
  ]
  
  private_subnet_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [
    for i in range(length(var.availability_zones)) : cidrsubnet(var.cidr_block, 8, i + 10)
  ]
  
  database_subnet_cidrs = length(var.database_subnet_cidrs) > 0 ? var.database_subnet_cidrs : [
    for i in range(length(var.availability_zones)) : cidrsubnet(var.cidr_block, 8, i + 20)
  ]
  
  # Common tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "aws-vpc"
    Region      = data.aws_region.current.name
  })
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-public-${var.availability_zones[count.index]}"
    Type = "Public"
    Tier = "Web"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-private-${var.availability_zones[count.index]}"
    Type = "Private"
    Tier = "Application"
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-database-${var.availability_zones[count.index]}"
    Type = "Private"
    Tier = "Database"
  })
}

# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-db-subnet-group"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  
  domain = "vpc"
  
  depends_on = [aws_internet_gateway.main]
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  depends_on = [aws_internet_gateway.main]
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-nat-${count.index + 1}"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-public-rt"
    Type = "Public"
  })
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 1
  
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
    }
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-private-rt-${count.index + 1}"
    Type = "Private"
  })
}

# Database Route Table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-database-rt"
    Type = "Database"
  })
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

# Route Table Associations - Database
resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)
  
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# Default Security Group
resource "aws_security_group" "default" {
  name_prefix = "${var.name}-default-"
  vpc_id      = aws_vpc.main.id
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  # Allow inbound traffic from within VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
    description = "All traffic from VPC"
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.name}-default-sg"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}
```

## 🚀 **Step 2: Create Module Outputs**

### Create Module Outputs (`modules/aws-vpc/outputs.tf`)
```hcl
# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# Internet Gateway
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.main.name
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_public_ips" {
  description = "List of public IPs associated with NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

output "database_route_table_id" {
  description = "ID of the database route table"
  value       = aws_route_table.database.id
}

# Security Group
output "default_security_group_id" {
  description = "ID of the default security group"
  value       = aws_security_group.default.id
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}
```

## 🚀 **Step 3: Create Version Constraints**

### Create Version File (`modules/aws-vpc/versions.tf`)
```hcl
terraform {
  required_version = ">= 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
}
```

## 🚀 **Step 4: Create Module Documentation**

### Create README (`modules/aws-vpc/README.md`)
```markdown
# AWS VPC Terraform Module

This module creates a VPC with public, private, and database subnets across multiple availability zones.

## Features

- VPC with configurable CIDR block
- Public subnets with Internet Gateway
- Private subnets with NAT Gateway(s)
- Database subnets with subnet group
- Configurable NAT Gateway strategy (single or per-AZ)
- Comprehensive tagging strategy
- Input validation and error handling

## Usage

```hcl
module "vpc" {
  source = "./modules/aws-vpc"
  
  name               = "my-app"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  environment        = "dev"
  
  # Optional: Custom subnet CIDRs
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  
  # Cost optimization for non-prod
  single_nat_gateway = true
  
  tags = {
    Project = "MyApplication"
    Owner   = "Platform Team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.0 |
| aws | ~> 6.12.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for all resources | `string` | n/a | yes |
| cidr_block | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| availability_zones | List of availability zones | `list(string)` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| database_subnet_ids | List of database subnet IDs |
```

## 🚀 **Step 5: Create Example Usage**

### Create Basic Example (`examples/basic/main.tf`)
```hcl
terraform {
  required_version = ">= 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "../../modules/aws-vpc"
  
  name               = "basic-example"
  cidr_block         = "10.0.0.0/16"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  environment        = "dev"
  
  # Cost optimization for development
  single_nat_gateway = true
  
  tags = {
    Example = "Basic VPC"
    Purpose = "Learning"
  }
}

# Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
```

## 🧪 **Step 6: Test the Module**

### Initialize and Plan
```bash
cd examples/basic
terraform init
terraform plan
```

### Apply the Configuration
```bash
terraform apply
```

### Verify Resources
```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=basic-example-vpc"

# Check Subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"

# Check Route Tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

### Clean Up
```bash
terraform destroy
```

## 🎯 **Validation Exercises**

1. **Test Input Validation**: Try invalid inputs to verify validation rules work
2. **Test Different Configurations**: Try with different AZ counts and CIDR blocks
3. **Cost Optimization**: Compare costs between single and multiple NAT gateways
4. **Resource Tagging**: Verify all resources have proper tags

## 📚 **Key Learning Points**

- Module structure and organization
- Input validation and error handling
- Dynamic resource creation with count
- Local values for computed configurations
- Comprehensive output definitions
- Documentation best practices

---

**Next**: Proceed to Lab 7.2 for advanced module composition patterns.
