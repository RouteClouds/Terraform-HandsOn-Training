# Test Your Understanding: Topic 2 - Terraform CLI & AWS Provider Configuration

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your mastery of Terraform CLI installation, configuration, and AWS Provider setup. The test combines multiple-choice questions, scenario-based challenges, and hands-on exercises to validate practical understanding and implementation skills.

### **Learning Objectives Assessed**
1. **Terraform CLI Installation and Setup** (25 points): Installation methods, version management, and troubleshooting
2. **AWS Provider Configuration** (30 points): Authentication methods, security implementation, and multi-environment setup
3. **CLI Workflow Mastery** (25 points): Command execution, state management, and debugging
4. **Security and Best Practices** (15 points): Authentication security, encryption, and compliance
5. **Enterprise Configuration** (5 points): Team collaboration, governance, and cost management

### **Assessment Integration with Visual Learning**
This assessment directly references the professional diagrams created in the DaC implementation:
- **Figure 2.1**: Terraform CLI Installation Methods (Questions 1-5)
- **Figure 2.2**: AWS Provider Configuration (Questions 6-10)
- **Figure 2.3**: CLI Workflow and Commands (Questions 11-15)
- **Figure 2.4**: Authentication Methods (Questions 16-20)
- **Figure 2.5**: Enterprise Configuration (Scenario-based challenges)

### **Time Allocation**
- **Multiple Choice Questions**: 30 minutes (20 questions)
- **Scenario-Based Challenges**: 20 minutes (5 scenarios)
- **Hands-On Exercises**: 40 minutes (3 exercises)
- **Total Assessment Time**: 90 minutes

---

## 🎯 **Multiple Choice Questions (20 Questions - 4 points each)**

### **Section A: Terraform CLI Installation and Setup (Questions 1-5)**

### **Question 1** (4 points)
Which installation method provides the most consistent Terraform CLI experience across different operating systems and environments?

A) Package managers (apt, yum, brew)  
B) Direct binary download  
C) Docker containers  
D) Source code compilation  

**Correct Answer**: C  
**Explanation**: Docker containers provide the most consistent experience across platforms, ensuring identical Terraform versions and dependencies regardless of the host operating system.

---

### **Question 2** (4 points)
What is the primary advantage of using tfenv for Terraform version management?

A) Faster installation process  
B) Automatic security updates  
C) Project-specific version switching  
D) Reduced disk space usage  

**Correct Answer**: C  
**Explanation**: tfenv allows switching between different Terraform versions per project using .terraform-version files, ensuring team consistency and project-specific version requirements.

---

### **Question 3** (4 points)
Which command verifies that Terraform CLI is properly installed and accessible?

A) `terraform --help`  
B) `terraform version`  
C) `terraform validate`  
D) `terraform init`  

**Correct Answer**: B  
**Explanation**: `terraform version` displays the installed Terraform version and confirms the CLI is properly installed and accessible in the system PATH.

---

### **Question 4** (4 points)
When using the ~> 1.13.0 version constraint, which versions would be acceptable?

A) 1.13.0, 1.13.1, 1.13.2, 1.14.0  
B) 1.13.0, 1.13.1, 1.13.2 only  
C) 1.13.0 only  
D) Any version 1.13 or higher  

**Correct Answer**: B  
**Explanation**: The ~> operator allows patch-level updates (1.13.x) but prevents minor version changes that could introduce breaking changes.

---

### **Question 5** (4 points)
What is the recommended approach for Terraform CLI installation in enterprise environments?

A) Individual manual installation on each workstation  
B) Centralized distribution through artifact repositories  
C) Direct download from HashiCorp website  
D) Installation via public package managers only  

**Correct Answer**: B  
**Explanation**: Enterprise environments should use centralized distribution through artifact repositories to ensure version consistency, security scanning, and controlled deployment.

---

### **Section B: AWS Provider Configuration (Questions 6-10)**

### **Question 6** (4 points)
Which AWS Provider version should be used with Terraform ~> 1.13.0 for optimal compatibility in 2025?

A) ~> 5.0.0  
B) ~> 6.0.0  
C) ~> 6.12.0  
D) >= 6.12.0  

**Correct Answer**: C  
**Explanation**: AWS Provider version ~> 6.12.0 provides optimal compatibility with Terraform 1.13.x and includes the latest AWS service features and security enhancements.

---

### **Question 7** (4 points)
What is the most secure authentication method for Terraform in CI/CD pipelines?

A) Static access keys in environment variables  
B) AWS CLI profiles  
C) OIDC federation with temporary credentials  
D) IAM user credentials in configuration files  

