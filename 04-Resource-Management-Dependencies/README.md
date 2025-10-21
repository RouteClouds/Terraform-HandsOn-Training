# Topic 4: Resource Management & Dependencies

**Certification Alignment**: Terraform Associate 003/004  
**Exam Objectives**: 3.3, 3.5, 3.6  
**Difficulty**: Intermediate  
**Estimated Time**: 5-6 hours

---

## Overview

Topic 4 covers resource management, addressing, and dependency management in Terraform.

## Learning Objectives

By completing this topic, you will be able to:

✅ Manage resource addressing  
✅ Understand resource syntax  
✅ Manage resource dependencies  
✅ Use implicit and explicit dependencies  
✅ Interact with Terraform state  
✅ Handle resource lifecycle  

## Certification Alignment

### Exam Objectives Covered

**Objective 3.3**: Manage resource addressing
- Know resource syntax
- Understand resource types
- Know resource names

**Objective 3.5**: Interact with Terraform state
- Know state file structure
- Understand resource state
- Know state commands

**Objective 3.6**: Manage resource dependencies
- Know implicit dependencies
- Know explicit dependencies
- Understand `depends_on`

### Domain Coverage

- **Domain 3**: Terraform Basics - 100%

## Key Concepts

### Resource Syntax
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

### Resource Addressing
- Type: `aws_instance`
- Name: `web`
- Full address: `aws_instance.web`

### Dependencies
- **Implicit**: Terraform infers from references
- **Explicit**: Using `depends_on`

## Exam Tips

💡 **Tip 1**: Know the resource syntax: `resource "type" "name" { ... }`

💡 **Tip 2**: Terraform automatically infers dependencies from resource references.

💡 **Tip 3**: Use `depends_on` for explicit dependencies when needed.

💡 **Tip 4**: Know how to reference resources: `aws_instance.web.id`

💡 **Tip 5**: Understand resource lifecycle: create, read, update, delete.

## Getting Started

### Step 1: Review Concept Material
Start with **Concept.md** to understand:
- Resource syntax and addressing
- Dependency management
- State interaction

### Step 2: Complete Labs
Follow **Lab-4.md** to:
- Create and manage resources
- Handle dependencies
- Interact with state

### Step 3: Test Your Knowledge
Complete **Test-Your-Understanding-Topic-4.md**:
- Answer multiple-choice questions
- Solve scenario-based problems
- Complete hands-on exercises

## Common Exam Questions

**Q: What is the resource syntax in Terraform?**
A: `resource "type" "name" { ... }`

**Q: How do you reference a resource?**
A: `resource_type.resource_name.attribute`

**Q: What is the difference between implicit and explicit dependencies?**
A: Implicit are inferred from references; explicit use `depends_on`.

**Q: When should you use `depends_on`?**
A: When Terraform cannot infer the dependency from resource references.

## Best Practices

✅ Use descriptive resource names  
✅ Let Terraform infer dependencies when possible  
✅ Use `depends_on` only when necessary  
✅ Understand resource lifecycle  
✅ Use resource references instead of hardcoding values  
✅ Keep resources organized  
✅ Document complex dependencies  

## Next Steps

After completing Topic 4:
1. Review certification exam objectives 3.3, 3.5, 3.6
2. Practice resource management
3. Proceed to **Topic 5**: Variables and Outputs
4. Continue with remaining topics for full certification prep

## Resources

- [Terraform Resources](https://www.terraform.io/docs/language/resources)
- [Resource Addressing](https://www.terraform.io/docs/cli/state/resource-addressing)
- [Resource Dependencies](https://www.terraform.io/docs/language/resources#resource-dependencies)
- [Terraform State](https://www.terraform.io/docs/language/state)

---

**Topic Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Learning

**Estimated Completion Time**: 5-6 hours  
**Difficulty Level**: Intermediate  
**Prerequisites**: Topics 1-3 completed

