# Topic 12: Test Your Understanding - Advanced Security & Compliance

**Total Questions**: 15  
**Time Limit**: 30 minutes  
**Passing Score**: 70% (11/15 correct)

---

## Multiple Choice Questions (12 questions)

### Question 1
How do you mark a variable as sensitive in Terraform?

A) `variable "password" { type = string }`  
B) `variable "password" { type = string; sensitive = true }`  
C) `variable "password" { secret = true }`  
D) `variable "password" { encrypted = true }`  

**Answer**: B  
**Explanation**: The `sensitive = true` flag marks a variable as sensitive.

---

### Question 2
What does encrypting the Terraform state file protect?

A) Terraform code  
B) AWS resources  
C) Sensitive data in state  
D) Network traffic  

**Answer**: C  
**Explanation**: Encrypting state protects sensitive data stored in the state file.

---

### Question 3
Which AWS service is used for secrets management?

A) AWS KMS  
B) AWS Secrets Manager  
C) AWS Parameter Store  
D) All of the above  

**Answer**: D  
**Explanation**: All three services can be used for secrets management.

---

### Question 4
What is the principle of least privilege?

A) Give all permissions  
B) Give only required permissions  
C) Give admin permissions  
D) Give no permissions  

**Answer**: B  
**Explanation**: Least privilege means giving only the minimum required permissions.

---

### Question 5
How do you enable state file encryption in S3?

A) `encrypt = true` in backend  
B) Enable S3 encryption  
C) Use KMS key  
D) All of the above  

**Answer**: D  
**Explanation**: All methods can be used to encrypt state files.

---

### Question 6
What is OIDC authentication used for?

A) Database authentication  
B) AWS API authentication  
C) GitHub Actions authentication  
D) All of the above  

**Answer**: D  
**Explanation**: OIDC can be used for various authentication scenarios.

---

### Question 7
How do you reference a secret from AWS Secrets Manager?

A) `aws_secret.name`  
B) `data.aws_secretsmanager_secret_version`  
C) `aws_secretsmanager_secret`  
D) `var.secret`  

**Answer**: B  
**Explanation**: Use `data.aws_secretsmanager_secret_version` to reference secrets.

---

### Question 8
What is a security group?

A) IAM role  
B) Virtual firewall  
C) Encryption key  
D) Backup service  

**Answer**: B  
**Explanation**: Security groups act as virtual firewalls for EC2 instances.

---

### Question 9
What does VPC stand for?

A) Virtual Private Cloud  
B) Virtual Public Cloud  
C) Virtual Private Connection  
D) Virtual Protocol Cloud  

**Answer**: A  
**Explanation**: VPC stands for Virtual Private Cloud.

---

### Question 10
How do you enable state locking?

A) Use DynamoDB table  
B) Use S3 versioning  
C) Use KMS encryption  
D) Use IAM policies  

**Answer**: A  
**Explanation**: DynamoDB table is used for state locking.

---

### Question 11
What is CloudTrail used for?

A) Audit logging  
B) Performance monitoring  
C) Cost tracking  
D) Resource tagging  

**Answer**: A  
**Explanation**: CloudTrail provides audit logging for AWS API calls.

---

### Question 12
How do you mark an output as sensitive?

A) `output "password" { value = var.password }`  
B) `output "password" { value = var.password; sensitive = true }`  
C) `output "password" { secret = true }`  
D) `output "password" { encrypted = true }`  

**Answer**: B  
**Explanation**: Use `sensitive = true` to mark outputs as sensitive.

---

## Scenario-Based Questions (3 questions)

### Scenario 1
You need to store a database password securely in Terraform. What approach would you use?

**Answer**:
1. Create secret in AWS Secrets Manager
2. Reference secret using data source
3. Mark variable as sensitive
4. Mark output as sensitive
5. Encrypt state file

---

### Scenario 2
You want to ensure only specific IAM users can modify Terraform state. How would you implement this?

**Answer**:
1. Create S3 bucket for state
2. Enable encryption
3. Create IAM policy with specific permissions
4. Attach policy to users
5. Enable state locking with DynamoDB

---

### Scenario 3
You need to build a secure VPC with public and private subnets. What components would you create?

**Answer**:
1. VPC with CIDR block
2. Public subnet for ALB
3. Private subnet for application
4. Security groups for each tier
5. NAT gateway for private subnet internet access

---

## Hands-On Exercises (2 exercises)

### Exercise 1: Implement Secrets Management
1. Create secret in AWS Secrets Manager
2. Write Terraform to reference secret
3. Mark variables as sensitive
4. Apply configuration
5. Verify secret is not exposed

### Exercise 2: Secure VPC Architecture
1. Create VPC with public/private subnets
2. Configure security groups
3. Implement least privilege access
4. Add compliance tagging
5. Verify network isolation

---

## Answer Key Summary

**Multiple Choice**: Questions 1-12  
- Q1: B, Q2: C, Q3: D, Q4: B, Q5: D  
- Q6: D, Q7: B, Q8: B, Q9: A, Q10: A  
- Q11: A, Q12: B  

**Scenario Questions**: 1-3  
- See detailed answers above  

**Hands-On Exercises**: 1-2  
- Complete exercises and document results  

---

## Scoring Guide

- **14-15 correct**: Excellent - Ready for certification exam
- **12-13 correct**: Good - Review weak areas
- **11 correct**: Passing - Study additional resources
- **Below 11**: Review Topic 12 content and retake

---

**Assessment Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Testing

