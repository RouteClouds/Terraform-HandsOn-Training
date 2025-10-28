#!/bin/bash

# Environment Switcher Script
# Switches between dev, staging, and prod environments

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

usage() {
    echo "Usage: $0 <environment>"
    echo ""
    echo "Environments:"
    echo "  dev       - Development environment"
    echo "  staging   - Staging environment"
    echo "  prod      - Production environment"
    exit 1
}

if [ $# -lt 1 ]; then
    log_error "Missing environment argument"
    usage
fi

ENVIRONMENT=$1

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    log_error "Invalid environment: $ENVIRONMENT"
    usage
fi

ENV_DIR="${PROJECT_DIR}/environments/${ENVIRONMENT}"
BACKEND_CONFIG="${ENV_DIR}/backend-config.hcl"

if [ ! -f "$BACKEND_CONFIG" ]; then
    log_error "Backend config not found: $BACKEND_CONFIG"
    exit 1
fi

cd "$TERRAFORM_DIR"

log_info "Switching to ${ENVIRONMENT} environment..."

# Reinitialize with new backend
terraform init -reconfigure -backend-config="$BACKEND_CONFIG"

log_info "✅ Switched to ${ENVIRONMENT} environment"
log_info "Current state backend: ${ENVIRONMENT}"

# Show current state
log_info "Current resources:"
terraform state list 2>/dev/null || log_warn "No resources in state (new environment?)"

