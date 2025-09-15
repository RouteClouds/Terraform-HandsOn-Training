# Lab 2: Terraform CLI & AWS Provider Configuration

## 🎯 Lab Objectives

By completing this lab, you will:

1. **Install and configure Terraform CLI** with version management using tfenv
2. **Set up multiple AWS authentication methods** (profiles, IAM roles, SSO)
3. **Configure multi-environment provider setups** with workspaces and aliases
4. **Implement remote state management** with S3 backend and DynamoDB locking
5. **Optimize development workflow** with IDE integration and automation scripts
6. **Troubleshoot common configuration issues** and implement monitoring

**Duration**: 120-150 minutes  
**Difficulty**: Intermediate  
**Prerequisites**: AWS account with administrative permissions, basic terminal knowledge

## 💰 Cost Estimates

### Expected AWS Costs for this Lab:
- **S3 bucket for state**: ~$0.023/GB/month (minimal usage)
- **DynamoDB table**: ~$0.25/month (on-demand pricing)
- **CloudWatch logs**: ~$0.50/GB ingested (minimal for lab)
- **Total estimated cost**: **$1.00 - $2.00/month**

**💡 Cost Optimization Note**: This lab focuses on configuration and setup with minimal resource creation to keep costs low.

## 🏗️ Lab Architecture Overview

In this lab, you'll configure:

1. **Terraform CLI** with version management and optimization
2. **Multiple AWS authentication methods** for different scenarios
3. **Multi-environment setup** with development, staging, and production configurations
4. **Remote state backend** with S3 and DynamoDB
5. **Development workflow** with IDE integration and automation

![Lab Architecture](../DaC/generated_diagrams/lab2_architecture.png)
*Figure 2.1: Lab 2 Terraform CLI & AWS Provider Configuration Architecture*

## 📋 Prerequisites Setup

### 1. Verify System Requirements
```bash
# Check operating system
uname -a

# Verify required tools
which curl
which git
which unzip

# Check AWS CLI (install if needed)
aws --version || echo "AWS CLI needs to be installed"
```

### 2. Set Environment Variables
```bash
export LAB_NAME="terraform-cli-aws-provider"
export STUDENT_NAME="your-name"  # Replace with your name
export AWS_REGION="us-east-1"
export TF_VERSION="1.13.2"
```

## 🚀 Part 1: Terraform CLI Installation and Configuration

### Step 1: Install tfenv for Version Management

#### 1.1 Install tfenv
```bash
# Clone tfenv repository
git clone https://github.com/tfutils/tfenv.git ~/.tfenv

# Add to PATH
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
tfenv --version
```

#### 1.2 Install and Configure Terraform
```bash
# List available Terraform versions
tfenv list-remote

# Install specific version
tfenv install 1.13.2

# Set as default
tfenv use 1.13.2

# Verify installation
terraform version
```

### Step 2: Configure Terraform CLI Optimization

#### 2.1 Create Terraform CLI Configuration
```bash
# Create Terraform configuration directory
mkdir -p ~/.terraform.d/plugin-cache

# Create CLI configuration file
cat > ~/.terraformrc << 'EOF'
plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true

# Provider installation configuration
provider_installation {
  filesystem_mirror {
    path    = "/usr/share/terraform/providers"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}

# Terraform Cloud configuration (optional)
credentials "app.terraform.io" {
  token = "your-terraform-cloud-token-here"
}
EOF
```

#### 2.2 Set Performance Environment Variables
```bash
# Add to ~/.bashrc for persistence
cat >> ~/.bashrc << 'EOF'

# Terraform Performance Optimization
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
export TF_CLI_ARGS_plan="-parallelism=10"
export TF_CLI_ARGS_apply="-parallelism=10"

# Terraform Logging (for debugging)
export TF_LOG=INFO
export TF_LOG_PATH="./terraform.log"

# AWS Optimization
export AWS_MAX_ATTEMPTS=10
export AWS_RETRY_MODE=adaptive
EOF

source ~/.bashrc
```

## 🔐 Part 2: AWS Authentication Configuration

### Step 3: Configure Multiple Authentication Methods

