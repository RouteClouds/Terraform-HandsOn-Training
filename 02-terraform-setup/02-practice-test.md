# Setting up Terraform Environment - Practice Questions

## Section 1: Multiple Choice Questions

1. Which command verifies the Terraform installation?
   - [ ] `terraform --version`
   - [x] `terraform version`
   - [ ] `terraform check`
   - [ ] `terraform verify`

   **Explanation:** The command `terraform version` displays the installed version and verifies the installation.

2. What is the purpose of the `.terraform.lock.hcl` file?
   - [ ] Store state information
   - [x] Lock provider versions
   - [ ] Store credentials
   - [ ] Configure backends

   **Explanation:** The `.terraform.lock.hcl` file locks provider versions to ensure consistent environments.

3. Which AWS service is commonly used for Terraform state locking?
   - [ ] S3
   - [ ] RDS
   - [x] DynamoDB
   - [ ] EFS

   **Explanation:** DynamoDB provides the locking mechanism for Terraform state files when using S3 backend.

4. What is the recommended way to manage different AWS credentials for different environments?
   - [ ] Hard-code in configuration
   - [ ] Use environment variables only
   - [x] Use AWS profiles
   - [ ] Store in version control

   **Explanation:** AWS profiles provide a secure and flexible way to manage multiple sets of credentials.

## Section 2: Hands-on Exercises

### Exercise 1: Environment Setup Validation
**Task:** Create a script to validate the Terraform environment setup.

```bash
#!/bin/bash

# Check Terraform installation
terraform version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Terraform installed"
else
    echo "❌ Terraform not installed"
fi

# Check AWS CLI
aws --version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ AWS CLI installed"
else
    echo "❌ AWS CLI not installed"
fi

# Check Git
git --version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Git installed"
else
    echo "❌ Git not installed"
fi
```

### Exercise 2: Backend Configuration
**Task:** Write a Terraform configuration for S3 backend with state locking.

## Section 3: Scenario-Based Questions

1. **Development Team Setup**
   Your team is starting a new Terraform project. Describe the setup process considering:
   - Version control strategy
   - Backend configuration
   - Environment separation
   - Access management

2. **Troubleshooting Scenario**
   The team reports Terraform initialization failures. Describe your troubleshooting approach:
   - Initial checks
   - Common causes
   - Resolution steps
   - Prevention measures

## Section 4: Fill in the Blanks

1. The command to initialize a new Terraform working directory is ________.
   **Answer:** terraform init

2. To configure AWS credentials using AWS CLI, the command is ________.
   **Answer:** aws configure

3. The file used to ignore certain files in Git for Terraform projects is ________.
   **Answer:** .gitignore

## Section 5: True/False Questions

1. Terraform state files should always be committed to version control.
   - [ ] True
   - [x] False
   
   **Explanation:** State files often contain sensitive information and should be stored in a remote backend.

2. Multiple teams can safely work on the same Terraform configuration without state locking.
   - [ ] True
   - [x] False
   
   **Explanation:** State locking is crucial to prevent concurrent modifications and state corruption.

## Additional Practice Resources
- Review lab exercises
- Examine setup diagrams
- Practice with different backend configurations
