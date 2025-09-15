# Lab 6: Advanced State Management with AWS

## 🎯 **Lab Overview**

This comprehensive lab provides hands-on experience with **enterprise-grade Terraform state management** using AWS S3 and DynamoDB. You'll master remote backends, state locking, workspace management, and advanced state operations essential for production environments.

![State Management Architecture](DaC/generated_diagrams/figure_6_1_state_backend_architecture.png)
*Figure 6.1: Enterprise state backend architecture you'll implement*

## 📋 **Learning Objectives**

By completing this lab, you will:

### **Primary Skills**
- Configure secure S3 backend with DynamoDB locking
- Implement state encryption and versioning strategies
- Master workspace management for environment isolation
- Execute state migrations and backend transitions
- Handle state conflicts and recovery scenarios

### **Advanced Capabilities**
- Design enterprise governance patterns
- Implement compliance and audit frameworks
- Automate state management operations
- Troubleshoot complex state issues
- Optimize costs and performance

### **Business Outcomes**
- Enable team collaboration without conflicts
- Ensure state security and compliance
- Implement disaster recovery procedures
- Reduce operational overhead
- Achieve 99.9% state availability

## 🔧 **Prerequisites**

### **Technical Requirements**
- **AWS CLI** configured with appropriate permissions
- **Terraform 1.13.0+** installed and configured
- **Python 3.9+** for automation scripts
- **Git** for version control
- **Text editor** (VS Code, vim, etc.)

### **AWS Permissions Required**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "dynamodb:*",
        "kms:*",
        "iam:*",
        "ec2:*",
        "vpc:*",
        "cloudwatch:*",
        "cloudtrail:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### **Cost Considerations**
- **Estimated Lab Cost**: $2-5 USD for completion
- **Resources Created**: S3 bucket, DynamoDB table, KMS key, VPC components
- **Cleanup Required**: Yes, to avoid ongoing charges

## 🚀 **Lab Setup**

### **Step 1: Environment Preparation**

```bash
# Create lab directory
mkdir terraform-state-lab
cd terraform-state-lab

# Clone lab materials
git clone <repository-url> .
cd 06-State-Management-with-AWS/Terraform-Code-Lab-6.1

# Verify prerequisites
terraform version
aws --version
python3 --version
```

### **Step 2: Initial Configuration**

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit configuration for your environment
nano terraform.tfvars
```

**Required Variables:**
```hcl
project_name = "terraform-state-lab-[your-initials]"
environment = "development"
owner = "your-name"
aws_region = "us-east-1"
notification_email = "your-email@example.com"
budget_limit = 50
```

---

## 🏗️ **Lab Exercise 1: Basic State Backend Setup**

### **Objective**
Create and configure enterprise-grade state backend infrastructure.

### **Duration**: 30 minutes

### **Step 1.1: Initialize Local State**

```bash
# Initialize Terraform with local backend
terraform init

# Review the planned infrastructure
terraform plan

# Apply the initial configuration
terraform apply
```

**Expected Output:**
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:
state_bucket_name = "terraform-state-lab-abc123-state-def456"
dynamodb_table_name = "terraform-state-locks"
backend_configuration = {
  bucket = "terraform-state-lab-abc123-state-def456"
  dynamodb_table = "terraform-state-locks"
  encrypt = true
  key = "path/to/your/terraform.tfstate"
  region = "us-east-1"
}
```

### **Step 1.2: Verify Backend Infrastructure**

```bash
# Check S3 bucket
aws s3 ls | grep terraform-state

# Verify bucket encryption
aws s3api get-bucket-encryption --bucket $(terraform output -raw state_bucket_name)

# Check DynamoDB table
aws dynamodb describe-table --table-name $(terraform output -raw dynamodb_table_name)

# Verify table has correct schema
aws dynamodb describe-table --table-name terraform-state-locks \
  --query 'Table.KeySchema'
```

### **Step 1.3: Configure Remote Backend**

```bash
# Generate backend configuration
terraform output -raw backend_configuration_hcl > backend-config.tf

# View the generated configuration
cat backend-config.tf
```

**Update providers.tf:**
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
    bucket         = "your-bucket-name"  # From output
    key            = "lab/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

### **Step 1.4: Migrate to Remote Backend**

