#!/bin/bash
# Validation Script for Project 1: Multi-Tier Web Application Infrastructure
# This script validates the deployed infrastructure

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_DIR/terraform-manifests"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Banner
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   Project 1: Multi-Tier Web Application Infrastructure       ║
║   Validation Script                                           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

info "Starting validation..."
echo ""

# Navigate to Terraform directory
cd "$TERRAFORM_DIR" || { fail "Failed to navigate to $TERRAFORM_DIR"; exit 1; }

# Section 1: Terraform State Validation
echo -e "${BLUE}═══ Section 1: Terraform State Validation ═══${NC}"

# Check if state exists
if terraform state list &> /dev/null; then
    pass "Terraform state exists"
    
    # Count resources
    RESOURCE_COUNT=$(terraform state list | wc -l)
    if [ "$RESOURCE_COUNT" -ge 40 ]; then
        pass "Resource count: $RESOURCE_COUNT (expected: ~45)"
    else
        fail "Resource count: $RESOURCE_COUNT (expected: ~45)"
    fi
else
    fail "Terraform state does not exist"
fi

# Check outputs
if terraform output &> /dev/null; then
    pass "Terraform outputs available"
else
    fail "Terraform outputs not available"
fi

echo ""

# Section 2: VPC Validation
echo -e "${BLUE}═══ Section 2: VPC Validation ═══${NC}"

if VPC_ID=$(terraform output -raw vpc_id 2>/dev/null); then
    pass "VPC ID retrieved: $VPC_ID"
    
    # Verify VPC exists
    if aws ec2 describe-vpcs --vpc-ids "$VPC_ID" &> /dev/null; then
        pass "VPC exists in AWS"
        
        # Check CIDR block
        VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --query 'Vpcs[0].CidrBlock' --output text)
        if [ "$VPC_CIDR" == "10.0.0.0/16" ]; then
            pass "VPC CIDR block: $VPC_CIDR"
        else
            warn "VPC CIDR block: $VPC_CIDR (expected: 10.0.0.0/16)"
        fi
        
        # Check DNS settings
        DNS_HOSTNAMES=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --query 'Vpcs[0].EnableDnsHostnames' --output text)
        DNS_SUPPORT=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --query 'Vpcs[0].EnableDnsSupport' --output text)
        
        if [ "$DNS_HOSTNAMES" == "True" ] && [ "$DNS_SUPPORT" == "True" ]; then
            pass "DNS hostnames and support enabled"
        else
            fail "DNS settings incorrect (Hostnames: $DNS_HOSTNAMES, Support: $DNS_SUPPORT)"
        fi
    else
        fail "VPC does not exist in AWS"
    fi
    
    # Check subnets
    SUBNET_COUNT=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets | length(@)' --output text)
    if [ "$SUBNET_COUNT" -eq 6 ]; then
        pass "Subnet count: $SUBNET_COUNT (expected: 6)"
    else
        fail "Subnet count: $SUBNET_COUNT (expected: 6)"
    fi
    
    # Check public subnets
    PUBLIC_SUBNET_COUNT=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=map-public-ip-on-launch,Values=true" --query 'Subnets | length(@)' --output text)
    if [ "$PUBLIC_SUBNET_COUNT" -eq 3 ]; then
        pass "Public subnet count: $PUBLIC_SUBNET_COUNT (expected: 3)"
    else
        fail "Public subnet count: $PUBLIC_SUBNET_COUNT (expected: 3)"
    fi
    
    # Check Internet Gateway
    IGW_COUNT=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways | length(@)' --output text)
    if [ "$IGW_COUNT" -eq 1 ]; then
        pass "Internet Gateway attached"
    else
        fail "Internet Gateway not attached"
    fi
    
    # Check NAT Gateways
    NAT_COUNT=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" "Name=state,Values=available" --query 'NatGateways | length(@)' --output text)
    if [ "$NAT_COUNT" -ge 1 ]; then
        pass "NAT Gateway count: $NAT_COUNT"
    else
        fail "No NAT Gateways found"
    fi
else
    fail "Could not retrieve VPC ID"
fi

echo ""

# Section 3: Compute Validation
echo -e "${BLUE}═══ Section 3: Compute Validation ═══${NC}"

if ASG_NAME=$(terraform output -raw asg_name 2>/dev/null); then
    pass "Auto Scaling Group name retrieved: $ASG_NAME"
    
    # Check ASG
    if aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" &> /dev/null; then
        pass "Auto Scaling Group exists"
        
        # Check instance count
        INSTANCE_COUNT=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --query 'AutoScalingGroups[0].Instances | length(@)' --output text)
        DESIRED_CAPACITY=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --query 'AutoScalingGroups[0].DesiredCapacity' --output text)
        
        if [ "$INSTANCE_COUNT" -eq "$DESIRED_CAPACITY" ]; then
            pass "Instance count matches desired capacity: $INSTANCE_COUNT"
        else
            warn "Instance count ($INSTANCE_COUNT) does not match desired capacity ($DESIRED_CAPACITY)"
        fi
        
        # Check instance health
        HEALTHY_COUNT=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --query 'AutoScalingGroups[0].Instances[?HealthStatus==`Healthy`] | length(@)' --output text)
        
        if [ "$HEALTHY_COUNT" -eq "$INSTANCE_COUNT" ]; then
            pass "All instances healthy: $HEALTHY_COUNT/$INSTANCE_COUNT"
        else
            fail "Unhealthy instances detected: $HEALTHY_COUNT/$INSTANCE_COUNT healthy"
        fi
    else
        fail "Auto Scaling Group does not exist"
    fi
