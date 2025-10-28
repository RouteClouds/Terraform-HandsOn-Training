# Topic 12: Hands-On Labs - Advanced Security & Compliance

**Estimated Time**: 7.5-9.5 hours
**Difficulty**: Advanced
**Prerequisites**: Topics 1-11 completed

---

## Lab Overview

This lab series covers six critical security and collaboration scenarios:
1. **Lab 12.1**: Implement Secrets Management
2. **Lab 12.2**: Secure State File Management
3. **Lab 12.3**: Build Secure VPC Architecture
4. **Lab 12.4**: Sentinel Policy Implementation
5. **Lab 12.5**: Team Management and RBAC
6. **Lab 12.6**: VCS-Driven Workflow (NEW)

---

## Lab 12.1: Implement Secrets Management

### Objective
Securely manage database passwords using AWS Secrets Manager.

### Prerequisites
- AWS account with Secrets Manager access
- Terraform installed
- AWS CLI configured

### Step 1: Create Secret

```bash
aws secretsmanager create-secret \
  --name prod/db/password \
  --secret-string '{"username":"admin","password":"SecurePassword123!"}'
```

### Step 2: Create Terraform Configuration

```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db/password"
}

locals {
  db_secret = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}

resource "aws_db_instance" "main" {
  username = local.db_secret.username
  password = local.db_secret.password
}
```

### Step 3: Mark as Sensitive

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}

output "db_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = false
}
```

### Step 4: Apply Configuration

```bash
terraform apply
```

### Step 5: Verify

```bash
terraform output
# Password output should be redacted
```

---

## Lab 12.2: Secure State File Management

### Objective
Configure encrypted S3 backend with state locking.

### Prerequisites
- S3 bucket created
- DynamoDB table created
- KMS key created

### Step 1: Create Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789:key/12345678"
  }
}
```

### Step 2: Enable Encryption

```bash
aws s3api put-bucket-encryption \
  --bucket terraform-state-prod \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:us-east-1:123456789:key/12345678"
      }
    }]
  }'
```

### Step 3: Enable Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket terraform-state-prod \
  --versioning-configuration Status=Enabled
```

### Step 4: Migrate State

```bash
terraform init
# Confirm migration to S3 backend
```

### Step 5: Verify

```bash
terraform state list
# Should work with remote state
```

---

## Lab 12.3: Build Secure VPC Architecture

### Objective
Design and implement a secure VPC with public/private subnets.

### Prerequisites
- Terraform initialized
- AWS credentials configured

### Step 1: Create VPC

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

### Step 2: Create Subnets

```hcl
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}
```

### Step 3: Create Security Groups

```hcl
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Step 4: Apply Configuration

```bash
terraform apply
```

### Step 5: Verify

```bash
terraform output
# Verify VPC and subnet IDs
```

---

## Lab 12.4: Sentinel Policy Implementation

### Objective
Implement and test Sentinel policies for governance and compliance in HCP Terraform.

