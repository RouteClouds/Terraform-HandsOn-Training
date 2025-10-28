#!/bin/bash

# Cleanup Script for Project 2: Modular Infrastructure
# This script destroys all deployed infrastructure

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

# Destroy infrastructure
terraform_destroy() {
    log_info "Destroying infrastructure..."
    cd "$TERRAFORM_DIR"
    
    terraform destroy -auto-approve
    
    log_info "Infrastructure destroyed successfully"
}

# Clean up local files
cleanup_local_files() {
    log_info "Cleaning up local files..."
    cd "$TERRAFORM_DIR"
    
    rm -rf .terraform/
    rm -f .terraform.lock.hcl
    rm -f tfplan
    rm -f terraform.tfstate.backup
    
    log_info "Local files cleaned up"
}

# Main cleanup flow
main() {
    log_warn "This will destroy ALL infrastructure resources!"
    log_warn "This action cannot be undone!"
    echo ""
    log_warn "Are you sure you want to proceed? (yes/no)"
    read -r response
    
    if [ "$response" = "yes" ]; then
        log_info "Starting cleanup..."
        echo ""
        
        terraform_destroy
        cleanup_local_files
        
        echo ""
        log_info "Cleanup completed successfully!"
    else
        log_info "Cleanup cancelled by user"
        exit 0
    fi
}

# Run main function
main

