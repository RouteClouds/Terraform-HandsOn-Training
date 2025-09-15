# Test Your Understanding - Topic 3: Core Terraform Operations

## 🎯 **Assessment Overview**

This comprehensive assessment evaluates your understanding of Terraform's core workflow operations, resource lifecycle management, dependency handling, performance optimization, and error recovery strategies.

**Duration**: 75 minutes  
**Total Points**: 100 points  
**Passing Score**: 80 points  
**Format**: Multiple choice, scenario-based questions, and hands-on exercises

---

## 📋 **Section A: Multiple Choice Questions (40 points)**
*Choose the best answer for each question. Each question is worth 2 points.*

### **Question 1: Core Terraform Workflow**
What is the correct order of Terraform's core workflow operations?

A) plan → init → apply → destroy  
B) init → validate → plan → apply  
C) init → plan → apply → destroy  
D) validate → init → plan → apply  

**Correct Answer**: B  
**Explanation**: The proper workflow is init (setup), validate (check syntax), plan (preview changes), then apply (execute changes).

---

### **Question 2: terraform init Purpose**
Which of the following is NOT performed during `terraform init`?

A) Download required providers  
B) Initialize backend configuration  
C) Create execution plan  
D) Set up the .terraform directory  

**Correct Answer**: C  
**Explanation**: terraform init sets up the environment but does not create execution plans - that's done by terraform plan.

---

### **Question 3: Resource Lifecycle Meta-Arguments**
Which meta-argument prevents a resource from being destroyed accidentally?

A) `create_before_destroy = true`  
B) `prevent_destroy = true`  
C) `ignore_changes = []`  
D) `replace_triggered_by = []`  

**Correct Answer**: B  
**Explanation**: prevent_destroy = true in a lifecycle block prevents Terraform from destroying the resource.

---

### **Question 4: Implicit Dependencies**
How does Terraform automatically detect dependencies between resources?

A) Through resource naming conventions  
B) Through resource references in configuration  
C) Through explicit depends_on declarations  
D) Through provider configuration  

**Correct Answer**: B  
**Explanation**: Terraform detects implicit dependencies when one resource references attributes of another resource.

---

### **Question 5: terraform plan Exit Codes**
When using `terraform plan -detailed-exitcode`, what does exit code 2 indicate?

A) Error occurred  
B) No changes needed  
C) Changes are present  
D) Plan saved successfully  

**Correct Answer**: C  
**Explanation**: Exit code 2 indicates that changes are present in the plan, useful for automation and CI/CD.

---

### **Question 6: Resource Targeting**
What is the primary use case for `terraform apply -target=resource`?

A) Performance optimization  
B) Debugging and selective deployment  
C) Cost reduction  
D) Security enhancement  

**Correct Answer**: B  
**Explanation**: Resource targeting is primarily used for debugging, testing, and selective deployment of specific resources.

---

### **Question 7: State Refresh**
When does Terraform automatically refresh the state?

A) During terraform init  
B) During terraform plan and apply  
C) During terraform destroy only  
D) Never automatically  

**Correct Answer**: B  
**Explanation**: Terraform automatically refreshes state during plan and apply operations to detect drift.

---

### **Question 8: count vs for_each**
What is the main advantage of using `for_each` over `count` for creating multiple resources?

A) Better performance  
B) Lower cost  
C) Stable resource addresses  
D) Simpler syntax  

**Correct Answer**: C  
**Explanation**: for_each provides stable resource addresses that don't change when items are added/removed from the middle.

---

### **Question 9: Parallelism Control**
What is the default parallelism level for Terraform operations?

A) 5  
B) 10  
C) 15  
D) 20  

**Correct Answer**: B  
**Explanation**: Terraform's default parallelism is 10 concurrent operations.

---

### **Question 10: Error Recovery**
Which command should be used to unlock a stuck Terraform state?

A) `terraform refresh`  
B) `terraform force-unlock LOCK_ID`  
C) `terraform state rm`  
D) `terraform import`  

**Correct Answer**: B  
**Explanation**: terraform force-unlock with the lock ID is used to manually release a stuck state lock.

---

### **Questions 11-20: Advanced Concepts**

**Question 11**: Which lifecycle argument creates a new resource before destroying the old one?
A) prevent_destroy  B) create_before_destroy  C) ignore_changes  D) replace_triggered_by  
**Answer**: B

**Question 12**: What happens when you run `terraform apply` without a saved plan?
A) Error occurs  B) Automatically creates plan  C) Uses last plan  D) Prompts for plan file  
**Answer**: B

