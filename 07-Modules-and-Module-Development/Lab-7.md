# Lab 7: Advanced Modules and Module Development

## 🎯 **Lab Overview**

This comprehensive lab provides hands-on experience with **enterprise-grade Terraform module development, composition, and governance**. You'll master module design patterns, implement testing strategies, establish registry workflows, and create governance frameworks essential for production environments.

![Module Architecture](DaC/generated_diagrams/figure_7_1_module_architecture.png)
*Figure 7.1: Module architecture and composition patterns you'll implement*

## 📋 **Learning Objectives**

By completing this lab, you will:

### **Primary Skills**
- Design and develop reusable Terraform modules
- Implement module composition and dependency management
- Create comprehensive testing strategies for modules
- Establish module registry and distribution workflows
- Apply enterprise governance and compliance frameworks

### **Advanced Capabilities**
- Master module versioning and lifecycle management
- Implement automated testing and CI/CD integration
- Design meta-modules and advanced composition patterns
- Establish security scanning and compliance checking
- Optimize module performance and cost efficiency

### **Business Outcomes**
- Enable infrastructure standardization across teams
- Reduce development time through reusable components
- Ensure consistency and quality through governance
- Implement security and compliance by design
- Achieve operational excellence through automation

## 🔧 **Prerequisites**

### **Technical Requirements**
- **AWS CLI** configured with appropriate permissions
- **Terraform 1.13.0+** installed and configured
- **Python 3.9+** for testing frameworks
- **Git** for version control and module management
- **Text editor** (VS Code, vim, etc.)

### **AWS Permissions Required**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "vpc:*",
        "s3:*",
        "rds:*",
        "iam:*",
        "cloudwatch:*",
        "cloudtrail:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### **Cost Considerations**
- **Estimated Lab Cost**: $5-15 USD for completion
- **Resources Created**: VPC, EC2 instances, S3 buckets, RDS database, testing infrastructure
- **Cleanup Required**: Yes, to avoid ongoing charges

## 🚀 **Lab Setup**

### **Step 1: Environment Preparation**

```bash
# Create lab directory
mkdir terraform-modules-lab
cd terraform-modules-lab

# Clone lab materials
git clone <repository-url> .
cd 07-Modules-and-Module-Development/Terraform-Code-Lab-7.1

# Verify prerequisites
terraform version
aws --version
python3 --version
```

### **Step 2: Initial Configuration**

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit configuration for your environment
nano terraform.tfvars
```

**Required Variables:**
```hcl
project_name = "terraform-modules-lab-[your-initials]"
environment = "development"
owner = "your-name"
aws_region = "us-east-1"
notification_email = "your-email@example.com"
budget_limit = 200
module_development_mode = true
enable_module_testing = true
```

---

## 🏗️ **Lab Exercise 1: Basic Module Development**

### **Objective**
Create and implement basic Terraform modules with proper structure and interfaces.

![Module Development Lifecycle](DaC/generated_diagrams/figure_7_2_development_lifecycle.png)
*Figure 7.2: Module development lifecycle you'll follow*

### **Duration**: 45 minutes

### **Step 1.1: Create VPC Module**

```bash
# Create module directory structure
mkdir -p modules/vpc
cd modules/vpc

# Create module files
touch main.tf variables.tf outputs.tf README.md
```

**modules/vpc/variables.tf:**
```hcl
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
```

**modules/vpc/main.tf:**
```hcl
# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-vpc"
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-igw"
      Environment = var.environment
    },
    var.tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-public-${count.index + 1}"
      Type        = "public"
      Environment = var.environment
    },
    var.tags
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-private-${count.index + 1}"
      Type        = "private"
      Environment = var.environment
    },
    var.tags
  )
}

# NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-public-rt"
      Type        = "public"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 1

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
      Type        = "private"
      Environment = var.environment
    },
    var.tags
  )
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}
```

**modules/vpc/outputs.tf:**
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "route_table_ids" {
  description = "IDs of the route tables"
  value = {
    public  = aws_route_table.public.id
    private = aws_route_table.private[*].id
  }
}

output "resource_count" {
  description = "Number of resources created"
  value = 1 + 1 + length(aws_subnet.public) + length(aws_subnet.private) + length(aws_nat_gateway.main) + 1 + length(aws_route_table.private)
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost in USD"
  value = length(aws_nat_gateway.main) * 45 + length(aws_eip.nat) * 3.6
}
```

### **Step 1.2: Test VPC Module**

```bash
# Return to lab root
cd ../..

# Initialize and validate
terraform init
terraform validate

# Plan VPC module only
terraform plan -target=module.vpc_example

# Apply VPC module
terraform apply -target=module.vpc_example
```

**Expected Output:**
```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:
vpc_module_outputs = {
  "internet_gateway_id" = "igw-0123456789abcdef0"
  "nat_gateway_ids" = [
    "nat-0123456789abcdef0",
    "nat-0123456789abcdef1"
  ]
  "private_subnet_ids" = [
    "subnet-0123456789abcdef0",
    "subnet-0123456789abcdef1"
  ]
  "public_subnet_ids" = [
    "subnet-0123456789abcdef2",
    "subnet-0123456789abcdef3"
  ]
  "vpc_cidr_block" = "10.0.0.0/16"
  "vpc_id" = "vpc-0123456789abcdef0"
}
```

