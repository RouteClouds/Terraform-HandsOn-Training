# Test Your Understanding: Topic 3 - Core Terraform Operations

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your mastery of core Terraform operations including resource lifecycle management, data sources, provisioners, meta-arguments, and enterprise resource organization. The test combines multiple-choice questions, scenario-based challenges, and hands-on exercises to validate practical understanding and implementation skills.

### **Learning Objectives Assessed**
1. **Resource Lifecycle Management** (25 points): Resource creation, updates, destruction, and state management
2. **Data Source Integration** (20 points): AWS data sources, external data, and dynamic configuration
3. **Meta-Argument Mastery** (25 points): count, for_each, depends_on, and lifecycle rules
4. **Provisioner Implementation** (15 points): Local and remote provisioners, configuration management
5. **Enterprise Organization** (15 points): Resource organization, tagging, and governance patterns

### **Assessment Integration with Visual Learning**
This assessment directly references the professional diagrams created in the DaC implementation:
- **Figure 3.1**: Terraform Resource Lifecycle and Management (Questions 1-5)
- **Figure 3.2**: Data Sources and Resource Dependencies (Questions 6-10)
- **Figure 3.3**: Provisioners and Configuration Management (Questions 11-15)
- **Figure 3.4**: Resource Meta-Arguments and Lifecycle Rules (Questions 16-20)
- **Figure 3.5**: Enterprise Resource Organization (Scenario-based challenges)

### **Time Allocation**
- **Multiple Choice Questions**: 40 minutes (20 questions)
- **Scenario-Based Challenges**: 25 minutes (5 scenarios)
- **Hands-On Exercises**: 45 minutes (3 exercises)
- **Total Assessment Time**: 110 minutes

---

## 🎯 **Multiple Choice Questions (20 Questions - 5 points each)**

### **Section A: Resource Lifecycle Management (Questions 1-5)**

### **Question 1** (5 points)
Which Terraform command shows the differences between the current state and the desired configuration?

A) `terraform show`  
B) `terraform plan`  
C) `terraform apply`  
D) `terraform refresh`  

**Correct Answer**: B  
**Explanation**: `terraform plan` compares the current state with the desired configuration and shows what changes will be made.

---

### **Question 2** (5 points)
What happens when you run `terraform apply` without a saved plan file?

A) Terraform fails with an error  
B) Terraform automatically generates a new plan and applies it  
C) Terraform applies the last saved plan  
D) Terraform only validates the configuration  

**Correct Answer**: B  
**Explanation**: When no plan file is specified, Terraform generates a new plan and prompts for confirmation before applying.

---

### **Question 3** (5 points)
Which lifecycle rule prevents a resource from being destroyed accidentally?

A) `create_before_destroy = true`  
B) `prevent_destroy = true`  
C) `ignore_changes = [all]`  
D) `replace_triggered_by = []`  

**Correct Answer**: B  
**Explanation**: `prevent_destroy = true` blocks Terraform from destroying the resource, providing protection against accidental deletion.

---

### **Question 4** (5 points)
What is the correct order of resource lifecycle phases in Terraform?

A) Apply → Plan → Configure → State  
B) Configure → Plan → Apply → State  
C) Plan → Configure → Apply → State  
D) State → Configure → Plan → Apply  

**Correct Answer**: B  
**Explanation**: The correct order is Configure (write configuration), Plan (generate execution plan), Apply (execute changes), State (update state file).

---

### **Question 5** (5 points)
Which command removes a resource from Terraform state without destroying the actual infrastructure?

A) `terraform destroy -target=resource`  
B) `terraform state rm resource`  
C) `terraform untaint resource`  
D) `terraform import resource`  

**Correct Answer**: B  
**Explanation**: `terraform state rm` removes a resource from the state file without affecting the actual infrastructure.

---

### **Section B: Data Source Integration (Questions 6-10)**

### **Question 6** (5 points)
What is the primary difference between resources and data sources in Terraform?

A) Data sources are faster to execute  
B) Resources create infrastructure, data sources read existing information  
C) Data sources require authentication, resources don't  
D) Resources are deprecated, data sources are preferred  

**Correct Answer**: B  
**Explanation**: Resources create and manage infrastructure, while data sources read information from existing infrastructure or external systems.

---

### **Question 7** (5 points)
Which data source would you use to get the latest Amazon Linux AMI?

A) `data "aws_instance" "latest"`  
B) `data "aws_ami" "amazon_linux"`  
C) `data "aws_image" "latest"`  
D) `data "aws_ec2_ami" "amazon"`  

**Correct Answer**: B  
**Explanation**: `data "aws_ami"` is the correct data source for retrieving AMI information, including the latest Amazon Linux AMI.

