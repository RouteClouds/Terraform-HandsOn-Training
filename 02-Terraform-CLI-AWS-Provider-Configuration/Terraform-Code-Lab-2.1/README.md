# AWS Terraform Training - Terraform CLI & AWS Provider Configuration

## 🎯 Lab 2.1: Advanced Provider Configuration and Authentication

### **Enterprise-Grade Terraform CLI Setup and Multi-Environment AWS Provider Configuration**

This lab demonstrates advanced Terraform CLI installation, configuration, and AWS Provider setup with multiple authentication methods, multi-region deployment, and enterprise security best practices.

---

## 📋 **Lab Overview**

### **Learning Objectives**
By completing this lab, you will:

1. **Install and configure Terraform CLI** with version management using tfenv
2. **Set up multiple AWS authentication methods** (profiles, IAM roles, SSO, assume role)
3. **Configure multi-region and cross-account providers** with aliases and advanced features
4. **Implement remote state backend** with S3 and DynamoDB for team collaboration
5. **Optimize development workflow** with automation scripts and IDE integration
6. **Troubleshoot common provider issues** and implement monitoring

### **Architecture Deployed**
- **Terraform CLI** with version management and optimization
- **Multiple AWS providers** with different authentication methods
- **Remote state backend** with S3 bucket and DynamoDB locking
- **Multi-region resources** across us-east-1, us-west-2, and us-west-1
- **Test resources** for provider validation and authentication testing
- **Cost optimization** with auto-shutdown Lambda function

### **Duration**: 120-150 minutes
### **Difficulty**: Intermediate to Advanced
### **Cost**: $1.00 - $2.00 per day (with auto-shutdown enabled)

---

## 🏗️ **Infrastructure Architecture**

```
┌─────────────────────────────────────────────────────────────────┐
│                    Terraform CLI & Provider Setup               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                 Terraform CLI                           │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │    │
│  │  │ tfenv       │ │ Provider    │ │ Performance     │   │    │
│  │  │ Version Mgmt│ │ Cache       │ │ Optimization    │   │    │
│  │  └─────────────┘ └─────────────┘ └─────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              AWS Provider Configuration                 │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │    │
│  │  │ Primary     │ │ Secondary   │ │ Disaster        │   │    │
│  │  │ us-east-1   │ │ us-west-2   │ │ Recovery        │   │    │
│  │  │             │ │             │ │ us-west-1       │   │    │
│  │  └─────────────┘ └─────────────┘ └─────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Authentication Methods                     │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │    │
│  │  │ AWS CLI     │ │ IAM Roles   │ │ AWS SSO         │   │    │
│  │  │ Profiles    │ │ Assume Role │ │ Integration     │   │    │
│  │  └─────────────┘ └─────────────┘ └─────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 **Quick Start Guide**

### **Prerequisites**
- **AWS Account** with appropriate permissions
- **Terminal/Command Line** access (Linux, macOS, or Windows WSL)
- **Git** for version control
- **Basic understanding** of AWS services and Terraform concepts

### **1. Clone and Setup**
```bash
# Navigate to the lab directory
cd 02-Terraform-CLI-AWS-Provider-Configuration/Terraform-Code-Lab-2.1

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit variables with your information
nano terraform.tfvars  # Update student_name and owner_email
```

### **2. Install Terraform CLI with tfenv**
```bash
# Install tfenv for version management
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install Terraform 1.13.2
tfenv install 1.13.2
tfenv use 1.13.2
terraform version
```

### **3. Configure AWS Authentication**
```bash
# Configure AWS CLI profiles
aws configure --profile development
aws configure --profile staging
aws configure --profile production

# Test authentication
aws sts get-caller-identity --profile development
```

### **4. Deploy Infrastructure**
```bash
# Initialize Terraform
terraform init

# Create and select workspace
terraform workspace new development
terraform workspace select development

# Plan deployment
terraform plan -var-file="terraform.tfvars"

# Apply configuration
terraform apply -var-file="terraform.tfvars"
```

### **5. Test Provider Configuration**
```bash
# Verify providers
terraform providers

