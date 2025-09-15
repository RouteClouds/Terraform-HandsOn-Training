# Test Your Understanding - Topic 4: Resource Management & Dependencies

## 🎯 **Assessment Overview**

This comprehensive assessment evaluates your understanding of advanced resource management, complex dependency patterns, sophisticated meta-arguments usage, and enterprise-grade lifecycle management strategies in Terraform.

**Duration**: 90 minutes  
**Total Points**: 100 points  
**Passing Score**: 80 points  
**Format**: Multiple choice, scenario-based questions, and hands-on exercises

---

## 📋 **Section A: Multiple Choice Questions (40 points)**
*Choose the best answer for each question. Each question is worth 2 points.*

### **Question 1: Implicit vs Explicit Dependencies**
What is the primary difference between implicit and explicit dependencies in Terraform?

A) Implicit dependencies are faster to resolve than explicit dependencies  
B) Implicit dependencies are automatically detected through resource references, explicit dependencies are manually declared  
C) Explicit dependencies are only used for cross-provider resources  
D) Implicit dependencies require the depends_on meta-argument  

**Correct Answer**: B  
**Explanation**: Implicit dependencies are automatically detected when one resource references attributes of another, while explicit dependencies are manually declared using depends_on.

---

### **Question 2: Count vs For_Each Meta-Arguments**
When should you use for_each instead of count for creating multiple resources?

A) When you need better performance  
B) When you want stable resource addresses that don't change when items are added/removed  
C) When you need to create more than 10 resources  
D) When working with string values only  

**Correct Answer**: B  
**Explanation**: for_each provides stable resource addresses using keys, while count uses numeric indices that can shift when items are added/removed.

---

### **Question 3: Lifecycle Meta-Argument - Create Before Destroy**
What is the primary use case for the create_before_destroy lifecycle rule?

A) Improving deployment performance  
B) Reducing infrastructure costs  
C) Enabling zero-downtime deployments by creating new resources before destroying old ones  
D) Preventing accidental resource deletion  

**Correct Answer**: C  
**Explanation**: create_before_destroy ensures zero-downtime deployments by creating replacement resources before destroying the original ones.

---

### **Question 4: Circular Dependency Resolution**
How can you resolve circular dependencies in Terraform?

A) Use the force_dependency meta-argument  
B) Use data sources to break the dependency cycle  
C) Increase the parallelism setting  
D) Use the ignore_changes lifecycle rule  

**Correct Answer**: B  
**Explanation**: Data sources can query existing resources without creating dependencies, effectively breaking circular dependency cycles.

---

### **Question 5: Depends_On Meta-Argument**
When should you use the depends_on meta-argument?

A) Only for cross-provider dependencies  
B) When Terraform cannot automatically detect the dependency relationship  
C) To improve resource creation performance  
D) To reduce the number of API calls  

**Correct Answer**: B  
**Explanation**: depends_on is used when dependencies exist that Terraform cannot automatically detect through resource attribute references.

---

### **Question 6: Resource Addressing with For_Each**
How do you reference a specific resource created with for_each?

A) `resource_type.resource_name[0]`  
B) `resource_type.resource_name["key"]`  
C) `resource_type.resource_name.key`  
D) `resource_type.resource_name[key]`  

**Correct Answer**: B  
**Explanation**: for_each resources are referenced using the key in square brackets with quotes: resource_type.resource_name["key"].

---

### **Question 7: Lifecycle - Prevent Destroy**
What happens when you try to destroy a resource with prevent_destroy = true?

A) The resource is destroyed after a confirmation prompt  
B) Terraform returns an error and refuses to destroy the resource  
C) The resource is marked for deletion but not actually destroyed  
D) Terraform creates a backup before destroying the resource  

**Correct Answer**: B  
**Explanation**: prevent_destroy = true causes Terraform to return an error and refuse to destroy the resource, protecting critical infrastructure.

---

### **Question 8: Dependency Graph Analysis**
Which command generates a visual representation of resource dependencies?

A) `terraform dependencies`  
B) `terraform graph | dot -Tpng > graph.png`  
C) `terraform plan --graph`  
D) `terraform show --dependencies`  

**Correct Answer**: B  
**Explanation**: terraform graph generates a DOT format graph that can be converted to PNG using Graphviz's dot command.

---

### **Question 9: Resource Targeting**
What is the primary purpose of resource targeting with -target?

A) Improving deployment performance  
B) Selective deployment and debugging of specific resources  
C) Reducing AWS API costs  
D) Enabling parallel resource creation  

**Correct Answer**: B  
**Explanation**: Resource targeting allows selective deployment and debugging of specific resources, useful for troubleshooting and phased deployments.

---

### **Question 10: Ignore Changes Lifecycle Rule**
When should you use the ignore_changes lifecycle rule?

A) To prevent all changes to a resource  
B) To ignore specific attributes that are managed externally or change frequently  
C) To improve Terraform performance  
D) To enable automatic resource updates  

**Correct Answer**: B  
**Explanation**: ignore_changes is used to ignore specific attributes that are managed externally or change frequently, preventing unnecessary resource updates.