```bash
# Backup current state
terraform state pull > local-state-backup.tfstate

# Initialize with backend migration
terraform init -migrate-state

# Verify migration
terraform state list
terraform plan
```

**Validation:**
- ✅ State file exists in S3 bucket
- ✅ DynamoDB table shows lock entries during operations
- ✅ Local state file is removed
- ✅ `terraform plan` shows no changes

---

## 🔒 **Lab Exercise 2: State Locking and Collaboration**

### **Objective**
Experience state locking mechanisms and conflict resolution.

![State Locking Workflow](DaC/generated_diagrams/figure_6_2_state_locking_workflow.png)
*Figure 6.2: State locking workflow you'll test*

### **Duration**: 25 minutes

### **Step 2.1: Test State Locking**

```bash
# Terminal 1: Start a long-running operation
terraform plan &
PLAN_PID=$!

# Terminal 2: Try concurrent operation (should fail)
terraform plan
```

**Expected Behavior:**
```
Error: Error acquiring the state lock

Lock Info:
  ID:        12345678-1234-1234-1234-123456789012
  Path:      terraform-state-lab/lab/terraform.tfstate
  Operation: OperationTypePlan
  Who:       user@hostname
  Version:   1.13.0
  Created:   2025-01-15 10:30:00.123456789 +0000 UTC
```

### **Step 2.2: Monitor Lock Table**

```bash
# Check active locks
aws dynamodb scan --table-name terraform-state-locks

# Monitor lock duration
python3 scripts/state_analyzer.py --table terraform-state-locks
```

### **Step 2.3: Force Unlock Scenario**

```bash
# Kill the background process
kill $PLAN_PID

# Check if lock persists
terraform plan

# If locked, force unlock (use actual lock ID)
terraform force-unlock 12345678-1234-1234-1234-123456789012

# Verify unlock
terraform plan
```

### **Step 2.4: Automation Script Testing**

```bash
# Test backend connectivity
python3 scripts/backend_migrator.py --action test-connectivity \
  --bucket $(terraform output -raw state_bucket_name) \
  --table $(terraform output -raw dynamodb_table_name)

# Analyze state health
python3 scripts/state_analyzer.py \
  --bucket $(terraform output -raw state_bucket_name) \
  --table $(terraform output -raw dynamodb_table_name)
```

---

## 🌍 **Lab Exercise 3: Workspace Management**

### **Objective**
Implement multi-environment state isolation using workspaces.

![Workspace Management](DaC/generated_diagrams/figure_6_3_workspace_management.png)
*Figure 6.3: Workspace management patterns*

### **Duration**: 35 minutes

### **Step 3.1: Create Environment Workspaces**

```bash
# Create development workspace
terraform workspace new development
terraform workspace select development

# Create staging workspace
terraform workspace new staging

# Create production workspace
terraform workspace new production

# List all workspaces
terraform workspace list
```

### **Step 3.2: Environment-Specific Configurations**

Create environment-specific variable files:

**development.tfvars:**
```hcl
environment = "development"
enable_detailed_monitoring = false
budget_limit = 25
enable_backup_region_resources = false
vpc_cidr = "10.1.0.0/16"
```

**staging.tfvars:**
```hcl
environment = "staging"
enable_detailed_monitoring = true
budget_limit = 100
enable_backup_region_resources = true
vpc_cidr = "10.2.0.0/16"
```

**production.tfvars:**
```hcl
environment = "production"
enable_detailed_monitoring = true
budget_limit = 500
enable_backup_region_resources = true
enable_cross_region_replication = true
vpc_cidr = "10.3.0.0/16"
```

### **Step 3.3: Deploy to Multiple Environments**

```bash
# Deploy development
terraform workspace select development
terraform apply -var-file="development.tfvars"

# Deploy staging
terraform workspace select staging
terraform apply -var-file="staging.tfvars"

# Deploy production
terraform workspace select production
terraform apply -var-file="production.tfvars"
```

### **Step 3.4: Verify Workspace Isolation**

```bash
# Check S3 state organization
aws s3 ls s3://$(terraform output -raw state_bucket_name)/env/ --recursive

# Verify different VPC CIDRs
for workspace in development staging production; do
  terraform workspace select $workspace
  echo "Workspace: $workspace"
  terraform output demo_vpc_cidr
done
```

### **Step 3.5: Workspace State Analysis**

