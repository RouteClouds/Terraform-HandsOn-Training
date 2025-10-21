# Topic 10: Terraform Testing & Validation

**Certification Alignment**: Terraform Associate 003/004  
**Exam Objectives**: 3.1, 6.3, 6.4  
**Difficulty**: Intermediate-Advanced  
**Estimated Time**: 4-5 hours

---

## Overview

Topic 10 covers comprehensive Terraform testing strategies, validation techniques, and quality assurance practices. This is critical for ensuring infrastructure code quality and compliance.

## Learning Objectives

By completing this topic, you will be able to:

✅ Validate Terraform configurations using terraform validate  
✅ Format code consistently with terraform fmt  
✅ Implement pre-commit hooks for automated validation  
✅ Write unit tests with Terratest  
✅ Implement Policy as Code with Sentinel  
✅ Perform security scanning with tfsec and Checkov  
✅ Design testable infrastructure code  
✅ Integrate testing into CI/CD pipelines  

## Directory Structure

```
10-terraform-testing/
├── Concept.md                          # Comprehensive theory (1000+ lines)
├── Lab-10.md                           # Hands-on labs (700+ lines)
├── Test-Your-Understanding-Topic-10.md # Assessment (400+ lines)
├── README.md                           # This file
├── Terraform-Code-Lab-10.1/            # Working code examples
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── .pre-commit-config.yaml
│   └── README.md
└── DaC/                                # Diagram as Code
    ├── requirements.txt
    ├── testing_workflow_diagram.py
    ├── validation_pipeline_diagram.py
    ├── policy_enforcement_diagram.py
    ├── generate_all_diagrams.py
    └── README.md
```

## Content Files

### 1. **Concept.md** (1000+ lines)
Comprehensive theory covering:
- Terraform validation commands
- Pre-commit hooks setup
- Testing frameworks (Terratest, Kitchen-Terraform)
- Policy as Code (Sentinel, OPA)
- Security scanning tools (tfsec, Checkov, Terrascan)
- Testing best practices
- CI/CD integration
- Certification exam focus areas

### 2. **Lab-10.md** (700+ lines)
Four hands-on labs:
- **Lab 10.1**: Pre-commit Hooks Setup
- **Lab 10.2**: Terratest Unit Tests
- **Lab 10.3**: Sentinel Policies
- **Lab 10.4**: Security Scanning

### 3. **Test-Your-Understanding-Topic-10.md** (400+ lines)
Assessment with:
- 12 multiple-choice questions
- 3 scenario-based questions
- 2 hands-on exercises
- Answer key with explanations

### 4. **Terraform-Code-Lab-10.1/**
Working code examples:
- Complete Terraform configuration
- Pre-commit hook configuration
- Testable infrastructure
- Ready to use for labs

### 5. **DaC/** (Diagram as Code)
Professional diagrams:
- Testing workflow diagram
- Validation pipeline diagram
- Policy enforcement diagram
- Reproducible and version-controlled

## Certification Alignment

### Exam Objectives Covered

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

## Getting Started

### Step 1: Review Concept Material
Start with **Concept.md** to understand:
- Terraform validation fundamentals
- Testing frameworks and tools
- Policy as Code concepts
- Security scanning practices

### Step 2: Generate Diagrams
```bash
cd DaC
pip install -r requirements.txt
python generate_all_diagrams.py
```

### Step 3: Complete Labs
Follow **Lab-10.md** to:
- Set up pre-commit hooks
- Write Terratest tests
- Implement Sentinel policies
- Run security scans

### Step 4: Test Your Knowledge
Complete **Test-Your-Understanding-Topic-10.md**:
- Answer 12 multiple-choice questions
- Solve 3 scenario-based problems
- Complete 2 hands-on exercises

### Step 5: Practice with Code
Use **Terraform-Code-Lab-10.1/** to:
- Apply working Terraform configuration
- Practice validation commands
- Experiment with testing tools

## Key Concepts

### Terraform Validation
```bash
terraform validate  # Check syntax
terraform fmt       # Format code
```

### Pre-commit Hooks
```bash
pre-commit install
pre-commit run --all-files
```

### Testing Frameworks
- **Terratest**: Go-based testing
- **Kitchen-Terraform**: Test-Kitchen plugin
- **Sentinel**: HashiCorp policy language

### Security Scanning
- **tfsec**: Static analysis for security
- **Checkov**: Infrastructure as Code scanning
- **Terrascan**: Compliance violation detection

## Exam Tips

💡 **Tip 1**: `terraform validate` checks syntax, not AWS permissions  
💡 **Tip 2**: `terraform fmt` is idempotent (safe to run multiple times)  
💡 **Tip 3**: Pre-commit hooks prevent bad code from being committed  
💡 **Tip 4**: Terratest requires Go knowledge  
💡 **Tip 5**: Sentinel is HashiCorp's policy language  

## Common Scenarios

### Scenario 1: Enforce Monitoring
Use Sentinel to require monitoring on all EC2 instances.

### Scenario 2: Prevent Bad Commits
Use pre-commit hooks to validate code before commits.

### Scenario 3: Security Compliance
Use tfsec and Checkov to scan for security issues.

## Best Practices

✅ Always validate before commits  
✅ Use pre-commit hooks to automate checks  
✅ Write testable infrastructure code  
✅ Implement security scanning  
✅ Enforce policies with Sentinel  
✅ Integrate testing into CI/CD  
✅ Document compliance requirements  

## Next Steps

After completing Topic 10:
1. Review certification exam objectives 3.1, 6.3, 6.4
2. Practice validation and testing techniques
3. Proceed to **Topic 11**: Troubleshooting & Debugging
4. Continue with remaining topics for full certification prep

## Resources

- [Terraform Validation Documentation](https://www.terraform.io/docs/commands/validate.html)
- [Pre-commit Framework](https://pre-commit.com/)
- [Terratest Documentation](https://terratest.gruntwork.io/)
- [Sentinel Documentation](https://www.terraform.io/cloud-docs/policy-enforcement/sentinel)
- [tfsec Documentation](https://aquasecurity.github.io/tfsec/)

---

**Topic Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Learning

**Estimated Completion Time**: 4-5 hours  
**Difficulty Level**: Intermediate-Advanced  
**Prerequisites**: Topics 1-9 completed

