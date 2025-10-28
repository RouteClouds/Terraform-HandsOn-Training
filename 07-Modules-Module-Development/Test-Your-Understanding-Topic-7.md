# Test Your Understanding: Topic 7 - Modules and Module Development

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your mastery of **Terraform module development, composition, and enterprise governance**. The test covers module design patterns, testing strategies, registry management, and advanced governance frameworks.

**Assessment Details:**
- **Duration**: 90 minutes
- **Total Points**: 112 points
- **Passing Score**: 90 points (80%)
- **Question Types**: Multiple choice, scenario-based, hands-on exercises
- **Difficulty**: Intermediate to Advanced

---

## 📚 **Section 1: Multiple Choice Questions (37 points)**

### **Question 1** (3 points)
What is the recommended file structure for a Terraform module?

A) `main.tf`, `variables.tf`, `outputs.tf`  
B) `main.tf`, `vars.tf`, `output.tf`, `README.md`  
C) `main.tf`, `variables.tf`, `outputs.tf`, `README.md`  
D) `module.tf`, `inputs.tf`, `outputs.tf`  

**Answer**: C) `main.tf`, `variables.tf`, `outputs.tf`, `README.md`

**Explanation**: The standard module structure includes main.tf for resources, variables.tf for inputs, outputs.tf for outputs, and README.md for documentation.

---

### **Question 2** (4 points)
Which of the following is the correct way to reference a module output in another resource?

A) `module.vpc.vpc_id`  
B) `${module.vpc.vpc_id}`  
C) `module.vpc.outputs.vpc_id`  
D) `output.vpc.vpc_id`  

**Answer**: A) `module.vpc.vpc_id`

**Explanation**: Module outputs are referenced using the syntax `module.<module_name>.<output_name>` without additional syntax.

---

### **Question 3** (4 points)
What is the purpose of the `source` argument in a module block?

A) To specify the module's output location  
B) To define where Terraform should find the module code  
C) To set the module's version number  
D) To configure the module's provider  

**Answer**: B) To define where Terraform should find the module code

**Explanation**: The `source` argument tells Terraform where to find the module code, whether local, Git, registry, or other sources.

---

### **Question 4** (4 points)
Which versioning strategy is recommended for Terraform modules?

A) Date-based versioning (YYYY.MM.DD)  
B) Semantic versioning (MAJOR.MINOR.PATCH)  
C) Sequential numbering (v1, v2, v3)  
D) Git commit hashes  

**Answer**: B) Semantic versioning (MAJOR.MINOR.PATCH)

**Explanation**: Semantic versioning provides clear communication about the nature of changes and compatibility between versions.

---

### **Question 5** (3 points)
What is the primary benefit of using modules in Terraform?

A) Faster execution time  
B) Reduced file size  
C) Code reusability and standardization  
D) Better error messages  

**Answer**: C) Code reusability and standardization

**Explanation**: Modules enable code reuse, standardization, and maintainability across different environments and projects.

---

### **Question 6** (4 points)
How should sensitive values be handled in module variables?

A) Mark variables as `sensitive = true`  
B) Encrypt values in the module code  
C) Store values in comments  
D) Use environment variables only  

**Answer**: A) Mark variables as `sensitive = true`

**Explanation**: The `sensitive = true` attribute prevents sensitive values from being displayed in logs and console output.

---

### **Question 7** (3 points)
What is the correct way to specify a module version from the Terraform Registry?

A) `version = "1.0.0"`  
B) `source = "terraform-aws-modules/vpc/aws@1.0.0"`  
C) `source = "terraform-aws-modules/vpc/aws" version = "1.0.0"`  
D) `module_version = "1.0.0"`  

**Answer**: C) `source = "terraform-aws-modules/vpc/aws" version = "1.0.0"`

**Explanation**: The version is specified as a separate argument alongside the source when using registry modules.

---

### **Question 8** (4 points)
What is the required naming convention for modules published to the HCP Terraform Private Module Registry?

A) `module-<PROVIDER>-<NAME>`
B) `terraform-<PROVIDER>-<NAME>`
C) `<NAME>-terraform-<PROVIDER>`
D) Any naming convention is acceptable

**Answer**: B) `terraform-<PROVIDER>-<NAME>`

**Explanation**: HCP Terraform requires modules to follow the naming convention `terraform-<PROVIDER>-<NAME>` (e.g., `terraform-aws-vpc`) for automatic detection and publishing to the private registry.