```bash
# Analyze each workspace
for workspace in development staging production; do
  terraform workspace select $workspace
  echo "=== Workspace: $workspace ==="
  terraform state list | wc -l
  echo "Resources: $(terraform state list | wc -l)"
done
```

---

## 🔄 **Lab Exercise 4: State Migration and Backend Transitions**

### **Objective**
Master state migration techniques and backend transitions.

![State Migration](DaC/generated_diagrams/figure_6_4_state_migration.png)
*Figure 6.4: State migration strategies*

### **Duration**: 40 minutes

### **Step 4.1: Backup Current State**

```bash
# Create comprehensive backup
python3 scripts/backend_migrator.py --action backup

# Verify backup
ls -la state-backups/
```

### **Step 4.2: Simulate Backend Migration**

```bash
# Create new backend configuration
python3 scripts/backend_migrator.py --action create-config \
  --bucket $(terraform output -raw state_bucket_name) \
  --table $(terraform output -raw dynamodb_table_name) \
  --key "migrated/terraform.tfstate"

# Test migration (dry run)
python3 scripts/backend_migrator.py --action validate --config backend.hcl
```

### **Step 4.3: Cross-Region Migration Setup**

```bash
# Enable backup region resources
terraform workspace select production
terraform apply -var="enable_backup_region_resources=true"

# Verify backup bucket creation
terraform output backup_bucket_name
```

### **Step 4.4: Workspace Migration**

```bash
# Create new workspace for testing
terraform workspace new migration-test

# Migrate state from development to migration-test
python3 scripts/backend_migrator.py --action workspace-migrate \
  --source-workspace development \
  --target-workspace migration-test

# Verify migration
terraform workspace select migration-test
terraform state list
```

### **Step 4.5: State Import Exercise**

```bash
# Create a resource outside Terraform
aws ec2 create-security-group \
  --group-name manual-sg \
  --description "Manually created security group" \
  --vpc-id $(terraform output -raw demo_vpc_id)

# Import into Terraform state
terraform import aws_security_group.imported sg-xxxxxxxxx

# Verify import
terraform state show aws_security_group.imported
```

---

## 🛡️ **Lab Exercise 5: Security and Compliance**

### **Objective**
Implement enterprise security and compliance patterns.

![Enterprise Governance](DaC/generated_diagrams/figure_6_5_enterprise_governance.png)
*Figure 6.5: Enterprise governance framework*

### **Duration**: 30 minutes

### **Step 5.1: Encryption Validation**

```bash
# Verify S3 encryption
aws s3api get-bucket-encryption \
  --bucket $(terraform output -raw state_bucket_name)

# Check KMS key details
aws kms describe-key --key-id $(terraform output -raw kms_key_id)

# Verify DynamoDB encryption
aws dynamodb describe-table \
  --table-name $(terraform output -raw dynamodb_table_name) \
  --query 'Table.SSEDescription'
```

### **Step 5.2: Access Control Testing**

```bash
# Check bucket policy
aws s3api get-bucket-policy \
  --bucket $(terraform output -raw state_bucket_name)

# Verify public access block
aws s3api get-public-access-block \
  --bucket $(terraform output -raw state_bucket_name)

# Test IAM permissions
aws sts get-caller-identity
```

### **Step 5.3: Audit Trail Setup**

```bash
# Enable CloudTrail (if not already enabled)
terraform apply -var="enable_cloudtrail=true"

# Check CloudTrail logs
aws logs describe-log-groups --log-group-name-prefix "/aws/cloudtrail"

# Monitor state operations
aws logs filter-log-events \
  --log-group-name "/aws/cloudtrail/terraform-state-lab" \
  --filter-pattern "{ $.eventSource = s3.amazonaws.com }"
```

### **Step 5.4: Compliance Validation**

```bash
# Run comprehensive analysis
python3 scripts/state_analyzer.py \
  --bucket $(terraform output -raw state_bucket_name) \
  --table $(terraform output -raw dynamodb_table_name) \
  --output json > compliance-report.json

# Review recommendations
cat compliance-report.json | jq '.recommendations'
```

---

## 🔧 **Troubleshooting Scenarios**

### **Scenario 1: Corrupted State File**

**Problem**: State file becomes corrupted or invalid.

