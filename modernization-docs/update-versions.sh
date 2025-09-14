#!/bin/bash

# AWS Terraform Training Modernization Script
# Updates all Terraform files to use standardized versions

echo "🚀 Starting AWS Terraform Training Modernization..."
echo "=================================================="

# Create backup directory
mkdir -p modernization-docs/backups
echo "📁 Created backup directory"

# Function to backup and update a file
update_terraform_file() {
    local file="$1"
    local backup_file="modernization-docs/backups/$(basename "$file").backup"
    
    # Create backup
    cp "$file" "$backup_file"
    
    # Update Terraform version
    sed -i 's/required_version = ">= 1\.0\.0"/required_version = "~> 1.13.0"/g' "$file"
    
    # Update AWS provider version
    sed -i 's/version = "~> 4\.0"/version = "~> 6.12.0"/g' "$file"
    
    # Update random provider version if exists
    sed -i 's/version = "~> 3\.0"/version = "~> 3.6.0"/g' "$file"
    
    echo "✅ Updated: $file"
}

# Function to update provider blocks
update_provider_block() {
    local file="$1"
    
    # Check if file contains provider "aws" block
    if grep -q 'provider "aws"' "$file"; then
        # Update region to us-east-1 if it's using variable
        sed -i 's/region = var\.aws_region/region = "us-east-1"/g' "$file"
        echo "🌍 Updated region in: $file"
    fi
}

# Find and update all Terraform files
echo "🔍 Finding Terraform files..."
terraform_files=$(find . -name "*.tf" -type f | grep -v modernization-docs)

total_files=$(echo "$terraform_files" | wc -l)
echo "📊 Found $total_files Terraform files to update"

counter=0
for file in $terraform_files; do
    counter=$((counter + 1))
    echo "[$counter/$total_files] Processing: $file"
    
    update_terraform_file "$file"
    update_provider_block "$file"
done

echo ""
echo "🎉 Modernization Complete!"
echo "=========================="
echo "📊 Updated $total_files Terraform files"
echo "📁 Backups stored in: modernization-docs/backups/"
echo "🔄 Next steps:"
echo "   1. Review changes with: git diff"
echo "   2. Test configurations with: terraform validate"
echo "   3. Commit changes when satisfied"

# Generate summary report
echo "📋 Generating update summary..."
cat > modernization-docs/UPDATE-SUMMARY.md << EOF
# Terraform Version Update Summary

## Files Updated: $total_files

### Changes Made:
- ✅ Terraform version: \`>= 1.0.0\` → \`~> 1.13.0\`
- ✅ AWS Provider version: \`~> 4.0\` → \`~> 6.12.0\`
- ✅ Random Provider version: \`~> 3.0\` → \`~> 3.6.0\`
- ✅ Region standardization: \`var.aws_region\` → \`"us-east-1"\`

### Backup Location:
All original files backed up to: \`modernization-docs/backups/\`

### Validation Required:
Run \`terraform validate\` in each directory to ensure configurations are valid.

### Date: $(date)
### Status: ✅ COMPLETED
EOF

echo "📄 Summary report created: modernization-docs/UPDATE-SUMMARY.md"
