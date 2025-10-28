# Examples and Use Cases
# Project 1: Multi-Tier Web Application Infrastructure

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [Complete Deployment Walkthrough](#complete-deployment-walkthrough)
3. [Development Environment](#development-environment)
4. [Staging Environment](#staging-environment)
5. [Production Environment](#production-environment)
6. [Custom Domain Setup](#custom-domain-setup)
7. [Multi-Region Deployment](#multi-region-deployment)
8. [Blue-Green Deployment](#blue-green-deployment)
9. [Disaster Recovery](#disaster-recovery)
10. [Cost Optimization](#cost-optimization)
11. [Security Hardening](#security-hardening)
12. [Integration Examples](#integration-examples)

---

## OVERVIEW

This document provides step-by-step examples and real-world use cases for deploying and managing Project 1: Multi-Tier Web Application Infrastructure. Each example includes complete commands, configuration files, and expected outputs.

---

## COMPLETE DEPLOYMENT WALKTHROUGH

### Step 1: Prerequisites

```bash
# Verify tools installed
terraform version  # Should be >= 1.13.0
aws --version      # Should be >= 2.0
git --version      # Should be >= 2.0

# Configure AWS credentials
aws configure
# AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region name: us-east-1
# Default output format: json

# Verify credentials
aws sts get-caller-identity
```

### Step 2: Clone and Setup

```bash
# Clone repository
git clone <repository-url>
cd Terraform-Capstone-Projects/Project-1-Multi-Tier-Web-Application

# Create backend resources
./scripts/setup-backend.sh

# Or manually:
aws s3api create-bucket \
  --bucket terraform-state-capstone-projects \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket terraform-state-capstone-projects \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Step 3: Configure Variables

```bash
# Navigate to terraform manifests
cd terraform-manifests

# Copy example tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit variables
nano terraform.tfvars
```

**terraform.tfvars**:
```hcl
# General Configuration
aws_region   = "us-east-1"
environment  = "dev"
project_name = "webapp"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

# EC2 Configuration
instance_type        = "t3.micro"
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 2

# RDS Configuration
db_engine            = "postgres"
db_instance_class    = "db.t3.micro"
db_name              = "webapp"
db_username          = "admin"
db_password          = "ChangeMe123!"  # CHANGE THIS!
db_multi_az          = true

# S3 Configuration
s3_versioning_enabled = true

# CloudFront Configuration
cloudfront_price_class = "PriceClass_100"

# Monitoring Configuration
enable_cloudwatch_alarms = true
alarm_email              = "your-email@example.com"

# Tags
common_tags = {
  Terraform   = "true"
  Project     = "Capstone-1"
  Environment = "dev"
  Owner       = "DevOps-Team"
}
```

### Step 4: Initialize Terraform

```bash
# Initialize
terraform init

# Expected output:
# Initializing the backend...
# Successfully configured the backend "s3"!
# Initializing provider plugins...
# - Finding hashicorp/aws versions matching "~> 6.12.0"...
# - Installing hashicorp/aws v6.12.0...
# Terraform has been successfully initialized!
```

### Step 5: Validate and Format

```bash
# Validate configuration
terraform validate
# Success! The configuration is valid.

# Format code
terraform fmt -recursive
# Lists formatted files

# Check formatting
terraform fmt -check -recursive
# Exit code 0 if all files formatted
```

### Step 6: Plan Deployment

```bash
# Create execution plan
terraform plan -out=tfplan

# Expected output:
# Terraform will perform the following actions:
#
#   # aws_vpc.main will be created
#   + resource "aws_vpc" "main" {
#       + cidr_block = "10.0.0.0/16"
#       ...
#     }
#
#   ... (44 more resources)
#
# Plan: 45 to add, 0 to change, 0 to destroy.
#
# Saved the plan to: tfplan

# Review plan output
less tfplan.txt
```

### Step 7: Apply Configuration

```bash
# Apply the plan
terraform apply tfplan

# Progress output:
# aws_vpc.main: Creating...
# aws_vpc.main: Creation complete after 2s [id=vpc-12345]
# aws_internet_gateway.main: Creating...
# aws_subnet.public[0]: Creating...
# ...
# Apply complete! Resources: 45 added, 0 changed, 0 destroyed.
#
# Outputs:
# alb_dns_name = "webapp-dev-alb-123456789.us-east-1.elb.amazonaws.com"
# cloudfront_domain_name = "d1234567890.cloudfront.net"
# rds_endpoint = "webapp-dev-db.c1234567890.us-east-1.rds.amazonaws.com:5432"
# vpc_id = "vpc-12345"
```

### Step 8: Verify Deployment

```bash
# Get outputs
terraform output

# Test ALB
ALB_DNS=$(terraform output -raw alb_dns_name)
curl -I http://$ALB_DNS
# HTTP/1.1 200 OK

# Test health endpoint
curl http://$ALB_DNS/health
# OK

# Check target health
TG_ARN=$(aws elbv2 describe-target-groups \
  --names webapp-dev-tg \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

aws elbv2 describe-target-health --target-group-arn $TG_ARN
# TargetHealth: healthy

# Test CloudFront
CF_DOMAIN=$(terraform output -raw cloudfront_domain_name)
curl -I https://$CF_DOMAIN
# HTTP/2 200
# x-cache: Hit from cloudfront

# View CloudWatch dashboard
aws cloudwatch get-dashboard \
  --dashboard-name webapp-dev-dashboard
```

### Step 9: Monitor Resources

```bash
# View application logs
aws logs tail /aws/ec2/webapp-dev --follow

# Check CloudWatch alarms
aws cloudwatch describe-alarms \
  --alarm-names webapp-dev-alb-unhealthy-targets

# View metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=app/webapp-dev-alb/... \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

### Step 10: Cleanup

```bash
# Destroy infrastructure
terraform destroy

# Confirm with 'yes'

# Expected output:
# aws_instance.web[0]: Destroying... [id=i-12345]
# ...
# Destroy complete! Resources: 45 destroyed.

# Verify cleanup
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=webapp"
# Should return empty

# Clean local files
rm -rf .terraform terraform.tfstate* tfplan
```

---

## DEVELOPMENT ENVIRONMENT

### Configuration

**dev.tfvars**:
```hcl
# Development environment - cost-optimized
aws_region   = "us-east-1"
environment  = "dev"
project_name = "webapp"

# VPC - Single NAT Gateway for cost savings
vpc_cidr           = "10.0.0.0/16"
single_nat_gateway = true  # Save ~$65/month

# EC2 - Minimal capacity
instance_type        = "t3.micro"
asg_min_size         = 1  # Minimum for testing
asg_max_size         = 3
asg_desired_capacity = 1

# RDS - Single-AZ for cost savings
db_instance_class = "db.t3.micro"
db_multi_az       = false  # Save ~$15/month

# Monitoring - Basic
enable_cloudwatch_alarms = true
alarm_email              = "dev-team@example.com"

# Tags
common_tags = {
  Environment = "dev"
  CostCenter  = "Development"
  AutoShutdown = "true"  # For automated shutdown
}
```

### Deployment

```bash
# Deploy development environment
terraform apply -var-file="dev.tfvars"

# Expected monthly cost: ~$80
# - EC2 (1x t3.micro): $7
# - ALB: $20
# - NAT Gateway (1x): $32
# - RDS (db.t3.micro single-AZ): $15
# - S3, CloudFront, etc.: $6
```

### Auto-Shutdown Script

**shutdown-dev.sh**:
```bash
#!/bin/bash
# Automatically shut down dev environment at night

# Stop EC2 instances
INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

if [ -n "$INSTANCE_IDS" ]; then
  echo "Stopping instances: $INSTANCE_IDS"
  aws ec2 stop-instances --instance-ids $INSTANCE_IDS
fi

# Stop RDS instance
aws rds stop-db-instance --db-instance-identifier webapp-dev-db

echo "Dev environment shut down at $(date)"
```

**Cron job** (run at 6 PM weekdays):
```bash
0 18 * * 1-5 /path/to/shutdown-dev.sh
```

---

## STAGING ENVIRONMENT

### Configuration

**staging.tfvars**:
```hcl
# Staging environment - production-like
aws_region   = "us-east-1"
environment  = "staging"
project_name = "webapp"

# VPC - Multi-AZ NAT Gateways
vpc_cidr           = "10.1.0.0/16"
single_nat_gateway = false  # High availability

# EC2 - Moderate capacity
instance_type        = "t3.small"
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 2

# RDS - Multi-AZ
db_instance_class = "db.t3.small"
db_multi_az       = true

# Domain
domain_name          = "staging.example.com"
create_route53_zone  = false  # Use existing zone

# Monitoring - Enhanced
enable_cloudwatch_alarms = true
alarm_email              = "staging-alerts@example.com"

# Tags
common_tags = {
  Environment = "staging"
  CostCenter  = "QA"
}
```

### Deployment

```bash
# Deploy staging environment
terraform workspace new staging
terraform apply -var-file="staging.tfvars"

# Expected monthly cost: ~$180
```

### Blue-Green Deployment Test

```bash
# 1. Deploy green environment
terraform apply -var="environment=staging-green"

# 2. Test green environment
curl -I http://webapp-staging-green-alb.us-east-1.elb.amazonaws.com

# 3. Switch traffic (update Route53)
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://switch-to-green.json

# 4. Monitor for issues
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_5XX_Count \
  --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Sum

# 5. Rollback if needed
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://switch-to-blue.json

# 6. Destroy old blue environment
terraform destroy -var="environment=staging-blue"
```

---

## PRODUCTION ENVIRONMENT

### Configuration

**prod.tfvars**:
```hcl
# Production environment - fully redundant
aws_region   = "us-east-1"
environment  = "prod"
project_name = "webapp"

# VPC - Full redundancy
vpc_cidr           = "10.2.0.0/16"
single_nat_gateway = false

# EC2 - High capacity
instance_type        = "t3.medium"
asg_min_size         = 4  # Minimum 2 per AZ
asg_max_size         = 12
asg_desired_capacity = 4

# RDS - Multi-AZ with read replica
db_instance_class = "db.t3.medium"
db_multi_az       = true

# Domain
domain_name          = "example.com"
create_route53_zone  = true

# CloudFront - Global distribution
cloudfront_price_class = "PriceClass_All"

# Monitoring - Full monitoring
enable_cloudwatch_alarms = true
alarm_email              = "prod-alerts@example.com"

# Tags
common_tags = {
  Environment = "prod"
  CostCenter  = "Production"
  Compliance  = "PCI-DSS"
}
```

### Deployment

```bash
# Deploy production environment
terraform workspace new prod
terraform apply -var-file="prod.tfvars"

# Expected monthly cost: ~$400
```

### Production Checklist

**Pre-Deployment**:
- [ ] Code reviewed and approved
- [ ] Security scan passed
- [ ] Load testing completed
- [ ] Backup verified
- [ ] Rollback plan documented
- [ ] Stakeholders notified
- [ ] Maintenance window scheduled

**Post-Deployment**:
- [ ] All health checks passing
- [ ] Monitoring configured
- [ ] Alarms tested
- [ ] Backup verified
- [ ] Documentation updated
- [ ] Stakeholders notified

---

## CUSTOM DOMAIN SETUP

### Prerequisites

```bash
# 1. Register domain (if not already)
# Use Route53 or external registrar

# 2. Request ACM certificate
aws acm request-certificate \
  --domain-name example.com \
  --subject-alternative-names "*.example.com" \
  --validation-method DNS \
  --region us-east-1

# 3. Validate certificate
# Add DNS records provided by ACM

# 4. Wait for validation
aws acm wait certificate-validated \
  --certificate-arn arn:aws:acm:us-east-1:123456789012:certificate/...
```

### Configuration

**domain.tfvars**:
```hcl
# Domain configuration
domain_name          = "example.com"
create_route53_zone  = true

# All other variables from prod.tfvars
```

### Deployment

```bash
# Deploy with custom domain
terraform apply -var-file="prod.tfvars" -var-file="domain.tfvars"

# Get nameservers
terraform output route53_name_servers

# Update domain registrar with nameservers
# ns-1234.awsdns-12.org
# ns-5678.awsdns-34.com
# ns-9012.awsdns-56.net
# ns-3456.awsdns-78.co.uk

# Wait for DNS propagation (up to 48 hours)
dig example.com NS

# Test domain
curl -I https://example.com
curl -I https://cdn.example.com
```

---

## MULTI-REGION DEPLOYMENT

### Primary Region (us-east-1)

**us-east-1.tfvars**:
```hcl
aws_region   = "us-east-1"
environment  = "prod"
project_name = "webapp"

# Standard production configuration
```

### Secondary Region (us-west-2)

**us-west-2.tfvars**:
```hcl
aws_region   = "us-west-2"
environment  = "prod"
project_name = "webapp"

vpc_cidr = "10.3.0.0/16"  # Different CIDR

# Same configuration as primary
```

### Deployment

```bash
# Deploy primary region
cd us-east-1
terraform init
terraform apply -var-file="us-east-1.tfvars"

# Deploy secondary region
cd ../us-west-2
terraform init
terraform apply -var-file="us-west-2.tfvars"

# Set up Route53 failover
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://failover-config.json
```

**failover-config.json**:
```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "example.com",
        "Type": "A",
        "SetIdentifier": "Primary",
        "Failover": "PRIMARY",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "webapp-prod-alb-us-east-1.elb.amazonaws.com",
          "EvaluateTargetHealth": true
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "example.com",
        "Type": "A",
        "SetIdentifier": "Secondary",
        "Failover": "SECONDARY",
        "AliasTarget": {
          "HostedZoneId": "Z3DZXE0Q79N41H",
          "DNSName": "webapp-prod-alb-us-west-2.elb.amazonaws.com",
          "EvaluateTargetHealth": true
        }
      }
    }
  ]
}
```

---

## BLUE-GREEN DEPLOYMENT

### Step 1: Deploy Green Environment

```bash
# Create green workspace
terraform workspace new green

# Deploy green with new version
terraform apply \
  -var="environment=prod-green" \
  -var="ami_id=ami-new-version"

# Get green ALB DNS
GREEN_ALB=$(terraform output -raw alb_dns_name)
```

### Step 2: Test Green Environment

```bash
# Smoke tests
curl -I http://$GREEN_ALB
curl http://$GREEN_ALB/health

# Load test
ab -n 1000 -c 10 http://$GREEN_ALB/

# Monitor metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=app/webapp-prod-green-alb/... \
  --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Average
```

### Step 3: Switch Traffic

```bash
# Update Route53 to point to green
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "'$GREEN_ALB'",
          "EvaluateTargetHealth": true
        }
      }
    }]
  }'

# Wait for DNS propagation
sleep 60

# Verify traffic switched
dig example.com
```

### Step 4: Monitor

```bash
# Monitor for 30 minutes
for i in {1..30}; do
  echo "Minute $i:"
  
  # Check error rate
  aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name HTTPCode_Target_5XX_Count \
    --dimensions Name=LoadBalancer,Value=app/webapp-prod-green-alb/... \
    --start-time $(date -u -d '1 minute ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 60 \
    --statistics Sum \
    --query 'Datapoints[0].Sum'
  
  sleep 60
done
```

### Step 5: Rollback (if needed)

```bash
# Switch back to blue
BLUE_ALB=$(terraform output -raw alb_dns_name -state=blue/terraform.tfstate)

aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "'$BLUE_ALB'",
          "EvaluateTargetHealth": true
        }
      }
    }]
  }'
```

### Step 6: Cleanup

```bash
# After successful deployment, destroy blue
terraform workspace select blue
terraform destroy

# Rename green to blue
terraform workspace select green
terraform workspace new blue
terraform state mv -state=green/terraform.tfstate -state-out=blue/terraform.tfstate
```

---

## DISASTER RECOVERY

### Backup Procedures

```bash
# 1. Backup Terraform state
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# 2. Backup RDS
aws rds create-db-snapshot \
  --db-instance-identifier webapp-prod-db \
  --db-snapshot-identifier webapp-prod-db-$(date +%Y%m%d-%H%M%S)

# 3. Backup S3
aws s3 sync s3://webapp-prod-static-assets s3://webapp-prod-backup/$(date +%Y%m%d)/

# 4. Export configuration
terraform show -json > infrastructure-$(date +%Y%m%d).json
```

### Recovery Procedures

**Scenario 1: Single Resource Failure**
```bash
# Identify failed resource
terraform state list

# Recreate resource
terraform apply -target=aws_instance.web[0]
```

**Scenario 2: Complete Region Failure**
```bash
# 1. Switch to secondary region (if multi-region)
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://failover-to-secondary.json

# 2. Or deploy to new region
cd us-west-2
terraform init
terraform apply -var-file="prod.tfvars"

# 3. Restore RDS from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier webapp-prod-db-restored \
  --db-snapshot-identifier webapp-prod-db-20251027-120000

# 4. Update DNS
terraform output alb_dns_name
# Update Route53 to point to new ALB
```

**Scenario 3: Complete Infrastructure Loss**
```bash
# 1. Restore state file
aws s3 cp s3://terraform-state-capstone-projects/project-1/terraform.tfstate terraform.tfstate

# 2. Recreate infrastructure
terraform init
terraform apply

# 3. Restore data
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier webapp-prod-db \
  --db-snapshot-identifier latest-snapshot

aws s3 sync s3://webapp-prod-backup/latest/ s3://webapp-prod-static-assets/
```

---

## COST OPTIMIZATION

### Reserved Instances

```bash
# 1. Analyze usage
aws ce get-reservation-utilization \
  --time-period Start=2025-10-01,End=2025-10-27 \
  --granularity MONTHLY

# 2. Purchase Reserved Instances
aws ec2 purchase-reserved-instances-offering \
  --reserved-instances-offering-id <offering-id> \
  --instance-count 2

# 3. Purchase RDS Reserved Instances
aws rds purchase-reserved-db-instances-offering \
  --reserved-db-instances-offering-id <offering-id> \
  --db-instance-count 1

# Expected savings: 30-40%
```

### Savings Plans

```bash
# 1. Get recommendations
aws ce get-savings-plans-purchase-recommendation \
  --savings-plans-type COMPUTE_SP \
  --term-in-years ONE_YEAR \
  --payment-option NO_UPFRONT

# 2. Purchase Savings Plan
aws savingsplans create-savings-plan \
  --savings-plan-offering-id <offering-id> \
  --commitment 10.00

# Expected savings: 30-50%
```

### Auto-Scaling Optimization

```hcl
# Scheduled scaling for predictable traffic
resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "scale-up-business-hours"
  min_size               = 4
  max_size               = 12
  desired_capacity       = 4
  recurrence             = "0 8 * * MON-FRI"
  time_zone              = "America/New_York"
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name  = "scale-down-after-hours"
  min_size               = 2
  max_size               = 6
  desired_capacity       = 2
  recurrence             = "0 18 * * MON-FRI"
  time_zone              = "America/New_York"
  autoscaling_group_name = aws_autoscaling_group.main.name
}
```

---

## SECURITY HARDENING

### Enable GuardDuty

```bash
# Enable GuardDuty
aws guardduty create-detector --enable

# Get detector ID
DETECTOR_ID=$(aws guardduty list-detectors --query 'DetectorIds[0]' --output text)

# View findings
aws guardduty list-findings --detector-id $DETECTOR_ID
```

### Enable Security Hub

```bash
# Enable Security Hub
aws securityhub enable-security-hub

# Enable standards
aws securityhub batch-enable-standards \
  --standards-subscription-requests '[
    {"StandardsArn": "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"},
    {"StandardsArn": "arn:aws:securityhub:us-east-1::standards/cis-aws-foundations-benchmark/v/1.2.0"}
  ]'

# View findings
aws securityhub get-findings
```

### Enable AWS Config

```bash
# Create S3 bucket for Config
aws s3api create-bucket \
  --bucket aws-config-webapp-prod \
  --region us-east-1

# Enable Config
aws configservice put-configuration-recorder \
  --configuration-recorder name=default,roleARN=arn:aws:iam::123456789012:role/aws-config-role \
  --recording-group allSupported=true,includeGlobalResourceTypes=true

aws configservice put-delivery-channel \
  --delivery-channel name=default,s3BucketName=aws-config-webapp-prod

aws configservice start-configuration-recorder \
  --configuration-recorder-name default
```

---

## INTEGRATION EXAMPLES

### CI/CD Pipeline (GitHub Actions)

**.github/workflows/terraform.yml**:
```yaml
name: Terraform

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.13.0
    
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Terraform Init
      run: terraform init
      working-directory: ./terraform-manifests
    
    - name: Terraform Validate
      run: terraform validate
      working-directory: ./terraform-manifests
    
    - name: Terraform Format
      run: terraform fmt -check -recursive
      working-directory: ./terraform-manifests
    
    - name: Terraform Plan
      run: terraform plan -out=tfplan
      working-directory: ./terraform-manifests
    
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve tfplan
      working-directory: ./terraform-manifests
```

### Monitoring Integration (Datadog)

```hcl
# Add Datadog agent to user data
resource "aws_launch_template" "main" {
  user_data = base64encode(templatefile("${path.module}/user-data.sh.tpl", {
    # ... other variables ...
    datadog_api_key = var.datadog_api_key
  }))
}
```

**user-data.sh.tpl** (add to existing):
```bash
# Install Datadog agent
DD_API_KEY=${datadog_api_key} DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Configure Datadog
cat > /etc/datadog-agent/datadog.yaml <<EOF
api_key: ${datadog_api_key}
site: datadoghq.com
tags:
  - env:${environment}
  - project:${project_name}
EOF

# Start Datadog agent
systemctl start datadog-agent
systemctl enable datadog-agent
```

---

**Document Version**: 1.0  
**Last Updated**: October 27, 2025  
**Status**: Complete  
**Total Lines**: 900+

