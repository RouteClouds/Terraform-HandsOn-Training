# Introduction to Infrastructure Automation - Labs

## Lab 1: Setting Up Your First Infrastructure as Code Environment
### Duration: 45 minutes

### Prerequisites
- Git installed
- Text editor (VS Code recommended)
- AWS account (free tier)
- Basic command line knowledge

### Lab Objectives
- Set up a version-controlled IaC environment
- Create basic infrastructure definition files
- Understand file organization
- Implement basic version control

### Steps

#### 1. Environment Setup
```bash
# Create project directory
mkdir first-iac-project
cd first-iac-project

# Initialize git repository
git init

# Create basic structure
mkdir terraform
cd terraform
```

#### 2. Create Basic Infrastructure Files
```bash
# Create main configuration file
cat > main.tf <<EOF
# This is your first Infrastructure as Code file
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = "us-east-1"
}
EOF

# Create gitignore file
cat > .gitignore <<EOF
.terraform
*.tfstate
*.tfstate.backup
.terraform.lock.hcl
EOF
```

#### 3. Version Control Implementation
```bash
# Add files to git
git add .
git commit -m "Initial infrastructure setup"

# Create development branch
git checkout -b development
```

### Validation
- Verify directory structure:
```bash
tree .
```
Expected output:
```
.
├── .git/
├── terraform/
│   ├── main.tf
│   └── .gitignore
```

- Verify git configuration:
```bash
git status
git branch
```

### Troubleshooting
| Problem | Solution |
|---------|----------|
| Git not initialized | Run `git init` in project root |
| Files not tracked | Check .gitignore contents |

## Lab 2: Infrastructure Documentation and Collaboration
### Duration: 60 minutes

### Prerequisites
- Completed Lab 1
- Basic Markdown knowledge
- GitHub account

### Lab Objectives
- Create comprehensive infrastructure documentation
- Implement collaboration practices
- Set up automated documentation

### Steps

#### 1. Create Documentation Structure
```bash
# Create documentation directory
mkdir docs
cd docs

# Create main documentation file
cat > infrastructure.md <<EOF
# Infrastructure Documentation

## Overview
This document describes our infrastructure setup.

## Components
1. AWS Provider Configuration
2. Basic Resource Setup
3. Security Considerations

## Implementation Details
[Add implementation details here]
EOF
```

#### 2. Set Up Automated Documentation
Create a documentation generation script:
```bash
#!/bin/bash
# doc-generator.sh

echo "Generating Infrastructure Documentation"
echo "=====================================>"

# Generate provider documentation
echo "## Provider Configuration" > provider-doc.md
grep -h "provider" ../terraform/*.tf >> provider-doc.md

# Generate resource documentation
echo "## Resource Configuration" > resource-doc.md
grep -h "resource" ../terraform/*.tf >> resource-doc.md
```

#### 3. Implement Collaboration Guidelines
Create contribution guidelines:
```bash
cat > CONTRIBUTING.md <<EOF
# Contribution Guidelines

## Code Review Process
1. Create feature branch
2. Make changes
3. Submit pull request
4. Peer review
5. Merge to main

## Documentation Standards
- Use clear descriptions
- Include examples
- Document all variables
EOF
```

### Validation
1. Check documentation structure:
```bash
tree docs/
```

2. Test documentation generation:
```bash
chmod +x doc-generator.sh
./doc-generator.sh
```

3. Verify contribution guidelines:
```bash
cat CONTRIBUTING.md
```

### Lab Files
All lab files are available in:
`iac-manifests/lab1/` and `iac-manifests/lab2/`

### Reference Diagrams
- Lab 1 Setup Flow: See `iac-diagrams/labs/lab1_setup.py`
- Lab 2 Documentation Flow: See `iac-diagrams/labs/lab2_documentation.py`
