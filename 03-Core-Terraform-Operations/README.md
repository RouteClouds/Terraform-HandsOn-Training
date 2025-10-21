# Topic 3: Core Terraform Operations

**Certification Alignment**: Terraform Associate 003/004  
**Exam Objectives**: 3.1, 3.2, 3.3, 6.1, 6.2  
**Difficulty**: Intermediate  
**Estimated Time**: 5-6 hours

---

## Overview

Topic 3 covers the core Terraform operations including validation, planning, applying, and destroying infrastructure.

## Learning Objectives

By completing this topic, you will be able to:

✅ Validate Terraform configuration syntax  
✅ Generate and review execution plans  
✅ Apply infrastructure changes  
✅ Destroy infrastructure  
✅ Understand the Terraform workflow  
✅ Manage infrastructure lifecycle  

## Certification Alignment

### Exam Objectives Covered

**Objective 3.1**: Validate Terraform configuration
- Know `terraform validate` command
- Understand syntax checking
- Know validation limitations

**Objective 3.2**: Initialize working directory
- Know `terraform init` command
- Understand backend initialization
- Know provider installation

**Objective 3.3**: Generate and review execution plan
- Know `terraform plan` command
- Understand plan output
- Know how to save plans

**Objective 6.1**: Describe Terraform workflow
- Know the complete workflow
- Understand each step's purpose

**Objective 6.2**: Initialize and configure Terraform
- Know initialization process
- Understand configuration

### Domain Coverage

- **Domain 3**: Terraform Basics - 100%
- **Domain 6**: Terraform Workflow - 95%

## Key Concepts

### Terraform Lifecycle
1. **Write**: Create configuration files
2. **Init**: Initialize working directory
3. **Validate**: Check syntax
4. **Plan**: Preview changes
5. **Apply**: Make changes
6. **Destroy**: Remove infrastructure

### Key Commands
- `terraform init`: Initialize
- `terraform validate`: Validate syntax
- `terraform plan`: Preview changes
- `terraform apply`: Apply changes
- `terraform destroy`: Remove infrastructure

## Exam Tips

💡 **Tip 1**: `terraform validate` checks syntax, NOT AWS permissions.

💡 **Tip 2**: Always review `terraform plan` output before applying.

💡 **Tip 3**: Use `terraform plan -out=tfplan` to save plans for later review.

💡 **Tip 4**: `terraform destroy` removes all managed resources.

💡 **Tip 5**: Know the difference between `terraform plan` and `terraform apply`.

## Getting Started

### Step 1: Review Concept Material
Start with **Concept.md** to understand:
- Core Terraform operations
- Workflow best practices
- Command options and flags

### Step 2: Complete Labs
Follow **Lab-3.md** to:
- Initialize Terraform projects
- Validate configurations
- Generate and review plans
- Apply and destroy infrastructure

### Step 3: Test Your Knowledge
Complete **Test-Your-Understanding-Topic-3.md**:
- Answer multiple-choice questions
- Solve scenario-based problems
- Complete hands-on exercises

## Common Exam Questions

**Q: What does `terraform validate` check?**
A: Syntax and structure, NOT AWS permissions or resource availability.

**Q: What is the purpose of `terraform plan`?**
A: To preview what changes will be made without actually making them.

**Q: What is the difference between `terraform plan` and `terraform apply`?**
A: Plan shows changes; apply makes the changes.

**Q: Can you use `terraform apply` without running `terraform plan`?**
A: Yes, but it's not recommended. Always review the plan first.

## Best Practices

✅ Always validate before planning  
✅ Always review plan before applying  
✅ Use `terraform plan -out=tfplan` to save plans  
✅ Use `terraform apply tfplan` to apply saved plans  
✅ Use `terraform destroy` carefully  
✅ Keep configuration files organized  
✅ Use version control for all files  

## Next Steps

After completing Topic 3:
1. Review certification exam objectives 3.1-3.3, 6.1-6.2
2. Practice core Terraform operations
3. Proceed to **Topic 4**: Resource Management & Dependencies
4. Continue with remaining topics for full certification prep

## Resources

- [Terraform Commands](https://www.terraform.io/docs/cli/commands)
- [Terraform Workflow](https://www.terraform.io/docs/cli/workflows)
- [Terraform Plan](https://www.terraform.io/docs/cli/commands/plan)
- [Terraform Apply](https://www.terraform.io/docs/cli/commands/apply)

---

**Topic Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Learning

**Estimated Completion Time**: 5-6 hours  
**Difficulty Level**: Intermediate  
**Prerequisites**: Topics 1-2 completed

