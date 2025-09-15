# Terraform Code Lab 7.1: Modules and Module Development

## 📋 Overview

This lab provides comprehensive hands-on experience with **Terraform module development, composition, and best practices**. You'll learn to create reusable modules, implement testing strategies, manage module registries, and establish enterprise governance patterns.

## 🎯 Learning Objectives

By completing this lab, you will:
- Design and develop reusable Terraform modules
- Implement module composition and dependency management
- Create comprehensive testing strategies for modules
- Establish module registry and distribution patterns
- Apply enterprise governance and compliance frameworks
- Master module versioning and lifecycle management

## 🏗️ Architecture Overview

This lab creates:
- **Module Examples**: VPC, Security Group, EC2, S3, and RDS modules
- **Testing Infrastructure**: Automated testing environments and frameworks
- **Module Registry**: Private registry simulation for module distribution
- **Governance Framework**: Security scanning, compliance checking, and audit trails
- **Multi-Region Setup**: Cross-region module testing capabilities

## 📁 File Structure

```
Terraform-Code-Lab-7.1/
├── providers.tf                 # Provider and backend configuration
├── variables.tf                 # Variable definitions with validation
├── main.tf                     # Main infrastructure and module examples
├── outputs.tf                  # Output values and integration data
├── data.tf                     # Data sources and external references
├── locals.tf                   # Local values and calculations
├── terraform.tfvars.example    # Example variable configurations
├── README.md                   # This documentation
├── modules/                    # Module development directory
│   ├── vpc/                    # VPC module example
│   ├── security-group/         # Security group module example
│   ├── ec2-instance/          # EC2 instance module example
│   ├── s3-bucket/             # S3 bucket module example
│   └── rds-database/          # RDS database module example
├── templates/                  # Configuration templates
│   ├── user_data.sh           # EC2 user data script
│   ├── module_readme.md       # Module documentation template
│   └── module_variables.tf    # Module variables template
└── tests/                     # Module testing framework
    ├── unit/                  # Unit tests for individual modules
    ├── integration/           # Integration tests for module composition
    └── e2e/                   # End-to-end tests for complete infrastructure
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform 1.13.0+** installed
3. **Python 3.9+** for testing frameworks
4. **Git** for version control
5. **Testing tools** (optional): Terratest, Kitchen-Terraform

### Required AWS Permissions

Your AWS credentials need the following permissions:
- EC2: Full access for compute module development
- VPC: Full access for networking module development
- S3: Full access for storage module development
- RDS: Full access for database module development
- IAM: Role and policy management for module security
- CloudWatch: Monitoring and logging for module operations

### Step 1: Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd 07-Modules-and-Module-Development/Terraform-Code-Lab-7.1

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit variables for your environment
nano terraform.tfvars
```

### Step 2: Configure Variables

Edit `terraform.tfvars` with your specific values:

```hcl
# Basic Configuration
project_name = "your-modules-project"
environment = "development"
owner = "your-name"
aws_region = "us-east-1"

# Module Development
module_development_mode = true
enable_module_testing = true
module_version = "1.0.0"

# Email for notifications
notification_email = "your-email@example.com"

# Budget limit (USD)
budget_limit = 200
```

### Step 3: Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

## 🔧 Module Development Workflow

### Creating a New Module

1. **Create Module Directory Structure**
```bash
mkdir -p modules/my-module
cd modules/my-module

# Create module files
touch main.tf variables.tf outputs.tf README.md
```

2. **Define Module Interface**
```hcl
# variables.tf
variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# outputs.tf
output "resource_id" {
  description = "ID of the created resource"
  value       = aws_resource.example.id
}
```

3. **Implement Module Logic**
```hcl
# main.tf
resource "aws_resource" "example" {
  name = var.name
  
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

### Module Testing Strategy

1. **Unit Testing**
```bash
# Test individual module syntax
terraform -chdir=modules/vpc validate

# Test module formatting
terraform -chdir=modules/vpc fmt -check
```

2. **Integration Testing**
```bash
# Test module composition
terraform plan -target=module.vpc_example
terraform plan -target=module.ec2_instance_example
```

3. **End-to-End Testing**
```bash
# Deploy complete infrastructure
terraform apply

# Validate functionality
terraform output
```

## 📚 Module Examples

### VPC Module Usage

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_name        = "my-project"
  environment         = "development"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  enable_nat_gateway = true
  enable_dns_hostnames = true
  
  tags = {
    Owner = "platform-team"
  }
}
```

