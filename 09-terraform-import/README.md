# Topic 9: Terraform Import & State Manipulation

**Certification Alignment**: Terraform Associate 003/004  
**Exam Objectives**: 4.1, 4.4, 4.5  
**Difficulty**: Intermediate  
**Estimated Time**: 4-5 hours

---

## Overview

Topic 9 covers advanced Terraform state management, focusing on importing existing infrastructure and manipulating state files. This is critical for real-world scenarios where you need to bring existing resources under Terraform management.

## Learning Objectives

By completing this topic, you will be able to:

✅ Import existing AWS resources into Terraform state  
✅ Understand Terraform state file structure and organization  
✅ Use resource targeting for selective operations  
✅ Manipulate state using terraform state commands  
✅ Migrate resources between state files  
✅ Recover from state file corruption  
✅ Apply import patterns for different resource types  
✅ Troubleshoot common import issues  

## Directory Structure

```
09-terraform-import/
├── Concept.md                          # Comprehensive theory (800+ lines)
├── Lab-9.md                            # Hands-on labs (600+ lines)
├── Test-Your-Understanding-Topic-9.md  # Assessment (400+ lines)
├── README.md                           # This file
├── Terraform-Code-Lab-9.1/             # Working code examples
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── README.md
└── DaC/                                # Diagram as Code
    ├── requirements.txt
    ├── import_workflow_diagram.py
    ├── state_file_structure_diagram.py
    ├── migration_patterns_diagram.py
    ├── generate_all_diagrams.py
    └── README.md
```

## Content Files

### 1. **Concept.md** (800+ lines)
Comprehensive theory covering:
- Introduction to Terraform import
- Import command syntax and options
- State file structure and organization
- Resource targeting techniques
- State manipulation commands (rm, mv, replace-provider)
- Import patterns and best practices
- Troubleshooting import issues
- Certification exam focus areas

### 2. **Lab-9.md** (600+ lines)
Three hands-on labs:
- **Lab 9.1**: Import existing EC2 instance
- **Lab 9.2**: Migrate resources between state files
- **Lab 9.3**: Recover from state file corruption

### 3. **Test-Your-Understanding-Topic-9.md** (400+ lines)
Assessment with:
- 10 multiple-choice questions
- 3 scenario-based questions
- 2 hands-on exercises
- Answer key with explanations

### 4. **Terraform-Code-Lab-9.1/**
Working code examples:
- Complete Terraform configuration
- EC2 instance and security group resources
- Import examples and state manipulation
- Ready to use for labs

### 5. **DaC/** (Diagram as Code)
Professional diagrams generated with Python:
- Import workflow diagram
- State file structure diagram
- Migration patterns diagram
- Reproducible and version-controlled

## Certification Alignment

### Exam Objectives Covered

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

## Getting Started

### Step 1: Review Concept Material
Start with **Concept.md** to understand:
- Terraform import fundamentals
- State file structure
- State manipulation commands
- Best practices and patterns

### Step 2: Generate Diagrams
```bash
cd DaC
pip install -r requirements.txt
python generate_all_diagrams.py
```

### Step 3: Complete Labs
Follow **Lab-9.md** to:
- Import an EC2 instance
- Migrate resources between state files
- Recover from state corruption

### Step 4: Test Your Knowledge
Complete **Test-Your-Understanding-Topic-9.md**:
- Answer 10 multiple-choice questions
- Solve 3 scenario-based problems
- Complete 2 hands-on exercises

### Step 5: Practice with Code
Use **Terraform-Code-Lab-9.1/** to:
- Apply working Terraform configuration
- Practice import commands
- Experiment with state manipulation

## Key Concepts

### Terraform Import
```bash
terraform import aws_instance.web i-1234567890abcdef0
```
Brings existing AWS resources into Terraform state.

### State Manipulation
```bash
terraform state list              # List resources
terraform state show aws_instance.web  # Show details
terraform state rm aws_instance.web    # Remove from state
terraform state mv old_name new_name   # Rename resource
```

### Resource Targeting
```bash
terraform plan -target=aws_instance.web
terraform apply -target=aws_instance.web
```

### Backup and Recovery
```bash
cp terraform.tfstate terraform.tfstate.backup
cp terraform.tfstate.backup terraform.tfstate
terraform refresh
```

## Exam Tips

💡 **Tip 1**: Import requires matching resource configuration  
💡 **Tip 2**: Always backup state before manipulation  
💡 **Tip 3**: Use `terraform plan` to verify after import  
💡 **Tip 4**: Resource targeting is useful for large deployments  
💡 **Tip 5**: State commands are powerful but use carefully  

## Common Scenarios

### Scenario 1: Migrate Existing Infrastructure
1. Write Terraform configuration
2. Import resources with `terraform import`
3. Verify with `terraform plan`
4. Commit to version control

### Scenario 2: Consolidate Multiple State Files
1. Use `terraform state mv` to move resources
2. Switch between workspaces
3. Verify resources in new location
4. Clean up old state

### Scenario 3: Disaster Recovery
1. Restore from backup: `cp .backup terraform.tfstate`
2. Refresh state: `terraform refresh`
3. Verify with `terraform plan`
4. Commit recovery

## Best Practices

✅ Always backup state before manipulation  
✅ Use remote state for team environments  
✅ Enable state locking for collaboration  
✅ Test import procedures in non-production first  
✅ Document import procedures  
✅ Version control your Terraform code  
✅ Use `terraform plan` to verify changes  
✅ Implement disaster recovery procedures  

## Troubleshooting

**Q: "Resource already exists in state"**  
A: Use `terraform state rm` to remove it first

**Q: "Resource not found in AWS"**  
A: Verify resource ID with AWS CLI

**Q: "State file corrupted"**  
A: Restore from `.backup` file and refresh

## Next Steps

After completing Topic 9:
1. Review certification exam objectives 4.1, 4.4, 4.5
2. Practice import scenarios with real resources
3. Proceed to **Topic 10**: Terraform Testing & Validation
4. Continue with remaining topics for full certification prep

## Resources

- [Terraform Import Documentation](https://www.terraform.io/docs/commands/import.html)
- [Terraform State Management](https://www.terraform.io/docs/state/)
- [AWS Resource IDs](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)

## Support

For questions or issues:
1. Review Concept.md for detailed explanations
2. Check Lab-9.md for step-by-step guidance
3. Consult Test-Your-Understanding-Topic-9.md for examples
4. Review Terraform official documentation

---

**Topic Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Learning

**Estimated Completion Time**: 4-5 hours  
**Difficulty Level**: Intermediate  
**Prerequisites**: Topics 1-8 completed

