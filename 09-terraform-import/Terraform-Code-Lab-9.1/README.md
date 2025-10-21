# Topic 9 Lab: Terraform Import & State Manipulation - Code Examples

This directory contains working Terraform code examples for Topic 9 labs.

## Files

- **providers.tf** - AWS provider configuration with version constraints
- **variables.tf** - Input variables for customization
- **main.tf** - EC2 instance and security group resources
- **outputs.tf** - Output values for verification
- **terraform.tfvars** - Variable values (create as needed)

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS account with EC2 permissions
- Basic understanding of Terraform workflow

## Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review Configuration

```bash
terraform plan
```

### 3. Create Resources

```bash
terraform apply
```

### 4. Import Existing Resource

If you have an existing EC2 instance to import:

```bash
# Get instance ID
aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text

# Import the instance
terraform import aws_instance.lab i-1234567890abcdef0
```

### 5. Verify State

```bash
# List all resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.lab

# Verify no changes needed
terraform plan
```

## Common Commands

### State Manipulation

```bash
# List resources
terraform state list

# Show resource details
terraform state show aws_instance.lab

# Remove resource from state (without destroying)
terraform state rm aws_instance.lab

# Move/rename resource
terraform state mv aws_instance.lab aws_instance.imported

# Replace provider
terraform state replace-provider 'registry.terraform.io/-/aws' 'registry.terraform.io/hashicorp/aws'
```

### Resource Targeting

```bash
# Plan only specific resource
terraform plan -target=aws_instance.lab

# Apply only specific resource
terraform apply -target=aws_instance.lab

# Destroy only specific resource
terraform destroy -target=aws_instance.lab
```

### Backup and Recovery

```bash
# Backup state
cp terraform.tfstate terraform.tfstate.backup

# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Refresh state from AWS
terraform refresh
```

## Variables

Customize behavior by creating `terraform.tfvars`:

```hcl
aws_region      = "us-east-1"
environment     = "lab"
instance_type   = "t2.micro"
instance_name   = "my-instance"
enable_monitoring = false
```

## Outputs

After applying, view outputs:

```bash
terraform output
terraform output instance_id
terraform output import_command
```

## Cleanup

Destroy resources when done:

```bash
terraform destroy
```

## Troubleshooting

**Error: "Resource already exists in state"**
```bash
terraform state rm aws_instance.lab
```

**Error: "Resource not found"**
- Verify instance ID with AWS CLI
- Check AWS region matches

**State file corrupted**
```bash
cp terraform.tfstate.backup terraform.tfstate
terraform refresh
```

## Lab Exercises

### Exercise 1: Import and Verify
1. Create EC2 instance manually in AWS
2. Update `main.tf` with matching configuration
3. Run `terraform import aws_instance.lab <instance-id>`
4. Verify with `terraform plan` (should show no changes)

### Exercise 2: State Manipulation
1. Rename resource: `terraform state mv aws_instance.lab aws_instance.imported`
2. Update `main.tf` to use new name
3. Verify: `terraform plan` (should show no changes)

### Exercise 3: Resource Targeting
1. Create multiple resources
2. Use `-target` flag: `terraform plan -target=aws_instance.lab`
3. Apply only specific resource: `terraform apply -target=aws_security_group.lab`

## Best Practices

✅ Always backup state before manipulation  
✅ Use `terraform plan` to verify changes  
✅ Test in non-production first  
✅ Use remote state for team environments  
✅ Enable state locking for collaboration  
✅ Document import procedures  
✅ Version control your Terraform code  

## Additional Resources

- [Terraform Import Documentation](https://www.terraform.io/docs/commands/import.html)
- [Terraform State Management](https://www.terraform.io/docs/state/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**Lab Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Ready for Use

