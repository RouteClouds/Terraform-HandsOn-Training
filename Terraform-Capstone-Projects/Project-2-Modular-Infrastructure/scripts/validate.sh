#!/bin/bash

# Validation Script for Project 2: Modular Infrastructure
# This script validates the deployed infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="${PROJECT_DIR}/root-module/terraform-manifests"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate Terraform state
validate_terraform_state() {
    log_info "Validating Terraform state..."
    cd "$TERRAFORM_DIR"
    
    if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
        log_error "No Terraform state found. Have you deployed the infrastructure?"
        exit 1
    fi
    
    log_info "Terraform state exists"
}

# Check AWS resources
check_aws_resources() {
    log_info "Checking AWS resources..."
    cd "$TERRAFORM_DIR"
    
    # Get outputs
    VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "")
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "")
    
    if [ -n "$VPC_ID" ]; then
        log_info "VPC ID: $VPC_ID"
    else
        log_warn "VPC ID not found in outputs"
    fi
    
    if [ -n "$ALB_DNS" ]; then
        log_info "ALB DNS: $ALB_DNS"
    else
        log_warn "ALB DNS not found in outputs"
    fi
}

# Test ALB endpoint
test_alb_endpoint() {
    log_info "Testing ALB endpoint..."
    cd "$TERRAFORM_DIR"
    
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "")
    
    if [ -n "$ALB_DNS" ]; then
        log_info "Testing HTTP connection to $ALB_DNS..."
        
        if curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS" | grep -q "200\|301\|302"; then
            log_info "ALB is responding"
        else
            log_warn "ALB is not responding or returned non-success status"
        fi
    else
        log_warn "ALB DNS not available for testing"
    fi
}

# Validate modules
validate_modules() {
    log_info "Validating modules..."
    
    for module_dir in "$PROJECT_DIR"/modules/*/; do
        module_name=$(basename "$module_dir")
        log_info "Validating module: $module_name"
        
        cd "$module_dir"
        terraform init -backend=false > /dev/null 2>&1
        terraform validate
        
        log_info "Module $module_name is valid"
    done
}

# Main validation flow
main() {
    log_info "Starting validation of Modular Infrastructure..."
    echo ""
    
    validate_terraform_state
    check_aws_resources
    test_alb_endpoint
    validate_modules
    
    echo ""
    log_info "Validation completed successfully!"
}

# Run main function
main

