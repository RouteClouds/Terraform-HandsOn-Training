# Makefile for Project 3: Multi-Environment Infrastructure Pipeline

.PHONY: help init-dev init-staging init-prod plan-dev plan-staging plan-prod apply-dev apply-staging apply-prod destroy-dev destroy-staging destroy-prod

# Variables
TERRAFORM_DIR := terraform-manifests
SCRIPTS_DIR := scripts
STATE_BACKEND_DIR := state-backend

# Default target
.DEFAULT_GOAL := help

# Help target
help: ## Show this help message
	@echo "Project 3: Multi-Environment Infrastructure Pipeline"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""

# State Backend targets
setup-backend: ## Setup state backend infrastructure
	@echo "Setting up state backend..."
	@cd $(STATE_BACKEND_DIR) && terraform init && terraform apply

destroy-backend: ## Destroy state backend (WARNING: destroys all state!)
	@echo "⚠️  WARNING: This will destroy the state backend!"
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	@cd $(STATE_BACKEND_DIR) && terraform destroy

# Development Environment
init-dev: ## Initialize dev environment
	@echo "Initializing dev environment..."
	@cd $(TERRAFORM_DIR) && terraform init -backend-config=../environments/dev/backend-config.hcl

plan-dev: ## Plan dev environment changes
	@echo "Planning dev environment..."
	@cd $(TERRAFORM_DIR) && terraform plan -var-file=../environments/dev/terraform.tfvars

apply-dev: ## Apply dev environment changes
	@echo "Applying dev environment..."
	@cd $(TERRAFORM_DIR) && terraform apply -var-file=../environments/dev/terraform.tfvars

destroy-dev: ## Destroy dev environment
	@echo "Destroying dev environment..."
	@cd $(TERRAFORM_DIR) && terraform destroy -var-file=../environments/dev/terraform.tfvars

output-dev: ## Show dev environment outputs
	@cd $(TERRAFORM_DIR) && terraform output

# Staging Environment
init-staging: ## Initialize staging environment
	@echo "Initializing staging environment..."
	@cd $(TERRAFORM_DIR) && terraform init -reconfigure -backend-config=../environments/staging/backend-config.hcl

plan-staging: ## Plan staging environment changes
	@echo "Planning staging environment..."
	@cd $(TERRAFORM_DIR) && terraform plan -var-file=../environments/staging/terraform.tfvars

apply-staging: ## Apply staging environment changes
	@echo "Applying staging environment..."
	@cd $(TERRAFORM_DIR) && terraform apply -var-file=../environments/staging/terraform.tfvars

destroy-staging: ## Destroy staging environment
	@echo "Destroying staging environment..."
	@cd $(TERRAFORM_DIR) && terraform destroy -var-file=../environments/staging/terraform.tfvars

output-staging: ## Show staging environment outputs
	@cd $(TERRAFORM_DIR) && terraform output

# Production Environment
init-prod: ## Initialize production environment
	@echo "Initializing production environment..."
	@cd $(TERRAFORM_DIR) && terraform init -reconfigure -backend-config=../environments/prod/backend-config.hcl

plan-prod: ## Plan production environment changes
	@echo "Planning production environment..."
	@cd $(TERRAFORM_DIR) && terraform plan -var-file=../environments/prod/terraform.tfvars

apply-prod: ## Apply production environment changes (requires confirmation)
	@echo "⚠️  WARNING: Applying to PRODUCTION!"
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	@cd $(TERRAFORM_DIR) && terraform apply -var-file=../environments/prod/terraform.tfvars

destroy-prod: ## Destroy production environment (requires confirmation)
	@echo "⚠️  WARNING: Destroying PRODUCTION!"
	@read -p "Type 'destroy-prod' to confirm: " confirm && [ "$$confirm" = "destroy-prod" ]
	@cd $(TERRAFORM_DIR) && terraform destroy -var-file=../environments/prod/terraform.tfvars

output-prod: ## Show production environment outputs
	@cd $(TERRAFORM_DIR) && terraform output

# Validation targets
validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@cd $(TERRAFORM_DIR) && terraform validate

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@cd $(TERRAFORM_DIR) && terraform fmt -recursive

fmt-check: ## Check Terraform formatting
	@echo "Checking Terraform formatting..."
	@cd $(TERRAFORM_DIR) && terraform fmt -check -recursive

# State Management
backup-state: ## Backup all state files
	@echo "Backing up state files..."
	@$(SCRIPTS_DIR)/backup-state.sh

switch-dev: ## Switch to dev environment
	@$(SCRIPTS_DIR)/switch-env.sh dev

switch-staging: ## Switch to staging environment
	@$(SCRIPTS_DIR)/switch-env.sh staging

switch-prod: ## Switch to production environment
	@$(SCRIPTS_DIR)/switch-env.sh prod

