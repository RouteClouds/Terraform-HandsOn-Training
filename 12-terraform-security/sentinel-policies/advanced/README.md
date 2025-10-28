# Advanced Sentinel Policies

This directory contains advanced Sentinel policy examples demonstrating sophisticated patterns for policy as code in HCP Terraform.

## 📚 Policies Overview

### 1. Common Functions Module (`common-functions.sentinel`)

**Purpose**: Reusable utility functions for policy composition

**Key Functions**:
- `get_resources(resource_type)` - Get all resources of a specific type
- `get_environment()` - Determine environment from workspace name
- `has_required_tags(resource, required_tags)` - Check if resource has required tags
- `get_missing_tags(resource, required_tags)` - Get list of missing tags
- `count_resources(resource_type)` - Count resources of a type
- `is_production()`, `is_staging()`, `is_development()` - Environment checks
- `print_violation(address, message, severity)` - Formatted violation output

**Usage Example**:

```sentinel
import "common-functions" as common

# Get all EC2 instances
ec2_instances = common.get_resources("aws_instance")

# Check environment
if common.is_production() {
    # Apply stricter rules for production
}

# Validate tags
for ec2_instances as item {
    if not common.has_required_tags(item.resource, ["Environment", "Owner"]) {
        # Handle violation
    }
}
```

---

### 2. Multi-Resource Validation (`multi-resource-validation.sentinel`)

**Purpose**: Validate relationships and security configurations across multiple resource types

**Enforcement Level**: Hard-mandatory

**Checks Performed**:

**RDS Security Validation**:
- ✅ Not publicly accessible
- ✅ Has security groups attached
- ✅ Backup retention >= 7 days (14 days for production)
- ✅ Storage encryption enabled
- ✅ Multi-AZ enabled for production
- ✅ Deletion protection for production
- ✅ DB subnet group configured
- ✅ Engine version explicitly specified
- ✅ Enhanced monitoring enabled (production)
- ✅ Auto minor version upgrade enabled

**Severity Levels**:
- **Critical**: Publicly accessible, no encryption
- **High**: No security groups, no Multi-AZ (prod), no deletion protection (prod)
- **Medium**: Low backup retention, no subnet group
- **Low**: No engine version, monitoring issues, auto-upgrade disabled

**Example Output**:

```
============================================================
Multi-Resource Validation Policy
============================================================
Environment: production
Total violations: 3

Violations by severity:
  Critical: 1
  High: 1
  Medium: 1
  Low: 0

Detailed violations:
  [CRITICAL] aws_db_instance.main
    Issue: RDS storage encryption not enabled
    Remediation: Set storage_encrypted = true

  [HIGH] aws_db_instance.main
    Issue: RDS Multi-AZ not enabled in production
    Remediation: Set multi_az = true for production databases

  [MEDIUM] aws_db_instance.main
    Issue: RDS backup retention less than 14 days (found: 7)
    Remediation: Set backup_retention_period >= 14

============================================================
```

---

### 3. Cost Budget Enforcement (`cost-budget-enforcement.sentinel`)

**Purpose**: Calculate estimated monthly costs and enforce budget limits

**Enforcement Level**: Soft-mandatory (allows override with reason)

**Features**:
- Calculates EC2 instance costs (15+ instance types)
- Calculates RDS instance costs (includes Multi-AZ multiplier)
- Calculates EBS volume costs (7 volume types)
- Includes storage costs for RDS
- Environment-specific budget limits
- Detailed cost breakdown by resource

**Budget Limits**:
- Development: $500/month
- Staging: $2,000/month
- Production: $10,000/month

**Supported Resources**:

**EC2 Instances**:
- T3: micro, small, medium, large, xlarge, 2xlarge
- M5: large, xlarge, 2xlarge, 4xlarge
- C5: large, xlarge, 2xlarge
- R5: large, xlarge, 2xlarge

**RDS Instances**:
- db.t3: micro, small, medium, large
- db.m5: large, xlarge, 2xlarge
- db.r5: large, xlarge

**EBS Volumes**:
- gp2, gp3 (General Purpose SSD)
- io1, io2 (Provisioned IOPS SSD)
- st1 (Throughput Optimized HDD)
- sc1 (Cold HDD)
- standard (Magnetic)

**Example Output**:

```
======================================================================
Cost Budget Enforcement Policy
======================================================================
Environment: production
Budget Limit: $10000/month

Resource Costs:
  EC2 Instances (5):                     $350.40
  RDS Instances (2):                     $1152.00
  EBS Volumes (3):                       $45.00
  --------------------------------------------------
  Total Monthly Cost:                    $1547.40

Budget Analysis:
  Budget Utilization: 15.47%
  Budget Remaining:  $8452.60

EC2 Instance Details:
  - aws_instance.web[0]
    Type: t3.medium | Monthly Cost: $30.37
  - aws_instance.web[1]
    Type: t3.medium | Monthly Cost: $30.37
  ...

RDS Instance Details:
  - aws_db_instance.main
    Class: db.m5.large (Multi-AZ) | Monthly Cost: $280.32
  ...

======================================================================
```

---

### 4. Time-Based Change Freeze (`time-based-freeze.sentinel`)

**Purpose**: Block or warn about infrastructure changes during defined freeze periods

**Enforcement Level**: Hard-mandatory for production/staging, advisory for development

