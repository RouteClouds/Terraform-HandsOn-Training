# Terraform Capstone Projects - Implementation Guide

## STEP-BY-STEP IMPLEMENTATION INSTRUCTIONS

### Phase 1: Master Planning Document

**Step 1.1**: Create `terraform-capstone-projects.md` with:
- Executive summary of all projects
- Terraform exam domain mapping table
- Project overview table with all 5 projects
- Prerequisites and learning path
- Success criteria and validation procedures

**Step 1.2**: Define project progression:
- Start with Project 1 (Multi-Tier Web App) - Intermediate
- Progress to Project 2 (Modular Infrastructure) - Intermediate-Advanced
- Continue with Project 3 (Multi-Environment) - Advanced
- Advance to Project 4 (Migration & Import) - Advanced
- Complete with Project 5 (Enterprise Security) - Advanced
- Ensure cumulative learning across projects

**Step 1.3**: Create Terraform topic coverage matrix:
- Map each project to training topics (1-12)
- Ensure all 12 topics are covered
- Verify percentage coverage aligns with exam weights
- Document learning objectives for each topic

---

### Phase 2: Project Directory Structure

**Step 2.1**: For each project, create directory structure:
```bash
mkdir -p Project-N-[Name]/{docs,diagrams,terraform-manifests,modules,scripts}
```

**Step 2.2**: Create core files in each project:
- README.md (main documentation)
- Makefile (automation targets)
- PROJECT-N-COMPLETION-SUMMARY.md
- .gitignore (Terraform-specific)
- .terraform-version

**Step 2.3**: Organize documentation:
- docs/architecture.md
- docs/theory.md
- docs/commands.md
- docs/troubleshooting.md
- docs/examples.md
- docs/validation.md

---

### Phase 3: Terraform Configuration Files

**Step 3.1**: Create provider configuration (providers.tf):
```hcl
terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "project-n/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Terraform-Capstone-N"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
```

**Step 3.2**: Create variables configuration (variables.tf):
- Define all input variables
- Include descriptions
- Set appropriate types
- Provide default values where appropriate
- Mark sensitive variables
- Add validation rules

**Step 3.3**: Create main configuration (main.tf):
- Define all AWS resources
- Implement proper resource naming
- Add resource dependencies
- Include lifecycle rules
- Add tags to all resources
- Use data sources where appropriate

**Step 3.4**: Create outputs configuration (outputs.tf):
- Define meaningful outputs
- Include descriptions
- Mark sensitive outputs
- Export values for other modules/projects

**Step 3.5**: Create local values (locals.tf):
- Define computed values
- Create naming conventions
- Set common tags
- Define resource configurations

**Step 3.6**: Create data sources (data.tf):
- Query existing AWS resources
- Fetch AMI IDs
- Get availability zones
- Retrieve account information

---

### Phase 4: Resource-Specific Configuration Files

**Step 4.1**: Create VPC configuration (vpc.tf):
- VPC resource
- Internet Gateway
- NAT Gateways
- Public subnets
- Private subnets
- Route tables
- Route table associations
- VPC endpoints (if needed)

**Step 4.2**: Create compute configuration (compute.tf):
- Launch templates
- Auto Scaling Groups
- EC2 instances
- Scaling policies
- CloudWatch alarms

**Step 4.3**: Create load balancer configuration (alb.tf):
- Application Load Balancer
- Target groups
- Listeners
- Listener rules
- Health checks

**Step 4.4**: Create database configuration (rds.tf):
- DB subnet group
- DB parameter group
- DB option group
- RDS instance
- Read replicas (if needed)

**Step 4.5**: Create storage configuration (s3.tf):
- S3 buckets
- Bucket policies
- Bucket versioning
- Bucket encryption
- Lifecycle rules

**Step 4.6**: Create security configuration (security.tf):
- Security groups
- Security group rules
- Network ACLs
- IAM roles
- IAM policies
- IAM role attachments

**Step 4.7**: Create monitoring configuration (monitoring.tf):
- CloudWatch log groups
- CloudWatch alarms
- SNS topics
- SNS subscriptions
- CloudWatch dashboards

