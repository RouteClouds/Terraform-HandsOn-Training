# Test Your Understanding: Topic 7 - Terraform Modules

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your mastery of advanced Terraform module development concepts, composition patterns, versioning strategies, testing frameworks, and enterprise governance. The test covers sophisticated module scenarios that you'll encounter in production environments.

### **Assessment Structure**
- **Total Questions**: 50 questions across 5 sections
- **Time Limit**: 90 minutes
- **Passing Score**: 85% (43/50 correct answers)
- **Question Types**: Multiple choice, scenario-based, hands-on implementation, and enterprise case studies

### **Learning Objectives Assessed**
1. **Module Architecture and Design** (20% - 10 questions)
2. **Module Composition and Dependencies** (20% - 10 questions)
3. **Versioning and Lifecycle Management** (20% - 10 questions)
4. **Testing and Validation Frameworks** (20% - 10 questions)
5. **Enterprise Governance and Registry** (20% - 10 questions)

---

## 📊 **Section 1: Module Architecture and Design (20 points)**

### **Question 1** (2 points)
Which module design principle ensures that each module has a single, well-defined purpose?

**A)** Reusability
**B)** Single Responsibility Principle
**C)** Composability
**D)** Parameterization

**Correct Answer: B** - Single Responsibility Principle ensures each module has one clear, focused purpose.

### **Question 2** (2 points)
What is the recommended file structure for a well-organized Terraform module?

**A)**
```
module/
├── main.tf
└── variables.tf
```

**B)**
```
module/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

**C)**
```
module/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── locals.tf
├── data.tf
├── README.md
├── examples/
├── docs/
└── test/
```

**D)** All structures are equally valid

**Correct Answer: C** - Comprehensive structure with all necessary files, examples, documentation, and tests.

### **Question 3** (2 points)
Which variable validation pattern is most appropriate for ensuring a VPC CIDR block is valid?

**A)**
```hcl
validation {
  condition = length(var.vpc_cidr) > 0
  error_message = "VPC CIDR cannot be empty."
}
```

**B)**
```hcl
validation {
  condition = can(regex("^10\\.", var.vpc_cidr))
  error_message = "VPC CIDR must start with 10."
}
```

**C)**
```hcl
validation {
  condition = can(cidrhost(var.vpc_cidr, 0))
  error_message = "VPC CIDR must be a valid IPv4 CIDR block."
}
```

**D)**
```hcl
validation {
  condition = contains(["10.0.0.0/16", "172.16.0.0/16"], var.vpc_cidr)
  error_message = "VPC CIDR must be from predefined list."
}
```

**Correct Answer: C** - Using `can(cidrhost())` properly validates IPv4 CIDR format and range.

### **Question 4** (2 points)
What is the best practice for handling optional variables with complex default values?

**A)** Use `null` as default and handle in locals
**B)** Use the `optional()` type constraint with defaults
**C)** Always require all variables to be specified
**D)** Use conditional expressions in resource blocks

**Correct Answer: B** - The `optional()` type constraint with defaults provides clean, declarative optional variable handling.

### **Question 5** (2 points)
Which output pattern provides the most flexibility for module consumers?

**A)**
```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

**B)**
```hcl
output "vpc_info" {
  value = {
    id = aws_vpc.main.id
    cidr = aws_vpc.main.cidr_block
  }
}
```

**C)**
```hcl
output "vpc_configuration" {
  value = {
    vpc_id = aws_vpc.main.id
    vpc_cidr = aws_vpc.main.cidr_block
    vpc_arn = aws_vpc.main.arn
    subnets = {
      public = {
        ids = aws_subnet.public[*].id
        cidrs = aws_subnet.public[*].cidr_block
      }
      private = {
        ids = aws_subnet.private[*].id
        cidrs = aws_subnet.private[*].cidr_block
      }
    }
    gateways = {
      internet_gateway_id = aws_internet_gateway.main.id
      nat_gateway_ids = aws_nat_gateway.main[*].id
    }
  }
}
```

**D)** Individual outputs for each resource attribute

**Correct Answer: C** - Structured output with organized, comprehensive information provides maximum flexibility.

---

## 🔄 **Section 2: Module Composition and Dependencies (20 points)**

### **Question 6** (2 points)
What is the recommended approach for managing dependencies between modules in a hierarchical architecture?

**A)** Use `depends_on` for all module relationships
**B)** Implement explicit dependencies through module outputs and inputs
**C)** Avoid dependencies by duplicating resources
**D)** Use data sources exclusively for cross-module references

**Correct Answer: B** - Explicit dependencies through outputs/inputs create clear, maintainable relationships.

