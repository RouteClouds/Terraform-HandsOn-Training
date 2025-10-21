# Terraform Associate Certification - Practice Exam

**Exam Format**: 57 Questions  
**Time Limit**: 60 minutes  
**Passing Score**: 70% (40/57 correct)  
**Difficulty**: Professional-level  
**Certification**: HashiCorp Terraform Associate 003/004

---

## Exam Instructions

1. **Time Management**: You have 60 minutes to complete 57 questions
2. **Question Types**: Multiple-choice, multiple-select, and scenario-based
3. **Scoring**: 70% passing score (40/57 correct)
4. **No Partial Credit**: Each question is either correct or incorrect
5. **Review**: You can review and change answers before submitting

---

## Domain Coverage

- **Domain 1**: IaC Concepts (8 questions)
- **Domain 2**: Terraform Purpose (8 questions)
- **Domain 3**: Terraform Basics (12 questions)
- **Domain 4**: Outside Core Workflow (10 questions)
- **Domain 5**: Terraform Modules (10 questions)
- **Domain 6**: Terraform Workflow (9 questions)

---

## DOMAIN 1: IaC CONCEPTS (8 Questions)

### Question 1
What is Infrastructure as Code (IaC)?

A) A programming language for AWS  
B) Managing infrastructure through code and automation  
C) A cloud storage service  
D) A database management tool  

**Answer**: B

---

### Question 2
Which of the following is a benefit of Infrastructure as Code?

A) Eliminates the need for testing  
B) Enables version control and reproducibility  
C) Removes all security concerns  
D) Eliminates the need for documentation  

**Answer**: B

---

### Question 3
What is the primary advantage of declarative IaC over imperative?

A) Faster execution  
B) Easier to understand intent  
C) Lower cost  
D) Better performance  

**Answer**: B

---

### Question 4
Which of the following is NOT a benefit of IaC?

A) Consistency  
B) Automation  
C) Guaranteed uptime  
D) Version control  

**Answer**: C

---

### Question 5
What does "idempotent" mean in the context of IaC?

A) Running the same code multiple times produces the same result  
B) Code that runs only once  
C) Code that cannot be changed  
D) Code that requires manual intervention  

**Answer**: A

---

### Question 6
Which principle ensures that infrastructure changes are tracked and auditable?

A) Immutability  
B) Version control  
C) Automation  
D) Scalability  

**Answer**: B

---

### Question 7
What is a "state file" in Terraform?

A) A configuration file  
B) A file that tracks the current state of infrastructure  
C) A backup file  
D) A log file  

**Answer**: B

---

### Question 8
Which of the following best describes "infrastructure drift"?

A) Moving infrastructure to a different region  
B) Differences between desired and actual infrastructure state  
C) Deleting infrastructure  
D) Upgrading infrastructure  

**Answer**: B

---

## DOMAIN 2: TERRAFORM PURPOSE (8 Questions)

### Question 9
What is Terraform?

A) A cloud provider  
B) An infrastructure provisioning tool  
C) A programming language  
D) A database  

**Answer**: B

---

### Question 10
Which of the following is a primary use case for Terraform?

A) Writing web applications  
B) Managing cloud infrastructure  
C) Creating databases  
D) Writing operating systems  

**Answer**: B

---

### Question 11
What is the main advantage of using Terraform over manual infrastructure management?

A) Lower cost  
B) Faster provisioning and consistency  
C) Better security  
D) Easier to learn  

**Answer**: B

---

### Question 12
Which cloud providers does Terraform support?

A) Only AWS  
B) Only Azure  
C) Multiple providers including AWS, Azure, GCP  
D) Only on-premises infrastructure  

**Answer**: C

---

### Question 13
What is a "provider" in Terraform?

A) A cloud service  
B) A plugin that enables Terraform to interact with APIs  
C) A configuration file  
D) A backup service  

**Answer**: B

---

### Question 14
Which of the following is NOT a Terraform component?

A) Provider  
B) Resource  
C) Variable  
D) Database  

**Answer**: D

---

### Question 15
What does "HCL" stand for?

A) High-level Configuration Language  
B) HashiCorp Configuration Language  
C) Hybrid Cloud Language  
D) Hardware Configuration Language  

**Answer**: B

---

### Question 16
What is the primary file extension for Terraform configuration files?