---

### **Question 9** (4 points)
Which authentication method is recommended for consuming modules from the HCP Terraform Private Module Registry in CI/CD pipelines?

A) Username and password
B) SSH keys
C) Environment variable with API token (`TF_TOKEN_app_terraform_io`)
D) OAuth tokens

**Answer**: C) Environment variable with API token (`TF_TOKEN_app_terraform_io`)

**Explanation**: For CI/CD pipelines, using an environment variable with an API token is the most secure and automated method. The token can be stored in the CI/CD system's secret management.

---

### **Question 10** (4 points)
What is the recommended version constraint operator for consuming modules from a private registry in production?

A) `version = "1.0.0"` (exact version)
B) `version = "~> 1.0"` (pessimistic constraint)
C) `version = ">= 1.0.0"` (minimum version)
D) No version constraint (always use latest)

**Answer**: B) `version = "~> 1.0"` (pessimistic constraint)

**Explanation**: The pessimistic constraint operator `~>` allows patch and minor version updates while preventing breaking changes from major version updates. For example, `~> 1.0` allows versions >= 1.0.0 and < 2.0.0, providing a balance between stability and receiving bug fixes.

---

## 🔧 **Section 2: Scenario-Based Questions (30 points)**

### **Scenario 1: Module Dependency Management** (10 points)

**Situation**: You're developing a web application infrastructure that requires a VPC, security groups, and EC2 instances. The security groups depend on the VPC, and the EC2 instances depend on both the VPC and security groups.

**Questions**:

**2.1** (3 points) How should you structure the module dependencies?
A) Create one large module with all resources  
B) Create separate modules and use implicit dependencies through outputs  
C) Use explicit `depends_on` for all modules  
D) Create modules without any dependencies  

**Answer**: B) Create separate modules and use implicit dependencies through outputs

**2.2** (4 points) What's the best way to pass the VPC ID from the VPC module to the security group module?
A) Use a data source to look up the VPC  
B) Hard-code the VPC ID  
C) Use the VPC module's output as input to the security group module  
D) Store the VPC ID in a variable file  

**Answer**: C) Use the VPC module's output as input to the security group module

**2.3** (3 points) How can you ensure the modules are applied in the correct order?
A) Use explicit `depends_on` statements  
B) Rely on Terraform's automatic dependency resolution through resource references  
C) Apply modules manually in sequence  
D) Use separate Terraform runs  

**Answer**: B) Rely on Terraform's automatic dependency resolution through resource references

---

### **Scenario 2: Module Testing Strategy** (10 points)

**Situation**: Your team is developing a complex RDS module that needs to be tested across multiple environments and configurations before being released to production teams.

**Questions**:

**2.4** (4 points) What testing levels should be implemented for the RDS module?
A) Unit tests only  
B) Integration tests only  
C) Unit, integration, and end-to-end tests  
D) Manual testing only  

**Answer**: C) Unit, integration, and end-to-end tests

**2.5** (3 points) Which tool is commonly used for automated Terraform module testing?
A) Jest  
B) Terratest  
C) Selenium  
D) JUnit  

**Answer**: B) Terratest

**2.6** (3 points) What should be included in unit tests for a Terraform module?
A) Syntax validation and variable validation  
B) Full infrastructure deployment  
C) Performance testing  
D) User interface testing  

**Answer**: A) Syntax validation and variable validation

---

### **Scenario 3: Module Registry Management** (10 points)

**Situation**: Your organization wants to establish a private module registry to share modules across multiple teams while maintaining version control and access management.

**Questions**:

**2.7** (4 points) What are the key components of a private module registry?
A) Storage, versioning, access control, and metadata  
B) Only storage and versioning  
C) Only access control  
D) Only metadata and documentation  

**Answer**: A) Storage, versioning, access control, and metadata

**2.8** (3 points) How should module versions be managed in the registry?
A) Overwrite existing versions  
B) Use immutable versions with semantic versioning  
C) Use only latest version  
D) Use date-based versions only  

**Answer**: B) Use immutable versions with semantic versioning

**2.9** (3 points) What information should be included in module metadata?
A) Only the module name  
B) Name, version, description, dependencies, and examples  
C) Only version and description  
D) Only dependencies  

**Answer**: B) Name, version, description, dependencies, and examples

---

