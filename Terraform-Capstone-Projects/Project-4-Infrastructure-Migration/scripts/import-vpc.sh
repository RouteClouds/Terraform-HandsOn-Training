#!/bin/bash

# VPC Import Automation Script
# Automates the import of VPC and networking resources

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SCENARIO_DIR="${PROJECT_DIR}/scenarios/scenario-1-vpc/imported"
EXISTING_DIR="${PROJECT_DIR}/existing-infrastructure"

log_info "VPC Import Automation"
echo ""

# Step 1: Get resource IDs from existing infrastructure
log_step "Step 1: Getting resource IDs from existing infrastructure..."
cd "$EXISTING_DIR"

if [ ! -f "terraform.tfstate" ]; then
    log_error "Existing infrastructure not deployed. Run 'terraform apply' in existing-infrastructure/ first."
    exit 1
fi

VPC_ID=$(terraform output -raw vpc_id)
IGW_ID=$(terraform output -raw internet_gateway_id)
PUBLIC_SUBNET_1_ID=$(terraform output -raw public_subnet_1_id)
PUBLIC_SUBNET_2_ID=$(terraform output -raw public_subnet_2_id)
PRIVATE_SUBNET_1_ID=$(terraform output -raw private_subnet_1_id)
PRIVATE_SUBNET_2_ID=$(terraform output -raw private_subnet_2_id)
PUBLIC_RT_ID=$(terraform output -raw public_route_table_id)
PUBLIC_RTA_1_ID=$(terraform output -raw public_route_table_association_1_id)
PUBLIC_RTA_2_ID=$(terraform output -raw public_route_table_association_2_id)

log_info "Resource IDs retrieved:"
echo "  VPC: $VPC_ID"
echo "  IGW: $IGW_ID"
echo "  Public Subnet 1: $PUBLIC_SUBNET_1_ID"
echo "  Public Subnet 2: $PUBLIC_SUBNET_2_ID"
echo "  Private Subnet 1: $PRIVATE_SUBNET_1_ID"
echo "  Private Subnet 2: $PRIVATE_SUBNET_2_ID"
echo "  Public Route Table: $PUBLIC_RT_ID"
echo ""

# Step 2: Initialize Terraform in scenario directory
log_step "Step 2: Initializing Terraform..."
cd "$SCENARIO_DIR"
terraform init
echo ""

# Step 3: Backup state (if exists)
if [ -f "terraform.tfstate" ]; then
    log_step "Step 3: Backing up existing state..."
    cp terraform.tfstate "terraform.tfstate.backup.$(date +%Y%m%d-%H%M%S)"
    log_info "State backed up"
    echo ""
fi

# Step 4: Import VPC
log_step "Step 4: Importing VPC..."
terraform import aws_vpc.main "$VPC_ID" || log_warn "VPC already imported or import failed"
echo ""

# Step 5: Import Internet Gateway
log_step "Step 5: Importing Internet Gateway..."
terraform import aws_internet_gateway.main "$IGW_ID" || log_warn "IGW already imported or import failed"
echo ""

# Step 6: Import Public Subnets
log_step "Step 6: Importing Public Subnets..."
terraform import 'aws_subnet.public[0]' "$PUBLIC_SUBNET_1_ID" || log_warn "Public subnet 1 already imported or import failed"
terraform import 'aws_subnet.public[1]' "$PUBLIC_SUBNET_2_ID" || log_warn "Public subnet 2 already imported or import failed"
echo ""

# Step 7: Import Private Subnets
log_step "Step 7: Importing Private Subnets..."
terraform import 'aws_subnet.private[0]' "$PRIVATE_SUBNET_1_ID" || log_warn "Private subnet 1 already imported or import failed"
terraform import 'aws_subnet.private[1]' "$PRIVATE_SUBNET_2_ID" || log_warn "Private subnet 2 already imported or import failed"
echo ""

# Step 8: Import Route Table
log_step "Step 8: Importing Public Route Table..."
terraform import aws_route_table.public "$PUBLIC_RT_ID" || log_warn "Route table already imported or import failed"
echo ""

# Step 9: Import Route Table Associations
log_step "Step 9: Importing Route Table Associations..."
terraform import 'aws_route_table_association.public[0]' "$PUBLIC_RTA_1_ID" || log_warn "RTA 1 already imported or import failed"
terraform import 'aws_route_table_association.public[1]' "$PUBLIC_RTA_2_ID" || log_warn "RTA 2 already imported or import failed"
echo ""

# Step 10: Validate import
log_step "Step 10: Validating import..."
terraform validate
echo ""

# Step 11: Check for drift
log_step "Step 11: Checking for configuration drift..."
terraform plan -detailed-exitcode
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    log_info "✅ Import successful! No configuration drift detected."
elif [ $EXIT_CODE -eq 2 ]; then
    log_warn "⚠️  Import completed but configuration drift detected."
    log_warn "Review the plan output above and adjust configuration as needed."
else
    log_error "❌ Import validation failed."
    exit 1
fi

echo ""
log_info "VPC import completed!"
log_info "Location: $SCENARIO_DIR"

