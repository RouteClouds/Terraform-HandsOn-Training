# Core Terraform Operations

## 🎯 Learning Objectives

By the end of this module, you will be able to:

1. **Master the core Terraform workflow** with init, plan, apply, and destroy operations
2. **Understand resource lifecycle management** including creation, updates, and deletion
3. **Implement dependency management** with implicit and explicit dependencies
4. **Optimize Terraform operations** with targeting, parallelism, and performance tuning
5. **Handle errors and recovery** with systematic troubleshooting approaches
6. **Apply enterprise workflow patterns** for team collaboration and production deployments

🎓 **Certification Note**: The Terraform workflow is critical for the exam. Remember: init → validate → plan → apply → destroy. Know what each command does and when to use it.
**Exam Objectives 3.1, 3.2, 3.3, 6.1, 6.2**: Core operations and workflow

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

💡 **Exam Tip**: Always run `terraform plan` before `terraform apply` to review changes. The exam expects you to know that plan shows what will change without actually making changes.
**Exam Objective 3.3**: Generate and review an execution plan

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

![Figure 3.1: Terraform Core Workflow](DaC/generated_diagrams/figure_3_1_terraform_core_workflow.png)
*Figure 3.1: Complete Terraform core workflow showing the sequence of init, validate, plan, apply, and destroy operations with their respective purposes, outputs, and best practices for enterprise infrastructure management*

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

![Figure 3.2: Resource Lifecycle States](DaC/generated_diagrams/figure_3_2_resource_lifecycle.png)
*Figure 3.2: Detailed resource lifecycle state diagram showing the complete journey of Terraform resources through creation, update, and deletion phases, including in-place updates, replacement strategies, and lifecycle meta-arguments*

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

![Figure 3.3: Dependency Graph Example](DaC/generated_diagrams/figure_3_3_dependency_graph.png)
*Figure 3.3: Comprehensive dependency graph visualization showing implicit and explicit dependencies between AWS resources including VPC, subnets, internet gateways, route tables, security groups, and EC2 instances with their relationship flows*

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

![Figure 3.4: Performance Optimization](DaC/generated_diagrams/figure_3_4_performance_optimization.png)
*Figure 3.4: Terraform performance optimization strategies including parallelism control, provider caching, resource targeting, and best practices for managing large-scale infrastructure deployments efficiently*

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

![Figure 3.5: Error Recovery Patterns](DaC/generated_diagrams/figure_3_5_error_recovery.png)
*Figure 3.5: Comprehensive error handling and recovery patterns for Terraform operations including state lock resolution, resource import strategies, partial apply recovery, and systematic troubleshooting workflows*

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

## 🆕 **Terraform 1.13 New Features (2025)**

### **Enhanced Stacks Command**

Terraform 1.13 introduces the new `stacks` command for managing multiple related configurations:

```bash
# Initialize a new stack
terraform stacks init

# Plan across multiple configurations
terraform stacks plan

# Apply changes to all stack components
terraform stacks apply

# List all stacks in the workspace
terraform stacks list
```

**Stack Configuration Example**:
```hcl
# stack.tf
stack "infrastructure" {
  source = "./infrastructure"

  inputs = {
    environment = "production"
    region      = "us-east-1"
  }
}

stack "applications" {
  source = "./applications"

  inputs = {
    vpc_id = stack.infrastructure.outputs.vpc_id
    environment = "production"
  }

  depends_on = [stack.infrastructure]
}
```

### **Improved Validation Framework**

Enhanced validation capabilities with better error messages and performance:

```bash
# Enhanced validation with detailed output
terraform validate -json

# Validate with experimental features
terraform validate -experimental-features

# Validate specific modules
terraform validate -target=module.vpc
```

**Advanced Validation Rules**:
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition = can(regex("^[tm][0-9]+\\.", var.instance_type))
    error_message = "Instance type must be from t or m series (e.g., t3.micro, m5.large)."
  }

  validation {
    condition = !contains(["t1.micro", "m1.small"], var.instance_type)
    error_message = "Legacy instance types are not supported."
  }
}
```

### **Enhanced Plan Output and Analysis**

Terraform 1.13 provides more detailed plan analysis:

```bash
# Generate plan with enhanced output
terraform plan -detailed-exitcode -json > plan.json