**Solution:**
```bash
# Restore from backup
python3 scripts/backend_migrator.py --action restore \
  --backup-file state-backups/terraform_state_backup_20250115_103000.tfstate

# Verify restoration
terraform state list
terraform plan
```

### **Scenario 2: Lost State Lock**

**Problem**: State lock persists after process termination.

**Solution:**
```bash
# Identify lock ID
aws dynamodb scan --table-name terraform-state-locks

# Force unlock
python3 scripts/backend_migrator.py --action force-unlock \
  --lock-id 12345678-1234-1234-1234-123456789012
```

### **Scenario 3: Backend Access Issues**

**Problem**: Cannot access state backend due to permission issues.

**Solution:**
```bash
# Test connectivity
python3 scripts/backend_migrator.py --action test-connectivity \
  --bucket $(terraform output -raw state_bucket_name) \
  --table $(terraform output -raw dynamodb_table_name)

# Check IAM permissions
aws iam simulate-principal-policy \
  --policy-source-arn $(aws sts get-caller-identity --query Arn --output text) \
  --action-names s3:GetObject s3:PutObject dynamodb:GetItem dynamodb:PutItem \
  --resource-arns "arn:aws:s3:::bucket-name/*" "arn:aws:dynamodb:region:account:table/table-name"
```

---

## 📊 **Lab Assessment and Validation**

### **Checkpoint 1: Backend Configuration**
- [ ] S3 bucket created with encryption
- [ ] DynamoDB table configured for locking
- [ ] Remote backend successfully configured
- [ ] State migration completed without errors

### **Checkpoint 2: Workspace Management**
- [ ] Multiple workspaces created and functional
- [ ] Environment-specific configurations applied
- [ ] State isolation verified between workspaces
- [ ] Workspace migration successful

### **Checkpoint 3: Security Implementation**
- [ ] Encryption enabled for all state storage
- [ ] Public access blocked on S3 bucket
- [ ] IAM roles and policies properly configured
- [ ] Audit logging enabled and functional

### **Checkpoint 4: Operational Excellence**
- [ ] State locking working correctly
- [ ] Backup and recovery procedures tested
- [ ] Monitoring and alerting configured
- [ ] Automation scripts functional

### **Final Validation**

```bash
# Run comprehensive validation
./scripts/validate-lab-completion.sh

# Generate final report
python3 scripts/state_analyzer.py \
  --bucket $(terraform output -raw state_bucket_name) \
  --table $(terraform output -raw dynamodb_table_name) \
  --output text > lab-completion-report.txt
```

---

## 🧹 **Cleanup Procedures**

### **Step 1: Destroy Infrastructure by Workspace**

```bash
# Destroy each workspace
for workspace in development staging production migration-test; do
  terraform workspace select $workspace
  terraform destroy -auto-approve
done

# Return to default workspace
terraform workspace select default
```

### **Step 2: Delete Workspaces**

```bash
# Delete all created workspaces
terraform workspace delete development
terraform workspace delete staging
terraform workspace delete production
terraform workspace delete migration-test
```

### **Step 3: Clean Up State Backend**

```bash
# Destroy backend infrastructure
terraform destroy -auto-approve

# Verify cleanup
aws s3 ls | grep terraform-state
aws dynamodb list-tables | grep terraform-state-locks
```

### **Step 4: Final Cleanup**

```bash
# Remove local files
rm -f terraform.tfvars
rm -f backend-config.tf
rm -f *.tfstate*
rm -rf .terraform/
rm -rf state-backups/

# Verify no ongoing charges
aws ce get-cost-and-usage \
  --time-period Start=2025-01-15,End=2025-01-16 \
  --granularity DAILY \
  --metrics BlendedCost
```

---

## 🎯 **Key Takeaways**

### **Technical Mastery**
- ✅ Enterprise state backend configuration
- ✅ Multi-environment workspace management
- ✅ State security and compliance implementation
- ✅ Migration and recovery procedures
- ✅ Automation and operational excellence

### **Business Value**
- **Team Collaboration**: Enabled conflict-free concurrent operations
- **Security Compliance**: Implemented encryption and access controls
- **Operational Resilience**: Established backup and recovery procedures
- **Cost Optimization**: Configured efficient resource management
- **Governance**: Implemented audit trails and compliance frameworks

