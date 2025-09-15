# Diagram as Code (DaC) - Core Terraform Operations

## 🎯 Overview

This directory contains **Diagram as Code (DaC)** implementation for **Topic 3: Core Terraform Operations**. The Python-based diagram generation system creates professional, high-resolution architectural diagrams that illustrate core Terraform workflow concepts and operational patterns.

## 📊 Generated Diagrams

### **Figure 3.1: Terraform Core Workflow**
- **Purpose**: Illustrates the complete Terraform workflow from initialization to destruction
- **Content**: Developer interactions, core operations (init/plan/apply/destroy), infrastructure components, state management
- **Use Case**: Understanding the fundamental Terraform workflow and operation sequence

### **Figure 3.2: Resource Lifecycle States**
- **Purpose**: Shows the complete lifecycle of Terraform resources from creation to destruction
- **Content**: Lifecycle phases, state transitions, meta-arguments, Terraform operations
- **Use Case**: Understanding resource management and lifecycle control patterns

### **Figure 3.3: Dependency Graph Example**
- **Purpose**: Demonstrates implicit and explicit dependencies in Terraform configurations
- **Content**: VPC infrastructure, networking components, compute resources, dependency relationships
- **Use Case**: Understanding dependency management and resource ordering

### **Figure 3.4: Performance Optimization**
- **Purpose**: Shows performance optimization strategies for Terraform operations
- **Content**: Parallelism control, provider caching, resource targeting, state optimization
- **Use Case**: Implementing performance improvements for large-scale deployments

### **Figure 3.5: Error Recovery Patterns**
- **Purpose**: Illustrates common error scenarios and recovery strategies
- **Content**: Error types, recovery actions, validation steps, monitoring approaches
- **Use Case**: Troubleshooting and recovering from common Terraform operational issues

## 🚀 Quick Start

### **Prerequisites**
```bash
# System dependencies (choose your OS)
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y graphviz python3-pip

# RHEL/CentOS/Fedora
sudo yum install -y graphviz python3-pip

# macOS
brew install graphviz python3

# Windows (using Chocolatey)
choco install graphviz python3
```

### **Installation**
```bash
# Navigate to DaC directory
cd 03-Core-Terraform-Operations/DaC

# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Verify installation
python -c "import diagrams; print('✅ Diagrams library installed successfully')"
```

### **Generate Diagrams**
```bash
# Generate all diagrams
python diagram_generation_script.py

# Check output
ls -la generated_diagrams/
```

## 📁 Directory Structure

```
DaC/
├── diagram_generation_script.py    # Main diagram generation script
├── requirements.txt                # Python dependencies
├── README.md                      # This documentation
├── .gitignore                     # Git ignore patterns
└── generated_diagrams/            # Output directory
    ├── README.md                  # Diagram documentation
    ├── core_workflow.png          # Figure 3.1
    ├── resource_lifecycle.png     # Figure 3.2
    ├── dependency_graph.png       # Figure 3.3
    ├── performance_optimization.png # Figure 3.4
    └── error_recovery.png         # Figure 3.5
```

## 🔧 Technical Specifications

### **Diagram Library**
- **Framework**: Python `diagrams` library v0.23.4
- **Backend**: Graphviz for rendering
- **Format**: PNG with 300 DPI for professional quality
- **Style**: Clean, professional AWS architecture style

### **Icon Sets Used**
- **AWS Icons**: VPC, EC2, S3, ELB, Internet Gateway, CloudWatch
- **Generic Icons**: Operations, workflows, states, processes
- **Custom Elements**: Terraform-specific operations and concepts

### **Quality Standards**
- **Resolution**: 300 DPI for print-quality output
- **Color Scheme**: Professional blue/orange AWS color palette
- **Typography**: Arial font family for consistency
- **Layout**: Logical flow with clear relationships and state transitions

## 🎨 Customization Guide

### **Modifying Diagrams**
```python
# Example: Adding a new operation to Figure 3.1
def generate_core_workflow():
    with Diagram("Figure 3.1: Terraform Core Workflow", ...):
        # Add new operation
        validate_cmd = General("terraform validate")
        
        # Connect to existing flow
        developer >> validate_cmd >> plan_cmd
```

