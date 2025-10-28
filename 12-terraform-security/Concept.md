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
- ✅ Configure VCS-driven workflows
- ✅ Implement team-based access control

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

## 7. Policy as Code with Sentinel

### 7.1 Introduction to Sentinel

**Sentinel** is HashiCorp's policy as code framework that enables fine-grained, logic-based policy decisions for HCP Terraform (Terraform Cloud/Enterprise). Sentinel policies allow organizations to enforce governance, compliance, and security requirements before infrastructure changes are applied.

**Key Benefits:**
- **Proactive Governance**: Prevent non-compliant infrastructure before deployment
- **Automated Compliance**: Enforce organizational standards automatically
- **Cost Control**: Prevent expensive resource provisioning
- **Security Enforcement**: Block insecure configurations
- **Audit Trail**: Track policy decisions and violations

### 7.2 Sentinel Policy Structure

Sentinel policies are written in the Sentinel language and follow a specific structure:

```sentinel
# Import required libraries
import "tfplan/v2" as tfplan
import "strings"

# Define helper functions
find_resources = func(type) {
    resources = {}
    for tfplan.resource_changes as address, rc {
        if rc.type == type {
            resources[address] = rc
        }
    }
    return resources
}

# Main policy rule
main = rule {
    all find_resources("aws_instance") as address, instance {
        instance.change.after.instance_type in ["t3.micro", "t3.small", "t3.medium"]
    }
}
```

### 7.3 Sentinel Enforcement Levels

HCP Terraform supports three enforcement levels:

1. **Advisory**: Policy failures are logged but don't block runs
   - Use for: New policies being tested, informational warnings

2. **Soft Mandatory**: Policy failures block runs but can be overridden
   - Use for: Important policies with exception workflows

3. **Hard Mandatory**: Policy failures block runs with no override
   - Use for: Critical security and compliance requirements

### 7.4 Common Sentinel Use Cases

#### Cost Control Policy

```sentinel
import "tfplan/v2" as tfplan
import "decimal"

# Calculate total monthly cost
calculate_cost = func() {
    cost = decimal.new(0)
    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_instance" {
            if rc.change.after.instance_type == "t3.micro" {
                cost = decimal.add(cost, decimal.new(8.5))
            } else if rc.change.after.instance_type == "t3.small" {
                cost = decimal.add(cost, decimal.new(17))
            }
        }
    }
    return cost
}

# Enforce cost limit
main = rule {
    decimal.less_than(calculate_cost(), decimal.new(1000))
}
```

#### Security Compliance Policy

```sentinel
import "tfplan/v2" as tfplan

# Ensure all S3 buckets have encryption enabled
main = rule {
    all tfplan.resource_changes as address, rc {
        rc.type != "aws_s3_bucket" or
        (rc.change.after.server_side_encryption_configuration else null) != null
    }
}
```

#### Tagging Compliance Policy

```sentinel
import "tfplan/v2" as tfplan

# Required tags for all resources
required_tags = ["Environment", "Owner", "CostCenter", "Project"]

# Check if resource has all required tags
has_required_tags = func(tags) {
    for required_tags as tag {
        if tag not in keys(tags) {
            return false
        }
    }
    return true
}

# Main rule
main = rule {
    all tfplan.resource_changes as address, rc {
        rc.mode == "data" or
        has_required_tags(rc.change.after.tags else {})
    }
}
```

### 7.5 Advanced Sentinel Patterns

This section covers advanced Sentinel patterns for complex policy scenarios, including policy composition, parameterization, multi-resource validation, and sophisticated logic patterns.

#### 7.5.1 Policy Composition with Imports

Sentinel supports importing common functions from separate modules for code reuse:

**Common Functions Module** (`common-functions.sentinel`):

```sentinel
# common-functions.sentinel
# Reusable functions for Sentinel policies

import "tfplan/v2" as tfplan
import "strings"

# Get all resources of a specific type
get_resources = func(resource_type) {
    resources = []
    for tfplan.resource_changes as address, rc {
        if rc.type == resource_type and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {
            append(resources, {
                "address": address,
                "resource": rc,
            })
        }
    }
    return resources
}

# Get environment from workspace name
get_environment = func() {
    workspace_name = strings.to_lower(tfplan.workspace.name)
    if strings.has_prefix(workspace_name, "prod") {
        return "production"
    } else if strings.has_prefix(workspace_name, "stg") or strings.has_prefix(workspace_name, "staging") {
        return "staging"
    } else if strings.has_prefix(workspace_name, "dev") {
        return "development"
    }
    return "development"
}

# Check if resource has required tags
has_required_tags = func(resource, required_tags) {
    if "tags" not in keys(resource.change.after) {
        return false
    }

    resource_tags = resource.change.after.tags
    for required_tags as tag {
        if tag not in keys(resource_tags) {
            return false
        }
    }
    return true
}

# Calculate estimated monthly cost for EC2 instances
calculate_ec2_cost = func(instance_type, hours_per_month) {
    # Simplified pricing (actual prices vary by region)
    pricing = {
        "t3.micro":   0.0104,
        "t3.small":   0.0208,
        "t3.medium":  0.0416,
        "t3.large":   0.0832,
        "m5.large":   0.096,
        "m5.xlarge":  0.192,
        "m5.2xlarge": 0.384,
    }

    if instance_type in keys(pricing) {
        return pricing[instance_type] * hours_per_month
    }
    return 0.0
}
```

**Policy Using Imports** (`enforce-tagging-by-environment.sentinel`):

```sentinel
import "tfplan/v2" as tfplan
import "common-functions" as common

# Define required tags by environment
required_tags_by_env = {
    "production": ["Environment", "Owner", "CostCenter", "Compliance", "BackupPolicy"],
    "staging":    ["Environment", "Owner", "CostCenter"],
    "development": ["Environment", "Owner"],
}

# Get current environment
environment = common.get_environment()
required_tags = required_tags_by_env[environment]

# Get all EC2 instances
ec2_instances = common.get_resources("aws_instance")

# Validate tagging
violations = []
for ec2_instances as item {
    if not common.has_required_tags(item.resource, required_tags) {
        append(violations, {
            "address": item.address,
            "missing_tags": required_tags,
        })
    }
}

# Main rule
main = rule {
    length(violations) == 0
}

# Print violations
print("Environment:", environment)
print("Required tags:", required_tags)
if length(violations) > 0 {
    print("Tagging violations found:")
    for violations as v {
        print("  -", v.address, "missing tags:", v.missing_tags)
    }
}
```

#### 7.5.2 Multi-Resource Validation with Dependencies

Validate relationships between multiple resource types:

```sentinel
import "tfplan/v2" as tfplan

# Ensure RDS instances are in private subnets and have security groups
validate_rds_security = func() {
    violations = []

    # Get all RDS instances
    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_db_instance" and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {

            # Check if publicly accessible
            if "publicly_accessible" in keys(rc.change.after) and
               rc.change.after.publicly_accessible == true {
                append(violations, {
                    "address": address,
                    "issue": "RDS instance is publicly accessible",
                    "severity": "critical",
                })
            }

            # Check if security groups are defined
            if "vpc_security_group_ids" not in keys(rc.change.after) or
               length(rc.change.after.vpc_security_group_ids) == 0 {
                append(violations, {
                    "address": address,
                    "issue": "RDS instance has no security groups",
                    "severity": "high",
                })
            }

            # Check if backup retention is configured
            if "backup_retention_period" in keys(rc.change.after) {
                retention = rc.change.after.backup_retention_period
                if retention < 7 {
                    append(violations, {
                        "address": address,
                        "issue": "RDS backup retention less than 7 days (found: " + string(retention) + ")",
                        "severity": "medium",
                    })
                }
            }

            # Check if encryption is enabled
            if "storage_encrypted" in keys(rc.change.after) and
               rc.change.after.storage_encrypted != true {
                append(violations, {
                    "address": address,
                    "issue": "RDS storage encryption not enabled",
                    "severity": "critical",
                })
            }
        }
    }

    return violations
}

# Run validation
violations = validate_rds_security()

# Main rule
main = rule {
    length(violations) == 0
}

# Print violations by severity
if length(violations) > 0 {
    print("RDS security violations found:")
    for violations as v {
        print("  [" + v.severity + "]", v.address + ":", v.issue)
    }
}
```