## 💻 **Section 3: Hands-On Exercises (25 points)**

### **Exercise 1: Module Development** (10 points)

**Task**: Create a simple S3 bucket module with the following requirements:
- Configurable bucket name
- Optional versioning
- Optional encryption
- Proper tagging support

**Solution**:
```hcl
# variables.tf
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}

# main.tf
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = merge(
    {
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# outputs.tf
output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}
```

**Grading Criteria**:
- Proper variable definitions (3 points)
- Correct resource implementation (4 points)
- Appropriate outputs (2 points)
- Code structure and style (1 point)

---

### **Exercise 2: Module Composition** (8 points)

**Task**: Write a root module that uses the S3 bucket module from Exercise 1 to create two buckets: one for application data and one for logs.

**Solution**:
```hcl
module "app_data_bucket" {
  source = "./modules/s3-bucket"

  bucket_name       = "my-app-data-${random_id.suffix.hex}"
  enable_versioning = true
  enable_encryption = true

  tags = {
    Purpose     = "application-data"
    Environment = "production"
  }
}

module "logs_bucket" {
  source = "./modules/s3-bucket"

  bucket_name       = "my-app-logs-${random_id.suffix.hex}"
  enable_versioning = false
  enable_encryption = true

  tags = {
    Purpose     = "application-logs"
    Environment = "production"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "app_data_bucket_id" {
  value = module.app_data_bucket.bucket_id
}

output "logs_bucket_id" {
  value = module.logs_bucket.bucket_id
}
```

**Grading Criteria**:
- Correct module usage (3 points)
- Proper configuration differences (2 points)
- Appropriate naming strategy (2 points)
- Output definitions (1 point)

---

### **Exercise 3: Module Testing Script** (7 points)

**Task**: Write a bash script that validates a Terraform module by checking syntax, formatting, and running a plan.

**Solution**:
```bash
#!/bin/bash

MODULE_DIR=${1:-"./modules/s3-bucket"}
EXIT_CODE=0

echo "Testing Terraform module: $MODULE_DIR"
echo "======================================"

# Test 1: Syntax validation
echo "1. Testing syntax validation..."
cd "$MODULE_DIR"
if terraform validate; then
    echo "✅ Syntax validation passed"
else
    echo "❌ Syntax validation failed"
    EXIT_CODE=1
fi

# Test 2: Formatting check
echo "2. Testing formatting..."
if terraform fmt -check; then
    echo "✅ Formatting check passed"
else
    echo "❌ Formatting check failed"
    EXIT_CODE=1
fi

# Test 3: Security scan (if tfsec is available)
echo "3. Testing security scan..."
if command -v tfsec &> /dev/null; then
    if tfsec .; then
        echo "✅ Security scan passed"
    else
        echo "⚠️  Security scan found issues"
    fi
else
    echo "ℹ️  tfsec not available, skipping security scan"
fi

# Test 4: Plan test (requires example)
echo "4. Testing plan generation..."
cd - > /dev/null
if [ -d "examples/basic" ]; then
    cd "examples/basic"
    terraform init -backend=false
    if terraform plan; then
        echo "✅ Plan generation passed"
    else
        echo "❌ Plan generation failed"
        EXIT_CODE=1
    fi
    cd - > /dev/null
else
    echo "ℹ️  No example found, skipping plan test"
fi

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "🎉 All tests passed!"
else
    echo "❌ Some tests failed!"
fi

exit $EXIT_CODE
```

**Grading Criteria**:
- Syntax validation test (2 points)
- Formatting check (2 points)
- Security scanning integration (1 point)
- Plan generation test (1 point)
- Error handling and reporting (1 point)

---

## 🏗️ **Section 4: Advanced Scenarios (20 points)**

### **Scenario 4: Enterprise Module Governance** (10 points)

**Challenge**: Design a comprehensive module governance framework for a large enterprise with multiple teams, compliance requirements, and security standards.

**Required Components**:
1. **Module Standards** (3 points)
2. **Testing Requirements** (3 points)
3. **Security Controls** (2 points)
4. **Compliance Framework** (2 points)

**Sample Solution Framework**:

**Module Standards**:
- Standardized file structure (main.tf, variables.tf, outputs.tf, README.md)
- Semantic versioning for all modules
- Comprehensive variable validation
- Required documentation and examples

**Testing Requirements**:
- Unit tests for syntax and validation
- Integration tests for module composition
- Security scanning with tfsec/checkov
- Compliance testing with policy frameworks

