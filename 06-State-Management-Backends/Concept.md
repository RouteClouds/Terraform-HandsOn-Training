# Topic 6: State Management & Backends

## 🎯 **Learning Objectives**

By completing this comprehensive topic, you will master advanced Terraform state management concepts and enterprise-scale backend architectures. This topic builds upon the foundation established in Topics 1-5, providing the critical knowledge needed for production-ready infrastructure deployments.

### **Primary Learning Outcomes**
1. **State Architecture Mastery** - Design and implement sophisticated state management architectures for enterprise environments
2. **Backend Selection Expertise** - Evaluate and select optimal backend solutions based on organizational requirements and constraints
3. **Collaboration Patterns** - Implement advanced team collaboration workflows with state locking and conflict resolution
4. **Remote State Integration** - Design complex remote state sharing patterns and cross-team integration strategies
5. **Migration and Recovery** - Execute state migrations and implement comprehensive disaster recovery procedures
6. **Enterprise Governance** - Establish enterprise-grade governance frameworks with security and compliance controls

### **Advanced Competencies Developed**
- **Strategic Decision Making**: Backend selection based on technical, operational, and business requirements
- **Risk Management**: State corruption prevention, backup strategies, and disaster recovery planning
- **Team Leadership**: Collaboration workflow design and conflict resolution procedures
- **Security Architecture**: Encryption, access control, and compliance framework implementation
- **Operational Excellence**: Monitoring, alerting, and automated state management procedures

---

## 📊 **Terraform State Fundamentals and Architecture**

### **Understanding Terraform State**

Terraform state is the cornerstone of infrastructure management, serving as the authoritative record of your infrastructure's current configuration. State management becomes increasingly critical as organizations scale their infrastructure and teams.

![Figure 6.1: Terraform State Architecture and Backend Types](DaC/generated_diagrams/figure_6_1_state_architecture_backends.png)
*Figure 6.1: Comprehensive state architecture patterns, backend types, and enterprise selection criteria*

#### **State File Structure and Components**

```json
{
  "version": 4,
  "terraform_version": "1.13.0",
  "serial": 42,
  "lineage": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "outputs": {
    "vpc_id": {
      "value": "vpc-12345678",
      "type": "string",
      "sensitive": false
    }
  },
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
            "id": "vpc-12345678",
            "cidr_block": "10.0.0.0/16",
            "enable_dns_hostnames": true,
            "enable_dns_support": true,
            "tags": {
              "Name": "main-vpc",
              "Environment": "production"
            }
          },
          "sensitive_attributes": [],
          "private": "eyJzY2hlbWFfdmVyc2lvbiI6IjEifQ==",
          "dependencies": []
        }
      ]
    }
  ],
  "check_results": []
}
```

#### **State Management Challenges at Scale**

**Single User Limitations**
- Local state files create collaboration barriers
- No concurrent access protection
- Manual backup and recovery procedures
- Limited audit trail and change tracking

**Multi-Team Complexity**
- State file conflicts and corruption risks
- Inconsistent infrastructure views across teams
- Difficulty in implementing access controls
- Complex dependency management between teams

**Enterprise Requirements**
- Centralized state management and governance
- Comprehensive audit trails and compliance reporting
- Automated backup and disaster recovery procedures
- Integration with enterprise security and monitoring systems

### **Backend Architecture Patterns**

#### **Local Backend - Development and Learning**

```hcl
# Local backend configuration (default)
# No explicit backend configuration required
# State stored in terraform.tfstate file

# Characteristics:
# - Single user access
# - No state locking
# - Local file storage
# - Manual backup procedures
# - Development and learning environments only

# Workspace management with local backend
terraform {
  # No backend configuration = local backend
}

# Local state file locations:
# - Default: ./terraform.tfstate
# - Workspaces: ./terraform.tfstate.d/<workspace>/terraform.tfstate
# - Backup: ./terraform.tfstate.backup
```

#### **S3 Backend - Production Standard**

