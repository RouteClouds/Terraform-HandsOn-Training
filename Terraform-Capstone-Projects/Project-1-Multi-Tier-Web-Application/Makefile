# Makefile for Project 1: Multi-Tier Web Application Infrastructure
# Provides convenient targets for common Terraform operations

.PHONY: help init validate fmt fmt-check plan apply deploy destroy clean test diagrams all

# Default target
.DEFAULT_GOAL := help

# Variables
TERRAFORM_DIR := terraform-manifests
SCRIPTS_DIR := scripts
DIAGRAMS_DIR := diagrams
VENV := $(DIAGRAMS_DIR)/venv

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

##@ General

help: ## Display this help message
	@echo "$(GREEN)╔═══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(GREEN)║                                                               ║$(NC)"
	@echo "$(GREEN)║   Project 1: Multi-Tier Web Application Infrastructure       ║$(NC)"
	@echo "$(GREEN)║   Makefile Targets                                            ║$(NC)"
	@echo "$(GREEN)║                                                               ║$(NC)"
	@echo "$(GREEN)╚═══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(YELLOW)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(GREEN)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Setup

init: ## Initialize Terraform
	@echo "$(GREEN)Initializing Terraform...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform init
	@echo "$(GREEN)✓ Terraform initialized$(NC)"

init-upgrade: ## Initialize Terraform with provider upgrade
	@echo "$(GREEN)Initializing Terraform with provider upgrade...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform init -upgrade
	@echo "$(GREEN)✓ Terraform initialized with upgraded providers$(NC)"

##@ Validation

validate: ## Validate Terraform configuration
	@echo "$(GREEN)Validating Terraform configuration...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform validate
	@echo "$(GREEN)✓ Configuration is valid$(NC)"

fmt: ## Format Terraform files
	@echo "$(GREEN)Formatting Terraform files...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform fmt -recursive
	@echo "$(GREEN)✓ Files formatted$(NC)"

fmt-check: ## Check if Terraform files are formatted
	@echo "$(GREEN)Checking Terraform formatting...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform fmt -check -recursive
	@echo "$(GREEN)✓ All files are properly formatted$(NC)"

lint: validate fmt-check ## Run all linting checks

##@ Planning

plan: ## Create Terraform execution plan
	@echo "$(GREEN)Creating Terraform plan...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform plan
	@echo "$(GREEN)✓ Plan created$(NC)"

plan-out: ## Create Terraform execution plan and save to file
	@echo "$(GREEN)Creating Terraform plan and saving to file...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform plan -out=tfplan
	@echo "$(GREEN)✓ Plan saved to tfplan$(NC)"

plan-destroy: ## Create Terraform destroy plan
	@echo "$(GREEN)Creating Terraform destroy plan...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform plan -destroy
	@echo "$(GREEN)✓ Destroy plan created$(NC)"

##@ Deployment

apply: ## Apply Terraform configuration (interactive)
	@echo "$(GREEN)Applying Terraform configuration...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform apply
	@echo "$(GREEN)✓ Configuration applied$(NC)"

apply-auto: ## Apply Terraform configuration (auto-approve)
	@echo "$(YELLOW)⚠️  Auto-approving Terraform apply$(NC)"
	@cd $(TERRAFORM_DIR) && terraform apply -auto-approve
	@echo "$(GREEN)✓ Configuration applied$(NC)"

deploy: ## Run full deployment script
	@echo "$(GREEN)Running deployment script...$(NC)"
	@$(SCRIPTS_DIR)/deploy.sh
	@echo "$(GREEN)✓ Deployment completed$(NC)"

##@ Destruction

destroy: ## Destroy Terraform-managed infrastructure (interactive)
	@echo "$(YELLOW)⚠️  Destroying infrastructure...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform destroy
	@echo "$(GREEN)✓ Infrastructure destroyed$(NC)"

destroy-auto: ## Destroy Terraform-managed infrastructure (auto-approve)
	@echo "$(YELLOW)⚠️  Auto-approving Terraform destroy$(NC)"
	@cd $(TERRAFORM_DIR) && terraform destroy -auto-approve
	@echo "$(GREEN)✓ Infrastructure destroyed$(NC)"

