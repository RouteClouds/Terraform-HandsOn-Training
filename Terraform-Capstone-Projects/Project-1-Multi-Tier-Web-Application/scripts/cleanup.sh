#!/bin/bash
# Cleanup Script for Project 1: Multi-Tier Web Application Infrastructure
# This script safely destroys all infrastructure resources

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
LOG_FILE="$PROJECT_DIR/cleanup-$(date +%Y%m%d-%H%M%S).log"

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
echo -e "${RED}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   Project 1: Multi-Tier Web Application Infrastructure       ║
║   Cleanup Script                                              ║
║                                                               ║
║   ⚠️  WARNING: This will DESTROY all infrastructure! ⚠️       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

log "Starting cleanup process..."
log "Log file: $LOG_FILE"

# Navigate to Terraform directory
cd "$TERRAFORM_DIR" || error "Failed to navigate to $TERRAFORM_DIR"

# Step 1: Check if infrastructure exists
log "Step 1: Checking if infrastructure exists..."

if ! terraform state list &> /dev/null; then
    warning "No Terraform state found. Nothing to destroy."
    exit 0
fi

RESOURCE_COUNT=$(terraform state list | wc -l)
log "Found $RESOURCE_COUNT resources to destroy"

# Step 2: Display resources to be destroyed
log "Step 2: Displaying resources to be destroyed..."
echo ""
info "Resources that will be destroyed:"
terraform state list | sed 's/^/  - /'
echo ""

# Step 3: Display current outputs
log "Step 3: Displaying current infrastructure..."
echo ""
info "Current infrastructure:"
terraform output 2>/dev/null || true
echo ""

# Step 4: Warning and confirmation
echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                                                               ║${NC}"
echo -e "${RED}║   ⚠️  CRITICAL WARNING ⚠️                                     ║${NC}"
echo -e "${RED}║                                                               ║${NC}"
echo -e "${RED}║   This action will:                                           ║${NC}"
echo -e "${RED}║   • Destroy ALL infrastructure resources                      ║${NC}"
echo -e "${RED}║   • Delete ALL data (databases, S3 buckets, etc.)            ║${NC}"
echo -e "${RED}║   • Remove ALL configurations                                 ║${NC}"
echo -e "${RED}║                                                               ║${NC}"
echo -e "${RED}║   This action CANNOT be undone!                               ║${NC}"
echo -e "${RED}║                                                               ║${NC}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# First confirmation
read -p "Are you sure you want to destroy all infrastructure? (yes/no): " -r
if [[ ! $REPLY =~ ^yes$ ]]; then
    warning "Cleanup cancelled by user"
    exit 0
fi

# Second confirmation
echo ""
echo -e "${YELLOW}This is your last chance to cancel!${NC}"
read -p "Type 'DESTROY' in capital letters to confirm: " -r
if [[ $REPLY != "DESTROY" ]]; then
    warning "Cleanup cancelled by user"
    exit 0
fi

# Step 5: Backup state before destruction
log "Step 5: Backing up Terraform state..."
BACKUP_FILE="$PROJECT_DIR/state-backup-$(date +%Y%m%d-%H%M%S).tfstate"
terraform state pull > "$BACKUP_FILE"
log "State backed up to: $BACKUP_FILE"

# Step 6: Backup outputs
log "Step 6: Backing up outputs..."
OUTPUTS_FILE="$PROJECT_DIR/outputs-backup-$(date +%Y%m%d-%H%M%S).json"
terraform output -json > "$OUTPUTS_FILE" 2>/dev/null || true
log "Outputs backed up to: $OUTPUTS_FILE"

# Step 7: Disable deletion protection (if any)
log "Step 7: Checking for deletion protection..."

# Check RDS deletion protection
if RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null); then
    DB_IDENTIFIER=$(echo "$RDS_ENDPOINT" | cut -d'.' -f1)
    
    DELETION_PROTECTION=$(aws rds describe-db-instances \
        --db-instance-identifier "$DB_IDENTIFIER" \
        --query 'DBInstances[0].DeletionProtection' \
        --output text 2>/dev/null || echo "false")
    
    if [ "$DELETION_PROTECTION" == "True" ]; then
        warning "RDS deletion protection is enabled. Disabling..."
        aws rds modify-db-instance \
            --db-instance-identifier "$DB_IDENTIFIER" \
            --no-deletion-protection \
            --apply-immediately
        log "RDS deletion protection disabled"
        
        # Wait for modification to complete
        info "Waiting for RDS modification to complete..."
        aws rds wait db-instance-available --db-instance-identifier "$DB_IDENTIFIER"
    fi
fi

# Check CloudFront distribution (takes time to disable)
if CF_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null); then
    CF_ENABLED=$(aws cloudfront get-distribution \
        --id "$CF_ID" \
        --query 'Distribution.DistributionConfig.Enabled' \
        --output text 2>/dev/null || echo "false")
    
    if [ "$CF_ENABLED" == "True" ]; then
        warning "CloudFront distribution is enabled. This may take 15-20 minutes to destroy."
    fi
fi

# Step 8: Empty S3 buckets
log "Step 8: Emptying S3 buckets..."

