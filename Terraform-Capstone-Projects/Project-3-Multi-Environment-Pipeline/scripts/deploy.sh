#!/bin/bash

# Deployment Script for Multi-Environment Infrastructure
# Usage: ./deploy.sh <environment> [action]
# Example: ./deploy.sh dev plan
# Example: ./deploy.sh prod apply

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="${PROJECT_DIR}/terraform-manifests"

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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Usage
usage() {
    echo "Usage: $0 <environment> [action]"
    echo ""
    echo "Environments:"
    echo "  dev       - Development environment"
    echo "  staging   - Staging environment"
    echo "  prod      - Production environment"
    echo ""
    echo "Actions:"
    echo "  plan      - Create execution plan (default)"
    echo "  apply     - Apply changes"
    echo "  destroy   - Destroy infrastructure"
    echo ""
    echo "Examples:"
    echo "  $0 dev plan"
    echo "  $0 staging apply"
    echo "  $0 prod plan"
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    log_error "Missing environment argument"
    usage
fi

ENVIRONMENT=$1
ACTION=${2:-plan}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    log_error "Invalid environment: $ENVIRONMENT"
    usage
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    log_error "Invalid action: $ACTION"
    usage
fi

# Environment-specific settings
ENV_DIR="${PROJECT_DIR}/environments/${ENVIRONMENT}"
TFVARS_FILE="${ENV_DIR}/terraform.tfvars"
BACKEND_CONFIG="${ENV_DIR}/backend-config.hcl"

# Check if files exist
if [ ! -f "$TFVARS_FILE" ]; then
    log_error "Variables file not found: $TFVARS_FILE"
    exit 1
fi

if [ ! -f "$BACKEND_CONFIG" ]; then
    log_error "Backend config not found: $BACKEND_CONFIG"
    exit 1
fi

# Main deployment
main() {
    log_info "Starting deployment for ${ENVIRONMENT} environment"
    log_info "Action: ${ACTION}"
    echo ""
    
    cd "$TERRAFORM_DIR"
    
    # Initialize
    log_step "Initializing Terraform..."
    terraform init -backend-config="$BACKEND_CONFIG"
    echo ""
    
    # Validate
    log_step "Validating configuration..."
    terraform validate
    echo ""
    
    # Format check
    log_step "Checking format..."
    terraform fmt -check -recursive || log_warn "Format check failed (non-critical)"
    echo ""
    
    # Execute action
    case $ACTION in
        plan)
            log_step "Creating execution plan..."
            terraform plan -var-file="$TFVARS_FILE" -out=tfplan
            echo ""
            log_info "Plan created successfully!"
            log_info "Review the plan above and run with 'apply' to execute"
            ;;
        
        apply)
            log_step "Creating execution plan..."
            terraform plan -var-file="$TFVARS_FILE" -out=tfplan
            echo ""
            
            # Confirmation for production
            if [ "$ENVIRONMENT" = "prod" ]; then
                log_warn "⚠️  PRODUCTION DEPLOYMENT ⚠️"
                log_warn "You are about to apply changes to PRODUCTION!"
                echo ""
                read -p "Type 'yes' to confirm: " confirm
                
                if [ "$confirm" != "yes" ]; then
                    log_info "Deployment cancelled"
                    exit 0
                fi
            fi
            
            log_step "Applying changes..."
            terraform apply tfplan
            rm -f tfplan
            echo ""
            
            log_step "Deployment outputs:"
            terraform output
            echo ""
            
            log_info "✅ Deployment completed successfully!"
            ;;
        
        destroy)
            log_warn "⚠️  DESTROY OPERATION ⚠️"
            log_warn "You are about to DESTROY infrastructure in ${ENVIRONMENT}!"
            echo ""
            
            # Extra confirmation for production
            if [ "$ENVIRONMENT" = "prod" ]; then
                log_error "Production destroy requires manual confirmation"
                read -p "Type 'destroy-prod' to confirm: " confirm
                
                if [ "$confirm" != "destroy-prod" ]; then
                    log_info "Destroy cancelled"
                    exit 0
                fi
            else
                read -p "Type 'yes' to confirm: " confirm
                
                if [ "$confirm" != "yes" ]; then
                    log_info "Destroy cancelled"
                    exit 0
                fi
            fi
            
            log_step "Destroying infrastructure..."
            terraform destroy -var-file="$TFVARS_FILE" -auto-approve
            echo ""
            
            log_info "✅ Infrastructure destroyed"
            ;;
    esac
}

# Run main function
main