cleanup: ## Run full cleanup script
	@echo "$(YELLOW)⚠️  Running cleanup script...$(NC)"
	@$(SCRIPTS_DIR)/cleanup.sh
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

##@ State Management

state-list: ## List all resources in Terraform state
	@echo "$(GREEN)Listing Terraform state resources...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform state list

state-show: ## Show detailed state for a specific resource (usage: make state-show RESOURCE=aws_vpc.main)
	@echo "$(GREEN)Showing state for resource: $(RESOURCE)$(NC)"
	@cd $(TERRAFORM_DIR) && terraform state show $(RESOURCE)

state-pull: ## Pull current state and display
	@echo "$(GREEN)Pulling Terraform state...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform state pull

state-backup: ## Backup current Terraform state
	@echo "$(GREEN)Backing up Terraform state...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform state pull > ../state-backup-$$(date +%Y%m%d-%H%M%S).tfstate
	@echo "$(GREEN)✓ State backed up$(NC)"

##@ Outputs

output: ## Display all Terraform outputs
	@echo "$(GREEN)Displaying Terraform outputs...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform output

output-json: ## Display all Terraform outputs in JSON format
	@echo "$(GREEN)Displaying Terraform outputs (JSON)...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform output -json

output-save: ## Save Terraform outputs to JSON file
	@echo "$(GREEN)Saving Terraform outputs to file...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform output -json > ../outputs-$$(date +%Y%m%d-%H%M%S).json
	@echo "$(GREEN)✓ Outputs saved$(NC)"

##@ Testing

test: ## Run validation tests
	@echo "$(GREEN)Running validation tests...$(NC)"
	@$(SCRIPTS_DIR)/validate.sh
	@echo "$(GREEN)✓ Tests completed$(NC)"

test-alb: ## Test ALB endpoint
	@echo "$(GREEN)Testing ALB endpoint...$(NC)"
	@ALB_DNS=$$(cd $(TERRAFORM_DIR) && terraform output -raw alb_dns_name 2>/dev/null); \
	if [ -n "$$ALB_DNS" ]; then \
		echo "Testing http://$$ALB_DNS"; \
		curl -I "http://$$ALB_DNS"; \
	else \
		echo "$(YELLOW)ALB DNS not found$(NC)"; \
	fi

test-health: ## Test health endpoint
	@echo "$(GREEN)Testing health endpoint...$(NC)"
	@ALB_DNS=$$(cd $(TERRAFORM_DIR) && terraform output -raw alb_dns_name 2>/dev/null); \
	if [ -n "$$ALB_DNS" ]; then \
		echo "Testing http://$$ALB_DNS/health"; \
		curl "http://$$ALB_DNS/health"; \
		echo ""; \
	else \
		echo "$(YELLOW)ALB DNS not found$(NC)"; \
	fi

##@ Diagrams

diagrams-setup: ## Setup Python virtual environment for diagrams
	@echo "$(GREEN)Setting up Python virtual environment...$(NC)"
	@cd $(DIAGRAMS_DIR) && python3 -m venv venv
	@cd $(DIAGRAMS_DIR) && . venv/bin/activate && pip install --upgrade pip
	@cd $(DIAGRAMS_DIR) && . venv/bin/activate && pip install -r requirements.txt
	@echo "$(GREEN)✓ Virtual environment setup complete$(NC)"

diagrams: ## Generate architecture diagrams
	@echo "$(GREEN)Generating architecture diagrams...$(NC)"
	@if [ ! -d "$(VENV)" ]; then \
		echo "$(YELLOW)Virtual environment not found. Running setup...$(NC)"; \
		$(MAKE) diagrams-setup; \
	fi
	@cd $(DIAGRAMS_DIR) && . venv/bin/activate && python3 generate_diagrams.py
	@echo "$(GREEN)✓ Diagrams generated$(NC)"

##@ Cleanup

clean: ## Clean up local Terraform files
	@echo "$(YELLOW)Cleaning up local Terraform files...$(NC)"
	@cd $(TERRAFORM_DIR) && rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup tfplan
	@echo "$(GREEN)✓ Local files cleaned$(NC)"