**Step 4.8**: Create DNS configuration (route53.tf):
- Route53 hosted zones
- Route53 records
- Health checks

---

### Phase 5: Diagram Generation

**Step 5.1**: Create `diagrams/generate_diagrams.py`:
```python
from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2, AutoScaling
from diagrams.aws.network import VPC, ELB, Route53, CloudFront
from diagrams.aws.database import RDS
from diagrams.aws.storage import S3
from diagrams.aws.security import IAM, KMS, SecretsManager
from diagrams.aws.management import Cloudwatch, Cloudtrail

# Generate High-Level Design
with Diagram("High-Level Architecture", show=False, outfile="hld", direction="TB"):
    # Define architecture
    pass

# Generate Low-Level Design
with Diagram("Low-Level Architecture", show=False, outfile="lld", direction="LR"):
    # Define detailed architecture
    pass

# Additional diagrams...
```

**Step 5.2**: Generate all required diagrams:
- hld.png - High-level overview
- lld.png - Low-level details
- vpc_architecture.png - VPC design
- network_topology.png - Network layout
- compute_architecture.png - Compute resources
- database_architecture.png - Database design
- security_architecture.png - Security design
- monitoring_architecture.png - Monitoring setup

**Step 5.3**: Verify diagram quality:
- Check PNG file generation
- Verify image quality (300+ DPI)
- Ensure proper labeling
- Validate AWS component icons
- Check color coding and grouping

---

### Phase 6: Documentation Creation

**Step 6.1**: Create README.md:
- Project title and overview
- Learning objectives
- Architecture summary
- Prerequisites
- Quick start guide (5-10 steps)
- Embedded diagrams section
- Troubleshooting quick reference
- References to official documentation

**Step 6.2**: Create docs/architecture.md:
- Detailed system architecture
- Component descriptions
- AWS resources used
- Network architecture
- Storage architecture
- Security architecture
- High availability design
- Scalability considerations
- Cost optimization strategies

**Step 6.3**: Create docs/theory.md:
- Terraform concepts covered
- Exam topics addressed
- Theoretical explanations
- Best practices
- Common pitfalls
- Design patterns
- Official documentation references

**Step 6.4**: Create docs/commands.md:
- terraform init
- terraform validate
- terraform plan
- terraform apply
- terraform destroy
- terraform state commands
- terraform import commands
- AWS CLI commands
- Each command with:
  * Full syntax
  * Description
  * Example usage
  * Expected output
  * Common flags

**Step 6.5**: Create docs/troubleshooting.md:
- Common issues and solutions
- Error messages and meanings
- Debugging procedures
- Log analysis techniques
- State troubleshooting
- Provider troubleshooting
- Resource troubleshooting
- Performance troubleshooting
- Real-world scenarios

**Step 6.6**: Create docs/examples.md:
- Step-by-step deployment examples
- Configuration examples
- Use case scenarios
- Advanced configurations
- Integration examples
- Migration examples

**Step 6.7**: Create docs/validation.md:
- Testing procedures
- Validation checklist
- Success criteria
- Performance benchmarks
- Security validation
- Compliance validation
- Cost validation

---

### Phase 7: Script Creation

**Step 7.1**: Create scripts/deploy.sh:
```bash
#!/bin/bash
set -e

echo "🚀 Deploying Terraform Infrastructure..."

# Check prerequisites
echo "✓ Checking prerequisites..."
terraform version > /dev/null || { echo "❌ Terraform not installed"; exit 1; }
aws sts get-caller-identity > /dev/null || { echo "❌ AWS credentials not configured"; exit 1; }

# Initialize Terraform
echo "✓ Initializing Terraform..."
terraform init

# Validate configuration
echo "✓ Validating configuration..."
terraform validate

# Format check
echo "✓ Checking format..."
terraform fmt -check

# Plan deployment
echo "✓ Planning deployment..."
terraform plan -out=tfplan

# Apply deployment
echo "✓ Applying deployment..."
terraform apply tfplan

echo "✅ Deployment complete!"
```

