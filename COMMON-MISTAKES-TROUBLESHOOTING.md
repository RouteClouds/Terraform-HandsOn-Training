# Terraform Associate - Common Mistakes & Troubleshooting Guide

**Learn from Common Mistakes to Avoid Them on the Exam**  
**Last Updated**: October 21, 2025

---

## CONCEPTUAL MISTAKES

### Mistake 1: Confusing terraform validate with terraform plan

**Wrong**: "terraform validate checks AWS permissions"  
**Correct**: "terraform validate checks syntax and structure only"

**Why It Matters**: The exam frequently tests this distinction.

**Solution**: Remember:
- `terraform validate`: Syntax and structure
- `terraform plan`: Preview changes (still doesn't check permissions)
- `terraform apply`: Actually makes changes

---

### Mistake 2: Not Understanding Variable Precedence

**Wrong**: "Environment variables override .tfvars files"  
**Correct**: "CLI flags override .tfvars files, which override environment variables"

**Precedence Order**:
1. CLI flags (`-var`)
2. `.tfvars` files
3. Environment variables (`TF_VAR_*`)
4. Default values

---

### Mistake 3: Confusing Implicit and Explicit Dependencies

**Wrong**: "Always use depends_on"  
**Correct**: "Let Terraform infer dependencies when possible"

**When to Use**:
- **Implicit**: When resource references another (preferred)
- **Explicit**: When Terraform can't infer the dependency

---

### Mistake 4: Misunderstanding State File

**Wrong**: "State file is just a backup"  
**Correct**: "State file maps configuration to real resources"

**Critical Points**:
- Never commit to Git
- Always use remote backend in production
- Encrypt state files
- Enable state locking

---

## COMMAND MISTAKES

### Mistake 5: Wrong Terraform Workflow Order

**Wrong**: `terraform plan → terraform init → terraform validate`  
**Correct**: `terraform init → terraform validate → terraform plan → terraform apply`

**Remember**: IVPA (Init, Validate, Plan, Apply)

---

### Mistake 6: Forgetting terraform init

**Symptom**: "Provider not found" error  
**Solution**: Always run `terraform init` first

**Why**: Initializes working directory and downloads providers

---

### Mistake 7: Not Reviewing terraform plan

**Wrong**: Running `terraform apply` without reviewing plan  
**Correct**: Always review `terraform plan` output first

**Best Practice**: Use `terraform plan -out=tfplan` to save plan

---

### Mistake 8: Using Wrong Flags

**Common Mistakes**:
- `terraform plan -destroy` (wrong, use `terraform destroy`)
- `terraform apply -auto-approve` (risky, use only in CI/CD)
- `terraform destroy -auto-approve` (very risky)

---

## STATE MANAGEMENT MISTAKES

### Mistake 9: Committing State Files to Git

**Wrong**: Committing `terraform.tfstate` to Git  
**Correct**: Add to `.gitignore`

**Why**: State files contain sensitive data

```
# .gitignore
*.tfstate
*.tfstate.*
```

---

### Mistake 10: Not Using Remote Backend

**Wrong**: Using local state in team environment  
**Correct**: Use remote backend (S3, Terraform Cloud, etc.)

**Benefits**:
- Team collaboration
- State locking
- Backup and recovery
- Audit logging

---

### Mistake 11: Not Enabling State Locking

**Wrong**: Using S3 backend without DynamoDB locking  
**Correct**: Enable state locking with DynamoDB

**Why**: Prevents concurrent modifications and state corruption

---

### Mistake 12: Manipulating State Incorrectly

**Wrong**: Manually editing state files  
**Correct**: Use `terraform state` commands

**Safe Commands**:
- `terraform state list`
- `terraform state show`
- `terraform state rm` (removes from state, doesn't destroy)
- `terraform state mv` (moves resource)

---

## RESOURCE MANAGEMENT MISTAKES

### Mistake 13: Hardcoding Values

**Wrong**:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

**Correct**:
```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

---

### Mistake 14: Not Using Resource References

**Wrong**: Hardcoding resource IDs  
**Correct**: Use resource references

```hcl
# Wrong
subnet_id = "subnet-12345"

# Correct
subnet_id = aws_subnet.private.id
```

---

### Mistake 15: Incorrect Resource Addressing

**Wrong**: `aws_instance.web` (when using count)  
**Correct**: `aws_instance.web[0]` or `aws_instance.web["key"]`

---

## MODULE MISTAKES

### Mistake 16: Wrong Module Structure

**Wrong**: All files in root directory  
**Correct**: Separate directories with main.tf, variables.tf, outputs.tf

```
module/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

### Mistake 17: Not Versioning Modules

**Wrong**: `source = "terraform-aws-modules/vpc/aws"`  
**Correct**: `source = "terraform-aws-modules/vpc/aws" version = "~> 3.0"`

---

### Mistake 18: Incorrect Module References

**Wrong**: `aws_instance.web.id` (inside module)  
**Correct**: `module.vpc.vpc_id` (from parent)

---

## SECURITY MISTAKES

### Mistake 19: Hardcoding Credentials

**Wrong**:
```hcl
provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
```

**Correct**: Use environment variables or IAM roles

---

### Mistake 20: Not Marking Sensitive Data

**Wrong**:
```hcl
output "db_password" {
  value = aws_db_instance.main.password
}
```

**Correct**:
```hcl
output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
```

---

### Mistake 21: Not Encrypting State

**Wrong**: Unencrypted S3 backend  
**Correct**: Enable encryption

```hcl
backend "s3" {
  encrypt = true
  kms_key_id = "arn:aws:kms:..."
}
```

---

## EXAM MISTAKES

### Mistake 22: Not Reading Questions Carefully

**Solution**: Read each question twice before answering

---

### Mistake 23: Second-Guessing Answers

**Solution**: Trust your preparation and don't change answers

---

### Mistake 24: Poor Time Management

**Solution**: 1 minute per question, answer easy ones first

---

### Mistake 25: Panicking on Difficult Questions

**Solution**: Mark and move on, return if time permits

---

## TROUBLESHOOTING GUIDE

### Error: "Provider not found"
**Solution**: Run `terraform init`

### Error: "Resource already exists"
**Solution**: Use `terraform import` or `terraform state rm`

### Error: "State lock timeout"
**Solution**: Check for stuck locks, use `terraform force-unlock`

### Error: "Invalid resource type"
**Solution**: Check resource syntax and provider documentation

### Error: "Variable not defined"
**Solution**: Check variable definition and precedence

---

## QUICK FIXES

| Problem | Solution |
|---------|----------|
| Syntax error | Run `terraform validate` |
| Resource not found | Check resource addressing |
| State corruption | Restore from backup |
| Stuck lock | Use `terraform force-unlock` |
| Wrong credentials | Check AWS configuration |
| Module not found | Check module source |
| Variable not set | Check variable precedence |

---

**Guide Version**: 1.0  
**Status**: Ready for Use

