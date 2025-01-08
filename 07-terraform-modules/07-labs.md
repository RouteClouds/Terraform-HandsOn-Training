# Terraform Modules - Labs

## Lab 1: Basic Module Usage
### Duration: 45 minutes

### Prerequisites
- AWS CLI configured
- Terraform installed
- Basic understanding of AWS VPC

### Lab Objectives
- Use public registry modules
- Configure module inputs
- Access module outputs
- Understand module versioning

### Steps

#### 1. Create VPC using AWS VPC Module
hcl
# main.tf
# Use the official AWS VPC module from Terraform Registry
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC Module from Terraform Registry
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"  # Specify module version for stability

  # VPC Configuration
  name = "my-vpc"
  cidr = "10.0.0.0/16"

  # Availability Zones
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # NAT Gateway Configuration
  enable_nat_gateway = true
  single_nat_gateway = true

  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags
  tags = {
    Environment = "lab"
    Lab         = "module-basics"
  }
}

# Output the VPC details
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}
```

### Validation Steps
```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply configuration
terraform apply -auto-approve

# Verify outputs
terraform output
```

### Troubleshooting Guide for Lab 1

#### Common Issues and Solutions

1. **Module Source Not Found**
bash
Error: Module not found

Error: Could not download module "vpc" (main.tf:15) source code from 
"terraform-aws-modules/vpc/aws": error downloading...
```

**Solution:**
- Verify internet connectivity
- Check module source path
- Run `terraform init` again
```bash
# Force re-initialization
terraform init -upgrade
```

2. **Version Constraints**
```bash
Error: Incompatible provider version

Provider registry.terraform.io/hashicorp/aws v4.0.0 does not meet version
constraints.
```

**Solution:**
- Update version constraints
- Check provider compatibility
```hcl
# Update provider version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}
```

### Detailed Explanations

#### VPC Module Configuration
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  # CIDR Block Explanation
  cidr = "10.0.0.0/16"  # Provides 65,536 IP addresses
  
  # Subnet Design
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]  # 256 IPs each
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]  # 256 IPs each
  
  # NAT Gateway Configuration
  enable_nat_gateway = true     # Allows private subnet internet access
  single_nat_gateway = true     # Cost-effective for non-prod environments
}
```

```## Lab 2: Creating Custom Modules
### Duration: 60 minutes

### Lab Objectives
- Create a custom module
- Implement module variables
- Define module outputs
- Use module in root configuration

### Steps

#### 1. Create Module Structure
```bash
mkdir -p modules/aws-ec2-instance
cd modules/aws-ec2-instance
```

#### 2. Create Module Files

```hcl
# modules/aws-ec2-instance/variables.tf
# Input variables for the module
variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID for instance placement"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the instance"
  type        = map(string)
  default     = {}
}
```

```hcl
# modules/aws-ec2-instance/main.tf
# Main module configuration
resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = var.vpc_security_group_ids

  tags = merge(
    {
      "Name" = var.instance_name
    },
    var.tags
  )
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

```hcl
# modules/aws-ec2-instance/outputs.tf
# Module outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}
```

#### 3. Use Custom Module

```hcl
# root/main.tf
# Root configuration using custom module
module "web_server" {
  source = "./modules/aws-ec2-instance"

  instance_name = "web-server"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Environment = "lab"
    Role       = "web"
  }
}

# Security group for web server
resource "aws_security_group" "web" {
  name        = "web-server-sg"
  description = "Security group for web server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}
```

### Lab 2 Additional Information

#### Module Structure Best Practices

1. **File Organization**
plaintext
modules/aws-ec2-instance/
├── main.tf          # Primary configuration
├── variables.tf     # Input variables
├── outputs.tf       # Output definitions
├── versions.tf      # Version constraints
├── README.md        # Documentation
└── examples/        # Example implementations
```

2. **Variable Validation**
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition     = can(regex("^t[23].", var.instance_type))
    error_message = "Instance type must be t2.* or t3.* series."
  }
}
```

#### Troubleshooting Lab 2

1. **Module Path Issues**
```bash
Error: Module not found

