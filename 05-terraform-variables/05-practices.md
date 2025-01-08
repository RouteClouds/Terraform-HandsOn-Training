# Terraform Variables - Practice Exercises

## Practice 1: Basic Variable Usage
### Objective
Create an EC2 instance using variables for all configurable parameters.

### Tasks
1. Create Variable Definitions
```hcl
# variables.tf
variable "instance_config" {
  description = "EC2 instance configuration"
  type = object({
    ami_id        = string
    instance_type = string
    name          = string
    environment   = string
  })
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}
```

2. Implement Resource Configuration
```hcl
# main.tf
resource "aws_instance" "example" {
  ami           = var.instance_config.ami_id
  instance_type = var.instance_config.instance_type

  tags = merge(
    var.tags,
    {
      Name = var.instance_config.name
    }
  )
}
```

### Validation
```bash
# Verify variable definitions
terraform validate

# Plan with variables
terraform plan -var-file="dev.tfvars"
```

## Practice 2: Variable Types and Validation
### Objective
Implement complex variable types with validation rules.

### Tasks
1. Create List and Map Variables
```hcl
variable "allowed_instance_types" {
  type = list(string)
  default = ["t2.micro", "t2.small", "t3.micro"]
  
  validation {
    condition     = length(var.allowed_instance_types) > 0
    error_message = "At least one instance type must be specified."
  }
}

variable "environment_configs" {
  type = map(object({
    instance_count = number
    instance_type  = string
  }))
  
  validation {
    condition     = alltrue([for k, v in var.environment_configs : 
                    contains(["dev", "staging", "prod"], k)])
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Validation
```bash
# Test validation rules
terraform console
> var.environment_configs.dev.instance_count
```

## Practice 3: Variable Files
### Objective
Create environment-specific configurations using variable files.

### Tasks
1. Create Base Variables
```hcl
# terraform.tfvars
region = "us-east-1"
project = "practice-exercise"
```

2. Create Environment-Specific Files
```hcl
# dev.tfvars
environment = "dev"
instance_type = "t2.micro"
instance_count = 1

# prod.tfvars
environment = "prod"
instance_type = "t2.medium"
instance_count = 3
```

### Validation
```bash
# Test different environments
terraform plan -var-file="dev.tfvars"
terraform plan -var-file="prod.tfvars"
```

## Practice 4: Sensitive Data Handling
### Objective
Implement secure variable handling for sensitive data.

### Tasks
1. Create Sensitive Variables
```hcl
variable "database_credentials" {
  type = object({
    username = string
    password = string
  })
  sensitive = true
}

variable "api_keys" {
  type      = map(string)
  sensitive = true
}
```

2. Implement Secure Output
```hcl
output "db_connection" {
  value = {
    host     = aws_db_instance.main.endpoint
    username = var.database_credentials.username
    database = aws_db_instance.main.name
  }
  sensitive = true
}
```

### Security Validation
```bash
# Verify sensitive value handling
terraform show
terraform output -json
```

## Additional Challenges
1. Create a module that accepts variable inputs
2. Implement dynamic block using variables
3. Create a complete VPC configuration using variables
4. Implement conditional resource creation based on variable values 