```hcl
# S3 backend with DynamoDB locking
terraform {
  backend "s3" {
    # S3 bucket configuration
    bucket = "company-terraform-state"
    key    = "infrastructure/production/terraform.tfstate"
    region = "us-east-1"
    
    # Encryption configuration
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    
    # State locking with DynamoDB
    dynamodb_table = "terraform-state-locks"
    
    # Access control and security
    acl                = "private"
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
        }
      }
    }
    
    # Versioning and lifecycle management
    versioning {
      enabled = true
    }
    
    lifecycle_rule {
      enabled = true
      
      noncurrent_version_expiration {
        days = 90
      }
      
      abort_incomplete_multipart_upload_days = 7
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-state-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name        = "Terraform State Locks"
    Environment = "production"
    Purpose     = "state-locking"
  }
}
```

#### **Terraform Cloud Backend - Enterprise SaaS**

```hcl
# Terraform Cloud backend configuration
terraform {
  cloud {
    organization = "company-name"
    
    workspaces {
      name = "production-infrastructure"
    }
  }
}

# Alternative: Terraform Cloud with workspace tags
terraform {
  cloud {
    organization = "company-name"
    
    workspaces {
      tags = ["production", "infrastructure"]
    }
  }
}

# Features provided by Terraform Cloud:
# - Remote state storage and management
# - Built-in state locking and collaboration
# - Remote execution environment
# - VCS integration and automated workflows
# - Policy as Code with Sentinel
# - Cost estimation and compliance scanning
# - Team and organization management
# - Audit logs and governance features
```

#### **Alternative Backend Options**

```hcl
# Azure Storage backend
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatestorage"
    container_name       = "terraform-state"
    key                  = "production.terraform.tfstate"
    
    # Access configuration
    access_key = var.storage_account_access_key
    # Or use Azure AD authentication
    use_azuread_auth = true
  }
}

# Google Cloud Storage backend
terraform {
  backend "gcs" {
    bucket = "company-terraform-state"
    prefix = "infrastructure/production"
    
    # Encryption configuration
    encryption_key = var.gcs_encryption_key
    
    # Access configuration
    credentials = var.gcp_credentials_file
  }
}

# Consul backend for service discovery integration
terraform {
  backend "consul" {
    address = "consul.company.com:8500"
    scheme  = "https"
    path    = "terraform/production/state"
    
    # Authentication
    token = var.consul_token
    
    # TLS configuration
    ca_file   = var.consul_ca_file
    cert_file = var.consul_cert_file
    key_file  = var.consul_key_file
  }
}

# etcd backend for Kubernetes environments
terraform {
  backend "etcdv3" {
    endpoints = ["https://etcd1.company.com:2379", "https://etcd2.company.com:2379"]
    prefix    = "/terraform/production/"
    
    # Authentication
    username = var.etcd_username
    password = var.etcd_password
    
    # TLS configuration
    cacert = var.etcd_ca_cert
    cert   = var.etcd_cert
    key    = var.etcd_key
  }
}
```

### **Backend Selection Criteria and Decision Framework**

#### **Technical Requirements Assessment**

```hcl
# Backend selection decision matrix
locals {
  backend_requirements = {
    # Team and collaboration requirements
    team_size = var.team_size                    # 1-5: local, 5-20: S3, 20+: Terraform Cloud
    concurrent_users = var.concurrent_users      # Concurrent access needs
    geographic_distribution = var.global_teams   # Multi-region team distribution
    
    # Technical requirements
    state_locking_required = var.enable_locking  # Prevent concurrent modifications
    encryption_required = var.encryption_policy  # Data protection requirements
    versioning_required = var.enable_versioning  # State history and rollback
    backup_strategy = var.backup_requirements    # Disaster recovery needs
    
    # Integration requirements
    ci_cd_integration = var.automation_level     # Pipeline integration needs
    vcs_integration = var.version_control        # Git workflow integration
    policy_enforcement = var.governance_level    # Compliance and governance
    audit_logging = var.audit_requirements       # Compliance and security
    
    # Operational requirements
    availability_sla = var.availability_target   # Uptime requirements
    performance_requirements = var.performance   # Latency and throughput
    cost_constraints = var.budget_limits         # Cost optimization needs
    maintenance_overhead = var.ops_capacity      # Operational complexity tolerance
  }
  
  # Backend recommendation logic
  recommended_backend = (
    local.backend_requirements.team_size <= 5 && 
    !local.backend_requirements.state_locking_required ? "local" :
    
    local.backend_requirements.team_size <= 20 && 
    local.backend_requirements.cost_constraints == "moderate" ? "s3" :
    
    local.backend_requirements.governance_level == "high" ||
    local.backend_requirements.team_size > 20 ? "terraform_cloud" :
    
    "s3"  # Default recommendation
  )
}
```

