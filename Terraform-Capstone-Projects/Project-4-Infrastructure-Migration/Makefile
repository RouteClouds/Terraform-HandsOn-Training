# Makefile for Project 4: Infrastructure Migration and Import

.PHONY: help setup scenario-1 scenario-2 backup-state restore-state validate-all clean diagrams

# Variables
EXISTING_DIR := existing-infrastructure
SCENARIO_1_DIR := scenarios/scenario-1-vpc/imported
SCENARIO_2_DIR := scenarios/scenario-2-ec2-to-asg/imported
SCRIPTS_DIR := scripts
DIAGRAMS_DIR := diagrams

# Default target
.DEFAULT_GOAL := help

# Help target
help: ## Show this help message
	@echo "Project 4: Infrastructure Migration and Import"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""

# Setup existing infrastructure
setup: ## Create existing infrastructure for import
	@echo "Creating existing infrastructure..."
	@cd $(EXISTING_DIR) && terraform init && terraform apply -auto-approve
	@echo ""
	@echo "✅ Existing infrastructure created!"
	@echo "Resource IDs:"
	@cd $(EXISTING_DIR) && terraform output

setup-plan: ## Plan existing infrastructure
	@cd $(EXISTING_DIR) && terraform init && terraform plan

# Scenario 1: VPC Import
scenario-1: ## Run VPC import scenario
	@echo "Running Scenario 1: VPC Import..."
	@$(SCRIPTS_DIR)/import-vpc.sh

scenario-1-init: ## Initialize Scenario 1
	@cd $(SCENARIO_1_DIR) && terraform init

scenario-1-plan: ## Plan Scenario 1
	@cd $(SCENARIO_1_DIR) && terraform plan

scenario-1-validate: ## Validate Scenario 1
	@cd $(SCENARIO_1_DIR) && terraform validate && terraform plan -detailed-exitcode

# Scenario 2: EC2 to ASG
scenario-2-init: ## Initialize Scenario 2
	@cd $(SCENARIO_2_DIR) && terraform init

scenario-2-plan: ## Plan Scenario 2
	@cd $(SCENARIO_2_DIR) && terraform plan

scenario-2-apply: ## Apply Scenario 2
	@cd $(SCENARIO_2_DIR) && terraform apply

scenario-2-validate: ## Validate Scenario 2
	@cd $(SCENARIO_2_DIR) && terraform validate && terraform plan

# State Management
backup-state: ## Backup all state files
	@echo "Backing up state files..."
	@mkdir -p state-backups
	@if [ -f "$(EXISTING_DIR)/terraform.tfstate" ]; then \
		cp $(EXISTING_DIR)/terraform.tfstate state-backups/existing-$$(date +%Y%m%d-%H%M%S).tfstate; \
	fi
	@if [ -f "$(SCENARIO_1_DIR)/terraform.tfstate" ]; then \
		cp $(SCENARIO_1_DIR)/terraform.tfstate state-backups/scenario-1-$$(date +%Y%m%d-%H%M%S).tfstate; \
	fi
	@if [ -f "$(SCENARIO_2_DIR)/terraform.tfstate" ]; then \
		cp $(SCENARIO_2_DIR)/terraform.tfstate state-backups/scenario-2-$$(date +%Y%m%d-%H%M%S).tfstate; \
	fi
	@echo "✅ State files backed up to state-backups/"

list-state-existing: ## List resources in existing infrastructure state
	@cd $(EXISTING_DIR) && terraform state list

list-state-scenario-1: ## List resources in Scenario 1 state
	@cd $(SCENARIO_1_DIR) && terraform state list

list-state-scenario-2: ## List resources in Scenario 2 state
	@cd $(SCENARIO_2_DIR) && terraform state list

show-state-existing: ## Show existing infrastructure state
	@cd $(EXISTING_DIR) && terraform state pull | jq .

