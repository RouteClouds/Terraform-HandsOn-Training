# Terraform Modules - Theory
![Terraform Modules)](/07-terraform-modules/07-Diagrams/07-theory-diagrams/terraform_modules_concept.png)
## Overview
Terraform modules are containers for multiple resources that are used together. They help in organizing Terraform code, promoting reusability, and implementing infrastructure patterns consistently across different environments and projects.

## Learning Objectives
- Understand module concepts and benefits
- Master module structure and components
- Learn module sourcing and versioning
- Implement module composition patterns
- Apply module best practices

## Key Concepts

### 1. Module Fundamentals

#### What is a Terraform Module?
- Self-contained packages of Terraform configurations
- Reusable infrastructure components
- Encapsulated resource definitions
- Parameterized configurations

#### Module Benefits
- **Reusability**: Write once, use many times
- **Encapsulation**: Hide complex implementations
- **Consistency**: Standardize infrastructure patterns
- **Maintainability**: Centralize changes
- **Versioning**: Control infrastructure evolution

### 2. Module Structure

#### Basic Module Components
hcl
module_directory/
├── main.tf          # Main resource definitions
├─��� variables.tf     # Input variables
├── outputs.tf       # Output definitions
├── versions.tf      # Version constraints
└── README.md        # Documentation
```

#### Optional Components
```hcl
module_directory/
├── providers.tf     # Provider configurations
├── locals.tf        # Local variables
├── data.tf         # Data source definitions
└── examples/       # Example implementations
```

### 3. Module Sources

#### Local Modules
```hcl
module "vpc" {
  source = "../modules/vpc"
  # Module inputs
}
```

#### Registry Modules
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"
  # Module inputs
}
```

#### Git Sources
```hcl
module "vpc" {
  source = "git::https://github.com/example/vpc.git?ref=v1.2.0"
  # Module inputs
}
```

### 4. Module Composition

#### Root Module
- Entry point for Terraform configuration
- Calls and composes other modules
- Defines high-level architecture

```hcl
# Root module example
module "networking" {
  source = "./modules/networking"
  vpc_cidr = "10.0.0.0/16"
}

module "compute" {
  source = "./modules/compute"
  vpc_id = module.networking.vpc_id
}
```

#### Child Modules
- Reusable infrastructure components
- Called by root or other modules
- Focused on specific functionality

```hcl
# Child module structure
module "database" {
  source = "./modules/database"
  depends_on = [module.networking]
  subnet_ids = module.networking.private_subnet_ids
}
```

### 5. Module Variables and Outputs

#### Input Variables
```hcl
# variables.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be valid CIDR block."
  }
}
```

#### Output Values
```hcl
# outputs.tf
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}
```

### 6. Module Versioning

#### Version Constraints
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"  # Allows 3.x but not 4.x
}
```

#### Version Types
- Exact: `version = "3.2.0"`
- Pessimistic: `version = "~> 3.2"`
- Flexible: `version = ">= 3.2.0"`

### 7. Module Best Practices

#### 1. Module Design
- Keep modules focused and single-purpose
- Use consistent interface patterns
- Implement proper validation
- Provide complete documentation

#### 2. Module Organization
```plaintext
terraform-aws-modules/
├── networking/
│   ├── vpc/
│   └── security-groups/
├── compute/
│   ├── ec2-instance/
│   └── auto-scaling/
└── database/
    ├── rds/
    └── dynamodb/
```

#### 3. Module Documentation
```markdown
# AWS VPC Module

## Usage
```hcl
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  environment = "production"
}
```

## Inputs
| Name | Description | Type | Default |
|------|-------------|------|---------|
| vpc_cidr | VPC CIDR block | string | - |
| environment | Environment name | string | - |

## Outputs
| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
```

### 8. Advanced Module Concepts

#### 1. Count and For_each with Modules
```hcl
module "server" {
  count  = 3
  source = "./modules/server"
  name   = "server-${count.index}"
}

module "subnet" {
  for_each = toset(["web", "app", "db"])
  source   = "./modules/subnet"
  name     = each.key
}
```

#### 2. Module Dependencies
```hcl
module "vpc" {
  source = "./modules/vpc"
}

module "app" {
  source     = "./modules/app"
  depends_on = [module.vpc]
  vpc_id     = module.vpc.vpc_id
}
```

#### 3. Conditional Module Creation
```hcl
module "backup" {
  source = "./modules/backup"
  count  = var.environment == "production" ? 1 : 0
}
```

## Real-World Implementation

### Case Study: Enterprise Infrastructure

#### 1. Module Structure
```plaintext
enterprise-infrastructure/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── database/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
└── examples/
```

#### 2. Implementation
```hcl
# environments/production/main.tf
module "networking" {
  source     = "../../modules/networking"
  vpc_cidr   = "10.0.0.0/16"
  environment = "production"
}