#### **Enterprise Backend Architecture Patterns**

```hcl
# Multi-environment backend strategy
terraform {
  backend "s3" {
    # Environment-specific bucket organization
    bucket = "company-terraform-state-${var.environment}"
    key    = "${var.project}/${var.component}/terraform.tfstate"
    region = var.aws_region
    
    # Consistent encryption across environments
    encrypt    = true
    kms_key_id = data.aws_kms_key.terraform_state.arn
    
    # Environment-specific locking table
    dynamodb_table = "terraform-locks-${var.environment}"
    
    # Workspace isolation strategy
    workspace_key_prefix = "workspaces"
  }
}

# Cross-account state access pattern
data "aws_caller_identity" "current" {}

locals {
  # Account-specific state bucket naming
  state_bucket = "terraform-state-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  
  # Cross-account access configuration
  cross_account_access = {
    dev_account     = "123456789012"
    staging_account = "234567890123"
    prod_account    = "345678901234"
  }
  
  # State key organization strategy
  state_key_pattern = "${var.business_unit}/${var.environment}/${var.application}/${var.component}/terraform.tfstate"
}
```

---

## 🔒 **State Locking and Team Collaboration**

### **State Locking Mechanisms and Implementation**

State locking is essential for preventing concurrent modifications that could lead to state corruption or inconsistent infrastructure. Understanding locking mechanisms enables safe team collaboration and automated workflows.

![Figure 6.2: State Locking and Collaboration Patterns](DaC/generated_diagrams/figure_6_2_state_locking_collaboration.png)
*Figure 6.2: State locking mechanisms, team collaboration workflows, and conflict resolution strategies*

#### **DynamoDB State Locking Implementation**

```hcl
# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_locks" {
  name           = "terraform-state-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Point-in-time recovery for lock table protection
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption {
    enabled     = true
    kms_key_id  = aws_kms_key.terraform_state.arn
  }

  # Tags for governance and cost allocation
  tags = {
    Name            = "Terraform State Locks"
    Environment     = "shared"
    Purpose         = "state-locking"
    CostCenter      = "infrastructure"
    DataRetention   = "indefinite"
    BackupRequired  = "true"
  }
}

# Lock table monitoring and alerting
resource "aws_cloudwatch_metric_alarm" "lock_table_throttles" {
  alarm_name          = "terraform-locks-throttled-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB throttling for Terraform state locks"
  alarm_actions       = [aws_sns_topic.terraform_alerts.arn]

  dimensions = {
    TableName = aws_dynamodb_table.terraform_state_locks.name
  }
}
```

#### **Lock Acquisition and Release Workflow**