#### 7.5.3 Cost Calculation and Budget Enforcement

Advanced cost calculation with detailed resource pricing:

```sentinel
import "tfplan/v2" as tfplan
import "decimal"

# EC2 instance pricing (hourly, us-east-1)
ec2_pricing = {
    "t3.micro":    decimal.new(0.0104),
    "t3.small":    decimal.new(0.0208),
    "t3.medium":   decimal.new(0.0416),
    "t3.large":    decimal.new(0.0832),
    "t3.xlarge":   decimal.new(0.1664),
    "m5.large":    decimal.new(0.096),
    "m5.xlarge":   decimal.new(0.192),
    "m5.2xlarge":  decimal.new(0.384),
    "c5.large":    decimal.new(0.085),
    "c5.xlarge":   decimal.new(0.17),
}

# RDS instance pricing (hourly, us-east-1)
rds_pricing = {
    "db.t3.micro":   decimal.new(0.017),
    "db.t3.small":   decimal.new(0.034),
    "db.t3.medium":  decimal.new(0.068),
    "db.m5.large":   decimal.new(0.192),
    "db.m5.xlarge":  decimal.new(0.384),
}

# Calculate monthly cost for EC2 instances
calculate_ec2_monthly_cost = func() {
    total_cost = decimal.new(0)
    hours_per_month = decimal.new(730)  # Average hours per month

    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_instance" and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {

            instance_type = rc.change.after.instance_type
            if instance_type in keys(ec2_pricing) {
                instance_cost = decimal.mul(ec2_pricing[instance_type], hours_per_month)
                total_cost = decimal.add(total_cost, instance_cost)
                print("EC2:", address, "-", instance_type, "- $" + string(instance_cost) + "/month")
            }
        }
    }

    return total_cost
}

# Calculate monthly cost for RDS instances
calculate_rds_monthly_cost = func() {
    total_cost = decimal.new(0)
    hours_per_month = decimal.new(730)

    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_db_instance" and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {

            instance_class = rc.change.after.instance_class
            if instance_class in keys(rds_pricing) {
                instance_cost = decimal.mul(rds_pricing[instance_class], hours_per_month)

                # Add multi-AZ cost (double the cost)
                if "multi_az" in keys(rc.change.after) and rc.change.after.multi_az == true {
                    instance_cost = decimal.mul(instance_cost, decimal.new(2))
                    print("RDS:", address, "-", instance_class, "(Multi-AZ) - $" + string(instance_cost) + "/month")
                } else {
                    print("RDS:", address, "-", instance_class, "- $" + string(instance_cost) + "/month")
                }

                total_cost = decimal.add(total_cost, instance_cost)
            }
        }
    }

    return total_cost
}

# Calculate total infrastructure cost
ec2_cost = calculate_ec2_monthly_cost()
rds_cost = calculate_rds_monthly_cost()
total_cost = decimal.add(ec2_cost, rds_cost)

# Budget limits by environment
budget_limits = {
    "dev":     decimal.new(500),
    "staging": decimal.new(2000),
    "prod":    decimal.new(10000),
}

# Get environment from workspace
workspace_name = tfplan.workspace.name
environment = "dev"
if "staging" in workspace_name {
    environment = "staging"
} else if "prod" in workspace_name {
    environment = "prod"
}

budget_limit = budget_limits[environment]

# Print cost summary
print("=" * 50)
print("Cost Estimate Summary")
print("=" * 50)
print("Environment:", environment)
print("EC2 Monthly Cost:  $" + string(ec2_cost))
print("RDS Monthly Cost:  $" + string(rds_cost))
print("Total Monthly Cost: $" + string(total_cost))
print("Budget Limit:      $" + string(budget_limit))
print("=" * 50)

# Main rule: enforce budget limit
main = rule {
    decimal.less_than_or_equal(total_cost, budget_limit)
}
```

#### 7.5.4 Time-Based Policies

Enforce policies based on time windows (e.g., change freeze periods):

```sentinel
import "tfplan/v2" as tfplan
import "time"

# Define change freeze periods (format: "YYYY-MM-DD")
freeze_periods = [
    {
        "start": "2025-11-20",
        "end":   "2025-12-05",
        "reason": "Holiday freeze period",
    },
    {
        "start": "2025-12-20",
        "end":   "2026-01-05",
        "reason": "Year-end freeze period",
    },
]

# Parse date string to time
parse_date = func(date_str) {
    return time.load(date_str + "T00:00:00Z")
}

# Check if current time is within freeze period
is_in_freeze_period = func() {
    current_time = time.now

    for freeze_periods as period {
        start_time = parse_date(period.start)
        end_time = parse_date(period.end)

        if time.after(current_time, start_time) and time.before(current_time, end_time) {
            print("⚠️  CHANGE FREEZE ACTIVE")
            print("Reason:", period.reason)
            print("Freeze period:", period.start, "to", period.end)
            return true
        }
    }

    return false
}

# Check if this is a production workspace
is_production = func() {
    workspace_name = tfplan.workspace.name
    return "prod" in workspace_name or "production" in workspace_name
}

# Main rule: block changes during freeze periods in production
main = rule when is_production() {
    not is_in_freeze_period()
}

# Advisory message for non-production
precond = rule when not is_production() {
    print("ℹ️  Change freeze check skipped for non-production environment")
    true
}
```

#### 7.5.5 Parameterized Policies with Sentinel Parameters

Use Sentinel parameters for flexible, reusable policies:

```sentinel
import "tfplan/v2" as tfplan
import "strings"

# Parameters (set in HCP Terraform policy set configuration)
param allowed_instance_types default ["t3.micro", "t3.small"]
param max_instance_count default 10
param required_tags default ["Environment", "Owner"]
param enforce_encryption default true

# Validate instance types
validate_instance_types = func() {
    violations = []

    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_instance" and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {

            instance_type = rc.change.after.instance_type
            if instance_type not in allowed_instance_types {
                append(violations, address + ": " + instance_type + " not in allowed types")
            }
        }
    }

    return violations
}

# Count total instances
count_instances = func() {
    count = 0

    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_instance" and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {
            count += 1
        }
    }

    return count
}

# Validate required tags
validate_tags = func() {
    violations = []

    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_instance" and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {

            if "tags" not in keys(rc.change.after) {
                append(violations, address + ": missing all required tags")
                continue
            }

            resource_tags = rc.change.after.tags
            missing_tags = []

            for required_tags as tag {
                if tag not in keys(resource_tags) {
                    append(missing_tags, tag)
                }
            }

            if length(missing_tags) > 0 {
                append(violations, address + ": missing tags: " + strings.join(missing_tags, ", "))
            }
        }
    }

    return violations
}

# Validate EBS encryption
validate_encryption = func() {
    violations = []

    if not enforce_encryption {
        return violations
    }

    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_instance" and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {

            # Check root block device encryption
            if "root_block_device" in keys(rc.change.after) {
                root_device = rc.change.after.root_block_device[0]
                if "encrypted" in keys(root_device) and root_device.encrypted != true {
                    append(violations, address + ": root volume not encrypted")
                }
            }
        }
    }

    return violations
}

# Run all validations
type_violations = validate_instance_types()
instance_count = count_instances()
tag_violations = validate_tags()
encryption_violations = validate_encryption()

# Print configuration
print("Policy Configuration:")
print("  Allowed instance types:", allowed_instance_types)
print("  Max instance count:", max_instance_count)
print("  Required tags:", required_tags)
print("  Enforce encryption:", enforce_encryption)
print("")

# Print violations
if length(type_violations) > 0 {
    print("Instance type violations:")
    for type_violations as v {
        print("  -", v)
    }
}

if instance_count > max_instance_count {
    print("Instance count violation:")
    print("  - Total instances:", instance_count, "(max:", max_instance_count + ")")
}

if length(tag_violations) > 0 {
    print("Tagging violations:")
    for tag_violations as v {
        print("  -", v)
    }
}

if length(encryption_violations) > 0 {
    print("Encryption violations:")
    for encryption_violations as v {
        print("  -", v)
    }
}

# Main rule: all validations must pass
main = rule {
    length(type_violations) == 0 and
    instance_count <= max_instance_count and
    length(tag_violations) == 0 and
    length(encryption_violations) == 0
}
```