A) .tf  
B) .json  
C) .yaml  
D) .xml  

**Answer**: A

---

## DOMAIN 3: TERRAFORM BASICS (12 Questions)

### Question 17
What does `terraform init` do?

A) Initializes AWS account  
B) Initializes Terraform working directory  
C) Initializes database  
D) Initializes network  

**Answer**: B

---

### Question 18
What is the purpose of `terraform plan`?

A) Creates infrastructure  
B) Destroys infrastructure  
C) Shows what changes will be made  
D) Backs up infrastructure  

**Answer**: C

---

### Question 19
What does `terraform apply` do?

A) Validates configuration  
B) Creates or modifies infrastructure  
C) Destroys infrastructure  
D) Backs up state  

**Answer**: B

---

### Question 20
What is the correct order of Terraform workflow?

A) apply → plan → init → validate  
B) init → validate → plan → apply  
C) validate → init → plan → apply  
D) plan → init → validate → apply  

**Answer**: B

---

### Question 21
What does `terraform validate` check?

A) AWS permissions  
B) Configuration syntax and structure  
C) Resource availability  
D) Network connectivity  

**Answer**: B

---

### Question 22
What is a "resource" in Terraform?

A) A configuration file  
B) A managed infrastructure object  
C) A variable  
D) A provider  

**Answer**: B

---

### Question 23
What is the syntax for defining a resource in Terraform?

A) `resource "type" "name" { ... }`  
B) `resource type name { ... }`  
C) `define resource type name { ... }`  
D) `resource: type: name: { ... }`  

**Answer**: A

---

### Question 24
What is a "data source" in Terraform?

A) A resource that is created  
B) A resource that is read-only  
C) A configuration file  
D) A backup  

**Answer**: B

---

### Question 25
What does `terraform destroy` do?

A) Deletes configuration files  
B) Removes infrastructure managed by Terraform  
C) Backs up infrastructure  
D) Validates configuration  

**Answer**: B

---

### Question 26
What is the purpose of `terraform fmt`?

A) Formats code to canonical style  
B) Validates configuration  
C) Creates infrastructure  
D) Backs up state  

**Answer**: A

---

### Question 27
What is a "variable" in Terraform?

A) A resource  
B) A provider  
C) An input value  
D) A state file  

**Answer**: C

---

### Question 28
What is the purpose of `terraform output`?

A) Displays resource details  
B) Displays output values  
C) Validates configuration  
D) Creates infrastructure  

**Answer**: B

---

## DOMAIN 4: OUTSIDE CORE WORKFLOW (10 Questions)

### Question 29
What does `terraform import` do?

A) Imports modules  
B) Brings existing resources into Terraform state  
C) Imports variables  
D) Imports providers  

**Answer**: B

---

### Question 30
What is the purpose of `terraform state list`?

A) Lists resources in state  
B) Lists providers  
C) Lists variables  
D) Lists modules  

**Answer**: A

---

### Question 31
What does `terraform state rm` do?

A) Removes resource from AWS  
B) Removes resource from state without destroying  
C) Removes state file  
D) Removes provider  

**Answer**: B

---

### Question 32
What is the purpose of `terraform taint`?

A) Marks resource for replacement  
B) Deletes resource  
C) Locks resource  
D) Validates resource  

**Answer**: A

---

### Question 33
What does `terraform force-unlock` do?

A) Unlocks AWS account  
B) Releases stuck state lock  
C) Unlocks resources  
D) Unlocks modules  

**Answer**: B

---

### Question 34
What is a "backend" in Terraform?

A) A provider  
B) A resource  
C) Where state is stored  
D) A module  

**Answer**: C

---

### Question 35
Which of the following is a valid backend option?

A) S3  
B) Azure Blob Storage  
C) Terraform Cloud  
D) All of the above  

**Answer**: D

---

### Question 36
What is the purpose of state locking?

A) Prevents concurrent modifications  
B) Encrypts state  
C) Backs up state  
D) Validates state  

**Answer**: A

---

### Question 37
What is "Sentinel" in Terraform?

A) A cloud provider  
B) A policy language  
C) A resource type  
D) A module  

**Answer**: B

---

### Question 38
What does `terraform refresh` do?

A) Refreshes AWS credentials  
B) Syncs state with actual resources  
C) Clears cache  
D) Resets configuration  

