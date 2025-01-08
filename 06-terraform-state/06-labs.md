# Terraform State Management - Labs
![terraform_state_lab)](/06-terraform-state/06-Diagrams/06-labs-diagrams/terraform_state_lab.png)
## Lab 1: Basic State Management and Backend Configuration
### Duration: 45 minutes
![State Management and Backend Configuration)](/06-terraform-state/06-Diagrams/06-labs-diagrams/generated/lab1_backend_setup.png)
### Prerequisites
- AWS CLI configured
- Terraform installed
- Basic understanding of S3 and DynamoDB

### Lab Objectives
- Configure remote backend with S3
- Implement state locking with DynamoDB
- Understand state file structure
- Practice basic state operations

### Steps

#### 1. Create Backend Infrastructure
```hcl
# backend-setup/main.tf
# This configuration creates the necessary infrastructure for remote state management

provider "aws" {
  region = "us-east-1"
}

# Create S3 bucket for state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${random_string.suffix.result}"  # Unique bucket name
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for state history
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Generate random suffix for bucket name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
```

#### 2. Configure Remote Backend
```hcl
# main.tf
# Configure backend to use the infrastructure created in step 1

terraform {
  backend "s3" {
    bucket         = "terraform-state-<GENERATED_SUFFIX>"  # Replace with your bucket name
    key            = "lab1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

#### 3. Create Test Resources
```hcl
# Create test VPC to demonstrate state management
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "state-management-test"
    Lab  = "terraform-state-lab1"
  }
}

# Create subnet to demonstrate state dependencies
resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "state-management-subnet"
    Lab  = "terraform-state-lab1"
  }
}
```

### Validation Steps
1. Initialize Terraform with backend:
```bash
terraform init
```

2. Apply configuration:
```bash
terraform apply
```

3. Verify state storage:
```bash
# List state contents
terraform state list

# Show specific resource
terraform state show aws_vpc.main
```

4. Check S3 bucket:
```bash
aws s3 ls s3://terraform-state-<GENERATED_SUFFIX>/lab1/
```

## Lab 2: State Operations and Manipulation
### Duration: 60 minutes
![ State Operations and Manipulation)](/06-terraform-state/06-Diagrams/06-labs-diagrams/generated/lab2_state_operations.png)
### Lab Objectives
- Practice state manipulation commands
- Move resources between states
- Import existing resources
- Handle state conflicts

### Steps

#### 1. State Move Operations
```bash
# Move resource to different name
terraform state mv aws_subnet.example aws_subnet.new_name

# Move resource to different state file
terraform state mv \
  -state-out=../other_config/terraform.tfstate \
  aws_subnet.new_name \
  aws_subnet.moved
```

#### 2. Import Existing Resources
```hcl
# resource_import.tf
# Define the resource to import
resource "aws_security_group" "imported" {
  name_prefix = "imported-sg"
  vpc_id      = aws_vpc.main.id

  # Define the configuration to match existing security group
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

```bash
# Import existing security group
terraform import aws_security_group.imported sg-1234567
```

#### 3. State Refresh and Update
```bash
# Refresh state
terraform refresh

# Show state differences
terraform plan
```

## Lab 3: Advanced State Management
### Duration: 90 minutes
![ Advanced State Management)](/06-terraform-state/06-Diagrams/06-labs-diagrams/generated/lab3_workspaces.png)

### Lab Objectives
- Implement workspace-based state management
- Handle state in CI/CD pipelines
- Practice state recovery scenarios
- Implement state file cleanup

### Steps

#### 1. Workspace Management
```bash
# Create and use workspaces
terraform workspace new development
terraform workspace new production

# Switch workspaces
terraform workspace select development
```

#### 2. Environment-Specific Configurations
```hcl
# variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

# main.tf
locals {
  workspace_suffix = terraform.workspace
  common_tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Lab         = "state-management-lab3"
  }
}

resource "aws_vpc" "workspace_example" {
  cidr_block = "10.0.0.0/16"
  
  tags = merge(
    local.common_tags,
    {
      Name = "vpc-${local.workspace_suffix}"
    }
  )
}
```

### Troubleshooting Guide

#### Common Issues and Solutions

1. **State Locking Conflicts**
```bash
# Check for locks
aws dynamodb get-item \
  --table-name terraform-state-locks \
  --key '{"LockID": {"S": "terraform-state-lab1/terraform.tfstate"}}'

# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

2. **State Version Conflicts**
```bash
# Pull latest state
terraform state pull > terraform.tfstate.backup
terraform state push terraform.tfstate.backup
```

3. **Backend Configuration Issues**
```bash
# Reconfigure backend
terraform init -reconfigure

# Migrate state
terraform init -migrate-state
```

### Best Practices
1. Always use remote backends in production
2. Enable versioning and encryption
3. Implement proper access controls
4. Regular state backup
5. Document state operations

### Clean Up
```bash
# Destroy resources
terraform destroy

# Clean up backend infrastructure
cd backend-setup
terraform destroy
``` 