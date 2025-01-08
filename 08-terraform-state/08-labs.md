# Terraform State - Labs

## Lab 1: State Manipulation and Inspection

### Objective
Learn how to inspect, manipulate and understand Terraform state files.

### Tasks
1. Create a new directory called `state-lab-1` and initialize a new Terraform configuration
2. Create the following resources:
   - An AWS VPC
   - Two subnets in different availability zones
   - A security group
3. After applying the configuration, use the following state commands and document what each one does:
   ```bash
   terraform show
   terraform state list
   terraform state show aws_vpc.main
   ```
4. Try to rename one of your resources using:
   ```bash
   terraform state mv aws_subnet.subnet1 aws_subnet.private_subnet1
   ```
5. Remove one of the subnets from state (without destroying it) using:
   ```bash
   terraform state rm aws_subnet.subnet2
   ```

### Success Criteria
- You can explain the output of each state command
- You successfully renamed a resource in the state
- You removed a resource from state without destroying the actual infrastructure

## Lab 2: Working with Workspaces

### Objective
Learn how to use Terraform workspaces to manage multiple environments.

### Tasks
1. Create a new directory called `workspace-lab` with a basic configuration that creates:
   - An S3 bucket
   - A DynamoDB table
2. Use workspace commands to:
   ```bash
   terraform workspace new development
   terraform workspace new staging
   terraform workspace new production
   ```
3. Modify your configuration to use workspace-specific names for resources:
   ```hcl
   resource "aws_s3_bucket" "example" {
     bucket = "my-app-${terraform.workspace}-data"
   }
   ```
4. Apply your configuration in each workspace
5. List all workspaces and switch between them:
   ```bash
   terraform workspace list
   terraform workspace select development
   ```

### Success Criteria
- You have created and managed multiple workspaces
- Resources are properly named according to the workspace
- You can switch between workspaces and show different state files

## Lab 3: Remote State Backend Configuration

### Objective
Configure and use a remote backend for storing Terraform state.

### Tasks
1. Create a new directory called `remote-state-lab`
2. Create an S3 bucket and DynamoDB table for state locking:
   - S3 bucket with versioning enabled
   - DynamoDB table with a primary key named `LockID`
3. Configure your backend in a new configuration:
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "your-terraform-state-bucket"
       key            = "lab3/terraform.tfstate"
       region         = "us-west-2"
       dynamodb_table = "terraform-state-lock"
       encrypt        = true
     }
   }
   ```
4. Create some test resources (e.g., VPC, subnet)
5. Apply the configuration and verify the state is stored in S3
6. Try to run apply from two different terminals to test state locking

### Success Criteria
- State is successfully stored in S3
- State locking works when attempting concurrent operations
- You can explain the benefits of remote state storage

### Additional Challenge
- Try to import an existing AWS resource into your Terraform state
- Configure state backup using S3 versioning
- Share state between two different Terraform configurations using data sources