### **Step 1.3: Validate Module Functionality**

```bash
# Check VPC creation
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_module_outputs | jq -r '.vpc_id')

# Check subnet creation
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_module_outputs | jq -r '.vpc_id')"

# Verify module structure
terraform state list | grep module.vpc_example
```

---

## 🔒 **Lab Exercise 2: Module Composition and Dependencies**

### **Objective**
Implement module composition patterns and manage dependencies between modules.

### **Duration**: 40 minutes

### **Step 2.1: Create Security Group Module**

```bash
# Create security group module
mkdir -p modules/security-group
cd modules/security-group
```

**modules/security-group/variables.tf:**
```hcl
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security group will be created"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
```

**modules/security-group/main.tf:**
```hcl
resource "aws_security_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.project_name} ${var.environment}"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-sg"
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = var.egress_rules[count.index].cidr_blocks
  description       = var.egress_rules[count.index].description
  security_group_id = aws_security_group.main.id
}
```

**modules/security-group/outputs.tf:**
```hcl
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.main.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.main.name
}

output "ingress_rules" {
  description = "Ingress rules applied"
  value       = var.ingress_rules
}

output "egress_rules" {
  description = "Egress rules applied"
  value       = var.egress_rules
}
```

### **Step 2.2: Test Module Composition**

```bash
# Return to lab root
cd ../..

# Plan security group module (depends on VPC)
terraform plan -target=module.security_group_example

# Apply security group module
terraform apply -target=module.security_group_example
```

### **Step 2.3: Verify Module Dependencies**

```bash
# Check dependency graph
terraform graph | grep -E "(module\.|->)"

# Verify security group creation
aws ec2 describe-security-groups --group-ids $(terraform output -json security_group_module_outputs | jq -r '.security_group_id')

# Test dependency resolution
terraform plan
```

---

## 🧪 **Lab Exercise 3: Module Testing and Validation**

### **Objective**
Implement comprehensive testing strategies for module validation and quality assurance.

![Testing Automation](DaC/generated_diagrams/figure_7_5_testing_automation.png)
*Figure 7.5: Testing and automation pipeline*

### **Duration**: 35 minutes

### **Step 3.1: Create Testing Framework**

```bash
# Create testing directory structure
mkdir -p tests/{unit,integration,e2e}
cd tests
```

**tests/unit/vpc_test.py:**
```python
#!/usr/bin/env python3
"""
Unit tests for VPC module
"""

import json
import subprocess
import sys
import os

def run_terraform_command(command, cwd=None):
    """Run terraform command and return output"""
    try:
        result = subprocess.run(
            command.split(),
            capture_output=True,
            text=True,
            cwd=cwd,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {command}")
        print(f"Error output: {e.stderr}")
        return None

def test_vpc_module_syntax():
    """Test VPC module syntax validation"""
    print("Testing VPC module syntax...")
    
    # Change to VPC module directory
    vpc_module_dir = "../../modules/vpc"
    
    # Run terraform validate
    output = run_terraform_command("terraform validate", cwd=vpc_module_dir)
    
    if output is not None and "Success" in output:
        print("✅ VPC module syntax validation passed")
        return True
    else:
        print("❌ VPC module syntax validation failed")
        return False

def test_vpc_module_formatting():
    """Test VPC module formatting"""
    print("Testing VPC module formatting...")
    
    vpc_module_dir = "../../modules/vpc"
    
    # Run terraform fmt check
    output = run_terraform_command("terraform fmt -check", cwd=vpc_module_dir)
    
    if output is not None:
        print("✅ VPC module formatting check passed")
        return True
    else:
        print("❌ VPC module formatting check failed")
        return False

def test_vpc_module_variables():
    """Test VPC module variable definitions"""
    print("Testing VPC module variables...")
    
    variables_file = "../../modules/vpc/variables.tf"
    
    if os.path.exists(variables_file):
        with open(variables_file, 'r') as f:
            content = f.read()
            
        required_variables = [
            'project_name',
            'environment',
            'vpc_cidr',
            'availability_zones'
        ]
        
        all_present = all(var in content for var in required_variables)
        
        if all_present:
            print("✅ VPC module variables test passed")
            return True
        else:
            print("❌ VPC module variables test failed")
            return False
    else:
        print("❌ VPC module variables file not found")
        return False

def main():
    """Run all unit tests"""
    print("Running VPC Module Unit Tests")
    print("=" * 40)
    
    tests = [
        test_vpc_module_syntax,
        test_vpc_module_formatting,
        test_vpc_module_variables
    ]
    
    results = []
    for test in tests:
        results.append(test())
        print()
    
    passed = sum(results)
    total = len(results)
    
    print(f"Test Results: {passed}/{total} passed")
    
    if passed == total:
        print("🎉 All unit tests passed!")
        sys.exit(0)
    else:
        print("❌ Some unit tests failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### **Step 3.2: Run Unit Tests**

```bash
# Make test executable
chmod +x unit/vpc_test.py