# Check outputs
terraform output provider_configuration
terraform output aws_account_information
```

### **6. Cleanup**
```bash
# Destroy all resources
terraform destroy -var-file="terraform.tfvars"
```

---

## 📁 **File Structure and Components**

### **Core Terraform Files**
```
Terraform-Code-Lab-2.1/
├── providers.tf                  # Advanced provider configuration with aliases
├── variables.tf                  # 30+ variables with validation
├── main.tf                      # Test resources and state backend
├── outputs.tf                   # 15+ outputs with troubleshooting info
├── terraform.tfvars.example     # Multiple scenario configurations
├── templates/                   # Template files for testing
│   └── provider-test.tpl        # Provider validation template
├── scripts/                     # Automation and helper scripts
│   └── auto_shutdown.py         # Lambda function for cost optimization
└── README.md                    # This comprehensive documentation
```

### **Key Infrastructure Components**

#### **1. Terraform CLI Configuration**
- **tfenv version management** for consistent Terraform versions
- **Provider caching** for improved performance
- **CLI optimization** with environment variables and configuration
- **IDE integration** with VS Code and pre-commit hooks

#### **2. AWS Provider Configuration**
- **Multiple provider aliases** for multi-region and cross-account scenarios
- **Authentication methods** including profiles, assume role, and SSO
- **Performance optimization** with retry configuration and caching
- **Default tags** for comprehensive resource management

#### **3. Multi-Region Setup**
- **Primary region** (us-east-1) for main resources
- **Secondary region** (us-west-2) for multi-region testing
- **Disaster recovery region** (us-west-1) for backup scenarios
- **Cross-region resource deployment** with provider aliases

#### **4. Authentication Testing**
- **Provider validation** with data sources and test resources
- **Authentication verification** across multiple methods
- **Permission testing** with IAM roles and policies
- **Cross-account access** configuration and testing

#### **5. State Management**
- **S3 backend** with encryption and versioning
- **DynamoDB locking** for concurrent access protection
- **Workspace isolation** for multi-environment management
- **State security** with access controls and monitoring

#### **6. Cost Optimization**
- **Auto-shutdown Lambda** for resource management
- **Pay-per-request billing** for DynamoDB
- **Minimal resource footprint** for training environments
- **Cost tracking** with comprehensive tagging

---

## ⚙️ **Configuration Scenarios**

### **Scenario 1: Basic Development Setup**
```hcl
environment = "development"
aws_profile = "development"
enable_multi_region = false
create_test_resources = true
auto_shutdown_enabled = true
auto_shutdown_hours = 2
```
**Use Case**: Individual developer learning and testing
**Estimated Cost**: $0.50-$1.00/day

### **Scenario 2: Multi-Region Testing**
```hcl
environment = "development"
enable_multi_region = true
enable_multi_region_test = true
aws_profile = "development"
secondary_region = "us-west-2"
disaster_recovery_region = "us-west-1"
```
**Use Case**: Testing multi-region deployment patterns
**Estimated Cost**: $1.00-$2.00/day

### **Scenario 3: Enterprise Authentication**
```hcl
auth_method = "assume-role"
assume_role_arn = "arn:aws:iam::123456789012:role/TerraformRole"
session_duration = 3600
external_id = "your-external-id"
encryption_enabled = true
monitoring_enabled = true
```
**Use Case**: Enterprise security and compliance requirements
**Estimated Cost**: $2.00-$4.00/day

### **Scenario 4: AWS SSO Integration**
```hcl
auth_method = "aws-sso"
aws_profile = "sso-terraform"
development_profile = "sso-development"
staging_profile = "sso-staging"
production_profile = "sso-production"
```
**Use Case**: Organizations using AWS SSO for centralized authentication
**Estimated Cost**: $1.00-$2.00/day

---

## 🔐 **Authentication Methods Supported**

### **1. AWS CLI Profiles**
```bash
# Configure named profiles
aws configure --profile development
aws configure --profile staging
aws configure --profile production

# Use in Terraform
aws_profile = "development"
```

### **2. IAM Role Assumption**
```hcl
assume_role {
  role_arn     = "arn:aws:iam::123456789012:role/TerraformRole"
  session_name = "terraform-session"
  external_id  = "your-external-id"
}
```

### **3. AWS SSO Integration**
```bash
# Configure SSO
aws configure sso
aws sso login --profile sso-terraform

# Use in Terraform
aws_profile = "sso-terraform"
```

### **4. Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"
export AWS_REGION="us-east-1"
```

### **5. Instance Profiles** (for EC2)
```hcl
# Automatic authentication when running on EC2
# No explicit configuration needed
```

---

## 🔧 **Development Workflow Optimization**

### **1. Terraform CLI Configuration**
```bash
# ~/.terraformrc
plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true
```

### **2. Environment Variables**
```bash
# Performance optimization
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
export TF_CLI_ARGS_plan="-parallelism=10"
export TF_CLI_ARGS_apply="-parallelism=10"

# Debugging
export TF_LOG=INFO
export TF_LOG_PATH="./terraform.log"
```

