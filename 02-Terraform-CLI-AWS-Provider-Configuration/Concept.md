# Terraform CLI & AWS Provider Configuration

## 🎯 Learning Objectives

By the end of this module, you will be able to:

1. **Install and configure Terraform CLI** with version management and best practices
2. **Set up AWS Provider authentication** using multiple secure methods (IAM roles, profiles, SSO)
3. **Implement enterprise-grade provider configurations** with version constraints and security
4. **Configure multi-environment setups** with workspace management and state backends
5. **Troubleshoot common CLI and provider issues** with systematic debugging approaches
6. **Optimize development workflows** with automation tools and IDE integration

## 📋 Terraform CLI Installation and Management

### Modern Installation Methods (2024-2025)

#### 1. **Official HashiCorp Repository (Recommended)**
```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform=1.13.2-1

# RHEL/CentOS/Fedora
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum install terraform-1.13.2-1

# macOS with Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform@1.13
```

#### 2. **Version Management with tfenv (Enterprise Recommended)**
```bash
# Install tfenv
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install and use specific Terraform version
tfenv install 1.13.2
tfenv use 1.13.2
tfenv list

# Set global default
echo "1.13.2" > ~/.tfenv/version
```

#### 3. **Docker-based Installation (CI/CD Environments)**
```bash
# Official HashiCorp Docker image
docker run --rm -v $(pwd):/workspace -w /workspace hashicorp/terraform:1.13.2 version

# Create alias for convenience
alias terraform='docker run --rm -v $(pwd):/workspace -w /workspace hashicorp/terraform:1.13.2'
```

### CLI Configuration and Optimization

#### 1. **Terraform CLI Configuration File**
```hcl
# ~/.terraformrc or %APPDATA%\terraform.rc (Windows)
plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true

provider_installation {
  filesystem_mirror {
    path    = "/usr/share/terraform/providers"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}

credentials "app.terraform.io" {
  token = "your-terraform-cloud-token"
}
```

#### 2. **Environment Variables for Optimization**
```bash
# Performance optimization
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
export TF_CLI_ARGS_plan="-parallelism=10"
export TF_CLI_ARGS_apply="-parallelism=10"

# Logging and debugging
export TF_LOG=INFO
export TF_LOG_PATH="./terraform.log"

# AWS-specific optimizations
export AWS_MAX_ATTEMPTS=10
export AWS_RETRY_MODE=adaptive
```

## 🔐 AWS Provider Authentication Methods

### 1. **IAM Roles (Production Recommended)**

#### EC2 Instance Profiles
```hcl
# Provider configuration using instance profile
provider "aws" {
  region = "us-east-1"
  
  # Instance profile authentication (automatic)
  # No explicit credentials needed when running on EC2
  
  default_tags {
    tags = {
      Environment      = var.environment
      ManagedBy        = "terraform"
      AuthMethod       = "instance-profile"
      TerraformVersion = "1.13.x"
      ProviderVersion  = "6.12.x"
    }
  }
}
```

#### Cross-Account Role Assumption
```hcl
provider "aws" {
  region = "us-east-1"
  
  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/TerraformExecutionRole"
    session_name = "terraform-session"
    external_id  = var.external_id
  }
  
  default_tags {
    tags = {
      Environment      = var.environment
      ManagedBy        = "terraform"
      AuthMethod       = "assume-role"
      TargetAccount    = "123456789012"
    }
  }
}
```

### 2. **AWS CLI Profiles (Development Recommended)**

#### Named Profiles Configuration
```bash
# ~/.aws/config
[default]
region = us-east-1
output = json

[profile development]
region = us-east-1
role_arn = arn:aws:iam::111111111111:role/DeveloperRole
source_profile = default

[profile production]
region = us-east-1
role_arn = arn:aws:iam::222222222222:role/ProductionRole
source_profile = default
mfa_serial = arn:aws:iam::333333333333:mfa/username
```

```hcl
# Provider configuration with named profile
provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
  
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  
  default_tags {
    tags = {
      Environment      = var.environment
      ManagedBy        = "terraform"
      AuthMethod       = "aws-profile"
      Profile          = var.aws_profile
    }
  }
}
```

### 3. **AWS SSO Integration (Enterprise Recommended)**

#### SSO Configuration
```bash
# Configure AWS SSO
aws configure sso
# SSO start URL: https://your-org.awsapps.com/start
# SSO region: us-east-1
# Account ID: 123456789012
# Role name: TerraformRole
# CLI default client Region: us-east-1
# CLI default output format: json
# CLI profile name: sso-terraform

# Login to SSO
aws sso login --profile sso-terraform
```

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "sso-terraform"
  
  default_tags {
    tags = {
      Environment      = var.environment
      ManagedBy        = "terraform"
      AuthMethod       = "aws-sso"
      SSOProfile       = "sso-terraform"
    }
  }
}
```

### 4. **Environment Variables (CI/CD Recommended)**
```bash
# Temporary credentials (from STS)
export AWS_ACCESS_KEY_ID="ASIAXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxx"
export AWS_SESSION_TOKEN="xxxxxxxxxxxxxxxx"
export AWS_REGION="us-east-1"