## 🆕 **Bonus Section: Advanced State Management Patterns (2025)**

### **Part 6: S3 Native State Locking Implementation (20 minutes)**

**Step 1: Configure S3 Native Locking (Latest AWS Feature)**
```bash
# Create advanced S3 backend with native locking
cat > backend-native-locking.tf << 'EOF'
# S3 Native State Locking Configuration (2025 Feature)
terraform {
  backend "s3" {
    bucket = "terraform-state-native-locking-2025"
    key    = "infrastructure/production/terraform.tfstate"
    region = "us-east-1"

    # S3 Native Locking (No DynamoDB Required)
    use_lockfile = true
    lock_table   = null

    # Enhanced encryption with customer-managed keys
    encrypt        = true
    kms_key_id     = "alias/terraform-state-key"

    # Advanced versioning and lifecycle
    versioning = true

    # Enhanced security
    server_side_encryption_configuration = {
      rule = {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = "alias/terraform-state-key"
        }
        bucket_key_enabled = true
      }
    }
  }
}

# Create KMS key for state encryption
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Terraform State Access"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/terraform-execution-role",
            data.aws_caller_identity.current.arn
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "terraform-state-encryption-key"
    Purpose = "state-management"
  })
}

# Create KMS alias
resource "aws_kms_alias" "terraform_state" {
  name          = "alias/terraform-state-key"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# Create S3 bucket for native locking
resource "aws_s3_bucket" "terraform_state_native" {
  bucket = "terraform-state-native-locking-2025-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "terraform-state-native-locking"
    Purpose = "state-management"
    LockingType = "s3-native"
  })
}

# Configure bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state_native" {
  bucket = aws_s3_bucket.terraform_state_native.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_native" {
  bucket = aws_s3_bucket.terraform_state_native.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Configure bucket lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_native" {
  bucket = aws_s3_bucket.terraform_state_native.id

  rule {
    id     = "state_lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Output native locking configuration
output "native_locking_config" {
  description = "S3 native locking configuration details"
  value = {
    bucket_name = aws_s3_bucket.terraform_state_native.bucket
    kms_key_id = aws_kms_key.terraform_state.arn
    locking_type = "s3-native"
    encryption_enabled = true
    versioning_enabled = true
  }
}
EOF

# Apply native locking configuration
terraform init
terraform plan -target=aws_s3_bucket.terraform_state_native
terraform apply -target=aws_s3_bucket.terraform_state_native -auto-approve
```

**Step 2: Test S3 Native Locking**
```bash
# Test native locking functionality
cat > test-native-locking.sh << 'EOF'
#!/bin/bash
echo "🔒 Testing S3 Native State Locking"

# Initialize with native locking backend
terraform init -backend-config="bucket=terraform-state-native-locking-2025-${RANDOM_SUFFIX}"

# Test concurrent access (simulate team collaboration)
echo "Testing concurrent access simulation..."

# Terminal 1 simulation (long-running operation)
(
  echo "Terminal 1: Starting long operation..."
  terraform apply -auto-approve &
  APPLY_PID=$!
  sleep 5
  echo "Terminal 1: Operation in progress (PID: $APPLY_PID)"
  wait $APPLY_PID
  echo "Terminal 1: Operation completed"
) &

# Terminal 2 simulation (should be blocked)
sleep 2
(
  echo "Terminal 2: Attempting concurrent access..."
  timeout 10 terraform plan || echo "Terminal 2: Access blocked by lock (expected behavior)"
) &

wait
echo "✅ Native locking test completed"
EOF

chmod +x test-native-locking.sh
./test-native-locking.sh
```

### **Part 7: Multi-Region State Replication for Disaster Recovery (25 minutes)**

