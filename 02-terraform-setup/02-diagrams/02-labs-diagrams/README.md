# Lab Diagrams for Terraform Setup

This directory contains the Diagrams as Code (DaC) for all labs in the Terraform Setup topic.

## Diagrams Overview

### Lab 1: Basic Environment Setup
- Shows the relationship between local development tools and AWS resources
- Illustrates the initial setup and authentication flow
- Demonstrates test resource creation

### Lab 2: Development Environment
- Visualizes the VPC infrastructure setup
- Shows networking components and their relationships
- Illustrates the development environment architecture

### Lab 3: Backend Configuration
- Depicts the state management infrastructure
- Shows the relationship between Terraform and backend services
- Illustrates state locking mechanism

### Lab 4: Workspace Management
- Shows the modular structure of the environment
- Illustrates multiple environment configurations
- Demonstrates workspace relationships

## Usage

1. Install required Python packages:
```bash
pip install diagrams
```

2. Generate diagrams:
```bash
python terraform-setup_lab.py
```

3. Generated files:
- lab1_basic_setup.png
- lab2_dev_environment.png
- lab3_backend_config.png
- lab4_workspace_setup.png

## Directory Structure
```plaintext
setup-diagrams/
├── labs/
│   ├── terraform-setup_lab.py
│   ├── README.md
│   └── generated/
│       ├── lab1_basic_setup.png
│       ├── lab2_dev_environment.png
│       ├── lab3_backend_config.png
│       └── lab4_workspace_setup.png
``` 