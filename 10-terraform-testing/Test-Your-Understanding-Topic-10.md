# Topic 10: Test Your Understanding - Terraform Testing & Validation

**Total Questions**: 17  
**Time Limit**: 30 minutes  
**Passing Score**: 70% (12/17 correct)

---

## Multiple Choice Questions (12 questions)

### Question 1
What does `terraform validate` check?

A) AWS API permissions  
B) Configuration syntax and structure  
C) Resource pricing  
D) Network connectivity  

**Answer**: B  
**Explanation**: `terraform validate` checks syntax and structure, not AWS permissions or connectivity.

---

### Question 2
What is the purpose of `terraform fmt`?

A) Format and validate code  
B) Format code to canonical style  
C) Check for security issues  
D) Generate documentation  

**Answer**: B  
**Explanation**: `terraform fmt` formats code consistently, not validates or checks security.

---

### Question 3
Which tool is used for Go-based infrastructure testing?

A) Kitchen-Terraform  
B) Terratest  
C) Sentinel  
D) tfsec  

**Answer**: B  
**Explanation**: Terratest is the Go-based testing framework for Terraform.

---

### Question 4
What is Sentinel?

A) AWS security service  
B) HashiCorp's policy language  
C) Terraform module registry  
D) CI/CD platform  

**Answer**: B  
**Explanation**: Sentinel is HashiCorp's policy language for infrastructure governance.

---

### Question 5
Which command checks for security vulnerabilities in Terraform code?

A) terraform validate  
B) terraform fmt  
C) tfsec  
D) terraform plan  

**Answer**: C  
**Explanation**: tfsec is a static analysis tool for Terraform security.

---

### Question 6
What does pre-commit do?

A) Commits code automatically  
B) Runs hooks before commits  
C) Prevents all commits  
D) Backs up code  

**Answer**: B  
**Explanation**: Pre-commit runs hooks before commits to catch errors early.

---

### Question 7
Which tool is used for general-purpose policy enforcement?

A) Sentinel  
B) tfsec  
C) OPA (Open Policy Agent)  
D) Checkov  

**Answer**: C  
**Explanation**: OPA is a general-purpose policy engine, while Sentinel is HashiCorp-specific.

---

### Question 8
What is the correct order for testing infrastructure?

A) Integration → Unit → Security  
B) Unit → Integration → Security  
C) Security → Unit → Integration  
D) Integration → Security → Unit  

**Answer**: B  
**Explanation**: Test pyramid: Unit tests first, then integration, then security.

---

### Question 9
Which tool scans for compliance violations?

A) tfsec  
B) Checkov  
C) Terrascan  
D) All of the above  

**Answer**: D  
**Explanation**: All three tools can scan for compliance violations.

---

### Question 10
What does `terraform fmt -check` do?

A) Formats code  
B) Checks format without modifying  
C) Checks for errors  
D) Checks AWS permissions  

**Answer**: B  
**Explanation**: `-check` flag shows if formatting is needed without modifying files.

---

### Question 11
Which is a testable code pattern?

A) Monolithic resources  
B) Modular components  
C) Inline configuration  
D) Hard-coded values  

**Answer**: B  
**Explanation**: Modular components are easier to test and reuse.

---

### Question 12
What is the primary benefit of pre-commit hooks?

A) Faster deployments  
B) Catch errors before commits  
C) Reduce AWS costs  
D) Improve documentation  

**Answer**: B  
**Explanation**: Pre-commit hooks catch errors early in the development process.

---

## Scenario-Based Questions (3 questions)

### Scenario 1
You want to ensure all EC2 instances have monitoring enabled. Which tool would you use?

**Answer**: Sentinel (or OPA)
- Write a policy that requires monitoring = true
- Enforce policy in Terraform Cloud
- Policy blocks plans that violate the rule

---

### Scenario 2
Your team commits Terraform code with formatting issues. How would you prevent this?

**Answer**: Pre-commit hooks
- Install pre-commit framework
- Configure terraform_fmt hook
- Hooks run before commits
- Prevents commits with formatting issues

---

### Scenario 3
You need to test a Terraform module to ensure it creates resources correctly. What approach would you use?

**Answer**: Terratest
- Write Go tests
- Use Terratest to apply configuration
- Assert resources are created correctly
- Verify outputs match expectations

---

## Hands-On Exercises (2 exercises)

### Exercise 1: Set Up Pre-commit Hooks
1. Create `.pre-commit-config.yaml`
2. Install pre-commit framework
3. Run hooks on existing Terraform code
4. Verify formatting is applied

### Exercise 2: Run Security Scans
1. Install tfsec and Checkov
2. Scan Terraform code
3. Identify security issues
4. Remediate issues
5. Re-scan to verify fixes

---

## Answer Key Summary

**Multiple Choice**: Questions 1-12  
- Q1: B, Q2: B, Q3: B, Q4: B, Q5: C  
- Q6: B, Q7: C, Q8: B, Q9: D, Q10: B  
- Q11: B, Q12: B  

**Scenario Questions**: 1-3  
- See detailed answers above  

**Hands-On Exercises**: 1-2  
- Complete exercises and document results  

---

## Scoring Guide

- **15-17 correct**: Excellent - Ready for certification exam
- **13-14 correct**: Good - Review weak areas
- **12 correct**: Passing - Study additional resources
- **Below 12**: Review Topic 10 content and retake

---

**Assessment Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Testing