---

### **Question 8** (5 points)
How do you reference the result of an external data source named "env_info"?

A) `external.env_info.result`  
B) `data.external.env_info.result`  
C) `data.external.env_info.output`  
D) `external.env_info.output`  

**Correct Answer**: B  
**Explanation**: External data source results are accessed using `data.external.<name>.result` syntax.

---

### **Question 9** (5 points)
Which data source provides information about available AWS availability zones?

A) `data "aws_regions" "available"`  
B) `data "aws_zones" "available"`  
C) `data "aws_availability_zones" "available"`  
D) `data "aws_azs" "available"`  

**Correct Answer**: C  
**Explanation**: `data "aws_availability_zones"` is the correct data source for retrieving availability zone information.

---

### **Question 10** (5 points)
What format must external data source programs return their output in?

A) YAML  
B) JSON  
C) XML  
D) Plain text  

**Correct Answer**: B  
**Explanation**: External data sources must return their output in valid JSON format for Terraform to parse.

---

### **Section C: Meta-Arguments and Advanced Control (Questions 11-15)**

### **Question 11** (5 points)
What is the key difference between `count` and `for_each` meta-arguments?

A) `count` is faster than `for_each`  
B) `count` uses numbers, `for_each` uses sets or maps  
C) `count` is deprecated, `for_each` is preferred  
D) `count` works with all resources, `for_each` doesn't  

**Correct Answer**: B  
**Explanation**: `count` creates instances based on a numeric value, while `for_each` creates instances based on sets or maps, providing more flexibility.

---

### **Question 12** (5 points)
How do you reference the second instance created with `count = 3`?

A) `resource_type.name[1]`  
B) `resource_type.name[2]`  
C) `resource_type.name.1`  
D) `resource_type.name.second`  

**Correct Answer**: A  
**Explanation**: With `count`, instances are zero-indexed, so the second instance (count.index = 1) is referenced as `[1]`.

---

### **Question 13** (5 points)
Which meta-argument creates explicit dependencies between resources?

A) `lifecycle`  
B) `provider`  
C) `depends_on`  
D) `for_each`  

**Correct Answer**: C  
**Explanation**: `depends_on` creates explicit dependencies when Terraform cannot automatically infer the relationship.

---

### **Question 14** (5 points)
What does `ignore_changes = [tags]` accomplish in a lifecycle block?

A) Prevents the resource from being created  
B) Ignores all changes to the resource  
C) Ignores changes to the tags attribute only  
D) Prevents the resource from being destroyed  

**Correct Answer**: C  
**Explanation**: `ignore_changes = [tags]` tells Terraform to ignore changes to the tags attribute, useful when external systems modify tags.

---

### **Question 15** (5 points)
When using `for_each` with a map, how do you access the current key and value?

A) `each.key` and `each.value`  
B) `for.key` and `for.value`  
C) `current.key` and `current.value`  
D) `item.key` and `item.value`  

**Correct Answer**: A  
**Explanation**: In `for_each` loops, `each.key` provides the current key and `each.value` provides the current value.

---

### **Section D: Provisioners and Enterprise Patterns (Questions 16-20)**

### **Question 16** (5 points)
Which provisioner executes commands on the machine running Terraform?

A) `remote-exec`  
B) `local-exec`  
C) `file`  
D) `shell`  

**Correct Answer**: B  
**Explanation**: The `local-exec` provisioner executes commands on the machine running Terraform, not on the remote resource.

---

### **Question 17** (5 points)
What is the recommended alternative to provisioners for EC2 instance configuration?

A) AWS Systems Manager  
B) User data scripts  
C) Configuration management tools  
D) All of the above  

**Correct Answer**: D  
**Explanation**: All options are recommended alternatives to provisioners, with user data being the most common for initial configuration.

---

### **Question 18** (5 points)
Which connection type is used for Windows instances with remote provisioners?

A) SSH  
B) RDP  
C) WinRM  
D) PowerShell  

**Correct Answer**: C  
**Explanation**: WinRM (Windows Remote Management) is the connection type used for Windows instances with remote provisioners.

---

### **Question 19** (5 points)
What is the primary purpose of resource tagging in enterprise environments?

A) Improving performance  
B) Cost allocation and governance  
C) Security enhancement  
D) Backup automation  

**Correct Answer**: B  
**Explanation**: Resource tagging is primarily used for cost allocation, governance, and organizational purposes in enterprise environments.

---

### **Question 20** (5 points)
Which naming convention is recommended for enterprise Terraform resources?

A) `{resource-type}-{random-id}`  
B) `{environment}-{project}-{resource}-{instance}`  
C) `{region}-{account}-{resource}`  
D) `{team}-{date}-{resource}`  