# Validation
validate-all: ## Validate all configurations
	@echo "Validating all configurations..."
	@cd $(EXISTING_DIR) && terraform validate && echo "✅ Existing infrastructure valid"
	@cd $(SCENARIO_1_DIR) && terraform validate && echo "✅ Scenario 1 valid"
	@cd $(SCENARIO_2_DIR) && terraform validate && echo "✅ Scenario 2 valid"

fmt: ## Format all Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive .

fmt-check: ## Check Terraform formatting
	@echo "Checking Terraform formatting..."
	@terraform fmt -check -recursive .

# Diagram Generation
diagrams: ## Generate architecture diagrams
	@echo "Generating architecture diagrams..."
	@cd $(DIAGRAMS_DIR) && python3 generate_diagrams.py

# Clean targets
clean-scenario-1: ## Clean Scenario 1 Terraform files
	@echo "Cleaning Scenario 1..."
	@cd $(SCENARIO_1_DIR) && rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate.backup

clean-scenario-2: ## Clean Scenario 2 Terraform files
	@echo "Cleaning Scenario 2..."
	@cd $(SCENARIO_2_DIR) && rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate.backup

clean-existing: ## Clean existing infrastructure Terraform files
	@echo "Cleaning existing infrastructure..."
	@cd $(EXISTING_DIR) && rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate.backup

clean: clean-scenario-1 clean-scenario-2 clean-existing ## Clean all Terraform files
	@echo "✅ All Terraform files cleaned"

# Destroy targets
destroy-scenario-2: ## Destroy Scenario 2 resources
	@echo "⚠️  Destroying Scenario 2 resources..."
	@cd $(SCENARIO_2_DIR) && terraform destroy

destroy-existing: ## Destroy existing infrastructure
	@echo "⚠️  WARNING: This will destroy all existing infrastructure!"
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	@cd $(EXISTING_DIR) && terraform destroy

# Import helpers
import-commands: ## Show import commands for all resources
	@echo "Import commands:"
	@cd $(EXISTING_DIR) && terraform output -raw import_commands

get-resource-ids: ## Get all resource IDs for import
	@echo "Resource IDs for import:"
	@cd $(EXISTING_DIR) && terraform output -json | jq -r 'to_entries[] | select(.key | endswith("_id") or endswith("_name") or endswith("_arn")) | "\(.key): \(.value.value)"'

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

# Version
version: ## Show Terraform version
	@terraform version

# Complete workflows
full-scenario-1: setup scenario-1 scenario-1-validate ## Complete Scenario 1 workflow

full-scenario-2: setup scenario-2-init scenario-2-apply scenario-2-validate ## Complete Scenario 2 workflow

# Testing
test-import: ## Test import process (dry run)
	@echo "Testing import process..."
	@echo "This would import resources without actually doing it"
	@cd $(EXISTING_DIR) && terraform output -raw import_commands

# State manipulation examples
state-examples: ## Show state manipulation command examples
	@echo "State Manipulation Examples:"
	@echo ""
	@echo "List resources:"
	@echo "  terraform state list"
	@echo ""
	@echo "Show resource:"
	@echo "  terraform state show aws_vpc.main"
	@echo ""
	@echo "Move resource:"
	@echo "  terraform state mv aws_vpc.main module.vpc.aws_vpc.main"
	@echo ""
	@echo "Remove resource:"
	@echo "  terraform state rm aws_instance.old"
	@echo ""
	@echo "Pull state:"
	@echo "  terraform state pull > backup.tfstate"
	@echo ""
	@echo "Push state:"
	@echo "  terraform state push backup.tfstate"

# Quick reference
quick-ref: ## Show quick reference guide
	@echo "Quick Reference Guide"
	@echo "===================="
	@echo ""
	@echo "1. Setup: make setup"
	@echo "2. Run Scenario 1: make scenario-1"
	@echo "3. Run Scenario 2: make scenario-2-init && make scenario-2-apply"
	@echo "4. Backup state: make backup-state"
	@echo "5. Validate: make validate-all"
	@echo "6. Clean: make clean"
	@echo ""
	@echo "For more help: make help"