---

### **Questions 11-20: Advanced Concepts**

**Question 11**: Which meta-argument allows you to replace a resource when another resource changes?
A) depends_on  B) replace_triggered_by  C) create_before_destroy  D) ignore_changes  
**Answer**: B

**Question 12**: What is the maximum number of resources you can target in a single terraform apply -target command?
A) 1  B) 10  C) 50  D) Unlimited  
**Answer**: D

**Question 13**: How do you reference all instances of a resource created with count?
A) resource_type.resource_name[*]  B) resource_type.resource_name.all  C) resource_type.resource_name[]  D) resource_type.resource_name.list  
**Answer**: A

**Question 14**: Which lifecycle rule is most appropriate for a production database?
A) create_before_destroy  B) prevent_destroy  C) ignore_changes  D) replace_triggered_by  
**Answer**: B

**Question 15**: What happens if you remove an item from the middle of a list used with count?
A) No impact on existing resources  B) Resources are renumbered and may be recreated  C) Terraform throws an error  D) Only the last resource is affected  
**Answer**: B

**Question 16**: How do you iterate over a map in a for_each expression?
A) for_each = var.map  B) for_each = keys(var.map)  C) for_each = values(var.map)  D) for_each = items(var.map)  
**Answer**: A

**Question 17**: Which command shows the current state of a specific resource?
A) terraform show resource_address  B) terraform state show resource_address  C) terraform get resource_address  D) terraform describe resource_address  
**Answer**: B

**Question 18**: What is the purpose of the each object in for_each resources?
A) To access the current index  B) To access the key and value of the current iteration  C) To reference other resources  D) To define resource attributes  
**Answer**: B

**Question 19**: How do you create conditional resources based on a variable?
A) Use if/else statements  B) Use count with conditional expression  C) Use depends_on conditionally  D) Use lifecycle rules  
**Answer**: B

**Question 20**: What is the recommended approach for managing resource dependencies in large infrastructures?
A) Use only explicit dependencies  B) Use only implicit dependencies  C) Combine implicit and explicit dependencies strategically  D) Avoid dependencies altogether  
**Answer**: C

---

## 🎯 **Section B: Scenario-Based Questions (30 points)**
*Analyze the scenarios and provide the best solutions. Each question is worth 10 points.*

### **Scenario 1: Complex Multi-Tier Dependency Management (10 points)**

**Situation**: A financial services company needs to deploy a complex multi-tier application with strict dependency requirements. The infrastructure includes:

- VPC with public, private, and database subnets across 3 AZs
- RDS database cluster that must be available before any application servers
- Three application tiers (web, app, api) with different scaling requirements
- Application Load Balancer that should only be created after all application tiers are healthy
- CloudWatch monitoring that depends on all infrastructure being ready

**Requirements**:
- Zero downtime during updates
- Strict dependency ordering for compliance
- Different scaling patterns for each application tier
- Ability to update individual tiers without affecting others
- Comprehensive monitoring and logging

**Question**: Design a comprehensive dependency management strategy using appropriate meta-arguments and lifecycle rules.

**Expected Answer Components**:
- Use of for_each for application tiers with stable addressing
- Explicit depends_on for critical dependency relationships
- Lifecycle rules for zero-downtime deployments
- Resource targeting strategy for tier-specific updates
- Monitoring dependencies and observability patterns

---

### **Scenario 2: Circular Dependency Resolution in Enterprise Environment (10 points)**

**Situation**: An enterprise deployment has encountered circular dependency issues:

- Security Group A needs to reference Security Group B for ingress rules
- Security Group B needs to reference Security Group A for egress rules
- Both security groups are required for the application to function
- The application spans multiple VPCs with peering connections
- Compliance requires specific security group rule documentation

**Current Error**:
```
Error: Cycle: aws_security_group.app -> aws_security_group.db -> aws_security_group.app
```

**Question**: Design a solution to resolve the circular dependency while maintaining security requirements and compliance.

**Expected Answer Components**:
- Data source usage to break circular dependencies
- Security group rule resources for complex relationships
- Alternative architecture patterns to avoid cycles
- Compliance documentation strategies
- Testing and validation approaches

---

### **Scenario 3: Advanced Lifecycle Management for Production Workloads (10 points)**

**Situation**: A production e-commerce platform requires sophisticated lifecycle management:

- Database instances that must never be accidentally destroyed
- Application servers that need zero-downtime updates
- Load balancers that should ignore certain AWS-managed attributes
- Auto Scaling Groups that should maintain capacity during updates
- Launch templates that trigger cascading updates when changed

**Requirements**:
- Prevent accidental destruction of critical resources
- Enable rolling updates without service interruption
- Ignore external changes to specific attributes
- Coordinate updates across dependent resources
- Maintain audit trail of all changes

**Question**: Design a comprehensive lifecycle management strategy using all available lifecycle meta-arguments.

