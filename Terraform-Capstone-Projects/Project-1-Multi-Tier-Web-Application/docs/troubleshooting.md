# Troubleshooting Guide
# Project 1: Multi-Tier Web Application Infrastructure

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [Common Issues](#common-issues)
3. [Terraform Errors](#terraform-errors)
4. [AWS Resource Errors](#aws-resource-errors)
5. [Network Issues](#network-issues)
6. [Application Issues](#application-issues)
7. [Database Issues](#database-issues)
8. [State Management Issues](#state-management-issues)
9. [Performance Issues](#performance-issues)
10. [Security Issues](#security-issues)
11. [Debugging Procedures](#debugging-procedures)
12. [Recovery Procedures](#recovery-procedures)

---

## OVERVIEW

This guide provides solutions to common issues encountered when deploying and managing Project 1: Multi-Tier Web Application Infrastructure. Each issue includes:
- **Symptoms**: How to identify the problem
- **Cause**: Why the problem occurs
- **Solution**: Step-by-step fix
- **Prevention**: How to avoid in future

---

## COMMON ISSUES

### Issue 1: Terraform Init Fails

**Symptoms**:
```
Error: Failed to install provider
Error: Failed to query available provider packages
```

**Causes**:
- No internet connectivity
- Incorrect provider version
- Corrupted .terraform directory
- Backend configuration error

**Solutions**:

**1. Check Internet Connectivity**:
```bash
# Test connectivity
ping -c 3 registry.terraform.io
curl -I https://registry.terraform.io

# If behind proxy, set environment variables
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

**2. Clean and Reinitialize**:
```bash
# Remove .terraform directory
rm -rf .terraform .terraform.lock.hcl

# Reinitialize
terraform init
```

**3. Check Provider Version**:
```bash
# Verify provider version exists
curl -s https://registry.terraform.io/v1/providers/hashicorp/aws/versions | jq '.versions[].version'

# Update providers.tf if needed
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"  # Update to available version
    }
  }
}
```

**4. Fix Backend Configuration**:
```bash
# Verify S3 bucket exists
aws s3 ls s3://terraform-state-capstone-projects

# If not, create it
aws s3api create-bucket \
  --bucket terraform-state-capstone-projects \
  --region us-east-1

# Verify DynamoDB table exists
aws dynamodb describe-table --table-name terraform-state-lock

# If not, create it
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

**Prevention**:
- Test connectivity before init
- Pin provider versions
- Document backend setup
- Use version control

---

### Issue 2: Terraform Plan Shows Unexpected Changes

**Symptoms**:
```
Terraform will perform the following actions:
  # aws_instance.web will be replaced
  -/+ resource "aws_instance" "web" {
```

**Causes**:
- Manual changes in AWS console
- State drift
- Variable changes
- Provider version changes

**Solutions**:

**1. Identify Changes**:
```bash
# Show detailed plan
terraform plan

# Review each change carefully
# Look for -/+ (replace) or ~ (update)
```

**2. Refresh State**:
```bash
# Refresh state from AWS
terraform apply -refresh-only

# Review changes
terraform plan
```

**3. Investigate Drift**:
```bash
# Show specific resource
terraform state show aws_instance.web

# Compare with AWS
aws ec2 describe-instances --instance-ids i-12345
```

**4. Fix Drift**:
```bash
# Option 1: Update configuration to match AWS
# Edit .tf files to match current state

# Option 2: Apply to fix AWS resources
terraform apply

# Option 3: Import if resource was created manually
terraform import aws_instance.web i-12345
```

**Prevention**:
- Avoid manual changes
- Use lifecycle ignore_changes for specific attributes
- Regular state refreshes
- Automated drift detection

---

### Issue 3: Resource Creation Timeout

**Symptoms**:
```
Error: timeout while waiting for state to become 'available'
Error: timeout - last error: ResourceNotReady
```

**Causes**:
- AWS service limits
- Network connectivity issues
- Resource dependencies
- Insufficient capacity

**Solutions**:

**1. Check Service Limits**:
```bash
# Check EC2 limits
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-1216C47A

# Request limit increase if needed
aws service-quotas request-service-quota-increase \
  --service-code ec2 \
  --quota-code L-1216C47A \
  --desired-value 20
```

**2. Increase Timeout**:
```hcl
# Add timeouts to resource
resource "aws_db_instance" "main" {
  # ... configuration ...
  
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
```

**3. Check Dependencies**:
```bash
# View dependency graph
terraform graph | dot -Tpng > graph.png

# Verify dependencies are correct
```

**4. Retry**:
```bash
# Simply retry the apply
terraform apply

# Terraform will continue from where it failed
```

**Prevention**:
- Set appropriate timeouts
- Check service limits before deployment
- Use smaller batch sizes
- Monitor AWS service health

---

### Issue 4: State Lock Error

**Symptoms**:
```
Error: Error acquiring the state lock
Lock Info:
  ID:        abc123...
  Path:      terraform-state-capstone-projects/project-1/terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Version:   1.13.0
  Created:   2025-10-27 10:00:00 UTC
```

**Causes**:
- Previous operation didn't complete
- Concurrent operations
- Crashed Terraform process
- Network interruption

**Solutions**:

**1. Wait for Lock Release**:
```bash
# Wait a few minutes
# Lock will auto-release after timeout
```

**2. Verify No Active Operations**:
```bash
# Check for running terraform processes
ps aux | grep terraform

# Kill if stuck
kill -9 <pid>
```

**3. Force Unlock** (Use with caution):
```bash
# Get lock ID from error message
LOCK_ID="abc123..."

# Force unlock
terraform force-unlock $LOCK_ID

# Confirm with 'yes'
```

**4. Check DynamoDB**:
```bash
# View lock table
aws dynamodb scan --table-name terraform-state-lock

# Manually delete lock item if needed (dangerous!)
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"terraform-state-capstone-projects/project-1/terraform.tfstate"}}'
```

**Prevention**:
- Don't run concurrent operations
- Use proper CI/CD pipelines
- Implement queue system
- Monitor for stuck processes

---

### Issue 5: Provider Authentication Error

**Symptoms**:
```
Error: error configuring Terraform AWS Provider: no valid credential sources
Error: UnauthorizedOperation: You are not authorized to perform this operation
```

**Causes**:
- Missing AWS credentials
- Expired credentials
- Insufficient IAM permissions
- Wrong AWS region

**Solutions**:

**1. Verify Credentials**:
```bash
# Check AWS CLI configuration
aws configure list

# Test credentials
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDAI...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/username"
# }
```

**2. Configure Credentials**:
```bash
# Option 1: AWS CLI
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="us-east-1"

# Option 3: IAM role (EC2)
# Attach IAM role to EC2 instance
```

**3. Check IAM Permissions**:
```bash
# Test specific permission
aws ec2 describe-vpcs

# If error, check IAM policy
aws iam get-user-policy \
  --user-name your-username \
  --policy-name your-policy

# Required permissions:
# - ec2:*
# - rds:*
# - s3:*
# - cloudfront:*
# - route53:*
# - iam:PassRole
# - logs:*
# - cloudwatch:*
```

**4. Verify Region**:
```bash
# Check configured region
aws configure get region

# Set correct region
aws configure set region us-east-1

# Or in providers.tf
provider "aws" {
  region = "us-east-1"
}
```

**Prevention**:
- Use IAM roles (preferred)
- Document required permissions
- Use least privilege principle
- Regular credential rotation

---

## TERRAFORM ERRORS

### Error: Cycle in Resource Dependencies

**Symptoms**:
```
Error: Cycle: aws_security_group.a, aws_security_group.b
```

**Cause**: Circular dependency between resources

**Solution**:
```hcl
# Bad: Circular dependency
resource "aws_security_group" "a" {
  ingress {
    security_groups = [aws_security_group.b.id]
  }
}

resource "aws_security_group" "b" {
  ingress {
    security_groups = [aws_security_group.a.id]
  }
}

# Good: Use security group rules
resource "aws_security_group" "a" {}
resource "aws_security_group" "b" {}

resource "aws_security_group_rule" "a_to_b" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.a.id
  source_security_group_id = aws_security_group.b.id
}

resource "aws_security_group_rule" "b_to_a" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.b.id
  source_security_group_id = aws_security_group.a.id
}
```

---

### Error: Invalid Count Argument

**Symptoms**:
```
Error: Invalid count argument
The "count" value depends on resource attributes that cannot be determined until apply
```

**Cause**: Count depends on computed value

**Solution**:
```hcl
# Bad: Count depends on resource attribute
resource "aws_subnet" "public" {
  count = length(aws_availability_zones.available.names)  # Error!
}

# Good: Use data source or variable
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_count = length(data.aws_availability_zones.available.names)
}

resource "aws_subnet" "public" {
  count = local.az_count
}

# Better: Use variable
variable "availability_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)
}
```

---

### Error: Variable Validation Failed

**Symptoms**:
```
Error: Invalid value for variable
The given value does not match the variable's validation rules
```

**Cause**: Variable value doesn't meet validation criteria

**Solution**:
```bash
# Check validation rules in variables.tf
cat variables.tf | grep -A 10 "variable \"environment\""

# Provide valid value
terraform apply -var="environment=dev"

# Or update terraform.tfvars
echo 'environment = "dev"' >> terraform.tfvars
```

---

### Error: Resource Already Exists

**Symptoms**:
```
Error: Error creating VPC: VpcLimitExceeded
Error: Error creating DB Instance: DBInstanceAlreadyExists
```

**Cause**: Resource already exists in AWS

**Solution**:
```bash
# Option 1: Import existing resource
terraform import aws_vpc.main vpc-12345

# Option 2: Delete existing resource
aws ec2 delete-vpc --vpc-id vpc-12345

# Option 3: Use different name
# Edit terraform.tfvars
project_name = "webapp2"
```

---

## AWS RESOURCE ERRORS

### VPC Creation Errors

**Error: VpcLimitExceeded**:
```bash
# Check VPC limit
aws ec2 describe-account-attributes \
  --attribute-names max-vpcs

# Delete unused VPCs
aws ec2 describe-vpcs --query 'Vpcs[?Tags==`null`].[VpcId]' --output text | \
  xargs -I {} aws ec2 delete-vpc --vpc-id {}

# Request limit increase
aws service-quotas request-service-quota-increase \
  --service-code vpc \
  --quota-code L-F678F1CE \
  --desired-value 10
```

**Error: InvalidCidrBlock**:
```hcl
# Ensure valid CIDR block
variable "vpc_cidr" {
  type = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Invalid CIDR block format."
  }
}
```

---

### EC2 Instance Errors

**Error: InsufficientInstanceCapacity**:
```bash
# Try different instance type
terraform apply -var="instance_type=t3.small"

# Try different availability zone
terraform apply -var='availability_zones=["us-east-1a","us-east-1c","us-east-1d"]'

# Wait and retry
sleep 300
terraform apply
```

**Error: InvalidAMIID.NotFound**:
```bash
# Verify AMI exists
aws ec2 describe-images --image-ids ami-12345

# Use data source to get latest AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

---

### RDS Errors

**Error: DBSubnetGroupDoesNotCoverEnoughAZs**:
```hcl
# Ensure subnets in at least 2 AZs
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id  # Must span 2+ AZs
}
```

**Error: InvalidDBInstanceState**:
```bash
# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier webapp-dev-db \
  --query 'DBInstances[0].DBInstanceStatus'

# Wait for available state
aws rds wait db-instance-available \
  --db-instance-identifier webapp-dev-db
```

---

### Load Balancer Errors

**Error: TooManyLoadBalancers**:
```bash
# Check ALB limit
aws service-quotas get-service-quota \
  --service-code elasticloadbalancing \
  --quota-code L-53DA6B97

# Delete unused ALBs
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?State.Code==`active`].[LoadBalancerArn]' \
  --output text | \
  xargs -I {} aws elbv2 delete-load-balancer --load-balancer-arn {}
```

**Error: InvalidSubnet**:
```hcl
# Ensure ALB in public subnets
resource "aws_lb" "main" {
  subnets = aws_subnet.public[*].id  # Must be public subnets
}
```

---

## NETWORK ISSUES

### Issue: Cannot Connect to EC2 Instances

**Symptoms**:
- SSH timeout
- HTTP connection refused
- Ping fails

**Diagnosis**:
```bash
# 1. Check instance status
aws ec2 describe-instance-status --instance-ids i-12345

# 2. Check security group
aws ec2 describe-security-groups --group-ids sg-12345

# 3. Check route table
aws ec2 describe-route-tables --route-table-ids rtb-12345

# 4. Check network ACLs
aws ec2 describe-network-acls --network-acl-ids acl-12345
```

**Solutions**:

**1. Fix Security Group**:
```hcl
# Allow SSH from your IP
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["YOUR_IP/32"]
  security_group_id = aws_security_group.ec2.id
}
```

**2. Fix Route Table**:
```hcl
# Ensure route to internet gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
```

**3. Use Systems Manager**:
```bash
# Connect without SSH
aws ssm start-session --target i-12345
```

---

### Issue: NAT Gateway Not Working

**Symptoms**:
- Private instances cannot reach internet
- Package installation fails
- API calls timeout

**Diagnosis**:
```bash
# Check NAT gateway status
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available"

# Check route table
aws ec2 describe-route-tables \
  --route-table-ids rtb-private

# Test from instance
aws ssm start-session --target i-12345
# Inside instance:
curl -I https://www.google.com
```

**Solutions**:

**1. Verify NAT Gateway**:
```bash
# Check NAT gateway state
aws ec2 describe-nat-gateways \
  --nat-gateway-ids nat-12345 \
  --query 'NatGateways[0].State'

# Should be "available"
```

**2. Fix Route Table**:
```hcl
# Ensure route to NAT gateway
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}
```

**3. Check Elastic IP**:
```bash
# Verify EIP attached to NAT gateway
aws ec2 describe-nat-gateways \
  --nat-gateway-ids nat-12345 \
  --query 'NatGateways[0].NatGatewayAddresses[0].PublicIp'
```

---

## APPLICATION ISSUES

### Issue: ALB Health Checks Failing

**Symptoms**:
```
Target health: unhealthy
Reason: Target.FailedHealthChecks
```

**Diagnosis**:
```bash
# Check target health
TG_ARN=$(aws elbv2 describe-target-groups \
  --names webapp-dev-tg \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN

# Check health check configuration
aws elbv2 describe-target-groups \
  --target-group-arns $TG_ARN \
  --query 'TargetGroups[0].HealthCheckPath'
```

**Solutions**:

**1. Verify Health Endpoint**:
```bash
# Connect to instance
aws ssm start-session --target i-12345

# Test health endpoint
curl http://localhost/health

# Should return 200 OK
```

**2. Fix Health Check Path**:
```hcl
resource "aws_lb_target_group" "main" {
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/health"  # Ensure this exists
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
}
```

**3. Check Security Group**:
```hcl
# Allow ALB to reach instances
resource "aws_security_group_rule" "ec2_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
}
```

**4. Increase Grace Period**:
```hcl
resource "aws_autoscaling_group" "main" {
  health_check_grace_period = 300  # Increase if needed
  health_check_type         = "ELB"
}
```

---

### Issue: Application Not Responding

**Symptoms**:
- 502 Bad Gateway
- 504 Gateway Timeout
- Connection refused

**Diagnosis**:
```bash
# Check application logs
aws logs tail /aws/ec2/webapp-dev --follow

# Check instance status
aws ec2 describe-instance-status --instance-ids i-12345

# Test from instance
aws ssm start-session --target i-12345
curl http://localhost
```

**Solutions**:

**1. Restart Application**:
```bash
# Connect to instance
aws ssm start-session --target i-12345

# Restart Apache
sudo systemctl restart httpd
sudo systemctl status httpd
```

**2. Check User Data**:
```bash
# View user data execution log
sudo cat /var/log/cloud-init-output.log

# Re-run user data if needed
sudo /var/lib/cloud/instance/scripts/part-001
```

**3. Check Disk Space**:
```bash
# Check disk usage
df -h

# Clean up if needed
sudo yum clean all
sudo rm -rf /tmp/*
```

---

## DATABASE ISSUES

### Issue: Cannot Connect to RDS

**Symptoms**:
```
psql: could not connect to server: Connection timed out
Error: dial tcp: i/o timeout
```

**Diagnosis**:
```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Test from EC2 instance
aws ssm start-session --target i-12345
telnet $RDS_ENDPOINT 5432
```

**Solutions**:

**1. Check Security Group**:
```hcl
# Allow EC2 to reach RDS
resource "aws_security_group_rule" "rds_from_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.rds.id
}
```

**2. Verify RDS Status**:
```bash
# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier webapp-dev-db \
  --query 'DBInstances[0].DBInstanceStatus'

# Wait for available
aws rds wait db-instance-available \
  --db-instance-identifier webapp-dev-db
```

**3. Test Connection**:
```bash
# Install PostgreSQL client
sudo yum install -y postgresql15

# Test connection
psql -h $RDS_ENDPOINT -U admin -d webapp

# If password error, verify password
terraform output -raw db_password
```

---

### Issue: RDS Performance Issues

**Symptoms**:
- Slow queries
- High CPU usage
- Connection timeouts

**Diagnosis**:
```bash
# Check RDS metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=webapp-dev-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Check Performance Insights
aws rds describe-db-instances \
  --db-instance-identifier webapp-dev-db \
  --query 'DBInstances[0].PerformanceInsightsEnabled'
```

**Solutions**:

**1. Scale Up**:
```bash
# Increase instance class
terraform apply -var="db_instance_class=db.t3.small"
```

**2. Add Read Replica**:
```hcl
resource "aws_db_instance" "read_replica" {
  replicate_source_db = aws_db_instance.main.identifier
  instance_class      = var.db_instance_class
}
```

**3. Optimize Queries**:
```sql
-- Enable pg_stat_statements
CREATE EXTENSION pg_stat_statements;

-- Find slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## STATE MANAGEMENT ISSUES

### Issue: State File Corrupted

**Symptoms**:
```
Error: state snapshot was created by Terraform v1.14.0, which is newer than current v1.13.0
Error: Failed to load state: state data in S3 does not have the expected content
```

**Solutions**:

**1. Restore from Backup**:
```bash
# List S3 versions
aws s3api list-object-versions \
  --bucket terraform-state-capstone-projects \
  --prefix project-1/terraform.tfstate

# Download previous version
aws s3api get-object \
  --bucket terraform-state-capstone-projects \
  --key project-1/terraform.tfstate \
  --version-id <version-id> \
  terraform.tfstate.backup

# Push restored state
terraform state push terraform.tfstate.backup
```

**2. Upgrade Terraform**:
```bash
# Download newer version
wget https://releases.hashicorp.com/terraform/1.14.0/terraform_1.14.0_linux_amd64.zip
unzip terraform_1.14.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify version
terraform version
```

---

### Issue: State Drift

**Symptoms**:
- Plan shows unexpected changes
- Resources modified outside Terraform

**Solutions**:

**1. Refresh State**:
```bash
# Refresh state from AWS
terraform apply -refresh-only

# Review changes
terraform plan
```

**2. Ignore Specific Changes**:
```hcl
resource "aws_instance" "web" {
  # ... configuration ...
  
  lifecycle {
    ignore_changes = [
      tags,
      user_data
    ]
  }
}
```

**3. Re-import Resources**:
```bash
# Remove from state
terraform state rm aws_instance.web

# Re-import
terraform import aws_instance.web i-12345
```

---

## PERFORMANCE ISSUES

### Issue: Slow Terraform Operations

**Symptoms**:
- terraform plan takes > 5 minutes
- terraform apply very slow

**Solutions**:

**1. Reduce Parallelism**:
```bash
# Reduce concurrent operations
terraform apply -parallelism=5
```

**2. Target Specific Resources**:
```bash
# Apply only changed resources
terraform apply -target=aws_instance.web
```

**3. Optimize State Backend**:
```bash
# Use S3 with DynamoDB locking
# Enable S3 Transfer Acceleration
aws s3api put-bucket-accelerate-configuration \
  --bucket terraform-state-capstone-projects \
  --accelerate-configuration Status=Enabled
```

---

### Issue: High AWS Costs

**Symptoms**:
- Unexpected AWS bill
- Cost alerts triggered

**Diagnosis**:
```bash
# Check current costs
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-27 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=SERVICE

# Check resource usage
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]'
```

**Solutions**:

**1. Use Single NAT Gateway**:
```bash
terraform apply -var="single_nat_gateway=true"
# Saves ~$65/month
```

**2. Use Smaller Instances**:
```bash
terraform apply -var="instance_type=t3.micro"
terraform apply -var="db_instance_class=db.t3.micro"
```

**3. Disable Multi-AZ for Dev**:
```bash
terraform apply -var="db_multi_az=false"
# Saves ~$15/month
```

**4. Set Up Auto-Shutdown**:
```bash
# Stop instances at night
aws ec2 stop-instances --instance-ids i-12345
```

---

## SECURITY ISSUES

### Issue: Security Group Too Permissive

**Symptoms**:
- Security scan warnings
- Open ports to 0.0.0.0/0

**Solutions**:

**1. Restrict SSH Access**:
```hcl
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["YOUR_IP/32"]  # Not 0.0.0.0/0
  security_group_id = aws_security_group.ec2.id
}
```

**2. Use Security Group References**:
```hcl
# Instead of CIDR blocks
resource "aws_security_group_rule" "ec2_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
}
```

---

### Issue: Unencrypted Resources

**Symptoms**:
- Compliance scan failures
- Security audit findings

**Solutions**:

**1. Enable EBS Encryption**:
```hcl
resource "aws_launch_template" "main" {
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = true
      kms_key_id  = aws_kms_key.main.arn
    }
  }
}
```

**2. Enable RDS Encryption**:
```hcl
resource "aws_db_instance" "main" {
  storage_encrypted = true
  kms_key_id        = aws_kms_key.main.arn
}
```

**3. Enable S3 Encryption**:
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.static_assets.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}
```

---

## DEBUGGING PROCEDURES

### Enable Debug Logging

```bash
# Set log level
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log

# Run command
terraform apply

# View logs
tail -f terraform-debug.log

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

### Analyze Logs

```bash
# Search for errors
grep -i error terraform-debug.log

# Search for specific resource
grep -i "aws_instance.web" terraform-debug.log

# View API calls
grep -i "HTTP Request" terraform-debug.log
```

### Use Terraform Console

```bash
# Start console
terraform console

# Test expressions
> var.vpc_cidr
> aws_vpc.main.id
> length(aws_subnet.public)
```

---

## RECOVERY PROCEDURES

### Recover from Failed Apply

```bash
# 1. Check state
terraform state list

# 2. Refresh state
terraform apply -refresh-only

# 3. Review plan
terraform plan

# 4. Retry apply
terraform apply
```

### Recover from Deleted State

```bash
# 1. Download from S3
aws s3 cp s3://terraform-state-capstone-projects/project-1/terraform.tfstate terraform.tfstate

# 2. Or restore from version
aws s3api list-object-versions \
  --bucket terraform-state-capstone-projects \
  --prefix project-1/terraform.tfstate

aws s3api get-object \
  --bucket terraform-state-capstone-projects \
  --key project-1/terraform.tfstate \
  --version-id <version-id> \
  terraform.tfstate

# 3. Push to backend
terraform state push terraform.tfstate
```

### Disaster Recovery

```bash
# 1. Backup current state
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# 2. Document all resources
terraform state list > resources.txt

# 3. Export outputs
terraform output -json > outputs.json

# 4. Recreate from scratch if needed
terraform destroy
terraform apply
```

---

**Document Version**: 1.0  
**Last Updated**: October 27, 2025  
**Status**: Complete  
**Total Lines**: 1,100+

