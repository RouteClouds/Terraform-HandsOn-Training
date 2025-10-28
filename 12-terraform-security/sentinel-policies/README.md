# Sentinel Policy Examples

This directory contains working Sentinel policy examples for HCP Terraform (Terraform Cloud/Enterprise) governance and compliance.

## 📋 Policy Catalog

| Policy | Description | Enforcement Level | Use Case |
|--------|-------------|-------------------|----------|
| `require-s3-encryption.sentinel` | Enforce S3 bucket encryption | Hard Mandatory | Security compliance |
| `cost-limit.sentinel` | Limit monthly infrastructure cost | Soft Mandatory | Cost control |
| `require-tags.sentinel` | Enforce required resource tags | Hard Mandatory | Compliance & governance |
| `restrict-instance-types.sentinel` | Limit EC2 instance types by environment | Soft Mandatory | Cost & performance |
| `restrict-regions.sentinel` | Limit AWS regions for deployments | Hard Mandatory | Data sovereignty |

## 🚀 Quick Start

### Prerequisites

1. **HCP Terraform Account**: Sign up at https://app.terraform.io
2. **Sentinel CLI** (for local testing):
   ```bash
   wget https://releases.hashicorp.com/sentinel/0.24.0/sentinel_0.24.0_linux_amd64.zip
   unzip sentinel_0.24.0_linux_amd64.zip
   sudo mv sentinel /usr/local/bin/
   ```

### Testing Policies Locally

```bash
# Test all policies
sentinel test

# Test specific policy
sentinel test require-s3-encryption.sentinel

# Apply policy to test data
sentinel apply -config=sentinel.hcl require-s3-encryption.sentinel
```

### Deploying to HCP Terraform

#### Option 1: Using the UI

1. Navigate to **Organization Settings** → **Policy Sets**
2. Click **Create a new policy set**
3. Choose **API-driven workflow**
4. Upload policy files
5. Set enforcement levels
6. Attach to workspaces

#### Option 2: Using Terraform

```hcl
resource "tfe_policy_set" "security" {
  name         = "security-policies"
  description  = "Security and compliance policies"
  organization = var.organization_name
  
  policy_ids = [
    tfe_sentinel_policy.s3_encryption.id,
    tfe_sentinel_policy.required_tags.id,
  ]
  
  workspace_ids = [
    tfe_workspace.production.id,
  ]
}

resource "tfe_sentinel_policy" "s3_encryption" {
  name         = "require-s3-encryption"
  description  = "Require encryption for all S3 buckets"
  organization = var.organization_name
  policy       = file("${path.module}/require-s3-encryption.sentinel")
  enforce_mode = "hard-mandatory"
}
```

## 📚 Policy Documentation

### 1. require-s3-encryption.sentinel

**Purpose**: Ensures all S3 buckets have server-side encryption enabled.

**Enforcement**: Hard Mandatory (cannot be overridden)

**Rationale**: Protects sensitive data at rest, meets compliance requirements (HIPAA, PCI-DSS, SOC 2).

**Example Violation**:
```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
  # Missing: server_side_encryption_configuration
}
```

**Compliant Configuration**:
```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### 2. cost-limit.sentinel

**Purpose**: Prevents infrastructure deployments exceeding monthly cost threshold.

**Enforcement**: Soft Mandatory (can be overridden with justification)

**Rationale**: Prevents accidental expensive deployments, enables budget control.

**Configuration**: Modify `max_monthly_cost` variable in policy.

### 3. require-tags.sentinel

**Purpose**: Enforces required tags on all AWS resources.

**Enforcement**: Hard Mandatory

**Required Tags**:
- `Environment` (dev, staging, prod)
- `Owner` (team or individual email)
- `CostCenter` (department or project code)
- `Project` (project name)

**Rationale**: Enables cost allocation, resource tracking, compliance reporting.

### 4. restrict-instance-types.sentinel

**Purpose**: Limits EC2 instance types based on workspace/environment.

**Enforcement**: Soft Mandatory

**Rules**:
- **Dev**: t3.micro, t3.small only
- **Staging**: t3.small, t3.medium, t3.large
- **Production**: t3.medium, t3.large, m5.large, m5.xlarge

**Rationale**: Prevents over-provisioning in non-production, ensures adequate resources in production.

### 5. restrict-regions.sentinel

**Purpose**: Limits AWS deployments to approved regions.

**Enforcement**: Hard Mandatory

**Allowed Regions** (default):
- us-east-1 (N. Virginia)
- us-west-2 (Oregon)
- eu-west-1 (Ireland)

**Rationale**: Data sovereignty compliance, cost optimization, latency requirements.

## 🧪 Testing Strategy

### Unit Testing

Each policy includes test cases in the `test/` directory:

```
test/
├── require-s3-encryption/
│   ├── pass.hcl          # Should pass
│   ├── fail.hcl          # Should fail
│   └── mock-tfplan-v2.sentinel
```

Run tests:
```bash
sentinel test require-s3-encryption.sentinel
```

### Integration Testing

Test policies against real Terraform plans:

```bash
# Generate plan
terraform plan -out=tfplan.binary