### 7.6 Testing Sentinel Policies

Comprehensive testing is essential for reliable Sentinel policies. This section covers test structure, mock data, test cases, and best practices.

#### 7.6.1 Sentinel Test Structure

Sentinel tests use a specific directory structure:

```
sentinel-policies/
├── policy.sentinel              # The policy file
├── sentinel.hcl                 # Policy configuration
├── test/
│   └── policy/
│       ├── pass.hcl            # Test cases that should pass
│       ├── fail.hcl            # Test cases that should fail
│       └── mocks/
│           ├── pass.json       # Mock data for passing tests
│           └── fail.json       # Mock data for failing tests
```

#### 7.6.2 Installing Sentinel CLI

```bash
# Download Sentinel CLI
wget https://releases.hashicorp.com/sentinel/0.24.0/sentinel_0.24.0_linux_amd64.zip
unzip sentinel_0.24.0_linux_amd64.zip
sudo mv sentinel /usr/local/bin/

# Verify installation
sentinel version

# Run tests
sentinel test

# Run tests with verbose output
sentinel test -verbose

# Run specific test
sentinel test -run=pass
```

#### 7.6.3 Creating Mock Data

Mock data simulates Terraform plan output for testing. Here's a complete example:

**Mock Data** (`test/require-encryption/mocks/pass.json`):

```json
{
  "tfplan/v2": {
    "resource_changes": {
      "aws_s3_bucket.example": {
        "address": "aws_s3_bucket.example",
        "mode": "managed",
        "type": "aws_s3_bucket",
        "name": "example",
        "provider_name": "registry.terraform.io/hashicorp/aws",
        "change": {
          "actions": ["create"],
          "before": null,
          "after": {
            "bucket": "my-encrypted-bucket",
            "acl": "private",
            "server_side_encryption_configuration": [
              {
                "rule": [
                  {
                    "apply_server_side_encryption_by_default": [
                      {
                        "sse_algorithm": "AES256"
                      }
                    ]
                  }
                ]
              }
            ],
            "tags": {
              "Environment": "production",
              "Owner": "platform-team"
            }
          },
          "after_unknown": {}
        }
      }
    },
    "configuration": {
      "provider_config": {
        "aws": {
          "name": "aws",
          "expressions": {
            "region": {
              "constant_value": "us-east-1"
            }
          }
        }
      }
    },
    "workspace": {
      "name": "prod-infrastructure"
    }
  }
}
```

**Mock Data** (`test/require-encryption/mocks/fail.json`):

```json
{
  "tfplan/v2": {
    "resource_changes": {
      "aws_s3_bucket.unencrypted": {
        "address": "aws_s3_bucket.unencrypted",
        "mode": "managed",
        "type": "aws_s3_bucket",
        "name": "unencrypted",
        "provider_name": "registry.terraform.io/hashicorp/aws",
        "change": {
          "actions": ["create"],
          "before": null,
          "after": {
            "bucket": "my-unencrypted-bucket",
            "acl": "private",
            "tags": {
              "Environment": "development"
            }
          },
          "after_unknown": {}
        }
      }
    },
    "configuration": {
      "provider_config": {
        "aws": {
          "name": "aws",
          "expressions": {
            "region": {
              "constant_value": "us-east-1"
            }
          }
        }
      }
    },
    "workspace": {
      "name": "dev-infrastructure"
    }
  }
}
```

#### 7.6.4 Writing Test Cases

**Test Configuration** (`test/require-encryption/pass.hcl`):

```hcl
mock "tfplan/v2" {
  module {
    source = "mocks/pass.json"
  }
}

test {
  rules = {
    main = true
  }
}
```

**Test Configuration** (`test/require-encryption/fail.hcl`):

```hcl
mock "tfplan/v2" {
  module {
    source = "mocks/fail.json"
  }
}

test {
  rules = {
    main = false
  }
}
```

#### 7.6.5 Complete Test Example

**Policy** (`require-s3-encryption.sentinel`):

```sentinel
import "tfplan/v2" as tfplan

# Find all S3 buckets
find_s3_buckets = func() {
    buckets = []
    for tfplan.resource_changes as address, rc {
        if rc.type == "aws_s3_bucket" and
           rc.mode == "managed" and
           (rc.change.actions contains "create" or rc.change.actions contains "update") {
            append(buckets, {
                "address": address,
                "resource": rc,
            })
        }
    }
    return buckets
}

# Check if bucket has encryption enabled
is_encrypted = func(bucket) {
    resource = bucket.resource

    # Check for server_side_encryption_configuration
    if "server_side_encryption_configuration" not in keys(resource.change.after) {
        return false
    }

    sse_config = resource.change.after.server_side_encryption_configuration
    if length(sse_config) == 0 {
        return false
    }

    return true
}

# Validate all buckets
buckets = find_s3_buckets()
violations = []

for buckets as bucket {
    if not is_encrypted(bucket) {
        append(violations, bucket.address)
    }
}

# Main rule
main = rule {
    length(violations) == 0
}

# Print violations
if length(violations) > 0 {
    print("S3 buckets without encryption:")
    for violations as v {
        print("  -", v)
    }
}
```

**Test Configuration** (`sentinel.hcl`):

```hcl
policy "require-s3-encryption" {
    source = "./require-s3-encryption.sentinel"
    enforcement_level = "hard-mandatory"
}
```

**Running Tests**:

```bash
# Run all tests
$ sentinel test
PASS - require-s3-encryption.sentinel
  PASS - test/require-encryption/pass.hcl
  PASS - test/require-encryption/fail.hcl

# Run with verbose output
$ sentinel test -verbose
PASS - require-s3-encryption.sentinel
  PASS - test/require-encryption/pass.hcl
    trace:
      TRUE - require-s3-encryption.sentinel:45:1 - Rule "main"
  PASS - test/require-encryption/fail.hcl
    trace:
      S3 buckets without encryption:
        - aws_s3_bucket.unencrypted
      FALSE - require-s3-encryption.sentinel:45:1 - Rule "main"
```

#### 7.6.6 Testing Best Practices

**1. Test Coverage**

Create tests for all scenarios:
- ✅ **Pass cases**: Valid configurations that should pass
- ✅ **Fail cases**: Invalid configurations that should fail
- ✅ **Edge cases**: Boundary conditions and special scenarios
- ✅ **Multiple resources**: Test with multiple resource instances

**2. Mock Data Quality**

- Use realistic mock data from actual Terraform plans
- Generate mock data using `terraform show -json tfplan`
- Include all relevant resource attributes
- Test with different resource states (create, update, delete)