#### 3.1 Set Up AWS CLI Profiles
```bash
# Configure default profile
aws configure
# AWS Access Key ID: [Enter your access key]
# AWS Secret Access Key: [Enter your secret key]
# Default region name: us-east-1
# Default output format: json

# Configure additional profiles for different environments
aws configure --profile development
aws configure --profile staging
aws configure --profile production

# Verify profiles
aws configure list-profiles
cat ~/.aws/config
```

#### 3.2 Create Advanced Profile Configuration
```bash
# Edit AWS config file for advanced settings
cat >> ~/.aws/config << 'EOF'

[profile terraform-dev]
region = us-east-1
output = json
role_arn = arn:aws:iam::111111111111:role/TerraformDeveloperRole
source_profile = default

[profile terraform-staging]
region = us-east-1
output = json
role_arn = arn:aws:iam::222222222222:role/TerraformStagingRole
source_profile = default
mfa_serial = arn:aws:iam::333333333333:mfa/your-username

[profile terraform-prod]
region = us-east-1
output = json
role_arn = arn:aws:iam::444444444444:role/TerraformProductionRole
source_profile = default
mfa_serial = arn:aws:iam::333333333333:mfa/your-username
duration_seconds = 3600
EOF
```

#### 3.3 Test Authentication Methods
```bash
# Test default profile
aws sts get-caller-identity

# Test named profiles
aws sts get-caller-identity --profile development
aws sts get-caller-identity --profile staging

# Test role assumption (if configured)
aws sts get-caller-identity --profile terraform-dev
```

## ⚙️ Part 3: Multi-Environment Provider Configuration

### Step 4: Create Lab Project Structure

#### 4.1 Initialize Project Directory
```bash
# Create project structure
mkdir -p terraform-cli-lab/{environments,modules,scripts}
cd terraform-cli-lab

# Create environment-specific directories
mkdir -p environments/{development,staging,production}

# Create the directory structure
tree . || ls -la
```

#### 4.2 Create Provider Configuration Templates
```bash
# Create main provider configuration
cat > providers.tf << 'EOF'
# Terraform CLI & AWS Provider Configuration Lab
# Multi-Environment Provider Setup

terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }

  # Remote state backend (will be configured later)
  backend "s3" {
    # Configuration will be provided via backend config file
  }
}

# Primary AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project          = var.project_name
      Environment      = var.environment
      ManagedBy        = "terraform"
      TerraformVersion = "1.13.x"
      ProviderVersion  = "6.12.x"
      Student          = var.student_name
      Lab              = "terraform-cli-aws-provider"
      CreatedDate      = timestamp()
    }
  }
}

# Secondary region provider (for multi-region scenarios)
provider "aws" {
  alias   = "secondary"
  region  = var.secondary_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project          = var.project_name
      Environment      = var.environment
      ManagedBy        = "terraform"
      Region           = var.secondary_region
      Purpose          = "secondary"
      Student          = var.student_name
    }
  }
}
EOF
```

### Step 5: Configure Environment-Specific Variables

#### 5.1 Create Variables Configuration
```bash
cat > variables.tf << 'EOF'
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-cli-lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "student_name" {
  description = "Student name for resource identification"
  type        = string
}

variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for multi-region setup"
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}
EOF
```

#### 5.2 Create Environment-Specific Variable Files
```bash
# Development environment
cat > environments/development.tfvars << 'EOF'
environment    = "development"
aws_profile    = "development"
student_name   = "your-name"  # Replace with your name
project_name   = "terraform-cli-lab"
aws_region     = "us-east-1"
secondary_region = "us-west-2"
EOF

# Staging environment
cat > environments/staging.tfvars << 'EOF'
environment    = "staging"
aws_profile    = "staging"
student_name   = "your-name"  # Replace with your name
project_name   = "terraform-cli-lab"
aws_region     = "us-east-1"
secondary_region = "us-west-2"
EOF

# Production environment
cat > environments/production.tfvars << 'EOF'
environment    = "production"
aws_profile    = "production"
student_name   = "your-name"  # Replace with your name
project_name   = "terraform-cli-lab"
aws_region     = "us-east-1"
secondary_region = "us-west-2"
EOF
```

