# Lab 1: Basic State Management and Backend Configuration

## Overview
This lab demonstrates setting up remote state management using AWS S3 and DynamoDB.

## Directory Structure
```plaintext
.
├── backend-setup/           # Backend infrastructure setup
│   ├── main.tf             # Main backend configuration
│   ├── variables.tf        # Backend variables
│   └── outputs.tf          # Backend outputs
└── test-configuration/     # Test infrastructure
    ├── main.tf             # Main test configuration
    ├── variables.tf        # Test variables
    └── outputs.tf          # Test outputs
```

## Usage

### 1. Set Up Backend Infrastructure
```bash
cd backend-setup
terraform init
terraform apply
```

### 2. Configure Test Infrastructure
```bash
cd ../test-configuration
# Create backend config file
cat > backend.hcl <<EOF
bucket         = "<GENERATED_BUCKET_NAME>"
key            = "lab1/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true
EOF

# Initialize with backend config
terraform init -backend-config=backend.hcl
terraform apply
```

## Clean Up
1. Destroy test infrastructure:
```bash
cd test-configuration
terraform destroy
```

2. Destroy backend infrastructure:
```bash
cd ../backend-setup
terraform destroy
```

## Notes
- Backend S3 bucket has versioning enabled
- State locking is implemented using DynamoDB
- All resources are tagged for tracking 