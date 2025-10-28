# Topic 12: Test Your Understanding - Advanced Security & Compliance

**Total Questions**: 48
**Time Limit**: 80 minutes
**Passing Score**: 70% (34/48 correct)

---

## Multiple Choice Questions (45 questions)

### Question 1
How do you mark a variable as sensitive in Terraform?

A) `variable "password" { type = string }`  
B) `variable "password" { type = string; sensitive = true }`  
C) `variable "password" { secret = true }`  
D) `variable "password" { encrypted = true }`  

**Answer**: B  
**Explanation**: The `sensitive = true` flag marks a variable as sensitive.

---

### Question 2
What does encrypting the Terraform state file protect?

A) Terraform code  
B) AWS resources  
C) Sensitive data in state  
D) Network traffic  

**Answer**: C  
**Explanation**: Encrypting state protects sensitive data stored in the state file.

---

### Question 3
Which AWS service is used for secrets management?

A) AWS KMS  
B) AWS Secrets Manager  
C) AWS Parameter Store  
D) All of the above  

**Answer**: D  
**Explanation**: All three services can be used for secrets management.

---

### Question 4
What is the principle of least privilege?

A) Give all permissions  
B) Give only required permissions  
C) Give admin permissions  
D) Give no permissions  

**Answer**: B  
**Explanation**: Least privilege means giving only the minimum required permissions.

---

### Question 5
How do you enable state file encryption in S3?

A) `encrypt = true` in backend  
B) Enable S3 encryption  
C) Use KMS key  
D) All of the above  

**Answer**: D  
**Explanation**: All methods can be used to encrypt state files.

---

### Question 6
What is OIDC authentication used for?

A) Database authentication  
B) AWS API authentication  
C) GitHub Actions authentication  
D) All of the above  

**Answer**: D  
**Explanation**: OIDC can be used for various authentication scenarios.

---

### Question 7
How do you reference a secret from AWS Secrets Manager?

A) `aws_secret.name`  
B) `data.aws_secretsmanager_secret_version`  
C) `aws_secretsmanager_secret`  
D) `var.secret`  

**Answer**: B  
**Explanation**: Use `data.aws_secretsmanager_secret_version` to reference secrets.

---

### Question 8
What is a security group?

A) IAM role  
B) Virtual firewall  
C) Encryption key  
D) Backup service  

**Answer**: B  
**Explanation**: Security groups act as virtual firewalls for EC2 instances.

---

### Question 9
What does VPC stand for?

A) Virtual Private Cloud  
B) Virtual Public Cloud  
C) Virtual Private Connection  
D) Virtual Protocol Cloud  

**Answer**: A  
**Explanation**: VPC stands for Virtual Private Cloud.

---

### Question 10
How do you enable state locking?

A) Use DynamoDB table  
B) Use S3 versioning  
C) Use KMS encryption  
D) Use IAM policies  

**Answer**: A  
**Explanation**: DynamoDB table is used for state locking.

---

### Question 11
What is CloudTrail used for?

A) Audit logging  
B) Performance monitoring  
C) Cost tracking  
D) Resource tagging  

**Answer**: A  
**Explanation**: CloudTrail provides audit logging for AWS API calls.

---

### Question 12
How do you mark an output as sensitive?

A) `output "password" { value = var.password }`  
B) `output "password" { value = var.password; sensitive = true }`  
C) `output "password" { secret = true }`  
D) `output "password" { encrypted = true }`  

**Answer**: B  
**Explanation**: Use `sensitive = true` to mark outputs as sensitive.

---

### Question 13
What is Sentinel in the context of HCP Terraform?

A) A monitoring tool for infrastructure
B) A policy as code framework for governance
C) A secret management service
D) A state locking mechanism

**Answer**: B
**Explanation**: Sentinel is HashiCorp's policy as code framework that enables governance and compliance enforcement in HCP Terraform.

---

### Question 14
Which Sentinel enforcement level blocks runs with no override option?

A) Advisory
B) Soft-mandatory
C) Hard-mandatory
D) Strict

**Answer**: C
**Explanation**: Hard-mandatory policies block runs and cannot be overridden, ensuring critical requirements are always met.

---

### Question 15
What is the purpose of a soft-mandatory Sentinel policy?

A) To log violations without blocking
B) To block runs but allow overrides with justification
C) To permanently block all violations
D) To send email notifications only

**Answer**: B
**Explanation**: Soft-mandatory policies block runs but can be overridden by authorized users with proper justification.

---

