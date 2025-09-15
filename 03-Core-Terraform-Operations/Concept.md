# Core Terraform Operations

## 🎯 Learning Objectives

By the end of this module, you will be able to:

1. **Master the core Terraform workflow** with init, plan, apply, and destroy operations
2. **Understand resource lifecycle management** including creation, updates, and deletion
3. **Implement dependency management** with implicit and explicit dependencies
4. **Optimize Terraform operations** with targeting, parallelism, and performance tuning
5. **Handle errors and recovery** with systematic troubleshooting approaches
6. **Apply enterprise workflow patterns** for team collaboration and production deployments

## 📋 The Core Terraform Workflow

### Modern Terraform Operations (2024-2025)

The Terraform workflow consists of four primary operations that form the foundation of infrastructure management:

#### 1. **terraform init - Initialization and Setup**
```bash
# Basic initialization
terraform init

# Initialize with backend configuration
terraform init -backend-config="bucket=my-state-bucket"

# Upgrade providers to latest versions
terraform init -upgrade

# Reconfigure backend
terraform init -reconfigure
```

**What happens during init:**
- Downloads and installs required providers
- Initializes the backend for state storage
- Creates `.terraform` directory with provider binaries
- Validates provider version constraints
- Sets up workspace configuration

**Enterprise Best Practices:**
```bash
# Initialize with specific provider versions
terraform init -upgrade=false

# Initialize with plugin cache for performance
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
terraform init

# Initialize with backend configuration file
terraform init -backend-config=backend.hcl
```

#### 2. **terraform plan - Preview and Validation**
```bash
# Basic plan operation
terraform plan

# Plan with variable file
terraform plan -var-file="production.tfvars"

# Plan with output to file
terraform plan -out=tfplan

# Plan with specific targets
terraform plan -target=aws_instance.web

# Detailed exit codes for automation
terraform plan -detailed-exitcode
```

**Plan Output Analysis:**
- **Green (+)**: Resources to be created
- **Yellow (~)**: Resources to be modified
- **Red (-)**: Resources to be destroyed
- **Blue (<=)**: Resources to be read during apply

**Advanced Planning Options:**
```bash
# Plan with parallelism control
terraform plan -parallelism=20

# Plan with refresh disabled
terraform plan -refresh=false

# Plan with variable overrides
terraform plan -var="instance_count=5"

# Plan for destroy operation
terraform plan -destroy
```

#### 3. **terraform apply - Infrastructure Deployment**
```bash
# Apply with confirmation prompt
terraform apply

# Apply with auto-approval (automation)
terraform apply -auto-approve

# Apply from saved plan
terraform apply tfplan

# Apply with specific targets
terraform apply -target=aws_instance.web

# Apply with variable overrides
terraform apply -var="environment=production"
```

**Apply Process Flow:**
1. **Refresh State**: Updates state with current infrastructure
2. **Create Plan**: Generates execution plan
3. **User Confirmation**: Prompts for approval (unless auto-approve)
4. **Execute Changes**: Creates, updates, or deletes resources
5. **Update State**: Records changes in state file

**Enterprise Apply Patterns:**
```bash
# Apply with backup state
terraform apply -backup=terraform.tfstate.backup

# Apply with state locking timeout
terraform apply -lock-timeout=10m

# Apply with input disabled for automation
terraform apply -input=false -auto-approve
```

#### 4. **terraform destroy - Infrastructure Cleanup**
```bash
# Destroy all resources
terraform destroy

# Destroy with auto-approval
terraform destroy -auto-approve

# Destroy specific resources
terraform destroy -target=aws_instance.web

# Destroy with variable file
terraform destroy -var-file="production.tfvars"
```

**Destroy Safety Measures:**
```hcl
# Prevent accidental destruction
resource "aws_instance" "critical" {
  # ... configuration ...
  
  lifecycle {
    prevent_destroy = true
  }
}
```

## 🔄 Resource Lifecycle Management