**3. Test Organization**

```
test/
├── policy-name/
│   ├── pass-basic.hcl
│   ├── pass-multiple-resources.hcl
│   ├── fail-missing-encryption.hcl
│   ├── fail-wrong-instance-type.hcl
│   └── mocks/
│       ├── pass-basic.json
│       ├── pass-multiple-resources.json
│       ├── fail-missing-encryption.json
│       └── fail-wrong-instance-type.json
```

**4. Continuous Integration**

Integrate Sentinel tests into CI/CD pipeline:

```yaml
# .github/workflows/sentinel-tests.yml
name: Sentinel Policy Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Sentinel
        run: |
          wget https://releases.hashicorp.com/sentinel/0.24.0/sentinel_0.24.0_linux_amd64.zip
          unzip sentinel_0.24.0_linux_amd64.zip
          sudo mv sentinel /usr/local/bin/

      - name: Run Sentinel Tests
        run: |
          cd sentinel-policies
          sentinel test -verbose
```

**5. Generating Mock Data from Real Plans**

```bash
# Generate a Terraform plan
terraform plan -out=tfplan

# Convert plan to JSON
terraform show -json tfplan > plan.json

# Extract relevant sections for mock data
jq '{
  "tfplan/v2": {
    "resource_changes": .resource_changes,
    "configuration": .configuration,
    "workspace": {
      "name": "test-workspace"
    }
  }
}' plan.json > test/policy/mocks/mock.json
```

**6. Testing with Parameters**

Test parameterized policies with different parameter values:

```hcl
# test/parameterized-policy/pass-dev.hcl
mock "tfplan/v2" {
  module {
    source = "mocks/dev-environment.json"
  }
}

param "allowed_instance_types" {
  value = ["t3.micro", "t3.small"]
}

param "max_instance_count" {
  value = 5
}

test {
  rules = {
    main = true
  }
}
```

**7. Debugging Failed Tests**

```bash
# Run tests with trace output
sentinel test -verbose -trace

# Test a single policy
sentinel test -run=pass-basic

# Apply policy directly to mock data
sentinel apply -trace \
  -config=sentinel.hcl \
  policy.sentinel \
  test/policy/mocks/mock.json
```

### 7.7 Integrating Sentinel with HCP Terraform

**Step 1: Create Policy Set in HCP Terraform**

1. Navigate to Organization Settings → Policy Sets
2. Click "Create a new policy set"
3. Choose "API-driven" or "VCS-driven" workflow
4. Add policies and configure enforcement levels

**Step 2: Attach Policy Set to Workspaces**

```hcl
# Using Terraform to manage policy sets
resource "tfe_policy_set" "security" {
  name         = "security-policies"
  description  = "Security and compliance policies"
  organization = "my-org"

  policy_ids = [
    tfe_sentinel_policy.encryption.id,
    tfe_sentinel_policy.tagging.id,
  ]

  workspace_ids = [
    tfe_workspace.prod.id,
    tfe_workspace.staging.id,
  ]
}

resource "tfe_sentinel_policy" "encryption" {
  name         = "require-encryption"
  description  = "Require encryption for all S3 buckets"
  organization = "my-org"
  policy       = file("policies/require-encryption.sentinel")
  enforce_mode = "hard-mandatory"
}
```

### 7.8 Best Practices for Sentinel Policies

1. **Start with Advisory**: Test new policies in advisory mode first
2. **Use Descriptive Names**: Make policy intent clear from the name
3. **Provide Clear Error Messages**: Help users understand violations
4. **Version Control**: Store policies in Git repositories
5. **Test Thoroughly**: Use Sentinel CLI for local testing
6. **Document Exceptions**: Clearly document when soft-mandatory overrides are acceptable
7. **Monitor Policy Violations**: Track and analyze policy failures
8. **Regular Reviews**: Review and update policies quarterly

### 7.9 Sentinel vs. Other Policy Tools

| Feature | Sentinel | OPA | Cloud Custodian |
|---------|----------|-----|-----------------|
| **Language** | Sentinel | Rego | YAML + Python |
| **HCP Terraform Integration** | Native | Plugin | External |
| **Learning Curve** | Medium | Steep | Low |
| **Terraform-Specific** | Yes | No | No |
| **Enforcement Levels** | 3 levels | Custom | Custom |
| **Best For** | Terraform governance | General policy | Cloud cleanup |

---

## 8. VCS-Driven Workflows

### 8.1 Introduction to VCS Integration

**Version Control System (VCS) integration** connects HCP Terraform to your Git repositories, enabling automated, GitOps-style infrastructure management.

**Key Benefits**:
- **Automated Runs**: Terraform runs trigger automatically on commits
- **Code Review**: Infrastructure changes go through PR review process
- **Audit Trail**: Git history provides complete change tracking
- **Collaboration**: Multiple team members work on infrastructure code
- **Rollback**: Easy rollback to previous infrastructure states

**Supported VCS Providers**:
- GitHub (Cloud and Enterprise)
- GitLab (Cloud and Self-Managed)
- Bitbucket (Cloud and Server)
- Azure DevOps

---

### 8.2 VCS Workflow Types

#### API-Driven Workflow
- Terraform runs triggered via API or CLI
- Manual `terraform apply` execution
- Suitable for local development and testing

#### VCS-Driven Workflow (Recommended)
- Terraform runs triggered by Git commits
- Automatic plan on pull requests
- Automatic apply on merge to main branch
- Ideal for production environments

#### CLI-Driven Workflow
- Local execution with remote state
- Terraform Cloud stores state only
- Developers run commands locally

---

### 8.3 Setting Up VCS Integration

#### Step 1: Configure VCS Provider in HCP Terraform

**Via UI**:
1. Navigate to Organization Settings → VCS Providers
2. Click "Add VCS Provider"
3. Select provider (GitHub, GitLab, etc.)
4. Follow OAuth authentication flow
5. Authorize HCP Terraform access

**Via Terraform**:

```hcl
resource "tfe_oauth_client" "github" {
  organization     = var.organization_name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}
```

#### Step 2: Connect Workspace to Repository

**Via UI**:
1. Navigate to Workspace Settings → Version Control
2. Click "Connect to VCS"
3. Select VCS provider
4. Choose repository
5. Configure working directory (if needed)
6. Set VCS branch (default: main)

**Via Terraform**:

```hcl
resource "tfe_workspace" "app" {
  name         = "production-app"
  organization = var.organization_name

  vcs_repo {
    identifier     = "myorg/terraform-infrastructure"
    branch         = "main"
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }

  working_directory = "environments/production"
}
```

---

### 8.4 VCS-Triggered Runs

#### Automatic Plan on Pull Request

When a pull request is opened:
1. HCP Terraform detects the PR
2. Automatically runs `terraform plan`
3. Posts plan output as PR comment
4. Updates PR status check

**Example PR Comment**:
```
Terraform Plan: 3 to add, 1 to change, 0 to destroy

Plan: 3 to add, 1 to change, 0 to destroy.

Changes to Outputs:
  + vpc_id = "vpc-12345678"
```

#### Automatic Apply on Merge

When PR is merged to main branch:
1. HCP Terraform detects the merge
2. Automatically runs `terraform apply`
3. Applies changes to infrastructure
4. Updates run status

**Configuration Options**:
- **Auto Apply**: Enable/disable automatic apply
- **Speculative Plans**: Run plans without applying
- **Trigger Patterns**: Specify which paths trigger runs

---

### 8.5 Branch-Based Workflows

#### Development Workflow

```
feature/add-s3-bucket
  ↓ (PR opened)
  ↓ Terraform Plan runs
  ↓ Code review
  ↓ (PR merged)
main
  ↓ Terraform Apply runs
  ↓ Infrastructure updated
```