### Question 16
Which Sentinel import provides access to Terraform plan data?

A) `import "terraform"`
B) `import "tfplan/v2" as tfplan`
C) `import "plan"`
D) `import "tfstate"`

**Answer**: B
**Explanation**: The `tfplan/v2` import provides access to Terraform plan data for policy evaluation.

---

### Question 17
What does an advisory Sentinel policy do when it fails?

A) Blocks the run completely
B) Logs the failure but allows the run to continue
C) Sends an email to administrators
D) Requires manual approval

**Answer**: B
**Explanation**: Advisory policies log failures for informational purposes but do not block runs.

---

### Question 18
In Sentinel, what is a policy set?

A) A collection of related policies applied to workspaces
B) A single policy file
C) A workspace configuration
D) A Terraform module

**Answer**: A
**Explanation**: A policy set is a collection of related Sentinel policies that can be applied to one or more workspaces.

---

### Question 19
Which of the following is a common use case for Sentinel policies?

A) Cost control by limiting instance types
B) Enforcing required resource tags
C) Restricting deployments to specific regions
D) All of the above

**Answer**: D
**Explanation**: Sentinel policies can enforce cost controls, tagging requirements, regional restrictions, and many other governance rules.

---

### Question 20
How can you test Sentinel policies locally before deploying to HCP Terraform?

A) Use `terraform test`
B) Use the Sentinel CLI with `sentinel test`
C) Use `terraform validate`
D) Local testing is not possible

**Answer**: B
**Explanation**: The Sentinel CLI provides a `sentinel test` command for local policy testing before deployment.

---

### Question 21
What happens when a hard-mandatory Sentinel policy fails?

A) The run is blocked and cannot proceed
B) The run continues with a warning
C) An email is sent to administrators
D) The policy is automatically disabled

**Answer**: A
**Explanation**: Hard-mandatory policy failures completely block runs with no override option.

---

### Question 22
Which Sentinel function is commonly used to iterate over resources in a plan?

A) `for_each`
B) `filter`
C) `for ... as ... { }`
D) `map`

**Answer**: C
**Explanation**: Sentinel uses `for ... as ... { }` syntax to iterate over collections like resources in a plan.

---

### Question 23
What are the four workspace access levels in HCP Terraform?

A) View, Edit, Delete, Admin
B) Read, Plan, Write, Admin
C) Basic, Standard, Advanced, Owner
D) User, Developer, Manager, Admin

**Answer**: B
**Explanation**: HCP Terraform provides four workspace access levels: Read (view only), Plan (can queue plans), Write (can apply), and Admin (full control).

---

### Question 24
Which team has full administrative access to an HCP Terraform organization and cannot be deleted?

A) Administrators team
B) Owners team
C) Default team
D) Root team

**Answer**: B
**Explanation**: The Owners team has full administrative access and is a built-in team that cannot be deleted.

---

### Question 25
What can a user with "Plan" access level do in a workspace?

A) Only view runs and state
B) View runs, queue plans, but cannot apply
C) Apply changes but cannot modify settings
D) Full administrative control

**Answer**: B
**Explanation**: Plan access allows users to view workspace content and queue plans, but they cannot apply changes or modify workspace settings.

---

### Question 26
Which organization-level permission allows a team to create and delete workspaces?

A) manage_workspaces
B) admin_workspaces
C) create_workspaces
D) workspace_admin

**Answer**: A
**Explanation**: The `manage_workspaces` organization-level permission grants the ability to create, delete, and manage workspaces across the organization.

---

### Question 27
What is the recommended approach for managing team membership in large organizations?

A) Manually add users via UI
B) Use SSO/SAML group mapping
C) Create a script to add users
D) Use email invitations

**Answer**: B
**Explanation**: SSO/SAML group mapping automatically synchronizes team membership based on identity provider groups, reducing manual overhead and improving security.

---

### Question 28
Which access level is most appropriate for auditors who need to review infrastructure but not make changes?

A) Plan
B) Write
C) Read
D) Admin

**Answer**: C
**Explanation**: Read access allows auditors to view workspace settings, state, and run history without the ability to make any changes.

---

### Question 29
What happens when you assign "Write" access to a team for a workspace?

A) Team members can only view the workspace
B) Team members can queue plans but not apply
C) Team members can queue plans and apply changes
D) Team members have full administrative control

**Answer**: C
**Explanation**: Write access includes all Plan permissions plus the ability to apply changes and manage variables.

---

### Question 30
Which of the following is a best practice for RBAC in HCP Terraform?