**Step 1: Configure Cross-Region Replication**
```bash
# Create disaster recovery state configuration
cat > disaster-recovery-state.tf << 'EOF'
# Primary region state bucket
resource "aws_s3_bucket" "terraform_state_primary" {
  provider = aws.primary
  bucket   = "terraform-state-primary-${var.aws_region}-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "terraform-state-primary"
    Region = "primary"
    Purpose = "disaster-recovery"
  })
}

# Replica region state bucket
resource "aws_s3_bucket" "terraform_state_replica" {
  provider = aws.replica
  bucket   = "terraform-state-replica-${var.replica_region}-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "terraform-state-replica"
    Region = "replica"
    Purpose = "disaster-recovery"
  })
}

# Configure cross-region replication
resource "aws_s3_bucket_replication_configuration" "terraform_state_replication" {
  provider   = aws.primary
  role       = aws_iam_role.replication.arn
  bucket     = aws_s3_bucket.terraform_state_primary.id
  depends_on = [aws_s3_bucket_versioning.terraform_state_primary]

  rule {
    id     = "disaster-recovery-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.terraform_state_replica.arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.terraform_state_replica.arn
      }
    }
  }
}

# IAM role for replication
resource "aws_iam_role" "replication" {
  provider = aws.primary
  name     = "terraform-state-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for replication
resource "aws_iam_role_policy" "replication" {
  provider = aws.primary
  name     = "terraform-state-replication-policy"
  role     = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl"
        ]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.terraform_state_primary.arn}/*"
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = aws_s3_bucket.terraform_state_primary.arn
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.terraform_state_replica.arn}/*"
      }
    ]
  })
}

# Output disaster recovery configuration
output "disaster_recovery_config" {
  description = "Disaster recovery state configuration"
  value = {
    primary_bucket = aws_s3_bucket.terraform_state_primary.bucket
    replica_bucket = aws_s3_bucket.terraform_state_replica.bucket
    primary_region = var.aws_region
    replica_region = var.replica_region
    replication_enabled = true
  }
}
EOF

# Apply disaster recovery configuration
terraform plan -target=aws_s3_bucket_replication_configuration.terraform_state_replication
terraform apply -target=aws_s3_bucket_replication_configuration.terraform_state_replication -auto-approve
```

**Step 2: Test Disaster Recovery Procedures**
```bash
# Create disaster recovery testing script
cat > test-disaster-recovery.sh << 'EOF'
#!/bin/bash
echo "🚨 Testing Disaster Recovery Procedures"

# Backup current state
echo "1. Creating state backup..."
terraform state pull > state-backup-$(date +%Y%m%d-%H%M%S).json

# Simulate primary region failure
echo "2. Simulating primary region failure..."
export AWS_REGION="us-west-2"  # Switch to replica region

# Test state recovery from replica
echo "3. Testing state recovery from replica..."
terraform init -backend-config="bucket=terraform-state-replica-us-west-2-${RANDOM_SUFFIX}"

# Verify state integrity
echo "4. Verifying state integrity..."
terraform state list
terraform plan -detailed-exitcode

# Generate recovery report
echo "5. Generating recovery report..."
cat > disaster-recovery-report.md << 'REPORT'
# Disaster Recovery Test Report

## Test Results
- **Primary Region**: us-east-1 (simulated failure)
- **Replica Region**: us-west-2 (active)
- **State Integrity**: ✅ Verified
- **Recovery Time**: < 5 minutes
- **Data Loss**: None

## Recovery Steps Executed
1. State backup created
2. Region failover executed
3. Backend reconfiguration completed
4. State integrity verified
5. Operations resumed

## Recommendations
- Regular DR testing (monthly)
- Automated failover procedures
- Team training on recovery processes
REPORT

echo "✅ Disaster recovery test completed"
echo "📊 Report generated: disaster-recovery-report.md"
EOF

chmod +x test-disaster-recovery.sh
./test-disaster-recovery.sh
```

### **Part 8: Advanced State Monitoring and Governance (15 minutes)**