if S3_BUCKET=$(terraform output -raw s3_bucket_name 2>/dev/null); then
    if aws s3 ls "s3://$S3_BUCKET" &> /dev/null; then
        info "Emptying S3 bucket: $S3_BUCKET"
        
        # Delete all versions and delete markers
        aws s3api list-object-versions \
            --bucket "$S3_BUCKET" \
            --output json \
            --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' | \
        jq -r '.Objects[]? | "--key \"\(.Key)\" --version-id \"\(.VersionId)\""' | \
        xargs -I {} aws s3api delete-object --bucket "$S3_BUCKET" {} 2>/dev/null || true
        
        aws s3api list-object-versions \
            --bucket "$S3_BUCKET" \
            --output json \
            --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' | \
        jq -r '.Objects[]? | "--key \"\(.Key)\" --version-id \"\(.VersionId)\""' | \
        xargs -I {} aws s3api delete-object --bucket "$S3_BUCKET" {} 2>/dev/null || true
        
        # Delete remaining objects
        aws s3 rm "s3://$S3_BUCKET" --recursive 2>/dev/null || true
        
        log "S3 bucket emptied: $S3_BUCKET"
    fi
fi

# Check for logs bucket
if S3_LOGS_BUCKET=$(terraform output -raw s3_logs_bucket_name 2>/dev/null); then
    if aws s3 ls "s3://$S3_LOGS_BUCKET" &> /dev/null; then
        info "Emptying S3 logs bucket: $S3_LOGS_BUCKET"
        aws s3 rm "s3://$S3_LOGS_BUCKET" --recursive 2>/dev/null || true
        log "S3 logs bucket emptied: $S3_LOGS_BUCKET"
    fi
fi

# Step 9: Create destroy plan
log "Step 9: Creating destroy plan..."
if terraform plan -destroy -out=destroy.tfplan; then
    log "Destroy plan created successfully"
else
    error "Failed to create destroy plan"
fi

# Step 10: Execute destroy
log "Step 10: Destroying infrastructure..."
START_TIME=$(date +%s)

echo ""
info "Starting destruction process. This may take 10-20 minutes..."
echo ""

if terraform apply destroy.tfplan; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    log "Infrastructure destroyed successfully in $DURATION seconds"
else
    error "Terraform destroy failed. Check the log file for details."
fi

# Step 11: Verify destruction
log "Step 11: Verifying destruction..."

REMAINING_RESOURCES=$(terraform state list 2>/dev/null | wc -l)
if [ "$REMAINING_RESOURCES" -eq 0 ]; then
    log "All resources destroyed successfully"
else
    warning "$REMAINING_RESOURCES resources still remain in state"
    terraform state list
fi

# Step 12: Clean up local files
log "Step 12: Cleaning up local files..."

read -p "Do you want to clean up local Terraform files? (yes/no): " -r
if [[ $REPLY =~ ^yes$ ]]; then
    info "Cleaning up local files..."
    
    # Remove Terraform files
    rm -rf .terraform 2>/dev/null || true
    rm -f .terraform.lock.hcl 2>/dev/null || true
    rm -f terraform.tfstate 2>/dev/null || true
    rm -f terraform.tfstate.backup 2>/dev/null || true
    rm -f tfplan 2>/dev/null || true
    rm -f destroy.tfplan 2>/dev/null || true
    rm -f plan-output.txt 2>/dev/null || true
    
    log "Local files cleaned up"
else
    info "Local files preserved"
fi

# Step 13: Optional - Remove backend state
echo ""
read -p "Do you want to remove the remote state from S3? (yes/no): " -r
if [[ $REPLY =~ ^yes$ ]]; then
    warning "Removing remote state..."
    
    S3_BUCKET="terraform-state-capstone-projects"
    STATE_KEY="project-1/multi-tier-web-app/terraform.tfstate"
    
    # Delete state file
    aws s3 rm "s3://$S3_BUCKET/$STATE_KEY" 2>/dev/null || true
    
    # Delete state versions
    aws s3api list-object-versions \
        --bucket "$S3_BUCKET" \
        --prefix "$STATE_KEY" \
        --output json \
        --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' | \
    jq -r '.Objects[]? | "--key \"\(.Key)\" --version-id \"\(.VersionId)\""' | \
    xargs -I {} aws s3api delete-object --bucket "$S3_BUCKET" {} 2>/dev/null || true
    
    log "Remote state removed"
else
    info "Remote state preserved"
fi

# Step 14: Summary
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}║   CLEANUP SUMMARY                                             ║${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
log "Cleanup completed at: $(date)"
log "Total duration: $DURATION seconds"
log "Resources destroyed: $RESOURCE_COUNT"
log "Log file: $LOG_FILE"
log "State backup: $BACKUP_FILE"
log "Outputs backup: $OUTPUTS_FILE"

echo ""
info "Cleanup completed successfully!"
info "Backups are available at:"
info "  - State: $BACKUP_FILE"
info "  - Outputs: $OUTPUTS_FILE"
echo ""

# Optional: Display cost savings
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}║   ESTIMATED MONTHLY COST SAVINGS                              ║${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}║   EC2 Instances:        ~$15                                  ║${NC}"
echo -e "${BLUE}║   Application Load Balancer: ~$20                             ║${NC}"
echo -e "${BLUE}║   NAT Gateways:         ~$32-96                               ║${NC}"
echo -e "${BLUE}║   RDS Database:         ~$15-30                               ║${NC}"
echo -e "${BLUE}║   CloudFront:           ~$5                                   ║${NC}"
echo -e "${BLUE}║   Other Services:       ~$10                                  ║${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}║   Total Savings:        ~$97-176/month                        ║${NC}"
echo -e "${BLUE}║                                                               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

log "All infrastructure has been destroyed. You will no longer incur charges for these resources."
echo -e "${GREEN}Cleanup completed successfully!${NC}"

