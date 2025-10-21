# Topic 2: Terraform CLI & AWS Provider Configuration

**Certification Alignment**: Terraform Associate 003/004  
**Exam Objectives**: 2.1, 2.2, 2.3, 2.4, 3.2  
**Difficulty**: Beginner-Intermediate  
**Estimated Time**: 4-5 hours

---

## Overview

Topic 2 covers the Terraform CLI commands and AWS provider configuration. This is essential for setting up and managing Terraform projects.

## Learning Objectives

By completing this topic, you will be able to:

✅ Describe the Terraform workflow  
✅ Initialize a Terraform working directory  
✅ Validate Terraform configuration  
✅ Generate and review execution plans  
✅ Configure AWS provider authentication  
✅ Manage provider versions  

## Certification Alignment

### Exam Objectives Covered

**Objective 2.1**: Describe Terraform workflow
- Know the init → validate → plan → apply → destroy sequence
- Understand what each command does

**Objective 2.2**: Initialize a Terraform working directory
- Know `terraform init` command
- Understand backend initialization
- Know provider installation

**Objective 2.3**: Validate Terraform configuration
- Know `terraform validate` command
- Understand syntax checking
- Know what validate does NOT check

**Objective 2.4**: Generate and review execution plan
- Know `terraform plan` command
- Understand plan output
- Know how to save and review plans

**Objective 3.2**: Configure AWS provider
- Know provider block syntax
- Understand authentication methods
- Know credential precedence

### Domain Coverage

- **Domain 2**: Terraform Purpose - 85%
- **Domain 3**: Terraform Basics - 95%

## Key Concepts

### Terraform Workflow
```
terraform init → terraform validate → terraform plan → terraform apply → terraform destroy
```

### AWS Provider Configuration
```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Authentication Methods
1. Environment variables
2. AWS CLI configuration
3. IAM roles
4. Temporary credentials

## Exam Tips

💡 **Tip 1**: Know the Terraform workflow order. It's always init → validate → plan → apply.

💡 **Tip 2**: `terraform validate` checks syntax, NOT AWS permissions or resource availability.

💡 **Tip 3**: Always run `terraform plan` before `terraform apply` to review changes.

💡 **Tip 4**: Know the AWS credential precedence: environment variables > AWS CLI > IAM roles.

💡 **Tip 5**: Provider configuration can be done via provider block or environment variables.

## Getting Started

### Step 1: Review Concept Material
Start with **Concept.md** to understand:
- Terraform CLI commands
- AWS provider configuration
- Authentication methods
- Workflow best practices

### Step 2: Complete Labs
Follow **Lab-2.md** to:
- Initialize Terraform projects
- Configure AWS provider
- Run Terraform commands
- Review execution plans

### Step 3: Test Your Knowledge
Complete **Test-Your-Understanding-Topic-2.md**:
- Answer multiple-choice questions
- Solve scenario-based problems
- Complete hands-on exercises

## Common Exam Questions

**Q: What is the correct Terraform workflow?**
A: init → validate → plan → apply → destroy

**Q: What does `terraform validate` check?**
A: Syntax and structure, NOT AWS permissions or resource availability.

**Q: How do you configure AWS credentials for Terraform?**
A: Environment variables, AWS CLI, IAM roles, or provider block.

**Q: What is the difference between `terraform plan` and `terraform apply`?**
A: Plan shows what will change; apply makes the changes.

## Best Practices

✅ Always run `terraform init` first  
✅ Always validate before planning  
✅ Always review plan before applying  
✅ Use environment variables for credentials  
✅ Never hardcode credentials  
✅ Use provider versioning  
✅ Document provider configuration  

## Next Steps

After completing Topic 2:
1. Review certification exam objectives 2.1-2.4, 3.2
2. Practice Terraform CLI commands
3. Proceed to **Topic 3**: Core Terraform Operations
4. Continue with remaining topics for full certification prep

## Resources

- [Terraform CLI Documentation](https://www.terraform.io/docs/cli)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Workflow](https://www.terraform.io/docs/cli/workflows)
- [AWS Authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)

---

**Topic Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Learning

**Estimated Completion Time**: 4-5 hours  
**Difficulty Level**: Beginner-Intermediate  
**Prerequisites**: Topic 1 completed