## 🗄️ Part 4: Remote State Backend Configuration

### Step 6: Create S3 Backend Infrastructure

#### 6.1 Create Backend Resources (Bootstrap)
```bash
# Create bootstrap configuration for state backend
cat > bootstrap.tf << 'EOF'
# Bootstrap resources for Terraform state backend
# Run this first to create S3 bucket and DynamoDB table

resource "random_id" "state_suffix" {
  byte_length = 4
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${var.student_name}-${random_id.state_suffix.hex}"

  tags = {
    Name        = "terraform-state-bucket"
    Purpose     = "terraform-state-storage"
    Environment = "shared"
    Student     = var.student_name
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-state-locks-${var.student_name}-${random_id.state_suffix.hex}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-state-locks"
    Purpose     = "terraform-state-locking"
    Environment = "shared"
    Student     = var.student_name
  }
}

# Outputs for backend configuration
output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "backend_config" {
  description = "Backend configuration for terraform init"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    region         = var.aws_region
    key            = "terraform-cli-lab/terraform.tfstate"
  }
}
EOF
```

#### 6.2 Bootstrap the Backend Infrastructure
```bash
# Initialize and apply bootstrap configuration
terraform init
terraform plan -var="student_name=$STUDENT_NAME"
terraform apply -var="student_name=$STUDENT_NAME"

# Save backend configuration
terraform output -json backend_config > backend_config.json
cat backend_config.json
```

### Step 7: Configure Remote Backend

#### 7.1 Create Backend Configuration Files
```bash
# Extract values from output
S3_BUCKET=$(terraform output -raw s3_bucket_name)
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name)

# Create backend configuration file
cat > backend.hcl << EOF
bucket         = "$S3_BUCKET"
key            = "terraform-cli-lab/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "$DYNAMODB_TABLE"
encrypt        = true
EOF

echo "Backend configuration created:"
cat backend.hcl
```

#### 7.2 Migrate to Remote Backend
```bash
# Remove bootstrap configuration (comment out bootstrap.tf)
mv bootstrap.tf bootstrap.tf.bak

# Reinitialize with remote backend
terraform init -backend-config=backend.hcl

# Verify remote state
terraform state list
```

## 🔧 Part 5: Workspace Management and Testing

### Step 8: Configure Terraform Workspaces

#### 8.1 Create and Manage Workspaces
```bash
# Create workspaces for different environments
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# List all workspaces
terraform workspace list

# Show current workspace
terraform workspace show
```

#### 8.2 Test Multi-Environment Configuration
```bash
# Switch to development workspace
terraform workspace select development

# Plan with development variables
terraform plan -var-file="environments/development.tfvars"

# Switch to staging workspace
terraform workspace select staging

# Plan with staging variables
terraform plan -var-file="environments/staging.tfvars"
```

### Step 9: Create Test Resources

#### 9.1 Add Simple Test Resources
```bash
cat > main.tf << 'EOF'
# Test resources to validate provider configuration

# Random suffix for unique naming
resource "random_id" "test" {
  byte_length = 4
}

# S3 bucket in primary region
resource "aws_s3_bucket" "test_primary" {
  bucket = "test-primary-${terraform.workspace}-${var.student_name}-${random_id.test.hex}"

  tags = {
    Name        = "test-primary-bucket"
    Environment = var.environment
    Workspace   = terraform.workspace
    Region      = var.aws_region
  }
}

# S3 bucket in secondary region
resource "aws_s3_bucket" "test_secondary" {
  provider = aws.secondary
  bucket   = "test-secondary-${terraform.workspace}-${var.student_name}-${random_id.test.hex}"

  tags = {
    Name        = "test-secondary-bucket"
    Environment = var.environment
    Workspace   = terraform.workspace
    Region      = var.secondary_region
  }
}
EOF
```