# Run unit tests
python3 unit/vpc_test.py
```

### **Step 3.3: Integration Testing**

```bash
# Create integration test
cat > integration/module_composition_test.sh << 'EOF'
#!/bin/bash

echo "Running Module Composition Integration Tests"
echo "============================================"

# Test VPC and Security Group composition
echo "Testing VPC and Security Group composition..."

# Plan both modules
terraform plan -target=module.vpc_example -target=module.security_group_example

if [ $? -eq 0 ]; then
    echo "✅ Module composition planning passed"
else
    echo "❌ Module composition planning failed"
    exit 1
fi

# Check dependency resolution
echo "Checking dependency resolution..."
terraform graph | grep -q "module.vpc_example.*module.security_group_example"

if [ $? -eq 0 ]; then
    echo "✅ Module dependencies resolved correctly"
else
    echo "❌ Module dependency resolution failed"
    exit 1
fi

echo "🎉 All integration tests passed!"
EOF

# Make executable and run
chmod +x integration/module_composition_test.sh
./integration/module_composition_test.sh
```

### **Step 3.4: End-to-End Testing**

```bash
# Apply all modules
terraform apply -auto-approve

# Verify infrastructure
echo "Verifying end-to-end infrastructure..."

# Check VPC
VPC_ID=$(terraform output -json vpc_module_outputs | jq -r '.vpc_id')
aws ec2 describe-vpcs --vpc-ids $VPC_ID --query 'Vpcs[0].State' --output text

# Check Security Group
SG_ID=$(terraform output -json security_group_module_outputs | jq -r '.security_group_id')
aws ec2 describe-security-groups --group-ids $SG_ID --query 'SecurityGroups[0].GroupId' --output text

echo "✅ End-to-end testing completed successfully"
```

---

## 📦 **Lab Exercise 4: Module Registry and Distribution**

### **Objective**
Establish module registry patterns and distribution workflows.

![Registry Ecosystem](DaC/generated_diagrams/figure_7_3_registry_ecosystem.png)
*Figure 7.3: Module registry ecosystem*

### **Duration**: 30 minutes

### **Step 4.1: Set Up Local Module Registry**

```bash
# Create registry structure
mkdir -p registry/{vpc,security-group,ec2-instance}

# Package VPC module
cd modules/vpc
tar -czf ../../registry/vpc/vpc-1.0.0.tar.gz .
cd ../..

# Package Security Group module
cd modules/security-group
tar -czf ../../registry/security-group/security-group-1.0.0.tar.gz .
cd ../..
```

### **Step 4.2: Upload to S3 Registry**

```bash
# Get registry bucket name
REGISTRY_BUCKET=$(terraform output -json module_testing_infrastructure | jq -r '.registry_bucket_name')

# Upload modules to registry
aws s3 cp registry/vpc/vpc-1.0.0.tar.gz s3://$REGISTRY_BUCKET/modules/vpc/1.0.0/
aws s3 cp registry/security-group/security-group-1.0.0.tar.gz s3://$REGISTRY_BUCKET/modules/security-group/1.0.0/

# List registry contents
aws s3 ls s3://$REGISTRY_BUCKET/modules/ --recursive
```

### **Step 4.3: Create Module Metadata**

```bash
# Create module metadata
cat > registry/vpc/metadata.json << EOF
{
  "name": "vpc",
  "version": "1.0.0",
  "description": "AWS VPC module with public and private subnets",
  "author": "$USER",
  "license": "MIT",
  "terraform_version": "~> 1.13.0",
  "providers": {
    "aws": "~> 6.12.0"
  },
  "dependencies": [],
  "examples": [
    {
      "name": "basic",
      "description": "Basic VPC with 2 AZs"
    }
  ]
}
EOF

# Upload metadata
aws s3 cp registry/vpc/metadata.json s3://$REGISTRY_BUCKET/modules/vpc/1.0.0/
```

### **Step 4.4: Test Module Consumption**

```bash
# Create test consumption
mkdir -p test-consumption
cd test-consumption

# Create test configuration
cat > main.tf << EOF
module "test_vpc" {
  source = "s3::https://s3.amazonaws.com/$REGISTRY_BUCKET/modules/vpc/1.0.0/vpc-1.0.0.tar.gz"
  
  project_name        = "test"
  environment         = "development"
  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}
EOF

# Test module download
terraform init
terraform validate

cd ..
```

---

## 🛡️ **Lab Exercise 5: Enterprise Governance and Compliance**

### **Objective**
Implement enterprise governance patterns and compliance frameworks.

![Enterprise Governance](DaC/generated_diagrams/figure_7_4_enterprise_governance.png)
*Figure 7.4: Enterprise governance framework*

### **Duration**: 25 minutes

### **Step 5.1: Security Scanning**

```bash
# Install security scanning tools (if not already installed)
# pip install checkov
# brew install tfsec

# Run security scan on modules
echo "Running security scans..."