```bash
#!/bin/bash
# Advanced state locking workflow script

set -euo pipefail

# Configuration
LOCK_TABLE="terraform-state-locks"
STATE_BUCKET="company-terraform-state"
STATE_KEY="infrastructure/production/terraform.tfstate"
LOCK_TIMEOUT=900  # 15 minutes
RETRY_INTERVAL=30 # 30 seconds

# Logging configuration
LOG_FILE="/var/log/terraform-operations.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Lock acquisition with retry logic
acquire_lock() {
    local operation="$1"
    local user="$2"
    local max_retries=30
    local retry_count=0

    log "Attempting to acquire lock for operation: $operation by user: $user"

    while [ $retry_count -lt $max_retries ]; do
        if terraform init -backend-config="bucket=$STATE_BUCKET" \
                         -backend-config="key=$STATE_KEY" \
                         -backend-config="dynamodb_table=$LOCK_TABLE"; then
            log "Lock acquired successfully"
            return 0
        fi

        retry_count=$((retry_count + 1))
        log "Lock acquisition failed, retry $retry_count/$max_retries in $RETRY_INTERVAL seconds"
        sleep $RETRY_INTERVAL
    done

    log "ERROR: Failed to acquire lock after $max_retries attempts"
    return 1
}

# Lock monitoring and health checks
monitor_lock_health() {
    local lock_id="$1"

    # Check lock table accessibility
    if ! aws dynamodb describe-table --table-name "$LOCK_TABLE" >/dev/null 2>&1; then
        log "ERROR: Cannot access lock table $LOCK_TABLE"
        return 1
    fi

    # Check for stale locks (older than timeout)
    local stale_locks
    stale_locks=$(aws dynamodb scan \
        --table-name "$LOCK_TABLE" \
        --filter-expression "attribute_exists(Created) AND Created < :timeout" \
        --expression-attribute-values "{\":timeout\":{\"S\":\"$(date -d "$LOCK_TIMEOUT seconds ago" -u +%Y-%m-%dT%H:%M:%SZ)\"}}" \
        --query 'Count' --output text)

    if [ "$stale_locks" -gt 0 ]; then
        log "WARNING: Found $stale_locks stale locks in table $LOCK_TABLE"
        # Implement stale lock cleanup logic here
    fi
}

# Emergency lock release procedures
force_unlock() {
    local lock_id="$1"
    local justification="$2"

    log "EMERGENCY: Force unlocking state with ID: $lock_id"
    log "Justification: $justification"

    # Backup current state before force unlock
    aws s3 cp "s3://$STATE_BUCKET/$STATE_KEY" \
              "s3://$STATE_BUCKET/backups/emergency-backup-$(date +%Y%m%d-%H%M%S).tfstate"

    # Force unlock
    terraform force-unlock "$lock_id"

    # Log emergency action for audit
    aws logs put-log-events \
        --log-group-name "/terraform/emergency-actions" \
        --log-stream-name "force-unlock-$(date +%Y%m%d)" \
        --log-events timestamp="$(date +%s)000",message="Force unlock executed: $lock_id - $justification"
}
```

#### **Team Collaboration Patterns**

```hcl
# Workspace-based team isolation
resource "terraform_workspace" "team_workspaces" {
  for_each = var.team_configurations

  name         = each.key
  organization = var.terraform_cloud_org

  # Team-specific settings
  auto_apply           = each.value.auto_apply_enabled
  file_triggers_enabled = each.value.file_triggers
  queue_all_runs       = each.value.queue_runs

  # VCS integration for team repositories
  vcs_repo {
    identifier     = each.value.repository
    branch         = each.value.branch
    oauth_token_id = var.vcs_oauth_token
  }

  # Environment variables for team context
  dynamic "environment_variable" {
    for_each = each.value.environment_variables
    content {
      key      = environment_variable.key
      value    = environment_variable.value
      category = "env"
      sensitive = contains(each.value.sensitive_vars, environment_variable.key)
    }
  }

  # Terraform variables for team configuration
  dynamic "variable" {
    for_each = each.value.terraform_variables
    content {
      key      = variable.key
      value    = variable.value
      category = "terraform"
      sensitive = contains(each.value.sensitive_vars, variable.key)
    }
  }
}

# Team access control and permissions
resource "terraform_team" "infrastructure_teams" {
  for_each = var.team_definitions

  name         = each.key
  organization = var.terraform_cloud_org

  # Team visibility and access
  visibility          = each.value.visibility
  organization_access = each.value.org_access

  # Team permissions
  dynamic "organization_membership" {
    for_each = each.value.members
    content {
      username = organization_membership.value.username
      role     = organization_membership.value.role
    }
  }
}

# Workspace access assignments
resource "terraform_team_access" "workspace_permissions" {
  for_each = local.team_workspace_access

  access       = each.value.access_level
  team_id      = terraform_team.infrastructure_teams[each.value.team].id
  workspace_id = terraform_workspace.team_workspaces[each.value.workspace].id

  # Granular permissions
  permissions {
    runs              = each.value.permissions.runs
    variables         = each.value.permissions.variables
    state_versions    = each.value.permissions.state_versions
    sentinel_mocks    = each.value.permissions.sentinel_mocks
    workspace_locking = each.value.permissions.workspace_locking
  }
}
```

