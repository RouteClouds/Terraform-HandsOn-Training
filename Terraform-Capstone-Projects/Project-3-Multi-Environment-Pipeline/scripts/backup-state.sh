#!/bin/bash

# State Backup Script
# Backs up Terraform state files from S3 to local backup directory

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${PROJECT_DIR}/state-backups"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get state bucket name from backend config
get_bucket_name() {
    local env=$1
    local backend_config="${PROJECT_DIR}/environments/${env}/backend-config.hcl"
    
    if [ ! -f "$backend_config" ]; then
        log_error "Backend config not found: $backend_config"
        return 1
    fi
    
    grep "bucket" "$backend_config" | awk -F'"' '{print $2}'
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

log_info "Starting state backup..."
log_info "Backup directory: $BACKUP_DIR"
log_info "Timestamp: $TIMESTAMP"
echo ""

# Backup each environment
for ENV in dev staging prod; do
    log_info "Backing up ${ENV} environment..."
    
    BUCKET=$(get_bucket_name "$ENV")
    if [ -z "$BUCKET" ]; then
        log_warn "Could not determine bucket for ${ENV}, skipping..."
        continue
    fi
    
    STATE_KEY="${ENV}/terraform.tfstate"
    BACKUP_FILE="${BACKUP_DIR}/${ENV}-${TIMESTAMP}.tfstate"
    
    # Download state file
    if aws s3 cp "s3://${BUCKET}/${STATE_KEY}" "$BACKUP_FILE" 2>/dev/null; then
        log_info "✅ Backed up ${ENV} state to: $BACKUP_FILE"
    else
        log_warn "⚠️  Could not backup ${ENV} state (may not exist yet)"
    fi
done

echo ""
log_info "State backup completed!"
log_info "Backups saved to: $BACKUP_DIR"

# List backups
echo ""
log_info "Available backups:"
ls -lh "$BACKUP_DIR"

