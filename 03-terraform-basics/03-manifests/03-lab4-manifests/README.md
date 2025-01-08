# Lab 4: State Management

## Overview
Managing Terraform state using remote backend and implementing state locking.

## Files
- `main.tf` - State configuration and example resources
- `variables.tf` - State management variables
- `outputs.tf` - State outputs
- `terraform.tfvars` - Variable values

## Prerequisites
- Completed Labs 1-3
- Understanding of S3 and DynamoDB
- Knowledge of state concepts

## Resources Created
1. S3 bucket for state storage
2. DynamoDB table for state locking
3. Example VPC resources
4. State backend configuration

## Instructions
1. Create state storage infrastructure
2. Configure remote backend
3. Implement state locking
4. Test concurrent access
5. Perform state operations
6. Clean up resources

## Validation Steps
- [ ] State bucket created
- [ ] Encryption enabled
- [ ] DynamoDB table configured
- [ ] State locking functional
- [ ] Remote backend working
- [ ] State operations successful 

## Troubleshooting Guide

### 1. State Backend Issues
- **Problem**: S3 bucket access denied
  - Check IAM permissions
  - Verify bucket exists
  - Confirm bucket policy

- **Problem**: DynamoDB table issues
  - Ensure table exists
  - Check table schema
  - Verify partition key

### 2. State Locking Problems
- **Problem**: Lock acquisition timeout
  - Check for stale locks
  - Verify DynamoDB permissions
  - Confirm table configuration

### 3. State Operation Issues
- **Problem**: State refresh fails
  - Check backend configuration
  - Verify credentials
  - Confirm resource existence

### Common Error Messages
```bash
# Backend Configuration Error
Error: Failed to get existing workspaces: S3 bucket does not exist
Solution: Create bucket before backend configuration

# State Locking Error
Error: Error acquiring the state lock
Solution: Check for and clear stale locks

# State Operation Error
Error: Failed to load state: AccessDenied
Solution: Verify IAM permissions for S3 and DynamoDB
```

### State Recovery Steps
1. Backup current state:
```bash
cp terraform.tfstate terraform.tfstate.backup
```

2. Fix corrupted state:
```bash
terraform state pull > terraform.tfstate
terraform state push terraform.tfstate
```

3. Force unlock state:
```bash
terraform force-unlock LOCK_ID
```

## Best Practices
1. Always use remote state in production
2. Enable versioning on state bucket
3. Implement state locking
4. Backup state regularly
5. Use proper access controls