module "compute" {
  source       = "../../modules/compute"
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnet_ids
  environment  = "production"
}
```

## Additional Resources
- [Terraform Module Documentation](https://www.terraform.io/docs/modules/index.html)
- [Terraform Registry](https://registry.terraform.io/)
- [Module Development](https://www.terraform.io/docs/modules/development.html)

### 9. Practical Module Examples

#### 1. AWS VPC Module with Multiple Environments

```hcl
# modules/vpc/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.azs[count.index]
  
  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
  }
}

# Usage in environments
module "vpc_prod" {
  source = "./modules/vpc"
  
  environment = "production"
  vpc_cidr    = "10.0.0.0/16"
  azs         = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "vpc_dev" {
  source = "./modules/vpc"
  
  environment = "development"
  vpc_cidr    = "172.16.0.0/16"
  azs         = ["us-east-1a", "us-east-1b"]
}
```

#### 2. Security Group Module with Dynamic Rules

```hcl
# modules/security-group/variables.tf
variable "name" {
  description = "Security group name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

# modules/security-group/main.tf
resource "aws_security_group" "this" {
  name        = var.name
  vpc_id      = var.vpc_id
  description = "Managed by Terraform"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
}

# Usage example
module "web_sg" {
  source = "./modules/security-group"
  
  name   = "web-server-sg"
  vpc_id = module.vpc.vpc_id
  
  ingress_rules = [
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]
}
```

#### 3. Multi-Region Module Deployment

```hcl
# modules/multi-region/variables.tf
variable "regions" {
  description = "Map of region configurations"
  type = map(object({
    vpc_cidr = string
    azs      = list(string)
    tags     = map(string)
  }))
}

# modules/multi-region/main.tf
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

module "vpc_us_east" {
  source = "../vpc"
  providers = {
    aws = aws.us_east_1
  }
  
  vpc_cidr = var.regions["us-east-1"].vpc_cidr
  azs      = var.regions["us-east-1"].azs
  tags     = var.regions["us-east-1"].tags
}

module "vpc_us_west" {
  source = "../vpc"
  providers = {
    aws = aws.us_west_2
  }
  
  vpc_cidr = var.regions["us-west-2"].vpc_cidr
  azs      = var.regions["us-west-2"].azs
  tags     = var.regions["us-west-2"].tags
}

# Usage example
module "multi_region" {
  source = "./modules/multi-region"
  
  regions = {
    "us-east-1" = {
      vpc_cidr = "10.0.0.0/16"
      azs      = ["us-east-1a", "us-east-1b"]
      tags     = { Environment = "prod", Region = "us-east-1" }
    }
    "us-west-2" = {
      vpc_cidr = "172.16.0.0/16"
      azs      = ["us-west-2a", "us-west-2b"]
      tags     = { Environment = "dr", Region = "us-west-2" }
    }
  }
}
```

#### 4. Module Composition with Dependencies

```hcl
# Example of complex module composition
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr     = "10.0.0.0/16"
  environment  = "production"
}

module "security" {
  source = "./modules/security"
  
  vpc_id       = module.networking.vpc_id
  depends_on   = [module.networking]
}

module "database" {
  source = "./modules/database"
  
  subnet_ids   = module.networking.private_subnet_ids
  sg_id        = module.security.db_sg_id
  depends_on   = [module.networking, module.security]
}

module "application" {
  source = "./modules/application"
  
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.private_subnet_ids
  sg_id        = module.security.app_sg_id
  db_endpoint  = module.database.endpoint
  depends_on   = [module.database]
}
```

#### 5. Conditional Module Configuration

```hcl
# Example of module with conditional resources
module "monitoring" {
  source = "./modules/monitoring"
  
  environment = var.environment
  
  alerts_enabled = var.environment == "production"
  backup_enabled = contains(["staging", "production"], var.environment)
  
  alert_thresholds = var.environment == "production" ? {
    cpu    = 80
    memory = 85
    disk   = 90
  } : {
    cpu    = 90
    memory = 90
    disk   = 95
  }
}
```

These examples demonstrate:
1. Environment-specific configurations
2. Dynamic resource creation
3. Multi-region deployment
4. Complex module dependencies
5. Conditional configurations

Would you like me to:
1. Add more specific examples?
2. Include more use cases?
3. Add more complex scenarios?
4. Expand any particular example?