### Prerequisites
- HCP Terraform account (sign up at https://app.terraform.io)
- Terraform installed locally
- AWS account with appropriate permissions
- Completed Labs 12.1-12.3

### Estimated Time
90 minutes

### Step 1: Set Up HCP Terraform Workspace

```bash
# Create a new directory for this lab
mkdir -p ~/terraform-labs/lab-12.4-sentinel
cd ~/terraform-labs/lab-12.4-sentinel

# Initialize Terraform configuration
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"

  cloud {
    organization = "YOUR_ORG_NAME"  # Replace with your org

    workspaces {
      name = "dev-sentinel-lab"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Test resources for Sentinel policies
resource "aws_s3_bucket" "test" {
  bucket = "sentinel-test-bucket-${random_id.suffix.hex}"

  tags = {
    Environment = "dev"
    Owner       = "your.email@example.com"
    CostCenter  = "Engineering"
    Project     = "SentinelLab"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test" {
  bucket = aws_s3_bucket.test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_instance" "test" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type = "t3.micro"

  tags = {
    Environment = "dev"
    Owner       = "your.email@example.com"
    CostCenter  = "Engineering"
    Project     = "SentinelLab"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
EOF
```

### Step 2: Create Sentinel Policies in HCP Terraform

**Option A: Using the UI**

1. Log in to HCP Terraform (https://app.terraform.io)
2. Navigate to **Settings** → **Policy Sets**
3. Click **Create a new policy set**
4. Select **API-driven workflow**
5. Name: `security-policies`
6. Upload the policy files from `12-terraform-security/sentinel-policies/`

**Option B: Using Terraform (Recommended)**

```bash
# Create policy management configuration
cat > policies.tf << 'EOF'
terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.51"
    }
  }
}

provider "tfe" {
  # Token set via TFE_TOKEN environment variable
}

variable "organization_name" {
  description = "HCP Terraform organization name"
  type        = string
}

# Create policy set
resource "tfe_policy_set" "security" {
  name         = "security-policies"
  description  = "Security and compliance policies for Terraform"
  organization = var.organization_name

  policy_ids = [
    tfe_sentinel_policy.s3_encryption.id,
    tfe_sentinel_policy.required_tags.id,
    tfe_sentinel_policy.instance_types.id,
  ]

  workspace_ids = [
    data.tfe_workspace.dev.id,
  ]
}

# Policy: Require S3 Encryption
resource "tfe_sentinel_policy" "s3_encryption" {
  name         = "require-s3-encryption"
  description  = "Require encryption for all S3 buckets"
  organization = var.organization_name
  policy       = file("../../12-terraform-security/sentinel-policies/require-s3-encryption.sentinel")
  enforce_mode = "hard-mandatory"
}

# Policy: Required Tags
resource "tfe_sentinel_policy" "required_tags" {
  name         = "require-tags"
  description  = "Enforce required tags on all resources"
  organization = var.organization_name
  policy       = file("../../12-terraform-security/sentinel-policies/require-tags.sentinel")
  enforce_mode = "hard-mandatory"
}

# Policy: Instance Type Restrictions
resource "tfe_sentinel_policy" "instance_types" {
  name         = "restrict-instance-types"
  description  = "Limit instance types by environment"
  organization = var.organization_name
  policy       = file("../../12-terraform-security/sentinel-policies/restrict-instance-types.sentinel")
  enforce_mode = "soft-mandatory"
}

data "tfe_workspace" "dev" {
  name         = "dev-sentinel-lab"
  organization = var.organization_name
}
EOF

# Set your HCP Terraform token
export TFE_TOKEN="your-terraform-cloud-token"

# Apply policy configuration
terraform init
terraform apply -var="organization_name=YOUR_ORG_NAME"
```

### Step 3: Test Policy Enforcement

**Test 1: Compliant Configuration (Should Pass)**

```bash
# Run terraform plan
terraform init
terraform plan

# Expected: All policies pass
```

**Test 2: Missing S3 Encryption (Should Fail)**

```bash
# Edit main.tf - remove encryption configuration
# Then run:
terraform plan

# Expected: Policy failure - "require-s3-encryption" blocks the run
```

**Test 3: Missing Required Tags (Should Fail)**

```bash
# Edit main.tf - remove tags from instance
# Then run:
terraform plan

# Expected: Policy failure - "require-tags" blocks the run
```

**Test 4: Invalid Instance Type (Should Warn)**

```bash
# Edit main.tf - change instance_type to "m5.4xlarge"
# Then run:
terraform plan

# Expected: Soft-mandatory policy failure - can be overridden
```

### Step 4: Override Soft-Mandatory Policy

1. Navigate to the failed run in HCP Terraform UI
2. Review the policy failure message
3. Click **Override & Continue**
4. Provide justification: "Testing override functionality for Lab 12.4"
5. Confirm override

### Step 5: View Policy Run History

1. In HCP Terraform, navigate to **Settings** → **Policy Sets**
2. Click on `security-policies`
3. View **Policy Checks** tab
4. Analyze pass/fail rates and common violations

### Step 6: Clean Up

```bash
# Destroy test resources
terraform destroy -auto-approve
```

### Lab Deliverables

- [ ] HCP Terraform workspace created
- [ ] Sentinel policies uploaded and configured
- [ ] Policy set attached to workspace
- [ ] All test scenarios executed
- [ ] Policy violations observed and documented
- [ ] Soft-mandatory override tested
- [ ] Policy run history reviewed

### Key Learnings

✅ Sentinel policies enforce governance before infrastructure deployment
✅ Hard-mandatory policies cannot be overridden
✅ Soft-mandatory policies allow overrides with justification
✅ Policy as code enables automated compliance
✅ HCP Terraform provides policy run history and analytics

### Troubleshooting

**Issue**: Policy not triggering
- **Solution**: Verify policy set is attached to workspace, check enforcement level

**Issue**: Cannot override soft-mandatory policy
- **Solution**: Verify user has override permissions in organization settings

**Issue**: Policy syntax errors
- **Solution**: Test policies locally with Sentinel CLI before uploading

---

## Lab Verification Checklist

### Lab 12.1 Verification
- [ ] Secret created in Secrets Manager
- [ ] Terraform references secret
- [ ] Sensitive variables marked
- [ ] Password output redacted

### Lab 12.2 Verification
- [ ] S3 backend configured
- [ ] Encryption enabled
- [ ] State locking working
- [ ] Remote state accessible

### Lab 12.3 Verification
- [ ] VPC created
- [ ] Subnets created
- [ ] Security groups configured
- [ ] Network properly isolated

### Lab 12.4 Verification
- [ ] HCP Terraform workspace created
- [ ] Sentinel policies deployed
- [ ] Policy set attached to workspace
- [ ] Compliant configuration passed policies
- [ ] Non-compliant configurations blocked
- [ ] Soft-mandatory override tested
- [ ] Policy run history reviewed

---

## Lab 12.5: Team Management and RBAC

### Objective
Implement role-based access control (RBAC) in HCP Terraform with teams, permissions, and workspace access levels.

### Prerequisites
- HCP Terraform account (free tier available)
- Organization owner access
- At least 2 test user accounts (or use email aliases)
- Terraform installed locally

### Estimated Time
90 minutes

---

### Step 1: Create HCP Terraform Organization

**Option A: Using UI**
1. Navigate to https://app.terraform.io
2. Click "Create Organization"
3. Enter organization name: `<yourname>-rbac-lab`
4. Select "Free" plan
5. Click "Create organization"

**Option B: Using Terraform**

```hcl
# Not applicable - organizations must be created via UI
# But we'll manage everything else with Terraform
```

---

### Step 2: Create Teams Using Terraform

Create `teams.tf`:

```hcl
terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.51.0"
    }
  }
}

provider "tfe" {
  token = var.tfe_token
}

variable "tfe_token" {
  description = "HCP Terraform API token"
  type        = string
  sensitive   = true
}

variable "organization_name" {
  description = "HCP Terraform organization name"
  type        = string
}

# Create Developers Team
resource "tfe_team" "developers" {
  name         = "developers"
  organization = var.organization_name
}

# Create DevOps Team with organization permissions
resource "tfe_team" "devops" {
  name         = "devops"
  organization = var.organization_name

  organization_access {
    manage_workspaces = true
    manage_policies   = false
  }
}

# Create Security Team with policy management
resource "tfe_team" "security" {
  name         = "security"
  organization = var.organization_name

  organization_access {
    manage_policies          = true
    manage_policy_overrides  = true
  }
}

# Create Auditors Team (read-only)
resource "tfe_team" "auditors" {
  name         = "auditors"
  organization = var.organization_name
}

output "team_ids" {
  value = {
    developers = tfe_team.developers.id
    devops     = tfe_team.devops.id
    security   = tfe_team.security.id
    auditors   = tfe_team.auditors.id
  }
}
```

Create `terraform.tfvars`:

```hcl
organization_name = "yourname-rbac-lab"
tfe_token         = "your-tfe-token-here"  # Get from User Settings → Tokens
```

**Apply the configuration**:

```bash
terraform init
terraform plan
terraform apply
```

---

### Step 3: Create Test Workspaces

Add to `teams.tf`:

```hcl
# Development Workspace
resource "tfe_workspace" "dev" {
  name         = "dev-application"
  organization = var.organization_name

  tag_names = ["development", "rbac-lab"]
}

# Staging Workspace
resource "tfe_workspace" "staging" {
  name         = "staging-application"
  organization = var.organization_name

  tag_names = ["staging", "rbac-lab"]
}

# Production Workspace
resource "tfe_workspace" "prod" {
  name         = "prod-application"
  organization = var.organization_name

  tag_names = ["production", "rbac-lab"]
}
```

---

### Step 4: Assign Workspace Access Levels

Add to `teams.tf`:

```hcl
# Developers: Write access to dev, Plan access to staging
resource "tfe_team_access" "developers_dev" {
  access       = "write"
  team_id      = tfe_team.developers.id
  workspace_id = tfe_workspace.dev.id
}

resource "tfe_team_access" "developers_staging" {
  access       = "plan"
  team_id      = tfe_team.developers.id
  workspace_id = tfe_workspace.staging.id
}

# DevOps: Admin access to all workspaces
resource "tfe_team_access" "devops_dev" {
  access       = "admin"
  team_id      = tfe_team.devops.id
  workspace_id = tfe_workspace.dev.id
}

resource "tfe_team_access" "devops_staging" {
  access       = "admin"
  team_id      = tfe_team.devops.id
  workspace_id = tfe_workspace.staging.id
}

resource "tfe_team_access" "devops_prod" {
  access       = "admin"
  team_id      = tfe_team.devops.id
  workspace_id = tfe_workspace.prod.id
}

# Security: Read access to all workspaces
resource "tfe_team_access" "security_dev" {
  access       = "read"
  team_id      = tfe_team.security.id
  workspace_id = tfe_workspace.dev.id
}

resource "tfe_team_access" "security_staging" {
  access       = "read"
  team_id      = tfe_team.security.id
  workspace_id = tfe_workspace.staging.id
}

resource "tfe_team_access" "security_prod" {
  access       = "read"
  team_id      = tfe_team.security.id
  workspace_id = tfe_workspace.prod.id
}

# Auditors: Read access to production only
resource "tfe_team_access" "auditors_prod" {
  access       = "read"
  team_id      = tfe_team.auditors.id
  workspace_id = tfe_workspace.prod.id
}
```

**Apply the changes**:

```bash
terraform apply
```

---

### Step 5: Test Access Levels

**Test Scenario 1: Developer Access**

1. Invite a test user to the "developers" team
2. Log in as that user
3. Navigate to `dev-application` workspace
4. Verify you can:
   - ✅ View workspace settings
   - ✅ Queue a plan
   - ✅ Apply changes
5. Navigate to `staging-application` workspace
6. Verify you can:
   - ✅ View workspace settings
   - ✅ Queue a plan
   - ❌ Cannot apply (plan-only access)
7. Navigate to `prod-application` workspace
8. Verify you:
   - ❌ Cannot see the workspace (no access)

**Test Scenario 2: Security Team Access**

1. Add user to "security" team
2. Log in and verify:
   - ✅ Can view all workspaces (read access)
   - ✅ Can access Organization Settings → Policy Sets
   - ❌ Cannot apply changes to any workspace
   - ❌ Cannot modify workspace settings

**Test Scenario 3: Auditor Access**

1. Add user to "auditors" team
2. Log in and verify:
   - ✅ Can view prod-application workspace
   - ✅ Can view run history
   - ✅ Can download state files
   - ❌ Cannot view dev or staging workspaces
   - ❌ Cannot queue plans or applies

---

### Step 6: Implement Team Membership via Terraform

Add to `teams.tf`:

```hcl
# Add team members (requires usernames to exist)
resource "tfe_team_member" "dev_alice" {
  team_id  = tfe_team.developers.id
  username = "alice"  # Replace with actual username
}

resource "tfe_team_member" "devops_bob" {
  team_id  = tfe_team.devops.id
  username = "bob"  # Replace with actual username
}

# Or use tfe_team_members for bulk assignment
resource "tfe_team_members" "security_team" {
  team_id = tfe_team.security.id

  usernames = [
    "charlie",
    "diana",
  ]
}
```

**Note**: Users must already exist in the organization before adding them to teams.

---

### Step 7: Review Audit Logs

1. Navigate to Organization Settings → Audit Trail
2. Review recent events:
   - Team creation
   - Workspace access changes
   - User additions to teams
3. Filter by event type: "team.create", "team_access.create"
4. Export audit logs (if needed for compliance)

---

### Step 8: Clean Up

```bash
# Remove all resources
terraform destroy

# Or keep for future reference
```

---

## Lab 12.5 Deliverables

- [ ] 4 teams created (developers, devops, security, auditors)
- [ ] 3 workspaces created (dev, staging, prod)
- [ ] Workspace access levels configured correctly
- [ ] Tested developer write access to dev workspace
- [ ] Tested developer plan-only access to staging
- [ ] Tested security team read access to all workspaces
- [ ] Tested auditor read access to prod only
- [ ] Reviewed audit trail logs

---

## Lab 12.5 Key Learnings

✅ **Teams** organize users with common permissions
✅ **Workspace access levels** control what teams can do
✅ **Organization permissions** grant cross-workspace capabilities
✅ **RBAC** follows principle of least privilege
✅ **Audit logs** track all permission changes

---

## Lab 12.5 Troubleshooting

**Issue 1: "User not found" when adding team members**
- **Solution**: Users must be invited to the organization first via UI

**Issue 2: "Insufficient permissions" when creating teams**
- **Solution**: Ensure your TFE token has organization owner permissions

**Issue 3: Cannot see workspace after assigning access**
- **Solution**: User may need to log out and log back in for permissions to refresh

---

## Lab 12.6: VCS-Driven Workflow

### Objective
Configure a VCS-driven workflow in HCP Terraform with GitHub integration, enabling automatic plans on pull requests and applies on merge.

### Prerequisites
- HCP Terraform account (free tier)
- GitHub account
- Git installed locally
- Terraform installed locally
- AWS account (for infrastructure deployment)

### Estimated Time
75 minutes

---

### Step 1: Create GitHub Repository

**Create a new repository**:

```bash
# Create directory
mkdir terraform-vcs-lab
cd terraform-vcs-lab

# Initialize Git
git init

# Create README
echo "# Terraform VCS Lab" > README.md
git add README.md
git commit -m "Initial commit"

# Create GitHub repository (via UI or gh CLI)
gh repo create terraform-vcs-lab --public --source=. --remote=origin --push
```

---

### Step 2: Create Terraform Configuration

**Create `main.tf`**:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "YOUR_ORG_NAME"  # Replace with your org

    workspaces {
      name = "vcs-lab-workspace"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Simple S3 bucket for demonstration
resource "aws_s3_bucket" "demo" {
  bucket = "vcs-lab-demo-${random_id.suffix.hex}"

  tags = {
    Name        = "VCS Lab Demo"
    Environment = "Development"
    ManagedBy   = "Terraform"
    VCS         = "GitHub"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

**Create `variables.tf`**:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
```

**Create `outputs.tf`**:

```hcl
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.demo.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.demo.arn
}
```

**Commit and push**:

```bash
git add .
git commit -m "Add initial Terraform configuration"
git push origin main
```

---

### Step 3: Configure VCS Provider in HCP Terraform

**Via UI**:

1. Log in to https://app.terraform.io
2. Navigate to your organization
3. Go to **Settings** → **VCS Providers**
4. Click **Add VCS Provider**
5. Select **GitHub** → **GitHub.com**
6. Click **Connect and continue**
7. Authorize HCP Terraform in GitHub
8. Note the OAuth Token ID (you'll need this)

---

### Step 4: Create VCS-Connected Workspace

**Option A: Via UI**

1. Click **New** → **Workspace**
2. Choose **Version control workflow**
3. Select your GitHub connection
4. Choose the `terraform-vcs-lab` repository
5. Configure workspace:
   - **Workspace Name**: `vcs-lab-workspace`
   - **Terraform Working Directory**: (leave blank)
   - **VCS Branch**: `main`
   - **Automatic Run Triggering**: Enabled
6. Click **Create workspace**

**Option B: Via Terraform**

Create `workspace-config/main.tf`:

```hcl
terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.51.0"
    }
  }
}

provider "tfe" {
  token = var.tfe_token
}

variable "tfe_token" {
  description = "HCP Terraform API token"
  type        = string
  sensitive   = true
}

variable "organization_name" {
  description = "HCP Terraform organization name"
  type        = string
}

variable "github_oauth_token_id" {
  description = "GitHub OAuth token ID from HCP Terraform"
  type        = string
}

resource "tfe_workspace" "vcs_lab" {
  name         = "vcs-lab-workspace"
  organization = var.organization_name

  vcs_repo {
    identifier     = "YOUR_GITHUB_USERNAME/terraform-vcs-lab"
    branch         = "main"
    oauth_token_id = var.github_oauth_token_id
  }

  auto_apply            = false  # Require manual approval
  file_triggers_enabled = true
  queue_all_runs        = false

  trigger_patterns = [
    "**/*.tf",
    "**/*.tfvars"
  ]
}
```

---

### Step 5: Configure AWS Credentials in Workspace

1. Navigate to workspace → **Variables**
2. Add environment variables:
   - `AWS_ACCESS_KEY_ID` (sensitive)
   - `AWS_SECRET_ACCESS_KEY` (sensitive)
   - `AWS_DEFAULT_REGION` = `us-east-1`

---

### Step 6: Test VCS-Driven Workflow - Pull Request

**Create a feature branch**:

```bash
git checkout -b feature/add-encryption
```

**Update `main.tf` to add encryption**:

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

**Commit and push**:

```bash
git add main.tf
git commit -m "Add S3 bucket encryption"
git push origin feature/add-encryption
```

**Create Pull Request**:

1. Go to GitHub repository
2. Click **Compare & pull request**
3. Add description: "Add encryption to S3 bucket"
4. Click **Create pull request**

**Observe HCP Terraform**:
- Navigate to HCP Terraform workspace
- See automatic plan triggered
- Review plan output
- Check PR comment with plan summary

---

### Step 7: Review and Merge

**Review the plan**:
1. Check HCP Terraform plan output
2. Verify changes: 1 to add (encryption configuration)
3. Review in GitHub PR

**Merge the PR**:
1. Click **Merge pull request** in GitHub
2. Confirm merge
3. Delete feature branch

**Observe automatic apply**:
- HCP Terraform detects merge to main
- If auto-apply is disabled, manually confirm apply
- Monitor apply progress
- Verify S3 bucket encryption enabled

---

### Step 8: Test Direct Push to Main

**Make a small change**:

```bash
git checkout main
git pull origin main

# Update tags in main.tf
# Change Environment = "Development" to Environment = "Production"

git add main.tf
git commit -m "Update environment tag to Production"
git push origin main
```

**Observe**:
- HCP Terraform automatically triggers plan
- Review and apply changes

---

### Step 9: Configure Branch Protection

**Enable branch protection in GitHub**:

1. Go to repository **Settings** → **Branches**
2. Click **Add rule**
3. Branch name pattern: `main`
4. Enable:
   - ✅ Require pull request reviews before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
5. Add status check: `Terraform Plan`
6. Click **Create**

---

### Step 10: Test Protected Branch

**Try to push directly to main** (should fail):

```bash
git checkout main
echo "# Test" >> README.md
git add README.md
git commit -m "Test direct push"
git push origin main  # This should be rejected
```

**Expected**: Push rejected due to branch protection

**Correct workflow**:
```bash
git checkout -b feature/update-readme
git push origin feature/update-readme
# Create PR → Review → Merge
```

---

### Step 11: Clean Up

**Destroy infrastructure**:
1. Navigate to HCP Terraform workspace
2. Go to **Settings** → **Destruction and Deletion**
3. Queue destroy plan
4. Confirm destruction

**Delete GitHub repository** (optional):
```bash
gh repo delete terraform-vcs-lab --yes
```

---

## Lab 12.6 Deliverables

- [ ] GitHub repository created and connected to HCP Terraform
- [ ] VCS-driven workspace configured
- [ ] Automatic plan triggered on pull request
- [ ] Plan output posted as PR comment
- [ ] Automatic apply triggered on merge to main
- [ ] Branch protection rules configured
- [ ] Direct push to main blocked by branch protection
- [ ] Infrastructure successfully deployed via VCS workflow

---

## Lab 12.6 Key Learnings

✅ **VCS integration** automates Terraform workflows
✅ **Pull requests** enable infrastructure code review
✅ **Automatic plans** provide visibility before merge
✅ **Branch protection** enforces workflow discipline
✅ **GitOps** provides complete audit trail

---

## Lab 12.6 Troubleshooting

**Issue 1: Workspace not triggering on PR**
- **Solution**: Check VCS connection status, verify webhook configuration, ensure trigger patterns match file changes

**Issue 2: "No changes" in plan**
- **Solution**: Verify working directory setting, check if changes are in .tf files, ensure branch is correct

**Issue 3: Apply fails with AWS credentials error**
- **Solution**: Verify AWS credentials are set as environment variables in workspace, check IAM permissions

**Issue 4: PR comment not appearing**
- **Solution**: Check GitHub App permissions, verify HCP Terraform has write access to repository

---

## Key Learnings

✅ Secrets should be managed securely
✅ State files must be encrypted
✅ Network security is critical
✅ Least privilege access required
✅ Compliance tagging important
✅ Sentinel policies enforce governance automatically
✅ Policy as code enables proactive compliance
✅ Team management enables secure collaboration
✅ RBAC ensures proper access control
✅ VCS integration automates infrastructure workflows
✅ GitOps provides audit trail and collaboration

---

**Lab Completion Time**: 7.5-9.5 hours
**Difficulty**: Advanced
**Next**: Proceed to Practice Exam

