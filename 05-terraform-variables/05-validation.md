# Terraform Variables - Practice Test

## Section 1: Multiple Choice

1. Which variable type is used for true/false values in Terraform?
   - [ ] string
   - [ ] number
   - [x] bool
   - [ ] list

2. What is the correct way to reference a variable in Terraform?
   - [ ] ${variable.name}
   - [x] var.name
   - [ ] vars.name
   - [ ] variable.name

3. Which file is automatically loaded by Terraform for variable values?
   - [x] terraform.tfvars
   - [ ] variables.tf
   - [ ] terraform.tf
   - [ ] auto.tfvars

## Section 2: Hands-On Tasks

1. Create a variable for environment with validation:
   ```hcl
   variable "environment" {
     type        = string
     description = "Environment name"
     validation {
       condition     = contains(["dev", "staging", "prod"], var.environment)
       error_message = "Environment must be dev, staging, or prod."
     }
   }
   ```

2. Implement a sensitive output:
   ```hcl
   output "database_password" {
     value     = aws_db_instance.example.password
     sensitive = true
   }
   ```

## Section 3: True/False

1. Variables marked as sensitive are encrypted in the state file.
   - [ ] True
   - [x] False

2. Terraform can automatically convert between number and string types.
   - [ ] True
   - [x] False

## Section 4: Fill in the Blanks

1. The ________ block is used to define output values in Terraform.
   **Answer:** output

2. To mark a variable as sensitive, set the ________ argument to true.
   **Answer:** sensitive

## Section 5: Practical Scenarios

1. You need to create multiple EC2 instances with different names. Which variable type would you use?
   **Answer:** map or list

2. How would you handle database credentials securely in Terraform?
   **Answer:** Use sensitive variables and AWS Secrets Manager 