**Question 13**: Which command shows the dependency graph in DOT format?
A) terraform graph  B) terraform show  C) terraform state list  D) terraform providers  
**Answer**: A

**Question 14**: What is the purpose of the `depends_on` meta-argument?
A) Performance optimization  B) Explicit dependencies  C) Resource ordering  D) Both B and C  
**Answer**: D

**Question 15**: Which operation does NOT modify the Terraform state?
A) terraform apply  B) terraform import  C) terraform plan  D) terraform refresh  
**Answer**: C

**Question 16**: What does `terraform validate` check?
A) AWS permissions  B) Configuration syntax  C) Resource state  D) Provider versions  
**Answer**: B

**Question 17**: Which meta-argument allows ignoring changes to specific attributes?
A) prevent_destroy  B) create_before_destroy  C) ignore_changes  D) replace_triggered_by  
**Answer**: C

**Question 18**: What is the recommended approach for handling sensitive values in Terraform?
A) Environment variables  B) Encrypted files  C) Variable files  D) All of the above  
**Answer**: D

**Question 19**: Which command removes a resource from state without destroying it?
A) terraform destroy  B) terraform state rm  C) terraform delete  D) terraform remove  
**Answer**: B

**Question 20**: What triggers a resource replacement in Terraform?
A) Changing immutable attributes  B) Force replacement  C) replace_triggered_by  D) All of the above  
**Answer**: D

---

## 🎯 **Section B: Scenario-Based Questions (30 points)**
*Analyze the scenarios and provide the best solutions. Each question is worth 10 points.*

### **Scenario 1: Resource Lifecycle Management Challenge (10 points)**

**Situation**: A development team needs to update their web application infrastructure. They have 5 EC2 instances running critical applications and need to upgrade the instance type from t3.micro to t3.small. However, they cannot afford any downtime during the upgrade process.

**Current Configuration**:
```hcl
resource "aws_instance" "web" {
  count         = 5
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "WebServer-${count.index + 1}"
  }
}
```

**Requirements**:
- Zero downtime during upgrade
- Maintain application availability
- Ensure proper dependency management
- Handle potential rollback scenarios

**Question**: Design a comprehensive lifecycle management strategy to safely upgrade the instances.

**Expected Answer Components**:
- Use of create_before_destroy lifecycle rule
- Load balancer integration for traffic management
- Rolling update strategy implementation
- Health check configuration
- Rollback procedures and state management
- Testing and validation approaches

---

### **Scenario 2: Complex Dependency Management (10 points)**

**Situation**: An enterprise application requires a complex multi-tier architecture with specific deployment ordering. The infrastructure includes VPC, subnets, security groups, RDS database, ElastiCache cluster, EC2 instances, and an Application Load Balancer. Some dependencies are not automatically detected by Terraform.

**Deployment Requirements**:
1. VPC and networking must be created first
2. Database and cache must be available before application servers
3. Application servers must be healthy before load balancer configuration
4. Specific security group rules depend on external services
5. Some resources have circular dependency issues

**Question**: Design a dependency management strategy that ensures proper resource ordering and handles complex dependencies.

**Expected Answer Components**:
- Implicit dependency identification and usage
- Explicit depends_on configuration where needed
- Resource targeting strategy for phased deployment
- Circular dependency resolution techniques
- Dependency graph analysis and optimization
- Error handling for dependency failures

---

### **Scenario 3: Performance Optimization and Error Recovery (10 points)**

**Situation**: A large infrastructure deployment with 200+ resources is experiencing performance issues and occasional failures. The team needs to optimize deployment time, handle partial failures gracefully, and implement robust error recovery procedures.

**Current Issues**:
- Terraform apply takes 45+ minutes to complete
- Frequent timeout errors with AWS API rate limits
- Partial apply failures leave infrastructure in inconsistent state
- State lock conflicts during team collaboration
- Difficulty troubleshooting specific resource failures

**Question**: Design a comprehensive performance optimization and error recovery strategy.

**Expected Answer Components**:
- Parallelism optimization and tuning
- Resource targeting for faster deployments
- Provider caching and performance improvements
- Error handling and retry strategies
- State management and backup procedures
- Team collaboration and state locking solutions
- Monitoring and alerting for deployment issues

---

## 🛠️ **Section C: Hands-On Practical Exercises (30 points)**
*Complete the following practical tasks. Each exercise is worth 10 points.*

### **Exercise 1: Core Workflow Mastery (10 points)**

**Task**: Implement a complete Terraform workflow demonstrating all core operations with proper error handling and optimization.

