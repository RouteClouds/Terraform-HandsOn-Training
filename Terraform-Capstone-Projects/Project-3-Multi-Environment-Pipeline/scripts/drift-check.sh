#!/bin/bash

# Drift Detection Script
# Checks for configuration drift across all environments

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="${PROJECT_DIR}/terraform-manifests"

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

# Check drift for an environment
check_drift() {
    local env=$1
    
    log_step "Checking drift for ${env} environment..."
    
    local env_dir="${PROJECT_DIR}/environments/${env}"
    local tfvars_file="${env_dir}/terraform.tfvars"
    local backend_config="${env_dir}/backend-config.hcl"
    
    cd "$TERRAFORM_DIR"
    
    # Initialize
    terraform init -reconfigure -backend-config="$backend_config" > /dev/null 2>&1
    
    # Run plan with detailed exit code
    set +e
    terraform plan -var-file="$tfvars_file" -detailed-exitcode > /dev/null 2>&1
    EXIT_CODE=$?
    set -e
    
    case $EXIT_CODE in
        0)
            log_info "✅ ${env}: No drift detected"
            return 0
            ;;
        1)
            log_error "❌ ${env}: Error checking for drift"
            return 1
            ;;
        2)
            log_warn "⚠️  ${env}: Configuration drift detected!"
            return 2
            ;;
    esac
}

# Main
main() {
    log_info "Starting drift detection across all environments..."
    echo ""
    
    DRIFT_DETECTED=0
    
    for ENV in dev staging prod; do
        check_drift "$ENV"
        RESULT=$?
        
        if [ $RESULT -eq 2 ]; then
            DRIFT_DETECTED=1
        fi
        
        echo ""
    done
    
    if [ $DRIFT_DETECTED -eq 1 ]; then
        log_warn "⚠️  Drift detected in one or more environments!"
        log_warn "Run './deploy.sh <env> plan' to see details"
        exit 2
    else
        log_info "✅ No drift detected in any environment"
        exit 0
    fi
}

# Run main
main