# Long-term credentials (NOT recommended for production)
export AWS_ACCESS_KEY_ID="AKIAXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxx"
export AWS_DEFAULT_REGION="us-east-1"
```

## ⚙️ Advanced Provider Configuration

### 1. **Multi-Region Provider Setup**
```hcl
# Primary region provider
provider "aws" {
  region = "us-east-1"
  alias  = "primary"
  
  default_tags {
    tags = {
      Environment = var.environment
      Region      = "us-east-1"
      Purpose     = "primary"
    }
  }
}

# Secondary region provider
provider "aws" {
  region = "us-west-2"
  alias  = "secondary"
  
  default_tags {
    tags = {
      Environment = var.environment
      Region      = "us-west-2"
      Purpose     = "disaster-recovery"
    }
  }
}

# Cross-region resource example
resource "aws_s3_bucket" "primary" {
  provider = aws.primary
  bucket   = "my-primary-bucket"
}

resource "aws_s3_bucket" "backup" {
  provider = aws.secondary
  bucket   = "my-backup-bucket"
}
```

### 2. **Provider Version Constraints and Lifecycle**
```hcl
terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
      
      # Provider configuration validation
      configuration_aliases = [
        aws.primary,
        aws.secondary,
      ]
    }
    
    # Additional providers with version constraints
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
  }
  
  # Provider lifecycle management
  provider_meta "aws" {
    module_name = "terraform-aws-training"
  }
}
```

### 3. **Enterprise Provider Configuration**
```hcl
provider "aws" {
  region = var.aws_region
  
  # Authentication configuration
  profile                     = var.aws_profile
  shared_config_files         = var.shared_config_files
  shared_credentials_files    = var.shared_credentials_files
  
  # Assume role configuration
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.session_name
    external_id  = var.external_id
    duration     = var.session_duration
    policy       = var.assume_role_policy
    
    tags = {
      TerraformSession = "true"
      Environment      = var.environment
      Purpose          = "infrastructure-management"
    }
  }
  
  # Request configuration
  max_retries                 = 10
  retry_mode                  = "adaptive"
  
  # Endpoint configuration (for testing or custom endpoints)
  endpoints {
    s3  = var.s3_endpoint
    ec2 = var.ec2_endpoint
    iam = var.iam_endpoint
  }
  
  # Security configuration
  insecure                    = false
  skip_credentials_validation = false
  skip_metadata_api_check     = false
  skip_region_validation      = false
  
  # Default tags for all resources
  default_tags {
    tags = {
      # Project metadata
      Project              = var.project_name
      Environment          = var.environment
      Owner                = var.owner_email
      CostCenter           = var.cost_center
      
      # Technical metadata
      ManagedBy            = "terraform"
      TerraformVersion     = "1.13.x"
      ProviderVersion      = "6.12.x"
      
      # Operational metadata
      CreatedDate          = timestamp()
      LastModified         = timestamp()
      
      # Compliance metadata
      DataClassification   = var.data_classification
      ComplianceFramework  = var.compliance_framework
      BackupRequired       = var.backup_required
      MonitoringEnabled    = var.monitoring_enabled
      
      # Automation metadata
      AutoShutdown         = var.auto_shutdown_enabled
      AutoScaling          = var.auto_scaling_enabled
      CostOptimization     = "enabled"
    }
  }
  
  # Ignore specific tags during updates
  ignore_tags {
    keys = [
      "LastAccessed",
      "TemporaryTag",
    ]
    
    key_prefixes = [
      "aws:",
      "kubernetes.io/",
    ]
  }
}
```

## 🏗️ Workspace and State Management

### 1. **Terraform Workspaces for Multi-Environment**
```bash
# Create and manage workspaces
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# List workspaces
terraform workspace list

# Switch between workspaces
terraform workspace select development

# Show current workspace
terraform workspace show
```

```hcl
# Workspace-aware configuration
locals {
  environment = terraform.workspace
  
  # Environment-specific configurations
  instance_counts = {
    development = 1
    staging     = 2
    production  = 3
  }
  
  instance_types = {
    development = "t3.micro"
    staging     = "t3.small"
    production  = "t3.medium"
  }
}

