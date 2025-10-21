# Topic 12: Diagram as Code (DaC)

This directory contains Python scripts that generate professional architecture diagrams for Topic 12 using the **Diagrams** library.

## Files

- **requirements.txt** - Python dependencies
- **secure_vpc_architecture_diagram.py** - Secure VPC reference architecture
- **secrets_management_diagram.py** - Secrets management architecture
- **secure_state_backend_diagram.py** - Secure state backend configuration
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
python secure_vpc_architecture_diagram.py
python secrets_management_diagram.py
python secure_state_backend_diagram.py
```

## Output

Diagrams are generated as PNG files:
- `secure_vpc_architecture.png` - Secure VPC design
- `secrets_management.png` - Secrets management flow
- `secure_state_backend.png` - State backend security

## Diagrams Included

### 1. Secure VPC Architecture Diagram
Shows a secure VPC design with:
- Public subnet with ALB
- Private subnet with application servers
- Private subnet with database
- Security groups with least privilege
- NAT gateway for outbound access

### 2. Secrets Management Diagram
Illustrates secrets management:
- Terraform code with sensitive variables
- AWS Secrets Manager
- KMS encryption
- Application access to secrets

### 3. Secure State Backend Diagram
Demonstrates state backend security:
- S3 bucket for state storage
- KMS encryption
- Versioning enabled
- DynamoDB for state locking
- CloudTrail for audit logging

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