A) Give all developers Admin access for flexibility
B) Use the principle of least privilege
C) Assign organization-level permissions to all teams
D) Avoid using teams and assign permissions individually

**Answer**: B
**Explanation**: The principle of least privilege means granting only the minimum permissions required for users to perform their job functions.

---

### Question 31
What is the primary benefit of VCS-driven workflows in HCP Terraform?

A) Faster Terraform execution
B) Automatic infrastructure deployment on code commits
C) Reduced AWS costs
D) Elimination of state files

**Answer**: B
**Explanation**: VCS-driven workflows automatically trigger Terraform plans on pull requests and applies on merges, enabling GitOps-style infrastructure management.

---

### Question 32
When using VCS integration, what happens when a pull request is opened?

A) Terraform automatically applies changes
B) Terraform runs a plan and posts results as a PR comment
C) The workspace is locked
D) All resources are destroyed

**Answer**: B
**Explanation**: When a PR is opened, HCP Terraform automatically runs a speculative plan and posts the results as a comment on the pull request for review.

---

### Question 33
Which VCS providers are supported by HCP Terraform?

A) Only GitHub
B) GitHub and GitLab only
C) GitHub, GitLab, Bitbucket, and Azure DevOps
D) Any Git-based system

**Answer**: C
**Explanation**: HCP Terraform supports GitHub (Cloud/Enterprise), GitLab (Cloud/Self-Managed), Bitbucket (Cloud/Server), and Azure DevOps.

---

### Question 34
What is the recommended workflow type for production environments in HCP Terraform?

A) API-driven workflow
B) CLI-driven workflow
C) VCS-driven workflow
D) Manual workflow

**Answer**: C
**Explanation**: VCS-driven workflow is recommended for production as it provides code review, audit trail, and automated deployment based on Git commits.

---

### Question 35
How can you restrict which file changes trigger Terraform runs in a VCS-connected workspace?

A) Use .gitignore file
B) Configure trigger_patterns in workspace settings
C) Disable auto-apply
D) Use branch protection rules

**Answer**: B
**Explanation**: The `trigger_patterns` setting allows you to specify which file paths should trigger Terraform runs (e.g., `**/*.tf`, `**/*.tfvars`).

---

### Question 36
What is the purpose of policy composition in Sentinel?

A) To combine multiple policies into one file
B) To import and reuse common functions across policies
C) To create policy hierarchies
D) To merge policy violations

**Answer**: B
**Explanation**: Policy composition allows you to create reusable function modules (like `common-functions.sentinel`) that can be imported into multiple policies, promoting code reuse and maintainability.

---

### Question 37
In Sentinel, what is the difference between `decimal.new(100)` and the integer `100`?

A) No difference, they are interchangeable
B) `decimal.new()` provides precise decimal arithmetic for cost calculations
C) `decimal.new()` is only for currency values
D) Integers are more accurate than decimals

**Answer**: B
**Explanation**: The `decimal` import provides precise decimal arithmetic, which is essential for accurate cost calculations where floating-point errors could accumulate. Regular integers/floats can have rounding errors.

---

### Question 38
How would you implement a time-based change freeze in Sentinel?

A) Use `time.now` to check current time against defined freeze periods
B) Configure freeze periods in HCP Terraform UI
C) Use cron expressions in the policy
D) Freeze periods cannot be implemented in Sentinel

**Answer**: A
**Explanation**: Sentinel's `time` import provides `time.now`, `time.load()`, `time.after()`, and `time.before()` functions to check if the current time falls within defined freeze periods.

---

### Question 39
What is the recommended approach for testing Sentinel policies?

A) Test only in production
B) Create mock data from real Terraform plans and use `sentinel test`
C) Manual testing in HCP Terraform
D) Unit tests are not needed for policies

**Answer**: B
**Explanation**: Best practice is to generate mock data using `terraform show -json tfplan`, create test cases for both pass and fail scenarios, and use `sentinel test` for automated testing before deploying policies.

---

### Question 40
In a multi-resource validation policy, how would you check if an RDS instance has Multi-AZ enabled?

A) `rc.change.after.multi_az == true`
B) `rc.multi_az.enabled`
C) `rc.config.multi_az`
D) Multi-AZ cannot be checked in Sentinel

**Answer**: A
**Explanation**: Resource attributes are accessed via `rc.change.after.<attribute_name>`. For RDS instances, `multi_az` is a boolean attribute that can be checked directly.

---

### Question 41
What is the base URL for the HCP Terraform API?