resource "aws_instance" "web" {
  count         = local.instance_counts[local.environment]
  instance_type = local.instance_types[local.environment]
  ami           = data.aws_ami.amazon_linux.id
  
  tags = {
    Name        = "web-${local.environment}-${count.index + 1}"
    Environment = local.environment
    Workspace   = terraform.workspace
  }
}
```

### 2. **Remote State Backend Configuration**
```hcl
# S3 backend with DynamoDB locking
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-${var.environment}"
    key            = "terraform-cli-aws-provider/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    
    # Workspace-specific state files
    workspace_key_prefix = "workspaces"
    
    # Additional security
    kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    
    # Access logging
    access_logging {
      target_bucket = "terraform-access-logs"
      target_prefix = "state-access/"
    }
  }
}
```

## 🔧 Development Workflow Optimization

### 1. **IDE Integration and Extensions**

#### VS Code Configuration
```json
// .vscode/settings.json
{
  "terraform.languageServer": {
    "enabled": true,
    "args": ["serve"]
  },
  "terraform.codelens.referenceCount": true,
  "terraform.validation.enableEnhancedValidation": true,
  "files.associations": {
    "*.tf": "terraform",
    "*.tfvars": "terraform"
  },
  "editor.formatOnSave": true,
  "[terraform]": {
    "editor.defaultFormatter": "hashicorp.terraform",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.formatDocument.terraform": true
    }
  }
}
```

#### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_tfsec
        args:
          - --args=--soft-fail
```

### 2. **Automation Scripts and Helpers**
```bash
#!/bin/bash
# scripts/terraform-wrapper.sh
set -e

ENVIRONMENT=${1:-development}
ACTION=${2:-plan}

echo "🚀 Terraform ${ACTION} for ${ENVIRONMENT} environment"

# Set workspace
terraform workspace select ${ENVIRONMENT} || terraform workspace new ${ENVIRONMENT}

# Initialize if needed
if [ ! -d ".terraform" ]; then
    echo "📦 Initializing Terraform..."
    terraform init
fi

# Validate configuration
echo "✅ Validating configuration..."
terraform validate

# Format code
echo "🎨 Formatting code..."
terraform fmt -recursive

# Execute action
case ${ACTION} in
    "plan")
        terraform plan -var-file="environments/${ENVIRONMENT}.tfvars" -out="${ENVIRONMENT}.tfplan"
        ;;
    "apply")
        terraform apply "${ENVIRONMENT}.tfplan"
        ;;
    "destroy")
        terraform destroy -var-file="environments/${ENVIRONMENT}.tfvars"
        ;;
    *)
        echo "❌ Unknown action: ${ACTION}"
        exit 1
        ;;
esac

echo "✅ Terraform ${ACTION} completed successfully!"
```

## 🔍 Troubleshooting and Debugging

### Common Issues and Solutions

#### 1. **Authentication Problems**
```bash
# Debug authentication
aws sts get-caller-identity
terraform console
> data.aws_caller_identity.current

# Check provider configuration
terraform providers
terraform version
```

#### 2. **Version Conflicts**
```bash
# Clear provider cache
rm -rf .terraform
terraform init -upgrade

# Check version constraints
terraform version
terraform providers lock -platform=linux_amd64 -platform=darwin_amd64
```

#### 3. **State Management Issues**
```bash
# State debugging
terraform state list
terraform state show aws_instance.example
terraform refresh

# State recovery
terraform import aws_instance.example i-1234567890abcdef0
```

## 📊 Performance Optimization

### 1. **Provider Caching and Parallelism**
```bash
# Enable provider caching
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR

# Optimize parallelism
terraform plan -parallelism=20
terraform apply -parallelism=20
```

### 2. **Resource Targeting and Partial Operations**
```bash
# Target specific resources
terraform plan -target=aws_instance.web
terraform apply -target=aws_s3_bucket.data

# Refresh specific resources
terraform refresh -target=aws_instance.web
```

## 🎯 Summary and Best Practices

### Enterprise-Grade Configuration Checklist

- ✅ **Version Management**: Use tfenv for Terraform version management
- ✅ **Authentication**: Implement IAM roles and AWS SSO for secure access
- ✅ **Provider Constraints**: Pin provider versions with pessimistic constraints
- ✅ **Multi-Environment**: Use workspaces or separate state files
- ✅ **Remote State**: Configure S3 backend with DynamoDB locking
- ✅ **Default Tags**: Implement comprehensive tagging strategy
- ✅ **Security**: Enable encryption and access logging
- ✅ **Monitoring**: Configure logging and debugging
- ✅ **Automation**: Implement CI/CD integration and pre-commit hooks
- ✅ **Documentation**: Maintain up-to-date configuration documentation

### Next Steps
1. **Hands-on Lab**: Implement multi-environment AWS provider setup
2. **Advanced Configuration**: Explore cross-account and cross-region patterns
3. **Integration**: Set up CI/CD pipelines with Terraform
4. **Monitoring**: Implement infrastructure monitoring and alerting

---

**Figure References:**
- Figure 2.1: Terraform CLI Installation Methods (see `../DaC/generated_diagrams/cli_installation.png`)
- Figure 2.2: AWS Authentication Flow (see `../DaC/generated_diagrams/aws_auth_flow.png`)
- Figure 2.3: Multi-Environment Architecture (see `../DaC/generated_diagrams/multi_env_setup.png`)
- Figure 2.4: Provider Configuration Patterns (see `../DaC/generated_diagrams/provider_patterns.png`)
- Figure 2.5: Development Workflow (see `../DaC/generated_diagrams/dev_workflow.png`)
