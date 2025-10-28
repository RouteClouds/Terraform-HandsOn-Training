# Makefile for Project 5: Enterprise-Grade Secure Infrastructure

.PHONY: help init plan apply destroy validate fmt security-scan test compliance-check cost-estimate diagrams clean

# Variables
TERRAFORM_DIR := terraform
DIAGRAMS_DIR := diagrams
SCRIPTS_DIR := scripts
TESTS_DIR := tests

# Default target
.DEFAULT_GOAL := help

# Help target
help: ## Show this help message
	@echo "Project 5: Enterprise-Grade Secure Infrastructure"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""

# Terraform Operations
init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@cd $(TERRAFORM_DIR) && terraform init

plan: ## Create Terraform execution plan
	@echo "Creating execution plan..."
	@cd $(TERRAFORM_DIR) && terraform plan -out=tfplan

apply: ## Apply Terraform changes
	@echo "Applying Terraform changes..."
	@cd $(TERRAFORM_DIR) && terraform apply tfplan

apply-auto: ## Apply Terraform changes without confirmation
	@echo "Applying Terraform changes (auto-approve)..."
	@cd $(TERRAFORM_DIR) && terraform apply -auto-approve

destroy: ## Destroy Terraform infrastructure
	@echo "⚠️  WARNING: This will destroy all infrastructure!"
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	@cd $(TERRAFORM_DIR) && terraform destroy

# Validation
validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@cd $(TERRAFORM_DIR) && terraform validate

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive .

fmt-check: ## Check Terraform formatting
	@echo "Checking Terraform formatting..."
	@terraform fmt -check -recursive .

# Security Scanning
security-scan: tfsec checkov terrascan ## Run all security scans

tfsec: ## Run tfsec security scan
	@echo "Running tfsec security scan..."
	@if command -v tfsec > /dev/null; then \
		tfsec $(TERRAFORM_DIR) --config-file security-scanning/tfsec.yml; \
	else \
		echo "⚠️  tfsec not installed. Install with: brew install tfsec"; \
	fi

checkov: ## Run checkov security scan
	@echo "Running checkov security scan..."
	@if command -v checkov > /dev/null; then \
		checkov -d $(TERRAFORM_DIR) --config-file security-scanning/checkov.yml; \
	else \
		echo "⚠️  checkov not installed. Install with: pip install checkov"; \
	fi

terrascan: ## Run terrascan security scan
	@echo "Running terrascan security scan..."
	@if command -v terrascan > /dev/null; then \
		terrascan scan -t aws -d $(TERRAFORM_DIR); \
	else \
		echo "⚠️  terrascan not installed. Install from: https://github.com/tenable/terrascan"; \
	fi

# Testing
test: test-unit test-integration ## Run all tests

test-unit: ## Run unit tests
	@echo "Running unit tests..."
	@if [ -d "$(TESTS_DIR)/unit" ]; then \
		cd $(TESTS_DIR)/unit && terraform test; \
	else \
		echo "No unit tests found"; \
	fi

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	@if [ -d "$(TESTS_DIR)/integration" ]; then \
		cd $(TESTS_DIR)/integration && terraform test; \
	else \
		echo "No integration tests found"; \
	fi

test-security: ## Run security tests
	@echo "Running security tests..."
	@make security-scan

# Compliance
compliance-check: ## Check compliance with CIS benchmarks
	@echo "Checking compliance..."
	@if command -v aws > /dev/null; then \
		$(SCRIPTS_DIR)/compliance-check.sh; \
	else \
		echo "⚠️  AWS CLI not installed"; \
	fi

# Cost Estimation
cost-estimate: ## Estimate infrastructure cost
	@echo "Estimating infrastructure cost..."
	@if command -v infracost > /dev/null; then \
		cd $(TERRAFORM_DIR) && infracost breakdown --path .; \
	else \
		echo "⚠️  infracost not installed. Install from: https://www.infracost.io/docs/"; \
	fi

cost-diff: ## Show cost difference
	@echo "Showing cost difference..."
	@if command -v infracost > /dev/null; then \
		cd $(TERRAFORM_DIR) && infracost diff --path .; \
	else \
		echo "⚠️  infracost not installed"; \
	fi

# Diagram Generation
diagrams: ## Generate architecture diagrams
	@echo "Generating architecture diagrams..."
	@cd $(DIAGRAMS_DIR) && python3 generate_diagrams.py

# Documentation
docs: ## Open documentation
	@echo "Opening documentation..."
	@if command -v xdg-open > /dev/null; then \
		xdg-open README.md; \
	elif command -v open > /dev/null; then \
		open README.md; \
	else \
		echo "Please open README.md manually"; \
	fi

