# Test Your Understanding: Topic 4 - Resource Management & Dependencies

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your mastery of advanced resource management and dependency patterns including complex dependency relationships, lifecycle management, meta-arguments, resource targeting, and enterprise-scale troubleshooting. The test combines multiple-choice questions, scenario-based challenges, and hands-on exercises to validate practical understanding and implementation skills.

### **Learning Objectives Assessed**
1. **Dependency Graph Management** (25 points): Complex dependency analysis, implicit/explicit relationships, and graph optimization
2. **Advanced Lifecycle Control** (25 points): Sophisticated lifecycle patterns, zero-downtime deployments, and state transitions
3. **Meta-Argument Mastery** (20 points): Advanced meta-argument combinations, conditional logic, and complex scenarios
4. **Resource Targeting Strategies** (15 points): Precise targeting, selective operations, and production deployment patterns
5. **Dependency Troubleshooting** (15 points): Issue diagnosis, resolution strategies, and prevention techniques

### **Assessment Integration with Visual Learning**
This assessment directly references the professional diagrams created in the DaC implementation:
- **Figure 4.1**: Terraform Dependency Graph and Resource Relationships (Questions 1-5)
- **Figure 4.2**: Resource Lifecycle Management and State Transitions (Questions 6-10)
- **Figure 4.3**: Meta-Arguments and Advanced Resource Control (Questions 11-15)
- **Figure 4.4**: Resource Targeting and Selective Operations (Questions 16-20)
- **Figure 4.5**: Dependency Troubleshooting and Resolution Patterns (Scenario-based challenges)

### **Time Allocation**
- **Multiple Choice Questions**: 45 minutes (20 questions)
- **Scenario-Based Challenges**: 30 minutes (5 scenarios)
- **Hands-On Exercises**: 60 minutes (3 exercises)
- **Total Assessment Time**: 135 minutes

---

## 🎯 **Multiple Choice Questions (20 Questions - 5 points each)**

### **Section A: Dependency Graph Management (Questions 1-5)**

### **Question 1** (5 points)
Which type of dependency is automatically detected when one resource references attributes of another resource?

A) Explicit dependency  
B) Implicit dependency  
C) Circular dependency  
D) Optional dependency  

**Correct Answer**: B  
**Explanation**: Implicit dependencies are automatically detected by Terraform when one resource references attributes of another resource through interpolation syntax.

---

### **Question 2** (5 points)
What is the primary purpose of the `depends_on` meta-argument?

A) To improve performance by parallelizing resource creation  
B) To create explicit dependencies when Terraform cannot automatically detect relationships  
C) To prevent circular dependencies between resources  
D) To optimize the dependency graph for faster execution  

**Correct Answer**: B  
**Explanation**: The `depends_on` meta-argument creates explicit dependencies when Terraform cannot automatically infer the relationship between resources.

---

### **Question 3** (5 points)
In which order does Terraform typically process resources during dependency resolution?

A) Alphabetical order by resource name  
B) Order of appearance in configuration files  
C) Topological sort based on dependency graph  
D) Random order for optimal parallelization  

**Correct Answer**: C  
**Explanation**: Terraform uses topological sorting of the dependency graph to determine the correct order for resource operations.

---

### **Question 4** (5 points)
What happens when Terraform detects a circular dependency in the configuration?

A) It automatically resolves the circular dependency  
B) It fails with an error during the planning phase  
C) It creates resources in random order  
D) It ignores one of the dependencies  

**Correct Answer**: B  
**Explanation**: Terraform fails with an error during the planning phase when it detects circular dependencies, as they cannot be resolved.

---

### **Question 5** (5 points)
Which command generates a visual representation of the dependency graph?

A) `terraform show`  
B) `terraform plan`  
C) `terraform graph`  
D) `terraform state list`  

**Correct Answer**: C  
**Explanation**: The `terraform graph` command generates a DOT format representation of the dependency graph that can be visualized with tools like Graphviz.

---

### **Section B: Advanced Lifecycle Control (Questions 6-10)**

### **Question 6** (5 points)
Which lifecycle rule ensures that a new resource is created before the old one is destroyed?

