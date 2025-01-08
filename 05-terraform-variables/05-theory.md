# Terraform Variables and Outputs

## 1. Introduction to Variables
![Introduction to Variables)](/05-terraform-variables/05-diagrams/05-theory-diagrams/terraform_variables_concept.png)
### 1.1 What are Terraform Variables?
Variables in Terraform serve as parameters for your infrastructure code, making it more flexible and reusable.

### 1.2 Why Use Variables?
- Reusability across environments
- Secure sensitive information
- Simplify configuration management
- Enable team collaboration

## 2. Types of Variables
### 2.1 Input Variables
```hcl
# String variable
variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "terraform-demo"
}

# Number variable
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

# List variable
variable "availability_zones" {
  description = "AZ to create resources in"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Map variable
variable "instance_tags" {
  description = "Tags for instances"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "demo"
  }
}
```

### 2.2 Local Variables
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
}
```

## 3. Variable Definition Files
### 3.1 terraform.tfvars
```hcl
# terraform.tfvars
instance_name = "prod-server"
instance_count = 3
availability_zones = ["us-west-2a", "us-west-2b"]
```

### 3.2 Other .tfvars Files
```hcl
# prod.tfvars
environment = "production"
instance_type = "t2.medium"
```

## 4. Variable Validation
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

## 5. Output Values
### 5.1 Basic Outputs
```hcl
output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.example.public_ip
}
```

### 5.2 Complex Outputs
```hcl
output "instance_details" {
  description = "Map of instance details"
  value = {
    id         = aws_instance.example.id
    public_ip  = aws_instance.example.public_ip
    private_ip = aws_instance.example.private_ip
    tags       = aws_instance.example.tags
  }
}
```

## 6. Variable Precedence
1. Environment variables (TF_VAR_*)
2. terraform.tfvars file
3. *.auto.tfvars files
4. Command line flags (-var or -var-file)

## 7. Best Practices
### 7.1 Variable Organization
- Group related variables
- Use descriptive names
- Include proper descriptions
- Set appropriate defaults

### 7.2 Security Considerations
```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

### 7.3 Documentation
- Document all variables
- Include usage examples
- Specify valid values
- Explain validation rules

## 8. Common Patterns
### 8.1 Conditional Resource Creation
```hcl
variable "create_database" {
  description = "Whether to create database"
  type        = bool
  default     = false
}

resource "aws_db_instance" "example" {
  count = var.create_database ? 1 : 0
  # ... other configuration ...
}
```

### 8.2 Dynamic Block Generation
```hcl
variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

resource "aws_security_group" "example" {
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
``` 