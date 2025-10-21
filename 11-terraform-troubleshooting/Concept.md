# Topic 11: Terraform Troubleshooting & Debugging

**Certification Alignment**: Exam Objectives 4.2, 4.3, 6.1, 6.5  
**Terraform Version**: 1.0+  
**AWS Provider**: 6.0+

---

## Learning Objectives

By the end of this topic, you will be able to:
- ✅ Enable and use Terraform logging for debugging
- ✅ Identify and resolve common Terraform errors
- ✅ Debug provider and API issues
- ✅ Troubleshoot state file problems
- ✅ Detect and resolve resource drift
- ✅ Optimize Terraform performance
- ✅ Handle authentication and authorization issues
- ✅ Recover from Terraform failures

---

## 1. Terraform Logging

### 1.1 Enable Logging

```bash
# Set log level
export TF_LOG=DEBUG

# Log levels: TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG=TRACE

# Save logs to file
export TF_LOG_PATH=/tmp/terraform.log
```

### 1.2 Log Levels

| Level | Purpose |
|-------|---------|
| TRACE | Most verbose, all operations |
| DEBUG | Detailed debugging information |
| INFO | General information |
| WARN | Warning messages |
| ERROR | Error messages only |

### 1.3 Analyzing Logs

```bash
# View logs
cat /tmp/terraform.log

# Search for errors
grep -i error /tmp/terraform.log

# Search for specific resource
grep aws_instance /tmp/terraform.log
```

---

## 2. Common Terraform Errors

### 2.1 Syntax Errors

**Error**: `Error: Unsupported argument`

**Cause**: Invalid argument name or typo

**Solution**:
```bash
terraform validate
terraform fmt
```

### 2.2 Resource Conflicts

**Error**: `Error: resource already exists`

**Cause**: Resource already exists in AWS

**Solution**:
```bash
terraform import aws_instance.web i-1234567890abcdef0
```

### 2.3 Dependency Cycles

**Error**: `Error: Cycle detected`

**Cause**: Circular dependencies between resources

**Solution**: Use `depends_on` explicitly or restructure code

### 2.4 Missing Variables

**Error**: `Error: Missing required argument`

**Cause**: Required variable not provided

**Solution**: Provide variable via `-var` or `terraform.tfvars`

---

## 3. Provider Debugging

### 3.1 Provider Errors

**Error**: `Error: error configuring Terraform AWS Provider`

**Cause**: AWS credentials not configured

**Solution**:
```bash
aws configure
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

### 3.2 API Errors

**Error**: `Error: AccessDenied`

**Cause**: IAM permissions insufficient

**Solution**: Check IAM policy and add required permissions

### 3.3 Rate Limiting

**Error**: `Error: RequestLimitExceeded`

**Cause**: Too many API requests

**Solution**: Use parallelism flag
```bash
terraform apply -parallelism=2
```

---

## 4. State File Troubleshooting

### 4.1 State Lock Issues

**Error**: `Error: Error acquiring the state lock`

**Cause**: State is locked by another operation

**Solution**:
```bash
terraform force-unlock LOCK_ID
```

### 4.2 State Corruption

**Error**: `Error: Failed to read state`

**Cause**: State file corrupted

**Solution**:
```bash
cp terraform.tfstate.backup terraform.tfstate
terraform refresh
```

### 4.3 State Mismatch

**Error**: `Error: resource does not exist`

**Cause**: Resource deleted outside Terraform

**Solution**:
```bash
terraform refresh
terraform state rm aws_instance.web
```

---

## 5. Resource Drift

### 5.1 Detecting Drift

```bash
terraform plan
# Shows resources that differ from state
```

### 5.2 Resolving Drift

**Option 1**: Update Terraform code
```hcl
resource "aws_instance" "web" {
  # Update to match actual state
}
```

**Option 2**: Refresh state
```bash
terraform refresh
```

**Option 3**: Replace resource
```bash
terraform taint aws_instance.web
terraform apply
```

---

## 6. Performance Optimization

### 6.1 Parallelism

```bash
# Increase parallelism
terraform apply -parallelism=10

# Default is 10
```

### 6.2 Targeting

```bash
# Apply only specific resource
terraform apply -target=aws_instance.web
```

### 6.3 Refresh Optimization

```bash
# Skip refresh
terraform apply -refresh=false
```

---

## 7. Certification Exam Focus

### 🎓 Exam Objectives Covered

**Objective 4.2**: Debugging Terraform issues
- Know logging techniques
- Understand common errors
- Know troubleshooting steps

**Objective 4.3**: Error handling
- Know error types
- Understand error messages
- Know recovery procedures

**Objective 6.1**: Workflow troubleshooting
- Know workflow issues
- Understand resolution steps

**Objective 6.5**: Problem resolution
- Know problem-solving approach
- Understand debugging techniques

### 💡 Exam Tips

- **Tip 1**: Enable TF_LOG for debugging
- **Tip 2**: Check AWS credentials first
- **Tip 3**: Use terraform validate early
- **Tip 4**: State lock issues use force-unlock
- **Tip 5**: Resource drift use refresh or taint

---

## 8. Key Takeaways

✅ **TF_LOG** enables detailed debugging  
✅ **terraform validate** catches syntax errors  
✅ **Common errors** have known solutions  
✅ **State issues** can be recovered  
✅ **Resource drift** can be detected and fixed  
✅ **Performance** can be optimized  

---

## Next Steps

1. Complete **Lab 11.1**: Debug Common Errors
2. Complete **Lab 11.2**: Troubleshoot State Issues
3. Complete **Lab 11.3**: Performance Optimization
4. Review **Test-Your-Understanding-Topic-11.md**
5. Proceed to **Topic 12**: Advanced Security & Compliance

---

**Document Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Labs

