# Lab Diagrams for Terraform State Management

This directory contains Diagrams as Code (DaC) for visualizing the lab exercises in Chapter 06 - Terraform State Management.

## Overview

### Lab 1: Basic State Management and Backend Configuration
- **File:** `06-lab1-diagram.py`
- **Output:** `generated/lab1_backend_setup.png`
- **Description:** Illustrates the basic state management setup with:
  - Terraform Configuration
  - Backend Infrastructure (S3 + DynamoDB)
  - Test Infrastructure (VPC + Subnet)
  - State Storage and Locking Relationships

### Lab 2: State Operations and Manipulation
- **File:** `06-lab2-diagram.py`
- **Output:** `generated/lab2_state_operations.png`
- **Description:** Shows state operation flows including:
  - State Management Commands
  - Infrastructure Resources
  - State File Relationships
  - Resource Dependencies

### Lab 3: Advanced State Management with Workspaces
- **File:** `06-lab3-diagram.py`
- **Output:** `generated/lab3_workspaces.png`
- **Description:** Demonstrates workspace-based management with:
  - Multiple Environment Configurations
  - State File Organization
  - Resource Isolation
  - Backend Integration

## Directory Structure
plaintext
06-labs-diagrams/
├── README.md
├── 06-lab1-diagram.py
├── 06-lab2-diagram.py
├── 06-lab3-diagram.py
└── generated/
    ├── lab1_backend_setup.png
    ├── lab2_state_operations.png
    └── lab3_workspaces.png
```

## Usage

### Prerequisites
1. Install required packages:
```bash
pip install diagrams
pip install graphviz
```

2. Ensure Graphviz is installed:
```bash
# Ubuntu/Debian
sudo apt-get install graphviz

# macOS
brew install graphviz

# Windows
choco install graphviz
```

### Generate Diagrams

1. Generate Lab 1 Diagram:
```bash
python3 06-lab1-diagram.py
```
- Shows backend setup and state storage
- Illustrates state locking mechanism
- Demonstrates test infrastructure

2. Generate Lab 2 Diagram:
```bash
python3 06-lab2-diagram.py
```
- Visualizes state operations
- Shows resource relationships
- Illustrates state manipulation

3. Generate Lab 3 Diagram:
```bash
python3 06-lab3-diagram.py
```
- Demonstrates workspace management
- Shows environment isolation
- Illustrates state organization

### Diagram Components

#### Lab 1 Components:
- Terraform Configuration
- S3 Bucket (State Storage)
- DynamoDB Table (State Locking)
- VPC and Subnet (Test Infrastructure)

#### Lab 2 Components:
- State Operations
- Network Resources
- Security Groups
- Resource Dependencies

#### Lab 3 Components:
- Development Workspace
- Production Workspace
- Backend Configuration
- Network Resources per Environment

## Customization

### Graph Attributes
All diagrams use consistent styling:
```python
graph_attr = {
    "fontsize": "20",
    "bgcolor": "white",
    "pad": "0.75"
}
```

### Color Scheme
- Blue: State relationships
- Red: Lock operations
- Black: Resource relationships

## Troubleshooting

### Common Issues
1. **Missing Output Directory:**
   - The script automatically creates the `generated` directory
   - Ensure write permissions in the current directory

2. **Import Errors:**
   - Verify all required packages are installed
   - Check Python version compatibility

3. **Graphviz Errors:**
   - Verify Graphviz installation
   - Check system PATH configuration

## Maintenance

### Adding New Diagrams
1. Create new Python file following naming convention
2. Import required components
3. Define diagram structure
4. Add to documentation

### Updating Existing Diagrams
1. Modify respective Python file
2. Update documentation if needed
3. Regenerate diagram

## Notes
- Diagrams are automatically saved in PNG format
- Each diagram uses appropriate direction (LR/TB) for best visibility
- Components are grouped logically in clusters
- Relationships are clearly labeled

## References
- [Diagrams Documentation](https://diagrams.mingrammer.com/)
- [Graphviz Documentation](https://graphviz.org/documentation/)
- [Terraform Documentation](https://www.terraform.io/docs)
```