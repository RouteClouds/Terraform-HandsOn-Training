# Terraform Associate Certification - Quick Reference Guide

**Quick Reference for Exam Preparation**  
**Last Updated**: October 21, 2025

---

## TERRAFORM WORKFLOW

```
terraform init → terraform validate → terraform plan → terraform apply → terraform destroy
```

---

## ESSENTIAL COMMANDS

### Initialization & Validation
```bash
terraform init              # Initialize working directory
terraform validate          # Check syntax (NOT permissions)
terraform fmt              # Format code
terraform fmt -check       # Check formatting without changes
```

### Planning & Applying
```bash
terraform plan                      # Preview changes
terraform plan -out=tfplan         # Save plan to file
terraform apply                     # Apply changes
terraform apply tfplan             # Apply saved plan
terraform destroy                   # Remove infrastructure
```

### State Management
```bash
terraform state list               # List resources in state
terraform state show <resource>    # Show resource details
terraform state rm <resource>      # Remove from state
terraform state mv <old> <new>     # Move resource
terraform refresh                  # Sync state with actual
```

### Debugging
```bash
terraform console                  # Interactive console
terraform graph                    # Show resource graph
terraform import <type>.<name> <id> # Import existing resource
terraform taint <resource>         # Mark for replacement
terraform untaint <resource>       # Unmark for replacement
```

---

## RESOURCE SYNTAX

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server"
  }
}
```

---

## VARIABLE TYPES

| Type | Example | Use Case |
|------|---------|----------|
| `string` | `"us-east-1"` | Text values |
| `number` | `2` | Numeric values |
| `bool` | `true` | Boolean values |
| `list` | `["a", "b"]` | Ordered collections |
| `map` | `{key = "value"}` | Key-value pairs |
| `set` | `toset(["a", "b"])` | Unique collections |
| `object` | `{name = "John"}` | Structured data |
| `tuple` | `["a", 1, true]` | Fixed-length collections |

---

## VARIABLE PRECEDENCE

1. **Command-line flags** (`-var`)
2. **Variable files** (`.tfvars`)
3. **Environment variables** (`TF_VAR_*`)
4. **Default values**

---

## BACKEND CONFIGURATION

### S3 Backend with Locking
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

---

## MODULE SYNTAX

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
}

# Reference module output
output "vpc_id" {
  value = module.vpc.vpc_id
}
```

---

## RESOURCE REFERENCES

```hcl
# Reference resource attribute
aws_instance.web.id

# Reference resource in list
aws_instance.web[0].id

# Reference module output
module.vpc.vpc_id

# Reference variable
var.instance_type

# Reference local value
local.common_tags
```

---

## DEPENDENCIES

### Implicit Dependencies
```hcl
resource "aws_instance" "web" {
  subnet_id = aws_subnet.private.id  # Implicit dependency
}
```

### Explicit Dependencies
```hcl
resource "aws_instance" "web" {
  depends_on = [aws_security_group.web]
}
```

---

## SENSITIVE DATA

### Mark Variable as Sensitive
```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

### Mark Output as Sensitive
```hcl
output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
```

---

## TERRAFORM CLOUD/ENTERPRISE

### Remote Backend
```hcl
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "my-workspace"
    }
  }
}
```

---

## COMMON PATTERNS

### Count
```hcl
resource "aws_instance" "web" {
  count         = 3
  instance_type = "t2.micro"
}

# Reference: aws_instance.web[0].id
```

### For Each
```hcl
resource "aws_instance" "web" {
  for_each      = toset(["web1", "web2"])
  instance_type = "t2.micro"
}

# Reference: aws_instance.web["web1"].id
```

### Conditional
```hcl
resource "aws_instance" "web" {
  count         = var.create_instance ? 1 : 0
  instance_type = "t2.micro"
}
```

---

## VALIDATION RULES

```hcl
variable "instance_type" {
  type = string
  
  validation {
    condition     = contains(["t2.micro", "t2.small"], var.instance_type)
    error_message = "Instance type must be t2.micro or t2.small."
  }
}
```

---

## DEBUGGING

### Enable Logging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform.log
```

### Log Levels
- `TRACE`: Most verbose
- `DEBUG`: Detailed information
- `INFO`: General information
- `WARN`: Warnings
- `ERROR`: Errors only

---

## EXAM TIPS

💡 **Tip 1**: Know the Terraform workflow order  
💡 **Tip 2**: `terraform validate` checks syntax, NOT permissions  
💡 **Tip 3**: Always review `terraform plan` before applying  
💡 **Tip 4**: Never commit state files to Git  
💡 **Tip 5**: Use remote backends in production  
💡 **Tip 6**: Know variable precedence  
💡 **Tip 7**: Understand implicit vs explicit dependencies  
💡 **Tip 8**: Mark sensitive data appropriately  
💡 **Tip 9**: Know module structure and sources  
💡 **Tip 10**: Understand state locking and management  

---

**Quick Reference Version**: 1.0  
**Status**: Ready for Use