**Security Controls**:
- Mandatory security scanning before publication
- Encrypted storage for sensitive modules
- Access control based on team membership
- Audit logging for all module operations

**Compliance Framework**:
- SOC 2 compliance for production modules
- GDPR compliance for data-handling modules
- Regular compliance audits and reporting
- Automated compliance checking in CI/CD

---

### **Scenario 5: Module Performance Optimization** (10 points)

**Challenge**: Optimize a complex module that creates a complete application stack but has performance and cost issues.

**Requirements**:
1. **Performance Analysis** (3 points)
2. **Optimization Strategy** (3 points)
3. **Cost Reduction** (2 points)
4. **Monitoring Implementation** (2 points)

**Sample Solution**:

**Performance Analysis**:
- Identify resource creation bottlenecks
- Analyze dependency chains and parallelization opportunities
- Review provider API rate limits and optimization
- Measure plan and apply execution times

**Optimization Strategy**:
- Implement conditional resource creation
- Use data sources instead of resource lookups where appropriate
- Optimize module composition to reduce dependency depth
- Implement resource lifecycle management

**Cost Reduction**:
- Right-size resources based on environment
- Implement auto-scaling and scheduling
- Use spot instances for non-critical workloads
- Implement lifecycle policies for storage resources

**Monitoring Implementation**:
- CloudWatch metrics for resource utilization
- Cost monitoring and alerting
- Performance dashboards for module usage
- Automated reporting for optimization opportunities

---

## 📊 **Assessment Scoring Guide**

### **Scoring Breakdown**
- **Section 1 (Multiple Choice)**: 25 points
- **Section 2 (Scenarios)**: 30 points  
- **Section 3 (Hands-On)**: 25 points
- **Section 4 (Advanced)**: 20 points
- **Total**: 100 points

### **Grade Scale**
- **90-100 points**: Expert Level (A)
- **80-89 points**: Proficient (B) - **Passing**
- **70-79 points**: Developing (C)
- **60-69 points**: Beginning (D)
- **Below 60 points**: Needs Improvement (F)

### **Competency Indicators**

**Expert Level (90-100)**:
- Demonstrates mastery of all module development concepts
- Can design enterprise-grade governance frameworks
- Shows deep understanding of testing and optimization
- Capable of leading module development initiatives

**Proficient (80-89)**:
- Solid understanding of module development fundamentals
- Can implement and troubleshoot common scenarios
- Understands testing and governance best practices
- Ready for production module development

**Developing (70-79)**:
- Basic understanding of module concepts
- Can perform routine module operations with guidance
- Needs additional practice with advanced scenarios
- Requires mentoring for complex module development

---

## 🎯 **Next Steps Based on Results**

### **For Expert Level Achievers**:
- Lead module development initiatives in your organization
- Mentor other team members on module best practices
- Contribute to open-source module communities
- Design enterprise governance frameworks

### **For Proficient Achievers**:
- Implement learned concepts in production environments
- Practice advanced module patterns and compositions
- Study enterprise governance and compliance requirements
- Prepare for advanced Terraform certifications

### **For Developing Achievers**:
- Review fundamental module concepts
- Complete additional hands-on exercises
- Practice module testing and validation
- Seek mentoring from experienced module developers

## 🆕 **2025 Advanced Module Development Scenarios**

### **Scenario 9: Meta-Modules and Module Composition**
**Difficulty**: Expert
**Time**: 30 minutes

Your organization needs to create a meta-module that orchestrates multiple infrastructure modules to deploy complete application stacks.

**Requirements**:
- Design a meta-module that combines VPC, security, compute, and database modules
- Implement feature flags for conditional resource creation
- Create environment-specific configuration overrides
- Establish proper module dependency management

**Deliverables**:
- Meta-module structure with proper composition
- Feature flag implementation for conditional resources
- Environment-specific configuration system
- Module dependency and output chaining

**Evaluation Criteria**:
- Meta-module design and composition (4 points)
- Feature flag implementation (3 points)
- Environment configuration (2 points)
- Dependency management (1 point)

### **Scenario 10: Dynamic Module Configuration with Functions**
**Difficulty**: Expert
**Time**: 25 minutes

Implement dynamic module configuration that adapts module behavior based on environment and business requirements using Terraform functions.

