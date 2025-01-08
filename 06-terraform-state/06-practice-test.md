# Terraform State Management - Practice Questions

## Section 1: Multiple Choice Questions (25 points)

1. What is the primary purpose of Terraform state?
   - [ ] To create infrastructure documentation
   - [x] To track and map resources to your configuration
   - [ ] To generate deployment scripts
   - [ ] To validate configuration syntax

   **Explanation:** Terraform state tracks the resources it manages and maps them to your configuration, enabling it to know what resources exist and need to be modified.

2. Which backend type is recommended for team environments?
   - [ ] Local backend
   - [x] Remote backend (like S3)
   - [ ] No backend
   - [ ] Console backend

   **Explanation:** Remote backends enable team collaboration, state locking, and secure storage of state files.

3. What is the purpose of state locking?
   - [ ] To encrypt state files
   - [ ] To compress state data
   - [x] To prevent concurrent state modifications
   - [ ] To backup state files

   **Explanation:** State locking prevents multiple team members from modifying state simultaneously, avoiding conflicts and corruption.

4. Which command is used to view a specific resource in the state file?
   - [ ] terraform list
   - [ ] terraform show
   - [x] terraform state show
   - [ ] terraform state list

   **Explanation:** `terraform state show` displays detailed information about a specific resource in the state.

5. What happens if you delete the state file?
   - [ ] Nothing, Terraform will recreate it
   - [ ] Resources are automatically destroyed
   - [x] Terraform loses track of managed resources
   - [ ] Configuration becomes invalid

   **Explanation:** Deleting the state file causes Terraform to lose track of resources it manages, potentially leading to duplicate resources on the next apply.

## Section 2: Hands-on Exercises (35 points)

### Exercise 1: Configure Remote Backend (15 points)
**Task:** Set up an S3 backend with DynamoDB state locking.

```hcl
# Write the backend configuration
terraform {
  backend "s3" {
    bucket         = "YOUR_BUCKET_NAME"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Success Criteria:**
- [ ] S3 bucket created with versioning enabled
- [ ] DynamoDB table created with correct schema
- [ ] Backend configuration working
- [ ] State locking functional

### Exercise 2: State Operations (20 points)
**Task:** Perform various state operations:
1. List resources in state
2. Move a resource
3. Import an existing resource
4. Remove a resource from state

```bash
# List resources
terraform state list

# Move resource
terraform state mv aws_instance.example aws_instance.new_name

# Import resource
terraform import aws_security_group.imported sg-1234567