A) `https://terraform.io/api`
B) `https://app.terraform.io/api/v2`
C) `https://cloud.hashicorp.com/terraform/api`
D) `https://api.terraform.io/v2`

**Answer**: B
**Explanation**: The HCP Terraform API base URL is `https://app.terraform.io/api/v2`. All API endpoints are relative to this base URL.

---

### Question 42
Which HTTP header is required for authenticating with the HCP Terraform API?

A) `X-API-Key: Bearer <token>`
B) `Authorization: Bearer <token>`
C) `TFC-Token: <token>`
D) `API-Token: <token>`

**Answer**: B
**Explanation**: The HCP Terraform API uses the standard `Authorization: Bearer <token>` header for authentication, along with `Content-Type: application/vnd.api+json`.

---

### Question 43
What is the rate limit for the HCP Terraform API?

A) 10 requests per second per user
B) 30 requests per second per organization
C) 100 requests per minute per workspace
D) No rate limit

**Answer**: B
**Explanation**: The HCP Terraform API has a rate limit of 30 requests per second per organization, shared across all users and tokens in the organization.

---

### Question 44
Which API endpoint would you use to create a new run (queue a plan) in HCP Terraform?

A) `POST /workspaces/{id}/runs`
B) `POST /runs`
C) `POST /plans`
D) `POST /workspaces/{id}/queue-plan`

**Answer**: B
**Explanation**: To create a new run, you POST to `/runs` with the workspace ID in the request payload's relationships section.

---

### Question 45
What HTTP status code indicates a successful workspace creation via the API?

A) `200 OK`
B) `201 Created`
C) `202 Accepted`
D) `204 No Content`

**Answer**: B
**Explanation**: `201 Created` is returned for successful POST requests that create new resources. `200 OK` is for GET requests, `202 Accepted` for async operations, and `204 No Content` for successful DELETE requests.

---

## Scenario-Based Questions (3 questions)

### Scenario 1
You need to store a database password securely in Terraform. What approach would you use?

**Answer**:
1. Create secret in AWS Secrets Manager
2. Reference secret using data source
3. Mark variable as sensitive
4. Mark output as sensitive
5. Encrypt state file

---

### Scenario 2
You want to ensure only specific IAM users can modify Terraform state. How would you implement this?

**Answer**:
1. Create S3 bucket for state
2. Enable encryption
3. Create IAM policy with specific permissions
4. Attach policy to users
5. Enable state locking with DynamoDB

---

### Scenario 3
You need to build a secure VPC with public and private subnets. What components would you create?

**Answer**:
1. VPC with CIDR block
2. Public subnet for ALB
3. Private subnet for application
4. Security groups for each tier
5. NAT gateway for private subnet internet access

---

## Hands-On Exercises (2 exercises)

### Exercise 1: Implement Secrets Management
1. Create secret in AWS Secrets Manager
2. Write Terraform to reference secret
3. Mark variables as sensitive
4. Apply configuration
5. Verify secret is not exposed

### Exercise 2: Secure VPC Architecture
1. Create VPC with public/private subnets
2. Configure security groups
3. Implement least privilege access
4. Add compliance tagging
5. Verify network isolation

---

## Answer Key Summary

**Multiple Choice**: Questions 1-45
- Q1: B, Q2: C, Q3: D, Q4: B, Q5: D
- Q6: D, Q7: B, Q8: B, Q9: A, Q10: A
- Q11: A, Q12: B, Q13: B, Q14: C, Q15: B
- Q16: B, Q17: B, Q18: A, Q19: D, Q20: B
- Q21: A, Q22: C, Q23: B, Q24: B, Q25: B
- Q26: A, Q27: B, Q28: C, Q29: C, Q30: B
- Q31: B, Q32: B, Q33: C, Q34: C, Q35: B
- Q36: B, Q37: B, Q38: A, Q39: B, Q40: A
- Q41: B, Q42: B, Q43: B, Q44: B, Q45: B

**Scenario Questions**: 1-3
- See detailed answers above

**Hands-On Exercises**: 1-2
- Complete exercises and document results

---

## Scoring Guide

- **46-48 correct**: Excellent - Ready for certification exam
- **42-45 correct**: Good - Review weak areas
- **34-41 correct**: Passing - Study additional resources
- **Below 34**: Review Topic 12 content and retake

---

**Assessment Version**: 6.0
**Last Updated**: October 28, 2025
**Status**: Enhanced with Sentinel Policy, Team Management, VCS Integration, Advanced Sentinel Patterns, and HCP Terraform API Questions

