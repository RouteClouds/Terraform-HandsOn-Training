# Practice Test 7: Terraform Modules and Module Development

## 📋 **Test Information**
- **Duration**: 45 minutes
- **Questions**: 25 questions
- **Passing Score**: 80% (20/25 correct answers)
- **Question Types**: Multiple choice, multiple select, scenario-based

---

## **Question 1** (Multiple Choice)
What is the primary benefit of using Terraform modules?

A) Faster execution of terraform apply
B) Reduced AWS costs
C) Code reusability and standardization
D) Automatic resource scaling

**Answer: C**
**Explanation**: Modules promote code reusability, standardization, and maintainability across infrastructure deployments.

---

## **Question 2** (Multiple Choice)
Which file is required in every Terraform module?

A) variables.tf
B) outputs.tf
C) main.tf
D) versions.tf

**Answer: C**
**Explanation**: While main.tf is the conventional name, at least one .tf file with resource definitions is required for a module to be functional.

---

## **Question 3** (Multiple Select)
Which of the following are best practices for module development? (Select all that apply)

A) Use input validation for variables
B) Include comprehensive outputs
C) Hard-code all values for consistency
D) Provide clear documentation
E) Use semantic versioning

**Answer: A, B, D, E**
**Explanation**: Hard-coding values reduces flexibility and reusability, which goes against module best practices.

---

## **Question 4** (Scenario-Based)
You're creating a VPC module that should work across different environments. Which approach is best for handling environment-specific configurations?

A) Create separate modules for each environment
B) Use conditional logic with variables
C) Hard-code production values
D) Use only default values

**Answer: B**
**Explanation**: Using conditional logic with variables allows a single module to adapt to different environments while maintaining consistency.

---

## **Question 5** (Multiple Choice)
What is the correct syntax to call a module in Terraform?

A) `resource "module" "vpc" { source = "./modules/vpc" }`
B) `module "vpc" { source = "./modules/vpc" }`
C) `import "vpc" from "./modules/vpc"`
D) `include "./modules/vpc"`

**Answer: B**
**Explanation**: The correct syntax uses the `module` block with a source parameter.

---

## **Question 6** (Multiple Choice)
Which meta-argument is commonly used in modules to create multiple similar resources?

A) depends_on
B) lifecycle
C) count
D) provider

**Answer: C**
**Explanation**: The `count` meta-argument is used to create multiple instances of resources based on a numeric value.

---

## **Question 7** (Multiple Select)
What should be included in a module's outputs.tf file? (Select all that apply)

A) Resource IDs that other modules might need
B) Computed values from resources
C) Sensitive information like passwords
D) Resource ARNs for cross-service integration
E) All variable values

**Answer: A, B, D**
**Explanation**: Outputs should expose useful values for consumption by other modules, but sensitive information should be marked as sensitive, and not all variables need to be output.

---

## **Question 8** (Scenario-Based)
Your module creates an RDS instance and you want to output the endpoint. However, the endpoint contains sensitive information. What's the best approach?

```hcl
output "db_endpoint" {
  value = aws_db_instance.main.endpoint
  # What should be added here?
}
```

A) `description = "Database endpoint"`
B) `sensitive = true`
C) `type = string`
D) Nothing additional needed

**Answer: B**
**Explanation**: The `sensitive = true` attribute prevents the output value from being displayed in logs and console output.

---

## **Question 9** (Multiple Choice)
What is the purpose of the versions.tf file in a module?

A) To track module version history
B) To specify required Terraform and provider versions
C) To define variable versions
D) To manage resource versions

**Answer: B**
**Explanation**: The versions.tf file specifies the minimum required versions of Terraform and providers for the module to function correctly.

---

## **Question 10** (Multiple Choice)
Which validation block would correctly validate that a variable contains a valid AWS region?

A) 
```hcl
validation {
  condition = length(var.region) > 0
  error_message = "Region cannot be empty."
}
```

B)
```hcl
validation {
  condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
  error_message = "Must be a valid AWS region format."
}
```

C)
```hcl
validation {
  condition = var.region == "us-east-1"
  error_message = "Only us-east-1 is allowed."
}
```

D)
```hcl
validation {
  condition = contains(["us-east-1", "us-west-2"], var.region)
  error_message = "Invalid region."
}
```

**Answer: B**
**Explanation**: Option B uses a regex pattern that matches the AWS region naming convention (e.g., us-east-1, eu-west-1).

---

## **Question 11** (Scenario-Based)
You have a module that creates different numbers of subnets based on the environment. Which approach is most appropriate?

A) Use count with a variable
B) Create separate resources for each environment
C) Use for_each with a map
D) Hard-code the maximum number

**Answer: A or C**
**Explanation**: Both count and for_each can work, but for_each with a map provides more flexibility and better state management.

---

## **Question 12** (Multiple Choice)
What is the difference between a root module and a child module?

A) Root modules can't call other modules
B) Child modules can't have variables
C) Root modules are executed directly by Terraform CLI
D) Child modules are always remote

**Answer: C**
**Explanation**: Root modules are the entry point for Terraform execution, while child modules are called by other modules.

---

## **Question 13** (Multiple Select)
Which of the following are valid module sources? (Select all that apply)

A) Local file path: `./modules/vpc`
B) Git repository: `git::https://github.com/user/repo.git`
C) Terraform Registry: `terraform-aws-modules/vpc/aws`
D) HTTP URL: `https://example.com/module.zip`
E) S3 bucket: `s3::https://bucket.s3.amazonaws.com/module.zip`

**Answer: A, B, C, D, E**
**Explanation**: Terraform supports multiple module sources including local paths, Git repositories, Terraform Registry, HTTP URLs, and S3 buckets.

