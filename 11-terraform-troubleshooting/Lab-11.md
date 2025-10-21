# Topic 11: Hands-On Labs - Terraform Troubleshooting & Debugging

**Estimated Time**: 3-4 hours  
**Difficulty**: Intermediate  
**Prerequisites**: Topics 1-10 completed

---

## Lab Overview

This lab series covers three critical troubleshooting scenarios:
1. **Lab 11.1**: Debug Common Terraform Errors
2. **Lab 11.2**: Troubleshoot State File Issues
3. **Lab 11.3**: Performance Troubleshooting

---

## Lab 11.1: Debug Common Terraform Errors

### Objective
Identify and resolve common Terraform errors using debugging techniques.

### Prerequisites
- Terraform installed
- AWS credentials configured
- Text editor

### Step 1: Enable Logging

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform.log
```

### Step 2: Create Configuration with Errors

Create `main.tf` with intentional errors:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  invalid_arg   = "value"  # Error: unsupported argument
}
```

### Step 3: Validate Configuration

```bash
terraform validate
# Error: Unsupported argument
```

### Step 4: Fix Errors

```bash
terraform fmt
# Review and fix errors
```

### Step 5: Verify Fix

```bash
terraform validate
# Success! The configuration is valid.
```

### Step 6: Review Logs

```bash
cat /tmp/terraform.log | grep -i error
```

---

## Lab 11.2: Troubleshoot State File Issues

### Objective
Diagnose and resolve state file problems.

### Prerequisites
- Terraform initialized
- AWS resources created

### Step 1: Create Resources

```bash
terraform apply
```

### Step 2: Simulate State Lock

```bash
# In another terminal
terraform apply
# Will show: Error acquiring the state lock
```

### Step 3: Force Unlock

```bash
terraform force-unlock LOCK_ID
```

### Step 4: Detect Drift

```bash
# Manually change resource in AWS
# Then run:
terraform plan
# Shows drift
```

### Step 5: Resolve Drift

```bash
# Option 1: Refresh
terraform refresh

# Option 2: Taint and replace
terraform taint aws_instance.web
terraform apply
```

---

## Lab 11.3: Performance Troubleshooting

### Objective
Optimize Terraform performance.

### Prerequisites
- Multiple resources configured
- Terraform initialized

### Step 1: Measure Baseline

```bash
time terraform plan
# Note execution time
```

### Step 2: Increase Parallelism

```bash
time terraform apply -parallelism=20
# Compare execution time
```

### Step 3: Use Targeting

```bash
# Apply only specific resource
terraform apply -target=aws_instance.web
```

### Step 4: Skip Refresh

```bash
terraform apply -refresh=false
# Faster but less accurate
```

### Step 5: Analyze Performance

```bash
# Enable logging
export TF_LOG=DEBUG
terraform plan
# Review logs for slow operations
```

---

## Lab Verification Checklist

### Lab 11.1 Verification
- [ ] Logging enabled
- [ ] Errors identified
- [ ] Errors fixed
- [ ] Configuration validates

### Lab 11.2 Verification
- [ ] State lock handled
- [ ] Drift detected
- [ ] Drift resolved
- [ ] State consistent

### Lab 11.3 Verification
- [ ] Baseline measured
- [ ] Parallelism tested
- [ ] Targeting used
- [ ] Performance improved

---

## Troubleshooting Guide

**Issue**: "Error acquiring the state lock"
- **Solution**: `terraform force-unlock LOCK_ID`

**Issue**: "Error: resource does not exist"
- **Solution**: `terraform refresh`

**Issue**: "Error: AccessDenied"
- **Solution**: Check AWS credentials and IAM permissions

**Issue**: Slow Terraform operations
- **Solution**: Increase parallelism or use targeting

---

## Key Learnings

✅ Logging enables effective debugging  
✅ Common errors have known solutions  
✅ State issues can be recovered  
✅ Performance can be optimized  
✅ Systematic troubleshooting is effective  

---

**Lab Completion Time**: 3-4 hours  
**Difficulty**: Intermediate  
**Next**: Proceed to Topic 12 - Advanced Security & Compliance

