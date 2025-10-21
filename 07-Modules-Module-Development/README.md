# Topic 7: Modules & Module Development

**Certification Alignment**: Terraform Associate 003/004  
**Exam Objectives**: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6  
**Difficulty**: Intermediate-Advanced  
**Estimated Time**: 6-7 hours

---

## Overview

Topic 7 covers Terraform modules for code reusability, organization, and best practices in module development.

## Learning Objectives

By completing this topic, you will be able to:

✅ Describe module structure  
✅ Understand module sources  
✅ Interact with module inputs and outputs  
✅ Manage module versioning  
✅ Use Terraform Registry  
✅ Develop reusable modules  

## Certification Alignment

### Exam Objectives Covered

**Objective 5.1**: Describe module structure
- Know module directory structure
- Understand main.tf, variables.tf, outputs.tf
- Know module organization

**Objective 5.2**: Describe module sources
- Know local modules
- Know registry modules
- Know remote modules

**Objective 5.3**: Interact with module inputs and outputs
- Know module variables
- Know module outputs
- Know module composition

**Objective 5.4**: Describe module versioning
- Know semantic versioning
- Understand version constraints
- Know version management

**Objective 5.5**: Interact with module registry
- Know Terraform Registry
- Know module publishing
- Know module discovery

**Objective 5.6**: Interact with module outputs
- Know output values
- Know output references
- Know output composition

### Domain Coverage

- **Domain 5**: Terraform Modules - 100%

## Key Concepts

### Module Structure
```
module/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

### Module Syntax
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

### Module Sources
- Local: `./modules/vpc`
- Registry: `terraform-aws-modules/vpc/aws`
- Remote: `git::https://...`

## Exam Tips

💡 **Tip 1**: Know the module structure: main.tf, variables.tf, outputs.tf.

💡 **Tip 2**: Modules are reusable containers of resources.

💡 **Tip 3**: Know the difference between module sources.

💡 **Tip 4**: Use semantic versioning for module versions.

💡 **Tip 5**: The Terraform Registry contains pre-built modules.

## Getting Started

### Step 1: Review Concept Material
Start with **Concept.md** to understand:
- Module structure and organization
- Module sources and usage
- Module development best practices

### Step 2: Complete Labs
Follow **Lab-7.md** to:
- Create reusable modules
- Use registry modules
- Manage module versions

### Step 3: Test Your Knowledge
Complete **Test-Your-Understanding-Topic-7.md**:
- Answer multiple-choice questions
- Solve scenario-based problems
- Complete hands-on exercises

## Common Exam Questions

**Q: What is a Terraform module?**
A: A reusable container of resources with inputs and outputs.

**Q: What is the recommended module structure?**
A: main.tf, variables.tf, outputs.tf, and README.md

**Q: How do you reference a module output?**
A: `module.module_name.output_name`

**Q: What is the Terraform Registry?**
A: A repository of pre-built modules and providers.

## Best Practices

✅ Use descriptive module names  
✅ Follow standard module structure  
✅ Document module inputs and outputs  
✅ Use semantic versioning  
✅ Create reusable modules  
✅ Test modules thoroughly  
✅ Publish modules to registry  

## Next Steps

After completing Topic 7:
1. Review certification exam objectives 5.1-5.6
2. Practice module development
3. Proceed to **Topic 8**: Advanced State Management
4. Continue with remaining topics for full certification prep

## Resources

- [Terraform Modules](https://www.terraform.io/docs/language/modules)
- [Module Structure](https://www.terraform.io/docs/language/modules/develop)
- [Terraform Registry](https://registry.terraform.io/)
- [Module Best Practices](https://www.terraform.io/docs/language/modules/develop/best-practices)

---

**Topic Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Learning

**Estimated Completion Time**: 6-7 hours  
**Difficulty Level**: Intermediate-Advanced  
**Prerequisites**: Topics 1-6 completed