### **Advanced Collaboration Workflows**

#### **GitOps Integration with State Management**

```yaml
# .github/workflows/terraform-collaboration.yml
name: Terraform Collaboration Workflow

on:
  pull_request:
    branches: [main]
    paths: ['infrastructure/**']
  push:
    branches: [main]
    paths: ['infrastructure/**']

env:
  TF_VERSION: '1.13.0'
  AWS_REGION: 'us-east-1'
  STATE_BUCKET: 'company-terraform-state'
  LOCK_TABLE: 'terraform-state-locks'

jobs:
  terraform-plan:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging]

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Terraform Init with Lock Retry
      run: |
        cd infrastructure/${{ matrix.environment }}
        for i in {1..5}; do
          if terraform init \
            -backend-config="bucket=${{ env.STATE_BUCKET }}" \
            -backend-config="key=${{ matrix.environment }}/terraform.tfstate" \
            -backend-config="dynamodb_table=${{ env.LOCK_TABLE }}" \
            -backend-config="region=${{ env.AWS_REGION }}"; then
            break
          fi
          echo "Init failed, retrying in 30 seconds..."
          sleep 30
        done

    - name: Terraform Plan with Lock Management
      run: |
        cd infrastructure/${{ matrix.environment }}
        terraform plan -detailed-exitcode -out=tfplan
      continue-on-error: true
      id: plan

    - name: Comment PR with Plan
      uses: actions/github-script@v7
      with:
        script: |
          const output = `#### Terraform Plan for ${{ matrix.environment }} 📖

          <details><summary>Show Plan</summary>

          \`\`\`terraform
          ${{ steps.plan.outputs.stdout }}
          \`\`\`

          </details>

          *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

  terraform-apply:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging]

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Terraform Apply with State Backup
      run: |
        cd infrastructure/${{ matrix.environment }}

        # Backup current state before apply
        aws s3 cp s3://${{ env.STATE_BUCKET }}/${{ matrix.environment }}/terraform.tfstate \
                  s3://${{ env.STATE_BUCKET }}/backups/${{ matrix.environment }}-$(date +%Y%m%d-%H%M%S).tfstate

        # Initialize and apply
        terraform init \
          -backend-config="bucket=${{ env.STATE_BUCKET }}" \
          -backend-config="key=${{ matrix.environment }}/terraform.tfstate" \
          -backend-config="dynamodb_table=${{ env.LOCK_TABLE }}" \
          -backend-config="region=${{ env.AWS_REGION }}"

        terraform apply -auto-approve

    - name: Notify Teams on Failure
      if: failure()
      uses: 8398a7/action-slack@v3
      with:
        status: failure
        channel: '#infrastructure-alerts'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🔄 **Remote State Sharing and Cross-Team Integration**

### **Remote State Data Sources and Integration Patterns**

Remote state sharing enables teams to build upon each other's infrastructure while maintaining clear boundaries and responsibilities. This section explores advanced patterns for cross-team integration and dependency management.

![Figure 6.3: Remote State Sharing and Data Flow](DaC/generated_diagrams/figure_6_3_remote_state_sharing.png)
*Figure 6.3: Remote state sharing patterns, data flow between configurations, and cross-team integration strategies*

#### **terraform_remote_state Data Source Implementation**

```hcl
# Foundation team state (network infrastructure)
# File: infrastructure/foundation/main.tf
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "foundation/network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