#### Multi-Environment Workflow

**Option 1: Branch per Environment**
```
├── dev branch → dev workspace
├── staging branch → staging workspace
└── main branch → prod workspace
```

**Option 2: Directory per Environment**
```
terraform/
├── environments/
│   ├── dev/ → dev workspace
│   ├── staging/ → staging workspace
│   └── prod/ → prod workspace
```

---

### 8.6 Webhook Configuration

HCP Terraform uses webhooks to receive notifications from VCS providers.

**Webhook Events**:
- `push`: Code pushed to branch
- `pull_request`: PR opened, updated, or closed
- `tag`: Tag created or deleted

**Webhook URL Format**:
```
https://app.terraform.io/webhooks/vcs/<webhook-id>
```

**Manual Webhook Setup** (if needed):
1. Go to repository settings → Webhooks
2. Add webhook URL from HCP Terraform
3. Select events: push, pull_request
4. Set content type: application/json
5. Add secret (provided by HCP Terraform)

---

### 8.7 VCS Integration Best Practices

#### 1. Use Protected Branches
```yaml
# .github/branch-protection.yml
branches:
  main:
    protection:
      required_pull_request_reviews:
        required_approving_review_count: 2
      required_status_checks:
        strict: true
        contexts:
          - "Terraform Plan"
```

#### 2. Implement PR Templates

**`.github/pull_request_template.md`**:
```markdown
## Description
Brief description of infrastructure changes

## Checklist
- [ ] Terraform fmt applied
- [ ] Terraform validate passed
- [ ] Plan reviewed
- [ ] Security implications considered
- [ ] Documentation updated

## Terraform Plan Summary
<!-- HCP Terraform will add plan here -->
```

#### 3. Use CODEOWNERS

**`.github/CODEOWNERS`**:
```
# Infrastructure team must approve all Terraform changes
*.tf @myorg/infrastructure-team
*.tfvars @myorg/infrastructure-team

# Security team must approve security-related changes
**/security/** @myorg/security-team
```

#### 4. Configure Run Triggers

Trigger runs only for relevant changes:

```hcl
resource "tfe_workspace" "app" {
  name         = "production-app"
  organization = var.organization_name

  vcs_repo {
    identifier     = "myorg/terraform-infrastructure"
    branch         = "main"
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }

  # Only trigger runs for changes in specific directory
  working_directory = "environments/production"

  # Trigger runs only for .tf file changes
  trigger_patterns = ["**/*.tf", "**/*.tfvars"]
}
```

#### 5. Enable Speculative Plans

Allow developers to test changes without affecting state:

```hcl
resource "tfe_workspace" "app" {
  name                  = "production-app"
  organization          = var.organization_name
  speculative_enabled   = true  # Enable speculative plans
  auto_apply            = false # Require manual approval
}
```

---

### 8.8 GitHub Actions Integration

While HCP Terraform provides VCS-driven workflows, you can also use GitHub Actions for additional automation.

**Example: Enhanced Terraform Workflow**

**`.github/workflows/terraform.yml`**:
```yaml
name: Terraform CI/CD

on:
  pull_request:
    branches: [main]
    paths:
      - '**.tf'
      - '**.tfvars'
  push:
    branches: [main]

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.13.0
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    - name: Terraform Format
      id: fmt
      run: terraform fmt -check -recursive
      continue-on-error: true

    - name: Terraform Init
      id: init
      run: terraform init

    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color

    - name: Terraform Plan
      id: plan
      if: github.event_name == 'pull_request'
      run: terraform plan -no-color
      continue-on-error: true

    - name: Update Pull Request
      uses: actions/github-script@v7
      if: github.event_name == 'pull_request'
      env:
        PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const output = `#### Terraform Format 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
          #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

          <details><summary>Show Plan</summary>

          \`\`\`\n
          ${process.env.PLAN}
          \`\`\`

          </details>

          *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve
```

---

### 8.9 Common VCS Integration Scenarios

#### Scenario 1: Feature Development
1. Developer creates feature branch
2. Makes infrastructure changes
3. Opens pull request
4. HCP Terraform runs speculative plan
5. Team reviews plan in PR
6. PR approved and merged
7. HCP Terraform applies changes

#### Scenario 2: Emergency Hotfix
1. Create hotfix branch from main
2. Make minimal changes
3. Fast-track PR review
4. Merge to main
5. Monitor apply in HCP Terraform
6. Verify infrastructure changes

#### Scenario 3: Multi-Environment Promotion
1. Changes tested in dev workspace (dev branch)
2. Merge dev → staging (triggers staging apply)
3. Validate in staging environment
4. Merge staging → main (triggers prod apply)
5. Production infrastructure updated

---

## 9. Team Management and RBAC

### 8.1 Introduction to HCP Terraform Organizations

**HCP Terraform** (formerly Terraform Cloud) provides enterprise-grade collaboration features through organizations and teams.

**Organization Structure**:
- **Organization**: Top-level container for workspaces, teams, and policies
- **Teams**: Groups of users with specific permissions
- **Workspaces**: Individual Terraform configurations with their own state
- **Users**: Individual members assigned to teams

**Key Benefits**:
- Centralized access control
- Role-based permissions
- Audit logging
- SSO/SAML integration
- Team-based collaboration

---

### 8.2 Team Structure and Hierarchy

**Built-in Teams**:

1. **Owners Team**
   - Full administrative access
   - Can manage organization settings
   - Can create/delete teams
   - Can manage billing
   - Cannot be deleted

2. **Default Team** (Deprecated)
   - Legacy team for backward compatibility
   - All users automatically added
   - Recommended to use custom teams instead

**Custom Teams**:
- Created by organization owners
- Assigned specific permissions
- Can have organization-level or workspace-level access
- Support SSO group mapping

---

### 8.3 Workspace Access Levels

HCP Terraform provides four workspace access levels:

| Access Level | Permissions | Use Case |
|--------------|-------------|----------|
| **Read** | View runs, state, variables | Auditors, stakeholders |
| **Plan** | Read + trigger plans | Developers reviewing changes |
| **Write** | Plan + apply changes | Standard developers |
| **Admin** | Write + manage workspace settings | Team leads, DevOps engineers |

**Detailed Permissions**:

**Read Access**:
- View workspace settings
- View state versions
- View run history
- View variables (not sensitive values)
- Download state files

**Plan Access**:
- All Read permissions
- Queue plans
- Comment on runs
- Lock/unlock workspace

**Write Access**:
- All Plan permissions
- Apply runs
- Upload state files
- Create/edit variables

**Admin Access**:
- All Write permissions
- Manage workspace settings
- Delete workspace
- Manage team access
- Manage run triggers
- Manage notifications

---

### 8.4 Organization-Level Permissions

Teams can have organization-wide permissions:

**Manage Policies**:
- Create/edit/delete Sentinel policies
- Manage policy sets
- Override policy failures

**Manage Policy Overrides**:
- Override soft-mandatory policies
- Requires justification

**Manage Workspaces**:
- Create new workspaces
- Delete workspaces
- Manage workspace settings across organization

**Manage VCS Settings**:
- Configure VCS connections
- Manage OAuth tokens
- Set up VCS-driven workflows

**Manage Modules**:
- Publish modules to private registry
- Manage module versions
- Configure module sharing

---

### 8.5 Implementing RBAC with Terraform

**Create Teams Using Terraform**:

```hcl
# Configure the TFE provider
terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.51.0"
    }
  }
}

provider "tfe" {
  token = var.tfe_token
}

# Create teams
resource "tfe_team" "developers" {
  name         = "developers"
  organization = var.organization_name
}

resource "tfe_team" "devops" {
  name         = "devops"
  organization = var.organization_name

  organization_access {
    manage_workspaces = true
    manage_policies   = true
  }
}

resource "tfe_team" "security" {
  name         = "security"
  organization = var.organization_name

  organization_access {
    manage_policies          = true
    manage_policy_overrides  = true
  }
}

# Assign workspace access
resource "tfe_team_access" "developers_write" {
  access       = "write"
  team_id      = tfe_team.developers.id
  workspace_id = tfe_workspace.app.id
}

resource "tfe_team_access" "devops_admin" {
  access       = "admin"
  team_id      = tfe_team.devops.id
  workspace_id = tfe_workspace.app.id
}

resource "tfe_team_access" "security_read" {
  access       = "read"
  team_id      = tfe_team.security.id
  workspace_id = tfe_workspace.app.id
}
```

---

### 8.6 Team Membership Management

**Add Users to Teams**:

```hcl
resource "tfe_team_member" "dev_alice" {
  team_id  = tfe_team.developers.id
  username = "alice"
}

resource "tfe_team_member" "dev_bob" {
  team_id  = tfe_team.developers.id
  username = "bob"
}

resource "tfe_team_members" "devops_team" {
  team_id = tfe_team.devops.id

  usernames = [
    "charlie",
    "diana",
  ]
}
```

**SSO Team Mapping** (UI Configuration):
- Map SSO groups to HCP Terraform teams
- Automatic team membership based on identity provider
- Supports SAML 2.0 and OIDC

---

### 8.7 RBAC Best Practices

**1. Principle of Least Privilege**
- Grant minimum permissions required
- Use Read access for auditors
- Reserve Admin access for team leads

**2. Separate Teams by Function**
```
developers → Write access to dev/staging workspaces
devops → Admin access to all workspaces
security → Read access + Policy management
auditors → Read-only access to all workspaces
```

**3. Use Organization-Level Permissions Sparingly**
- Only grant to trusted teams
- Prefer workspace-level permissions
- Document permission rationale

**4. Implement Approval Workflows**
- Require manual approval for production applies
- Use Sentinel policies for automated checks
- Separate plan and apply permissions

**5. Regular Access Reviews**
- Audit team membership quarterly
- Remove inactive users
- Review permission levels
- Document access changes

**6. Leverage SSO/SAML**
- Centralize identity management
- Automatic provisioning/deprovisioning
- Enforce MFA at identity provider level

**7. Workspace Naming Conventions**
```
<team>-<environment>-<application>
devops-prod-webapp
developers-dev-api
security-staging-database
```

---

### 8.8 Audit Logging and Compliance

**Audit Events Tracked**:
- User login/logout
- Team membership changes
- Permission modifications
- Workspace access
- Run approvals/applies
- Policy overrides
- State access

**Access Audit Logs**:
- Available in HCP Terraform UI
- Can be exported via API
- Integrate with SIEM tools
- Retain for compliance requirements

**Example: Retrieve Audit Logs via API**:

```bash
curl \
  --header "Authorization: Bearer $TFE_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organization/my-org/audit-trail
```

---

### 8.9 Common RBAC Scenarios

**Scenario 1: Developer Workflow**
- **Team**: Developers
- **Access**: Write to dev/staging, Plan to production
- **Workflow**: Develop → Test → Request approval for prod

**Scenario 2: Security Review**
- **Team**: Security
- **Access**: Read to all workspaces, Manage policies
- **Workflow**: Review plans → Enforce policies → Audit compliance

**Scenario 3: Emergency Response**
- **Team**: On-call DevOps
- **Access**: Admin to all workspaces
- **Workflow**: Respond to incidents → Apply fixes → Document changes

**Scenario 4: External Auditor**
- **Team**: Auditors
- **Access**: Read-only to all workspaces
- **Workflow**: Review configurations → Export state → Generate reports

---

## 10. HCP Terraform API

### 10.1 Introduction to HCP Terraform API

The **HCP Terraform API** provides programmatic access to all HCP Terraform functionality, enabling automation, integration with external systems, and custom workflows.

**Key Features**:
- **RESTful API**: Standard HTTP methods (GET, POST, PATCH, DELETE)
- **JSON API Specification**: Follows JSON:API standard for consistency
- **Authentication**: Token-based authentication with organization and team tokens
- **Rate Limiting**: 30 requests per second per organization
- **Versioned**: API version specified in headers

**API Base URL**:
```
https://app.terraform.io/api/v2
```

**Authentication Header**:
```bash
Authorization: Bearer <YOUR_TOKEN>
Content-Type: application/vnd.api+json
```

---

### 10.2 Authentication and Tokens

#### 10.2.1 Token Types

**1. User Tokens**
- Personal access tokens for individual users
- Created in User Settings → Tokens
- Inherit user's permissions
- Can be revoked at any time

**2. Team Tokens**
- Shared tokens for team-level access
- Created in Team Settings → Team API Token
- Inherit team's permissions
- One token per team

**3. Organization Tokens**
- Organization-wide access tokens
- Created in Organization Settings → API Token
- Full organization access
- Use with caution

#### 10.2.2 Creating a User Token

**Via UI**:
1. Navigate to User Settings → Tokens
2. Click "Create an API token"
3. Enter description (e.g., "CI/CD Pipeline")
4. Copy token immediately (shown only once)
5. Store securely (e.g., GitHub Secrets, AWS Secrets Manager)

**Token Format**:
```
<token_id>.<random_string>
```

Example:
```
AtlasToken.atlasv1.abc123def456...
```

---

### 10.3 Workspace Management API

#### 10.3.1 List Workspaces

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/my-org/workspaces
```

**Response**:
```json
{
  "data": [
    {
      "id": "ws-abc123",
      "type": "workspaces",
      "attributes": {
        "name": "prod-infrastructure",
        "terraform-version": "1.6.0",
        "working-directory": "",
        "auto-apply": false,
        "execution-mode": "remote"
      }
    }
  ]
}
```

#### 10.3.2 Create Workspace

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @payload.json \
  https://app.terraform.io/api/v2/organizations/my-org/workspaces
```

**Payload** (`payload.json`):
```json
{
  "data": {
    "type": "workspaces",
    "attributes": {
      "name": "new-workspace",
      "terraform-version": "1.6.0",
      "working-directory": "",
      "auto-apply": false,
      "execution-mode": "remote",
      "description": "Created via API"
    }
  }
}
```

#### 10.3.3 Update Workspace

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request PATCH \
  --data @update.json \
  https://app.terraform.io/api/v2/workspaces/ws-abc123
```

**Payload** (`update.json`):
```json
{
  "data": {
    "type": "workspaces",
    "attributes": {
      "auto-apply": true,
      "terraform-version": "1.6.0"
    }
  }
}
```

#### 10.3.4 Delete Workspace

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request DELETE \
  https://app.terraform.io/api/v2/workspaces/ws-abc123
```

---

### 10.4 Run Management API

#### 10.4.1 Create a Run (Queue Plan)

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @run.json \
  https://app.terraform.io/api/v2/runs
```

**Payload** (`run.json`):
```json
{
  "data": {
    "type": "runs",
    "attributes": {
      "message": "Triggered via API",
      "is-destroy": false
    },
    "relationships": {
      "workspace": {
        "data": {
          "type": "workspaces",
          "id": "ws-abc123"
        }
      }
    }
  }
}
```

**Response**:
```json
{
  "data": {
    "id": "run-xyz789",
    "type": "runs",
    "attributes": {
      "status": "pending",
      "message": "Triggered via API",
      "created-at": "2025-10-28T12:00:00Z"
    }
  }
}
```

#### 10.4.2 Get Run Status

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/runs/run-xyz789
```

