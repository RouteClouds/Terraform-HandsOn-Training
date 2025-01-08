# Terraform Basics - Practice Test

## Section 1: Multiple Choice Questions (40 points)

### Basic Concepts (15 points)
1. What command initializes a Terraform working directory?
   - [ ] terraform start
   - [x] terraform init
   - [ ] terraform begin
   - [ ] terraform setup

2. Which file extension is used for Terraform configuration files?
   - [ ] .tf.json
   - [x] .tf
   - [ ] .terraform
   - [ ] .hcl

3. What is the purpose of `terraform plan`?
   - [ ] Apply changes to infrastructure
   - [x] Preview changes before applying
   - [ ] Initialize providers
   - [ ] Destroy resources

4. Which command formats Terraform configuration files?
   - [ ] terraform format
   - [x] terraform fmt
   - [ ] terraform style
   - [ ] terraform beautify

5. What is the purpose of the `.terraform` directory?
   - [ ] Stores state files
   - [x] Stores provider plugins and modules
   - [ ] Stores variable definitions
   - [ ] Stores output values

### Resource Management (15 points)
6. Which of these defines a dependency between resources?
   - [ ] depends = []
   - [x] depends_on = []
   - [ ] dependency = []
   - [ ] requires = []

7. How do you reference an attribute of another resource?
   - [ ] ${resource.name.attribute}
   - [x] resource_type.resource_name.attribute
   - [ ] $(resource.attribute)
   - [ ] resource[attribute]

8. What is the correct way to tag AWS resources in Terraform?
   - [ ] tag { key = "value" }
   - [x] tags = { key = "value" }
   - [ ] aws_tags { key = "value" }
   - [ ] labels = { key = "value" }

9. Which block type is used to declare a provider?
   - [x] provider "aws" {}
   - [ ] aws_provider {}
   - [ ] terraform_provider "aws" {}
   - [ ] use_provider "aws" {}

10. How do you specify required provider versions?
    - [ ] provider_version = ">= 1.0"
    - [ ] version = ">= 1.0"
    - [x] required_providers { aws = { version = ">= 1.0" } }
    - [ ] aws_provider_version = ">= 1.0"

### Variables and Outputs (10 points)
11. Which file is commonly used to define variable values?
    - [ ] variables.tf
    - [ ] terraform.tf
    - [x] terraform.tfvars
    - [ ] outputs.tf

12. What is the correct syntax for a variable definition?
    - [x] variable "name" { type = string }
    - [ ] var "name" = "value"
    - [ ] variable = { name = "value" }
    - [ ] define_variable "name" "value"

13. How do you reference an environment variable in Terraform?
    - [ ] ${ENV.variable}
    - [x] $TF_VAR_variable_name
    - [ ] %variable_name%
    - [ ] env(variable_name)

14. Which variable type allows complex nested structures?
    - [ ] map
    - [ ] list
    - [x] object
    - [ ] set

15. What is the correct way to define an output value?
    - [x] output "name" { value = resource.attribute }
    - [ ] output = { name = resource.attribute }
    - [ ] export "name" = resource.attribute
    - [ ] define_output "name" resource.attribute

[Previous sections for Practical Exercises, Troubleshooting, and Bonus Challenge remain the same...]

## Additional Section: State Management Questions (10 points)

16. What command is used to list resources in the state file?
    - [ ] terraform list
    - [x] terraform state list
    - [ ] terraform show resources
    - [ ] terraform state show

17. How do you remove a resource from state without destroying it?
    - [ ] terraform delete resource
    - [ ] terraform state delete
    - [x] terraform state rm
    - [ ] terraform remove resource

18. Which backend feature prevents concurrent state modifications?
    - [ ] State versioning
    - [x] State locking
    - [ ] State encryption
    - [ ] State backup

19. What is the recommended backend for production environments?
    - [ ] local
    - [x] s3 with DynamoDB
    - [ ] consul
    - [ ] artifactory

20. How do you import existing infrastructure into Terraform state?
    - [ ] terraform add resource
    - [ ] terraform state add
    - [x] terraform import
    - [ ] terraform state import

## Scoring
- Multiple Choice: 50 points (2.5 points each)
- Practical Exercises: 30 points
- Troubleshooting: 10 points
- Bonus Challenge: 10 points
Total Possible: 100 points
Passing Score: 70 points

## Time Limit
- 2 hours for main test
- 30 minutes for bonus challenge