# Network infrastructure outputs
output "vpc_configuration" {
  description = "VPC configuration for consumption by application teams"
  value = {
    vpc_id = aws_vpc.main.id
    vpc_cidr_block = aws_vpc.main.cidr_block

    # Subnet information organized by tier
    subnets = {
      public = {
        ids = aws_subnet.public[*].id
        cidrs = aws_subnet.public[*].cidr_block
        availability_zones = aws_subnet.public[*].availability_zone
      }
      private = {
        ids = aws_subnet.private[*].id
        cidrs = aws_subnet.private[*].cidr_block
        availability_zones = aws_subnet.private[*].availability_zone
      }
      database = {
        ids = aws_subnet.database[*].id
        cidrs = aws_subnet.database[*].cidr_block
        availability_zones = aws_subnet.database[*].availability_zone
      }
    }

    # Gateway and routing information
    gateways = {
      internet_gateway_id = aws_internet_gateway.main.id
      nat_gateway_ids = aws_nat_gateway.main[*].id
      nat_gateway_ips = aws_eip.nat[*].public_ip
    }

    # Security group defaults
    default_security_groups = {
      web_sg_id = aws_security_group.web_default.id
      app_sg_id = aws_security_group.app_default.id
      db_sg_id = aws_security_group.db_default.id
    }

    # DNS and service discovery
    dns_configuration = {
      private_zone_id = aws_route53_zone.private.zone_id
      private_zone_name = aws_route53_zone.private.name
      resolver_endpoints = aws_route53_resolver_endpoint.main[*].id
    }
  }

  # Mark as sensitive if contains internal network details
  sensitive = var.network_configuration_sensitive
}

# Security infrastructure outputs
output "security_configuration" {
  description = "Security configuration for application teams"
  value = {
    # KMS keys for different data classifications
    kms_keys = {
      general = aws_kms_key.general.arn
      sensitive = aws_kms_key.sensitive.arn
      restricted = aws_kms_key.restricted.arn
    }

    # IAM roles and policies
    iam_roles = {
      ec2_instance_role = aws_iam_role.ec2_instance.arn
      lambda_execution_role = aws_iam_role.lambda_execution.arn
      ecs_task_role = aws_iam_role.ecs_task.arn
    }

    # Security group templates
    security_group_rules = {
      web_tier_ingress = local.web_tier_rules
      app_tier_ingress = local.app_tier_rules
      db_tier_ingress = local.db_tier_rules
    }

    # Certificate and SSL configuration
    certificates = {
      wildcard_cert_arn = aws_acm_certificate.wildcard.arn
      api_cert_arn = aws_acm_certificate.api.arn
    }
  }

  sensitive = true
}

# Application team consuming foundation state
# File: applications/web-app/main.tf
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "applications/web-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

# Remote state data sources
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "company-terraform-state"
    key    = "foundation/network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "company-terraform-state"
    key    = "foundation/security/terraform.tfstate"
    region = "us-east-1"
  }
}

# Using remote state data in resource configuration
resource "aws_instance" "web_servers" {
  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # Use VPC and subnet from foundation team
  subnet_id = data.terraform_remote_state.foundation.outputs.vpc_configuration.subnets.private.ids[count.index % length(data.terraform_remote_state.foundation.outputs.vpc_configuration.subnets.private.ids)]

  # Use security groups from foundation team
  vpc_security_group_ids = [
    data.terraform_remote_state.foundation.outputs.vpc_configuration.default_security_groups.app_sg_id,
    aws_security_group.web_app_specific.id
  ]

  # Use IAM role from security team
  iam_instance_profile = aws_iam_instance_profile.web_app.name

  # Use KMS key from security team for EBS encryption
  root_block_device {
    encrypted  = true
    kms_key_id = data.terraform_remote_state.security.outputs.security_configuration.kms_keys.general
  }

  tags = merge(var.common_tags, {
    Name = "web-server-${count.index + 1}"
    Tier = "web"
    Team = "web-application"
  })
}