else
    fail "Could not retrieve Auto Scaling Group name"
fi

echo ""

# Section 4: Load Balancer Validation
echo -e "${BLUE}═══ Section 4: Load Balancer Validation ═══${NC}"

if ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null); then
    pass "ALB DNS retrieved: $ALB_DNS"
    
    # Check ALB status
    ALB_STATE=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?DNSName==`'$ALB_DNS'`].State.Code' --output text)
    if [ "$ALB_STATE" == "active" ]; then
        pass "ALB state: active"
    else
        fail "ALB state: $ALB_STATE (expected: active)"
    fi
    
    # Test ALB endpoint
    HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "http://$ALB_DNS" || echo "000")
    if [ "$HTTP_CODE" == "200" ]; then
        pass "ALB endpoint responding: HTTP $HTTP_CODE"
    else
        fail "ALB endpoint not responding: HTTP $HTTP_CODE"
    fi
    
    # Test health endpoint
    HEALTH_RESPONSE=$(curl -s "http://$ALB_DNS/health" || echo "ERROR")
    if echo "$HEALTH_RESPONSE" | grep -q "OK"; then
        pass "Health endpoint responding: $HEALTH_RESPONSE"
    else
        warn "Health endpoint response: $HEALTH_RESPONSE"
    fi
    
    # Check target health
    if TG_ARN=$(terraform output -raw target_group_arn 2>/dev/null); then
        HEALTHY_TARGETS=$(aws elbv2 describe-target-health --target-group-arn "$TG_ARN" --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`] | length(@)' --output text)
        TOTAL_TARGETS=$(aws elbv2 describe-target-health --target-group-arn "$TG_ARN" --query 'TargetHealthDescriptions | length(@)' --output text)
        
        if [ "$HEALTHY_TARGETS" -eq "$TOTAL_TARGETS" ] && [ "$TOTAL_TARGETS" -gt 0 ]; then
            pass "All targets healthy: $HEALTHY_TARGETS/$TOTAL_TARGETS"
        else
            fail "Unhealthy targets: $HEALTHY_TARGETS/$TOTAL_TARGETS healthy"
        fi
    fi
else
    fail "Could not retrieve ALB DNS"
fi

echo ""

# Section 5: Database Validation
echo -e "${BLUE}═══ Section 5: Database Validation ═══${NC}"

if RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null); then
    pass "RDS endpoint retrieved: $RDS_ENDPOINT"
    
    # Extract DB identifier
    DB_IDENTIFIER=$(echo "$RDS_ENDPOINT" | cut -d'.' -f1)
    
    # Check RDS status
    if aws rds describe-db-instances --db-instance-identifier "$DB_IDENTIFIER" &> /dev/null; then
        pass "RDS instance exists"
        
        DB_STATUS=$(aws rds describe-db-instances --db-instance-identifier "$DB_IDENTIFIER" --query 'DBInstances[0].DBInstanceStatus' --output text)
        if [ "$DB_STATUS" == "available" ]; then
            pass "RDS status: available"
        else
            warn "RDS status: $DB_STATUS (expected: available)"
        fi
        
        # Check Multi-AZ
        MULTI_AZ=$(aws rds describe-db-instances --db-instance-identifier "$DB_IDENTIFIER" --query 'DBInstances[0].MultiAZ' --output text)
        if [ "$MULTI_AZ" == "True" ]; then
            pass "Multi-AZ enabled"
        else
            warn "Multi-AZ disabled"
        fi
        
        # Check encryption
        ENCRYPTED=$(aws rds describe-db-instances --db-instance-identifier "$DB_IDENTIFIER" --query 'DBInstances[0].StorageEncrypted' --output text)
        if [ "$ENCRYPTED" == "True" ]; then
            pass "Storage encryption enabled"
        else
            fail "Storage encryption disabled"
        fi
    else
        fail "RDS instance does not exist"
    fi
else
    fail "Could not retrieve RDS endpoint"
fi

echo ""

# Section 6: Storage Validation
echo -e "${BLUE}═══ Section 6: Storage Validation ═══${NC}"

if S3_BUCKET=$(terraform output -raw s3_bucket_name 2>/dev/null); then
    pass "S3 bucket name retrieved: $S3_BUCKET"
    
    # Check bucket exists
    if aws s3 ls "s3://$S3_BUCKET" &> /dev/null; then
        pass "S3 bucket exists"
        
        # Check versioning
        VERSIONING=$(aws s3api get-bucket-versioning --bucket "$S3_BUCKET" --query 'Status' --output text)
        if [ "$VERSIONING" == "Enabled" ]; then
            pass "S3 versioning enabled"
        else
            warn "S3 versioning: $VERSIONING"
        fi
        
        # Check encryption
        if aws s3api get-bucket-encryption --bucket "$S3_BUCKET" &> /dev/null; then
            pass "S3 encryption enabled"
        else
            fail "S3 encryption not enabled"
        fi
        
        # Check public access block
        PUBLIC_ACCESS=$(aws s3api get-public-access-block --bucket "$S3_BUCKET" --query 'PublicAccessBlockConfiguration.BlockPublicAcls' --output text)
        if [ "$PUBLIC_ACCESS" == "True" ]; then
            pass "S3 public access blocked"
        else
            fail "S3 public access not blocked"
        fi
    else
        fail "S3 bucket does not exist"
    fi
else
    fail "Could not retrieve S3 bucket name"
fi

echo ""

# Section 7: CDN Validation
echo -e "${BLUE}═══ Section 7: CDN Validation ═══${NC}"

if CF_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null); then
    pass "CloudFront distribution ID retrieved: $CF_ID"
    
    # Check distribution status
    CF_STATUS=$(aws cloudfront get-distribution --id "$CF_ID" --query 'Distribution.Status' --output text)
    if [ "$CF_STATUS" == "Deployed" ]; then
        pass "CloudFront status: Deployed"
    else
        warn "CloudFront status: $CF_STATUS (expected: Deployed)"
    fi
    
    # Test CloudFront endpoint
    if CF_DOMAIN=$(terraform output -raw cloudfront_domain_name 2>/dev/null); then
        HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "https://$CF_DOMAIN" || echo "000")
        if [ "$HTTP_CODE" == "200" ]; then
            pass "CloudFront endpoint responding: HTTP $HTTP_CODE"
        else
            warn "CloudFront endpoint: HTTP $HTTP_CODE"
        fi
    fi
else
    fail "Could not retrieve CloudFront distribution ID"
fi

echo ""

# Section 8: Monitoring Validation
echo -e "${BLUE}═══ Section 8: Monitoring Validation ═══${NC}"

# Check CloudWatch log groups
if LOG_GROUP=$(terraform output -raw cloudwatch_log_group_name 2>/dev/null); then
    if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" &> /dev/null; then
        pass "CloudWatch log group exists: $LOG_GROUP"
    else
        fail "CloudWatch log group does not exist"
    fi
else
    warn "Could not retrieve CloudWatch log group name"
fi

# Check CloudWatch dashboard
if DASHBOARD=$(terraform output -raw cloudwatch_dashboard_name 2>/dev/null); then
    if aws cloudwatch get-dashboard --dashboard-name "$DASHBOARD" &> /dev/null; then
        pass "CloudWatch dashboard exists: $DASHBOARD"
    else
        fail "CloudWatch dashboard does not exist"
    fi
else
    warn "Could not retrieve CloudWatch dashboard name"
fi

# Check CloudWatch alarms
ALARM_COUNT=$(aws cloudwatch describe-alarms --alarm-name-prefix "webapp" --query 'MetricAlarms | length(@)' --output text)
if [ "$ALARM_COUNT" -gt 0 ]; then
    pass "CloudWatch alarms configured: $ALARM_COUNT"
else
    warn "No CloudWatch alarms found"
fi

echo ""

# Section 9: Security Validation
echo -e "${BLUE}═══ Section 9: Security Validation ═══${NC}"

# Check KMS key
if KMS_KEY=$(terraform output -raw kms_key_id 2>/dev/null); then
    if aws kms describe-key --key-id "$KMS_KEY" &> /dev/null; then
        pass "KMS key exists"
        
        # Check key rotation
        KEY_ROTATION=$(aws kms get-key-rotation-status --key-id "$KMS_KEY" --query 'KeyRotationEnabled' --output text)
        if [ "$KEY_ROTATION" == "True" ]; then
            pass "KMS key rotation enabled"
        else
            warn "KMS key rotation disabled"
        fi
    else
        fail "KMS key does not exist"
    fi
else
    warn "Could not retrieve KMS key ID"
fi

# Check security groups
SG_COUNT=$(aws ec2 describe-security-groups --filters "Name=tag:Project,Values=webapp" --query 'SecurityGroups | length(@)' --output text)
if [ "$SG_COUNT" -ge 3 ]; then
    pass "Security groups configured: $SG_COUNT"
else
    warn "Security group count: $SG_COUNT (expected: >= 3)"
fi

echo ""

# Summary
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}║   VALIDATION SUMMARY                                          ║${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${RED}Failed:${NC}   $FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

# Exit code
if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ All critical validations passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some validations failed. Please review the output above.${NC}"
    exit 1
fi