**Correct Answer**: B  
**Explanation**: The pattern `{environment}-{project}-{resource}-{instance}` provides clear identification and organization for enterprise resources.

---

## 🎭 **Scenario-Based Challenges (5 Scenarios - 6 points each)**

### **Scenario 1: Resource Lifecycle Management** (6 points)
Your team needs to update a critical database instance without downtime. The database has `prevent_destroy = true` and is referenced by multiple application servers.

**Required Elements:**
- Lifecycle rule modification strategy
- Zero-downtime update approach
- Dependency management

**Sample Solution:**
```hcl
# Create new database with create_before_destroy
resource "aws_db_instance" "main" {
  # ... configuration ...
  
  lifecycle {
    create_before_destroy = true
    # Temporarily remove prevent_destroy for update
    # prevent_destroy = true
  }
}

# Update application servers to use new database
resource "aws_instance" "app" {
  # ... configuration ...
  user_data = templatefile("app_config.sh", {
    db_endpoint = aws_db_instance.main.endpoint
  })
  
  depends_on = [aws_db_instance.main]
}
```

### **Scenario 2: Dynamic Infrastructure Scaling** (6 points)
Implement a solution that creates different numbers of instances based on environment using data sources and meta-arguments.

**Required Elements:**
- Environment detection using data sources
- Dynamic instance count calculation
- Proper resource distribution across AZs

### **Scenario 3: Multi-Provider Configuration** (6 points)
Configure resources across multiple AWS regions with proper provider aliases and data source integration.

**Required Elements:**
- Multiple provider configurations
- Cross-region data source usage
- Resource placement strategy

### **Scenario 4: Provisioner Error Handling** (6 points)
Design a robust provisioner configuration with error handling and retry logic for application deployment.

**Required Elements:**
- Connection configuration with timeouts
- Error handling strategies
- Idempotent provisioner scripts

### **Scenario 5: Enterprise Governance Implementation** (6 points)
Implement a comprehensive tagging and naming strategy for a multi-team, multi-environment organization.

**Required Elements:**
- Standardized naming conventions
- Comprehensive tagging strategy
- Cost allocation framework

---

## 🛠️ **Hands-On Exercises (3 Exercises - 10 points each)**

### **Exercise 1: Complete Resource Lifecycle** (10 points)
Implement a complete resource lifecycle scenario with proper state management.

**Tasks:**
1. Create VPC with subnets using count
2. Implement lifecycle rules for critical resources
3. Demonstrate state management operations
4. Perform controlled resource updates

### **Exercise 2: Data Source Integration** (10 points)
Build dynamic infrastructure using multiple data source types.

**Tasks:**
1. Use AWS data sources for AMI and AZ discovery
2. Implement external data source for environment info
3. Create HTTP data source integration
4. Build template-based configuration

### **Exercise 3: Meta-Argument Mastery** (10 points)
Demonstrate advanced meta-argument usage in complex scenarios.

**Tasks:**
1. Implement for_each with complex data structures
2. Create explicit dependencies with depends_on
3. Use lifecycle rules for production scenarios
4. Combine multiple meta-arguments effectively

---

## 📊 **Assessment Scoring**

### **Scoring Rubric**
- **90-100 points**: Excellent - Comprehensive mastery of core operations
- **80-89 points**: Good - Strong understanding with minor gaps
- **70-79 points**: Satisfactory - Basic competency with some weaknesses
- **60-69 points**: Needs Improvement - Significant knowledge gaps
- **Below 60 points**: Unsatisfactory - Major deficiencies requiring additional training

### **Detailed Scoring Breakdown**
- **Multiple Choice (100 points)**: 5 points per question, 20 questions
- **Scenarios (30 points)**: 6 points per scenario, 5 scenarios
- **Hands-On (30 points)**: 10 points per exercise, 3 exercises
- **Total Possible**: 160 points

---

## 🎯 **Answer Key and Explanations**

### **Multiple Choice Answers**
1. B - terraform plan  2. B - Generates new plan  3. B - prevent_destroy = true  4. B - Configure → Plan → Apply → State  5. B - terraform state rm
6. B - Resources create, data sources read  7. B - data "aws_ami"  8. B - data.external.env_info.result  9. C - aws_availability_zones  10. B - JSON
11. B - count uses numbers, for_each uses sets/maps  12. A - [1]  13. C - depends_on  14. C - Ignores tags only  15. A - each.key and each.value
16. B - local-exec  17. D - All of the above  18. C - WinRM  19. B - Cost allocation and governance  20. B - environment-project-resource-instance

---

*This comprehensive assessment validates practical mastery of core Terraform operations, ensuring readiness for advanced resource management and enterprise infrastructure deployment.*
