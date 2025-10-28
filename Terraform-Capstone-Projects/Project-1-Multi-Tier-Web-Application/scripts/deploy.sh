#!/bin/bash
# Deployment Script for Project 1: Multi-Tier Web Application Infrastructure
# This script automates the deployment process with validation and error handling

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

# Logging
LOG_FILE="$PROJECT_DIR/deploy-$(date +%Y%m%d-%H%M%S).log"

# Functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# Banner
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   Project 1: Multi-Tier Web Application Infrastructure       ║
║   Deployment Script                                           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

log "Starting deployment process..."
log "Log file: $LOG_FILE"

# Step 1: Prerequisites Check
log "Step 1: Checking prerequisites..."

# Check Terraform
if ! command -v terraform &> /dev/null; then
    error "Terraform is not installed. Please install Terraform >= 1.13.0"
fi

TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
log "Terraform version: $TERRAFORM_VERSION"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    error "AWS CLI is not installed. Please install AWS CLI >= 2.0"
fi

AWS_VERSION=$(aws --version | cut -d' ' -f1 | cut -d'/' -f2)
log "AWS CLI version: $AWS_VERSION"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    error "AWS credentials not configured. Run 'aws configure'"
fi

AWS_ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
AWS_USER=$(aws sts get-caller-identity --query 'Arn' --output text)
log "AWS Account: $AWS_ACCOUNT"
log "AWS User: $AWS_USER"

# Check jq
if ! command -v jq &> /dev/null; then
    warning "jq is not installed. Some features may not work properly"
fi

# Step 2: Backend Setup
log "Step 2: Verifying backend configuration..."

S3_BUCKET="terraform-state-capstone-projects"
DYNAMODB_TABLE="terraform-state-lock"

# Check S3 bucket
if aws s3 ls "s3://$S3_BUCKET" &> /dev/null; then
    log "S3 bucket exists: $S3_BUCKET"
else
    warning "S3 bucket does not exist: $S3_BUCKET"
    read -p "Create S3 bucket? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Creating S3 bucket..."
        aws s3api create-bucket --bucket "$S3_BUCKET" --region us-east-1
        aws s3api put-bucket-versioning --bucket "$S3_BUCKET" --versioning-configuration Status=Enabled
        aws s3api put-bucket-encryption --bucket "$S3_BUCKET" --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
        log "S3 bucket created successfully"
    else
        error "S3 bucket is required for remote state"
    fi
fi

# Check DynamoDB table
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" &> /dev/null; then
    log "DynamoDB table exists: $DYNAMODB_TABLE"
else
    warning "DynamoDB table does not exist: $DYNAMODB_TABLE"
    read -p "Create DynamoDB table? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Creating DynamoDB table..."
        aws dynamodb create-table \
            --table-name "$DYNAMODB_TABLE" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --billing-mode PAY_PER_REQUEST \
            --region us-east-1
        log "DynamoDB table created successfully"
    else
        error "DynamoDB table is required for state locking"
    fi
fi

# Step 3: Navigate to Terraform directory
log "Step 3: Navigating to Terraform directory..."
cd "$TERRAFORM_DIR" || error "Failed to navigate to $TERRAFORM_DIR"
log "Current directory: $(pwd)"

# Step 4: Terraform Init
log "Step 4: Initializing Terraform..."
if terraform init; then
    log "Terraform initialized successfully"
else
    error "Terraform init failed"
fi

# Step 5: Terraform Validate
log "Step 5: Validating Terraform configuration..."
if terraform validate; then
    log "Terraform configuration is valid"
else
    error "Terraform validation failed"
fi

# Step 6: Terraform Format Check
log "Step 6: Checking Terraform formatting..."
if terraform fmt -check -recursive; then
    log "Terraform files are properly formatted"
else
    warning "Some files need formatting. Running terraform fmt..."
    terraform fmt -recursive
    log "Files formatted successfully"
fi

# Step 7: Terraform Plan
log "Step 7: Creating Terraform plan..."
PLAN_FILE="$PROJECT_DIR/tfplan-$(date +%Y%m%d-%H%M%S)"