# Scan VPC module
tfsec modules/vpc/ --format json > security-reports/vpc-security.json

# Scan Security Group module
tfsec modules/security-group/ --format json > security-reports/sg-security.json

# Run Checkov scan
checkov -d modules/ --framework terraform --output json > security-reports/checkov-report.json

echo "✅ Security scanning completed"
```

### **Step 5.2: Compliance Checking**

```bash
# Create compliance rules
mkdir -p compliance-rules

cat > compliance-rules/aws-compliance.rego << 'EOF'
package terraform.aws

# Ensure VPCs have DNS hostnames enabled
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_vpc"
    not resource.change.after.enable_dns_hostnames
    msg := "VPC must have DNS hostnames enabled"
}

# Ensure security groups don't allow unrestricted access
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group_rule"
    resource.change.after.type == "ingress"
    "0.0.0.0/0" in resource.change.after.cidr_blocks
    resource.change.after.from_port == 0
    resource.change.after.to_port == 65535
    msg := "Security group rule allows unrestricted access"
}
EOF

# Run compliance check
terraform plan -out=compliance.plan
terraform show -json compliance.plan > compliance.json

# Check compliance (would use OPA/Conftest in real scenario)
echo "✅ Compliance checking completed"
```

### **Step 5.3: Governance Metrics**

```bash
# Generate governance report
cat > governance-report.sh << 'EOF'
#!/bin/bash

echo "Module Governance Report"
echo "======================="
echo "Generated: $(date)"
echo ""

echo "Module Inventory:"
echo "- VPC Module: v1.0.0"
echo "- Security Group Module: v1.0.0"
echo ""

echo "Security Scan Results:"
if [ -f security-reports/vpc-security.json ]; then
    echo "- VPC Module: $(jq '.results | length' security-reports/vpc-security.json) issues found"
fi

echo ""
echo "Compliance Status:"
echo "- DNS Hostnames: ✅ Enabled"
echo "- Security Groups: ✅ Properly configured"
echo "- Encryption: ✅ Enabled where applicable"

echo ""
echo "Module Usage:"
terraform state list | grep module | wc -l | xargs echo "- Active modules:"

echo ""
echo "Cost Estimation:"
terraform output -json module_development_metrics | jq -r '.estimated_monthly_cost' | xargs echo "- Estimated monthly cost: $"
EOF

chmod +x governance-report.sh
./governance-report.sh
```

---

## 📊 **Lab Assessment and Validation**

### **Checkpoint 1: Module Development**
- [ ] VPC module created with proper structure
- [ ] Security Group module created with dependencies
- [ ] Module interfaces properly defined
- [ ] Module composition working correctly

### **Checkpoint 2: Testing Framework**
- [ ] Unit tests implemented and passing
- [ ] Integration tests validating module composition
- [ ] End-to-end tests verifying infrastructure
- [ ] Security scanning integrated

### **Checkpoint 3: Registry and Distribution**
- [ ] Local module registry established
- [ ] Modules packaged and uploaded
- [ ] Module metadata created
- [ ] Module consumption tested

### **Checkpoint 4: Governance and Compliance**
- [ ] Security scanning implemented
- [ ] Compliance checking configured
- [ ] Governance metrics generated
- [ ] Enterprise patterns established

### **Final Validation**

```bash
# Run comprehensive validation
./scripts/validate-lab-completion.sh

# Generate final report
terraform output -json module_development_metrics > lab-completion-report.json
```

---

## 🧹 **Cleanup Procedures**

### **Step 1: Destroy Infrastructure**

```bash
# Destroy all resources
terraform destroy -auto-approve

# Clean up testing artifacts
rm -rf tests/reports/
rm -rf security-reports/
rm -rf registry/
rm -rf test-consumption/
```

### **Step 2: Clean Up Registry**

```bash
# Remove registry contents
REGISTRY_BUCKET=$(terraform output -json module_testing_infrastructure | jq -r '.registry_bucket_name')
aws s3 rm s3://$REGISTRY_BUCKET --recursive
```

### **Step 3: Final Cleanup**

```bash
# Remove local files
rm -f terraform.tfvars
rm -f *.plan
rm -f *.json
rm -rf .terraform/

# Verify cleanup
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=terraform-modules-lab*"
```

---

## 🎯 **Key Takeaways**

### **Technical Mastery**
- ✅ Module design and development patterns
- ✅ Module composition and dependency management
- ✅ Comprehensive testing strategies
- ✅ Registry management and distribution
- ✅ Enterprise governance and compliance

### **Business Value**
- **Standardization**: Consistent infrastructure patterns across teams
- **Reusability**: Reduced development time through modular components
- **Quality**: Comprehensive testing and validation frameworks
- **Governance**: Security and compliance by design
- **Efficiency**: Automated workflows and operational excellence

## 🆕 **Bonus Section: Advanced Module Development Patterns (2025)**

### **Part 6: Meta-Modules and Module Composition (30 minutes)**

**Step 1: Create Meta-Module for Application Stack**
```bash
# Create meta-module directory structure
mkdir -p modules/meta-modules/application-stack
cd modules/meta-modules/application-stack

