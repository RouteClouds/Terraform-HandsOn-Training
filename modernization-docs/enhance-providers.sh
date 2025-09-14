#!/bin/bash

# AWS Terraform Training Provider Enhancement Script
# Adds default tags and enhanced configurations to provider blocks

echo "🚀 Starting Provider Enhancement..."
echo "=================================="

# Function to enhance provider blocks with default tags
enhance_provider_block() {
    local file="$1"
    local module_name="$2"
    
    # Check if file contains provider "aws" block without default_tags
    if grep -q 'provider "aws"' "$file" && ! grep -q 'default_tags' "$file"; then
        
        # Create a temporary file for the enhanced provider block
        cat > /tmp/enhanced_provider.txt << EOF

  default_tags {
    tags = {
      Environment      = var.environment
      Project          = var.project_name
      ManagedBy        = "terraform"
      TerraformVersion = "1.13.x"
      ProviderVersion  = "6.12.x"
      TrainingModule   = "$module_name"
    }
  }
EOF

        # Insert default_tags before the closing brace of provider block
        sed -i '/provider "aws" {/,/^}$/ {
            /^}$/ {
                i\
  default_tags {\
    tags = {\
      Environment      = var.environment\
      Project          = var.project_name\
      ManagedBy        = "terraform"\
      TerraformVersion = "1.13.x"\
      ProviderVersion  = "6.12.x"\
      TrainingModule   = "'$module_name'"\
    }\
  }
            }
        }' "$file"
        
        echo "✅ Enhanced provider in: $file"
        return 0
    else
        echo "⏭️  Skipped (no provider or already enhanced): $file"
        return 1
    fi
}

# Function to determine module name from file path
get_module_name() {
    local file_path="$1"
    
    if [[ "$file_path" == *"01-introduction-to-iac"* ]]; then
        echo "01-introduction-to-iac"
    elif [[ "$file_path" == *"02-terraform-setup"* ]]; then
        echo "02-terraform-setup"
    elif [[ "$file_path" == *"03-terraform-basics"* ]]; then
        echo "03-terraform-basics"
    elif [[ "$file_path" == *"04-terraform-providers-resources"* ]]; then
        echo "04-terraform-providers-resources"
    elif [[ "$file_path" == *"05-terraform-variables"* ]]; then
        echo "05-terraform-variables"
    elif [[ "$file_path" == *"06-terraform-state"* ]]; then
        echo "06-terraform-state"
    elif [[ "$file_path" == *"07-terraform-modules"* ]]; then
        echo "07-terraform-modules"
    elif [[ "$file_path" == *"08-terraform-state"* ]]; then
        echo "08-terraform-state"
    elif [[ "$file_path" == *"09-terraform-import"* ]]; then
        echo "09-terraform-import"
    elif [[ "$file_path" == *"10-terraform-testing"* ]]; then
        echo "10-terraform-testing"
    elif [[ "$file_path" == *"11-terraform-cicd"* ]]; then
        echo "11-terraform-cicd"
    elif [[ "$file_path" == *"12-terraform-cloud"* ]]; then
        echo "12-terraform-cloud"
    else
        echo "aws-terraform-training"
    fi
}

# Find files with provider blocks that need enhancement
echo "🔍 Finding provider configurations to enhance..."
provider_files=$(find . -name "*.tf" -type f | grep -v modernization-docs | xargs grep -l 'provider "aws"')

total_files=$(echo "$provider_files" | wc -l)
echo "📊 Found $total_files provider configurations"

enhanced_count=0
for file in $provider_files; do
    module_name=$(get_module_name "$file")
    echo "Processing: $file (Module: $module_name)"
    
    if enhance_provider_block "$file" "$module_name"; then
        enhanced_count=$((enhanced_count + 1))
    fi
done

echo ""
echo "🎉 Provider Enhancement Complete!"
echo "================================="
echo "📊 Enhanced $enhanced_count out of $total_files provider configurations"
echo "📋 All providers now include standardized default tags"

# Generate enhancement report
cat > modernization-docs/PROVIDER-ENHANCEMENT-REPORT.md << EOF
# Provider Enhancement Report

## Summary
- **Total Provider Files**: $total_files
- **Enhanced Files**: $enhanced_count
- **Skipped Files**: $((total_files - enhanced_count))

## Enhancements Applied
- ✅ Default tags with training module identification
- ✅ Terraform and provider version tracking
- ✅ Environment and project tagging
- ✅ Managed by Terraform identification

## Default Tags Added
\`\`\`hcl
default_tags {
  tags = {
    Environment      = var.environment
    Project          = var.project_name
    ManagedBy        = "terraform"
    TerraformVersion = "1.13.x"
    ProviderVersion  = "6.12.x"
    TrainingModule   = "[module-specific]"
  }
}
\`\`\`

### Date: $(date)
### Status: ✅ COMPLETED
EOF

echo "📄 Enhancement report created: modernization-docs/PROVIDER-ENHANCEMENT-REPORT.md"
