# Terraform Code Lab 2.1: CLI & AWS Provider Configuration

## 📋 **Overview**

This Terraform Code Lab demonstrates practical implementation of Terraform CLI installation, configuration, and AWS Provider setup. The lab provides hands-on experience with enterprise-grade configuration patterns, security best practices, and multi-environment deployment strategies.

## 🎯 **Learning Objectives**

By completing this code lab, you will gain practical experience with:

1. **Terraform CLI Configuration** - Version management, provider setup, and backend configuration
2. **AWS Provider Authentication** - Multiple authentication methods and security implementation
3. **Enterprise Configuration Patterns** - Multi-environment setup, tagging strategies, and governance
4. **Security Best Practices** - Encryption, access controls, and compliance implementation
5. **Cost Management** - Budget controls, resource optimization, and cost allocation

## 🏗️ **Infrastructure Components**

This lab creates the following AWS resources:

### **Core Infrastructure**
- **S3 Buckets**: Terraform state storage with versioning and encryption
- **DynamoDB Table**: State locking mechanism for team collaboration
- **IAM Role**: Terraform execution permissions with least privilege
- **KMS Key**: Encryption key for resource security (optional)

### **Monitoring and Governance**
- **CloudWatch Log Group**: Terraform operation logging (optional)
- **AWS Budget**: Cost control and monitoring
- **Resource Tags**: Comprehensive tagging for governance and cost allocation

### **Validation Resources**
- **Provider Test Buckets**: Validation of multiple provider configurations
- **Multi-Region Resources**: Cross-region deployment testing

## 📁 **File Structure**

```
Terraform-Code-Lab-2.1/
├── README.md                 # This documentation file
├── providers.tf              # Terraform and AWS provider configuration
├── variables.tf              # Input variable definitions
├── locals.tf                 # Local values and computed configurations
├── main.tf                   # Main infrastructure resources
├── outputs.tf                # Output value definitions
└── terraform.tfvars          # Variable values (example configuration)
```

## 🚀 **Quick Start Guide**

### **Prerequisites**
1. **Terraform CLI**: Version ~> 1.13.0 installed and configured
2. **AWS CLI**: Version 2.15.0+ with configured credentials
3. **AWS Account**: Active account with appropriate permissions
4. **Git**: For version control and collaboration

### **Step 1: Clone and Setup**
```bash
# Navigate to the lab directory
cd 02-Terraform-CLI-AWS-Provider-Configuration/Terraform-Code-Lab-2.1

# Copy example variables file
cp terraform.tfvars terraform.tfvars.local

# Edit variables for your environment
nano terraform.tfvars.local
```

### **Step 2: Configure AWS Authentication**
```bash
# Option 1: AWS CLI Profile
aws configure --profile terraform-lab
export AWS_PROFILE=terraform-lab

# Option 2: Environment Variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Verify authentication
aws sts get-caller-identity
```

### **Step 3: Initialize Terraform**
```bash
# Initialize Terraform working directory
terraform init

# Validate configuration
terraform validate

# Format configuration files
terraform fmt -recursive
```

### **Step 4: Plan and Apply**
```bash
# Generate execution plan
terraform plan -var-file="terraform.tfvars.local"

# Apply configuration (after reviewing plan)
terraform apply -var-file="terraform.tfvars.local"
```

### **Step 5: Verify Deployment**
```bash
# List created resources
terraform state list

# Show specific resource details
terraform show aws_s3_bucket.terraform_state

# Verify AWS resources
aws s3 ls | grep terraform-lab
aws dynamodb list-tables | grep terraform-state-lock
```

## 🔧 **Configuration Options**

### **Environment-Specific Configuration**
```bash
# Development environment
terraform apply -var="environment=dev" -var="budget_limit=25"

# Staging environment
terraform apply -var="environment=staging" -var="budget_limit=100"

# Production environment
terraform apply -var="environment=prod" -var="budget_limit=500"
```

### **Feature Flags**
```hcl
# Enable/disable specific features
feature_flags = {
  enable_logging          = true
  enable_metrics         = true
  enable_tracing         = false
  enable_auto_scaling    = false
  enable_load_balancing  = false
  enable_ssl_termination = true
}
```

### **Security Configuration**
```hcl
# Security settings
encryption_at_rest = true
encryption_in_transit = true
data_classification = "internal"
compliance_requirements = ["SOC2", "PCI-DSS"]
```

## 🔐 **Security Best Practices**

### **Authentication Methods**
1. **Development**: AWS CLI profiles with MFA
2. **CI/CD**: OIDC federation with temporary credentials
3. **Production**: IAM roles with cross-account access