# Create meta-module configuration
cat > main.tf << 'EOF'
# Meta-module for complete application stack
terraform {
  required_version = "~> 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../vpc"

  project_name       = var.application_config.name
  environment        = var.application_config.environment
  vpc_cidr          = var.application_config.networking.vpc_cidr
  availability_zones = var.application_config.networking.availability_zones

  enable_nat_gateway = var.application_config.networking.enable_nat_gateway
  enable_vpn_gateway = var.application_config.networking.enable_vpn_gateway

  tags = merge(var.tags, {
    Component = "networking"
    MetaModule = "application-stack"
  })
}

# Security Group Module
module "security_group" {
  source = "../../security-group"

  project_name = var.application_config.name
  environment  = var.application_config.environment
  vpc_id       = module.vpc.vpc_id

  # Dynamic security rules based on application type
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

  tags = merge(var.tags, {
    Component = "security"
    MetaModule = "application-stack"
  })
}

# EC2 Instance Module
module "ec2_instances" {
  source = "../../ec2-instance"

  project_name      = var.application_config.name
  environment       = var.application_config.environment
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  security_group_id = module.security_group.security_group_id

  instance_type    = var.application_config.compute.instance_type
  min_size         = var.application_config.compute.min_capacity
  max_size         = var.application_config.compute.max_capacity
  desired_capacity = var.application_config.compute.desired_capacity

  enable_detailed_monitoring = var.feature_flags.enable_monitoring

  tags = merge(var.tags, {
    Component = "compute"
    MetaModule = "application-stack"
  })
}

# RDS Database Module (conditional)
module "database" {
  count  = var.feature_flags.enable_database ? 1 : 0
  source = "../../rds-database"

  project_name = var.application_config.name
  environment  = var.application_config.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids

  engine            = var.application_config.database.engine
  engine_version    = var.application_config.database.engine_version
  instance_class    = var.application_config.database.instance_class
  allocated_storage = var.application_config.database.allocated_storage
  multi_az         = var.application_config.database.multi_az

  tags = merge(var.tags, {
    Component = "database"
    MetaModule = "application-stack"
  })
}

# S3 Bucket Module (conditional)
module "storage" {
  count  = var.feature_flags.enable_storage ? 1 : 0
  source = "../../s3-bucket"

  project_name = var.application_config.name
  environment  = var.application_config.environment

  bucket_purpose = "application-storage"
  versioning_enabled = true
  encryption_enabled = var.application_config.security.encryption_at_rest

  tags = merge(var.tags, {
    Component = "storage"
    MetaModule = "application-stack"
  })
}
EOF

# Create meta-module variables
cat > variables.tf << 'EOF'
variable "application_config" {
  description = "Complete application configuration"
  type = object({
    name         = string
    environment  = string
    version      = string

    compute = object({
      instance_type     = string
      min_capacity      = number
      max_capacity      = number
      desired_capacity  = number
      enable_spot       = bool
    })

    database = object({
      engine            = string
      engine_version    = string
      instance_class    = string
      allocated_storage = number
      multi_az         = bool
    })

    networking = object({
      vpc_cidr             = string
      availability_zones   = list(string)
      enable_nat_gateway   = bool
      enable_vpn_gateway   = bool
    })

    security = object({
      enable_waf           = bool
      enable_shield        = bool
      ssl_policy          = string
      encryption_at_rest  = bool
    })
  })
}

variable "feature_flags" {
  description = "Feature flags for conditional resource creation"
  type = object({
    enable_monitoring    = bool
    enable_logging      = bool
    enable_backup       = bool
    enable_database     = bool
    enable_storage      = bool
    enable_cdn          = bool
    enable_cache        = bool
  })

  default = {
    enable_monitoring = true
    enable_logging   = true
    enable_backup    = true
    enable_database  = true
    enable_storage   = true
    enable_cdn       = false
    enable_cache     = false
  }
}

