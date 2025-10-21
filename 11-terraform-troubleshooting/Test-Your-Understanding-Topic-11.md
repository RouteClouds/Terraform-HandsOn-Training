# Topic 11: Test Your Understanding - Terraform Troubleshooting & Debugging

**Total Questions**: 15  
**Time Limit**: 30 minutes  
**Passing Score**: 70% (11/15 correct)

---

## Multiple Choice Questions (10 questions)

### Question 1
What does setting `TF_LOG=DEBUG` do?

A) Enables debug mode in AWS  
B) Enables detailed Terraform logging  
C) Disables logging  
D) Logs only errors  

**Answer**: B  
**Explanation**: TF_LOG=DEBUG enables detailed Terraform logging for debugging.

---

### Question 2
What is the purpose of `terraform validate`?

A) Validates AWS permissions  
B) Checks configuration syntax  
C) Validates resource creation  
D) Validates state file  

**Answer**: B  
**Explanation**: `terraform validate` checks configuration syntax and structure.

---

### Question 3
How do you resolve "Error acquiring the state lock"?

A) Delete state file  
B) Use `terraform force-unlock`  
C) Restart Terraform  
D) Clear cache  

**Answer**: B  
**Explanation**: `terraform force-unlock` releases a stuck state lock.

---

### Question 4
What does `terraform refresh` do?

A) Refreshes AWS credentials  
B) Syncs state with actual resources  
C) Clears cache  
D) Resets configuration  

**Answer**: B  
**Explanation**: `terraform refresh` updates state to match actual AWS resources.

---

### Question 5
How do you detect resource drift?

A) Run `terraform plan`  
B) Run `terraform validate`  
C) Check AWS console  
D) Review logs  

**Answer**: A  
**Explanation**: `terraform plan` shows resources that differ from state.

---

### Question 6
What does `terraform taint` do?

A) Marks resource for replacement  
B) Deletes resource  
C) Locks resource  
D) Validates resource  

**Answer**: A  
**Explanation**: `terraform taint` marks a resource for replacement on next apply.

---

### Question 7
How do you increase Terraform performance?

A) Use `-parallelism` flag  
B) Delete resources  
C) Clear state  
D) Restart Terraform  

**Answer**: A  
**Explanation**: `-parallelism` flag increases concurrent operations.

---

### Question 8
What causes "Error: resource does not exist"?

A) Resource not in configuration  
B) Resource deleted outside Terraform  
C) State file corrupted  
D) AWS permissions issue  

**Answer**: B  
**Explanation**: This error occurs when a resource is deleted outside Terraform.

---

### Question 9
How do you save Terraform logs to a file?

A) Use `TF_LOG_PATH` environment variable  
B) Use `--log-file` flag  
C) Redirect stdout  
D) Use `terraform log`  

**Answer**: A  
**Explanation**: `TF_LOG_PATH` environment variable specifies log file location.

---

### Question 10
What is the default parallelism value?

A) 1  
B) 5  
C) 10  
D) Unlimited  

**Answer**: C  
**Explanation**: Default parallelism is 10 concurrent operations.

---

## Scenario-Based Questions (3 questions)

### Scenario 1
You get "Error: AccessDenied" when running terraform apply. What should you check?

**Answer**:
1. AWS credentials are configured correctly
2. IAM user/role has required permissions
3. Check AWS credentials with `aws sts get-caller-identity`
4. Add missing IAM permissions
5. Retry terraform apply

---

### Scenario 2
Your terraform plan shows resources that don't match actual AWS state. How would you resolve this?

**Answer**:
1. Run `terraform refresh` to sync state
2. Or use `terraform taint` to mark for replacement
3. Run `terraform apply` to fix drift
4. Verify with `terraform plan` (should show no changes)

---

### Scenario 3
Terraform operations are very slow. How would you optimize?

**Answer**:
1. Increase parallelism: `terraform apply -parallelism=20`
2. Use targeting: `terraform apply -target=aws_instance.web`
3. Skip refresh: `terraform apply -refresh=false`
4. Enable logging to identify slow operations
5. Consider splitting into multiple workspaces

---

## Hands-On Exercises (2 exercises)

### Exercise 1: Debug Configuration Errors
1. Create Terraform configuration with intentional errors
2. Enable TF_LOG=DEBUG
3. Run terraform validate
4. Identify and fix errors
5. Verify configuration is valid

### Exercise 2: Resolve State Issues
1. Create resources with terraform apply
2. Manually modify resource in AWS
3. Run terraform plan to detect drift
4. Use terraform refresh to resolve
5. Verify state is consistent

---

## Answer Key Summary

**Multiple Choice**: Questions 1-10  
- Q1: B, Q2: B, Q3: B, Q4: B, Q5: A  
- Q6: A, Q7: A, Q8: B, Q9: A, Q10: C  

**Scenario Questions**: 1-3  
- See detailed answers above  

**Hands-On Exercises**: 1-2  
- Complete exercises and document results  

---

## Scoring Guide

- **14-15 correct**: Excellent - Ready for certification exam
- **12-13 correct**: Good - Review weak areas
- **11 correct**: Passing - Study additional resources
- **Below 11**: Review Topic 11 content and retake

---

**Assessment Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Testing