**Requirements**:
1. Create a multi-tier web application infrastructure
2. Implement proper resource lifecycle management
3. Demonstrate dependency management (both implicit and explicit)
4. Show performance optimization techniques
5. Handle error scenarios and recovery procedures

**Deliverables**:
- Complete Terraform configuration with all core resources
- Documentation of workflow steps and commands used
- Performance optimization implementation
- Error handling and recovery procedures
- Validation and testing results

**Evaluation Criteria**:
- Workflow implementation (3 points)
- Resource lifecycle management (3 points)
- Performance optimization (2 points)
- Error handling (2 points)

---

### **Exercise 2: Advanced Dependency and Lifecycle Management (10 points)**

**Task**: Create a complex infrastructure with advanced dependency patterns and lifecycle management.

**Requirements**:
1. Implement resources with circular dependency challenges
2. Use all lifecycle meta-arguments appropriately
3. Create both implicit and explicit dependencies
4. Implement rolling updates with zero downtime
5. Handle resource replacement scenarios

**Deliverables**:
- Infrastructure with complex dependency patterns
- Lifecycle management configuration
- Dependency graph visualization
- Rolling update implementation
- Testing and validation procedures

**Evaluation Criteria**:
- Dependency management (3 points)
- Lifecycle configuration (3 points)
- Rolling update implementation (2 points)
- Testing and documentation (2 points)

---

### **Exercise 3: Performance Optimization and Troubleshooting (10 points)**

**Task**: Optimize a large-scale Terraform deployment and implement comprehensive troubleshooting procedures.

**Requirements**:
1. Optimize deployment performance for 50+ resources
2. Implement resource targeting strategies
3. Configure provider caching and parallelism
4. Create troubleshooting and debugging procedures
5. Implement monitoring and alerting for deployments

**Deliverables**:
- Performance-optimized Terraform configuration
- Resource targeting implementation
- Troubleshooting documentation and procedures
- Performance benchmarking results
- Monitoring and alerting setup

**Evaluation Criteria**:
- Performance optimization (3 points)
- Resource targeting (2 points)
- Troubleshooting procedures (3 points)
- Monitoring implementation (2 points)

---

## 📊 **Assessment Scoring Guide**

### **Scoring Breakdown**
- **Section A (Multiple Choice)**: 40 points (2 points each)
- **Section B (Scenarios)**: 30 points (10 points each)
- **Section C (Hands-On)**: 30 points (10 points each)
- **Total**: 100 points

### **Grade Scale**
- **90-100 points**: Excellent (A) - Advanced mastery of core operations
- **80-89 points**: Good (B) - Proficient understanding with minor gaps
- **70-79 points**: Satisfactory (C) - Basic competency with some weaknesses
- **60-69 points**: Needs Improvement (D) - Requires additional study and practice
- **Below 60 points**: Unsatisfactory (F) - Significant knowledge gaps requiring remediation

### **Remediation Recommendations**

**For scores below 80 points**:
1. Review Terraform core workflow documentation and practice all operations
2. Complete additional hands-on labs focusing on resource lifecycle management
3. Study dependency management patterns and practice with complex scenarios
4. Gain experience with performance optimization and troubleshooting techniques
5. Practice error recovery procedures and state management operations

---

## 🎯 **Learning Objectives Assessment**

Upon successful completion of this assessment, you demonstrate:

- ✅ **Comprehensive mastery** of Terraform's core workflow operations
- ✅ **Advanced skills** in resource lifecycle management and dependency handling
- ✅ **Performance optimization** expertise for large-scale deployments
- ✅ **Error recovery** and troubleshooting capabilities
- ✅ **Enterprise workflow** patterns and best practices
- ✅ **Practical application** of core operations in real-world scenarios

---

## 📚 **Additional Study Resources**

### **For Further Learning**
- [Terraform Core Workflow](https://developer.hashicorp.com/terraform/intro/core-workflow)
- [Resource Lifecycle](https://developer.hashicorp.com/terraform/language/resources/behavior)
- [Terraform State Management](https://developer.hashicorp.com/terraform/language/state)
- [Performance Optimization Guide](https://developer.hashicorp.com/terraform/internals/debugging)

### **Practice Labs**
- Complete Lab 3.2: Advanced Resource Management
- Explore Lab 4.1: Resource Dependencies and Data Sources
- Practice Lab 5.1: Variables and Outputs Management

---

**Assessment Version**: 3.0  
**Last Updated**: January 2025  
**Aligned with**: Terraform ~> 1.13.0, AWS Provider ~> 6.12.0  
**Review Date**: Quarterly updates recommended
