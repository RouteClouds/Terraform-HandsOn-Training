# Terraform Variables - Labs

## Lab 1: Basic Variable Usage
![ Basic Variable Usage](/05-terraform-variables/05-diagrams/05-labs-diagrams/lab1_diagram.png)
### Objective
Learn to work with basic input variables and outputs.

### Tasks
1. Create Basic Variable Definitions
```hcl
# variables.tf
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}
```

2. Implement Variable Usage
```hcl
# main.tf
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = {
    Name = var.instance_name
  }
}
```

3. Define Outputs
```hcl
# outputs.tf
output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.example.public_ip
}
```

### Validation Steps
- [ ] Variables properly defined
- [ ] Resources using variables
- [ ] Outputs displaying correctly

## Lab 2: Variable Types and Validation
![ Variable Types and Validation](/05-terraform-variables/05-diagrams/05-labs-diagrams/lab2_diagram.png)
### Objective
Master different variable types and implement validation rules.

### Tasks
1. Create Complex Variable Types
```hcl
# variables.tf
variable "instance_config" {
  description = "EC2 instance configuration"
  type = object({
    instance_type = string
    environment   = string
    count        = number
  })
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.instance_config.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(number)
  default     = [80, 443, 22]
}
```

2. Implement Map Variables
```hcl
variable "instance_tags" {
  description = "Tags for EC2 instances"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-labs"
    ManagedBy   = "terraform"
  }
}
```

### Validation Steps
- [ ] Complex types working
- [ ] Validation rules enforced
- [ ] Maps properly applied

## Lab 3: Variable Files and Precedence
![ Variable Files and Precedence](/05-terraform-variables/05-diagrams/05-labs-diagrams/lab3_diagram.png)
### Objective
Understand variable file usage and precedence order.

### Tasks
1. Create terraform.tfvars
```hcl
# terraform.tfvars
aws_region    = "us-east-1"
instance_type = "t2.micro"
instance_name = "terraform-demo"
```

2. Create Environment-Specific Files
```hcl
# prod.tfvars
environment = "production"
instance_type = "t2.medium"
instance_count = 3
```

3. Test Variable Precedence
```bash
# Test different variable sources
export TF_VAR_instance_type="t2.small"
terraform plan -var="instance_type=t2.large"
terraform plan -var-file="prod.tfvars"
```

### Validation Steps
- [ ] Variable files loaded
- [ ] Precedence order correct
- [ ] Environment variables working

## Lab 4: Sensitive Variables and Outputs
![Sensitive Variables and Outputs](/05-terraform-variables/05-diagrams/05-labs-diagrams/lab4_diagram.png)
### Objective
Handle sensitive information securely in Terraform.

### Tasks
1. Define Sensitive Variables
```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API Key"
  type        = string
  sensitive   = true
}
```

2. Use Sensitive Outputs
```hcl
output "db_connection_string" {
  description = "Database connection string"
  value       = "postgresql://${var.db_user}:${var.database_password}@${aws_db_instance.example.endpoint}/mydb"
  sensitive   = true
}
```

### Validation Steps
- [ ] Sensitive values masked
- [ ] Secure handling working
- [ ] Output protection verified

## Best Practices
1. Variable Organization
   - Group related variables
   - Use descriptive names
   - Include proper descriptions

2. Security
   - Mark sensitive variables
   - Use variable files
   - Implement validation

3. Maintainability
   - Use consistent naming
   - Document all variables
   - Follow type constraints

## Troubleshooting Guide
1. Variable Loading Issues
```bash
# Check variable definitions
terraform console
> var.instance_type

# Verify variable files
terraform plan -var-file="custom.tfvars"
```

2. Validation Errors
```bash
# Test variable values
terraform validate

# Debug variable content
terraform console
> var.instance_config
```

3. Sensitive Data Issues
```bash
# Check sensitive output
terraform output db_connection_string

# Verify sensitive marking
terraform show
```

## Additional Challenges
1. Create a complex variable structure for a multi-tier application
2. Implement custom validation rules
3. Use dynamic blocks with variables
4. Create environment-specific configurations 