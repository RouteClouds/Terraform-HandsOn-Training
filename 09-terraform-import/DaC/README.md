# Topic 9: Diagram as Code (DaC)

This directory contains Python scripts that generate professional architecture diagrams for Topic 9 using the **Diagrams** library.

## Overview

Diagrams as Code (DaC) allows you to create and version-control infrastructure diagrams programmatically. All diagrams are generated from Python code, making them reproducible and maintainable.

## Files

- **requirements.txt** - Python dependencies
- **import_workflow_diagram.py** - Terraform import workflow diagram
- **state_file_structure_diagram.py** - State file structure and organization
- **migration_patterns_diagram.py** - Resource migration patterns
- **generate_all_diagrams.py** - Master script to generate all diagrams

## Installation

### Prerequisites

- Python 3.7+
- Graphviz (required by Diagrams library)

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
# Import workflow
python import_workflow_diagram.py

# State file structure
python state_file_structure_diagram.py

# Migration patterns
python migration_patterns_diagram.py
```

## Output

Diagrams are generated as PNG files:
- `import_workflow.png` - Terraform import workflow
- `state_file_structure.png` - State file structure
- `migration_patterns.png` - Migration patterns

## Diagrams Included

### 1. Import Workflow Diagram
Shows the complete Terraform import process:
- Existing AWS infrastructure
- Terraform configuration
- Import process
- Verification steps
- Version control integration

### 2. State File Structure Diagram
Illustrates Terraform state organization:
- Local state files
- State file contents (version, serial, lineage)
- Resource entries and attributes
- Remote state options (S3, DynamoDB)
- Version control considerations

### 3. Migration Patterns Diagram
Demonstrates different migration scenarios:
- Single resource migration
- Dependent resources migration
- Workspace migration
- Disaster recovery patterns

## Customization

To modify diagrams, edit the Python scripts:

```python
# Example: Change diagram title
with Diagram("Custom Title", filename="custom_name", ...):
    # diagram content
```

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

## Integration with Documentation

Include generated diagrams in documentation:

```markdown
![Import Workflow](DaC/import_workflow.png)
```

## Additional Resources

- [Diagrams Library Documentation](https://diagrams.mingrammer.com/)
- [AWS Icons Available](https://diagrams.mingrammer.com/docs/guides/diagram)
- [Graphviz Documentation](https://graphviz.org/)

---

**DaC Version**: 1.0  
**Last Updated**: October 21, 2025  
**Status**: Ready for Use