if terraform plan -out="$PLAN_FILE" | tee "$PROJECT_DIR/plan-output.txt"; then
    log "Terraform plan created successfully"
    log "Plan file: $PLAN_FILE"
else
    error "Terraform plan failed"
fi

# Display plan summary
info "Plan Summary:"
grep "Plan:" "$PROJECT_DIR/plan-output.txt" || true

# Step 8: Review and Confirm
echo ""
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                                                               ║${NC}"
echo -e "${YELLOW}║   REVIEW THE PLAN OUTPUT ABOVE                                ║${NC}"
echo -e "${YELLOW}║                                                               ║${NC}"
echo -e "${YELLOW}║   This will create/modify/destroy AWS resources              ║${NC}"
echo -e "${YELLOW}║   which may incur costs.                                      ║${NC}"
echo -e "${YELLOW}║                                                               ║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

read -p "Do you want to proceed with the deployment? (yes/no): " -r
if [[ ! $REPLY =~ ^yes$ ]]; then
    warning "Deployment cancelled by user"
    exit 0
fi

# Step 9: Terraform Apply
log "Step 9: Applying Terraform configuration..."
START_TIME=$(date +%s)

if terraform apply "$PLAN_FILE"; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    log "Terraform apply completed successfully in $DURATION seconds"
else
    error "Terraform apply failed"
fi

# Step 10: Display Outputs
log "Step 10: Displaying outputs..."
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}║   DEPLOYMENT SUCCESSFUL!                                      ║${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

terraform output

# Save outputs to file
terraform output -json > "$PROJECT_DIR/outputs-$(date +%Y%m%d-%H%M%S).json"

# Step 11: Post-Deployment Validation
log "Step 11: Running post-deployment validation..."

# Get ALB DNS
if ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null); then
    log "ALB DNS: $ALB_DNS"
    
    # Test ALB endpoint
    info "Testing ALB endpoint..."
    if curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS" | grep -q "200"; then
        log "ALB endpoint is responding (HTTP 200)"
    else
        warning "ALB endpoint is not responding with HTTP 200"
    fi
    
    # Test health endpoint
    info "Testing health endpoint..."
    if curl -s "http://$ALB_DNS/health" | grep -q "OK"; then
        log "Health endpoint is responding"
    else
        warning "Health endpoint is not responding"
    fi
else
    warning "Could not retrieve ALB DNS name"
fi

# Check target health
info "Checking target health..."
if TG_ARN=$(terraform output -raw target_group_arn 2>/dev/null); then
    HEALTHY_TARGETS=$(aws elbv2 describe-target-health \
        --target-group-arn "$TG_ARN" \
        --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`] | length(@)' \
        --output text)
    log "Healthy targets: $HEALTHY_TARGETS"
else
    warning "Could not retrieve target group ARN"
fi

# Step 12: Summary
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}║   DEPLOYMENT SUMMARY                                          ║${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
log "Deployment completed at: $(date)"
log "Total duration: $DURATION seconds"
log "Log file: $LOG_FILE"
log "Plan file: $PLAN_FILE"
log "Outputs file: $PROJECT_DIR/outputs-$(date +%Y%m%d-%H%M%S).json"

# Display connection information
if [ -n "${ALB_DNS:-}" ]; then
    echo ""
    info "Application URL: http://$ALB_DNS"
    info "Health Check: http://$ALB_DNS/health"
fi

if CF_DOMAIN=$(terraform output -raw cloudfront_domain_name 2>/dev/null); then
    info "CloudFront URL: https://$CF_DOMAIN"
fi

if DOMAIN=$(terraform output -raw domain_name 2>/dev/null); then
    if [ "$DOMAIN" != "null" ] && [ -n "$DOMAIN" ]; then
        info "Custom Domain: https://$DOMAIN"
        info "CDN Domain: https://cdn.$DOMAIN"
    fi
fi

echo ""
log "Next steps:"
log "1. Verify the application is accessible"
log "2. Check CloudWatch logs and metrics"
log "3. Review CloudWatch alarms"
log "4. Test auto-scaling behavior"
log "5. Update documentation"

echo ""
echo -e "${GREEN}Deployment completed successfully!${NC}"

