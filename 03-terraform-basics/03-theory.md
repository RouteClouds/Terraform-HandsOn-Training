# Terraform Basics
![Terraform Basics Concept](/03-terraform-basics/03-diagrams/03-theory-diagrams/terraform_basics_concepts.png)
![Terraform Workflow)](/03-terraform-basics/03-diagrams/03-theory-diagrams/terraform_workflow.png)
## Overview
This section covers the fundamental concepts of Terraform, including its basic commands, configuration syntax, and core workflows.

## Learning Objectives
- Understand Terraform configuration language (HCL)
- Master basic Terraform commands
- Learn resource and provider concepts
- Understand variables and outputs
- Grasp state management basics

## 1. Terraform Configuration Language (HCL)
![Terraform Configuration Language (HCL)](/03-terraform-basics/03-diagrams/03-theory-diagrams/hcl_configuration_structure.png)
### Basic Syntax
```hcl
# Block syntax
<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Arguments
}

# Example
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

### Configuration Blocks
1. **Terraform Block**
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
```

2. **Provider Block**
```hcl
provider "aws" {
  region = "us-east-1"
  profile = "default"
}
```

3. **Resource Block**
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
  }
}
```

## 2. Basic Terraform Commands

### Core Workflow Commands
| Command | Description | Usage |
|---------|-------------|-------|
| terraform init | Initialize working directory | Initial setup |
| terraform plan | Create execution plan | Review changes |
| terraform apply | Apply changes | Create/update infrastructure |
| terraform destroy | Destroy infrastructure | Cleanup resources |

### Additional Commands
```bash
# Format configuration
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources
terraform state list
```

## 3. Resource Management (Enhanced)

### Understanding Resource Blocks
A resource block declares a resource of a specific type ("aws_instance", "aws_vpc", etc.) with a unique name that can be used to refer to this resource elsewhere in the same Terraform module.

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
    Environment = "Production"
  }
}
```

#### Resource Block Components:
1. **Resource Type** (`aws_instance`): Determines what kind of infrastructure object the resource manages
2. **Resource Name** (`web_server`): Local identifier for referring to this resource
3. **Resource Configuration**: Key-value pairs that configure the resource

### Resource Dependencies Explained
![Resource Dependencies)](/03-terraform-basics/03-diagrams/03-theory-diagrams/resource_dependencies.png)
#### 1. Implicit Dependencies
Terraform automatically determines dependencies when one resource references another using interpolation expressions:

```hcl
# VPC Resource
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnet Resource (implicitly depends on VPC)
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id  # Creates implicit dependency
  cidr_block = "10.0.1.0/24"
}

# EC2 Instance (implicitly depends on Subnet)
resource "aws_instance" "app" {
  subnet_id = aws_subnet.public.id  # Creates implicit dependency
  ami       = "ami-0c55b159cbfafe1f0"
}
```

#### 2. Explicit Dependencies
Used when there's a dependency that isn't visible to Terraform through resource arguments:

```hcl
# S3 Bucket
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

# EC2 Instance that needs the bucket to exist
resource "aws_instance" "processor" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  depends_on = [aws_s3_bucket.data]  # Explicit dependency
}
```

### Resource Lifecycle
Resources in Terraform go through several phases:

1. **Plan Phase**
   - Resource differences are identified
   - Required changes are determined
   ```bash
   terraform plan
   ```

2. **Apply Phase**
   - Resources are created, updated, or deleted
   - State file is updated
   ```bash
   terraform apply
   ```

3. **Destroy Phase**
   - Resources are removed
   - State file is updated
   ```bash
   terraform destroy
   ```

### Resource Meta-Arguments
Common arguments that can be used with any resource type:

```hcl
resource "aws_instance" "example" {
  # Count - Create multiple instances
  count = 3
  
  # Provider - Specify alternate provider
  provider = aws.alternate
  
  # Lifecycle - Customize resource behavior
  lifecycle {
    create_before_destroy = true
    prevent_destroy      = true
    ignore_changes      = [tags]
  }
  
  # Timeouts - Customize operation timeouts
  timeouts {
    create = "60m"
    delete = "2h"
  }
}
```

### Resource Targeting
Terraform allows you to target specific resources for operations:

```bash
# Plan changes for specific resource
terraform plan -target=aws_instance.example

# Apply changes to specific resource
terraform apply -target=aws_instance.example

# Destroy specific resource
terraform destroy -target=aws_instance.example
```

### Resource Import
Bringing existing infrastructure under Terraform management:

1. **Create Resource Configuration**
```hcl
resource "aws_instance" "imported" {
  # Configuration will be filled in after import
}
```

2. **Import Command**
```bash
terraform import aws_instance.imported i-1234567890abcdef0
```

### Resource Tagging Strategy
Implement consistent tagging for better resource management:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
  }
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = merge(
    local.common_tags,
    {
      Name = "Example Instance"
      Role = "Web Server"
    }
  )
}
```

## 4. Variables and Outputs
![Variable Types)](/03-terraform-basics/03-diagrams/03-theory-diagrams/variable_types_and_usage.png)
### Variable Types
```hcl
# String
variable "region" {
  type = string
  default = "us-east-1"
}

# Number
variable "instance_count" {
  type = number
  default = 1
}

# List
variable "availability_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

# Map
variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
}
```

### Output Definitions
```hcl
output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.example.public_ip
}
```

## 5. State Management
![State Management)](/03-terraform-basics/03-diagrams/03-theory-diagrams/state_management.png)

### State Basics
- State file (`terraform.tfstate`)
- State locking
- Remote state
- State operations

### State Commands
```bash
# List resources in state
terraform state list

# Show resource details
terraform state show aws_instance.example

# Move resource in state
terraform state mv aws_instance.example aws_instance.new

# Remove resource from state
terraform state rm aws_instance.example
```

## 6. Best Practices

### Code Organization
1. Use consistent naming
2. Implement proper formatting
3. Group related resources
4. Comment complex configurations
5. Use variables for reusability

### State Management
1. Use remote state
2. Enable state locking
3. Backup state files
4. Restrict state access
5. Use workspaces for separation

### Security
1. Never commit secrets
2. Use variables for sensitive data
3. Implement proper access controls
4. Review all changes
5. Use version control

## 7. Common Workflows

### Development Workflow
1. Write configuration
2. Initialize directory
3. Plan changes
4. Apply changes
5. Verify resources
6. Iterate as needed

### Maintenance Workflow
1. Update configuration
2. Review plan
3. Apply changes
4. Validate updates
5. Document changes

## Additional Resources

### Official Documentation
- [Terraform Language Documentation](https://www.terraform.io/docs/language/index.html)
- [Terraform CLI Documentation](https://www.terraform.io/docs/cli/index.html)
- [Provider Documentation](https://registry.terraform.io/browse/providers)

### Best Practice Guides
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [AWS with Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Practice Exercises
1. Create basic configurations
2. Implement variable usage
3. Manage resource dependencies
4. Work with state operations
5. Use different provider configurations
