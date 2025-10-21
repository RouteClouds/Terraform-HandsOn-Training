# Topic 11: Terraform Troubleshooting & Debugging

**Certification Alignment**: Terraform Associate 003/004  
**Exam Objectives**: 4.2, 4.3, 6.1, 6.5  
**Difficulty**: Intermediate  
**Estimated Time**: 3-4 hours

---

## Overview

Topic 11 covers comprehensive Terraform troubleshooting techniques, debugging strategies, and error resolution. This is critical for resolving real-world infrastructure issues.

## Learning Objectives

By completing this topic, you will be able to:

✅ Enable and use Terraform logging for debugging  
✅ Identify and resolve common Terraform errors  
✅ Debug provider and API issues  
✅ Troubleshoot state file problems  
✅ Detect and resolve resource drift  
✅ Optimize Terraform performance  
✅ Handle authentication and authorization issues  
✅ Recover from Terraform failures  

## Directory Structure

```
11-terraform-troubleshooting/
├── Concept.md                          # Comprehensive theory (700+ lines)
├── Lab-11.md                           # Hands-on labs (500+ lines)
├── Test-Your-Understanding-Topic-11.md # Assessment (400+ lines)
├── README.md                           # This file
├── Terraform-Code-Lab-11.1/            # Working code examples
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── README.md
└── DaC/                                # Diagram as Code
    ├── requirements.txt
    ├── debugging_workflow_diagram.py
    ├── error_resolution_flowchart.py
    ├── state_troubleshooting_diagram.py
    ├── generate_all_diagrams.py
    └── README.md
```

## Content Files

### 1. **Concept.md** (700+ lines)
Comprehensive theory covering:
- Terraform logging and log levels
- Common Terraform errors and solutions
- Provider debugging techniques
- State file troubleshooting
- Resource drift detection and resolution
- Performance optimization
- Authentication and authorization issues
- Certification exam focus areas

### 2. **Lab-11.md** (500+ lines)
Three hands-on labs:
- **Lab 11.1**: Debug Common Terraform Errors
- **Lab 11.2**: Troubleshoot State File Issues
- **Lab 11.3**: Performance Troubleshooting

### 3. **Test-Your-Understanding-Topic-11.md** (400+ lines)
Assessment with:
- 10 multiple-choice questions
- 3 scenario-based questions
- 2 hands-on exercises
- Answer key with explanations

### 4. **Terraform-Code-Lab-11.1/**
Working code examples:
- Complete Terraform configuration
- Troubleshooting scenarios
- Ready to use for labs

### 5. **DaC/** (Diagram as Code)
Professional diagrams:
- Debugging workflow diagram
- Error resolution flowchart
- State troubleshooting diagram
- Reproducible and version-controlled

## Certification Alignment

### Exam Objectives Covered

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

## Getting Started

### Step 1: Review Concept Material
Start with **Concept.md** to understand:
- Terraform logging fundamentals
- Common error types and solutions
- Troubleshooting techniques
- Performance optimization

### Step 2: Generate Diagrams
```bash
cd DaC
pip install -r requirements.txt
python generate_all_diagrams.py
```

### Step 3: Complete Labs
Follow **Lab-11.md** to:
- Debug configuration errors
- Troubleshoot state issues
- Optimize performance

### Step 4: Test Your Knowledge
Complete **Test-Your-Understanding-Topic-11.md**:
- Answer 10 multiple-choice questions
- Solve 3 scenario-based problems
- Complete 2 hands-on exercises

### Step 5: Practice with Code
Use **Terraform-Code-Lab-11.1/** to:
- Apply working Terraform configuration
- Practice debugging techniques
- Experiment with troubleshooting

## Key Concepts

### Terraform Logging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform.log
```

### Common Errors
- Syntax errors: Use `terraform validate`
- Provider errors: Check AWS credentials
- State errors: Use `terraform refresh`
- Resource errors: Use `terraform import`

### Troubleshooting Tools
- `terraform validate` - Check syntax
- `terraform plan` - Detect drift
- `terraform refresh` - Sync state
- `terraform taint` - Mark for replacement
- `terraform force-unlock` - Release state lock

## Exam Tips

💡 **Tip 1**: Enable TF_LOG for debugging  
💡 **Tip 2**: Check AWS credentials first  
💡 **Tip 3**: Use terraform validate early  
💡 **Tip 4**: State lock issues use force-unlock  
💡 **Tip 5**: Resource drift use refresh or taint  

## Common Scenarios

### Scenario 1: Syntax Error
Use `terraform validate` to identify and fix syntax errors.

### Scenario 2: Provider Error
Check AWS credentials and IAM permissions.

### Scenario 3: State Lock
Use `terraform force-unlock` to release stuck lock.

### Scenario 4: Resource Drift
Use `terraform plan` to detect, then `terraform refresh` to resolve.

## Best Practices

✅ Always enable logging when debugging  
✅ Use terraform validate early  
✅ Check AWS credentials first  
✅ Use terraform refresh to sync state  
✅ Use terraform taint to replace resources  
✅ Optimize parallelism for performance  
✅ Document troubleshooting steps  

## Next Steps

After completing Topic 11:
1. Review certification exam objectives 4.2, 4.3, 6.1, 6.5
2. Practice troubleshooting techniques
3. Proceed to **Topic 12**: Advanced Security & Compliance
4. Continue with remaining topics for full certification prep

## Resources

- [Terraform Debugging](https://www.terraform.io/docs/internals/debugging.html)
- [Terraform Logging](https://www.terraform.io/docs/internals/logging.html)
- [Common Errors](https://www.terraform.io/docs/language/errors/)
- [AWS Provider Troubleshooting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#troubleshooting)

---

**Topic Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Learning

**Estimated Completion Time**: 3-4 hours  
**Difficulty Level**: Intermediate  
**Prerequisites**: Topics 1-10 completed

