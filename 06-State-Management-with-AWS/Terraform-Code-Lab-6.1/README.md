# Terraform Code Lab 6.1: State Management with AWS

## 📋 Overview

This lab provides hands-on experience with **Terraform state management using AWS S3 and DynamoDB**. You'll learn to configure remote backends, implement state locking, manage workspaces, and handle state migration scenarios.

## 🎯 Learning Objectives

By completing this lab, you will:
- Configure enterprise-grade S3 backend with DynamoDB locking
- Implement state encryption and versioning
- Manage multiple environments using Terraform workspaces
- Practice state migration and backend transitions
- Understand state security and compliance patterns
- Troubleshoot common state management issues

## 🏗️ Architecture Overview

This lab creates:
- **S3 Bucket**: Encrypted state storage with versioning
- **DynamoDB Table**: State locking mechanism
- **KMS Key**: Custom encryption for sensitive state data
- **Demo VPC**: Infrastructure for state management testing
- **IAM Roles**: Secure access control for state operations
- **Monitoring**: CloudWatch metrics and alerts

## 📁 File Structure

```
Terraform-Code-Lab-6.1/
├── providers.tf                 # Provider and backend configuration
├── variables.tf                 # Variable definitions with validation
├── main.tf                     # Main infrastructure resources
├── outputs.tf                  # Output values and integration data
├── data.tf                     # Data sources and external references
├── locals.tf                   # Local values and calculations
├── terraform.tfvars.example    # Example variable configurations
├── README.md                   # This documentation
├── scripts/                    # Automation and utility scripts
│   ├── state_analyzer.py       # State analysis and validation
│   └── backend_migrator.py     # Backend migration automation
└── templates/                  # Configuration templates
    ├── backend.tpl             # Backend configuration template
    └── workspace-config.tpl    # Workspace configuration template
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform 1.13.0+** installed
3. **Python 3.9+** for automation scripts
4. **Git** for version control

### Required AWS Permissions

Your AWS credentials need the following permissions:
- S3: Full access for state bucket management
- DynamoDB: Full access for lock table management
- KMS: Key creation and management permissions
- IAM: Role and policy management
- VPC: Network resource management
- CloudWatch: Monitoring and logging

### Step 1: Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd 06-State-Management-with-AWS/Terraform-Code-Lab-6.1

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit variables for your environment
nano terraform.tfvars
```

### Step 2: Configure Variables

Edit `terraform.tfvars` with your specific values:

```hcl
# Basic Configuration
project_name = "your-project-name"
environment = "development"
owner = "your-name"
aws_region = "us-east-1"

# Email for notifications
notification_email = "your-email@example.com"

# Budget limit (USD)
budget_limit = 100
```

### Step 3: Initialize and Deploy

```bash
# Initialize Terraform (first time)
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

## 🔧 Advanced Configuration

### Multi-Environment Setup

Create environment-specific variable files:

```bash
# Development environment
cat > development.tfvars << EOF
environment = "development"
enable_detailed_monitoring = false
budget_limit = 50
enable_backup_region_resources = false
EOF

# Production environment
cat > production.tfvars << EOF
environment = "production"
enable_detailed_monitoring = true
budget_limit = 1000
enable_backup_region_resources = true
enable_cross_region_replication = true
EOF
```

Apply with specific environment:
```bash
terraform apply -var-file="development.tfvars"
terraform apply -var-file="production.tfvars"
```

### Workspace Management

```bash
# Create workspaces for different environments
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# Switch between workspaces
terraform workspace select development
terraform workspace select production

# List all workspaces
terraform workspace list

# Show current workspace
terraform workspace show
```

### Backend Migration

If you need to migrate from local to remote backend:

```bash
# 1. Configure backend in providers.tf
# 2. Initialize with migration
terraform init -migrate-state

# For reconfiguration
terraform init -reconfigure

# For backend configuration file
terraform init -backend-config=backend.hcl
```

## 🔐 Security Best Practices

### State File Security

1. **Encryption**: Always enable encryption at rest and in transit
2. **Access Control**: Use IAM roles with least privilege
3. **Versioning**: Enable S3 versioning for state history
4. **Backup**: Implement cross-region replication for DR

### Access Management

```bash
# Use IAM roles instead of access keys
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT:role/TerraformRole \
  --role-session-name terraform-session