Module "web_server" (main.tf:2) source "./modules/aws-ec2-instance" does not exist.
```

**Solution:**
- Verify directory structure
- Check relative paths
```bash
# Verify module path
ls -R modules/
tree modules/
```

```## Lab 3: Module Composition
### Duration: 75 minutes

### Lab Objectives
- Compose multiple modules
- Handle module dependencies
- Implement conditional module usage
- Use module count and for_each

### Steps

#### 1. Create Application Stack Module

```hcl
# modules/app-stack/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
}
```

```hcl
# modules/app-stack/main.tf
# Security Group Module
module "security_group" {
  source = "../security-group"

  name   = "${var.environment}-app-sg"
  vpc_id = var.vpc_id
}

# EC2 Instances Module
module "instances" {
  source   = "../aws-ec2-instance"
  count    = var.instance_count

  instance_name = "${var.environment}-app-${count.index + 1}"
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]
  
  vpc_security_group_ids = [module.security_group.security_group_id]

  tags = {
    Environment = var.environment
    Role        = "application"
  }
}

# Load Balancer (conditional)
module "alb" {
  source = "../alb"
  count  = var.environment == "production" ? 1 : 0

  name               = "${var.environment}-alb"
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  instance_ids       = module.instances[*].instance_id
  security_group_ids = [module.security_group.security_group_id]
}
```

#### 2. Implement Root Configuration

```hcl
# root/main.tf
# Create multiple environments
locals {
  environments = {
    development = {
      instance_count = 1
      instance_type  = "t2.micro"
    }
    production = {
      instance_count = 2
      instance_type  = "t2.small"
    }
  }
}

# Create app stack for each environment
module "app_stack" {
  for_each = local.environments
  source   = "./modules/app-stack"

  environment     = each.key
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnets
  instance_count = each.value.instance_count

  providers = {
    aws = aws
  }
}
```

### Lab 3 Advanced Concepts

#### Module Composition Patterns

1. **Layered Architecture**
plaintext
Root Module
├── Networking Layer (VPC, Subnets)
├── Security Layer (Security Groups)
├── Data Layer (RDS, ElastiCache)
└── Application Layer (EC2, ALB)
```

2. **State Dependencies**
```hcl
# Explicit dependency
module "application" {
  source = "./modules/app-stack"
  
  depends_on = [
    module.networking,
    module.security
  ]
}
```

#### Advanced Module Features

1. **Dynamic Block Usage**
```hcl
resource "aws_security_group" "example" {
  name = "dynamic-sg"

  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

2. **Conditional Creation**
```hcl
module "backup" {
  source = "./modules/backup"
  count  = var.environment == "production" ? 1 : 0

  retention_days = 30
  backup_schedule = "0 1 * * *"
}
```

### Best Practices Checklist

#### Module Development
- [ ] Use consistent naming conventions
- [ ] Implement proper variable validation
- [ ] Include comprehensive documentation
- [ ] Add example configurations
- [ ] Test modules in isolation

#### Module Usage
- [ ] Lock module versions
- [ ] Use consistent tagging
- [ ] Implement proper error handling
- [ ] Follow least privilege principle
- [ ] Regular security updates

### Additional Validation Steps

```bash
# Verify module structure
tree -a modules/

# Validate configurations
terraform fmt -recursive
terraform validate

# Check security best practices
tfsec .

# Run module tests (if available)
cd modules/aws-ec2-instance/tests
go test -v
```

### Common Troubleshooting Commands

```bash
# Show module tree
terraform graph | dot -Tsvg > graph.svg

# Debug module issues
TF_LOG=DEBUG terraform plan

# Verify state
terraform show
terraform state list

# Clean up
terraform state rm module.problematic_module
terraform init -reconfigure
```

```## Additional Resources
- [Terraform Module Documentation](https://www.terraform.io/docs/modules/index.html)
- [AWS VPC Module Documentation](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Module Development Guide](https://www.terraform.io/docs/modules/development.html)

```