### Understanding Resource States

Resources in Terraform progress through distinct lifecycle phases:

#### 1. **Creation Phase**
```hcl
# New resource definition
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name        = "WebServer"
    Environment = "production"
  }
}
```

**Creation Process:**
- Resource configuration is validated
- Dependencies are resolved
- Provider API calls are made
- Resource is created in AWS
- State file is updated with resource details

#### 2. **Update Phase**
```hcl
# Modified resource configuration
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.small"  # Changed from t3.micro
  
  tags = {
    Name        = "WebServer"
    Environment = "production"
    Owner       = "DevOps Team"  # Added new tag
  }
}
```

**Update Strategies:**
- **In-place updates**: Modify existing resource
- **Replace updates**: Destroy and recreate resource
- **Create-before-destroy**: Create new, then destroy old

#### 3. **Deletion Phase**
Resources are deleted when:
- Removed from configuration
- Explicitly destroyed
- Replaced due to configuration changes

### Resource Meta-Arguments

#### **count - Multiple Resource Instances**
```hcl
resource "aws_instance" "web" {
  count = 3
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "WebServer-${count.index + 1}"
  }
}

# Reference specific instance
output "first_instance_ip" {
  value = aws_instance.web[0].public_ip
}
```

#### **for_each - Dynamic Resource Creation**
```hcl
variable "environments" {
  type = map(object({
    instance_type = string
    ami_id       = string
  }))
  
  default = {
    dev = {
      instance_type = "t3.micro"
      ami_id       = "ami-0c55b159cbfafe1f0"
    }
    prod = {
      instance_type = "t3.medium"
      ami_id       = "ami-0c55b159cbfafe1f0"
    }
  }
}

resource "aws_instance" "app" {
  for_each = var.environments
  
  ami           = each.value.ami_id
  instance_type = each.value.instance_type
  
  tags = {
    Name        = "AppServer-${each.key}"
    Environment = each.key
  }
}
```

#### **lifecycle - Resource Behavior Control**
```hcl
resource "aws_instance" "database" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  
  lifecycle {
    # Create new instance before destroying old one
    create_before_destroy = true
    
    # Prevent accidental destruction
    prevent_destroy = true
    
    # Ignore changes to specific attributes
    ignore_changes = [
      ami,
      user_data
    ]
    
    # Replace resource when specific attributes change
    replace_triggered_by = [
      aws_security_group.web.id
    ]
  }
}
```

## 🔗 Dependency Management

### Implicit Dependencies

Terraform automatically detects dependencies through resource references:

```hcl
# VPC resource
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "MainVPC"
  }
}

# Subnet depends on VPC (implicit)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id  # Creates dependency
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "PublicSubnet"
  }
}

# Internet Gateway depends on VPC (implicit)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Creates dependency
  
  tags = {
    Name = "MainIGW"
  }
}

# Route table depends on VPC and IGW (implicit)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  # Creates dependency
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id  # Creates dependency
  }
  
  tags = {
    Name = "PublicRouteTable"
  }
}
```

### Explicit Dependencies

Use `depends_on` when dependencies aren't visible through resource attributes:

```hcl
# S3 bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "my-app-data-bucket"
}

# IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "EC2AppRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# EC2 instance that needs both S3 bucket and IAM role
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  # Explicit dependencies
  depends_on = [
    aws_s3_bucket.app_data,
    aws_iam_role.ec2_role
  ]
  
  tags = {
    Name = "AppServer"
  }
}
```

### Dependency Graph Visualization

```bash
# Generate dependency graph
terraform graph | dot -Tpng > graph.png

# Generate dependency graph in DOT format
terraform graph > dependencies.dot
```

## ⚡ Performance Optimization

### Parallelism Control

```bash
# Increase parallelism for faster operations
terraform apply -parallelism=20

# Reduce parallelism for rate-limited APIs
terraform apply -parallelism=5

# Set default parallelism via environment
export TF_CLI_ARGS_apply="-parallelism=15"
export TF_CLI_ARGS_plan="-parallelism=15"
```

