# Topic 10 Lab: Terraform Testing & Validation - Code Examples

This directory contains working Terraform code examples for Topic 10 labs.

## Files

- **providers.tf** - AWS provider configuration
- **variables.tf** - Input variables with validation
- **main.tf** - Testable infrastructure (EC2, security groups, alarms)
- **outputs.tf** - Output values for testing
- **.pre-commit-config.yaml** - Pre-commit hook configuration

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS account with EC2 permissions
- Python 3.7+ (for pre-commit)

## Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Set Up Pre-commit Hooks

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

### 3. Validate Configuration

```bash
terraform validate
terraform fmt -check
```

### 4. Plan Deployment

```bash
terraform plan
```

### 5. Apply Configuration

```bash
terraform apply
```

## Testing Commands

### Terraform Validation

```bash
# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Check format without modifying
terraform fmt -check
```

### Pre-commit Hooks

```bash
# Run all hooks
pre-commit run --all-files

# Run specific hook
pre-commit run terraform_fmt --all-files

# Run on staged files
pre-commit run
```

### Security Scanning

```bash
# Install tfsec
brew install tfsec

# Scan for security issues
tfsec .

# Scan with minimum severity
tfsec . --minimum-severity HIGH
```

## Variables

Customize behavior by creating `terraform.tfvars`:

```hcl
aws_region        = "us-east-1"
environment       = "lab"
instance_type     = "t2.micro"
enable_monitoring = true
instance_count    = 2
```

## Outputs

After applying, view outputs:

```bash
terraform output
terraform output instance_ids
terraform output test_results
```

## Testing Compliance

The configuration includes compliance checks:
- ✅ Monitoring enabled on all instances
- ✅ EBS optimization enabled
- ✅ Root volume encryption enabled
- ✅ Security group properly configured
- ✅ CloudWatch alarms configured

## Cleanup

Destroy resources when done:

```bash
terraform destroy
```

## Lab Exercises

### Exercise 1: Pre-commit Hooks
1. Install pre-commit framework
2. Run hooks on configuration
3. Verify formatting is applied
4. Make a commit to test hooks

### Exercise 2: Validation
1. Run `terraform validate`
2. Run `terraform fmt -check`
3. Fix any formatting issues
4. Re-run validation

### Exercise 3: Security Scanning
1. Install tfsec
2. Run security scan
3. Review findings
4. Verify compliance

## Best Practices

✅ Always run validation before commits  
✅ Use pre-commit hooks to automate checks  
✅ Enable monitoring on all instances  
✅ Encrypt sensitive data  
✅ Use security groups properly  
✅ Test infrastructure code  
✅ Document compliance requirements  

## Additional Resources

- [Terraform Validation](https://www.terraform.io/docs/commands/validate.html)
- [Pre-commit Framework](https://pre-commit.com/)
- [tfsec Documentation](https://aquasecurity.github.io/tfsec/)
- [Checkov Documentation](https://www.checkov.io/)

---

**Lab Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Ready for Use