# Remove resource
terraform state rm aws_instance.old
```

## Section 3: Scenario-Based Questions (25 points)

1. **Team Collaboration Scenario**
   Your team reports state file conflicts. Describe your solution considering:
   - State locking implementation
   - Backend configuration
   - Workspace usage
   - Team workflow

   **Expected Answer Points:**
   - Implement remote backend with S3 and DynamoDB
   - Configure state locking
   - Use workspaces for environment isolation
   - Establish clear team workflow

2. **State Migration Scenario**
   You need to migrate from local state to remote state. Outline your approach:
   - Backup strategy
   - Migration steps
   - Validation process
   - Rollback plan

## Section 4: True/False Questions (15 points)

1. Terraform state files should be committed to version control.
   - [ ] True
   - [x] False
   
   **Explanation:** State files often contain sensitive information and should be stored in remote backends, not version control.

2. Multiple workspaces can share the same state file.
   - [ ] True
   - [x] False
   
   **Explanation:** Each workspace maintains its own state file to ensure environment isolation.

3. State locking is only necessary in team environments.
   - [ ] True
   - [x] False
   
   **Explanation:** State locking is important even in single-user scenarios to prevent concurrent modifications from multiple commands.

## Section 5: Fill in the Blanks

1. The command to initialize a backend configuration is ________.
   **Answer:** terraform init

2. The DynamoDB table for state locking must have ________ as the partition key.
   **Answer:** LockID

3. The ________ command is used to manually reconcile state with real infrastructure.
   **Answer:** terraform refresh

## Additional Practice Resources

### State Commands Reference
```bash
# State Management Commands
terraform state list
terraform state show
terraform state mv
terraform state rm
terraform state pull
terraform state push
terraform import
terraform refresh
```

### Common State Problems and Solutions

1. **Lost State File**
   ```bash
   # Recreate state through import
   terraform import aws_instance.example i-1234567
   ```

2. **State Lock Issues**
   ```bash
   # Force unlock (use with caution)
   terraform force-unlock LOCK_ID
   ```

3. **State Version Conflicts**
   ```bash
   # Pull latest state
   terraform state pull > terraform.tfstate
   terraform state push terraform.tfstate
   ```

## Best Practices Checklist
- [ ] Use remote backend
- [ ] Enable state locking
- [ ] Enable backend encryption
- [ ] Regular state backups
- [ ] Document state operations
- [ ] Use workspaces for isolation
- [ ] Implement proper access controls 

## Section 6: Advanced Concepts (20 points)

1. What happens when you run `terraform refresh`? (Choose all that apply)
   - [x] Updates state file to match real infrastructure
   - [x] Detects drift in resources
   - [ ] Modifies real infrastructure
   - [x] Updates resource attributes in state

   **Explanation:** `terraform refresh` updates the state file to match real-world resources without modifying infrastructure.

2. When using workspaces with an S3 backend, how are state files typically organized?
   - [ ] All workspaces share one state file
   - [ ] Each workspace uses a different bucket
   - [x] State files are stored in different key paths
   - [ ] Workspaces don't work with S3 backend

   **Explanation:** S3 backend stores workspace states in different key paths like `env:/workspace-name/terraform.tfstate`.

3. What is the purpose of the `-state-out` flag in `terraform state mv`?
   - [ ] To backup state file
   - [x] To specify a different destination state file
   - [ ] To rename state file
   - [ ] To encrypt state file

   **Explanation:** `-state-out` allows moving resources to a different state file.

## Section 7: Troubleshooting Scenarios (30 points)

### Scenario 1: State Lock Timeout
You receive the error: "Error acquiring the state lock: timeout while waiting for state lock"

**What are the appropriate steps to resolve this? (Order them correctly)**
1. Check if another operation is running
2. Verify DynamoDB table status
3. Check CloudWatch logs for lock info
4. Use force-unlock if necessary (with caution)

### Scenario 2: State File Corruption
Your team member reports: "Error loading state: state file is corrupt or invalid"

**What should be your approach?**
1. Immediate actions:
   - [ ] Backup current state file
   - [ ] Check state file version
   - [ ] Attempt state recovery

2. Recovery steps:
   - [ ] Use latest state backup
   - [ ] Refresh state with real infrastructure
   - [ ] Validate state consistency

### Scenario 3: Missing Resources
After a failed apply, some resources are missing from state but exist in AWS.

**How would you resolve this?**
bash
# Steps to resolve:
1. List existing resources
aws ec2 describe-instances --filters "Name=tag:Environment,Values=Production"

2. Import missing resources
terraform import aws_instance.example i-1234567

3. Verify state
terraform state list
terraform state show aws_instance.example
```

## Section 8: State Management Best Practices (20 points)

1. Which of these is NOT a recommended practice for state management?
   - [ ] Using remote backends
   - [ ] Enabling state locking
   - [x] Storing sensitive data in state files
   - [ ] Regular state backups

2. For a multi-environment setup, which approach is recommended?
   - [ ] Single state file for all environments
   - [ ] Local state files with Git
   - [x] Separate state files with workspaces
   - [ ] Manual state file management

3. When should you use `terraform state rm`?
   - [ ] To delete resources from infrastructure
   - [x] To remove resources from state without destroying them
   - [ ] To clean up old state files
   - [ ] To remove backend configuration

## Section 9: Practical Exercises (30 points)

### Exercise 3: State Migration
**Task:** Migrate from local state to S3 backend with the following requirements:
- Maintain resource state
- Enable encryption
- Configure state locking
- Validate migration

```hcl
# Backend configuration
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Exercise 4: Workspace Management
**Task:** Set up and manage multiple workspaces:

```bash
# Create workspaces
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# List workspaces
terraform workspace list

# Select workspace
terraform workspace select development

# Show current workspace
terraform workspace show
```

## Section 10: State File Analysis (15 points)

Review the following state file excerpt and answer the questions:

```json
{
  "version": 4,
  "terraform_version": "1.0.0",
  "serial": 5,
  "lineage": "3827d000-a2a9-...",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_vpc",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "cidr_block": "10.0.0.0/16",
            "enable_dns_hostnames": true,
            "tags": {
              "Name": "main-vpc",
              "Environment": "production"
            }
          }
        }
      ]
    }
  ]
}
```

Questions:
1. What is the state file version?
2. How many resources are tracked?
3. What provider is being used?
4. What are the VPC's DNS settings?
[Previous content continues...]
```