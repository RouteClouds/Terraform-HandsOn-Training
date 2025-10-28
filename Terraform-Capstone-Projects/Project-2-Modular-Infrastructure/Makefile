# Makefile for Project 2: Modular Infrastructure with Terraform Modules

.PHONY: help init validate fmt plan apply deploy destroy clean test diagrams all

# Variables
TERRAFORM_DIR := root-module/terraform-manifests
SCRIPTS_DIR := scripts
DIAGRAMS_DIR := diagrams

# Default target
.DEFAULT_GOAL := help

# Help target
help: ## Show this help message
	@echo "Project 2: Modular Infrastructure with Terraform Modules"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# Terraform targets
init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@cd $(TERRAFORM_DIR) && terraform init

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@cd $(TERRAFORM_DIR) && terraform validate

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@cd $(TERRAFORM_DIR) && terraform fmt -recursive

plan: ## Create Terraform plan
	@echo "Creating Terraform plan..."
	@cd $(TERRAFORM_DIR) && terraform plan

apply: ## Apply Terraform changes
	@echo "Applying Terraform changes..."
	@cd $(TERRAFORM_DIR) && terraform apply

deploy: ## Deploy infrastructure (init + validate + plan + apply)
	@echo "Deploying infrastructure..."
	@$(SCRIPTS_DIR)/deploy.sh

destroy: ## Destroy infrastructure
	@echo "Destroying infrastructure..."
	@cd $(TERRAFORM_DIR) && terraform destroy

clean: ## Clean up Terraform files
	@echo "Cleaning up Terraform files..."
	@cd $(TERRAFORM_DIR) && rm -rf .terraform/ .terraform.lock.hcl tfplan terraform.tfstate.backup

# Module targets
validate-modules: ## Validate all modules
	@echo "Validating all modules..."
	@for dir in modules/*/; do \
		echo "Validating $$dir..."; \
		cd $$dir && terraform init -backend=false && terraform validate && cd ../..; \
	done

test-modules: ## Test all modules
	@echo "Testing all modules..."
	@for dir in modules/*/; do \
		echo "Testing $$dir..."; \
		cd $$dir && terraform init -backend=false && terraform validate && cd ../..; \
	done

# Validation targets
test: ## Run validation tests
	@echo "Running validation tests..."
	@$(SCRIPTS_DIR)/validate.sh

# Diagram targets
diagrams: ## Generate architecture diagrams
	@echo "Generating architecture diagrams..."
	@cd $(DIAGRAMS_DIR) && python3 generate_diagrams.py

# Output targets
output: ## Show Terraform outputs
	@echo "Terraform outputs:"
	@cd $(TERRAFORM_DIR) && terraform output

output-json: ## Show Terraform outputs in JSON format
	@echo "Terraform outputs (JSON):"
	@cd $(TERRAFORM_DIR) && terraform output -json

# State targets
state-list: ## List resources in Terraform state
	@echo "Resources in Terraform state:"
	@cd $(TERRAFORM_DIR) && terraform state list

state-show: ## Show detailed state information
	@echo "Detailed state information:"
	@cd $(TERRAFORM_DIR) && terraform state show

# Documentation targets
docs: ## Generate module documentation
	@echo "Module documentation is available in each module's README.md"
	@find modules -name "README.md" -exec echo {} \;

# Complete workflow targets
all: init validate fmt plan ## Run init, validate, fmt, and plan

full-deploy: init validate fmt plan apply output ## Complete deployment workflow

full-cleanup: destroy clean ## Complete cleanup workflow

# CI/CD targets
ci-validate: init validate fmt ## CI validation workflow
	@echo "CI validation completed"

ci-plan: init validate plan ## CI plan workflow
	@echo "CI plan completed"

ci-apply: init validate apply ## CI apply workflow
	@echo "CI apply completed"

# Development targets
dev-init: ## Initialize for development
	@echo "Initializing for development..."
	@make init
	@make validate

dev-deploy: ## Deploy for development
	@echo "Deploying for development..."
	@make init
	@make validate
	@make plan
	@make apply

# Production targets
prod-plan: ## Plan for production
	@echo "Planning for production..."
	@make init
	@make validate
	@make plan

prod-apply: ## Apply for production (requires confirmation)
	@echo "Applying for production..."
	@echo "WARNING: This will apply changes to production!"
	@read -p "Are you sure? [yes/no]: " confirm && [ "$$confirm" = "yes" ]
	@make apply

# Utility targets
version: ## Show Terraform version
	@terraform version

providers: ## Show provider requirements
	@cd $(TERRAFORM_DIR) && terraform providers

graph: ## Generate dependency graph
	@cd $(TERRAFORM_DIR) && terraform graph | dot -Tpng > dependency-graph.png
	@echo "Dependency graph saved to dependency-graph.png"

# Module-specific targets
vpc: ## Deploy only VPC module
	@echo "Deploying VPC module..."
	@cd $(TERRAFORM_DIR) && terraform apply -target=module.vpc

security: ## Deploy only Security module
	@echo "Deploying Security module..."
	@cd $(TERRAFORM_DIR) && terraform apply -target=module.security

compute: ## Deploy only Compute module
	@echo "Deploying Compute module..."
	@cd $(TERRAFORM_DIR) && terraform apply -target=module.compute

database: ## Deploy only Database module
	@echo "Deploying Database module..."
	@cd $(TERRAFORM_DIR) && terraform apply -target=module.database

# Refresh targets
refresh: ## Refresh Terraform state
	@echo "Refreshing Terraform state..."
	@cd $(TERRAFORM_DIR) && terraform refresh

# Import targets
import: ## Import existing resources (requires RESOURCE and ID)
	@echo "Importing resource..."
	@cd $(TERRAFORM_DIR) && terraform import $(RESOURCE) $(ID)

# Workspace targets
workspace-list: ## List Terraform workspaces
	@cd $(TERRAFORM_DIR) && terraform workspace list

workspace-new: ## Create new workspace (requires NAME)
	@cd $(TERRAFORM_DIR) && terraform workspace new $(NAME)

workspace-select: ## Select workspace (requires NAME)
	@cd $(TERRAFORM_DIR) && terraform workspace select $(NAME)

# Lint targets
lint: ## Lint Terraform files
	@echo "Linting Terraform files..."
	@cd $(TERRAFORM_DIR) && terraform fmt -check -recursive

# Security scan targets
security-scan: ## Run security scan (requires tfsec)
	@echo "Running security scan..."
	@if command -v tfsec > /dev/null; then \
		tfsec $(TERRAFORM_DIR); \
	else \
		echo "tfsec not installed. Install from https://github.com/aquasecurity/tfsec"; \
	fi

# Cost estimation targets
cost-estimate: ## Estimate infrastructure costs (requires infracost)
	@echo "Estimating infrastructure costs..."
	@if command -v infracost > /dev/null; then \
		cd $(TERRAFORM_DIR) && infracost breakdown --path .; \
	else \
		echo "infracost not installed. Install from https://www.infracost.io/"; \
	fi

