# Lab 4: Sensitive Variables

## Overview
Learn to handle sensitive information securely using AWS RDS and Secrets Manager.

## Files
- `c1-versions.tf` - Provider and version configurations
- `c2-variables.tf` - Variable definitions including sensitive variables
- `c3-rds.tf` - RDS and Secrets Manager resources
- `c4-outputs.tf` - Secure output configurations
- `terraform.tfvars` - Non-sensitive variable values
- `secrets.tfvars` - Sensitive variable values (not committed)
- `.gitignore` - Git ignore patterns

## Prerequisites
1. Completed Lab 3
2. Understanding of AWS RDS
3. Knowledge of AWS Secrets Manager
4. Basic security practices

## Lab Steps

### 1. Sensitive Variable Definition
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

### 2. Secure Storage Configuration
```hcl
# AWS Secrets Manager configuration
resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.environment}/database/credentials"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
```

### 3. Sensitive Output Handling
```hcl
output "db_connection_info" {
  value = {
    endpoint = aws_db_instance.main.endpoint
    database = aws_db_instance.main.db_name
  }
  sensitive = true
}
```

## Execution Steps
```bash
# Initialize with backend
terraform init

# Plan with sensitive values
terraform plan -var-file="secrets.tfvars"

# Apply configuration
terraform apply -var-file="secrets.tfvars"

# Safely check outputs
terraform output -json
```

## Security Checklist
- [ ] Sensitive variables marked correctly
- [ ] Secrets stored in AWS Secrets Manager
- [ ] Sensitive outputs properly marked
- [ ] .gitignore configured correctly
- [ ] State file secured

## Common Issues and Solutions
1. Sensitive Value Exposure
   ```bash
   # Check for sensitive values in plan
   terraform show
   ```

2. Secrets Manager Access
   ```bash
   # Verify secret creation
   aws secretsmanager list-secrets
   ```

3. State File Security
   ```bash
   # Configure remote state
   terraform init -backend=true
   ```

## Security Best Practices
1. Never commit sensitive files
   - Use .gitignore
   - Use separate tfvars files
   - Use environment variables

2. Secure State Management
   - Use remote state
   - Enable encryption
   - Implement state locking

3. Access Control
   - Use IAM roles
   - Implement least privilege
   - Regular rotation of credentials

## Troubleshooting Guide
1. Sensitive Variable Issues
   - Check variable definitions
   - Verify sensitive marking
   - Review state file handling

2. Secrets Manager Problems
   - Verify IAM permissions
   - Check secret versions
   - Validate JSON formatting

3. Database Connection Issues
   - Verify security group rules
   - Check network access
   - Validate credentials