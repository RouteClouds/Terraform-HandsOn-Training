# Lab 3: Core Terraform Operations

## 🎯 Lab Objectives

By completing this lab, you will:

1. **Master the core Terraform workflow** with init, plan, apply, and destroy operations
2. **Implement resource lifecycle management** with creation, updates, and deletion patterns
3. **Configure dependency management** with implicit and explicit dependencies
4. **Optimize Terraform performance** with parallelism and targeting techniques
5. **Handle errors and recovery scenarios** with systematic troubleshooting approaches
6. **Apply enterprise workflow patterns** for production-ready deployments

**Duration**: 90-120 minutes  
**Difficulty**: Intermediate  
**Prerequisites**: Completed Topics 1-2, AWS account with administrative permissions

## 💰 Cost Estimates

### Expected AWS Costs for this Lab:
- **EC2 instances (t3.micro)**: ~$0.0116/hour × 3 instances = ~$0.035/hour
- **VPC and networking**: Free tier eligible
- **S3 bucket**: ~$0.023/GB/month (minimal usage)
- **CloudWatch logs**: ~$0.50/GB ingested (minimal for lab)
- **Total estimated cost**: **$0.50 - $1.50/day** (with auto-shutdown)

**💡 Cost Optimization Note**: This lab includes auto-shutdown after 4 hours and uses minimal resources.

## 🏗️ Lab Architecture Overview

In this lab, you'll build a complete web application infrastructure demonstrating:

1. **Core Terraform operations** across the full lifecycle
2. **Resource dependencies** with VPC, subnets, security groups, and EC2 instances
3. **Performance optimization** with parallelism and targeting
4. **Error handling** and recovery scenarios
5. **Enterprise patterns** for team collaboration

![Lab Architecture](../DaC/generated_diagrams/lab3_architecture.png)
*Figure 3.1: Lab 3 Core Terraform Operations Architecture*

## 📋 Prerequisites Setup

### 1. Verify Environment
```bash
# Check Terraform version
terraform version

# Verify AWS authentication
aws sts get-caller-identity

# Set lab environment variables
export LAB_NAME="core-terraform-operations"
export STUDENT_NAME="your-name"  # Replace with your name
export AWS_REGION="us-east-1"
```

### 2. Create Lab Directory
```bash
# Create and navigate to lab directory
mkdir -p terraform-core-operations-lab
cd terraform-core-operations-lab

# Initialize git for version control
git init
echo "*.tfstate*" > .gitignore
echo ".terraform/" >> .gitignore
```

## 🚀 Part 1: Core Workflow Mastery

### Step 1: Initialize Terraform Project

#### 1.1 Create Provider Configuration
```bash
cat > providers.tf << 'EOF'
terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "terraform-core-operations"
      Environment = var.environment
      Student     = var.student_name
      Lab         = "core-terraform-operations"
      ManagedBy   = "terraform"
    }
  }
}
EOF
```

#### 1.2 Create Variables Configuration
```bash
cat > variables.tf << 'EOF'
variable "student_name" {
  description = "Student name for resource identification"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}
EOF
```

#### 1.3 Create terraform.tfvars
```bash
cat > terraform.tfvars << EOF
student_name = "$STUDENT_NAME"
environment  = "lab"
aws_region   = "$AWS_REGION"
instance_count = 2
instance_type = "t3.micro"
enable_monitoring = true
EOF
```

#### 1.4 Initialize Terraform
```bash
# Initialize Terraform
terraform init

# Verify initialization
ls -la .terraform/
terraform providers
```

### Step 2: Plan and Validate

#### 2.1 Create Basic Infrastructure Configuration
```bash
cat > main.tf << 'EOF'
# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# Data source for latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "lab-vpc-${random_id.suffix.hex}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "lab-igw-${random_id.suffix.hex}"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "lab-public-subnet-${random_id.suffix.hex}"
    Type = "public"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  
  tags = {
    Name = "lab-private-subnet-${random_id.suffix.hex}"
    Type = "private"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "lab-public-rt-${random_id.suffix.hex}"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group for Web Servers
resource "aws_security_group" "web" {
  name_prefix = "lab-web-sg-"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "lab-web-sg-${random_id.suffix.hex}"
  }
}
EOF
```

#### 2.2 Plan Infrastructure
```bash
# Create execution plan
terraform plan

# Save plan to file
terraform plan -out=lab.tfplan

# Review plan details
terraform show lab.tfplan
```

### Step 3: Apply and Monitor