# Drift Detection
drift-check: ## Check for configuration drift
	@echo "Checking for configuration drift..."
	@$(SCRIPTS_DIR)/drift-check.sh

drift-check-dev: ## Check drift in dev environment
	@echo "Checking drift in dev environment..."
	@cd $(TERRAFORM_DIR) && terraform init -reconfigure -backend-config=../environments/dev/backend-config.hcl
	@cd $(TERRAFORM_DIR) && terraform plan -var-file=../environments/dev/terraform.tfvars -detailed-exitcode

drift-check-staging: ## Check drift in staging environment
	@echo "Checking drift in staging environment..."
	@cd $(TERRAFORM_DIR) && terraform init -reconfigure -backend-config=../environments/staging/backend-config.hcl
	@cd $(TERRAFORM_DIR) && terraform plan -var-file=../environments/staging/terraform.tfvars -detailed-exitcode

drift-check-prod: ## Check drift in production environment
	@echo "Checking drift in production environment..."
	@cd $(TERRAFORM_DIR) && terraform init -reconfigure -backend-config=../environments/prod/backend-config.hcl
	@cd $(TERRAFORM_DIR) && terraform plan -var-file=../environments/prod/terraform.tfvars -detailed-exitcode

# Deployment Scripts
deploy-dev: ## Deploy dev using script
	@$(SCRIPTS_DIR)/deploy.sh dev apply

deploy-staging: ## Deploy staging using script
	@$(SCRIPTS_DIR)/deploy.sh staging apply

deploy-prod: ## Deploy production using script
	@$(SCRIPTS_DIR)/deploy.sh prod apply

# Diagram Generation
diagrams: ## Generate architecture diagrams
	@echo "Generating architecture diagrams..."
	@cd diagrams && python3 generate_diagrams.py

# Clean targets
clean: ## Clean Terraform files
	@echo "Cleaning Terraform files..."
	@cd $(TERRAFORM_DIR) && rm -rf .terraform/ .terraform.lock.hcl tfplan *.tfstate.backup

clean-all: ## Clean all Terraform files including state backend
	@echo "Cleaning all Terraform files..."
	@cd $(TERRAFORM_DIR) && rm -rf .terraform/ .terraform.lock.hcl tfplan *.tfstate.backup
	@cd $(STATE_BACKEND_DIR) && rm -rf .terraform/ .terraform.lock.hcl *.tfstate.backup

# State Commands
state-list-dev: ## List resources in dev state
	@cd $(TERRAFORM_DIR) && terraform state list

state-list-staging: ## List resources in staging state
	@cd $(TERRAFORM_DIR) && terraform state list

state-list-prod: ## List resources in production state
	@cd $(TERRAFORM_DIR) && terraform state list

# Version targets
version: ## Show Terraform version
	@terraform version

providers: ## Show provider requirements
	@cd $(TERRAFORM_DIR) && terraform providers

# Security scan
security-scan: ## Run security scan (requires tfsec)
	@echo "Running security scan..."
	@if command -v tfsec > /dev/null; then \
		tfsec $(TERRAFORM_DIR); \
	else \
		echo "tfsec not installed. Install from https://github.com/aquasecurity/tfsec"; \
	fi

# Cost estimation
cost-estimate-dev: ## Estimate dev environment costs (requires infracost)
	@echo "Estimating dev environment costs..."
	@if command -v infracost > /dev/null; then \
		cd $(TERRAFORM_DIR) && infracost breakdown --path . --terraform-var-file=../environments/dev/terraform.tfvars; \
	else \
		echo "infracost not installed. Install from https://www.infracost.io/"; \
	fi

cost-estimate-staging: ## Estimate staging environment costs
	@echo "Estimating staging environment costs..."
	@if command -v infracost > /dev/null; then \
		cd $(TERRAFORM_DIR) && infracost breakdown --path . --terraform-var-file=../environments/staging/terraform.tfvars; \
	else \
		echo "infracost not installed. Install from https://www.infracost.io/"; \
	fi

cost-estimate-prod: ## Estimate production environment costs
	@echo "Estimating production environment costs..."
	@if command -v infracost > /dev/null; then \
		cd $(TERRAFORM_DIR) && infracost breakdown --path . --terraform-var-file=../environments/prod/terraform.tfvars; \
	else \
		echo "infracost not installed. Install from https://www.infracost.io/"; \
	fi

# Complete workflows
full-deploy-dev: init-dev validate fmt plan-dev apply-dev output-dev ## Complete dev deployment workflow

full-deploy-staging: init-staging validate fmt plan-staging apply-staging output-staging ## Complete staging deployment workflow

full-deploy-prod: init-prod validate fmt plan-prod apply-prod output-prod ## Complete production deployment workflow

