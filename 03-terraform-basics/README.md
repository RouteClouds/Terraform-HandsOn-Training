# Topic 03: Terraform Basics

## Overview
This module covers fundamental concepts of Terraform, including basic commands, resource creation, variable management, and state operations.

## Prerequisites
- AWS CLI installed and configured
- Terraform (>= 1.0.0) installed
- Basic understanding of AWS services
- Text editor (VS Code recommended)

## Module Structure
```plaintext
03-terraform-basics/
├── theory.md                 # Theoretical concepts
├── labs.md                   # Lab instructions
├── practice-test.md         # Practice exercises
├── terraform-manifests/     # Lab configurations
│   ├── lab1/               # Basic Commands
│   ├── lab2/               # Variables and VPC
│   ├── lab3/               # Resource Dependencies
│   └── lab4/               # State Management
└── terraform-diagrams/      # Architecture diagrams
    ├── theory/             # Theory diagrams
    └── labs/               # Lab diagrams
```

## Learning Objectives
1. Understand Terraform basics and workflow
2. Master essential Terraform commands
3. Learn resource and dependency management
4. Implement state management best practices
5. Work with variables and outputs

## Labs Overview
1. **Lab 1**: Basic Terraform Commands
   - Initialize Terraform
   - Create S3 bucket
   - Apply and destroy resources

2. **Lab 2**: Variables and VPC
   - Work with variables
   - Create VPC resources
   - Implement outputs

3. **Lab 3**: Resource Dependencies
   - Manage implicit dependencies
   - Create explicit dependencies
   - Build complete network stack

4. **Lab 4**: State Management
   - Configure remote state
   - Implement state locking
   - Perform state operations

## Time Allocation
- Theory: 1 hour
- Labs: 4 hours
- Practice: 1 hour
Total: 6 hours

## Additional Resources
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/) 