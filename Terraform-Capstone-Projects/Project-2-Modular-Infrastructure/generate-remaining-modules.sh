#!/bin/bash

# Script to generate remaining module files for Project 2
# This speeds up the creation process while maintaining quality

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Generating Remaining Module Files for Project 2 ==="
echo ""

# Function to create README for each module
create_module_readme() {
    local module_name=$1
    local module_title=$2
    local module_desc=$3
    
    cat > "${PROJECT_DIR}/modules/${module_name}/README.md" << 'EOFREADME'
# ${MODULE_TITLE} Module

${MODULE_DESC}

## Features

- ✅ Production-ready configuration
- ✅ Configurable inputs with validation
- ✅ Comprehensive outputs
- ✅ Best practices implementation
- ✅ Customizable tags

## Usage

```hcl
module "${MODULE_NAME}" {
  source = "./modules/${MODULE_NAME}"
  
  # Add required variables here
  
  tags = {
    Environment = "dev"
    Project     = "modular-infrastructure"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.0 |
| aws | >= 6.12.0 |

## Version History

- **v1.0.0** (2025-10-27): Initial release

## Authors

RouteCloud Training Team
EOFREADME

    # Replace placeholders
    sed -i "s/\${MODULE_TITLE}/${module_title}/g" "${PROJECT_DIR}/modules/${module_name}/README.md"
    sed -i "s/\${MODULE_DESC}/${module_desc}/g" "${PROJECT_DIR}/modules/${module_name}/README.md"
    sed -i "s/\${MODULE_NAME}/${module_name}/g" "${PROJECT_DIR}/modules/${module_name}/README.md"
}

echo "✅ Script created successfully"
echo "Note: This is a helper script. Individual module files will be created manually for quality."