**Step 7.2**: Create scripts/validate.sh:
```bash
#!/bin/bash

echo "🔍 Validating deployment..."

# Check Terraform state
echo "✓ Checking Terraform state..."
terraform state list

# Verify AWS resources
echo "✓ Verifying AWS resources..."
# Add resource-specific checks

echo "✅ Validation complete!"
```

**Step 7.3**: Create scripts/cleanup.sh:
```bash
#!/bin/bash

echo "🧹 Cleaning up resources..."

# Confirmation prompt
read -p "Are you sure you want to destroy all resources? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

# Destroy resources
echo "✓ Destroying resources..."
terraform destroy -auto-approve

echo "✅ Cleanup complete!"
```

**Step 7.4**: Make scripts executable:
```bash
chmod +x scripts/*.sh
```

---

### Phase 8: Makefile Creation

**Step 8.1**: Create Makefile with targets:
```makefile
.PHONY: help init validate plan apply destroy clean

help:
	@echo "Available targets:"
	@echo "  init     - Initialize Terraform"
	@echo "  validate - Validate configuration"
	@echo "  plan     - Plan deployment"
	@echo "  apply    - Apply deployment"
	@echo "  destroy  - Destroy resources"
	@echo "  clean    - Clean Terraform files"

init:
	terraform init

validate:
	terraform validate
	terraform fmt -check

plan:
	terraform plan

apply:
	terraform apply

destroy:
	terraform destroy

clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f tfplan
```

---

### Phase 9: Terraform Variables Files

**Step 9.1**: Create terraform.tfvars (default values):
```hcl
# Project Configuration
project_name = "terraform-capstone"
environment  = "dev"
aws_region   = "us-east-1"

# Network Configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Compute Configuration
instance_type = "t3.micro"
min_size      = 2
max_size      = 6
desired_size  = 3

# Database Configuration
db_engine         = "postgres"
db_engine_version = "15.3"
db_instance_class = "db.t3.micro"
db_name           = "appdb"
db_username       = "admin"

# Tags
tags = {
  Project     = "Terraform-Capstone"
  ManagedBy   = "Terraform"
  Environment = "dev"
}
```

**Step 9.2**: Create dev.tfvars (development environment):
```hcl
environment = "dev"
instance_type = "t3.micro"
db_instance_class = "db.t3.micro"
multi_az = false
```

**Step 9.3**: Create staging.tfvars (staging environment):
```hcl
environment = "staging"
instance_type = "t3.small"
db_instance_class = "db.t3.small"
multi_az = true
```

**Step 9.4**: Create prod.tfvars (production environment):
```hcl
environment = "prod"
instance_type = "t3.medium"
db_instance_class = "db.t3.medium"
multi_az = true
backup_retention_period = 7
```

---

### Phase 10: Module Development (Project 2 Specific)

**Step 10.1**: Create module structure:
```bash
mkdir -p modules/{vpc,compute,database,load-balancer,storage,monitoring,security,dns}
```

**Step 10.2**: For each module, create:
- main.tf (resource definitions)
- variables.tf (input variables)
- outputs.tf (output values)
- README.md (module documentation)
- versions.tf (version constraints)
- examples/ (usage examples)

**Step 10.3**: Module best practices:
- Single responsibility principle
- Clear input/output contracts
- Comprehensive documentation
- Version constraints
- Examples and tests
- Semantic versioning

---

### Phase 11: Testing and Validation

**Step 11.1**: Terraform validation:
```bash
# Format check
terraform fmt -recursive -check

# Validation
terraform validate

# Plan review
terraform plan -out=tfplan

# Show plan
terraform show tfplan
```

**Step 11.2**: Security scanning:
```bash
# Install tfsec
brew install tfsec

# Run security scan
tfsec .

# Install checkov
pip install checkov

# Run compliance scan
checkov -d .
```

**Step 11.3**: Cost estimation:
```bash
# Install infracost
brew install infracost

# Generate cost estimate
infracost breakdown --path .
```

**Step 11.4**: Terraform testing:
```bash
# Create tests directory
mkdir -p tests

# Write test files
# tests/main_test.go (for Go tests)
# tests/terraform_test.tf (for native tests)

# Run tests
terraform test
```

---

### Phase 12: CI/CD Integration (Project 3 Specific)