A) `prevent_destroy = true`  
B) `create_before_destroy = true`  
C) `ignore_changes = [all]`  
D) `replace_triggered_by = []`  

**Correct Answer**: B  
**Explanation**: The `create_before_destroy = true` lifecycle rule ensures zero-downtime deployments by creating the new resource before destroying the old one.

---

### **Question 7** (5 points)
What is the primary use case for the `ignore_changes` lifecycle rule?

A) To prevent resource destruction  
B) To ignore changes made by external systems  
C) To force resource replacement  
D) To improve deployment performance  

**Correct Answer**: B  
**Explanation**: The `ignore_changes` rule tells Terraform to ignore changes to specific attributes that may be modified by external systems or processes.

---

### **Question 8** (5 points)
Which lifecycle rule provides the strongest protection against accidental resource deletion?

A) `create_before_destroy = true`  
B) `ignore_changes = [all]`  
C) `prevent_destroy = true`  
D) `replace_triggered_by = []`  

**Correct Answer**: C  
**Explanation**: The `prevent_destroy = true` rule provides the strongest protection by completely preventing Terraform from destroying the resource.

---

### **Question 9** (5 points)
What does the `replace_triggered_by` lifecycle rule accomplish?

A) Prevents resource replacement  
B) Triggers resource replacement based on changes to other resources  
C) Ignores replacement triggers  
D) Optimizes replacement performance  

**Correct Answer**: B  
**Explanation**: The `replace_triggered_by` rule triggers resource replacement when specified resources or attributes change.

---

### **Question 10** (5 points)
In which scenario would you use `create_before_destroy = true`?

A) For resources that can tolerate downtime  
B) For resources that require zero-downtime updates  
C) For resources that should never be updated  
D) For resources that are expensive to create  

**Correct Answer**: B  
**Explanation**: `create_before_destroy = true` is used for resources that require zero-downtime updates, such as load balancers or critical application components.

---

### **Section C: Meta-Argument Mastery (Questions 11-15)**

### **Question 11** (5 points)
What is the key advantage of using `for_each` over `count` for creating multiple resources?

A) `for_each` is faster than `count`  
B) `for_each` provides more stable resource addresses when the collection changes  
C) `for_each` uses less memory than `count`  
D) `for_each` supports more resource types than `count`  

**Correct Answer**: B  
**Explanation**: `for_each` provides more stable resource addresses because resources are identified by their key rather than their index position.

---

### **Question 12** (5 points)
How do you reference the current key and value in a `for_each` loop?

A) `count.index` and `count.value`  
B) `each.key` and `each.value`  
C) `for.key` and `for.value`  
D) `item.key` and `item.value`  

**Correct Answer**: B  
**Explanation**: In `for_each` loops, `each.key` provides the current key and `each.value` provides the current value from the map or set.

---

### **Question 13** (5 points)
Which data types can be used with the `for_each` meta-argument?

A) Lists and tuples only  
B) Maps and sets only  
C) Strings and numbers only  
D) All primitive types  

**Correct Answer**: B  
**Explanation**: The `for_each` meta-argument can only be used with maps and sets, not with lists or primitive types.

---

### **Question 14** (5 points)
What happens when you use `count = 0` on a resource?

A) Terraform creates one instance of the resource  
B) Terraform creates no instances of the resource  
C) Terraform throws an error  
D) Terraform ignores the resource  

**Correct Answer**: B  
**Explanation**: When `count = 0`, Terraform creates no instances of the resource, effectively disabling it conditionally.

---

### **Question 15** (5 points)
Which meta-argument allows you to specify a different provider configuration for a resource?

A) `depends_on`  
B) `lifecycle`  
C) `provider`  
D) `for_each`  

**Correct Answer**: C  
**Explanation**: The `provider` meta-argument allows you to specify which provider configuration to use for a particular resource.

---

### **Section D: Resource Targeting and Troubleshooting (Questions 16-20)**

### **Question 16** (5 points)
Which command applies changes to only a specific resource?

