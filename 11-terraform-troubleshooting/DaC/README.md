# Topic 11: Diagram as Code (DaC)

This directory contains Python scripts that generate professional architecture diagrams for Topic 11 using the **Diagrams** library.

## Files

- **requirements.txt** - Python dependencies
- **debugging_workflow_diagram.py** - Terraform debugging workflow
- **error_resolution_flowchart.py** - Error resolution decision tree
- **state_troubleshooting_diagram.py** - State troubleshooting process
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
python debugging_workflow_diagram.py
python error_resolution_flowchart.py
python state_troubleshooting_diagram.py
```

## Output

Diagrams are generated as PNG files:
- `debugging_workflow.png` - Debugging workflow
- `error_resolution_flowchart.png` - Error resolution flowchart
- `state_troubleshooting.png` - State troubleshooting

## Diagrams Included

### 1. Debugging Workflow Diagram
Shows the complete debugging process:
- Problem detection
- Enable debugging
- Collect information
- Analysis
- Resolution
- Verification

### 2. Error Resolution Flowchart
Illustrates error resolution decision tree:
- Syntax errors
- Provider errors
- State errors
- Resource errors
- Verification

### 3. State Troubleshooting Diagram
Demonstrates state troubleshooting:
- State lock issues
- State corruption
- Resource drift
- State mismatch
- Resolution and verification

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

---

**DaC Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Ready for Use