# Convert to JSON
terraform show -json tfplan.binary > tfplan.json

# Test policy
sentinel apply -config=sentinel.hcl require-s3-encryption.sentinel
```

## 📊 Monitoring & Reporting

### Policy Run Dashboard

Monitor policy enforcement in HCP Terraform:
1. Navigate to **Organization Settings** → **Policy Sets**
2. View **Policy Checks** tab for run history
3. Analyze pass/fail rates and common violations

### Metrics to Track

- **Pass Rate**: Percentage of runs passing all policies
- **Override Rate**: Frequency of soft-mandatory overrides
- **Common Violations**: Most frequently violated policies
- **Time to Remediation**: Time from violation to fix

## 🔧 Customization Guide

### Modifying Enforcement Levels

Edit `sentinel.hcl`:

```hcl
policy "require-s3-encryption" {
    enforcement_level = "hard-mandatory"  # Change to "soft-mandatory" or "advisory"
}
```

### Adding Custom Policies

1. Create new `.sentinel` file
2. Follow existing policy structure
3. Add test cases
4. Update `sentinel.hcl`
5. Test locally before deploying

### Environment-Specific Policies

Use workspace names to apply different rules:

```sentinel
workspace_name = tfplan.workspace.name

is_production = strings.has_prefix(workspace_name, "prod")

main = rule when is_production {
    # Stricter rules for production
}
```

## 🆘 Troubleshooting

### Common Issues

**Issue**: Policy fails but should pass
- **Solution**: Check Terraform version compatibility, verify mock data format

**Issue**: Policy passes but should fail
- **Solution**: Review policy logic, check resource addressing

**Issue**: Cannot override soft-mandatory policy
- **Solution**: Verify user has override permissions in HCP Terraform

### Debug Mode

Enable verbose output:
```bash
sentinel apply -trace require-s3-encryption.sentinel
```

## 🚀 Advanced Policies

For more sophisticated policy examples, see the **`advanced/`** directory:

- **`common-functions.sentinel`**: Reusable utility functions for policy composition
- **`multi-resource-validation.sentinel`**: Validates relationships between multiple resource types (RDS security)
- **`cost-budget-enforcement.sentinel`**: Advanced cost calculation with detailed pricing for EC2, RDS, and EBS
- **`time-based-freeze.sentinel`**: Time-based change freeze periods (holiday freezes, maintenance windows)

See **[`advanced/README.md`](advanced/README.md)** for detailed documentation and usage examples.

---

## 📖 Additional Resources

- [Sentinel Documentation](https://docs.hashicorp.com/sentinel)
- [Sentinel Language Specification](https://docs.hashicorp.com/sentinel/language)
- [HCP Terraform Policy Sets](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement)
- [Sentinel Testing Guide](https://developer.hashicorp.com/sentinel/docs/commands/test)
- [Terraform Associate Certification](https://www.hashicorp.com/certification/terraform-associate)

## 🤝 Contributing

To add new policies:
1. Follow existing naming conventions
2. Include comprehensive documentation
3. Add test cases (pass and fail scenarios)
4. Update this README

---

**Version**: 2.0
**Last Updated**: October 28, 2025
**Maintainer**: RouteCloud Training Team

