# Lab 3: Advanced State Management with Workspaces

## Overview
This lab demonstrates advanced state management concepts using Terraform workspaces and environment-specific configurations with modular infrastructure.

## Directory Structure
```plaintext
.
├── modules/
│   └── vpc/                    # VPC module
│       ├── main.tf            # Module resources
│       ├── variables.tf       # Module variables
│       └── outputs.tf         # Module outputs
└── environments/
    ├── development/           # Development environment
    │   ├── main.tf           # Main configuration
    │   ├── variables.tf      # Environment variables
    │   └── outputs.tf        # Environment outputs
    └── production/           # Production environment
        ├── main.tf           # Main configuration
        ├── variables.tf      # Environment variables
        └── outputs.tf        # Environment outputs
```

## Features
- Workspace-based environment management
- Modular infrastructure design
- Environment-specific configurations
- State isolation per environment

## Usage

### 1. Initialize Backend
```bash
# Create backend configuration
cat > backend.hcl <<EOF
bucket         = "terraform-state-xxxxx"
key            = "env/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true
EOF
```

### 2. Create and Select Workspace
```bash
# Create workspaces
terraform workspace new development
terraform workspace new production

# Select workspace
terraform workspace select development
```

### 3. Initialize and Apply
```bash
# Initialize with backend config
terraform init -backend-config=backend.hcl

# Plan and apply
terraform plan
terraform apply
```

### 4. Workspace Operations
```bash
# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Switch workspace
terraform workspace select production
```

## State Management Features

### 1. State Isolation
- Each workspace maintains its own state
- State files are stored in different paths
- Prevents environment conflicts

### 2. Resource Naming
- Resources are prefixed with workspace name
- Ensures unique resource names
- Facilitates resource tracking

### 3. Configuration Variations
- Environment-specific variables
- Conditional resource creation
- Workspace-based tagging

## Best Practices

### 1. Workspace Management
- Use consistent naming conventions
- Document workspace purposes
- Limit workspace access

### 2. State Organization
- Use separate state files per environment
- Implement state locking
- Regular state backups

### 3. Module Usage
- Keep modules environment-agnostic
- Use variables for flexibility
- Document module interfaces

## Troubleshooting

### Common Issues
1. Workspace Selection
```bash
# Verify current workspace
terraform workspace show

# List available workspaces
terraform workspace list
```

2. State Conflicts
```bash
# Force unlock if needed
terraform force-unlock LOCK_ID

# Refresh state
terraform refresh
```

3. Backend Configuration
```bash
# Reconfigure backend
terraform init -reconfigure

# Verify backend config
terraform show
```

## Clean Up
```bash
# Destroy resources in each workspace
terraform workspace select development
terraform destroy

terraform workspace select production
terraform destroy

# Delete workspaces
terraform workspace select default
terraform workspace delete development
terraform workspace delete production
```

## Notes
- Always verify workspace before operations
- Use consistent naming across environments
- Document all workspace-specific configurations
- Regularly validate state files 