#### 9.2 Create Outputs
```bash
cat > outputs.tf << 'EOF'
output "workspace_info" {
  description = "Current workspace information"
  value = {
    workspace   = terraform.workspace
    environment = var.environment
    profile     = var.aws_profile
    region      = var.aws_region
  }
}

output "test_resources" {
  description = "Test resources created"
  value = {
    primary_bucket   = aws_s3_bucket.test_primary.bucket
    secondary_bucket = aws_s3_bucket.test_secondary.bucket
    random_suffix    = random_id.test.hex
  }
}

output "provider_validation" {
  description = "Provider configuration validation"
  value = {
    terraform_version = "1.13.x"
    aws_provider      = "6.12.x"
    authentication    = "profile-based"
    multi_region      = "enabled"
  }
}
EOF
```

## 🧪 Part 6: Testing and Validation

### Step 10: Comprehensive Testing

#### 10.1 Test Each Environment
```bash
# Test development environment
terraform workspace select development
terraform plan -var-file="environments/development.tfvars"
terraform apply -var-file="environments/development.tfvars" -auto-approve

# Verify outputs
terraform output

# Test staging environment
terraform workspace select staging
terraform plan -var-file="environments/staging.tfvars"
# Note: Don't apply to save costs, just validate planning works

# Test production environment
terraform workspace select production
terraform plan -var-file="environments/production.tfvars"
# Note: Don't apply to save costs, just validate planning works
```

#### 10.2 Validate Provider Configuration
```bash
# Check provider versions
terraform version
terraform providers

# Validate configuration
terraform validate

# Check state backend
terraform state list
aws s3 ls s3://$S3_BUCKET/
```

## 🔧 Part 7: Development Workflow Optimization

### Step 11: Create Automation Scripts

#### 11.1 Create Terraform Wrapper Script
```bash
cat > scripts/terraform-wrapper.sh << 'EOF'
#!/bin/bash
# Terraform CLI Lab - Automation Wrapper Script

set -e

# Configuration
ENVIRONMENTS=("development" "staging" "production")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Validate environment
validate_environment() {
    local env=$1
    if [[ ! " ${ENVIRONMENTS[@]} " =~ " ${env} " ]]; then
        log_error "Invalid environment: $env"
        log_info "Valid environments: ${ENVIRONMENTS[*]}"
        exit 1
    fi
}

# Main function
main() {
    local environment=${1:-development}
    local action=${2:-plan}
    
    validate_environment "$environment"
    
    log_info "🚀 Terraform $action for $environment environment"
    
    cd "$PROJECT_DIR"
    
    # Set workspace
    log_info "📋 Setting workspace to $environment"
    terraform workspace select "$environment" || terraform workspace new "$environment"
    
    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        log_info "📦 Initializing Terraform..."
        terraform init -backend-config=backend.hcl
    fi
    
    # Validate configuration
    log_info "✅ Validating configuration..."
    terraform validate
    
    # Format code
    log_info "🎨 Formatting code..."
    terraform fmt -recursive
    
    # Execute action
    case $action in
        "plan")
            log_info "📋 Planning infrastructure..."
            terraform plan -var-file="environments/${environment}.tfvars"
            ;;
        "apply")
            log_info "🚀 Applying infrastructure..."
            terraform apply -var-file="environments/${environment}.tfvars"
            ;;
        "destroy")
            log_warning "🗑️  Destroying infrastructure..."
            terraform destroy -var-file="environments/${environment}.tfvars"
            ;;
        "output")
            log_info "📊 Showing outputs..."
            terraform output
            ;;
        *)
            log_error "Unknown action: $action"
            log_info "Valid actions: plan, apply, destroy, output"
            exit 1
            ;;
    esac
    
    log_success "Terraform $action completed successfully!"
}

# Help function
show_help() {
    echo "Usage: $0 [environment] [action]"
    echo ""
    echo "Environments: ${ENVIRONMENTS[*]}"
    echo "Actions: plan, apply, destroy, output"
    echo ""
    echo "Examples:"
    echo "  $0 development plan"
    echo "  $0 staging apply"
    echo "  $0 production destroy"
}

# Parse arguments
if [[ $1 == "-h" || $1 == "--help" ]]; then
    show_help
    exit 0
fi

main "$@"
EOF

chmod +x scripts/terraform-wrapper.sh
```

#### 11.2 Test Automation Script
```bash
# Test the wrapper script
./scripts/terraform-wrapper.sh development plan
./scripts/terraform-wrapper.sh development output
```

