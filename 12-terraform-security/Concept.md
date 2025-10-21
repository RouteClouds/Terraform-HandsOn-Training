# Topic 12: Advanced Security & Compliance

**Certification Alignment**: Exam Objectives 3.1, 3.4, 4.1, 4.4  
**Terraform Version**: 1.0+  
**AWS Provider**: 6.0+

---

## Learning Objectives

By the end of this topic, you will be able to:
- ✅ Implement secrets management in Terraform
- ✅ Handle sensitive data securely
- ✅ Configure encrypted state backends
- ✅ Implement least privilege access patterns
- ✅ Design secure VPC architectures
- ✅ Apply compliance frameworks
- ✅ Implement audit logging
- ✅ Secure CI/CD pipelines

---

## 1. Secrets Management

### 1.1 AWS Secrets Manager

**Store secrets securely**:

```hcl
resource "aws_secretsmanager_secret" "db_password" {
  name = "prod/db/password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}
```

### 1.2 Reference Secrets

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "main" {
  password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

### 1.3 HashiCorp Vault

**Enterprise secrets management**:

```hcl
provider "vault" {
  address = "https://vault.example.com"
}

data "vault_generic_secret" "db_password" {
  path = "secret/data/prod/db"
}
```

---

## 2. Sensitive Data Handling

### 2.1 Sensitive Variables

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

### 2.2 Sensitive Outputs

```hcl
output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
```

### 2.3 State File Protection

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

---

## 3. Encryption

### 3.1 State Encryption

```bash
# Enable encryption in S3 backend
aws s3api put-bucket-encryption \
  --bucket terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### 3.2 KMS Encryption

```hcl
resource "aws_kms_key" "terraform" {
  description = "KMS key for Terraform state"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform.arn
    }
  }
}
```

---

## 4. IAM & Access Control

### 4.1 Least Privilege

```hcl
resource "aws_iam_policy" "terraform" {
  name = "terraform-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:*"]
        Resource = "*"
      }
    ]
  })
}
```

### 4.2 OIDC Authentication

```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
```

---

## 5. Network Security

### 5.1 VPC Configuration

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
```

### 5.2 Security Groups

```hcl
resource "aws_security_group" "app" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

## 6. Compliance & Audit

### 6.1 Compliance Tagging

```hcl
locals {
  compliance_tags = {
    Compliance = "PCI-DSS"
    Owner      = "Security"
    CostCenter = "Engineering"
  }
}

resource "aws_instance" "compliant" {
  tags = merge(local.compliance_tags, {
    Name = "compliant-instance"
  })
}
```

### 6.2 CloudTrail Logging

```hcl
resource "aws_cloudtrail" "main" {
  name                          = "terraform-trail"
  s3_bucket_name                = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
```

---

## 7. Certification Exam Focus

### 🎓 Exam Objectives Covered

**Objective 3.1**: Secure configuration
- Know sensitive variable handling
- Understand encryption options
- Know security best practices

**Objective 3.4**: Sensitive data
- Know how to handle secrets
- Understand state file security
- Know encryption requirements

**Objective 4.1**: Security practices
- Know IAM best practices
- Understand network security
- Know compliance requirements

**Objective 4.4**: Compliance
- Know compliance frameworks
- Understand audit logging
- Know tagging strategies

### 💡 Exam Tips

- **Tip 1**: Always mark sensitive variables
- **Tip 2**: Encrypt state files
- **Tip 3**: Use least privilege IAM
- **Tip 4**: Enable audit logging
- **Tip 5**: Implement compliance tagging

---

## 8. Key Takeaways

✅ **Secrets** should be managed securely  
✅ **Sensitive data** must be protected  
✅ **State files** must be encrypted  
✅ **IAM** should follow least privilege  
✅ **Network** security is critical  
✅ **Compliance** requires tagging and logging  

---

## Next Steps

1. Complete **Lab 12.1**: Secrets Management
2. Complete **Lab 12.2**: Secure State Backend
3. Complete **Lab 12.3**: Secure VPC Architecture
4. Review **Test-Your-Understanding-Topic-12.md**
5. Proceed to **Practice Exam**

---

**Document Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Labs

