# Topic 10: Diagram as Code (DaC)

This directory contains Python scripts that generate professional architecture diagrams for Topic 10 using the **Diagrams** library.

## Files

- **requirements.txt** - Python dependencies
- **testing_workflow_diagram.py** - Terraform testing workflow
- **validation_pipeline_diagram.py** - Validation pipeline stages
- **policy_enforcement_diagram.py** - Policy as Code enforcement
- **generate_all_diagrams.py** - Master generation script

## Installation

### Prerequisites

- Python 3.7+
- Graphviz

### Install Graphviz

**macOS**:
```bash
brew install graphviz
```

**Ubuntu/Debian**:
```bash
sudo apt-get install graphviz
```

**Windows**:
```bash
choco install graphviz
```

### Install Python Dependencies

```bash
pip install -r requirements.txt
```

## Usage

### Generate All Diagrams

```bash
python generate_all_diagrams.py
```

### Generate Individual Diagrams

```bash
python testing_workflow_diagram.py
python validation_pipeline_diagram.py
python policy_enforcement_diagram.py
```

## Output

Diagrams are generated as PNG files:
- `testing_workflow.png` - Testing workflow
- `validation_pipeline.png` - Validation pipeline
- `policy_enforcement.png` - Policy enforcement

## Diagrams Included

### 1. Testing Workflow Diagram
Shows the complete Terraform testing workflow:
- Development phase (code, validate, format)
- Pre-commit hooks
- Version control
- CI/CD pipeline
- Testing phase
- Deployment

### 2. Validation Pipeline Diagram
Illustrates validation pipeline stages:
- Syntax validation
- Linting
- Security scanning
- Policy enforcement
- Testing
- Pass/fail results

### 3. Policy Enforcement Diagram
Demonstrates policy as code enforcement:
- Terraform configuration
- Policy definitions
- Policy evaluation
- Compliance checking
- Deployment decision

## Best Practices

✅ Keep diagrams in version control  
✅ Regenerate diagrams when updating  
✅ Use consistent naming conventions  
✅ Document diagram purposes  
✅ Include in documentation  

## Troubleshooting

**Error: "graphviz not found"**
- Install Graphviz (see Installation section)

**Error: "No module named 'diagrams'"**
- Install dependencies: `pip install -r requirements.txt`

**Diagrams not generating**
- Check Python version (3.7+)
- Verify Graphviz installation
- Check file permissions

---

**DaC Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Ready for Use

