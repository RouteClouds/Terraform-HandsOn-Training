# Validation and Testing Guide
# Project 1: Multi-Tier Web Application Infrastructure

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [Pre-Deployment Validation](#pre-deployment-validation)
3. [Post-Deployment Validation](#post-deployment-validation)
4. [Success Criteria](#success-criteria)
5. [Functional Testing](#functional-testing)
6. [Performance Testing](#performance-testing)
7. [Security Testing](#security-testing)
8. [Compliance Validation](#compliance-validation)
9. [Cost Validation](#cost-validation)
10. [Automated Testing](#automated-testing)

---

## OVERVIEW

This document provides comprehensive validation and testing procedures for Project 1: Multi-Tier Web Application Infrastructure. Use these procedures to ensure the infrastructure meets all requirements and functions correctly.

---

## PRE-DEPLOYMENT VALIDATION

### 1. Configuration Validation

**Terraform Syntax**:
```bash
# Validate syntax
terraform validate

# Expected output:
# Success! The configuration is valid.

# If errors:
# Error: Unsupported argument
#   on vpc.tf line 10:
#   10:   invalid_argument = "value"
```

**Formatting Check**:
```bash
# Check formatting
terraform fmt -check -recursive

# Exit code 0: All files formatted
# Exit code 3: Files need formatting

# Format files
terraform fmt -recursive
```

**Variable Validation**:
```bash
# Check required variables
grep -r "variable" *.tf | grep -v "default"

# Verify terraform.tfvars has all required values
cat terraform.tfvars

# Test variable validation rules
terraform plan -var="environment=invalid"
# Should fail with validation error
```

### 2. Backend Validation

**S3 Bucket**:
```bash
# Verify bucket exists
aws s3 ls s3://terraform-state-capstone-projects

# Check versioning
aws s3api get-bucket-versioning \
  --bucket terraform-state-capstone-projects

# Expected output:
# {
#     "Status": "Enabled"
# }

# Check encryption
aws s3api get-bucket-encryption \
  --bucket terraform-state-capstone-projects

# Expected output:
# {
#     "ServerSideEncryptionConfiguration": {
#         "Rules": [{
#             "ApplyServerSideEncryptionByDefault": {
#                 "SSEAlgorithm": "AES256"
#             }
#         }]
#     }
# }
```

**DynamoDB Table**:
```bash
# Verify table exists
aws dynamodb describe-table \
  --table-name terraform-state-lock

# Expected output:
# {
#     "Table": {
#         "TableName": "terraform-state-lock",
#         "TableStatus": "ACTIVE",
#         "KeySchema": [{
#             "AttributeName": "LockID",
#             "KeyType": "HASH"
#         }]
#     }
# }
```

### 3. AWS Credentials Validation

**Verify Credentials**:
```bash
# Check credentials
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDAI...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/username"
# }
```

**Check Permissions**:
```bash
# Test EC2 permissions
aws ec2 describe-vpcs --max-results 1

# Test RDS permissions
aws rds describe-db-instances --max-records 1

# Test S3 permissions
aws s3 ls

# Test IAM permissions
aws iam get-user
```

### 4. Service Limits Validation

**EC2 Limits**:
```bash
# Check VPC limit
aws ec2 describe-account-attributes \
  --attribute-names max-vpcs

# Check instance limit
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-1216C47A

# Check EIP limit
aws ec2 describe-account-attributes \
  --attribute-names max-elastic-ips
```

**RDS Limits**:
```bash
# Check DB instance limit
aws service-quotas get-service-quota \
  --service-code rds \
  --quota-code L-7B6409FD

# Check DB subnet group limit
aws service-quotas get-service-quota \
  --service-code rds \
  --quota-code L-48C6BF61
```

### 5. Plan Review

**Generate Plan**:
```bash
# Create plan
terraform plan -out=tfplan | tee plan-output.txt

# Review plan output
less plan-output.txt
```

**Checklist**:
- [ ] Expected number of resources (45)
- [ ] No unexpected deletions
- [ ] No unexpected replacements
- [ ] Correct resource names
- [ ] Correct CIDR blocks
- [ ] Correct instance types
- [ ] Correct database configuration
- [ ] Correct tags

---

## POST-DEPLOYMENT VALIDATION

### 1. Resource Creation Validation

**List All Resources**:
```bash
# List Terraform resources
terraform state list

# Expected count: 45 resources
terraform state list | wc -l

# Verify specific resources
terraform state list | grep aws_vpc
terraform state list | grep aws_subnet
terraform state list | grep aws_instance
terraform state list | grep aws_lb
terraform state list | grep aws_db_instance
```

**Verify Outputs**:
```bash
# Get all outputs
terraform output

# Verify specific outputs
terraform output vpc_id
terraform output alb_dns_name
terraform output rds_endpoint
terraform output cloudfront_domain_name

# Verify output format
terraform output -json | jq '.'
```

### 2. VPC Validation

**VPC**:
```bash
# Get VPC ID
VPC_ID=$(terraform output -raw vpc_id)

# Verify VPC
aws ec2 describe-vpcs --vpc-ids $VPC_ID

# Check CIDR block
aws ec2 describe-vpcs \
  --vpc-ids $VPC_ID \
  --query 'Vpcs[0].CidrBlock' \
  --output text
# Expected: 10.0.0.0/16

# Check DNS settings
aws ec2 describe-vpcs \
  --vpc-ids $VPC_ID \
  --query 'Vpcs[0].[EnableDnsHostnames,EnableDnsSupport]' \
  --output text
# Expected: True True
```

**Subnets**:
```bash
# List subnets
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,MapPublicIpOnLaunch]' \
  --output table

# Expected: 6 subnets (3 public, 3 private)

# Verify public subnets
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=map-public-ip-on-launch,Values=true" \
  --query 'Subnets | length(@)'
# Expected: 3

# Verify private subnets
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=map-public-ip-on-launch,Values=false" \
  --query 'Subnets | length(@)'
# Expected: 3
```

**Internet Gateway**:
```bash
# Verify IGW
aws ec2 describe-internet-gateways \
  --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
  --query 'InternetGateways[0].[InternetGatewayId,Attachments[0].State]' \
  --output text
# Expected: igw-xxxxx available
```

**NAT Gateways**:
```bash
# List NAT gateways
aws ec2 describe-nat-gateways \
  --filter "Name=vpc-id,Values=$VPC_ID" \
  --query 'NatGateways[*].[NatGatewayId,State,SubnetId]' \
  --output table

# Expected: 3 NAT gateways (or 1 if single_nat_gateway=true)
# State should be "available"
```

**Route Tables**:
```bash
# List route tables
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'RouteTables[*].[RouteTableId,Routes[?DestinationCidrBlock==`0.0.0.0/0`].GatewayId]' \
  --output table

# Verify public route table has IGW
# Verify private route tables have NAT gateways
```

### 3. Compute Validation

**Auto Scaling Group**:
```bash
# Get ASG name
ASG_NAME=$(terraform output -raw asg_name)

# Verify ASG
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].[MinSize,MaxSize,DesiredCapacity,Instances | length(@)]' \
  --output text

# Expected: 2 6 2 2 (min, max, desired, current)

# Check ASG health
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances[*].[InstanceId,HealthStatus,LifecycleState]' \
  --output table

# All instances should be "Healthy" and "InService"
```

**EC2 Instances**:
```bash
# List instances
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=webapp" "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PrivateIpAddress]' \
  --output table

# Verify instance count matches ASG desired capacity

# Check instance status
aws ec2 describe-instance-status \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:Project,Values=webapp" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text) \
  --query 'InstanceStatuses[*].[InstanceId,InstanceStatus.Status,SystemStatus.Status]' \
  --output table

# All should be "ok" "ok"
```

**Launch Template**:
```bash
# Get launch template ID
LT_ID=$(terraform output -raw launch_template_id)

# Verify launch template
aws ec2 describe-launch-template-versions \
  --launch-template-id $LT_ID \
  --query 'LaunchTemplateVersions[0].[LaunchTemplateId,VersionNumber,LaunchTemplateData.InstanceType]' \
  --output text

# Verify user data
aws ec2 describe-launch-template-versions \
  --launch-template-id $LT_ID \
  --query 'LaunchTemplateVersions[0].LaunchTemplateData.UserData' \
  --output text | base64 -d
```

### 4. Load Balancer Validation

**ALB**:
```bash
# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)

# Verify ALB
aws elbv2 describe-load-balancers \
  --names webapp-dev-alb \
  --query 'LoadBalancers[0].[LoadBalancerName,State.Code,Scheme,Type]' \
  --output text

# Expected: webapp-dev-alb active internet-facing application

# Check ALB subnets
aws elbv2 describe-load-balancers \
  --names webapp-dev-alb \
  --query 'LoadBalancers[0].AvailabilityZones[*].[ZoneName,SubnetId]' \
  --output table

# Should be in 3 public subnets
```

**Target Group**:
```bash
# Get target group ARN
TG_ARN=$(terraform output -raw target_group_arn)

# Verify target group
aws elbv2 describe-target-groups \
  --target-group-arns $TG_ARN \
  --query 'TargetGroups[0].[TargetGroupName,Protocol,Port,HealthCheckPath]' \
  --output text

# Expected: webapp-dev-tg HTTP 80 /health

# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State,TargetHealth.Reason]' \
  --output table

# All targets should be "healthy"
```

**Listeners**:
```bash
# List listeners
aws elbv2 describe-listeners \
  --load-balancer-arn $(aws elbv2 describe-load-balancers \
    --names webapp-dev-alb \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text) \
  --query 'Listeners[*].[Protocol,Port,DefaultActions[0].Type]' \
  --output table

# Expected: HTTP 80 forward (and HTTPS 443 if domain configured)
```

### 5. Database Validation

**RDS Instance**:
```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Verify RDS
aws rds describe-db-instances \
  --db-instance-identifier webapp-dev-db \
  --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Engine,EngineVersion,DBInstanceClass,MultiAZ]' \
  --output text

# Expected: webapp-dev-db available postgres 15.4 db.t3.micro true

# Check storage
aws rds describe-db-instances \
  --db-instance-identifier webapp-dev-db \
  --query 'DBInstances[0].[AllocatedStorage,StorageType,StorageEncrypted]' \
  --output text

# Expected: 20 gp3 true

# Check backup
aws rds describe-db-instances \
  --db-instance-identifier webapp-dev-db \
  --query 'DBInstances[0].[BackupRetentionPeriod,PreferredBackupWindow]' \
  --output text

# Expected: 7 03:00-04:00
```

**Database Connectivity**:
```bash
# Test from EC2 instance
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=webapp" "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

# Connect to instance
aws ssm start-session --target $INSTANCE_ID

# Inside instance:
# Install PostgreSQL client
sudo yum install -y postgresql15

# Test connection
psql -h $RDS_ENDPOINT -U admin -d webapp -c "SELECT version();"

# Should return PostgreSQL version
```

### 6. Storage Validation

**S3 Buckets**:
```bash
# Get bucket name
S3_BUCKET=$(terraform output -raw s3_bucket_name)

# Verify bucket
aws s3 ls s3://$S3_BUCKET

# Check versioning
aws s3api get-bucket-versioning --bucket $S3_BUCKET

# Expected: Status: Enabled

# Check encryption
aws s3api get-bucket-encryption --bucket $S3_BUCKET

# Expected: SSEAlgorithm: aws:kms

# Check public access block
aws s3api get-public-access-block --bucket $S3_BUCKET

# Expected: All blocked
```

### 7. CDN Validation

**CloudFront Distribution**:
```bash
# Get distribution ID
CF_ID=$(terraform output -raw cloudfront_distribution_id)

# Verify distribution
aws cloudfront get-distribution \
  --id $CF_ID \
  --query 'Distribution.[Id,Status,DomainName]' \
  --output text

# Expected: d1234567890 Deployed d1234567890.cloudfront.net

# Check origins
aws cloudfront get-distribution \
  --id $CF_ID \
  --query 'Distribution.DistributionConfig.Origins.Items[*].[Id,DomainName]' \
  --output table

# Should have S3 and ALB origins
```

### 8. DNS Validation

**Route53 Hosted Zone** (if domain configured):
```bash
# Get zone ID
ZONE_ID=$(terraform output -raw route53_zone_id)

# Verify zone
aws route53 get-hosted-zone --id $ZONE_ID

# List records
aws route53 list-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --query 'ResourceRecordSets[*].[Name,Type,AliasTarget.DNSName]' \
  --output table

# Should have A records for domain and cdn subdomain
```

### 9. Monitoring Validation

**CloudWatch Log Groups**:
```bash
# List log groups
aws logs describe-log-groups \
  --log-group-name-prefix /aws/ec2/webapp \
  --query 'logGroups[*].[logGroupName,retentionInDays]' \
  --output table

# Expected: /aws/ec2/webapp-dev 7
```

**CloudWatch Alarms**:
```bash
# List alarms
aws cloudwatch describe-alarms \
  --alarm-name-prefix webapp-dev \
  --query 'MetricAlarms[*].[AlarmName,StateValue,MetricName]' \
  --output table

# All alarms should be in "OK" state (or "INSUFFICIENT_DATA" initially)
```

**CloudWatch Dashboard**:
```bash
# Get dashboard
aws cloudwatch get-dashboard \
  --dashboard-name webapp-dev-dashboard

# Should return dashboard JSON
```

### 10. Security Validation

**Security Groups**:
```bash
# List security groups
aws ec2 describe-security-groups \
  --filters "Name=tag:Project,Values=webapp" \
  --query 'SecurityGroups[*].[GroupId,GroupName,IpPermissions | length(@)]' \
  --output table

# Verify rules
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw alb_security_group_id) \
  --query 'SecurityGroups[0].IpPermissions[*].[FromPort,ToPort,IpProtocol,IpRanges[0].CidrIp]' \
  --output table

# ALB should allow 80 and 443 from 0.0.0.0/0
```

**IAM Roles**:
```bash
# Verify EC2 role
aws iam get-role \
  --role-name $(terraform output -raw ec2_iam_role_arn | cut -d'/' -f2)

# List attached policies
aws iam list-attached-role-policies \
  --role-name $(terraform output -raw ec2_iam_role_arn | cut -d'/' -f2)

# Should have SSM and CloudWatch policies
```

**KMS Key**:
```bash
# Get KMS key ID
KMS_KEY=$(terraform output -raw kms_key_id)

# Verify key
aws kms describe-key --key-id $KMS_KEY

# Check key rotation
aws kms get-key-rotation-status --key-id $KMS_KEY

# Expected: KeyRotationEnabled: true
```

---

## SUCCESS CRITERIA

### Infrastructure Criteria

- [ ] All 45 resources created successfully
- [ ] VPC with correct CIDR block (10.0.0.0/16)
- [ ] 6 subnets across 3 AZs (3 public, 3 private)
- [ ] Internet Gateway attached
- [ ] 3 NAT Gateways (or 1 if single_nat_gateway=true)
- [ ] Auto Scaling Group with 2 healthy instances
- [ ] Application Load Balancer in active state
- [ ] RDS instance in available state
- [ ] S3 buckets created with encryption
- [ ] CloudFront distribution deployed
- [ ] Route53 records created (if domain configured)

### Functional Criteria

- [ ] ALB health checks passing
- [ ] All targets healthy in target group
- [ ] Application accessible via ALB DNS
- [ ] Health endpoint returns 200 OK
- [ ] Database connection successful
- [ ] CloudFront serving content
- [ ] DNS resolution working (if domain configured)

### Security Criteria

- [ ] All resources encrypted at rest
- [ ] Security groups follow least privilege
- [ ] No public access to RDS
- [ ] S3 public access blocked
- [ ] IAM roles with minimal permissions
- [ ] VPC Flow Logs enabled
- [ ] CloudWatch Logs encrypted

### Monitoring Criteria

- [ ] CloudWatch Log Groups created
- [ ] CloudWatch Alarms configured
- [ ] CloudWatch Dashboard created
- [ ] SNS topic created (if email configured)
- [ ] Application logs flowing to CloudWatch

### Performance Criteria

- [ ] ALB response time < 1 second
- [ ] Target health checks passing
- [ ] Auto Scaling policies configured
- [ ] CloudFront cache hit ratio > 80%

---

## FUNCTIONAL TESTING

### HTTP Endpoint Testing

```bash
# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test root endpoint
curl -I http://$ALB_DNS
# Expected: HTTP/1.1 200 OK

# Test health endpoint
curl http://$ALB_DNS/health
# Expected: OK

# Test with verbose output
curl -v http://$ALB_DNS

# Test HTTPS (if configured)
curl -I https://example.com
# Expected: HTTP/2 200
```

### Load Testing

```bash
# Install Apache Bench
sudo yum install -y httpd-tools

# Run load test
ab -n 1000 -c 10 http://$ALB_DNS/

# Expected output:
# Requests per second: > 100
# Time per request: < 100ms
# Failed requests: 0

# Run extended load test
ab -n 10000 -c 50 -t 60 http://$ALB_DNS/

# Monitor Auto Scaling
watch -n 5 'aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names webapp-dev-asg \
  --query "AutoScalingGroups[0].[DesiredCapacity,Instances | length(@)]"'
```

### Database Testing

```bash
# Connect to instance
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=webapp" "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

aws ssm start-session --target $INSTANCE_ID

# Inside instance:
# Test database connection
psql -h $RDS_ENDPOINT -U admin -d webapp <<EOF
-- Create test table
CREATE TABLE test (id SERIAL PRIMARY KEY, name VARCHAR(100));

-- Insert test data
INSERT INTO test (name) VALUES ('Test 1'), ('Test 2'), ('Test 3');

-- Query test data
SELECT * FROM test;

-- Drop test table
DROP TABLE test;
EOF
```

---

## PERFORMANCE TESTING

### Response Time Testing

```bash
# Test response time
for i in {1..10}; do
  curl -o /dev/null -s -w "Response time: %{time_total}s\n" http://$ALB_DNS
done

# Expected: < 1 second

# Test CloudFront response time
for i in {1..10}; do
  curl -o /dev/null -s -w "Response time: %{time_total}s\n" https://$CF_DOMAIN
done

# Expected: < 0.5 seconds
```

### Throughput Testing

```bash
# Test throughput
ab -n 10000 -c 100 http://$ALB_DNS/ | grep "Requests per second"

# Expected: > 100 requests/second
```

### Scalability Testing

```bash
# Trigger scale-up
ab -n 100000 -c 200 -t 600 http://$ALB_DNS/ &

# Monitor scaling
watch -n 10 'aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names webapp-dev-asg \
  --query "AutoScalingGroups[0].[DesiredCapacity,Instances | length(@)]"'

# Should scale from 2 to 4-6 instances
```

---

## SECURITY TESTING

### Port Scanning

```bash
# Scan ALB
nmap -p 80,443 $ALB_DNS

# Expected: Only 80 and 443 open

# Scan EC2 instance (should timeout - in private subnet)
INSTANCE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=webapp" \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)

nmap -p 22,80,443 $INSTANCE_IP
# Expected: Timeout (not accessible from internet)
```

### SSL/TLS Testing

```bash
# Test SSL configuration (if HTTPS configured)
sslscan https://example.com

# Expected:
# - TLS 1.2 and 1.3 supported
# - Strong cipher suites
# - Valid certificate
```

### Vulnerability Scanning

```bash
# Run AWS Inspector
aws inspector2 create-findings-report \
  --report-format JSON \
  --s3-destination bucketName=security-reports

# Review findings
aws inspector2 list-findings
```

---

## COMPLIANCE VALIDATION

### CIS Benchmark

```bash
# Enable AWS Config
aws configservice put-configuration-recorder \
  --configuration-recorder name=default,roleARN=arn:aws:iam::123456789012:role/aws-config-role

# Enable CIS rules
aws configservice put-config-rule \
  --config-rule file://cis-rules.json

# Check compliance
aws configservice describe-compliance-by-config-rule
```

### GDPR Compliance

- [ ] Data encrypted at rest
- [ ] Data encrypted in transit
- [ ] Access logging enabled
- [ ] Data retention policies configured
- [ ] Right to be forgotten implemented

---

## COST VALIDATION

### Cost Estimation

```bash
# Get current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=SERVICE

# Expected: ~$80-200 depending on configuration
```

### Cost Optimization Check

```bash
# Check for unused resources
aws ec2 describe-volumes --filters "Name=status,Values=available"
aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query 'Addresses[?AssociationId==null]'
aws rds describe-db-snapshots --query 'DBSnapshots[?SnapshotCreateTime<`2025-09-01`]'
```

---

## AUTOMATED TESTING

### Terraform Test Script

**test.sh**:
```bash
#!/bin/bash
set -e

echo "Running Terraform tests..."

# 1. Validate
echo "1. Validating configuration..."
terraform validate

# 2. Format check
echo "2. Checking formatting..."
terraform fmt -check -recursive

# 3. Plan
echo "3. Creating plan..."
terraform plan -out=tfplan

# 4. Apply
echo "4. Applying configuration..."
terraform apply -auto-approve tfplan

# 5. Test outputs
echo "5. Testing outputs..."
terraform output vpc_id
terraform output alb_dns_name

# 6. Test ALB
echo "6. Testing ALB..."
ALB_DNS=$(terraform output -raw alb_dns_name)
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" http://$ALB_DNS)
if [ "$HTTP_CODE" != "200" ]; then
  echo "ALB test failed: HTTP $HTTP_CODE"
  exit 1
fi

# 7. Test health endpoint
echo "7. Testing health endpoint..."
HEALTH=$(curl -s http://$ALB_DNS/health)
if [ "$HEALTH" != "OK" ]; then
  echo "Health check failed: $HEALTH"
  exit 1
fi

# 8. Destroy
echo "8. Destroying infrastructure..."
terraform destroy -auto-approve

echo "All tests passed!"
```

### Terratest (Go)

**main_test.go**:
```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/http-helper"
)

func TestTerraformWebApp(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../terraform-manifests",
        Vars: map[string]interface{}{
            "environment": "test",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    albDns := terraform.Output(t, terraformOptions, "alb_dns_name")
    url := "http://" + albDns

    http_helper.HttpGetWithRetry(t, url, nil, 200, "OK", 30, 5)
}
```

---

**Document Version**: 1.0  
**Last Updated**: October 27, 2025  
**Status**: Complete  
**Total Lines**: 800+