**Requirements**:
- Create environment-specific configuration maps
- Implement dynamic module selection using for_each
- Build conditional module instantiation based on requirements
- Generate computed configurations using Terraform functions

**Deliverables**:
- Dynamic configuration system with environment maps
- for_each implementation for module selection
- Conditional module instantiation logic
- Function-based configuration computation

**Evaluation Criteria**:
- Dynamic configuration complexity (4 points)
- for_each implementation (3 points)
- Conditional logic (2 points)
- Function usage optimization (1 point)

### **Scenario 11: Advanced Module Testing and Validation Framework**
**Difficulty**: Advanced
**Time**: 25 minutes

Create a comprehensive testing framework for module validation including unit tests, integration tests, and automated validation.

**Requirements**:
- Implement unit testing for individual modules
- Create integration tests for module composition
- Set up automated validation and security scanning
- Establish performance and compliance testing

**Deliverables**:
- Unit testing framework implementation
- Integration testing suite
- Automated validation scripts
- Security and compliance testing integration

**Evaluation Criteria**:
- Testing framework completeness (3 points)
- Integration testing implementation (3 points)
- Automation and validation (2 points)
- Security and compliance integration (2 points)

### **Scenario 12: Enterprise Module Registry and Distribution**
**Difficulty**: Expert
**Time**: 20 minutes

Design and implement an enterprise module registry with versioning, metadata management, and automated distribution.

**Requirements**:
- Create private module registry infrastructure
- Implement module versioning and metadata management
- Set up automated module publishing workflows
- Establish module governance and access control

**Deliverables**:
- Module registry infrastructure (S3 + DynamoDB)
- Versioning and metadata management system
- Automated publishing and distribution workflows
- Governance and access control implementation

**Evaluation Criteria**:
- Registry infrastructure design (4 points)
- Versioning and metadata system (3 points)
- Automation workflows (2 points)
- Governance implementation (1 point)

## 📊 **Enhanced Assessment Summary**

### **Total Points**: 152 points
- **Core Module Development (1-10)**: 112 points
- **Advanced 2025 Patterns (9-12)**: 40 points

### **Grading Scale**:
- **Expert (137-152 points)**: Mastery of all patterns including cutting-edge features and Private Module Registry
- **Advanced (122-136 points)**: Strong understanding with minor gaps in advanced features
- **Intermediate (107-121 points)**: Good grasp of core concepts, needs practice with modern features
- **Beginner (91-106 points)**: Basic understanding, requires additional study
- **Needs Review (<91 points)**: Fundamental concepts need reinforcement

### **2025 Skills Validation**:
- ✅ **Core Module Development**: Structure, variables, outputs, versioning mastery
- ✅ **Advanced Composition**: Meta-modules and complex module orchestration
- ✅ **Dynamic Configuration**: Function-based and environment-specific behavior
- ✅ **Testing Excellence**: Comprehensive testing frameworks and automation
- ✅ **Registry Management**: Enterprise module distribution and governance
- ✅ **Private Module Registry**: HCP Terraform registry publishing and consumption
- ✅ **Security Integration**: Security scanning and compliance validation
- ✅ **Performance Optimization**: Module performance and scalability patterns
- ✅ **Modern Features**: Latest Terraform 1.13 and AWS provider capabilities

### **Key Learning Outcomes**:
1. **Module Design Mastery** - Complete understanding of module architecture and patterns
2. **Composition Excellence** - Advanced module composition and orchestration
3. **Testing Proficiency** - Comprehensive testing strategies and automation
4. **Registry Management** - Enterprise module distribution and governance
5. **Private Module Registry** - HCP Terraform registry publishing, versioning, and consumption
6. **Security Integration** - Security scanning and compliance frameworks
7. **Performance Optimization** - Module performance and scalability
8. **Version Management** - Semantic versioning and lifecycle management
9. **🆕 Meta-Module Patterns** - Complex application stack orchestration
10. **🆕 Dynamic Configuration** - Function-based environment adaptation
11. **🆕 Enterprise Registry** - Advanced module distribution and governance

---

**Assessment Version**: 4.0
**Last Updated**: October 2025
**Terraform Version**: ~> 1.13.0
**AWS Provider Version**: ~> 6.12.0
**Estimated Completion Time**: 120 minutes
**🆕 2025 Features**: Meta-Modules, Dynamic Configuration, Advanced Testing, Enterprise Registry, Private Module Registry