# State Management
state-list: ## List resources in state
	@cd $(TERRAFORM_DIR) && terraform state list

state-show: ## Show specific resource
	@read -p "Enter resource address: " resource && \
	cd $(TERRAFORM_DIR) && terraform state show $$resource

state-backup: ## Backup state file
	@echo "Backing up state file..."
	@mkdir -p backups
	@if [ -f "$(TERRAFORM_DIR)/terraform.tfstate" ]; then \
		cp $(TERRAFORM_DIR)/terraform.tfstate backups/terraform.tfstate.$$(date +%Y%m%d-%H%M%S); \
		echo "✅ State backed up to backups/"; \
	else \
		echo "No state file found"; \
	fi

# Outputs
outputs: ## Show Terraform outputs
	@cd $(TERRAFORM_DIR) && terraform output

outputs-json: ## Show Terraform outputs in JSON
	@cd $(TERRAFORM_DIR) && terraform output -json

# Clean
clean: ## Clean temporary files
	@echo "Cleaning temporary files..."
	@find . -type f -name "*.tfplan" -delete
	@find . -type f -name "*.tfstate.backup" -delete
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Cleaned"

clean-all: clean ## Clean all generated files including diagrams
	@echo "Cleaning all generated files..."
	@rm -f $(DIAGRAMS_DIR)/*.png
	@echo "✅ All cleaned"

# Troubleshooting
troubleshoot: ## Run troubleshooting script
	@echo "Running troubleshooting..."
	@$(SCRIPTS_DIR)/troubleshoot.sh

debug: ## Enable Terraform debug logging
	@echo "Enabling debug logging..."
	@export TF_LOG=DEBUG && cd $(TERRAFORM_DIR) && terraform plan

# Version
version: ## Show Terraform version
	@terraform version

# Quick workflows
quick-deploy: init validate security-scan plan apply ## Quick deployment workflow

full-check: validate fmt-check security-scan test compliance-check ## Full validation workflow

# CI/CD simulation
ci: fmt-check validate security-scan test ## CI pipeline simulation

cd: plan ## CD pipeline simulation (requires manual apply)

# Setup
setup: ## Setup project dependencies
	@echo "Setting up project dependencies..."
	@$(SCRIPTS_DIR)/setup.sh

# Graph
graph: ## Generate dependency graph
	@echo "Generating dependency graph..."
	@cd $(TERRAFORM_DIR) && terraform graph | dot -Tpng > ../diagrams/dependency-graph.png
	@echo "✅ Graph saved to diagrams/dependency-graph.png"

# Refresh
refresh: ## Refresh Terraform state
	@cd $(TERRAFORM_DIR) && terraform refresh

# Import
import: ## Import existing resource
	@read -p "Enter resource address: " address && \
	read -p "Enter resource ID: " id && \
	cd $(TERRAFORM_DIR) && terraform import $$address $$id

# Taint
taint: ## Mark resource for recreation
	@read -p "Enter resource address: " resource && \
	cd $(TERRAFORM_DIR) && terraform taint $$resource

# Untaint
untaint: ## Remove taint from resource
	@read -p "Enter resource address: " resource && \
	cd $(TERRAFORM_DIR) && terraform untaint $$resource

# Console
console: ## Open Terraform console
	@cd $(TERRAFORM_DIR) && terraform console

# Providers
providers: ## Show provider requirements
	@cd $(TERRAFORM_DIR) && terraform providers

# Lock
lock: ## Update provider lock file
	@cd $(TERRAFORM_DIR) && terraform providers lock

# Workspace operations
workspace-list: ## List workspaces
	@cd $(TERRAFORM_DIR) && terraform workspace list

workspace-new: ## Create new workspace
	@read -p "Enter workspace name: " name && \
	cd $(TERRAFORM_DIR) && terraform workspace new $$name

workspace-select: ## Select workspace
	@read -p "Enter workspace name: " name && \
	cd $(TERRAFORM_DIR) && terraform workspace select $$name

# Quick reference
quick-ref: ## Show quick reference guide
	@echo "Quick Reference Guide"
	@echo "===================="
	@echo ""
	@echo "1. Setup: make setup"
	@echo "2. Initialize: make init"
	@echo "3. Validate: make validate"
	@echo "4. Security Scan: make security-scan"
	@echo "5. Plan: make plan"
	@echo "6. Apply: make apply"
	@echo "7. Test: make test"
	@echo "8. Compliance: make compliance-check"
	@echo ""
	@echo "For more help: make help"

