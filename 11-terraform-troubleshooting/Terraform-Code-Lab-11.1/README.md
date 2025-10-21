# Topic 11 Lab: Terraform Troubleshooting & Debugging - Code Examples

This directory contains working Terraform code examples for Topic 11 labs.

## Files

- **providers.tf** - AWS provider configuration
- **variables.tf** - Input variables
- **main.tf** - Infrastructure with troubleshooting scenarios
- **outputs.tf** - Output values
- **README.md** - This file

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS account with EC2 permissions
- Text editor

## Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Validate Configuration

```bash
terraform validate
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Apply Configuration

```bash
terraform apply
```

## Debugging Commands

### Enable Logging

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform.log
```

### View Logs

```bash
cat /tmp/terraform.log
grep -i error /tmp/terraform.log
```

### Validate Configuration

```bash
terraform validate
terraform fmt -check
```

### Detect Drift

```bash
terraform plan
# Shows resources that differ from state
```

### Refresh State

```bash
terraform refresh
```

### Taint Resource

```bash
terraform taint aws_instance.troubleshooting[0]
terraform apply
```

### Force Unlock

```bash
terraform force-unlock LOCK_ID
```

## Performance Optimization

### Increase Parallelism

```bash
terraform apply -parallelism=20
```

### Use Targeting

```bash
terraform apply -target=aws_instance.troubleshooting[0]
```

### Skip Refresh

```bash
terraform apply -refresh=false
```

## Variables

Customize behavior by creating `terraform.tfvars`:

```hcl
aws_region                    = "us-east-1"
environment                   = "lab"
instance_type                 = "t2.micro"
instance_count                = 2
enable_detailed_monitoring    = true
```

## Outputs

After applying, view outputs:

```bash
terraform output
terraform output instance_ids
terraform output troubleshooting_info
```

## Troubleshooting Scenarios

### Scenario 1: Syntax Error
Uncomment the error_example resource in main.tf to test error handling.

### Scenario 2: Resource Drift
Manually modify an instance in AWS, then run `terraform plan` to detect drift.

### Scenario 3: State Lock
Run terraform apply in two terminals simultaneously to test state locking.

### Scenario 4: Performance
Create multiple instances and test parallelism optimization.

## Cleanup

Destroy resources when done:

```bash
terraform destroy
```

## Lab Exercises

### Exercise 1: Debug Configuration
1. Enable TF_LOG=DEBUG
2. Run terraform validate
3. Identify any errors
4. Fix errors
5. Verify configuration

### Exercise 2: Detect and Resolve Drift
1. Create resources with terraform apply
2. Manually modify resource in AWS
3. Run terraform plan to detect drift
4. Use terraform refresh to resolve
5. Verify state is consistent

### Exercise 3: Performance Optimization
1. Measure baseline: `time terraform plan`
2. Increase parallelism: `terraform apply -parallelism=20`
3. Use targeting: `terraform apply -target=aws_instance.troubleshooting[0]`
4. Compare performance

## Best Practices

✅ Always enable logging when debugging  
✅ Use terraform validate early  
✅ Check AWS credentials first  
✅ Use terraform refresh to sync state  
✅ Use terraform taint to replace resources  
✅ Optimize parallelism for performance  
✅ Document troubleshooting steps  

## Additional Resources

- [Terraform Debugging](https://www.terraform.io/docs/internals/debugging.html)
- [Terraform Logging](https://www.terraform.io/docs/internals/logging.html)
- [Common Errors](https://www.terraform.io/docs/language/errors/)
- [AWS Provider Troubleshooting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#troubleshooting)

---

**Lab Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Ready for Use

