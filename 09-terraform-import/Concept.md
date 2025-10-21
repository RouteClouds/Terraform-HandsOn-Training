# Topic 9: Terraform Import & State Manipulation

**Certification Alignment**: Exam Objectives 4.1, 4.4, 4.5  
**Terraform Version**: 1.0+  
**AWS Provider**: 6.0+

---

## Learning Objectives

By the end of this topic, you will be able to:
- ✅ Import existing AWS resources into Terraform state
- ✅ Understand Terraform state file structure and organization
- ✅ Use resource targeting to manage specific resources
- ✅ Manipulate state using terraform state commands
- ✅ Migrate resources between state files
- ✅ Recover from state file corruption
- ✅ Apply import patterns for different resource types
- ✅ Troubleshoot common import issues

---

## 1. Introduction to Terraform Import

### 1.1 What is Terraform Import?

**Terraform import** is a command that allows you to bring existing infrastructure resources into Terraform management. This is essential when:
- Migrating existing infrastructure to Terraform
- Adopting Terraform for previously manually-managed resources
- Recovering from infrastructure disasters
- Consolidating infrastructure management

### 1.2 Why Import Resources?

**Benefits of importing resources**:
- ✅ Manage existing infrastructure with Terraform
- ✅ Avoid recreating resources
- ✅ Maintain infrastructure continuity
- ✅ Centralize infrastructure management
- ✅ Enable infrastructure as code practices

### 1.3 Import Workflow

```
Existing Infrastructure → terraform import → Terraform State → Terraform Code
```

---

## 2. Terraform Import Command

### 2.1 Basic Syntax

```bash
terraform import [options] ADDRESS ID
```

**Parameters**:
- `ADDRESS`: Resource address in Terraform configuration (e.g., `aws_instance.example`)
- `ID`: Resource identifier in AWS (e.g., `i-1234567890abcdef0`)

### 2.2 Common Import Examples

**EC2 Instance**:
```bash
terraform import aws_instance.web i-1234567890abcdef0
```

**Security Group**:
```bash
terraform import aws_security_group.main sg-12345678
```

**VPC**:
```bash
terraform import aws_vpc.main vpc-12345678
```

**RDS Database**:
```bash
terraform import aws_db_instance.main mydb
```

### 2.3 Import Options

**Useful flags**:
- `-config=PATH`: Path to Terraform configuration directory
- `-lock=false`: Don't lock state during import
- `-input=false`: Disable input prompts
- `-var 'key=value'`: Set Terraform variables

---

## 3. State File Structure

### 3.1 State File Format

Terraform state is stored in JSON format with:
- **version**: State file format version
- **terraform_version**: Terraform version used
- **serial**: Incremental counter for state changes
- **lineage**: Unique identifier for state lineage
- **resources**: Array of managed resources

### 3.2 Resource State Entry

Each resource in state contains:
- **type**: Resource type (e.g., `aws_instance`)
- **name**: Resource name in configuration
- **instances**: Array of resource instances
- **attributes**: Resource properties and values

### 3.3 State File Location

```
.terraform/
├── terraform.tfstate          # Current state
├── terraform.tfstate.backup   # Previous state backup
└── terraform.tfstate.d/       # State for workspaces
```

---

## 4. Resource Targeting

### 4.1 Target Flag Usage

**Target specific resources during operations**:

```bash
# Plan only specific resource
terraform plan -target=aws_instance.web

# Apply only specific resource
terraform apply -target=aws_instance.web

# Destroy only specific resource
terraform destroy -target=aws_instance.web
```

### 4.2 Multiple Targets

```bash
terraform apply \
  -target=aws_instance.web \
  -target=aws_security_group.main
```

### 4.3 Targeting Nested Resources

```bash
# Target module resource
terraform apply -target=module.vpc.aws_vpc.main

# Target resource in module
terraform apply -target=module.vpc.aws_subnet.private[0]
```

---

## 5. State Manipulation Commands

### 5.1 terraform state list

**List all resources in state**:

```bash
terraform state list
# Output:
# aws_instance.web
# aws_security_group.main
# aws_vpc.main
```

### 5.2 terraform state show

**Display resource details**:

```bash
terraform state show aws_instance.web
# Shows all attributes of the resource
```

### 5.3 terraform state rm

**Remove resource from state** (without destroying):

```bash
terraform state rm aws_instance.web
# Resource remains in AWS but is no longer managed by Terraform
```

### 5.4 terraform state mv

**Move resource in state**:

```bash
# Rename resource
terraform state mv aws_instance.web aws_instance.app

# Move between modules
terraform state mv aws_instance.web module.app.aws_instance.web
```

