# VCS-Driven Workflow Guide

## Overview

This document describes the VCS-driven workflow implementation for the Multi-Environment Infrastructure Pipeline project using GitHub Actions.

---

## Table of Contents

1. [Workflow Architecture](#workflow-architecture)
2. [GitHub Actions Workflows](#github-actions-workflows)
3. [Branch Strategy](#branch-strategy)
4. [Deployment Process](#deployment-process)
5. [Drift Detection](#drift-detection)
6. [Security and Secrets](#security-and-secrets)
7. [Troubleshooting](#troubleshooting)

---

## Workflow Architecture

### Overview

The project implements a complete GitOps workflow where infrastructure changes are managed through Git operations:

```
Developer → Git Push → GitHub → GitHub Actions → Terraform → AWS
```

### Workflow Types by Environment

| Environment | Trigger | Plan | Apply | Approval Required |
|-------------|---------|------|-------|-------------------|
| **Development** | Push to `main` or PR | Automatic | Automatic | No |
| **Staging** | Manual dispatch | Automatic | Manual | Yes (1 reviewer) |
| **Production** | Manual dispatch | Automatic | Manual | Yes (2 reviewers) |

### Benefits

- ✅ **Audit Trail**: All changes tracked in Git history
- ✅ **Code Review**: PR-based workflow ensures peer review
- ✅ **Automation**: Reduces manual errors
- ✅ **Consistency**: Same process across environments
- ✅ **Rollback**: Easy to revert changes via Git
- ✅ **Visibility**: Team can see all infrastructure changes

---

## GitHub Actions Workflows

### 1. Development Workflow (`terraform-dev.yml`)

**Purpose**: Fast iteration and testing in development environment

**Triggers**:
- Pull request to `main` branch
- Push to `main` branch

**Steps**:
1. Checkout code
2. Setup Terraform
3. Terraform format check
4. Terraform init (with dev backend config)
5. Terraform validate
6. Terraform plan (on PR)
7. Post plan as PR comment
8. Terraform apply (on merge to main)

**Key Features**:
- Automatic apply on merge (no approval needed)
- Plan output posted as PR comment
- Fast feedback loop

**Example Workflow File**:

```yaml
name: Terraform Dev

on:
  pull_request:
    branches: [main]
    paths:
      - 'terraform-manifests/**'
      - 'environments/dev/**'
  push:
    branches: [main]
    paths:
      - 'terraform-manifests/**'
      - 'environments/dev/**'

jobs:
  terraform:
    name: 'Terraform Dev'
    runs-on: ubuntu-latest
    environment: development
    
    defaults:
      run:
        working-directory: ./terraform-manifests
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.13.0
    
    - name: Terraform Format
      id: fmt
      run: terraform fmt -check -recursive
      continue-on-error: true
    
    - name: Terraform Init
      id: init
      run: terraform init -backend-config=../environments/dev/backend-config.hcl
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color
    
    - name: Terraform Plan
      id: plan
      if: github.event_name == 'pull_request'
      run: terraform plan -var-file=../environments/dev/terraform.tfvars -no-color
      continue-on-error: true
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Update Pull Request
      uses: actions/github-script@v7
      if: github.event_name == 'pull_request'
      env:
        PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const output = `#### Terraform Format 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
          #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`
          
          <details><summary>Show Plan</summary>
          
          \`\`\`\n
          ${process.env.PLAN}
          \`\`\`
          
          </details>
          
          *Environment: development*
          *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })
    
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -var-file=../environments/dev/terraform.tfvars -auto-approve
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### 2. Staging Workflow (`terraform-staging.yml`)

**Purpose**: Pre-production validation with manual approval

**Triggers**:
- Manual workflow dispatch
- Optionally: Push to `main` (after dev deployment)

**Steps**:
1. Checkout code
2. Setup Terraform
3. Terraform init (with staging backend config)
4. Terraform plan
5. **Manual approval required** (1 reviewer)
6. Terraform apply

**Key Features**:
- Manual trigger for controlled deployments
- Requires 1 reviewer approval
- Production-like configuration

### 3. Production Workflow (`terraform-prod.yml`)

**Purpose**: Controlled production deployments with strict approval

**Triggers**:
- Manual workflow dispatch only

**Steps**:
1. Checkout code
2. Setup Terraform
3. Terraform init (with prod backend config)
4. Terraform plan
5. **Manual approval required** (2 reviewers)
6. Terraform apply
7. Post-deployment verification

**Key Features**:
- Manual trigger only (no automatic deployments)
- Requires 2 reviewer approvals
- Enhanced monitoring and verification
- Rollback plan documented

### 4. Drift Detection Workflow (`drift-detection.yml`)

**Purpose**: Detect configuration drift across all environments

**Triggers**:
- Scheduled: Daily at 9 AM UTC
- Manual workflow dispatch

**Steps**:
1. For each environment (dev, staging, prod):
   - Checkout code
   - Setup Terraform
   - Terraform init
   - Terraform plan (detect drift)
   - If drift detected: Create GitHub issue

**Key Features**:
- Runs daily automatically
- Creates issues for drift detection
- Assigns to infrastructure team
- Includes plan output in issue

**Example Drift Detection Workflow**:

```yaml
name: Drift Detection

on:
  schedule:
    - cron: '0 9 * * *'  # Daily at 9 AM UTC
  workflow_dispatch:

jobs:
  drift-check:
    name: 'Check Drift - ${{ matrix.environment }}'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging, prod]
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.13.0
    
    - name: Terraform Init
      run: terraform init -backend-config=../environments/${{ matrix.environment }}/backend-config.hcl
      working-directory: ./terraform-manifests
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Terraform Plan (Drift Check)
      id: plan
      run: |
        terraform plan -var-file=../environments/${{ matrix.environment }}/terraform.tfvars -detailed-exitcode -no-color || echo "drift_detected=true" >> $GITHUB_OUTPUT
      working-directory: ./terraform-manifests
      continue-on-error: true
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Create Issue if Drift Detected
      if: steps.plan.outputs.drift_detected == 'true'
      uses: actions/github-script@v7
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          github.rest.issues.create({
            owner: context.repo.owner,
            repo: context.repo.repo,
            title: '⚠️ Configuration Drift Detected - ${{ matrix.environment }}',
            body: `**Environment**: ${{ matrix.environment }}
            **Detected**: ${new Date().toISOString()}
            
            **Action Required**:
            1. Review the drift in the workflow run
            2. Determine if drift should be imported or reverted
            3. Update Terraform code if needed
            4. Run terraform apply to reconcile state
            
            **Workflow Run**: ${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`,
            labels: ['drift-detection', 'infrastructure', '${{ matrix.environment }}'],
            assignees: ['infrastructure-team']
          })
```

---

## Branch Strategy

### Branch Structure

```
main (production-ready code)
  ├── feature/add-monitoring
  ├── feature/update-instance-types
  ├── feature/add-new-service
  └── hotfix/security-patch
```

### Branch Types

**1. Main Branch**
- Protected branch
- Requires PR reviews (2 approvers)
- Requires status checks to pass
- Represents production-ready code
- Deployments to dev happen automatically on merge

**2. Feature Branches**
- Created from `main`
- Naming: `feature/<description>`
- Used for new features or enhancements
- Merged via PR after review

**3. Hotfix Branches**
- Created from `main`
- Naming: `hotfix/<description>`
- Used for urgent fixes
- Fast-tracked review process
- Merged via PR with expedited approval

### Branch Protection Rules

Configure the following for `main` branch:

```yaml
Branch Protection Rules for 'main':
  ✅ Require pull request reviews before merging
     - Required approving reviews: 2
     - Dismiss stale pull request approvals when new commits are pushed
     - Require review from Code Owners
  
  ✅ Require status checks to pass before merging
     - Require branches to be up to date before merging
     - Status checks that are required:
       - Terraform Format
       - Terraform Plan - Dev
  
  ✅ Require conversation resolution before merging
  
  ✅ Require signed commits (optional)
  
  ✅ Include administrators (enforce rules for admins)
  
  ✅ Restrict who can push to matching branches
     - Only: infrastructure-team
```

---

## Deployment Process

### Feature Development Workflow

**Step 1: Create Feature Branch**

```bash
# Update main branch
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/add-cloudwatch-monitoring
```

**Step 2: Make Infrastructure Changes**

```bash
# Edit Terraform files
vim terraform-manifests/main.tf

# Add CloudWatch dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-monitoring"
  dashboard_body = jsonencode({
    widgets = [
      # ... dashboard configuration
    ]
  })
}
```

**Step 3: Test Locally (Optional)**

```bash
cd terraform-manifests
terraform init -backend-config=../environments/dev/backend-config.hcl
terraform plan -var-file=../environments/dev/terraform.tfvars
```

**Step 4: Commit and Push**

```bash
git add .
git commit -m "Add CloudWatch monitoring dashboard"
git push origin feature/add-cloudwatch-monitoring
```

**Step 5: Create Pull Request**

```bash
# Using GitHub CLI
gh pr create \
  --title "Add CloudWatch monitoring dashboard" \
  --body "Adds CloudWatch dashboard for monitoring key metrics" \
  --base main \
  --head feature/add-cloudwatch-monitoring
```

**Step 6: Review Plan Output**

- GitHub Actions automatically runs `terraform plan`
- Plan output is posted as PR comment
- Review the plan for expected changes
- Request reviews from team members

**Step 7: Address Review Comments**

```bash
# Make requested changes
vim terraform-manifests/main.tf

# Commit and push
git add .
git commit -m "Address review comments"
git push origin feature/add-cloudwatch-monitoring

# Plan runs automatically again
```

**Step 8: Merge PR**

```bash
# After approval, merge via GitHub UI or CLI
gh pr merge --squash --delete-branch
```

**Step 9: Automatic Dev Deployment**

- Merge to `main` triggers automatic deployment to dev
- Monitor GitHub Actions workflow
- Verify changes in AWS console

### Staging Deployment

**Step 1: Trigger Staging Workflow**

```bash
# Via GitHub CLI
gh workflow run terraform-staging.yml

# Or via GitHub UI:
# Actions → Terraform Staging → Run workflow
```

**Step 2: Review Plan**

- Workflow runs `terraform plan`
- Review plan output in workflow logs
- Verify expected changes

**Step 3: Approve Deployment**

- Navigate to workflow run
- Click "Review deployments"
- Select "staging" environment
- Click "Approve and deploy"

**Step 4: Monitor Apply**

- Watch workflow progress
- Verify successful completion
- Check AWS console for changes

**Step 5: Validate Staging**

```bash
# Run smoke tests
./scripts/smoke-test.sh staging

# Verify application functionality
curl https://staging.example.com/health
```

### Production Deployment

**Step 1: Validate Staging**

- Ensure staging deployment is successful
- Run full test suite
- Verify all functionality

**Step 2: Trigger Production Workflow**

```bash
# Via GitHub CLI
gh workflow run terraform-prod.yml

# Or via GitHub UI:
# Actions → Terraform Production → Run workflow
```

**Step 3: Review Plan Carefully**

- Review plan output thoroughly
- Verify no unexpected changes
- Check for potential impact
- Discuss with team if needed

**Step 4: Obtain Approvals**

- Requires 2 approvals
- Approvers review plan output
- Approvers verify change window
- Approvers click "Approve and deploy"

**Step 5: Monitor Apply**

- Watch workflow progress closely
- Monitor CloudWatch metrics
- Check application health endpoints
- Be ready to rollback if needed

**Step 6: Post-Deployment Verification**

```bash
# Run smoke tests
./scripts/smoke-test.sh prod

# Verify application functionality
curl https://prod.example.com/health

# Check CloudWatch dashboards
# Verify no errors in logs
```

**Step 7: Document Deployment**

- Update deployment log
- Document any issues encountered
- Update runbook if needed

---

## Drift Detection

### What is Drift?

Configuration drift occurs when infrastructure is modified outside of Terraform (e.g., manual changes in AWS console).

### Drift Detection Workflow

The drift detection workflow runs daily and:

1. Runs `terraform plan` for each environment
2. Checks exit code:
   - `0`: No changes (no drift)
   - `1`: Error
   - `2`: Changes detected (drift)
3. Creates GitHub issue if drift detected

### Handling Drift

**Option 1: Import Drift into Terraform**

If the manual change should be kept:

```bash
# Update Terraform code to match current state
vim terraform-manifests/main.tf

# Run plan to verify
terraform plan

# Commit changes
git add .
git commit -m "Import manual changes to Terraform"
git push
```

**Option 2: Revert Drift**

If the manual change should be reverted:

```bash
# Run terraform apply to revert to desired state
terraform apply

# This will undo the manual changes
```

### Preventing Drift

- Use IAM policies to restrict manual changes
- Enable CloudTrail for audit logging
- Use AWS Config rules
- Educate team on Terraform-only changes
- Use Sentinel policies (if using Terraform Cloud)

---

## Security and Secrets

### GitHub Secrets

Configure the following secrets in repository settings:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key for Terraform | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for Terraform | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `TF_API_TOKEN` | Terraform Cloud token (optional) | `xxxxxx.atlasv1.xxxxxx` |

### GitHub Environments

Configure three environments with protection rules:

**Development Environment**:
- No protection rules
- Automatic deployments allowed

**Staging Environment**:
- Required reviewers: 1
- Wait timer: 0 minutes
- Deployment branches: `main` only

**Production Environment**:
- Required reviewers: 2
- Wait timer: 5 minutes (optional)
- Deployment branches: `main` only
- Environment secrets (if different from repo secrets)

### Best Practices

- ✅ Use IAM roles instead of access keys (if using OIDC)
- ✅ Rotate secrets regularly
- ✅ Use least privilege IAM policies
- ✅ Enable MFA for GitHub accounts
- ✅ Use branch protection rules
- ✅ Enable audit logging
- ✅ Review access regularly

---

## Troubleshooting

### Common Issues

**Issue 1: Workflow Fails with "Backend Initialization Failed"**

**Cause**: Backend configuration incorrect or S3 bucket doesn't exist

**Solution**:
```bash
# Verify backend configuration
cat environments/dev/backend-config.hcl

# Verify S3 bucket exists
aws s3 ls s3://terraform-state-{account-id}

# Verify DynamoDB table exists
aws dynamodb describe-table --table-name terraform-locks-dev
```

**Issue 2: Plan Shows Unexpected Changes**

**Cause**: Configuration drift or state file out of sync

**Solution**:
```bash
# Refresh state
terraform refresh

# Review changes carefully
terraform plan

# If drift, decide to import or revert
```

**Issue 3: State Lock Error**

**Cause**: Previous workflow didn't release lock

**Solution**:
```bash
# Check DynamoDB for lock
aws dynamodb scan --table-name terraform-locks-dev

# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

**Issue 4: Approval Not Showing**

**Cause**: Environment not configured or user not in reviewers list

**Solution**:
- Verify environment exists in repository settings
- Verify user is in required reviewers list
- Check environment protection rules

**Issue 5: Workflow Triggered Unexpectedly**

**Cause**: Path filters not configured correctly

**Solution**:
```yaml
# Update workflow to include path filters
on:
  push:
    branches: [main]
    paths:
      - 'terraform-manifests/**'
      - 'environments/dev/**'
```

---

**Document Version**: 1.0  
**Last Updated**: October 28, 2025  
**Author**: RouteCloud Training Team