### Security Group Module Usage

```hcl
module "web_security_group" {
  source = "./modules/security-group"
  
  vpc_id = module.vpc.vpc_id
  
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    }
  ]
}
```

### EC2 Instance Module Usage

```hcl
module "web_servers" {
  source = "./modules/ec2-instance"
  
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.web_security_group.security_group_id
  
  instance_type    = "t3.medium"
  min_size        = 2
  max_size        = 10
  desired_capacity = 4
  
  enable_detailed_monitoring = true
}
```

## 🧪 Testing Framework

### Automated Testing

```bash
# Run all tests
make test

# Run specific test suite
make test-unit
make test-integration
make test-e2e

# Run security scanning
make security-scan

# Run compliance checking
make compliance-check
```

### Manual Testing

```bash
# Test module creation
terraform apply -target=module.vpc_example

# Test module updates
terraform apply -target=module.vpc_example

# Test module destruction
terraform destroy -target=module.vpc_example
```

## 📦 Module Registry

### Local Registry Setup

```bash
# Initialize local registry
aws s3 mb s3://my-terraform-modules

# Upload module
tar -czf vpc-module-1.0.0.tar.gz -C modules/vpc .
aws s3 cp vpc-module-1.0.0.tar.gz s3://my-terraform-modules/vpc/1.0.0/
```

### Module Publishing

```bash
# Tag module version
git tag v1.0.0

# Create release
gh release create v1.0.0

# Publish to registry
terraform login
terraform publish
```

## 🔐 Security and Compliance

### Security Scanning

```bash
# Run security scan
tfsec .

# Run compliance check
checkov -d .

# Run vulnerability assessment
terrascan scan
```

### Compliance Framework

```bash
# Generate compliance report
terraform-compliance -f compliance-rules/ -p terraform.plan

# Audit module usage
terraform state list | grep module

# Review access patterns
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole
```

## 💰 Cost Management

### Cost Estimation

```bash
# Estimate costs
terraform plan -out=plan.out
terraform show -json plan.out | jq '.planned_values.root_module.resources'

# Monitor actual costs
aws ce get-cost-and-usage \
  --time-period Start=2025-01-01,End=2025-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

### Cost Optimization

- Use appropriate instance types for each environment
- Implement lifecycle policies for S3 storage
- Enable auto-scaling for variable workloads
- Use spot instances for non-critical workloads
- Monitor and alert on cost thresholds

## 🔧 Troubleshooting

### Common Issues

#### Module Not Found
```bash
# Error: Module not found
# Solution: Check module source path
terraform get -update
```

#### Circular Dependencies
```bash
# Error: Cycle in module dependencies
# Solution: Review module composition
terraform graph | dot -Tpng > dependency-graph.png
```

#### Version Conflicts
```bash
# Error: Module version conflict
# Solution: Update version constraints
terraform init -upgrade
```

## 🧹 Cleanup Procedures

### Destroy Infrastructure

```bash
# Destroy all resources
terraform destroy

# Destroy specific modules
terraform destroy -target=module.vpc_example
terraform destroy -target=module.ec2_instance_example
```

### Clean Up Registry

```bash
# Remove module artifacts
aws s3 rm s3://my-terraform-modules --recursive

# Delete registry bucket
aws s3 rb s3://my-terraform-modules
```

## 🎯 Key Takeaways

### Technical Mastery
- ✅ Module design and development patterns
- ✅ Module composition and dependency management
- ✅ Testing strategies and automation
- ✅ Registry management and distribution
- ✅ Security and compliance integration

### Business Value
- **Reusability**: Standardized infrastructure components
- **Consistency**: Uniform deployment patterns across environments
- **Quality**: Comprehensive testing and validation
- **Governance**: Security and compliance enforcement
- **Efficiency**: Reduced development time and effort

### Next Steps
- Implement advanced module patterns (meta-modules, module composition)
- Integrate with CI/CD pipelines for automated testing
- Establish enterprise module governance policies
- Explore Terraform Cloud/Enterprise module registry features
- Develop organization-specific module libraries

---

**Lab Completion Time**: 4-5 hours  
**Skill Level**: Intermediate to Advanced  
**Prerequisites Met**: ✅ AWS, Terraform, Module Development  
**Ready for Production**: ✅ Enterprise patterns implemented