**Expected Answer Components**:
- prevent_destroy for critical resources
- create_before_destroy for zero-downtime updates
- ignore_changes for externally managed attributes
- replace_triggered_by for coordinated updates
- Testing and validation procedures

---

## 🛠️ **Section C: Hands-On Practical Exercises (30 points)**
*Complete the following practical tasks. Each exercise is worth 10 points.*

### **Exercise 1: Multi-Tier Dependency Implementation (10 points)**

**Task**: Implement a complex multi-tier infrastructure demonstrating advanced dependency patterns.

**Requirements**:
1. Create a VPC with subnets using count meta-argument
2. Implement security groups using for_each meta-argument
3. Deploy RDS database with explicit dependencies
4. Create application tiers with lifecycle management
5. Implement load balancer with complex dependency chains

**Deliverables**:
- Complete Terraform configuration with all dependency patterns
- Dependency graph visualization
- Resource targeting demonstration
- Lifecycle management implementation
- Testing and validation results

**Evaluation Criteria**:
- Dependency implementation (3 points)
- Meta-arguments usage (3 points)
- Lifecycle management (2 points)
- Testing and documentation (2 points)

---

### **Exercise 2: Circular Dependency Resolution (10 points)**

**Task**: Create and resolve a circular dependency scenario using advanced Terraform techniques.

**Requirements**:
1. Create a scenario with circular dependencies
2. Demonstrate the error condition
3. Implement resolution using data sources
4. Show alternative resolution approaches
5. Validate the solution works correctly

**Deliverables**:
- Initial configuration with circular dependency
- Error demonstration and analysis
- Resolution implementation with data sources
- Alternative approaches documentation
- Testing and validation procedures

**Evaluation Criteria**:
- Problem demonstration (2 points)
- Resolution implementation (4 points)
- Alternative approaches (2 points)
- Testing and validation (2 points)

---

### **Exercise 3: Advanced Lifecycle and Meta-Arguments (10 points)**

**Task**: Implement sophisticated lifecycle management and meta-arguments patterns for enterprise scenarios.

**Requirements**:
1. Use all four lifecycle meta-arguments appropriately
2. Implement both count and for_each patterns
3. Demonstrate resource replacement scenarios
4. Show dependency targeting and selective updates
5. Implement monitoring and observability

**Deliverables**:
- Configuration with all lifecycle patterns
- Meta-arguments demonstration
- Resource replacement testing
- Dependency targeting examples
- Monitoring and observability implementation

**Evaluation Criteria**:
- Lifecycle implementation (3 points)
- Meta-arguments usage (3 points)
- Resource management (2 points)
- Monitoring and testing (2 points)

---

## 📊 **Assessment Scoring Guide**

### **Scoring Breakdown**
- **Section A (Multiple Choice)**: 40 points (2 points each)
- **Section B (Scenarios)**: 30 points (10 points each)
- **Section C (Hands-On)**: 30 points (10 points each)
- **Total**: 100 points

### **Grade Scale**
- **90-100 points**: Excellent (A) - Advanced mastery of resource management and dependencies
- **80-89 points**: Good (B) - Proficient understanding with minor gaps
- **70-79 points**: Satisfactory (C) - Basic competency with some weaknesses
- **60-69 points**: Needs Improvement (D) - Requires additional study and practice
- **Below 60 points**: Unsatisfactory (F) - Significant knowledge gaps requiring remediation

### **Remediation Recommendations**

**For scores below 80 points**:
1. Review Terraform resource behavior and dependency documentation
2. Practice with complex multi-tier infrastructure scenarios
3. Study meta-arguments usage patterns and best practices
4. Gain experience with lifecycle management in production scenarios
5. Practice circular dependency resolution techniques

---

## 🎯 **Learning Objectives Assessment**

Upon successful completion of this assessment, you demonstrate:

- ✅ **Advanced mastery** of resource dependency management patterns
- ✅ **Expert-level skills** in meta-arguments usage and lifecycle management
- ✅ **Complex problem-solving** abilities for dependency conflicts and circular dependencies
- ✅ **Enterprise-grade** resource organization and management strategies
- ✅ **Production-ready** lifecycle management and zero-downtime deployment techniques
- ✅ **Practical application** of advanced resource management in real-world scenarios

---

## 📚 **Additional Study Resources**

### **For Further Learning**
- [Terraform Resource Behavior](https://developer.hashicorp.com/terraform/language/resources/behavior)
- [Meta-Arguments Documentation](https://developer.hashicorp.com/terraform/language/meta-arguments)
- [Lifecycle Management](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
- [Dependency Management Best Practices](https://developer.hashicorp.com/terraform/language/resources/behavior#resource-dependencies)

### **Practice Labs**
- Complete Lab 4.2: Advanced Resource Patterns
- Explore Lab 5.1: Variables and Outputs with Dependencies
- Practice Lab 6.1: State Management with Complex Dependencies

---

**Assessment Version**: 4.0  
**Last Updated**: January 2025  
**Aligned with**: Terraform ~> 1.13.0, AWS Provider ~> 6.12.0  
**Review Date**: Quarterly updates recommended