**Answer**: B

---

## DOMAIN 5: TERRAFORM MODULES (10 Questions)

### Question 39
What is a "module" in Terraform?

A) A resource  
B) A reusable container of resources  
C) A provider  
D) A variable  

**Answer**: B

---

### Question 40
What is the primary benefit of using modules?

A) Faster execution  
B) Code reusability and organization  
C) Lower cost  
D) Better security  

**Answer**: B

---

### Question 41
What is the correct syntax for calling a module?

A) `module "name" { source = "path" }`  
B) `call module "name" { source = "path" }`  
C) `use module "name" { source = "path" }`  
D) `import module "name" { source = "path" }`  

**Answer**: A

---

### Question 42
Where are modules typically stored?

A) In the root directory only  
B) In a modules directory  
C) In the Terraform Registry  
D) All of the above  

**Answer**: D

---

### Question 43
What is the Terraform Registry?

A) A database  
B) A repository of modules and providers  
C) A cloud service  
D) A backup service  

**Answer**: B

---

### Question 44
What is a "root module"?

A) The main module  
B) A module in the root directory  
C) The first module loaded  
D) All of the above  

**Answer**: D

---

### Question 45
What is the purpose of module "outputs"?

A) To display information  
B) To pass values from module to parent  
C) To create resources  
D) To validate configuration  

**Answer**: B

---

### Question 46
What is the purpose of module "variables"?

A) To store data  
B) To accept input values  
C) To define resources  
D) To configure providers  

**Answer**: B

---

### Question 47
What is "module composition"?

A) Creating modules  
B) Combining multiple modules  
C) Deleting modules  
D) Backing up modules  

**Answer**: B

---

### Question 48
What is the recommended structure for a module?

A) All files in root directory  
B) Separate directories for modules  
C) main.tf, variables.tf, outputs.tf  
D) Both B and C  

**Answer**: D

---

## DOMAIN 6: TERRAFORM WORKFLOW (9 Questions)

### Question 49
What is the first step in the Terraform workflow?

A) terraform plan  
B) terraform apply  
C) terraform init  
D) terraform validate  

**Answer**: C

---

### Question 50
What should you do before running `terraform apply`?

A) Run `terraform plan`  
B) Run `terraform validate`  
C) Review the plan  
D) All of the above  

**Answer**: D

---

### Question 51
What is the purpose of version control in Terraform workflow?

A) Track changes  
B) Enable collaboration  
C) Maintain history  
D) All of the above  

**Answer**: D

---

### Question 52
What is "CI/CD" in the context of Terraform?

A) Cloud Infrastructure/Cloud Deployment  
B) Continuous Integration/Continuous Deployment  
C) Configuration Integration/Configuration Deployment  
D) Cloud Integration/Cloud Delivery  

**Answer**: B

---

### Question 53
What is the purpose of `terraform workspace`?

A) Manage multiple environments  
B) Create modules  
C) Define variables  
D) Configure providers  

**Answer**: A

---

### Question 54
What is a "pull request" in Terraform workflow?

A) A request to pull resources  
B) A code review mechanism  
C) A backup request  
D) A deployment request  

**Answer**: B

---

### Question 55
What is the purpose of code review in Terraform workflow?

A) Ensure code quality  
B) Catch errors early  
C) Share knowledge  
D) All of the above  

**Answer**: D

---

### Question 56
What is "infrastructure testing"?

A) Testing infrastructure code  
B) Testing AWS services  
C) Testing network connectivity  
D) Testing security  

**Answer**: A

---

### Question 57
What is the best practice for managing Terraform state in a team?

A) Store locally  
B) Use remote backend  
C) Share via email  
D) Store in Git  

**Answer**: B

---

## Scoring

**Your Score**: _____ / 57

**Percentage**: _____ %

**Result**: 
- 40-57 correct (70-100%): **PASS** ✅
- 0-39 correct (0-69%): **FAIL** ❌

---

## Next Steps

If you **PASSED**:
- Congratulations! You're ready for the certification exam
- Review weak areas for final preparation
- Schedule your exam

If you **FAILED**:
- Review the topics where you struggled
- Study the relevant course materials
- Retake the practice exam
- Focus on understanding concepts, not just memorization

---

**Practice Exam Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Complete - Ready for Use

