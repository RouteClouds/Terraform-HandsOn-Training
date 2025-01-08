# Terraform Basics - Lab Diagrams

This directory contains the Diagrams as Code (DaC) for visualizing the lab exercises in the Terraform Basics module.

## Diagram Types

### 1. Lab 1: Basic Commands
- Illustrates Terraform command workflow
- Shows S3 bucket creation process
- Demonstrates basic resource management

### 2. Lab 2: Variables and VPC
- Shows variable usage in Terraform
- Illustrates VPC and subnet creation
- Demonstrates network configuration

### 3. Lab 3: Resource Dependencies
- Visualizes resource dependency chains
- Shows complete VPC infrastructure
- Demonstrates security and compute resources

### 4. Lab 4: State Management
- Illustrates state backend configuration
- Shows state locking mechanism
- Demonstrates state tracking for resources

### 5. Labs Overview
- Shows progression between labs
- Illustrates learning path
- Demonstrates skill building sequence

## Generated Files

The script generates the following diagrams:
- lab1_basic_commands.png
- lab2_variables_vpc.png
- lab3_resource_dependencies.png
- lab4_state_management.png
- labs_overview.png

## Directory Structure
```plaintext
labs/
├── terraform_basics_labs.py
├── README.md
└── generated/
    ├── lab1_basic_commands.png
    ├── lab2_variables_vpc.png
    ├── lab3_resource_dependencies.png
    ├── lab4_state_management.png
    └── labs_overview.png
```

## Usage

1. Generate all diagrams:
```bash
python terraform_basics_labs.py
```

2. View generated diagrams in the `generated/` directory

## Diagram Relationships

1. Lab 1 → Lab 2: Basic commands to variable usage
2. Lab 2 → Lab 3: Simple VPC to complex infrastructure
3. Lab 3 → Lab 4: Resource management to state management

## Best Practices
- Keep diagrams focused on key concepts
- Use consistent naming conventions
- Group related components
- Show clear relationships
- Include relevant labels 