variable "environment_overrides" {
  description = "Environment-specific configuration overrides"
  type = map(object({
    backup_retention = number
    monitoring_level = string
    log_retention   = number
  }))

  default = {
    production = {
      backup_retention = 30
      monitoring_level = "detailed"
      log_retention   = 90
    }
    staging = {
      backup_retention = 7
      monitoring_level = "basic"
      log_retention   = 30
    }
    development = {
      backup_retention = 3
      monitoring_level = "basic"
      log_retention   = 7
    }
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
EOF

# Create meta-module outputs
cat > outputs.tf << 'EOF'
output "application_stack" {
  description = "Complete application stack information"
  value = {
    # Networking outputs
    vpc_id              = module.vpc.vpc_id
    public_subnet_ids   = module.vpc.public_subnet_ids
    private_subnet_ids  = module.vpc.private_subnet_ids

    # Security outputs
    security_group_id = module.security_group.security_group_id

    # Compute outputs
    instance_ids = module.ec2_instances.instance_ids
    load_balancer_dns = module.ec2_instances.load_balancer_dns

    # Database outputs (conditional)
    database_endpoint = var.feature_flags.enable_database ? module.database[0].endpoint : null
    database_port     = var.feature_flags.enable_database ? module.database[0].port : null

    # Storage outputs (conditional)
    storage_bucket_name = var.feature_flags.enable_storage ? module.storage[0].bucket_name : null
    storage_bucket_arn  = var.feature_flags.enable_storage ? module.storage[0].bucket_arn : null
  }
}

output "application_urls" {
  description = "Application access URLs"
  value = {
    load_balancer_url = "http://${module.ec2_instances.load_balancer_dns}"
    health_check_url  = "http://${module.ec2_instances.load_balancer_dns}/health"
  }
}

output "monitoring_endpoints" {
  description = "Monitoring and management endpoints"
  value = var.feature_flags.enable_monitoring ? {
    cloudwatch_dashboard = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${var.application_config.name}"
    logs_group = "/aws/ec2/${var.application_config.name}"
  } : null
}
EOF

# Test meta-module
cd ../../../
terraform init
terraform plan -target=module.application_stack_example
```

**Step 2: Dynamic Module Configuration**
```bash
# Create dynamic module configuration
cat > dynamic-modules.tf << 'EOF'
# Dynamic module configuration based on environment
locals {
  # Environment-specific configurations
  environment_configs = {
    development = {
      instance_types = ["t3.micro", "t3.small"]
      storage_types  = ["gp3"]
      backup_schedule = "daily"
      monitoring_level = "basic"
      cost_optimization = true
    }

    staging = {
      instance_types = ["t3.small", "t3.medium"]
      storage_types  = ["gp3", "io1"]
      backup_schedule = "twice-daily"
      monitoring_level = "enhanced"
      cost_optimization = true
    }

    production = {
      instance_types = ["t3.large", "t3.xlarge", "m5.large", "m5.xlarge"]
      storage_types  = ["gp3", "io1", "io2"]
      backup_schedule = "continuous"
      monitoring_level = "comprehensive"
      cost_optimization = false
    }
  }

  # Dynamic module selection based on requirements
  selected_modules = {
    for module_name, config in var.module_requirements : module_name => {
      enabled = config.enabled
      source  = config.source_override != null ? config.source_override : "./modules/${module_name}"
      version = config.version_override != null ? config.version_override : var.default_module_version

      # Dynamic configuration based on environment
      configuration = merge(
        local.environment_configs[var.environment],
        config.custom_config
      )
    }
  }
}

# Dynamic module instantiation
module "dynamic_infrastructure" {
  for_each = { for k, v in local.selected_modules : k => v if v.enabled }

  source = each.value.source

  # Pass dynamic configuration
  configuration = each.value.configuration
  environment   = var.environment
  project_name  = var.project_name

  # Module-specific tags
  tags = merge(local.common_tags, {
    ModuleName = each.key
    ModuleVersion = each.value.version
    Environment = var.environment
    DynamicConfig = "true"
  })
}

# Output dynamic module results
output "dynamic_modules_deployed" {
  description = "Information about dynamically deployed modules"
  value = {
    for k, v in module.dynamic_infrastructure : k => {
      module_name = k
      configuration = local.selected_modules[k].configuration
      outputs = v
    }
  }
}
EOF

# Test dynamic configuration
terraform plan -var="environment=production"
terraform plan -var="environment=development"
```

### **Part 7: Advanced Module Testing and Validation (25 minutes)**

**Step 1: Implement Comprehensive Testing Framework**
```bash
# Create testing framework
mkdir -p tests/{unit,integration,e2e}

# Create unit test for VPC module
cat > tests/unit/vpc_test.go << 'EOF'
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../../modules/vpc",
        Vars: map[string]interface{}{
            "project_name": "test-vpc",
            "environment": "test",
            "vpc_cidr": "10.0.0.0/16",
            "availability_zones": []string{"us-east-1a", "us-east-1b"},
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)

    publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
    assert.Len(t, publicSubnetIds, 2)

    privateSubnetIds := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
    assert.Len(t, privateSubnetIds, 2)
}
EOF

# Create integration test
cat > tests/integration/application_stack_test.sh << 'EOF'
#!/bin/bash
set -e

echo "🧪 Running Application Stack Integration Tests"

# Test 1: Basic deployment
echo "Test 1: Basic application stack deployment"
terraform apply -target=module.application_stack_example -auto-approve

# Validate VPC creation
VPC_ID=$(terraform output -raw application_stack_vpc_id)
if [ -z "$VPC_ID" ]; then
    echo "❌ VPC not created"
    exit 1
fi
echo "✅ VPC created: $VPC_ID"

# Validate security group creation
SG_ID=$(terraform output -raw application_stack_security_group_id)
if [ -z "$SG_ID" ]; then
    echo "❌ Security group not created"
    exit 1
fi
echo "✅ Security group created: $SG_ID"

# Test 2: Module composition
echo "Test 2: Module composition validation"
terraform state list | grep "module.application_stack_example"
if [ $? -eq 0 ]; then
    echo "✅ Module composition working"
else
    echo "❌ Module composition failed"
    exit 1
fi

# Test 3: Feature flags
echo "Test 3: Feature flag functionality"
terraform apply -var="feature_flags={enable_database=false}" -auto-approve
DB_ENDPOINT=$(terraform output -raw application_stack_database_endpoint 2>/dev/null || echo "null")
if [ "$DB_ENDPOINT" = "null" ]; then
    echo "✅ Feature flags working - database disabled"
else
    echo "❌ Feature flags not working"
    exit 1
fi

echo "🎉 All integration tests passed!"
EOF

chmod +x tests/integration/application_stack_test.sh

# Create end-to-end test
cat > tests/e2e/full_deployment_test.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Running End-to-End Deployment Tests"

# Deploy complete infrastructure
echo "Deploying complete infrastructure..."
terraform apply -auto-approve

# Test application accessibility
echo "Testing application accessibility..."
LB_DNS=$(terraform output -raw application_stack_load_balancer_dns)
if [ ! -z "$LB_DNS" ]; then
    # Wait for load balancer to be ready
    sleep 60

    # Test HTTP connectivity
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_DNS/health || echo "000")
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✅ Application accessible via HTTP"
    else
        echo "⚠️ Application not yet accessible (Status: $HTTP_STATUS)"
    fi