clean-all: clean ## Clean up all generated files including diagrams
	@echo "$(YELLOW)Cleaning up all generated files...$(NC)"
	@rm -rf $(DIAGRAMS_DIR)/*.png
	@rm -rf $(DIAGRAMS_DIR)/venv
	@rm -f *.log *.tfstate *.json
	@echo "$(GREEN)✓ All generated files cleaned$(NC)"

##@ Workflows

all: init validate fmt plan ## Run full validation workflow
	@echo "$(GREEN)✓ Full validation workflow completed$(NC)"

full-deploy: init validate fmt plan-out apply-auto output ## Run full deployment workflow
	@echo "$(GREEN)✓ Full deployment workflow completed$(NC)"

full-test: test test-alb test-health ## Run all tests
	@echo "$(GREEN)✓ All tests completed$(NC)"

##@ Information

info: ## Display infrastructure information
	@echo "$(GREEN)╔═══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(GREEN)║                                                               ║$(NC)"
	@echo "$(GREEN)║   Infrastructure Information                                  ║$(NC)"
	@echo "$(GREEN)║                                                               ║$(NC)"
	@echo "$(GREEN)╚═══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(BLUE)Project:$(NC) Multi-Tier Web Application Infrastructure"
	@echo "$(BLUE)Terraform Directory:$(NC) $(TERRAFORM_DIR)"
	@echo "$(BLUE)Scripts Directory:$(NC) $(SCRIPTS_DIR)"
	@echo "$(BLUE)Diagrams Directory:$(NC) $(DIAGRAMS_DIR)"
	@echo ""
	@if [ -d "$(TERRAFORM_DIR)/.terraform" ]; then \
		echo "$(GREEN)✓ Terraform initialized$(NC)"; \
	else \
		echo "$(YELLOW)✗ Terraform not initialized (run 'make init')$(NC)"; \
	fi
	@echo ""
	@cd $(TERRAFORM_DIR) && if terraform state list &> /dev/null; then \
		RESOURCE_COUNT=$$(terraform state list | wc -l); \
		echo "$(BLUE)Resources in state:$(NC) $$RESOURCE_COUNT"; \
	else \
		echo "$(YELLOW)No Terraform state found$(NC)"; \
	fi
	@echo ""

version: ## Display tool versions
	@echo "$(GREEN)Tool Versions:$(NC)"
	@echo "$(BLUE)Terraform:$(NC) $$(terraform version | head -n1)"
	@echo "$(BLUE)AWS CLI:$(NC) $$(aws --version)"
	@echo "$(BLUE)Python:$(NC) $$(python3 --version)"
	@echo "$(BLUE)Make:$(NC) $$(make --version | head -n1)"

##@ Documentation

docs: ## Open documentation in browser
	@echo "$(GREEN)Opening documentation...$(NC)"
	@if command -v xdg-open &> /dev/null; then \
		xdg-open README.md; \
	elif command -v open &> /dev/null; then \
		open README.md; \
	else \
		echo "$(YELLOW)Please open README.md manually$(NC)"; \
	fi

##@ Quick Commands

quick-deploy: init validate fmt plan-out apply-auto test ## Quick deployment with validation
	@echo "$(GREEN)✓ Quick deployment completed$(NC)"

quick-destroy: plan-destroy destroy-auto ## Quick destruction
	@echo "$(GREEN)✓ Quick destruction completed$(NC)"

refresh: ## Refresh Terraform state
	@echo "$(GREEN)Refreshing Terraform state...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform refresh
	@echo "$(GREEN)✓ State refreshed$(NC)"

graph: ## Generate Terraform dependency graph
	@echo "$(GREEN)Generating Terraform dependency graph...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform graph | dot -Tpng > ../terraform-graph.png
	@echo "$(GREEN)✓ Graph saved to terraform-graph.png$(NC)"

console: ## Open Terraform console
	@echo "$(GREEN)Opening Terraform console...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform console

##@ CI/CD

ci-validate: init validate fmt-check ## CI validation workflow
	@echo "$(GREEN)✓ CI validation completed$(NC)"

ci-plan: init validate fmt-check plan-out ## CI plan workflow
	@echo "$(GREEN)✓ CI plan completed$(NC)"

ci-apply: init validate fmt-check plan-out apply-auto ## CI apply workflow
	@echo "$(GREEN)✓ CI apply completed$(NC)"

ci-test: test ## CI test workflow
	@echo "$(GREEN)✓ CI test completed$(NC)"

