#!/bin/bash

# Project 1: Multi-Tier Web Application Infrastructure - File Generation Script
# This script generates all required files for Project 1 based on the guidelines

set -e

PROJECT_DIR="Project-1-Multi-Tier-Web-Application"
TERRAFORM_DIR="$PROJECT_DIR/terraform-manifests"
DOCS_DIR="$PROJECT_DIR/docs"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
DIAGRAMS_DIR="$PROJECT_DIR/diagrams"

echo "========================================="
echo "Generating Project 1 Files"
echo "========================================="

# Ensure directories exist
mkdir -p "$TERRAFORM_DIR" "$DOCS_DIR" "$SCRIPTS_DIR" "$DIAGRAMS_DIR"

echo "✓ Directories created"

# Generate .gitignore
cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
*.tfvars.backup
.terraform.lock.hcl
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Python
venv/
__pycache__/
*.pyc
*.pyo
*.egg-info/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Diagrams
diagrams/*.png
!diagrams/README.md
EOF

echo "✓ .gitignore created"

# Generate .terraform-version
echo "1.13.0" > "$PROJECT_DIR/.terraform-version"
echo "✓ .terraform-version created"

echo ""
echo "========================================="
echo "Project 1 Basic Files Generated"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Review terraform-manifests/ files"
echo "2. Generate diagrams with: cd diagrams && python3 generate_diagrams.py"
echo "3. Review documentation in docs/"
echo "4. Test scripts in scripts/"
echo "5. Run: make init && make plan"
echo ""