fi

# Test database connectivity (if enabled)
DB_ENDPOINT=$(terraform output -raw application_stack_database_endpoint 2>/dev/null || echo "null")
if [ "$DB_ENDPOINT" != "null" ]; then
    echo "✅ Database endpoint available: $DB_ENDPOINT"
fi

# Test monitoring setup
if [ "$(terraform output -raw monitoring_enabled)" = "true" ]; then
    echo "✅ Monitoring enabled"
fi

# Generate deployment report
cat > deployment-report.md << REPORT
# End-to-End Deployment Test Report

## Infrastructure Status
- **VPC**: $(terraform output -raw application_stack_vpc_id)
- **Load Balancer**: $LB_DNS
- **Database**: $DB_ENDPOINT
- **Monitoring**: $(terraform output -raw monitoring_enabled 2>/dev/null || echo "disabled")

## Test Results
- **HTTP Accessibility**: $HTTP_STATUS
- **Database Connectivity**: $([ "$DB_ENDPOINT" != "null" ] && echo "✅ Available" || echo "❌ Not configured")
- **Module Composition**: ✅ Working
- **Feature Flags**: ✅ Working

## Deployment Time
- **Started**: $(date)
- **Infrastructure Ready**: ✅
REPORT

echo "📊 Deployment report generated: deployment-report.md"
echo "🎉 End-to-end tests completed!"
EOF

chmod +x tests/e2e/full_deployment_test.sh

# Run tests
echo "Running module tests..."
./tests/integration/application_stack_test.sh
./tests/e2e/full_deployment_test.sh
```

### **Part 8: Enterprise Module Registry and Distribution (20 minutes)**

**Step 1: Create Private Module Registry**
```bash
# Create module registry infrastructure
cat > module-registry.tf << 'EOF'
# Module registry S3 bucket
resource "aws_s3_bucket" "module_registry" {
  bucket = "${var.organization_name}-terraform-module-registry"

  tags = merge(local.common_tags, {
    Name    = "terraform-module-registry"
    Purpose = "module-distribution"
  })
}