A) `terraform apply -resource=aws_instance.web`  
B) `terraform apply -target=aws_instance.web`  
C) `terraform apply -only=aws_instance.web`  
D) `terraform apply -select=aws_instance.web`  

**Correct Answer**: B  
**Explanation**: The `-target` flag allows you to apply changes to only specific resources and their dependencies.

---

### **Question 17** (5 points)
What is a potential risk of using resource targeting in production?

A) It may create incomplete infrastructure  
B) It always causes data loss  
C) It prevents future deployments  
D) It increases costs significantly  

**Correct Answer**: A  
**Explanation**: Resource targeting can create incomplete infrastructure if dependencies are not properly considered, potentially leading to broken deployments.

---

### **Question 18** (5 points)
Which command forces replacement of a specific resource?

A) `terraform apply -replace=aws_instance.web`  
B) `terraform apply -recreate=aws_instance.web`  
C) `terraform apply -force=aws_instance.web`  
D) `terraform apply -refresh=aws_instance.web`  

**Correct Answer**: A  
**Explanation**: The `-replace` flag forces Terraform to destroy and recreate the specified resource during the next apply.

---

### **Question 19** (5 points)
What is the primary purpose of the `terraform refresh` command?

A) To update the configuration files  
B) To sync the state file with actual infrastructure  
C) To restart failed resources  
D) To optimize resource performance  

**Correct Answer**: B  
**Explanation**: The `terraform refresh` command updates the state file to match the current state of the actual infrastructure.

---

### **Question 20** (5 points)
Which approach is recommended for resolving circular dependencies?

A) Use more explicit dependencies  
B) Break the circular dependency by restructuring resources  
C) Ignore the circular dependency  
D) Use random delays between resource creation  

**Correct Answer**: B  
**Explanation**: The recommended approach is to break circular dependencies by restructuring resources, often by separating them into different resources or using intermediate resources.

---

## 🎭 **Scenario-Based Challenges (5 Scenarios - 8 points each)**

### **Scenario 1: Complex Multi-Tier Dependency Management** (8 points)
Your team is deploying a financial services platform with strict dependency requirements. The database must be fully operational before any application servers start, and the load balancer must be configured before traffic routing begins.

**Required Elements:**
- Database with lifecycle protection
- Application servers with explicit database dependency
- Load balancer with proper target group configuration
- Zero-downtime deployment strategy

**Sample Solution:**
```hcl
resource "aws_db_instance" "main" {
  # ... database configuration ...
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  # ... ASG configuration ...
  
  depends_on = [
    aws_db_instance.main,
    aws_lb_target_group.app
  ]
  
  lifecycle {
    create_before_destroy = true
  }
}
```

### **Scenario 2: Advanced Lifecycle Management for Production** (8 points)
Implement a production database deployment that prevents accidental destruction, ignores external tag changes, and supports blue-green deployment patterns.

**Required Elements:**
- Database with destruction protection
- Ignore changes for externally managed attributes
- Blue-green deployment capability
- Backup and recovery configuration

### **Scenario 3: Dynamic Resource Creation with Complex Dependencies** (8 points)
Create a multi-application deployment where each application has different dependencies, scaling requirements, and security configurations using advanced meta-arguments.

**Required Elements:**
- for_each implementation for multiple applications
- Dynamic security group assignments
- Conditional resource creation based on application requirements
- Complex dependency resolution

### **Scenario 4: Resource Targeting for Production Hotfix** (8 points)
Design a strategy for deploying an emergency security patch to production API servers without affecting other infrastructure components.

**Required Elements:**
- Targeted deployment strategy
- Dependency impact analysis
- Rollback plan
- Monitoring and validation approach

### **Scenario 5: Dependency Troubleshooting and Resolution** (8 points)
Diagnose and resolve a complex dependency issue where circular dependencies are preventing deployment and some resources are failing due to timing issues.

**Required Elements:**
- Circular dependency identification
- Resolution strategy implementation
- Timing issue mitigation
- Prevention measures for future deployments

---

## 🛠️ **Hands-On Exercises (3 Exercises - 15 points each)**