**Features**:
- Define multiple freeze periods with start/end dates
- Hard freeze (blocks changes) vs soft freeze (warns only)
- Environment-specific enforcement
- Business hours enforcement (optional)
- Change summary reporting

**Freeze Period Configuration**:

```sentinel
freeze_periods = [
    {
        "start": "2025-11-20",
        "end":   "2025-12-05",
        "reason": "Thanksgiving holiday freeze period",
        "severity": "hard",  # Blocks all changes
    },
    {
        "start": "2025-12-20",
        "end":   "2026-01-05",
        "reason": "Year-end holiday freeze period",
        "severity": "hard",
    },
    {
        "start": "2025-06-15",
        "end":   "2025-06-20",
        "reason": "Mid-year audit period",
        "severity": "soft",  # Warns but allows changes
    },
]
```

**Example Output**:

```
======================================================================
Time-Based Change Freeze Policy
======================================================================
Current Time: 2025-11-25 14:30:00 +0000 UTC
Environment: production
Workspace: prod-infrastructure

Changes Summary:
  Resources to create: 3
  Resources to update: 2
  Resources to delete: 0
  Total changes: 5

⚠️  ACTIVE CHANGE FREEZE PERIODS:

🚫 Freeze Period Active
  Reason: Thanksgiving holiday freeze period
  Period: 2025-11-20 to 2025-12-05
  Severity: HARD

❌ Changes are BLOCKED during hard freeze periods
   Contact your infrastructure team for emergency change approval

Configured Freeze Periods:
  - 2025-11-20 to 2025-12-05 (Thanksgiving holiday freeze period)
  - 2025-12-20 to 2026-01-05 (Year-end holiday freeze period)
  - 2025-06-15 to 2025-06-20 (Mid-year audit period)

======================================================================
```

---

## 🧪 Testing Advanced Policies

### Test Structure

Each policy should have a corresponding test directory:

```
test/
├── policy-name/
│   ├── pass.hcl
│   ├── fail.hcl
│   └── mocks/
│       ├── pass.json
│       └── fail.json
```

### Running Tests

```bash
# Install Sentinel CLI
wget https://releases.hashicorp.com/sentinel/0.24.0/sentinel_0.24.0_linux_amd64.zip
unzip sentinel_0.24.0_linux_amd64.zip
sudo mv sentinel /usr/local/bin/

# Run all tests
cd 12-terraform-security/sentinel-policies/advanced
sentinel test

# Run tests with verbose output
sentinel test -verbose

# Run specific test
sentinel test -run=pass
```

### Generating Mock Data

```bash
# Generate Terraform plan
terraform plan -out=tfplan

# Convert to JSON
terraform show -json tfplan > plan.json

# Extract mock data
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

---

## 📖 Usage in HCP Terraform

### 1. Create Policy Set

```hcl
# sentinel.hcl
policy "multi-resource-validation" {
    source = "./advanced/multi-resource-validation.sentinel"
    enforcement_level = "hard-mandatory"
}

policy "cost-budget-enforcement" {
    source = "./advanced/cost-budget-enforcement.sentinel"
    enforcement_level = "soft-mandatory"
}

policy "time-based-freeze" {
    source = "./advanced/time-based-freeze.sentinel"
    enforcement_level = "hard-mandatory"
}
```

### 2. Upload to HCP Terraform

**Via UI**:
1. Navigate to Organization Settings → Policy Sets
2. Click "Create a new policy set"
3. Choose "API-driven" workflow
4. Upload policy files
5. Attach to workspaces

**Via Terraform**:

```hcl
resource "tfe_policy_set" "advanced_policies" {
  name         = "advanced-sentinel-policies"
  description  = "Advanced Sentinel policies for governance"
  organization = "my-org"
  
  policy_ids = [
    tfe_sentinel_policy.multi_resource.id,
    tfe_sentinel_policy.cost_budget.id,
    tfe_sentinel_policy.time_freeze.id,
  ]
  
  workspace_ids = [
    tfe_workspace.prod.id,
    tfe_workspace.staging.id,
  ]
}
```

---

## 🎯 Best Practices

1. **Policy Composition**: Use `common-functions.sentinel` for reusable logic
2. **Test Coverage**: Create both pass and fail test cases
3. **Clear Messages**: Provide actionable remediation guidance
4. **Severity Levels**: Use appropriate severity for violations
5. **Environment Awareness**: Apply stricter rules to production
6. **Cost Awareness**: Keep pricing data updated
7. **Documentation**: Document all freeze periods and exceptions

---

## 🔄 Maintenance

### Updating Pricing Data

Update pricing in `cost-budget-enforcement.sentinel`:

```sentinel
ec2_pricing = {
    "t3.micro": decimal.new(0.0104),  # Update with current pricing
    # ...
}
```

### Adding Freeze Periods

Update `time-based-freeze.sentinel`:

```sentinel
freeze_periods = [
    {
        "start": "2026-11-20",
        "end":   "2026-12-05",
        "reason": "Thanksgiving 2026",
        "severity": "hard",
    },
    # Add new periods here
]
```

---

## 📚 Additional Resources

- [Sentinel Documentation](https://docs.hashicorp.com/sentinel)
- [Sentinel Language Specification](https://docs.hashicorp.com/sentinel/language)
- [HCP Terraform Policy Sets](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement)
- [Sentinel Imports](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/sentinel/import)

---

**Version**: 1.0  
**Last Updated**: October 28, 2025  
**Author**: RouteCloud Training Team