# Analyze plan changes
terraform show -json plan.tfplan | jq '.resource_changes[] | select(.change.actions[] == "create")'

# Plan with resource targeting improvements
terraform plan -target=module.vpc -target=module.security_groups
```

### **Improved State Management**

Enhanced state operations with better performance and safety:

```bash
# Enhanced state operations
terraform state list -id=aws_instance.web

# Improved state migration
terraform state mv -dry-run aws_instance.old aws_instance.new

# State backup with versioning
terraform state pull > state-backup-$(date +%Y%m%d-%H%M%S).json
```

## 💰 **Business Value and ROI Analysis**

### **Core Terraform Operations ROI**

**Investment Analysis**:
- **Learning Curve**: 20-40 hours initial training
- **Tool Setup**: 2-4 hours environment configuration
- **Process Implementation**: 1-2 weeks workflow establishment
- **Team Training**: $1,000-2,000 per team member

**Return on Investment**:

| Benefit Category | Manual Operations | Terraform Operations | Improvement |
|------------------|------------------|---------------------|-------------|
| **Deployment Speed** | 2-4 hours | 10-30 minutes | 80-90% faster |
| **Error Rate** | 20-30% human errors | <3% configuration errors | 90% reduction |
| **Consistency** | 60% environment drift | 95% consistency | 58% improvement |
| **Rollback Time** | 1-4 hours | 5-15 minutes | 85% faster |
| **Documentation** | Manual, often outdated | Self-documenting code | 100% accuracy |

**Annual Value Creation**:
- **Operational Efficiency**: $75,000-150,000 per team
- **Error Prevention**: $30,000-80,000 in avoided incidents
- **Compliance Automation**: $40,000-70,000 in audit efficiency
- **Infrastructure Consistency**: $25,000-50,000 in operational savings
- **Total Annual Value**: $170,000-350,000 per development team

### **Enterprise Success Metrics**

**Operational Excellence**:
- **Mean Time to Deployment**: Reduced from 2 hours to 15 minutes
- **Infrastructure Drift**: Reduced from 40% to <5%
- **Change Success Rate**: Improved from 70% to 97%
- **Recovery Time**: Reduced from 2 hours to 10 minutes
- **Team Productivity**: 250% increase in infrastructure velocity

**Strategic Benefits**:
- **Scalability**: Support for 5x infrastructure growth without team expansion
- **Innovation**: 50% more time available for feature development
- **Risk Reduction**: 92% reduction in deployment-related incidents
- **Competitive Advantage**: 4-month faster time-to-market
- **Cost Optimization**: 30% reduction in infrastructure operational costs

## 🎯 **2025 Best Practices Summary**

### **Modern Workflow Checklist**

- ✅ **Version Management**: Use Terraform ~> 1.13.0 with latest features
- ✅ **Stacks Integration**: Implement stack-based architecture for complex deployments
- ✅ **Enhanced Validation**: Use advanced validation rules and JSON output
- ✅ **State Security**: Implement encrypted remote state with versioning
- ✅ **Performance Optimization**: Use parallelism and resource targeting
- ✅ **Error Recovery**: Implement comprehensive backup and recovery procedures
- ✅ **CI/CD Integration**: Automate workflows with modern pipeline tools
- ✅ **Monitoring**: Implement comprehensive logging and alerting
- ✅ **Team Collaboration**: Use state locking and consistent formatting
- ✅ **Documentation**: Maintain self-documenting infrastructure code

### **Enterprise Adoption Strategy**

**Phase 1: Foundation (Weeks 1-2)**
- Establish core workflow patterns
- Implement state management and security
- Train team on basic operations

**Phase 2: Optimization (Weeks 3-4)**
- Implement performance optimizations
- Establish error recovery procedures
- Integrate with CI/CD pipelines

**Phase 3: Scale (Weeks 5-8)**
- Deploy stack-based architecture
- Implement advanced monitoring
- Establish enterprise governance

---

*This comprehensive guide provides the foundation for mastering Terraform core operations, enabling teams to achieve operational excellence while maximizing business value and return on investment through modern infrastructure automation.*
