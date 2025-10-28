#!/bin/bash

# Deployment Script for Project 2: Modular Infrastructure
# This script automates the deployment of the modular infrastructure

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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Initialize Terraform
terraform_init() {
    log_info "Initializing Terraform..."
    cd "$TERRAFORM_DIR"
    terraform init
    log_info "Terraform initialized successfully"
}

# Validate Terraform configuration
terraform_validate() {
    log_info "Validating Terraform configuration..."
    cd "$TERRAFORM_DIR"
    terraform validate
    log_info "Terraform configuration is valid"
}

# Format Terraform files
terraform_fmt() {
    log_info "Formatting Terraform files..."
    cd "$TERRAFORM_DIR"
    terraform fmt -recursive
    log_info "Terraform files formatted"
}

# Plan Terraform changes
terraform_plan() {
    log_info "Planning Terraform changes..."
    cd "$TERRAFORM_DIR"
    terraform plan -out=tfplan
    log_info "Terraform plan created successfully"
}

# Apply Terraform changes
terraform_apply() {
    log_info "Applying Terraform changes..."
    cd "$TERRAFORM_DIR"
    
    if [ -f "tfplan" ]; then
        terraform apply tfplan
        rm -f tfplan
    else
        terraform apply -auto-approve
    fi
    
    log_info "Terraform apply completed successfully"
}

# Show outputs
show_outputs() {
    log_info "Deployment outputs:"
    cd "$TERRAFORM_DIR"
    terraform output
}

# Main deployment flow
main() {
    log_info "Starting deployment of Modular Infrastructure..."
    echo ""
    
    check_prerequisites
    terraform_init
    terraform_validate
    terraform_fmt
    terraform_plan
    
    echo ""
    log_warn "Review the plan above. Do you want to proceed with apply? (yes/no)"
    read -r response
    
    if [ "$response" = "yes" ]; then
        terraform_apply
        echo ""
        show_outputs
        echo ""
        log_info "Deployment completed successfully!"
    else
        log_warn "Deployment cancelled by user"
        exit 0
    fi
}

# Run main function
main