# Application Load Balancer using foundation outputs
resource "aws_lb" "web_app" {
  name               = "web-app-alb"
  internal           = false
  load_balancer_type = "application"

  # Use public subnets from foundation team
  subnets = data.terraform_remote_state.foundation.outputs.vpc_configuration.subnets.public.ids

  # Use security group from foundation team
  security_groups = [
    data.terraform_remote_state.foundation.outputs.vpc_configuration.default_security_groups.web_sg_id,
    aws_security_group.alb_specific.id
  ]

  tags = var.common_tags
}
```

#### **Advanced State Sharing Patterns**

```hcl
# Hierarchical state organization
locals {
  # State dependency hierarchy
  state_dependencies = {
    # Level 1: Foundation infrastructure
    foundation = {
      network = {
        bucket = var.state_bucket
        key    = "foundation/network/terraform.tfstate"
        region = var.aws_region
      }
      security = {
        bucket = var.state_bucket
        key    = "foundation/security/terraform.tfstate"
        region = var.aws_region
      }
      dns = {
        bucket = var.state_bucket
        key    = "foundation/dns/terraform.tfstate"
        region = var.aws_region
      }
    }

    # Level 2: Platform services
    platform = {
      monitoring = {
        bucket = var.state_bucket
        key    = "platform/monitoring/terraform.tfstate"
        region = var.aws_region
      }
      logging = {
        bucket = var.state_bucket
        key    = "platform/logging/terraform.tfstate"
        region = var.aws_region
      }
      service_mesh = {
        bucket = var.state_bucket
        key    = "platform/service-mesh/terraform.tfstate"
        region = var.aws_region
      }
    }

    # Level 3: Shared services
    shared_services = {
      databases = {
        bucket = var.state_bucket
        key    = "shared/databases/terraform.tfstate"
        region = var.aws_region
      }
      cache = {
        bucket = var.state_bucket
        key    = "shared/cache/terraform.tfstate"
        region = var.aws_region
      }
      message_queues = {
        bucket = var.state_bucket
        key    = "shared/messaging/terraform.tfstate"
        region = var.aws_region
      }
    }
  }
}

# Dynamic remote state data sources
data "terraform_remote_state" "foundation_states" {
  for_each = local.state_dependencies.foundation

  backend = "s3"
  config = each.value
}

data "terraform_remote_state" "platform_states" {
  for_each = local.state_dependencies.platform

  backend = "s3"
  config = each.value
}

data "terraform_remote_state" "shared_service_states" {
  for_each = local.state_dependencies.shared_services

  backend = "s3"
  config = each.value
}

# Computed values from multiple state sources
locals {
  # Aggregate network configuration from foundation
  network_config = {
    vpc_id = data.terraform_remote_state.foundation_states["network"].outputs.vpc_configuration.vpc_id
    vpc_cidr = data.terraform_remote_state.foundation_states["network"].outputs.vpc_configuration.vpc_cidr_block

    # Subnet selection logic
    app_subnets = data.terraform_remote_state.foundation_states["network"].outputs.vpc_configuration.subnets.private.ids
    web_subnets = data.terraform_remote_state.foundation_states["network"].outputs.vpc_configuration.subnets.public.ids
    db_subnets = data.terraform_remote_state.foundation_states["network"].outputs.vpc_configuration.subnets.database.ids
  }

  # Aggregate security configuration
  security_config = {
    kms_keys = data.terraform_remote_state.foundation_states["security"].outputs.security_configuration.kms_keys
    iam_roles = data.terraform_remote_state.foundation_states["security"].outputs.security_configuration.iam_roles
    certificates = data.terraform_remote_state.foundation_states["security"].outputs.security_configuration.certificates
  }

  # Aggregate monitoring configuration
  monitoring_config = try(
    data.terraform_remote_state.platform_states["monitoring"].outputs.monitoring_configuration,
    {}
  )

  # Service discovery endpoints
  service_endpoints = {
    database_cluster = try(
      data.terraform_remote_state.shared_service_states["databases"].outputs.database_endpoints.primary_cluster,
      null
    )
    cache_cluster = try(
      data.terraform_remote_state.shared_service_states["cache"].outputs.cache_endpoints.primary_cluster,
      null
    )
    message_queue = try(
      data.terraform_remote_state.shared_service_states["message_queues"].outputs.queue_endpoints.primary_queue,
      null
    )
  }
}
```
```
```
