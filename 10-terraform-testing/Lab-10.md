# Topic 10: Hands-On Labs - Terraform Testing & Validation

**Estimated Time**: 4-5 hours  
**Difficulty**: Intermediate-Advanced  
**Prerequisites**: Topics 1-9 completed

---

## Lab Overview

This lab series covers four critical testing scenarios:
1. **Lab 10.1**: Pre-commit Hooks for Terraform Validation
2. **Lab 10.2**: Unit Tests with Terratest
3. **Lab 10.3**: Policy as Code with Sentinel
4. **Lab 10.4**: Security Scanning with tfsec and Checkov

---

## Lab 10.1: Pre-commit Hooks for Terraform Validation

### Objective
Set up automated validation using pre-commit hooks to catch errors before commits.

### Prerequisites
- Python 3.7+
- Git repository initialized
- Terraform installed

### Step 1: Install Pre-commit

```bash
pip install pre-commit
```

### Step 2: Create .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.81.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
        args: ['--config=.tflint.hcl']
      - id: terraform_docs
```

### Step 3: Install Hooks

```bash
pre-commit install
```

### Step 4: Test Hooks

```bash
# Run on all files
pre-commit run --all-files

# Run on staged files
pre-commit run
```

### Step 5: Verify

```bash
# Make a commit
git add .
git commit -m "Test pre-commit hooks"
```

---

## Lab 10.2: Unit Tests with Terratest

### Objective
Write and execute Go-based tests for Terraform modules.

### Prerequisites
- Go 1.16+
- Terraform installed
- AWS credentials configured

### Step 1: Set Up Go Project

```bash
mkdir terraform-tests
cd terraform-tests
go mod init terraform-tests
go get github.com/gruntwork-io/terratest/modules/terraform
```

### Step 2: Create Test File

Create `vpc_test.go`:

```go
package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVPCCreation(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId)
}
```

### Step 3: Run Tests

```bash
go test -v
```

### Step 4: Verify Results

```
=== RUN   TestVPCCreation
--- PASS: TestVPCCreation (45.23s)
PASS
ok      terraform-tests 45.23s
```

---

## Lab 10.3: Policy as Code with Sentinel

### Objective
Define and enforce infrastructure policies using Sentinel.

### Prerequisites
- Terraform Cloud account
- Sentinel CLI installed

### Step 1: Create Sentinel Policy

Create `enforce_monitoring.sentinel`:

```sentinel
import "tfplan/v2" as tfplan

main = rule {
  all tfplan.resources.aws_instance as _, instances {
    all instances as _, instance {
      instance.values.monitoring == true
    }
  }
}
```

### Step 2: Test Policy

```bash
sentinel test enforce_monitoring.sentinel
```

### Step 3: Apply Policy

Upload to Terraform Cloud and associate with workspace.

### Step 4: Verify Enforcement

```bash
terraform plan
# Policy will be evaluated
```

---

## Lab 10.4: Security Scanning

### Objective
Scan Terraform code for security vulnerabilities.

### Prerequisites
- tfsec installed: `brew install tfsec`
- Checkov installed: `pip install checkov`

### Step 1: Run tfsec

```bash
tfsec .
```

### Step 2: Run Checkov

```bash
checkov -d .
```

### Step 3: Review Results

```
Check: CKV_AWS_1: "Ensure EC2 is EBS optimized"
  PASSED for resource: aws_instance.web
  FAILED for resource: aws_instance.db
```

### Step 4: Remediate Issues

Update Terraform code to fix security issues:

```hcl
resource "aws_instance" "db" {
  ebs_optimized = true
  # ... other configuration
}
```

### Step 5: Re-scan

```bash
tfsec .
# All checks should pass
```

---

## Lab Verification Checklist

### Lab 10.1 Verification
- [ ] Pre-commit hooks installed
- [ ] Hooks run on commit
- [ ] terraform fmt applied
- [ ] terraform validate passed

### Lab 10.2 Verification
- [ ] Go tests written
- [ ] Tests execute successfully
- [ ] Assertions pass
- [ ] Terraform resources created

### Lab 10.3 Verification
- [ ] Sentinel policy created
- [ ] Policy tests pass
- [ ] Policy enforced in Terraform Cloud
- [ ] Plan evaluation works

### Lab 10.4 Verification
- [ ] tfsec scan completed
- [ ] Checkov scan completed
- [ ] Security issues identified
- [ ] Issues remediated

---

## Troubleshooting Guide

**Issue**: Pre-commit hooks not running
- **Solution**: Run `pre-commit install` again

**Issue**: Go tests fail with "module not found"
- **Solution**: Run `go mod tidy`

**Issue**: Sentinel policy syntax error
- **Solution**: Check policy syntax with `sentinel fmt`

**Issue**: Security scan finds too many issues
- **Solution**: Start with HIGH severity issues first

---

## Key Learnings

✅ Pre-commit hooks automate validation  
✅ Terratest enables infrastructure testing  
✅ Sentinel enforces infrastructure policies  
✅ Security scanning identifies vulnerabilities  
✅ Testing improves code quality  
✅ Automation prevents errors  

---

**Lab Completion Time**: 4-5 hours  
**Difficulty**: Intermediate-Advanced  
**Next**: Proceed to Topic 11 - Troubleshooting & Debugging