### **Adding New Diagrams**
```python
def generate_new_diagram():
    """Generate a new custom diagram."""
    with Diagram("New Diagram Title", ...):
        # Define components
        operation1 = General("Operation 1")
        operation2 = General("Operation 2")
        
        # Define relationships
        operation1 >> operation2
```

### **Styling Options**
```python
# Custom graph attributes
graph_attr = {
    "dpi": "300",           # High resolution
    "bgcolor": "white",     # Background color
    "fontname": "Arial",    # Font family
    "fontsize": "16",       # Font size
    "rankdir": "TB",        # Direction (TB/LR)
    "splines": "ortho"      # Edge style
}
```

## 🔍 Troubleshooting

### **Common Issues**

#### **Graphviz Not Found**
```bash
# Error: "graphviz executables not found"
# Solution: Install system Graphviz package
sudo apt-get install graphviz  # Ubuntu/Debian
sudo yum install graphviz       # RHEL/CentOS
brew install graphviz           # macOS
```

#### **Permission Errors**
```bash
# Error: Permission denied writing to output directory
# Solution: Check directory permissions
chmod 755 generated_diagrams/
```

#### **Import Errors**
```bash
# Error: "No module named 'diagrams'"
# Solution: Ensure virtual environment is activated and dependencies installed
source venv/bin/activate
pip install -r requirements.txt
```

### **Debugging**
```bash
# Enable verbose output
python diagram_generation_script.py --verbose

# Check Graphviz installation
dot -V

# Test basic diagram generation
python -c "
from diagrams import Diagram
from diagrams.aws.compute import EC2
with Diagram('Test', show=False):
    EC2('Test')
print('✅ Basic diagram generation works')
"
```

## 📈 Performance Optimization

### **Batch Generation**
```python
# Generate multiple diagrams efficiently
diagrams_to_generate = [
    generate_core_workflow,
    generate_resource_lifecycle,
    generate_dependency_graph,
    generate_performance_optimization,
    generate_error_recovery
]

for diagram_func in diagrams_to_generate:
    try:
        diagram_func()
        print(f"✅ {diagram_func.__name__} completed")
    except Exception as e:
        print(f"❌ {diagram_func.__name__} failed: {e}")
```

### **Memory Management**
```python
# For large diagrams, consider memory optimization
import gc

def generate_large_diagram():
    # Generate diagram
    with Diagram(...):
        # Diagram content
        pass
    
    # Force garbage collection
    gc.collect()
```

## 🔄 Integration with Documentation

### **Markdown Integration**
```markdown
# Reference diagrams in documentation
![Terraform Core Workflow](../DaC/generated_diagrams/core_workflow.png)
*Figure 3.1: Terraform Core Workflow*
```

### **Automated Updates**
```bash
# Add to CI/CD pipeline
#!/bin/bash
cd DaC/
python diagram_generation_script.py
git add generated_diagrams/
git commit -m "Update diagrams for Topic 3"
```

## 📚 Educational Value

### **Learning Objectives Supported**
- **Visual Learning**: Complex workflows illustrated through clear diagrams
- **Process Understanding**: Step-by-step operation flows and state transitions
- **Best Practices**: Visual representation of optimization and recovery patterns
- **Troubleshooting**: Clear error scenarios and resolution paths

### **Instructor Resources**
- **High-resolution diagrams** suitable for presentations
- **Editable source code** for customization
- **Consistent styling** across all training materials
- **Professional quality** appropriate for enterprise training

## 🔗 Related Resources

### **Documentation References**
- [Terraform Core Workflow Documentation](https://developer.hashicorp.com/terraform/intro/core-workflow)
- [Terraform Resource Lifecycle](https://developer.hashicorp.com/terraform/language/resources/behavior)
- [Diagrams Library Documentation](https://diagrams.mingrammer.com/)
- [Graphviz Documentation](https://graphviz.org/documentation/)

### **Training Materials**
- **Concept.md**: Theoretical foundation for diagram concepts
- **Lab-3.md**: Hands-on implementation of diagrammed workflows
- **Terraform-Code-Lab-3.1/**: Practical code examples

---

**DaC Version**: 3.0  
**Last Updated**: January 2025  
**Python Version**: 3.9+  
**Diagrams Library**: 0.23.4  
**Quality**: Professional (300 DPI)
