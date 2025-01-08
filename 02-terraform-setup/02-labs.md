# Setting up Terraform Environment - Labs

## Lab 1: Basic Environment Setup

### Duration: 60 minutes
![lab1 basic environment setup](/02-terraform-setup/02-diagrams/02-labs-diagrams/lab_1_3A_basic_environment_setup.png)
### Prerequisites
- Administrative access to your machine
- Internet connection
- Basic command line knowledge

### Steps

#### 1. Install Required Tools
```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y wget unzip

# Download Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install AWS CLI
sudo apt-get install -y awscli
```

#### 2. Configure AWS Credentials
```bash
aws configure
# Follow prompts to enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region
# - Output format
```

#### 3. Verify Installation
```bash
terraform version
aws --version
```

### Validation
- Terraform command works
- AWS CLI configured correctly
- Environment variables set

## Lab 2: Development Environment Configuration
### Duration: 90 minutes
![Development Environment Configuration](/02-terraform-setup/02-diagrams/02-labs-diagrams/lab_2_3A_development_environment.png)
### Steps

#### 1. VS Code Setup
- Install VS Code
- Install Terraform extension
- Configure settings

#### 2. Git Configuration
```bash
# Initialize Git repository
git init
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Create .gitignore
cat > .gitignore <<EOF
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl
EOF
```

#### 3. Create Project Structure
```bash
mkdir -p {environments/{dev,staging,prod},modules,scripts}
```

### Validation
- VS Code properly configured
- Git repository initialized
- Project structure created

## Lab 3: Backend Configuration Setup
### Duration: 60 minutes
![Backend Configuration Setup](/02-terraform-setup/02-diagrams/02-labs-diagrams/lab_3_3A_backend_configuration.png)
### Prerequisites
- Completed Labs 1 and 2
- AWS account with S3 and DynamoDB permissions

### Steps

#### 1. Create S3 Bucket for Backend
```bash
# Create backend configuration
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "terraform-state-${AWS_ACCOUNT_ID}"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
EOF

# Create S3 bucket using AWS CLI
aws s3api create-bucket \
    --bucket terraform-state-${AWS_ACCOUNT_ID} \
    --region us-east-1
```

#### 2. Enable Bucket Versioning
```bash
aws s3api put-bucket-versioning \
    --bucket terraform-state-${AWS_ACCOUNT_ID} \
    --versioning-configuration Status=Enabled
```

#### 3. Create DynamoDB Table for State Locking
```bash
aws dynamodb create-table \
    --table-name terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### Validation
- S3 bucket created and versioning enabled
- DynamoDB table created
- Backend configuration successful

## Lab 4: Environment Workspace Setup
### Duration: 45 minutes
![Workspace Setup](/02-terraform-setup/02-diagrams/02-labs-diagrams/lab_4_3A_workspace_setup.png)
### Steps

#### 1. Create Environment Configurations
```bash
# Create environment-specific directories
for env in dev staging prod; do
    mkdir -p environments/$env
    
    # Create main configuration
    cat > environments/$env/main.tf <<EOF
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
EOF

    # Create variables file
    cat > environments/$env/variables.tf <<EOF
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "${env}"
}
EOF
done
```

#### 2. Initialize Each Environment
```bash
for env in dev staging prod; do
    cd environments/$env
    terraform init
    cd ../..
done
```

### Validation
- Environment directories created
- Configuration files in place
- Successful initialization

[Continue with more labs...]