### Provider Caching

```bash
# Enable provider caching
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR

# Configure in .terraformrc
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
```

### Resource Targeting

```bash
# Target specific resources for faster operations
terraform plan -target=aws_instance.web
terraform apply -target=aws_instance.web

# Target multiple resources
terraform apply -target=aws_instance.web -target=aws_security_group.web

# Target entire modules
terraform apply -target=module.networking
```

## 🔧 Advanced Operations

### State Refresh

```bash
# Refresh state without applying changes
terraform refresh

# Plan with refresh disabled
terraform plan -refresh=false

# Apply with refresh disabled
terraform apply -refresh=false
```

### Import Existing Resources

```bash
# Import existing AWS instance
terraform import aws_instance.web i-1234567890abcdef0

# Import with specific provider
terraform import -provider=aws.us_west aws_instance.web i-1234567890abcdef0
```

### Workspace Management

```bash
# Create new workspace
terraform workspace new production

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select production

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete staging
```

## 🛠️ Error Handling and Recovery

### Common Error Patterns

#### 1. **Resource Already Exists**
```bash
# Error: Resource already exists
# Solution: Import existing resource
terraform import aws_instance.web i-1234567890abcdef0
```

#### 2. **State Lock Errors**
```bash
# Error: State is locked
# Solution: Force unlock (use carefully)
terraform force-unlock LOCK_ID
```

#### 3. **Provider Version Conflicts**
```bash
# Error: Provider version constraint
# Solution: Update provider constraints
terraform init -upgrade
```

### Recovery Strategies

#### **State Backup and Recovery**
```bash
# Create state backup before risky operations
cp terraform.tfstate terraform.tfstate.backup

# Restore from backup if needed
cp terraform.tfstate.backup terraform.tfstate
```

#### **Partial Apply Recovery**
```bash
# If apply fails partially, check state
terraform state list

# Show specific resource state
terraform state show aws_instance.web

# Remove problematic resource from state
terraform state rm aws_instance.problematic

# Re-import if necessary
terraform import aws_instance.problematic i-1234567890abcdef0
```

## 📊 Monitoring and Logging

### Enable Detailed Logging

```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH="./terraform.log"

# Different log levels
export TF_LOG=TRACE  # Most verbose
export TF_LOG=DEBUG
export TF_LOG=INFO
export TF_LOG=WARN
export TF_LOG=ERROR
```

### Performance Monitoring

```bash
# Time operations
time terraform plan
time terraform apply

# Monitor resource creation
terraform apply | tee apply.log
```

## 🎯 Enterprise Workflow Patterns

### CI/CD Integration

```bash
# Automated validation pipeline
terraform fmt -check
terraform validate
terraform plan -detailed-exitcode

# Exit codes:
# 0 = No changes
# 1 = Error
# 2 = Changes present
```

### Team Collaboration

```bash
# Lock state for exclusive access
terraform apply -lock=true -lock-timeout=10m

# Use consistent formatting
terraform fmt -recursive

# Validate before commit
terraform validate
```

### Production Deployment

```bash
# Production-safe workflow
terraform plan -out=production.tfplan
# Review plan thoroughly
terraform apply production.tfplan
```

---

**Figure References:**
- Figure 3.1: Terraform Core Workflow (see `../DaC/generated_diagrams/core_workflow.png`)
- Figure 3.2: Resource Lifecycle States (see `../DaC/generated_diagrams/resource_lifecycle.png`)
- Figure 3.3: Dependency Graph Example (see `../DaC/generated_diagrams/dependency_graph.png`)
- Figure 3.4: Performance Optimization (see `../DaC/generated_diagrams/performance_optimization.png`)
- Figure 3.5: Error Recovery Patterns (see `../DaC/generated_diagrams/error_recovery.png`)