### **Encryption and Security**
- **Encryption at Rest**: All storage resources encrypted
- **Encryption in Transit**: TLS/SSL for all communications
- **Access Controls**: Least privilege IAM policies
- **Audit Trails**: CloudTrail and CloudWatch logging

### **Credential Management**
```bash
# Never commit credentials to version control
echo "terraform.tfvars.local" >> .gitignore
echo "*.tfvars.local" >> .gitignore

# Use environment variables for sensitive values
export TF_VAR_external_id="secure-external-id"
export TF_VAR_mfa_device_arn="arn:aws:iam::123456789012:mfa/username"
```

## 💰 **Cost Management**

### **Budget Configuration**
- **Default Budget**: $50/month with 80% and 100% alerts
- **Environment-based**: Different limits for dev/staging/prod
- **Cost Allocation**: Comprehensive tagging for chargeback

### **Cost Optimization Features**
- **Resource Right-sizing**: Environment-appropriate instance types
- **Lifecycle Management**: Automated cleanup and archival
- **Monitoring**: Cost tracking and optimization recommendations

## 🧪 **Testing and Validation**

### **Configuration Testing**
```bash
# Syntax validation
terraform validate

# Security scanning (if tools available)
tfsec .
checkov -f main.tf

# Plan validation
terraform plan -detailed-exitcode
```

### **Provider Validation**
```bash
# Test provider configuration
terraform providers

# Validate authentication
aws sts get-caller-identity --profile terraform-lab

# Test resource creation
terraform apply -target=aws_s3_bucket.provider_test_default
```

### **Multi-Environment Testing**
```bash
# Test workspace functionality
terraform workspace new dev
terraform workspace new staging
terraform workspace list

# Environment-specific deployment
terraform workspace select dev
terraform apply -var-file="environments/dev.tfvars"
```

## 🔄 **Workspace Management**

### **Creating Workspaces**
```bash
# Create environment-specific workspaces
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# Switch between workspaces
terraform workspace select development
terraform workspace show
```

### **Environment Isolation**
```bash
# Deploy to different environments
terraform workspace select development
terraform apply -var="environment=dev"

terraform workspace select staging
terraform apply -var="environment=staging"
```

## 📊 **Monitoring and Observability**

### **CloudWatch Integration**
- **Log Groups**: Terraform operation logging
- **Metrics**: Resource utilization and performance
- **Dashboards**: Infrastructure health monitoring
- **Alarms**: Proactive alerting and notifications

### **Cost Monitoring**
- **AWS Budgets**: Monthly cost limits and alerts
- **Cost Explorer**: Detailed cost analysis and trends
- **Resource Tagging**: Cost allocation and chargeback

## 🛠️ **Troubleshooting**

### **Common Issues**

**1. Authentication Errors**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify profile configuration
aws configure list --profile terraform-lab

# Test permissions
aws s3 ls
```

**2. Provider Version Conflicts**
```bash
# Clear provider cache
rm -rf .terraform/
terraform init

# Lock provider versions
terraform providers lock -platform=linux_amd64
```

**3. State Lock Issues**
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID

# Check DynamoDB table
aws dynamodb scan --table-name terraform-state-lock
```

### **Debug Mode**
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log

# Run with debug output
terraform plan
terraform apply

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

## 🧹 **Cleanup**

### **Resource Cleanup**
```bash
# Destroy all resources
terraform destroy -var-file="terraform.tfvars.local"

# Selective destruction
terraform destroy -target=aws_s3_bucket.provider_test_default

# Clean up workspaces
terraform workspace select default
terraform workspace delete development
```

### **State Cleanup**
```bash
# Remove from state without destroying
terraform state rm aws_s3_bucket.terraform_state

# Import existing resources
terraform import aws_s3_bucket.existing bucket-name
```

## 📚 **Additional Resources**

### **Documentation**
- [Terraform CLI Documentation](https://www.terraform.io/docs/cli/index.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### **Training Materials**
- **Concept.md**: Theoretical foundation and best practices
- **Lab-2.md**: Hands-on exercises and guided implementation
- **Test-Your-Understanding-Topic-2.md**: Assessment and validation

### **Community Resources**
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
- [AWS Terraform Examples](https://github.com/hashicorp/terraform-provider-aws/tree/main/examples)
- [Terraform Registry](https://registry.terraform.io/)

---

## 📞 **Support**

For questions or issues with this lab:
1. Review the troubleshooting section above
2. Check the main training documentation
3. Consult the official Terraform and AWS documentation
4. Follow enterprise development standards and practices

---

*This code lab provides practical, hands-on experience with Terraform CLI and AWS Provider configuration, supporting the theoretical concepts covered in Topic 2 of the AWS Terraform Training curriculum.*