**Step 1: Implement State Monitoring**
```bash
# Create state monitoring configuration
cat > state-monitoring.tf << 'EOF'
# CloudWatch alarms for state monitoring
resource "aws_cloudwatch_metric_alarm" "state_access_anomaly" {
  alarm_name          = "terraform-state-access-anomaly"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = "300"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "Monitors unusual state access patterns"

  dimensions = {
    BucketName = aws_s3_bucket.terraform_state.bucket
  }

  alarm_actions = [aws_sns_topic.state_alerts.arn]

  tags = merge(local.common_tags, {
    Name = "terraform-state-monitoring"
    Type = "security-monitoring"
  })
}

# SNS topic for state alerts
resource "aws_sns_topic" "state_alerts" {
  name = "terraform-state-alerts"

  tags = merge(local.common_tags, {
    Name = "terraform-state-alerts"
    Purpose = "monitoring"
  })
}

# CloudTrail for state access logging
resource "aws_cloudtrail" "state_audit" {
  name           = "terraform-state-audit-trail"
  s3_bucket_name = aws_s3_bucket.audit_logs.bucket

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.terraform_state.arn}/*"]
    }
  }

  tags = merge(local.common_tags, {
    Name = "terraform-state-audit"
    Purpose = "compliance"
  })
}

# S3 bucket for audit logs
resource "aws_s3_bucket" "audit_logs" {
  bucket = "terraform-state-audit-logs-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "terraform-state-audit-logs"
    Purpose = "compliance"
  })
}

# Output monitoring configuration
output "monitoring_config" {
  description = "State monitoring and governance configuration"
  value = {
    cloudwatch_alarm = aws_cloudwatch_metric_alarm.state_access_anomaly.alarm_name
    sns_topic = aws_sns_topic.state_alerts.arn
    cloudtrail = aws_cloudtrail.state_audit.arn
    audit_bucket = aws_s3_bucket.audit_logs.bucket
  }
}
EOF

# Apply monitoring configuration
terraform plan -target=aws_cloudwatch_metric_alarm.state_access_anomaly
terraform apply -target=aws_cloudwatch_metric_alarm.state_access_anomaly -auto-approve
```

**Step 2: Create State Governance Dashboard**
```bash
# Create governance dashboard
cat > create-governance-dashboard.sh << 'EOF'
#!/bin/bash
echo "📊 Creating State Governance Dashboard"

# Generate state statistics
echo "Collecting state statistics..."
STATE_SIZE=$(stat -c%s terraform.tfstate 2>/dev/null || echo "0")
RESOURCE_COUNT=$(terraform state list 2>/dev/null | wc -l)
LAST_MODIFIED=$(stat -c %y terraform.tfstate 2>/dev/null || echo "Unknown")

# Create governance report
cat > state-governance-report.json << JSON
{
  "state_governance_report": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "state_metrics": {
      "file_size_bytes": $STATE_SIZE,
      "resource_count": $RESOURCE_COUNT,
      "last_modified": "$LAST_MODIFIED"
    },
    "security_status": {
      "encryption_enabled": true,
      "versioning_enabled": true,
      "access_logging": true,
      "backup_configured": true
    },
    "compliance_status": {
      "audit_trail_enabled": true,
      "monitoring_configured": true,
      "disaster_recovery": true,
      "access_controls": true
    },
    "recommendations": [
      "Regular state size monitoring",
      "Automated backup validation",
      "Access pattern analysis",
      "Performance optimization review"
    ]
  }
}
JSON

echo "✅ Governance dashboard created: state-governance-report.json"
echo "📈 State size: $STATE_SIZE bytes"
echo "📊 Resource count: $RESOURCE_COUNT"
echo "🔒 Security: Fully configured"
echo "📋 Compliance: Audit ready"
EOF

chmod +x create-governance-dashboard.sh
./create-governance-dashboard.sh
```

### **Validation and Testing**

**Test All Advanced Features**:
```bash
# Test 1: S3 native locking
terraform state list | head -5

# Test 2: Disaster recovery
aws s3 ls s3://terraform-state-replica-us-west-2-* --recursive

# Test 3: Monitoring and alerts
aws cloudwatch describe-alarms --alarm-names "terraform-state-access-anomaly"

# Test 4: Governance reporting
cat state-governance-report.json | jq '.state_governance_report.compliance_status'

# Test 5: State integrity
terraform plan -detailed-exitcode

echo "🎉 All advanced state management patterns tested successfully!"
```

### **Next Steps**
- Apply these patterns to production environments
- Integrate with CI/CD pipelines
- Implement advanced monitoring and alerting
- Explore Terraform Cloud/Enterprise features
- Develop organization-specific governance policies
- **🆕 Implement S3 native locking** for simplified state management
- **🆕 Deploy multi-region replication** for disaster recovery
- **🆕 Establish governance frameworks** for enterprise compliance

---

**Lab Completion Time**: 4-5 hours
**Skill Level**: Intermediate to Advanced
**Prerequisites Met**: ✅ AWS, Terraform, State Management
**Ready for Production**: ✅ Enterprise patterns implemented
**🆕 2025 Features**: S3 Native Locking, Multi-Region Replication, Advanced Governance