### 5.5 terraform state replace-provider

**Change resource provider**:

```bash
terraform state replace-provider \
  'registry.terraform.io/-/aws' \
  'registry.terraform.io/hashicorp/aws'
```

---

## 6. Import Patterns & Best Practices

### 6.1 Pre-Import Checklist

Before importing resources:
- ✅ Write Terraform configuration for resources
- ✅ Ensure resource addresses match configuration
- ✅ Verify AWS credentials and permissions
- ✅ Backup current state file
- ✅ Test in non-production environment first

### 6.2 Import Workflow Steps

1. **Write Configuration**: Create `.tf` files with resource definitions
2. **Initialize Terraform**: Run `terraform init`
3. **Import Resources**: Use `terraform import` for each resource
4. **Verify State**: Run `terraform state list` and `terraform state show`
5. **Plan Changes**: Run `terraform plan` to verify no changes
6. **Commit**: Add configuration to version control

### 6.3 Common Import Scenarios

**Scenario 1: Migrate Single Resource**
```bash
# 1. Write configuration
# 2. Import resource
terraform import aws_instance.web i-1234567890abcdef0
# 3. Verify
terraform plan
```

**Scenario 2: Migrate Multiple Resources**
```bash
# Create script to import multiple resources
for resource_id in i-111 i-222 i-333; do
  terraform import aws_instance.web $resource_id
done
```

**Scenario 3: Migrate with Dependencies**
```bash
# Import in dependency order
terraform import aws_vpc.main vpc-12345678
terraform import aws_subnet.main subnet-12345678
terraform import aws_instance.web i-1234567890abcdef0
```

---

## 7. Troubleshooting Import Issues

### 7.1 Common Errors

**Error: "Resource already exists in state"**
- Solution: Remove existing resource from state first
- Command: `terraform state rm aws_instance.web`

**Error: "Resource not found"**
- Solution: Verify resource ID is correct
- Check: AWS console for correct resource identifier

**Error: "Invalid resource address"**
- Solution: Ensure resource address matches configuration
- Format: `resource_type.resource_name`

### 7.2 Import Verification

**Verify import success**:

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Plan to verify no changes
terraform plan
```

### 7.3 Rollback Import

**If import fails or is incorrect**:

```bash
# Remove from state
terraform state rm aws_instance.web

# Fix configuration
# Re-import
terraform import aws_instance.web i-1234567890abcdef0
```

---

## 8. State File Corruption Recovery

### 8.1 Backup Strategy

**Always maintain backups**:
- Terraform automatically creates `.backup` files
- Store backups in version control
- Use remote state for redundancy

### 8.2 Recovery Procedures

**Restore from backup**:

```bash
# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Verify state
terraform state list

# Re-plan
terraform plan
```

### 8.3 Disaster Recovery

**If state is lost**:

```bash
# Refresh state from AWS
terraform refresh

# Or re-import all resources
terraform import aws_instance.web i-1234567890abcdef0
```

---

## 9. Certification Exam Focus

### 🎓 Exam Objectives Covered

**Objective 4.1**: Import resources into Terraform state
- Know `terraform import` command syntax
- Understand resource address format
- Be able to import common AWS resources

**Objective 4.4**: Manage state with terraform state commands
- Know `terraform state` subcommands
- Understand `state rm`, `state mv`, `state show`
- Be able to manipulate state safely

**Objective 4.5**: Understand when to use terraform taint/untaint
- Know difference between `taint` and `untaint`
- Understand resource replacement scenarios
- Know when to use state manipulation vs. taint

### 💡 Exam Tips

- **Tip 1**: Import requires matching resource configuration
- **Tip 2**: Always backup state before manipulation
- **Tip 3**: Use `terraform plan` to verify after import
- **Tip 4**: Resource targeting is useful for large deployments
- **Tip 5**: State commands are powerful but use carefully

---

## 10. Key Takeaways

✅ **terraform import** brings existing resources into Terraform management  
✅ **State file** contains all resource information and must be protected  
✅ **Resource targeting** allows selective operations on specific resources  
✅ **State commands** enable advanced state manipulation and recovery  
✅ **Import patterns** vary by resource type and use case  
✅ **Backup strategy** is essential for disaster recovery  

---

## Next Steps

1. Complete **Lab 9.1**: Import existing EC2 instance
2. Complete **Lab 9.2**: Migrate resources between state files
3. Complete **Lab 9.3**: Recover from state file corruption
4. Review **Test-Your-Understanding-Topic-9.md** for assessment questions
5. Proceed to **Topic 10**: Terraform Testing & Validation

---

**Document Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Labs and Assessment

