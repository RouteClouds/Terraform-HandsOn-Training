# Topic 12 Lab: Advanced Security & Compliance - Code Examples

This directory contains working Terraform code examples for Topic 12 labs demonstrating security best practices.

## Files

- **providers.tf** - AWS provider with security configuration
- **variables.tf** - Input variables with sensitive data handling
- **main.tf** - Secure VPC architecture with security groups
- **outputs.tf** - Output values
- **README.md** - This file

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS account with VPC and security permissions
- Text editor

## Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Create terraform.tfvars

```hcl
aws_region           = "us-east-1"
environment          = "prod"
vpc_cidr             = "10.0.0.0/16"
private_subnet_cidr  = "10.0.1.0/24"
public_subnet_cidr   = "10.0.2.0/24"
db_username          = "admin"
db_password          = "SecurePassword123456!"
enable_encryption    = true
```

### 3. Validate Configuration

```bash
terraform validate
```

### 4. Plan Deployment

```bash
terraform plan
```

### 5. Apply Configuration

```bash
terraform apply
```

## Security Features

### Implemented Security Best Practices

✅ **VPC Isolation**: Public and private subnets  
✅ **Least Privilege**: Security groups with minimal permissions  
✅ **Encryption**: KMS key for data encryption  
✅ **Sensitive Data**: Marked variables and outputs  
✅ **Compliance Tagging**: PCI-DSS compliance tags  
✅ **Network Segmentation**: Separate security groups per tier  

### Security Groups

**ALB Security Group**:
- Ingress: HTTPS (443) and HTTP (80) from internet
- Egress: To VPC CIDR only

**Application Security Group**:
- Ingress: HTTP (80) from ALB only
- Egress: To internet

**Database Security Group**:
- Ingress: MySQL (3306) from app only
- Egress: None (no outbound access)

## Sensitive Data Handling

### Variables

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

### Outputs

```hcl
output "security_summary" {
  value = { ... }
  # Non-sensitive output
}
```

## Encryption

### KMS Key

- Automatic key rotation enabled
- 10-day deletion window
- Used for data encryption

## Compliance

### Tagging Strategy

All resources tagged with:
- `Compliance`: PCI-DSS
- `Owner`: Security
- `CostCenter`: Engineering
- `Environment`: prod
- `ManagedBy`: Terraform

## Outputs

After applying, view outputs:

```bash
terraform output
terraform output vpc_id
terraform output security_summary
```

## Lab Exercises

### Exercise 1: Implement Secrets Management
1. Create AWS Secrets Manager secret
2. Reference secret in Terraform
3. Mark variables as sensitive
4. Apply configuration
5. Verify secret is not exposed

### Exercise 2: Secure State Backend
1. Create S3 bucket for state
2. Enable encryption
3. Configure DynamoDB for locking
4. Migrate state to S3
5. Verify remote state

### Exercise 3: Secure VPC Architecture
1. Create VPC with subnets
2. Configure security groups
3. Implement least privilege
4. Add compliance tagging
5. Verify network isolation

## Cleanup

Destroy resources when done:

```bash
terraform destroy
```

## Best Practices

✅ Always mark sensitive variables  
✅ Encrypt state files  
✅ Use least privilege access  
✅ Implement compliance tagging  
✅ Enable audit logging  
✅ Use security groups properly  
✅ Rotate encryption keys  
✅ Document security policies  

## Additional Resources

- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [Terraform Security](https://www.terraform.io/docs/language/state/sensitive-data.html)
- [VPC Security](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html)
- [KMS Documentation](https://docs.aws.amazon.com/kms/)

---

**Lab Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Ready for Use

