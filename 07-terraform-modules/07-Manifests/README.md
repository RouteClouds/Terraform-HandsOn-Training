# Terraform Modules - Lab Manifests

This directory contains the Terraform configurations for the hands-on labs demonstrating module concepts and best practices.

## Lab Structure

```plaintext
07-Manifests/
├── 07-lab1-manifests/          # Basic Module Usage
├── 07-lab2-manifests/          # Custom Module Creation
└── 07-lab3-manifests/          # Module Composition
```

## Lab 1: Basic Module Usage

### Overview
Demonstrates how to use public registry modules with proper configuration and best practices.

### Directory Structure
```plaintext
07-lab1-manifests/
├── main.tf           # VPC module configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output definitions
├── backend.tf        # Backend configuration
└── terraform.tfvars  # Variable values
```

### Features
- AWS VPC module usage
- Multi-AZ subnet configuration
- NAT Gateway setup
- DNS configuration
- VPC Flow Logs (optional)

### Usage
```bash
cd 07-lab1-manifests
terraform init
terraform plan
terraform apply
```

## Lab 2: Custom Module Creation

### Overview
Demonstrates how to create and use a custom EC2 instance module with enhanced features.

### Directory Structure
```plaintext
07-lab2-manifests/
├── modules/
│   └── aws-ec2-instance/          # Custom EC2 Instance Module
│       ├── main.tf                # Instance configuration
│       ├── variables.tf           # Module variables
│       ├── outputs.tf             # Module outputs
│       ├── versions.tf            # Version constraints
│       └── README.md              # Module documentation
└── root/                          # Root Configuration
    ├── main.tf                    # Main configuration
    ├── variables.tf               # Root variables
    ├── outputs.tf                 # Root outputs
    ├── backend.tf                 # Backend configuration
    └── terraform.tfvars          # Variable values
```

### Features
- Custom EC2 instance module
- Dynamic AMI selection
- Enhanced security features
- Optional EBS volume
- Detailed monitoring
- User data configuration

### Module Usage
```hcl
module "web_server" {
  source = "./modules/aws-ec2-instance"

  instance_name    = "web-server"
  instance_type    = "t2.micro"
  subnet_id        = module.vpc.public_subnets[0]
  
  vpc_security_group_ids = [aws_security_group.web.id]
  associate_public_ip    = true
  
  root_volume_size = 20
  root_volume_type = "gp3"

  tags = {
    Environment = "dev"
    Role        = "web"
  }
}
```

## Lab 3: Module Composition

### Overview
Demonstrates advanced module composition techniques with environment-specific configurations.

### Directory Structure
```plaintext
07-lab3-manifests/
├── modules/
│   ├── alb/                    # Load Balancer Module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security-group/         # Security Group Module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── app-stack/             # Application Stack Module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── development/           # Development Environment
    │   ├── main.tf
    │   ├── variables.tf
    │   └── terraform.tfvars
    └── production/           # Production Environment
        ├── main.tf
        ├── variables.tf
        └── terraform.tfvars
```

### Features
- Environment-specific configurations
- Module composition
- Conditional resource creation
- Security group management
- Load balancer configuration
- Multi-environment deployment

### Environment Deployment
```bash
# Development Environment
cd environments/development
terraform init
terraform workspace new dev
terraform apply

# Production Environment
cd ../production
terraform init
terraform workspace new prod
terraform apply
```

## Prerequisites

### AWS Configuration
- AWS CLI installed and configured
- Appropriate IAM permissions
- S3 bucket for remote state
- DynamoDB table for state locking

### Required Tools
- Terraform >= 1.0.0
- AWS CLI >= 2.0.0
- Git (for version control)

## Common Commands

### Module Operations
```bash
# Initialize modules
terraform init

# Update modules
terraform get -update

# List modules
terraform state list

# Show module outputs
terraform output
```

### State Management
```bash
# Show state
terraform show

# List resources
terraform state list

# Move resources
terraform state mv

# Remove resources
terraform state rm
```

## Best Practices

### Module Development
- Keep modules focused and single-purpose
- Use consistent variable naming
- Implement proper validation
- Provide comprehensive documentation
- Include examples
- Version your modules

### State Management
- Use remote state
- Enable state locking
- Implement proper backend
- Use workspaces for environments

### Security
- Enable encryption
- Use security groups properly
- Implement least privilege
- Enable monitoring and logging

## Troubleshooting

### Common Issues
1. Module Source Issues
```bash
# Force module update
terraform get -update
```

2. State Lock Issues
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

3. Backend Issues
```bash
# Reconfigure backend
terraform init -reconfigure
```

## Additional Resources
- [Terraform Module Documentation](https://www.terraform.io/docs/modules/index.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/) 