### **3. IDE Integration**
```json
// .vscode/settings.json
{
  "terraform.languageServer": {
    "enabled": true
  },
  "terraform.validation.enableEnhancedValidation": true,
  "editor.formatOnSave": true
}
```

### **4. Pre-commit Hooks**
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
```

---

## 🧪 **Testing and Validation**

### **Provider Configuration Testing**
```bash
# Verify Terraform installation
terraform version

# Check provider configuration
terraform providers

# Validate authentication
aws sts get-caller-identity --profile development

# Test provider functionality
terraform console
> data.aws_caller_identity.current
```

### **Multi-Region Testing**
```bash
# Plan with multi-region enabled
terraform plan -var="enable_multi_region=true"

# Check resources in different regions
aws s3 ls --region us-east-1
aws s3 ls --region us-west-2
```

### **Authentication Testing**
```bash
# Test different profiles
aws sts get-caller-identity --profile development
aws sts get-caller-identity --profile staging

# Test assume role
aws sts assume-role --role-arn "arn:aws:iam::123456789012:role/TestRole" --role-session-name "test-session"
```

---

## 🔍 **Troubleshooting Guide**

### **Common Issues and Solutions**

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Terraform Not Found** | Command not found | Install tfenv and Terraform: `tfenv install 1.13.2` |
| **AWS Authentication Failed** | Access denied errors | Check AWS credentials: `aws sts get-caller-identity` |
| **Provider Version Conflict** | Version constraint errors | Run `terraform init -upgrade` |
| **State Lock Timeout** | DynamoDB lock errors | Check DynamoDB table permissions |
| **Multi-Region Access Denied** | Region-specific errors | Verify IAM permissions for all regions |
| **Assume Role Failed** | STS errors | Check role trust policy and external ID |

### **Debugging Commands**
```bash
# Check Terraform configuration
terraform validate
terraform providers

# Debug AWS authentication
aws sts get-caller-identity
aws configure list

# Check provider cache
ls -la ~/.terraform.d/plugin-cache/

# View detailed logs
export TF_LOG=DEBUG
terraform plan
```

---

## 📊 **Cost Optimization Features**

### **1. Automated Cost Controls**
- **Auto-shutdown Lambda**: Terminates resources after specified hours
- **Pay-per-request DynamoDB**: No fixed costs for state locking
- **Minimal resource footprint**: Only essential resources for testing
- **Comprehensive tagging**: Cost allocation and tracking

### **2. Cost Monitoring**
```bash
# View cost optimization configuration
terraform output cost_optimization_configuration

# Check estimated costs
terraform output -json | jq '.cost_optimization_configuration.value.estimated_costs'
```

### **3. Resource Cleanup**
```bash
# Automated cleanup with auto-shutdown
# Manual cleanup
terraform destroy -var-file="terraform.tfvars"

# Verify cleanup
aws s3 ls | grep terraform-state
aws dynamodb list-tables | grep terraform-locks
```

---

## 📚 **Learning Resources and Next Steps**

### **Immediate Next Steps**
1. **Test all authentication methods** configured in the lab
2. **Experiment with multi-region deployments** using provider aliases
3. **Configure remote state backend** for team collaboration
4. **Set up development workflow** with IDE integration and automation
5. **Practice troubleshooting** common provider configuration issues

### **Advanced Learning Opportunities**
1. **Implement CI/CD pipelines** with Terraform and AWS authentication
2. **Configure cross-account access** with assume role patterns
3. **Set up AWS SSO integration** for enterprise authentication
4. **Implement provider caching** for improved performance
5. **Create custom provider configurations** for specific use cases

### **Recommended Reading**
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform State Management](https://developer.hashicorp.com/terraform/language/state)

---

## 🎯 **Success Criteria**

Upon successful completion, you should have:

- ✅ **Installed and configured Terraform CLI** with version management
- ✅ **Set up multiple AWS authentication methods** with proper security
- ✅ **Configured multi-region provider setup** with aliases and testing
- ✅ **Implemented remote state backend** with S3 and DynamoDB
- ✅ **Optimized development workflow** with automation and IDE integration
- ✅ **Validated provider configuration** through comprehensive testing
- ✅ **Implemented cost optimization** with auto-shutdown and monitoring

---

**Lab Version**: 2.1  
**Last Updated**: January 2025  
**Terraform Version**: ~> 1.13.0  
**AWS Provider Version**: ~> 6.12.0  
**Compatibility**: Multi-platform (Linux, macOS, Windows WSL)