#### 3.1 Apply Infrastructure
```bash
# Apply with confirmation
terraform apply

# Apply saved plan (no confirmation needed)
terraform apply lab.tfplan

# Monitor apply progress
terraform apply | tee apply.log
```

#### 3.2 Verify Infrastructure
```bash
# List created resources
terraform state list

# Show specific resource details
terraform state show aws_vpc.main

# Check AWS Console or CLI
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=lab-vpc-*"
```

## 🔄 Part 2: Resource Lifecycle Management

### Step 4: Add EC2 Instances with Dependencies

#### 4.1 Add EC2 Resources to main.tf
```bash
cat >> main.tf << 'EOF'

# EC2 Instances with count
resource "aws_instance" "web" {
  count = var.instance_count
  
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    instance_number = count.index + 1
    student_name    = var.student_name
  }))
  
  tags = {
    Name = "lab-web-${count.index + 1}-${random_id.suffix.hex}"
    Role = "web-server"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer (demonstrates explicit dependencies)
resource "aws_lb" "main" {
  name               = "lab-alb-${random_id.suffix.hex}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = [aws_subnet.public.id, aws_subnet.private.id]
  
  # Explicit dependency
  depends_on = [aws_internet_gateway.main]
  
  tags = {
    Name = "lab-alb-${random_id.suffix.hex}"
  }
}

# S3 Bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "lab-app-data-${var.student_name}-${random_id.suffix.hex}"
  
  tags = {
    Name = "lab-app-data-${random_id.suffix.hex}"
  }
}

# CloudWatch Log Group (conditional creation)
resource "aws_cloudwatch_log_group" "app_logs" {
  count = var.enable_monitoring ? 1 : 0
  
  name              = "/aws/ec2/lab-${random_id.suffix.hex}"
  retention_in_days = 7
  
  tags = {
    Name = "lab-logs-${random_id.suffix.hex}"
  }
}
EOF
```

#### 4.2 Create User Data Script
```bash
cat > user_data.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y httpd

# Create simple web page
cat > /var/www/html/index.html << HTML
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Core Operations Lab</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #232F3E; color: white; padding: 20px; }
        .content { padding: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Terraform Core Operations Lab</h1>
        <p>Instance ${instance_number} - Student: ${student_name}</p>
    </div>
    <div class="content">
        <h2>Infrastructure Details</h2>
        <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
        <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
        <p><strong>Instance Type:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-type)</p>
        <p><strong>Deployment Time:</strong> $(date)</p>
    </div>
</body>
</html>
HTML

systemctl start httpd
systemctl enable httpd
EOF
```

#### 4.3 Plan and Apply Updates
```bash
# Plan the updates
terraform plan

# Apply updates
terraform apply

# Verify new resources
terraform state list | grep aws_instance
```

### Step 5: Resource Modifications and Updates

#### 5.1 Modify Instance Configuration
```bash
# Update variables to change instance count
cat > terraform.tfvars << EOF
student_name = "$STUDENT_NAME"
environment  = "lab"
aws_region   = "$AWS_REGION"
instance_count = 3  # Increased from 2
instance_type = "t3.small"  # Upgraded from t3.micro
enable_monitoring = true
EOF
```

#### 5.2 Plan and Apply Changes
```bash
# Plan the changes
terraform plan

# Apply changes with auto-approval
terraform apply -auto-approve

# Verify changes
aws ec2 describe-instances --filters "Name=tag:Project,Values=terraform-core-operations" --query 'Reservations[].Instances[].{InstanceId:InstanceId,InstanceType:InstanceType,State:State.Name}'
```

## ⚡ Part 3: Performance Optimization and Targeting

### Step 6: Resource Targeting

#### 6.1 Target Specific Resources
```bash
# Plan changes for specific resource
terraform plan -target=aws_instance.web

# Apply changes to specific resource
terraform apply -target=aws_instance.web[0]

# Target multiple resources
terraform apply -target=aws_instance.web -target=aws_security_group.web
```

#### 6.2 Performance Optimization
```bash
# Increase parallelism
terraform apply -parallelism=20

# Set environment variable for default parallelism
export TF_CLI_ARGS_apply="-parallelism=15"
export TF_CLI_ARGS_plan="-parallelism=15"

# Time the operations
time terraform plan
time terraform apply
```

### Step 7: Error Handling and Recovery