**Correct Answer**: C  
**Explanation**: OIDC federation eliminates the need for long-lived credentials in CI/CD pipelines, providing temporary credentials with automatic rotation and enhanced security.

---

### **Question 8** (4 points)
Which provider configuration block enables default tags for all AWS resources?

A) `required_providers`  
B) `default_tags`  
C) `assume_role`  
D) `backend`  

**Correct Answer**: B  
**Explanation**: The `default_tags` block in the AWS provider configuration automatically applies specified tags to all resources created by that provider instance.

---

### **Question 9** (4 points)
What is the purpose of the external_id parameter in role assumption?

A) Identifying the external user  
B) Additional security layer for cross-account access  
C) Specifying the external account ID  
D) Enabling external authentication providers  

**Correct Answer**: B  
**Explanation**: The external_id parameter provides an additional security layer for cross-account role assumption, preventing the "confused deputy" problem.

---

### **Question 10** (4 points)
Which authentication method should be avoided in production environments?

A) IAM roles with temporary credentials  
B) OIDC federation  
C) Static access keys in configuration files  
D) AWS CLI profiles with MFA  

**Correct Answer**: C  
**Explanation**: Static access keys in configuration files pose significant security risks and should never be used in production environments.

---

### **Section C: CLI Workflow and Commands (Questions 11-15)**

### **Question 11** (4 points)
What is the correct order of Terraform CLI commands for a new project?

A) plan → init → validate → apply  
B) init → validate → plan → apply  
C) validate → init → plan → apply  
D) init → plan → validate → apply  

**Correct Answer**: B  
**Explanation**: The correct workflow is init (download providers), validate (check syntax), plan (preview changes), then apply (execute changes).

---

### **Question 12** (4 points)
Which command should be run after modifying provider version constraints?

A) `terraform validate`  
B) `terraform plan`  
C) `terraform init`  
D) `terraform refresh`  

**Correct Answer**: C  
**Explanation**: `terraform init` must be run after modifying provider version constraints to download the new provider versions.

---

### **Question 13** (4 points)
What does the `terraform fmt` command accomplish?

A) Validates configuration syntax  
B) Formats configuration files to canonical style  
C) Generates execution plans  
D) Initializes the working directory  

**Correct Answer**: B  
**Explanation**: `terraform fmt` formats Terraform configuration files to the canonical style and formatting conventions.

---

### **Question 14** (4 points)
Which command provides detailed information about a specific resource in the state?

A) `terraform state list`  
B) `terraform show`  
C) `terraform state show <resource>`  
D) `terraform output`  

**Correct Answer**: C  
**Explanation**: `terraform state show <resource>` displays detailed information about a specific resource in the Terraform state.

---

### **Question 15** (4 points)
What is the purpose of saving a Terraform plan to a file?

A) Backup the configuration  
B) Share with team members  
C) Ensure exact execution of reviewed changes  
D) Reduce planning time  

**Correct Answer**: C  
**Explanation**: Saving a plan to a file ensures that the exact changes reviewed during planning are applied, preventing drift between plan and apply.

---

### **Section D: Security and Authentication (Questions 16-20)**

### **Question 16** (4 points)
Which AWS service provides temporary credentials for role assumption?

A) AWS IAM  
B) AWS STS  
C) AWS Organizations  
D) AWS Config  

**Correct Answer**: B  
**Explanation**: AWS Security Token Service (STS) provides temporary credentials when assuming IAM roles.

---

### **Question 17** (4 points)
What is the recommended approach for MFA in Terraform automation?

A) Disable MFA for automation accounts  
B) Use MFA with long-lived sessions  
C) Implement MFA at the CI/CD pipeline level  
D) Store MFA tokens in environment variables  

**Correct Answer**: C  
**Explanation**: MFA should be implemented at the CI/CD pipeline level, with automation using temporary credentials from role assumption.

---

### **Question 18** (4 points)
Which environment variable takes precedence over terraform.tfvars files?

A) `AWS_PROFILE`  
B) `TF_VAR_variable_name`  
C) `AWS_REGION`  
D) `TF_LOG`  

**Correct Answer**: B  
**Explanation**: Environment variables prefixed with `TF_VAR_` take precedence over values in terraform.tfvars files.

---

### **Question 19** (4 points)
What is the security benefit of using IAM roles instead of IAM users for Terraform?

A) Easier credential management  
B) Temporary credentials with automatic rotation  
C) Better performance  
D) Lower cost  

**Correct Answer**: B  
**Explanation**: IAM roles provide temporary credentials that automatically rotate, reducing the risk of credential compromise.

---

### **Question 20** (4 points)
Which logging level provides the most detailed Terraform debugging information?