### **Question 7** (2 points)
Which pattern best represents a foundation → platform → application module hierarchy?

**A)**
```hcl
# All modules in same configuration
module "vpc" { }
module "app" { }
module "monitoring" { }
```

**B)**
```hcl
# Foundation layer
module "vpc" { }

# Platform layer (depends on foundation)
module "monitoring" {
  vpc_id = module.vpc.vpc_id
}

# Application layer (depends on platform)
module "app" {
  vpc_id = module.vpc.vpc_id
  monitoring_config = module.monitoring.config
}
```

**C)**
```hcl
# Separate state files with remote state data sources
data "terraform_remote_state" "foundation" { }
data "terraform_remote_state" "platform" { }

module "app" {
  vpc_id = data.terraform_remote_state.foundation.outputs.vpc_id
  monitoring_config = data.terraform_remote_state.platform.outputs.config
}
```

**D)** Both B and C are valid approaches

**Correct Answer: D** - Both approaches are valid; choice depends on team structure and deployment strategy.

### **Question 8** (2 points)
How should circular dependencies between modules be resolved?

**A)** Use `depends_on` to force ordering
**B)** Merge modules with circular dependencies
**C)** Refactor architecture to eliminate circular dependencies
**D)** Use data sources to break the cycle

**Correct Answer: C** - Circular dependencies indicate architectural issues that should be resolved through refactoring.

### **Question 9** (2 points)
What is the best practice for passing sensitive data between modules?

**A)** Use environment variables
**B)** Mark outputs as sensitive and use secure parameter passing
**C)** Store in external files
**D)** Avoid passing sensitive data between modules

**Correct Answer: B** - Sensitive outputs with secure parameter passing maintains security while enabling composition.

### **Question 10** (2 points)
Which module composition pattern is most suitable for dynamic infrastructure scaling?

**A)** Static module calls with fixed counts
**B)** `for_each` with dynamic module instantiation
**C)** Conditional module calls with `count`
**D)** Manual module duplication

**Correct Answer: B** - `for_each` provides flexible, dynamic module instantiation based on input data.

---

## 📋 **Section 3: Versioning and Lifecycle Management (20 points)**

### **Question 11** (2 points)
Which semantic versioning change indicates a breaking change in a module?

**A)** 1.2.3 → 1.2.4 (patch)
**B)** 1.2.3 → 1.3.0 (minor)
**C)** 1.2.3 → 2.0.0 (major)
**D)** 1.2.3 → 1.2.4-beta (pre-release)

**Correct Answer: C** - Major version changes (2.0.0) indicate breaking changes.

### **Question 12** (2 points)
What is the recommended version constraint for production module usage?

**A)** `source = "git::https://github.com/company/module.git"`
**B)** `source = "git::https://github.com/company/module.git?ref=main"`
**C)** `source = "git::https://github.com/company/module.git?ref=v1.2.3"`
**D)** `source = "./local-module"`

**Correct Answer: C** - Pinning to specific version tags ensures reproducible deployments.

### **Question 13** (2 points)
Which module registry approach provides the best governance for enterprise environments?

**A)** Public Terraform Registry only
**B)** Private module registry with approval workflows
**C)** Git repositories with manual version management
**D)** Local file system modules

**Correct Answer: B** - Private registries with approval workflows provide enterprise governance and control.

### **Question 14** (2 points)
What is the best practice for module deprecation?

**A)** Immediately remove deprecated modules
**B)** Mark as deprecated with migration timeline and alternative recommendations
**C)** Keep deprecated modules indefinitely
**D)** Only notify through documentation

**Correct Answer: B** - Gradual deprecation with clear migration path and timeline.

### **Question 15** (2 points)
Which CI/CD integration pattern is most effective for module lifecycle management?

**A)** Manual testing and deployment
**B)** Automated testing with manual approval for releases
**C)** Fully automated testing, building, and deployment
**D)** Testing only on main branch

**Correct Answer: B** - Automated testing with human approval balances efficiency and control.

---

## 🧪 **Section 4: Testing and Validation Frameworks (20 points)**

### **Question 16** (2 points)
Which testing framework is most commonly used for Terraform module testing?

**A)** Jest
**B)** Terratest
**C)** Pytest
**D)** RSpec

**Correct Answer: B** - Terratest is the de facto standard for Terraform testing.

### **Question 17** (2 points)
What does the testing pyramid recommend for Terraform modules?

**A)** Only integration tests
**B)** More unit tests, fewer integration tests, minimal end-to-end tests
**C)** Equal distribution of all test types
**D)** Only end-to-end tests