**Step 12.1**: Create .github/workflows/terraform.yml:
```yaml
name: Terraform CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.13.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

**Step 12.2**: Add approval gates for production
**Step 12.3**: Implement automated testing
**Step 12.4**: Add notification integrations

---

### Phase 13: State Management Setup

**Step 13.1**: Create S3 bucket for state:
```bash
aws s3api create-bucket \
  --bucket terraform-state-capstone \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket terraform-state-capstone \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket terraform-state-capstone \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

**Step 13.2**: Create DynamoDB table for locking:
```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

**Step 13.3**: Configure backend in providers.tf
**Step 13.4**: Initialize with backend migration

---

### Phase 14: Import Procedures (Project 4 Specific)

**Step 14.1**: Resource discovery:
```bash
# List existing resources
aws ec2 describe-instances
aws rds describe-db-instances
aws s3api list-buckets
aws vpc describe-vpcs
```

**Step 14.2**: Create import script:
```bash
#!/bin/bash
# Import existing resources

# Import VPC
terraform import aws_vpc.main vpc-xxxxx

# Import subnets
terraform import aws_subnet.public[0] subnet-xxxxx
terraform import aws_subnet.private[0] subnet-xxxxx

# Import EC2 instances
terraform import aws_instance.web[0] i-xxxxx

# Import RDS
terraform import aws_db_instance.main db-xxxxx
```

**Step 14.3**: Generate configuration:
- Use terraform show to view imported state
- Write corresponding Terraform configuration
- Validate with terraform plan (should show no changes)

**Step 14.4**: State manipulation:
```bash
# List state resources
terraform state list

# Show resource details
terraform state show aws_vpc.main

# Move resource
terraform state mv aws_instance.old aws_instance.new

# Remove resource
terraform state rm aws_instance.deprecated
```

---

### Phase 15: Security Implementation (Project 5 Specific)

**Step 15.1**: Secrets management:
```hcl
# Create secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "db-password"
  kms_key_id = aws_kms_key.main.id
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# Reference secret in RDS
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

**Step 15.2**: KMS encryption:
```hcl
resource "aws_kms_key" "main" {
  description             = "KMS key for encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "main" {
  name          = "alias/terraform-capstone"
  target_key_id = aws_kms_key.main.key_id
}
```

**Step 15.3**: IAM least privilege:
```hcl
resource "aws_iam_role" "ec2" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ec2" {
  name = "ec2-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*"
      ]
    }]
  })
}
```

**Step 15.4**: CloudTrail logging:
```hcl
resource "aws_cloudtrail" "main" {
  name                          = "terraform-capstone-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.main.arn
}
```

---

### Phase 16: Completion Summary

**Step 16.1**: Create PROJECT-N-COMPLETION-SUMMARY.md:
- Project completion checklist
- All deliverables list
- File count and statistics
- Diagram count and descriptions
- Terraform resource count
- Documentation statistics
- Testing results
- Known limitations
- Future enhancements
- Lessons learned

**Step 16.2**: Document statistics:
- Total lines of Terraform code
- Number of resources created
- Number of modules used
- Documentation pages
- Diagrams generated
- Tests written

---

### Phase 17: Quality Assurance

**Step 17.1**: Validate all Terraform configurations:
```bash
terraform fmt -recursive
terraform validate
terraform plan
```

**Step 17.2**: Test all scripts:
```bash
./scripts/deploy.sh
./scripts/validate.sh
./scripts/cleanup.sh
```

**Step 17.3**: Verify all documentation:
- Check all links are working
- Verify all code examples are correct
- Test all commands
- Validate all diagrams display

**Step 17.4**: Final verification checklist:
- [ ] All Terraform files are valid
- [ ] All scripts are executable and tested
- [ ] All diagrams are generated and embedded
- [ ] All documentation is comprehensive
- [ ] All commands are tested
- [ ] All troubleshooting scenarios are covered
- [ ] All exam topics are addressed
- [ ] All diagrams display correctly
- [ ] All links are working
- [ ] All code examples are tested
- [ ] State backend is configured
- [ ] Security best practices implemented
- [ ] Cost optimization considered

---

END OF IMPLEMENTATION GUIDE

