# Topic 10: Terraform Testing & Validation

**Certification Alignment**: Exam Objectives 3.1, 6.3, 6.4  
**Terraform Version**: 1.0+  
**AWS Provider**: 6.0+

---

## Learning Objectives

By the end of this topic, you will be able to:
- ✅ Validate Terraform configurations using terraform validate
- ✅ Format code consistently with terraform fmt
- ✅ Implement pre-commit hooks for automated validation
- ✅ Write unit tests with Terratest
- ✅ Implement Policy as Code with Sentinel
- ✅ Perform security scanning with tfsec and Checkov
- ✅ Design testable infrastructure code
- ✅ Integrate testing into CI/CD pipelines

---

## 1. Terraform Validation Commands

### 1.1 terraform validate

**Purpose**: Validates Terraform configuration syntax and structure

```bash
terraform validate
```

**Output**:
```
Success! The configuration is valid.
```

**Common Errors**:
- Missing required arguments
- Invalid resource types
- Syntax errors
- Type mismatches

### 1.2 terraform fmt

**Purpose**: Formats Terraform code to canonical style

```bash
# Format current directory
terraform fmt

# Format recursively
terraform fmt -recursive

# Check without modifying
terraform fmt -check

# Show diff
terraform fmt -diff
```

### 1.3 terraform plan

**Purpose**: Preview infrastructure changes

```bash
terraform plan -out=tfplan
```

---

## 2. Pre-commit Hooks

### 2.1 Installation

```bash
pip install pre-commit
```

### 2.2 Configuration

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.81.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_docs
```

### 2.3 Setup

```bash
pre-commit install
pre-commit run --all-files
```

---

## 3. Testing Frameworks

### 3.1 Terratest

**Go-based testing framework** for Terraform modules

```go
package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformExample(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/terraform",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
```

### 3.2 Kitchen-Terraform

**Test-Kitchen plugin** for Terraform

```yaml
driver:
  name: terraform

provisioner:
  name: terraform

verifier:
  name: terraform
  systems:
    - name: default
      backend: local
```

---

## 4. Policy as Code

### 4.1 Sentinel

**HashiCorp's policy language** for infrastructure governance

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

### 4.2 OPA (Open Policy Agent)

**General-purpose policy engine**

```rego
package terraform

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    resource.change.after.monitoring == false
    msg := sprintf("Instance %s must have monitoring enabled", [resource.address])
}
```

---

## 5. Security Scanning

### 5.1 tfsec

**Static analysis tool** for Terraform security

```bash
tfsec .
tfsec . --format json
tfsec . --minimum-severity HIGH
```

### 5.2 Checkov

**Infrastructure as Code scanning** tool

```bash
checkov -d .
checkov -f main.tf
checkov --framework terraform
```

### 5.3 Terrascan

**Detect compliance and security violations**

```bash
terrascan scan -t terraform
terrascan scan -t terraform -f main.tf
```

---

## 6. Testing Best Practices

### 6.1 Test Pyramid

```
        /\
       /  \  Integration Tests
      /    \
     /------\
    /        \  Unit Tests
   /          \
  /____________\
```

### 6.2 Testable Code Patterns

**Good**: Modular, reusable components
```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = var.vpc_cidr
}
```

**Bad**: Monolithic, hard to test
```hcl
resource "aws_vpc" "main" {
  # Complex inline configuration
}
```

### 6.3 Test Organization

```
terraform/
├── modules/
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── tests/
│   ├── vpc_test.go
│   └── fixtures/
└── examples/
```

---

## 7. CI/CD Integration

### 7.1 GitHub Actions Example

```yaml
name: Terraform Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform fmt -check
      - run: terraform validate
      - run: tfsec .
```

### 7.2 GitLab CI Example

```yaml
stages:
  - validate
  - test
  - security

validate:
  stage: validate
  script:
    - terraform validate
    - terraform fmt -check

security:
  stage: security
  script:
    - tfsec .
```

---

## 8. Certification Exam Focus

### 🎓 Exam Objectives Covered

**Objective 3.1**: Terraform validation and formatting
- Know `terraform validate` command
- Understand `terraform fmt` usage
- Know when to use each command

**Objective 6.3**: Testing workflows
- Understand testing strategies
- Know testing frameworks
- Understand test organization

**Objective 6.4**: Quality assurance
- Know security scanning tools
- Understand policy as code
- Know CI/CD integration

### 💡 Exam Tips

- **Tip 1**: `terraform validate` checks syntax, not AWS permissions
- **Tip 2**: `terraform fmt` is idempotent (safe to run multiple times)
- **Tip 3**: Pre-commit hooks prevent bad code from being committed
- **Tip 4**: Terratest requires Go knowledge
- **Tip 5**: Sentinel is HashiCorp's policy language

---

## 9. Key Takeaways

✅ **terraform validate** checks configuration syntax  
✅ **terraform fmt** ensures consistent code style  
✅ **Pre-commit hooks** automate validation  
✅ **Terratest** enables infrastructure testing  
✅ **Sentinel** enforces infrastructure policies  
✅ **Security scanning** identifies vulnerabilities  
✅ **CI/CD integration** automates quality checks  

---

## Next Steps

1. Complete **Lab 10.1**: Pre-commit Hooks Setup
2. Complete **Lab 10.2**: Terratest Unit Tests
3. Complete **Lab 10.3**: Sentinel Policies
4. Complete **Lab 10.4**: Security Scanning
5. Review **Test-Your-Understanding-Topic-10.md** for assessment
6. Proceed to **Topic 11**: Troubleshooting & Debugging

---

**Document Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Labs