### **Exercise 1: Complete Dependency Graph Implementation** (15 points)
Implement a comprehensive multi-tier infrastructure with complex dependency relationships.

**Tasks:**
1. Create VPC with multi-AZ subnets using count
2. Implement security groups with cross-references using for_each
3. Deploy database with explicit dependencies and lifecycle protection
4. Create application tiers with complex dependency chains
5. Generate and analyze dependency graph

**Evaluation Criteria:**
- Correct implicit dependency implementation (3 points)
- Proper explicit dependency usage (3 points)
- Advanced lifecycle management (3 points)
- Meta-argument implementation (3 points)
- Dependency graph analysis (3 points)

### **Exercise 2: Advanced Lifecycle and Meta-Argument Patterns** (15 points)
Demonstrate mastery of lifecycle management and meta-arguments in complex scenarios.

**Tasks:**
1. Implement zero-downtime deployment with create_before_destroy
2. Configure database with comprehensive lifecycle protection
3. Use for_each for dynamic application deployment
4. Implement conditional resources with feature flags
5. Demonstrate replace_triggered_by functionality

**Evaluation Criteria:**
- Zero-downtime deployment implementation (4 points)
- Lifecycle protection configuration (3 points)
- for_each implementation complexity (3 points)
- Conditional resource logic (3 points)
- Advanced lifecycle patterns (2 points)

### **Exercise 3: Resource Targeting and Troubleshooting Mastery** (15 points)
Master resource targeting strategies and dependency troubleshooting techniques.

**Tasks:**
1. Implement selective deployment using resource targeting
2. Demonstrate rolling update with targeted operations
3. Resolve simulated circular dependency issues
4. Implement dependency troubleshooting procedures
5. Create production deployment strategy

**Evaluation Criteria:**
- Resource targeting accuracy (3 points)
- Rolling update implementation (3 points)
- Circular dependency resolution (3 points)
- Troubleshooting methodology (3 points)
- Production deployment strategy (3 points)

---

## 📊 **Assessment Scoring**

### **Scoring Rubric**
- **90-100 points**: Excellent - Comprehensive mastery of advanced resource management
- **80-89 points**: Good - Strong understanding with minor gaps in complex scenarios
- **70-79 points**: Satisfactory - Basic competency with some weaknesses in advanced patterns
- **60-69 points**: Needs Improvement - Significant knowledge gaps requiring additional training
- **Below 60 points**: Unsatisfactory - Major deficiencies requiring comprehensive review

### **Detailed Scoring Breakdown**
- **Multiple Choice (100 points)**: 5 points per question, 20 questions
- **Scenarios (40 points)**: 8 points per scenario, 5 scenarios
- **Hands-On (45 points)**: 15 points per exercise, 3 exercises
- **Total Possible**: 185 points

---

## 🎯 **Answer Key and Explanations**

### **Multiple Choice Answers**
1. B - Implicit dependency  2. B - Create explicit dependencies  3. C - Topological sort  4. B - Fails with error  5. C - terraform graph
6. B - create_before_destroy = true  7. B - Ignore external changes  8. C - prevent_destroy = true  9. B - Triggers replacement  10. B - Zero-downtime updates
11. B - More stable addresses  12. B - each.key and each.value  13. B - Maps and sets only  14. B - Creates no instances  15. C - provider
16. B - terraform apply -target  17. A - Incomplete infrastructure  18. A - terraform apply -replace  19. B - Sync state with infrastructure  20. B - Break circular dependency

### **Key Learning Points**
- **Dependency Management**: Understanding implicit vs explicit dependencies and proper graph construction
- **Lifecycle Control**: Mastering advanced lifecycle patterns for production deployments
- **Meta-Arguments**: Effective use of for_each, count, and other meta-arguments in complex scenarios
- **Resource Targeting**: Strategic use of targeting for efficient operations and troubleshooting
- **Troubleshooting**: Systematic approach to dependency issue resolution and prevention

---

*This comprehensive assessment validates advanced mastery of resource management and dependency patterns, ensuring readiness for enterprise-scale infrastructure management and complex deployment scenarios.*
