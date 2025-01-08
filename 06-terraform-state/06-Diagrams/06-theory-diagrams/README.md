# Terraform State Management - Theory Diagrams

This directory contains the Diagrams as Code (DaC) for visualizing Terraform state management concepts.

## Generated Diagrams

### 1. State Management Overview (01_state_overview.png)
- Shows basic state file structure
- Illustrates relationship between Terraform and resources
- Demonstrates metadata and dependency tracking

### 2. State Storage Options (02_storage_options.png)
- Compares local and remote state storage
- Shows AWS backend configuration
- Illustrates other backend options

### 3. State Operations Flow (03_state_operations.png)
- Visualizes state commands
- Shows state file interaction
- Demonstrates resource management

### 4. State Locking Mechanism (04_state_locking.png)
- Illustrates team collaboration
- Shows locking mechanism
- Demonstrates concurrent access handling

### 5. Enterprise State Management (05_enterprise_setup.png)
- Shows multi-environment setup
- Illustrates state isolation
- Demonstrates enterprise-scale configuration

## Usage

1. Ensure prerequisites are installed:
```bash
pip install diagrams
```

2. Generate diagrams:
```bash
python 06_concepts.py
```

3. Find generated PNG files in the `generated/` directory.

## Requirements
- Python 3.7+
- diagrams library
- Graphviz 