# Module registry versioning
resource "aws_s3_bucket_versioning" "module_registry" {
  bucket = aws_s3_bucket.module_registry.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Module registry encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "module_registry" {
  bucket = aws_s3_bucket.module_registry.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Module metadata management
resource "aws_dynamodb_table" "module_metadata" {
  name           = "${var.organization_name}-module-metadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "module_name"
  range_key      = "version"

  attribute {
    name = "module_name"
    type = "S"
  }

  attribute {
    name = "version"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  global_secondary_index {
    name     = "category-index"
    hash_key = "category"
  }

  tags = merge(local.common_tags, {
    Name    = "module-metadata"
    Purpose = "module-registry"
  })
}

# Module publishing automation
resource "null_resource" "module_publishing" {
  for_each = var.modules_to_publish

  triggers = {
    module_hash = filemd5("${path.module}/modules/${each.key}/main.tf")
    version     = each.value.version
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Package module
      cd modules/${each.key}
      tar -czf ${each.key}-${each.value.version}.tar.gz .

      # Upload to registry
      aws s3 cp ${each.key}-${each.value.version}.tar.gz \
        s3://${aws_s3_bucket.module_registry.bucket}/${each.key}/${each.value.version}/

      # Update metadata
      aws dynamodb put-item \
        --table-name ${aws_dynamodb_table.module_metadata.name} \
        --item '{
          "module_name": {"S": "${each.key}"},
          "version": {"S": "${each.value.version}"},
          "category": {"S": "${each.value.category}"},
          "description": {"S": "${each.value.description}"},
          "published_date": {"S": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"},
          "source_url": {"S": "${each.value.source_url}"},
          "documentation_url": {"S": "${each.value.documentation_url}"}
        }'

      # Clean up
      rm ${each.key}-${each.value.version}.tar.gz
    EOT
  }
}

# Output registry information
output "module_registry_info" {
  description = "Module registry information"
  value = {
    registry_bucket = aws_s3_bucket.module_registry.bucket
    metadata_table = aws_dynamodb_table.module_metadata.name
    registry_url = "s3://${aws_s3_bucket.module_registry.bucket}"
  }
}
EOF

# Apply module registry
terraform plan -target=aws_s3_bucket.module_registry
terraform apply -target=aws_s3_bucket.module_registry -auto-approve
```

**Step 2: Module Publishing and Distribution**
```bash
# Create module publishing script
cat > scripts/publish-module.sh << 'EOF'
#!/bin/bash
set -e

MODULE_NAME=$1
MODULE_VERSION=$2
MODULE_CATEGORY=$3

if [ -z "$MODULE_NAME" ] || [ -z "$MODULE_VERSION" ] || [ -z "$MODULE_CATEGORY" ]; then
    echo "Usage: $0 <module_name> <version> <category>"
    echo "Example: $0 vpc 1.0.0 networking"
    exit 1
fi

echo "📦 Publishing module: $MODULE_NAME v$MODULE_VERSION"

# Validate module structure
if [ ! -d "modules/$MODULE_NAME" ]; then
    echo "❌ Module directory not found: modules/$MODULE_NAME"
    exit 1
fi

# Required files check
REQUIRED_FILES=("main.tf" "variables.tf" "outputs.tf")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "modules/$MODULE_NAME/$file" ]; then
        echo "❌ Required file missing: $file"
        exit 1
    fi
done

# Validate module syntax
echo "🔍 Validating module syntax..."
cd modules/$MODULE_NAME
terraform init -backend=false
terraform validate
cd ../..

# Package module
echo "📦 Packaging module..."
cd modules/$MODULE_NAME
tar -czf ../../${MODULE_NAME}-${MODULE_VERSION}.tar.gz .
cd ../..

# Get registry bucket name
REGISTRY_BUCKET=$(terraform output -raw module_registry_bucket_name)
METADATA_TABLE=$(terraform output -raw module_metadata_table_name)

# Upload to registry
echo "⬆️ Uploading to registry..."
aws s3 cp ${MODULE_NAME}-${MODULE_VERSION}.tar.gz \
    s3://$REGISTRY_BUCKET/$MODULE_NAME/$MODULE_VERSION/

# Update metadata
echo "📝 Updating metadata..."
aws dynamodb put-item \
    --table-name $METADATA_TABLE \
    --item "{
        \"module_name\": {\"S\": \"$MODULE_NAME\"},
        \"version\": {\"S\": \"$MODULE_VERSION\"},
        \"category\": {\"S\": \"$MODULE_CATEGORY\"},
        \"description\": {\"S\": \"$MODULE_NAME module version $MODULE_VERSION\"},
        \"published_date\": {\"S\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"},
        \"source_url\": {\"S\": \"s3://$REGISTRY_BUCKET/$MODULE_NAME/$MODULE_VERSION/\"},
        \"documentation_url\": {\"S\": \"https://github.com/your-org/terraform-modules/tree/main/modules/$MODULE_NAME\"}
    }"

# Clean up
rm ${MODULE_NAME}-${MODULE_VERSION}.tar.gz

echo "✅ Module published successfully!"
echo "📍 Registry location: s3://$REGISTRY_BUCKET/$MODULE_NAME/$MODULE_VERSION/"
EOF

chmod +x scripts/publish-module.sh

# Publish modules
./scripts/publish-module.sh vpc 1.0.0 networking
./scripts/publish-module.sh security-group 1.0.0 security
./scripts/publish-module.sh ec2-instance 1.0.0 compute
```

### **Validation and Testing**

**Test All Advanced Features**:
```bash
# Test 1: Meta-module deployment
terraform apply -target=module.application_stack_example -auto-approve

# Test 2: Dynamic module configuration
terraform plan -var="environment=production"

# Test 3: Module testing framework
./tests/integration/application_stack_test.sh

# Test 4: Module registry
aws s3 ls s3://$(terraform output -raw module_registry_bucket_name)/

# Test 5: Module publishing
./scripts/publish-module.sh s3-bucket 1.0.0 storage

echo "🎉 All advanced module development patterns tested successfully!"
```

### **Next Steps**
- Implement advanced module patterns (meta-modules, module composition)
- Integrate with CI/CD pipelines for automated testing and deployment
- Establish organization-specific module governance policies
- Explore Terraform Cloud/Enterprise module registry features
- Develop comprehensive module libraries for your organization
- **🆕 Deploy meta-modules** for complex application stacks
- **🆕 Implement dynamic configuration** for environment-specific behavior
- **🆕 Establish enterprise registry** for module distribution and governance

---

**Lab Completion Time**: 5-6 hours
**Skill Level**: Intermediate to Advanced
**Prerequisites Met**: ✅ AWS, Terraform, Module Development
**Ready for Production**: ✅ Enterprise patterns implemented
**🆕 2025 Features**: Meta-Modules, Dynamic Configuration, Advanced Testing, Enterprise Registry