**Response**:
```json
{
  "data": {
    "id": "run-xyz789",
    "type": "runs",
    "attributes": {
      "status": "applied",
      "status-timestamps": {
        "queued-at": "2025-10-28T12:00:00Z",
        "plan-queueable-at": "2025-10-28T12:00:05Z",
        "planning-at": "2025-10-28T12:00:10Z",
        "planned-at": "2025-10-28T12:01:00Z",
        "applying-at": "2025-10-28T12:02:00Z",
        "applied-at": "2025-10-28T12:03:00Z"
      }
    }
  }
}
```

**Run Statuses**:
- `pending` - Waiting to be queued
- `plan_queued` - Queued for planning
- `planning` - Currently planning
- `planned` - Plan complete, waiting for confirmation
- `confirmed` - Confirmed, ready to apply
- `apply_queued` - Queued for apply
- `applying` - Currently applying
- `applied` - Successfully applied
- `errored` - Error occurred
- `canceled` - Canceled by user

#### 10.4.3 Apply a Run

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data '{"comment": "Approved via API"}' \
  https://app.terraform.io/api/v2/runs/run-xyz789/actions/apply
```

#### 10.4.4 Cancel a Run

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data '{"comment": "Canceled via API"}' \
  https://app.terraform.io/api/v2/runs/run-xyz789/actions/cancel
```

---

### 10.5 Variable Management API

#### 10.5.1 List Variables

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/workspaces/ws-abc123/vars"
```

**Response**:
```json
{
  "data": [
    {
      "id": "var-123",
      "type": "vars",
      "attributes": {
        "key": "region",
        "value": "us-east-1",
        "category": "terraform",
        "sensitive": false,
        "description": "AWS region"
      }
    }
  ]
}
```

#### 10.5.2 Create Variable

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @variable.json \
  https://app.terraform.io/api/v2/workspaces/ws-abc123/vars
```

**Payload** (`variable.json`):
```json
{
  "data": {
    "type": "vars",
    "attributes": {
      "key": "instance_type",
      "value": "t3.medium",
      "category": "terraform",
      "sensitive": false,
      "description": "EC2 instance type",
      "hcl": false
    }
  }
}
```

**For Sensitive Variables**:
```json
{
  "data": {
    "type": "vars",
    "attributes": {
      "key": "db_password",
      "value": "super-secret-password",
      "category": "terraform",
      "sensitive": true,
      "description": "Database password"
    }
  }
}
```

#### 10.5.3 Update Variable

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request PATCH \
  --data @update-var.json \
  https://app.terraform.io/api/v2/workspaces/ws-abc123/vars/var-123
```

**Payload** (`update-var.json`):
```json
{
  "data": {
    "type": "vars",
    "attributes": {
      "value": "t3.large"
    }
  }
}
```

#### 10.5.4 Delete Variable

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request DELETE \
  https://app.terraform.io/api/v2/workspaces/ws-abc123/vars/var-123
```

---

### 10.6 State Version Management API

#### 10.6.1 List State Versions

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/workspaces/ws-abc123/state-versions"
```

**Response**:
```json
{
  "data": [
    {
      "id": "sv-abc123",
      "type": "state-versions",
      "attributes": {
        "created-at": "2025-10-28T12:00:00Z",
        "serial": 5,
        "terraform-version": "1.6.0",
        "vcs-commit-sha": "abc123def456",
        "vcs-commit-url": "https://github.com/org/repo/commit/abc123"
      }
    }
  ]
}
```

#### 10.6.2 Get Current State Version

**Request**:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/workspaces/ws-abc123/current-state-version
```

#### 10.6.3 Download State File

**Step 1**: Get state version with download URL:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/state-versions/sv-abc123
```

**Step 2**: Download from hosted-state-download-url:
```bash
curl \
  --header "Authorization: Bearer $TOKEN" \
  <hosted-state-download-url> \
  -o terraform.tfstate
```

---

### 10.7 Practical API Examples

#### 10.7.1 Python Example: Create Workspace and Trigger Run

```python
#!/usr/bin/env python3
import requests
import json
import time
import os

# Configuration
API_TOKEN = os.environ.get('TFC_TOKEN')
ORG_NAME = 'my-organization'
BASE_URL = 'https://app.terraform.io/api/v2'

headers = {
    'Authorization': f'Bearer {API_TOKEN}',
    'Content-Type': 'application/vnd.api+json'
}

def create_workspace(name, terraform_version='1.6.0'):
    """Create a new workspace"""
    payload = {
        'data': {
            'type': 'workspaces',
            'attributes': {
                'name': name,
                'terraform-version': terraform_version,
                'auto-apply': False,
                'execution-mode': 'remote'
            }
        }
    }

    response = requests.post(
        f'{BASE_URL}/organizations/{ORG_NAME}/workspaces',
        headers=headers,
        json=payload
    )

    if response.status_code == 201:
        workspace = response.json()['data']
        print(f"✅ Workspace created: {workspace['id']}")
        return workspace['id']
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return None

def trigger_run(workspace_id, message='Triggered via API'):
    """Trigger a new run"""
    payload = {
        'data': {
            'type': 'runs',
            'attributes': {
                'message': message,
                'is-destroy': False
            },
            'relationships': {
                'workspace': {
                    'data': {
                        'type': 'workspaces',
                        'id': workspace_id
                    }
                }
            }
        }
    }

    response = requests.post(
        f'{BASE_URL}/runs',
        headers=headers,
        json=payload
    )

    if response.status_code == 201:
        run = response.json()['data']
        print(f"✅ Run created: {run['id']}")
        return run['id']
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
        return None

def get_run_status(run_id):
    """Get run status"""
    response = requests.get(
        f'{BASE_URL}/runs/{run_id}',
        headers=headers
    )

    if response.status_code == 200:
        run = response.json()['data']
        return run['attributes']['status']
    else:
        return None

def wait_for_run(run_id, timeout=600):
    """Wait for run to complete"""
    start_time = time.time()

    while time.time() - start_time < timeout:
        status = get_run_status(run_id)
        print(f"Run status: {status}")

        if status in ['applied', 'errored', 'canceled', 'discarded']:
            return status

        time.sleep(10)

    return 'timeout'

# Main execution
if __name__ == '__main__':
    # Create workspace
    workspace_id = create_workspace('api-demo-workspace')

    if workspace_id:
        # Trigger run
        run_id = trigger_run(workspace_id, 'Initial deployment')

        if run_id:
            # Wait for completion
            final_status = wait_for_run(run_id)
            print(f"Final status: {final_status}")
```

#### 10.7.2 Bash Example: Manage Variables

```bash
#!/bin/bash
# manage-variables.sh - Manage HCP Terraform variables via API

set -e

# Configuration
TFC_TOKEN="${TFC_TOKEN}"
ORG_NAME="my-organization"
WORKSPACE_NAME="prod-infrastructure"
BASE_URL="https://app.terraform.io/api/v2"

# Get workspace ID
get_workspace_id() {
    curl -s \
        --header "Authorization: Bearer $TFC_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        "$BASE_URL/organizations/$ORG_NAME/workspaces/$WORKSPACE_NAME" \
        | jq -r '.data.id'
}

