# Terraform Basics - Theory Diagrams

This directory contains the Diagrams as Code (DaC) for visualizing the theoretical concepts of Terraform basics.

## Diagram Types

### 1. Terraform Basic Workflow
- Illustrates the core Terraform commands
- Shows the lifecycle of Terraform operations
- Demonstrates the workflow sequence

### 2. HCL Configuration Structure
- Shows the relationship between different configuration files
- Illustrates file dependencies
- Demonstrates configuration organization

### 3. Resource Dependencies
- Visualizes resource relationships
- Shows implicit and explicit dependencies
- Demonstrates AWS resource hierarchy

### 4. Variable Types and Usage
- Illustrates different variable types
- Shows variable relationships
- Demonstrates variable organization

### 5. State Management
- Shows state storage options
- Illustrates state operations
- Demonstrates state workflow

### 6. Best Practices
- Visualizes development workflow
- Shows organizational best practices
- Demonstrates security considerations

## Usage

1. Generate diagrams:
```bash
python terraform_basics_concepts.py
```

2. Generated files:
- terraform_workflow.png
- hcl_structure.png
- resource_dependencies.png
- variable_types.png
- state_management.png
- best_practices.png

## Directory Structure
```plaintext
theory/
├── terraform_basics_concepts.py
├── README.md
└── generated/
    ├── terraform_workflow.png
    ├── hcl_structure.png
    ├── resource_dependencies.png
    ├── variable_types.png
    ├── state_management.png
    └── best_practices.png
```

## Diagram Relationships
1. Workflow → Configuration
2. Configuration → Resources
3. Resources → Variables
4. Variables → State
5. State → Best Practices

## Best Practices
- Keep diagrams focused and clear
- Use consistent naming
- Group related components
- Show clear relationships 