## 🔍 Part 8: Troubleshooting and Monitoring

### Step 12: Implement Monitoring and Debugging

#### 12.1 Create Debug Script
```bash
cat > scripts/debug-terraform.sh << 'EOF'
#!/bin/bash
# Terraform Debug and Troubleshooting Script

echo "🔍 Terraform Configuration Debug Report"
echo "========================================"

echo ""
echo "📋 System Information:"
echo "OS: $(uname -a)"
echo "User: $(whoami)"
echo "Working Directory: $(pwd)"

echo ""
echo "🔧 Terraform Information:"
terraform version
echo "Terraform Path: $(which terraform)"

echo ""
echo "☁️  AWS Configuration:"
aws --version
echo "AWS CLI Path: $(which aws)"
echo "Current AWS Identity:"
aws sts get-caller-identity 2>/dev/null || echo "❌ AWS authentication failed"

echo ""
echo "📁 Project Structure:"
find . -name "*.tf" -o -name "*.tfvars" | head -20

echo ""
echo "🏗️  Terraform State:"
terraform workspace list 2>/dev/null || echo "❌ No workspaces found"
echo "Current workspace: $(terraform workspace show 2>/dev/null || echo 'default')"

echo ""
echo "📦 Provider Information:"
terraform providers 2>/dev/null || echo "❌ Run 'terraform init' first"

echo ""
echo "✅ Configuration Validation:"
terraform validate 2>/dev/null && echo "✅ Configuration is valid" || echo "❌ Configuration has errors"

echo ""
echo "🔍 Debug Report Complete"
EOF

chmod +x scripts/debug-terraform.sh
./scripts/debug-terraform.sh
```

## 🧹 Part 9: Cleanup and Documentation

### Step 13: Cleanup Resources

#### 13.1 Destroy Test Resources
```bash
# Switch to development workspace and destroy resources
terraform workspace select development
terraform destroy -var-file="environments/development.tfvars" -auto-approve

# Clean up workspaces (optional)
terraform workspace select default
terraform workspace delete development
terraform workspace delete staging
terraform workspace delete production
```

#### 13.2 Document Configuration
```bash
# Create documentation
cat > README.md << 'EOF'
# Terraform CLI & AWS Provider Configuration Lab

## Overview
This lab demonstrates enterprise-grade Terraform CLI and AWS Provider configuration with:
- Version management using tfenv
- Multiple authentication methods
- Multi-environment setup with workspaces
- Remote state backend with S3 and DynamoDB
- Development workflow optimization

## Quick Start
1. Install dependencies: `./scripts/setup.sh`
2. Configure AWS profiles: `aws configure --profile development`
3. Run terraform: `./scripts/terraform-wrapper.sh development plan`

## Architecture
- **Terraform Version**: 1.13.2
- **AWS Provider**: 6.12.0
- **Authentication**: AWS CLI profiles
- **State Backend**: S3 with DynamoDB locking
- **Environments**: development, staging, production

## Files
- `providers.tf`: Provider configuration
- `variables.tf`: Variable definitions
- `main.tf`: Test resources
- `outputs.tf`: Output definitions
- `environments/`: Environment-specific configurations
- `scripts/`: Automation and helper scripts

## Cost Optimization
- Minimal resource creation
- Auto-cleanup scripts
- Environment-specific sizing
EOF
```

## 📊 Lab Completion Summary

Upon successful completion, you should have:

- ✅ **Installed Terraform CLI** with version management using tfenv
- ✅ **Configured multiple AWS authentication methods** (profiles, roles)
- ✅ **Set up multi-environment provider configuration** with workspaces
- ✅ **Implemented remote state backend** with S3 and DynamoDB
- ✅ **Created automation scripts** for development workflow
- ✅ **Validated configuration** across multiple environments
- ✅ **Implemented monitoring and debugging** capabilities

### **Key Achievements:**
- **Enterprise-grade CLI setup** with optimization and caching
- **Secure authentication patterns** following AWS best practices
- **Multi-environment management** with workspace isolation
- **Remote state management** with encryption and locking
- **Development workflow automation** with scripts and validation