**Correct Answer: B** - Testing pyramid emphasizes more unit tests at the base, fewer integration tests, and minimal e2e tests.

### **Question 18** (2 points)
Which validation tool is best for security compliance checking?

**A)** `terraform validate`
**B)** `terraform fmt`
**C)** Checkov or TFSec
**D)** TFLint

**Correct Answer: C** - Checkov and TFSec specialize in security and compliance validation.

### **Question 19** (2 points)
What is the recommended approach for testing module examples?

**A)** Manual testing only
**B)** Automated testing of all examples in CI/CD
**C)** Documentation-only examples
**D)** Testing examples is unnecessary

**Correct Answer: B** - Automated testing ensures examples remain functional and serve as integration tests.

### **Question 20** (2 points)
Which testing strategy provides the best balance of coverage and efficiency?

**A)** Test every possible input combination
**B)** Test happy path scenarios only
**C)** Test critical paths, edge cases, and error conditions
**D)** Test only the most complex scenarios

**Correct Answer: C** - Comprehensive testing of critical paths, edge cases, and error conditions provides optimal coverage.

---

## 🏢 **Section 5: Enterprise Governance and Registry (20 points)**

### **Question 21** (2 points)
Which governance model is most effective for large enterprise module management?

**A)** Centralized control with single team ownership
**B)** Federated model with center of excellence and distributed ownership
**C)** Completely decentralized with no oversight
**D)** External vendor management only

**Correct Answer: B** - Federated model balances central governance with distributed expertise and ownership.

### **Question 22** (2 points)
What is the most important factor in module registry access control?

**A)** Public access for all modules
**B)** Role-based access control with least privilege principles
**C)** Single admin account for all operations
**D)** No access controls needed

**Correct Answer: B** - RBAC with least privilege ensures appropriate access while maintaining security.

### **Question 23** (2 points)
Which module approval workflow provides the best quality assurance?

**A)** Automatic approval for all submissions
**B)** Multi-stage review with automated testing, security scanning, and peer review
**C)** Single reviewer approval
**D)** No approval process needed

**Correct Answer: B** - Multi-stage review with automation and human oversight ensures comprehensive quality assurance.

### **Question 24** (2 points)
How should module documentation standards be enforced in enterprise environments?

**A)** Optional documentation
**B)** Automated documentation generation and validation in CI/CD
**C)** Manual documentation review only
**D)** Documentation is not necessary for modules

**Correct Answer: B** - Automated documentation standards enforcement ensures consistency and completeness.

### **Question 25** (2 points)
What is the best practice for module cost management and optimization?

**A)** No cost considerations needed
**B)** Manual cost review after deployment
**C)** Automated cost estimation and optimization recommendations in module design
**D)** Cost management is not a module concern

**Correct Answer: C** - Proactive cost estimation and optimization in module design prevents expensive surprises.

---

## 📊 **Assessment Results and Scoring**

### **Scoring Rubric**
- **90-100% (45-50 correct)**: **Expert Level** - Ready for enterprise-scale module development and governance
- **85-89% (43-44 correct)**: **Advanced Level** - Strong understanding with minor knowledge gaps
- **75-84% (38-42 correct)**: **Intermediate Level** - Good foundation, requires additional study
- **65-74% (33-37 correct)**: **Beginner Level** - Basic understanding, significant study needed
- **Below 65% (<33 correct)**: **Needs Review** - Fundamental concepts require reinforcement

### **Answer Key Summary**
1. B  2. C  3. C  4. B  5. C
6. B  7. D  8. C  9. B  10. B
11. C  12. C  13. B  14. B  15. B
16. B  17. B  18. C  19. B  20. C
21. B  22. B  23. B  24. B  25. C

### **Knowledge Gap Analysis**
If you scored below 85%, focus additional study on these areas:
- **Module Architecture**: Review design principles and structural organization patterns
- **Composition Patterns**: Practice hierarchical module design and dependency management
- **Versioning Strategies**: Study semantic versioning and lifecycle management workflows
- **Testing Frameworks**: Master Terratest and validation tool integration
- **Enterprise Governance**: Understand registry management and approval workflows

### **Next Steps**
- **Expert Level**: Proceed to Topic 8 - Advanced State Management
- **Advanced Level**: Review missed concepts, then proceed to Topic 8
- **Intermediate/Beginner**: Complete additional hands-on exercises before advancing
- **Needs Review**: Revisit Topic 7 materials and complete all lab exercises

---

*This assessment validates your readiness for enterprise-scale Terraform module development and governance. Strong performance indicates mastery of advanced concepts needed for production infrastructure deployments.*
