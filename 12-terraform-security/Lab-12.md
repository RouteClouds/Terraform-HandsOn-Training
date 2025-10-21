# Topic 12: Hands-On Labs - Advanced Security & Compliance

**Estimated Time**: 4-5 hours  
**Difficulty**: Advanced  
**Prerequisites**: Topics 1-11 completed

---

## Lab Overview

This lab series covers three critical security scenarios:
1. **Lab 12.1**: Implement Secrets Management
2. **Lab 12.2**: Secure State File Management
3. **Lab 12.3**: Build Secure VPC Architecture

---

## Lab 12.1: Implement Secrets Management

### Objective
Securely manage database passwords using AWS Secrets Manager.

### Prerequisites
- AWS account with Secrets Manager access
- Terraform installed
- AWS CLI configured

### Step 1: Create Secret

```bash
aws secretsmanager create-secret \
  --name prod/db/password \
  --secret-string '{"username":"admin","password":"SecurePassword123!"}'
```

### Step 2: Create Terraform Configuration

```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db/password"
}

locals {
  db_secret = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}

resource "aws_db_instance" "main" {
  username = local.db_secret.username
  password = local.db_secret.password
}
```

### Step 3: Mark as Sensitive

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}

output "db_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = false
}
```

### Step 4: Apply Configuration

```bash
terraform apply
```

### Step 5: Verify

```bash
terraform output
# Password output should be redacted
```

---

## Lab 12.2: Secure State File Management

### Objective
Configure encrypted S3 backend with state locking.

### Prerequisites
- S3 bucket created
- DynamoDB table created
- KMS key created

### Step 1: Create Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789:key/12345678"
  }
}
```

### Step 2: Enable Encryption

```bash
aws s3api put-bucket-encryption \
  --bucket terraform-state-prod \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:us-east-1:123456789:key/12345678"
      }
    }]
  }'
```

### Step 3: Enable Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket terraform-state-prod \
  --versioning-configuration Status=Enabled
```

### Step 4: Migrate State

```bash
terraform init
# Confirm migration to S3 backend
```

### Step 5: Verify

```bash
terraform state list
# Should work with remote state
```

---

## Lab 12.3: Build Secure VPC Architecture

### Objective
Design and implement a secure VPC with public/private subnets.

### Prerequisites
- Terraform initialized
- AWS credentials configured

### Step 1: Create VPC

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

### Step 2: Create Subnets

```hcl
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}
```

### Step 3: Create Security Groups

```hcl
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Step 4: Apply Configuration

```bash
terraform apply
```

### Step 5: Verify

```bash
terraform output
# Verify VPC and subnet IDs
```

---

## Lab Verification Checklist

### Lab 12.1 Verification
- [ ] Secret created in Secrets Manager
- [ ] Terraform references secret
- [ ] Sensitive variables marked
- [ ] Password output redacted

### Lab 12.2 Verification
- [ ] S3 backend configured
- [ ] Encryption enabled
- [ ] State locking working
- [ ] Remote state accessible

### Lab 12.3 Verification
- [ ] VPC created
- [ ] Subnets created
- [ ] Security groups configured
- [ ] Network properly isolated

---

## Key Learnings

✅ Secrets should be managed securely  
✅ State files must be encrypted  
✅ Network security is critical  
✅ Least privilege access required  
✅ Compliance tagging important  

---

**Lab Completion Time**: 4-5 hours  
**Difficulty**: Advanced  
**Next**: Proceed to Practice Exam