## 🆕 **Bonus Section: 2025 Modern Authentication Patterns**

### **Part 7: AWS SSO CLI v2 Setup (15 minutes)**

**Step 1: Configure AWS SSO**
```bash
# Configure AWS SSO (if available in your organization)
aws configure sso
# Follow prompts:
# SSO session name: terraform-enterprise
# SSO start URL: https://your-org.awsapps.com/start
# SSO region: us-east-1

# Login to SSO
aws sso login --profile terraform-enterprise

# Test SSO authentication
aws sts get-caller-identity --profile terraform-enterprise
```

**Step 2: Update Provider for SSO**
```bash
# Create SSO-enabled provider configuration
cat > providers-sso.tf << 'EOF'
provider "aws" {
  alias   = "sso"
  profile = "terraform-enterprise"
  region  = var.aws_region

  default_tags {
    tags = {
      ManagedBy    = "terraform"
      SSOSession   = "terraform-enterprise"
      AuthMethod   = "AWS-SSO"
      Environment  = var.environment
    }
  }
}
EOF

# Test SSO provider
terraform plan -var="use_sso=true"
```

### **Part 8: OIDC GitHub Actions Setup (20 minutes)**

**Step 1: Create OIDC Provider**
```bash
# Create OIDC identity provider for GitHub Actions
cat > github-oidc.tf << 'EOF'
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name        = "GitHubActions-OIDC"
    Purpose     = "Terraform-CI-CD"
    Environment = var.environment
  }
}

resource "aws_iam_role" "github_actions" {
  name = "GitHubActions-Terraform-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:your-org/your-repo:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
EOF

# Apply OIDC configuration
terraform apply -target=aws_iam_openid_connect_provider.github
terraform apply -target=aws_iam_role.github_actions
```

**Step 2: Create GitHub Actions Workflow**
```bash
# Create GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/terraform.yml << 'EOF'
name: Terraform CI/CD with OIDC
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          role-session-name: terraform-github-actions
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ~1.13.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -no-color

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
EOF
```

### **Part 9: Terraform Cloud Integration (10 minutes)**

**Step 1: Configure Terraform Cloud Backend**
```bash
# Create Terraform Cloud configuration
cat > terraform-cloud.tf << 'EOF'
terraform {
  cloud {
    organization = "your-organization"

    workspaces {
      name = "aws-cli-lab-${var.environment}"
    }
  }
}
EOF

# Login to Terraform Cloud
terraform login

# Initialize with Terraform Cloud
terraform init
```

**Step 2: Set Environment Variables in Terraform Cloud**
```bash
# Set variables via CLI (or use web interface)
terraform workspace select aws-cli-lab-development

# Variables to set in Terraform Cloud:
# AWS_ACCESS_KEY_ID (environment variable, sensitive)
# AWS_SECRET_ACCESS_KEY (environment variable, sensitive)
# TF_VAR_aws_region (terraform variable)
# TF_VAR_environment (terraform variable)
```

### **Validation and Testing**

**Test All Authentication Methods**:
```bash
# Test 1: Profile-based authentication
AWS_PROFILE=terraform-dev terraform plan

# Test 2: SSO authentication
aws sso login --profile terraform-enterprise
AWS_PROFILE=terraform-enterprise terraform plan

# Test 3: Assume role authentication
terraform plan -var="use_assume_role=true"

# Test 4: Environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
terraform plan

# Test 5: Terraform Cloud
terraform plan  # Uses Terraform Cloud backend
```

### **Next Steps:**
1. **Explore advanced provider features** like assume role and cross-account access
2. **Implement CI/CD integration** with the configured authentication methods
3. **Add monitoring and alerting** for infrastructure changes
4. **Practice troubleshooting** common configuration issues
5. **🆕 Set up AWS SSO CLI v2** for enterprise authentication
6. **🆕 Implement OIDC GitHub Actions** for secure CI/CD
7. **🆕 Configure Terraform Cloud** for team collaboration

---

**Lab Duration**: 120-150 minutes  
**Difficulty Level**: Intermediate  
**Cost Impact**: $1.00 - $2.00/month  
**Learning Value**: Foundation for enterprise Terraform workflows