# Create or update variable
set_variable() {
    local key="$1"
    local value="$2"
    local sensitive="${3:-false}"
    local workspace_id="$4"

    # Check if variable exists
    existing_var=$(curl -s \
        --header "Authorization: Bearer $TFC_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        "$BASE_URL/workspaces/$workspace_id/vars" \
        | jq -r ".data[] | select(.attributes.key == \"$key\") | .id")

    if [ -n "$existing_var" ]; then
        # Update existing variable
        echo "Updating variable: $key"
        curl -s \
            --header "Authorization: Bearer $TFC_TOKEN" \
            --header "Content-Type: application/vnd.api+json" \
            --request PATCH \
            --data @- \
            "$BASE_URL/workspaces/$workspace_id/vars/$existing_var" <<EOF
{
  "data": {
    "type": "vars",
    "attributes": {
      "value": "$value",
      "sensitive": $sensitive
    }
  }
}
EOF
    else
        # Create new variable
        echo "Creating variable: $key"
        curl -s \
            --header "Authorization: Bearer $TFC_TOKEN" \
            --header "Content-Type: application/vnd.api+json" \
            --request POST \
            --data @- \
            "$BASE_URL/workspaces/$workspace_id/vars" <<EOF
{
  "data": {
    "type": "vars",
    "attributes": {
      "key": "$key",
      "value": "$value",
      "category": "terraform",
      "sensitive": $sensitive
    }
  }
}
EOF
    fi
}

# Main execution
WORKSPACE_ID=$(get_workspace_id)
echo "Workspace ID: $WORKSPACE_ID"

# Set variables
set_variable "region" "us-east-1" "false" "$WORKSPACE_ID"
set_variable "instance_type" "t3.medium" "false" "$WORKSPACE_ID"
set_variable "db_password" "super-secret" "true" "$WORKSPACE_ID"

echo "✅ Variables updated successfully"
```

---

### 10.8 API Best Practices

#### 10.8.1 Security Best Practices

**1. Token Management**
- ✅ Store tokens in secure secret managers (AWS Secrets Manager, HashiCorp Vault)
- ✅ Use environment variables, never hardcode tokens
- ✅ Rotate tokens regularly (every 90 days)
- ✅ Use team tokens for shared automation, user tokens for personal scripts
- ✅ Revoke tokens immediately when no longer needed

**2. Least Privilege**
- ✅ Use team tokens with minimal required permissions
- ✅ Create separate tokens for different automation tasks
- ✅ Avoid using organization tokens unless absolutely necessary

**3. Audit Logging**
- ✅ Log all API calls for audit trail
- ✅ Include timestamps, user/token, action, and result
- ✅ Monitor for unusual API activity

#### 10.8.2 Error Handling

**1. HTTP Status Codes**
- `200 OK` - Successful GET request
- `201 Created` - Successful POST request
- `204 No Content` - Successful DELETE request
- `400 Bad Request` - Invalid request payload
- `401 Unauthorized` - Invalid or missing token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation error
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

**2. Retry Logic**
```python
import time
import requests

def api_call_with_retry(url, headers, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = requests.get(url, headers=headers, timeout=30)

            if response.status_code == 429:
                # Rate limited, wait and retry
                wait_time = 2 ** attempt  # Exponential backoff
                print(f"Rate limited, waiting {wait_time}s...")
                time.sleep(wait_time)
                continue

            response.raise_for_status()
            return response.json()

        except requests.exceptions.RequestException as e:
            if attempt == max_retries - 1:
                raise
            print(f"Attempt {attempt + 1} failed: {e}")
            time.sleep(2 ** attempt)

    return None
```

#### 10.8.3 Rate Limiting

**Limits**:
- 30 requests per second per organization
- Applies to all API endpoints
- Shared across all users and tokens in organization

**Best Practices**:
- ✅ Implement exponential backoff for 429 responses
- ✅ Batch operations when possible
- ✅ Cache responses to reduce API calls
- ✅ Use webhooks for event-driven automation instead of polling

#### 10.8.4 Pagination

**Large Result Sets**:
```bash
# First page
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/my-org/workspaces?page[size]=20&page[number]=1"

# Next page
curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/my-org/workspaces?page[size]=20&page[number]=2"
```

**Python Pagination Example**:
```python
def get_all_workspaces(org_name):
    workspaces = []
    page = 1

    while True:
        response = requests.get(
            f'{BASE_URL}/organizations/{org_name}/workspaces',
            headers=headers,
            params={'page[size]': 100, 'page[number]': page}
        )

        data = response.json()
        workspaces.extend(data['data'])

        # Check if there are more pages
        if 'next' not in data.get('links', {}):
            break

        page += 1

    return workspaces
```

---

## 11. Certification Exam Focus

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

**Objective 9.2**: HCP Terraform Governance
- Understand Sentinel policy as code
- Know enforcement levels (advisory, soft-mandatory, hard-mandatory)
- Understand policy sets and workspace attachment
- Know common policy patterns (cost, security, compliance)

**Objective 9.3**: HCP Terraform Collaboration
- Understand organization and team structure
- Know workspace access levels (read, plan, write, admin)
- Understand organization-level vs workspace-level permissions
- Know RBAC best practices
- Understand team membership management

**Objective 9.1**: HCP Terraform Workflows
- Understand VCS-driven vs API-driven workflows
- Know how to connect workspaces to VCS repositories
- Understand automatic plan on PR and apply on merge
- Know VCS webhook configuration
- Understand branch-based workflows

**Objective 9.4**: HCP Terraform API (NEW)
- Understand API authentication with tokens
- Know how to manage workspaces via API
- Understand run management (create, apply, cancel)
- Know variable management via API
- Understand state version management
- Know API best practices (rate limiting, error handling, security)

### 💡 Exam Tips

- **Tip 1**: Always mark sensitive variables
- **Tip 2**: Encrypt state files
- **Tip 3**: Use least privilege IAM
- **Tip 4**: Enable audit logging
- **Tip 5**: Implement compliance tagging
- **Tip 6**: Understand Sentinel enforcement levels for HCP Terraform
- **Tip 7**: Know when to use hard-mandatory vs soft-mandatory policies
- **Tip 8**: Know the four workspace access levels (read, plan, write, admin)
- **Tip 9**: Understand the difference between organization and workspace permissions
- **Tip 10**: Understand VCS-driven workflow benefits (automatic plan on PR, apply on merge)
- **Tip 11**: Know the difference between VCS-driven, API-driven, and CLI-driven workflows
- **Tip 12**: Understand HCP Terraform API authentication (user, team, organization tokens)
- **Tip 13**: Know common API operations (workspace, run, variable, state management)
- **Tip 14**: Understand API rate limiting (30 requests/second per organization)

---

## 12. Key Takeaways

✅ **Secrets** should be managed securely
✅ **Sensitive data** must be protected
✅ **State files** must be encrypted
✅ **IAM** should follow least privilege
✅ **Network** security is critical
✅ **Compliance** requires tagging and logging
✅ **Sentinel policies** enforce governance in HCP Terraform
✅ **Policy as code** enables automated compliance
✅ **Team management** enables secure collaboration
✅ **RBAC** ensures proper access control
✅ **VCS integration** automates infrastructure workflows
✅ **GitOps** provides audit trail and collaboration
✅ **HCP Terraform API** enables programmatic automation
✅ **API-driven workflows** integrate with external systems

---

## Next Steps

1. Complete **Lab 12.1**: Secrets Management
2. Complete **Lab 12.2**: Secure State Backend
3. Complete **Lab 12.3**: Secure VPC Architecture
4. Complete **Lab 12.4**: Sentinel Policy Implementation
5. Complete **Lab 12.5**: Team Management and RBAC
6. Complete **Lab 12.6**: VCS-Driven Workflow
7. Complete **Lab 12.7**: HCP Terraform API Integration (NEW)
8. Review **Test-Your-Understanding-Topic-12.md**
9. Proceed to **Practice Exam**

---

**Document Version**: 5.0
**Last Updated**: October 28, 2025
**Status**: Enhanced with Sentinel Policy, Team Management, VCS Integration, and HCP Terraform API Content