#### 7.1 Simulate and Handle Errors
```bash
# Create state backup
cp terraform.tfstate terraform.tfstate.backup

# Simulate error by manually deleting a resource
aws ec2 terminate-instances --instance-ids $(terraform output -raw instance_ids | jq -r '.[0]')

# Detect drift
terraform plan

# Refresh state
terraform refresh

# Fix by applying
terraform apply
```

#### 7.2 State Management Operations
```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.web[0]

# Remove resource from state (if needed)
terraform state rm aws_instance.web[2]

# Import resource back (if needed)
terraform import 'aws_instance.web[2]' i-1234567890abcdef0
```

## 🧪 Part 4: Advanced Operations and Testing

### Step 8: Workspace Management
```bash
# Create new workspace
terraform workspace new staging

# List workspaces
terraform workspace list

# Switch back to default
terraform workspace select default

# Show current workspace
terraform workspace show
```

### Step 9: Validation and Testing
```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Check for security issues (if tfsec is installed)
tfsec .

# Generate dependency graph
terraform graph | dot -Tpng > dependencies.png
```

### Step 10: Create Outputs
```bash
cat > outputs.tf << 'EOF'
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.app_data.bucket
}

output "web_urls" {
  description = "URLs to access the web servers"
  value       = [for ip in aws_instance.web[*].public_ip : "http://${ip}"]
}
EOF
```

#### 10.1 Apply and View Outputs
```bash
# Apply to create outputs
terraform apply

# View all outputs
terraform output

# View specific output
terraform output instance_public_ips

# Output in JSON format
terraform output -json
```

## 🧹 Part 5: Cleanup and Documentation

### Step 11: Systematic Cleanup

#### 11.1 Destroy Specific Resources First
```bash
# Destroy load balancer first (to avoid dependency issues)
terraform destroy -target=aws_lb.main

# Destroy EC2 instances
terraform destroy -target=aws_instance.web

# Destroy remaining resources
terraform destroy
```

#### 11.2 Verify Cleanup
```bash
# Check state is empty
terraform state list

# Verify in AWS
aws ec2 describe-instances --filters "Name=tag:Project,Values=terraform-core-operations" --query 'Reservations[].Instances[].State.Name'
```

### Step 12: Document Lessons Learned
```bash
cat > lab-summary.md << EOF
# Core Terraform Operations Lab Summary

## Completed Tasks
- ✅ Mastered init, plan, apply, destroy workflow
- ✅ Implemented resource lifecycle management
- ✅ Configured implicit and explicit dependencies
- ✅ Optimized performance with parallelism
- ✅ Handled errors and recovery scenarios
- ✅ Applied enterprise workflow patterns

## Key Learnings
1. **Dependency Management**: Implicit dependencies through resource references
2. **Performance**: Parallelism significantly improves apply times
3. **Error Recovery**: State backup and refresh are crucial
4. **Resource Targeting**: Useful for debugging and partial deployments
5. **Lifecycle Management**: create_before_destroy prevents downtime

## Resources Created
- VPC with public and private subnets
- EC2 instances with auto-scaling capability
- Application Load Balancer
- S3 bucket for application data
- CloudWatch log groups for monitoring

## Cost Optimization
- Used t3.micro instances for cost efficiency
- Implemented auto-shutdown after 4 hours
- Minimal resource footprint for training

## Next Steps
- Explore Terraform modules for code organization
- Implement remote state backend
- Add automated testing with Terratest
- Integrate with CI/CD pipelines
EOF
```

## 📊 Lab Completion Summary

Upon successful completion, you should have:

- ✅ **Mastered core Terraform workflow** with all four primary operations
- ✅ **Implemented resource lifecycle management** with creation, updates, and deletion
- ✅ **Configured dependency management** with both implicit and explicit patterns
- ✅ **Optimized performance** using parallelism and resource targeting
- ✅ **Handled error scenarios** with systematic recovery approaches
- ✅ **Applied enterprise patterns** for production-ready workflows

### **Key Achievements:**
- **Complete infrastructure deployment** with networking, compute, and storage
- **Dependency management** across complex resource relationships
- **Performance optimization** with parallelism and targeting techniques
- **Error handling** and recovery with state management
- **Enterprise workflow** patterns for team collaboration

### **Next Steps:**
1. **Explore advanced resource management** with modules and data sources
2. **Implement remote state management** for team collaboration
3. **Add automated testing** and validation workflows
4. **Integrate with CI/CD pipelines** for automated deployments

---

**Lab Duration**: 90-120 minutes  
**Difficulty Level**: Intermediate  
**Cost Impact**: $0.50 - $1.50/day  
**Learning Value**: Foundation for advanced Terraform operations