# Enable MFA for production environments
aws sts get-session-token --serial-number arn:aws:iam::ACCOUNT:mfa/USER \
  --token-code 123456
```

### Sensitive Data Handling

```bash
# Use environment variables for sensitive values
export TF_VAR_external_id="your-secret-external-id"
export TF_VAR_notification_email="admin@yourcompany.com"

# Never commit terraform.tfvars to version control
echo "terraform.tfvars" >> .gitignore
echo "*.tfvars" >> .gitignore
```

## 🧪 Testing and Validation

### State Validation

```bash
# Validate state integrity
terraform state list
terraform state show aws_s3_bucket.terraform_state

# Pull and examine state
terraform state pull > current-state.json
cat current-state.json | jq '.version'
```

### Backend Testing

```bash
# Test state locking
terraform plan &  # Run in background
terraform plan    # Should show lock error

# Force unlock if needed (use carefully)
terraform force-unlock <lock-id>
```

### Automation Scripts

```bash
# Run state analysis
python3 scripts/state_analyzer.py

# Validate backend configuration
python3 scripts/backend_migrator.py --validate
```

## 📊 Monitoring and Troubleshooting

### CloudWatch Metrics

Monitor these key metrics:
- S3 bucket size and request count
- DynamoDB read/write capacity utilization
- State lock duration and frequency
- Failed operations count

### Common Issues and Solutions

#### Issue: State Lock Timeout
```bash
# Check for stuck locks
aws dynamodb scan --table-name terraform-state-locks

# Force unlock (last resort)
terraform force-unlock <lock-id>
```

#### Issue: Backend Configuration Error
```bash
# Reconfigure backend
terraform init -reconfigure

# Migrate state to new backend
terraform init -migrate-state
```

#### Issue: Permission Denied
```bash
# Check IAM permissions
aws sts get-caller-identity
aws iam simulate-principal-policy --policy-source-arn <role-arn> \
  --action-names s3:GetObject --resource-arns <bucket-arn>/*
```

## 💰 Cost Management

### Cost Optimization

- Use S3 Intelligent Tiering for large state files
- Enable lifecycle policies for old state versions
- Use DynamoDB on-demand billing for variable workloads
- Monitor costs with AWS Budgets

### Estimated Costs

| Resource | Monthly Cost (USD) |
|----------|-------------------|
| S3 Storage (1GB) | $0.50 |
| DynamoDB Table | $0.25 |
| KMS Key | $1.00 |
| Data Transfer | $0.10 |
| **Total** | **~$2.00** |

## 🔄 Cleanup

### Destroy Resources

```bash
# Destroy infrastructure (keep state backend)
terraform destroy -target=aws_vpc.demo
terraform destroy -target=aws_security_group.demo

# Full cleanup (including state backend)
terraform destroy

# Clean up workspaces
terraform workspace select default
terraform workspace delete development
terraform workspace delete staging
terraform workspace delete production
```

### Manual Cleanup

If Terraform destroy fails:

```bash
# Delete S3 bucket versions
aws s3api delete-objects --bucket <bucket-name> \
  --delete "$(aws s3api list-object-versions --bucket <bucket-name> \
  --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

# Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-state-locks

# Delete KMS key (after waiting period)
aws kms schedule-key-deletion --key-id <key-id> --pending-window-in-days 7
```

## 📚 Additional Resources

### Documentation
- [Terraform Backend Configuration](https://www.terraform.io/docs/backends/types/s3.html)
- [AWS S3 Backend](https://www.terraform.io/docs/backends/types/s3.html)
- [State Locking](https://www.terraform.io/docs/state/locking.html)
- [Workspace Management](https://www.terraform.io/docs/state/workspaces.html)

### Best Practices
- [Terraform State Best Practices](https://www.terraform.io/docs/state/index.html)
- [AWS Security Best Practices](https://aws.amazon.com/security/security-resources/)
- [Infrastructure as Code Security](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🤝 Support

### Getting Help
- Review the troubleshooting section above
- Check Terraform and AWS documentation
- Examine CloudWatch logs for detailed error information
- Use the automation scripts for validation and analysis

### Contributing
- Follow the established code style and patterns
- Add comprehensive variable validation
- Include security considerations in all changes
- Update documentation for new features

---

**Note**: This lab is designed for educational purposes. Always follow your organization's security policies and compliance requirements when implementing in production environments.