---

## **Question 14** (Multiple Choice)
When should you use module versioning?

A) Only for public modules
B) Only for production environments
C) For all modules to ensure consistency
D) Never, it's not necessary

**Answer: C**
**Explanation**: Module versioning ensures consistency and allows controlled updates across all environments.

---

## **Question 15** (Scenario-Based)
You want to create a module that can optionally create a NAT Gateway. What's the best approach?

```hcl
resource "aws_nat_gateway" "main" {
  # What should be added here?
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}
```

A) `count = 1`
B) `count = var.enable_nat_gateway ? 1 : 0`
C) `for_each = var.enable_nat_gateway`
D) `depends_on = [var.enable_nat_gateway]`

**Answer: B**
**Explanation**: Using count with a conditional expression allows optional resource creation based on a boolean variable.

---

## **Question 16** (Multiple Choice)
What is the purpose of local values in modules?

A) To store sensitive data
B) To compute values from variables and resources
C) To define module outputs
D) To create local resources only

**Answer: B**
**Explanation**: Local values are used to compute and store intermediate values derived from variables, resources, or data sources.

---

## **Question 17** (Multiple Select)
Which testing strategies are recommended for Terraform modules? (Select all that apply)

A) Unit testing with Terratest
B) Integration testing in isolated environments
C) Static analysis with tools like tflint
D) Security scanning with tools like tfsec
E) Manual testing only

**Answer: A, B, C, D**
**Explanation**: Comprehensive testing includes unit tests, integration tests, static analysis, and security scanning. Manual testing alone is insufficient.

---

## **Question 18** (Multiple Choice)
How should you handle secrets in module variables?

A) Pass them as plain text variables
B) Use sensitive variables and external secret management
C) Hard-code them in the module
D) Store them in terraform.tfvars

**Answer: B**
**Explanation**: Secrets should be marked as sensitive and managed through external secret management systems, not stored in plain text.

---

## **Question 19** (Scenario-Based)
Your module needs to create resources in multiple AWS regions. What's the best approach?

A) Use multiple provider blocks in the module
B) Pass provider configurations from the calling module
C) Create separate modules for each region
D) Use data sources to determine the region

**Answer: B**
**Explanation**: Provider configurations should be passed from the calling module using provider aliases for multi-region deployments.

---

## **Question 20** (Multiple Choice)
What is the recommended way to organize module files?

A) Put everything in main.tf
B) Separate by resource type (ec2.tf, rds.tf, etc.)
C) Use standard files: main.tf, variables.tf, outputs.tf, versions.tf
D) Create one file per resource

**Answer: C**
**Explanation**: The standard organization uses main.tf for resources, variables.tf for inputs, outputs.tf for outputs, and versions.tf for version constraints.

---

## **Question 21** (Multiple Select)
Which of the following are benefits of using the Terraform Registry for modules? (Select all that apply)

A) Version management
B) Documentation hosting
C) Community contributions
D) Automatic testing
E) Usage analytics

**Answer: A, B, C, E**
**Explanation**: The Terraform Registry provides version management, documentation, community modules, and usage analytics, but doesn't automatically test modules.

---

## **Question 22** (Multiple Choice)
When creating a module for enterprise use, what should you prioritize?

A) Maximum flexibility with many variables
B) Simplicity with minimal configuration
C) Balance between flexibility and opinionated defaults
D) Hard-coded best practices

**Answer: C**
**Explanation**: Enterprise modules should balance flexibility for different use cases with opinionated defaults that enforce best practices.

---

## **Question 23** (Scenario-Based)
You're creating a module that should work with different AWS account configurations. How should you handle account-specific settings?

A) Hard-code account IDs in the module
B) Use data sources to discover account information
C) Require account ID as a variable
D) Use environment variables only

**Answer: B**
**Explanation**: Using data sources like `aws_caller_identity` allows the module to automatically discover account information without hard-coding.

---

## **Question 24** (Multiple Choice)
What is the purpose of the `for_each` meta-argument in modules?

A) To iterate over lists only
B) To create resources based on a map or set
C) To repeat module calls
D) To loop through variables

**Answer: B**
**Explanation**: The `for_each` meta-argument creates multiple resource instances based on a map or set, providing more flexibility than count.

---

## **Question 25** (Multiple Select)
Which practices improve module maintainability? (Select all that apply)

A) Comprehensive documentation
B) Clear variable descriptions
C) Example usage in README
D) Minimal error handling
E) Consistent naming conventions

**Answer: A, B, C, E**
**Explanation**: Good documentation, clear descriptions, examples, and consistent naming improve maintainability. Minimal error handling reduces maintainability.

---

## 📊 **Scoring Guide**

- **23-25 correct (92-100%)**: Excellent understanding of Terraform modules
- **20-22 correct (80-88%)**: Good grasp of module concepts with minor gaps
- **17-19 correct (68-76%)**: Adequate knowledge but needs improvement
- **Below 17 correct (<68%)**: Requires significant study of module development

## 📚 **Study Areas for Improvement**

If you scored below 80%, focus on these areas:
- Module structure and organization
- Input validation and variable design
- Output definitions and sensitive data handling
- Module composition patterns
- Testing strategies for modules
- Version management and distribution
- Enterprise module governance

## 🎯 **Next Steps**

- Review the Concept.md file for detailed explanations
- Complete the hands-on labs for practical experience
- Practice creating modules for different AWS services
- Study the official Terraform module documentation
- Explore community modules in the Terraform Registry

---

**Congratulations on completing Practice Test 7!** Use your results to guide further study and hands-on practice with Terraform modules.