A) `TF_LOG=INFO`  
B) `TF_LOG=DEBUG`  
C) `TF_LOG=TRACE`  
D) `TF_LOG=ERROR`  

**Correct Answer**: C  
**Explanation**: `TF_LOG=TRACE` provides the most detailed logging information for debugging Terraform operations.

---

## 🎭 **Scenario-Based Challenges (5 Scenarios - 4 points each)**

### **Scenario 1: Multi-Environment Setup** (4 points)
Your organization needs to deploy infrastructure across development, staging, and production environments using different AWS accounts. Design the provider configuration approach.

**Required Elements:**
- Cross-account role assumption
- Environment-specific authentication
- Security best practices

**Sample Solution:**
```hcl
provider "aws" {
  alias = "development"
  assume_role {
    role_arn = "arn:aws:iam::DEV-ACCOUNT:role/TerraformRole"
    session_name = "terraform-dev"
  }
  region = "us-east-1"
}

provider "aws" {
  alias = "production"
  assume_role {
    role_arn = "arn:aws:iam::PROD-ACCOUNT:role/TerraformRole"
    session_name = "terraform-prod"
    external_id = var.external_id
  }
  region = "us-east-1"
}
```

### **Scenario 2: CI/CD Pipeline Authentication** (4 points)
Configure Terraform authentication for a GitHub Actions workflow without storing long-lived credentials.

**Required Elements:**
- OIDC federation setup
- Temporary credential usage
- Security best practices

### **Scenario 3: State Management Strategy** (4 points)
Design a remote state configuration for a team of 10 developers working on the same infrastructure.

**Required Elements:**
- S3 backend configuration
- State locking mechanism
- Team collaboration support

### **Scenario 4: Version Management** (4 points)
Your team needs to maintain multiple Terraform projects with different version requirements. Design a version management strategy.

**Required Elements:**
- Project-specific version control
- Team consistency
- Upgrade path planning

### **Scenario 5: Troubleshooting Authentication** (4 points)
A developer reports authentication errors when running Terraform. Provide a systematic troubleshooting approach.

**Required Elements:**
- Diagnostic commands
- Common issue identification
- Resolution steps

---

## 🛠️ **Hands-On Exercises (3 Exercises - 10 points each)**

### **Exercise 1: CLI Installation and Configuration** (10 points)
Install Terraform CLI using two different methods and configure version management.

**Tasks:**
1. Install Terraform using package manager
2. Install using direct binary download
3. Configure tfenv for version management
4. Verify installations and create project-specific version file

### **Exercise 2: AWS Provider Setup** (10 points)
Configure AWS Provider with multiple authentication methods.

**Tasks:**
1. Configure AWS CLI profile authentication
2. Set up environment variable authentication
3. Implement role assumption configuration
4. Test each authentication method

### **Exercise 3: Complete Workflow Execution** (10 points)
Execute a complete Terraform workflow from initialization to deployment.

**Tasks:**
1. Initialize new Terraform project
2. Configure remote state backend
3. Create simple AWS resources
4. Execute full workflow (init, validate, plan, apply)
5. Demonstrate state management operations

---

## 📊 **Assessment Scoring**

### **Scoring Rubric**
- **90-100 points**: Excellent - Comprehensive understanding and flawless execution
- **80-89 points**: Good - Strong understanding with minor gaps
- **70-79 points**: Satisfactory - Basic understanding with some weaknesses
- **60-69 points**: Needs Improvement - Significant gaps in understanding
- **Below 60 points**: Unsatisfactory - Major deficiencies requiring additional training

### **Detailed Scoring Breakdown**
- **Multiple Choice (80 points)**: 4 points per question, 20 questions
- **Scenarios (20 points)**: 4 points per scenario, 5 scenarios
- **Hands-On (30 points)**: 10 points per exercise, 3 exercises
- **Total Possible**: 130 points

---

## 🎯 **Answer Key and Explanations**

### **Multiple Choice Answers**
1. C - Docker containers  2. C - Project-specific version switching  3. B - terraform version  4. B - 1.13.0, 1.13.1, 1.13.2 only  5. B - Centralized distribution
6. C - ~> 6.12.0  7. C - OIDC federation  8. B - default_tags  9. B - Additional security layer  10. C - Static access keys
11. B - init → validate → plan → apply  12. C - terraform init  13. B - Formats configuration files  14. C - terraform state show  15. C - Ensure exact execution
16. B - AWS STS  17. C - Implement at CI/CD level  18. B - TF_VAR_variable_name  19. B - Temporary credentials  20. C - TF_LOG=TRACE

---

*This comprehensive assessment validates practical understanding of Terraform CLI and AWS Provider configuration, ensuring readiness for advanced Terraform operations and enterprise implementation.*
