# Lab 4: Resource Management & Dependencies

## 🎯 **Lab Objectives**

By completing this comprehensive hands-on lab, you will demonstrate advanced mastery of:

1. **Dependency Graph Management** - Build and analyze complex dependency relationships between resources
2. **Advanced Lifecycle Control** - Implement sophisticated lifecycle management patterns for enterprise scenarios
3. **Meta-Argument Mastery** - Utilize advanced meta-argument combinations for complex resource management
4. **Resource Targeting Strategies** - Execute precise, selective operations for efficient infrastructure management
5. **Dependency Troubleshooting** - Diagnose and resolve complex dependency issues in production-like environments

### **Measurable Outcomes**
- **100% successful** dependency graph analysis and management
- **98% accuracy** in implementing advanced lifecycle patterns
- **95% efficiency** in resource targeting and selective operations
- **100% compliance** with enterprise resource management standards

---

## 📋 **Lab Scenario**

### **Business Context**
You are a Senior Cloud Architect at FinTech Innovations, a rapidly scaling financial services company processing $2B in annual transactions. The company is migrating from a monolithic architecture to a microservices-based platform requiring sophisticated resource management and dependency orchestration. Your current challenges include:

- **Complex Dependencies**: Managing intricate relationships between 100+ AWS resources across multiple tiers
- **Zero-Downtime Deployments**: Ensuring continuous availability during infrastructure updates
- **Resource Optimization**: Implementing efficient targeting strategies for large-scale operations
- **Compliance Requirements**: Meeting strict financial industry regulations for infrastructure management

### **Success Criteria**
Your task is to implement an advanced Terraform solution that achieves:
- **Zero dependency conflicts** across all resource relationships
- **99.99% availability** through proper lifecycle management and deployment strategies
- **75% reduction** in deployment time through efficient resource targeting
- **100% compliance** with financial industry security and governance standards

![Figure 4.1: Dependency Graph and Resource Relationships](DaC/generated_diagrams/figure_4_1_dependency_graph_relationships.png)
*Figure 4.1: The complex dependency graph you'll implement and manage in this lab*

---

## 🛠️ **Prerequisites and Setup**

### **Required Tools and Versions**
- **Operating System**: Windows 10+, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **Terraform CLI**: Version ~> 1.13.0 (installed and configured from previous labs)
- **AWS CLI**: Version 2.15.0+ with configured credentials
- **Git**: Version 2.40+ for version control and dependency tracking
- **Text Editor**: VS Code with HashiCorp Terraform extension v2.29.0+
- **Graphviz**: For dependency graph visualization

### **AWS Account Requirements**
- **AWS Account**: Active AWS account with administrative access
- **IAM Permissions**: Full access to EC2, VPC, RDS, S3, IAM, CloudWatch, and Auto Scaling
- **Budget Alert**: $50 monthly budget configured for lab resources
- **Region**: All resources will be created in us-east-1
- **Key Pair**: EC2 key pair for SSH access (create if not exists)

### **Pre-Lab Verification**
```bash
# Verify Terraform installation and version
terraform version
# Expected: Terraform v1.13.x

# Verify AWS CLI configuration
aws sts get-caller-identity
aws configure get region
# Expected: us-east-1

# Install Graphviz for dependency visualization
# Ubuntu/Debian:
sudo apt-get install graphviz
# macOS:
brew install graphviz
# Windows: Download from https://graphviz.org/download/

# Verify Graphviz installation
dot -V
# Expected: graphviz version 2.40+
```

---

## 🚀 **Lab Exercise 1: Complex Dependency Graph Implementation**

### **Objective**
Master dependency graph analysis and implementation through hands-on creation of a multi-tier financial services platform.

![Figure 4.2: Lifecycle Management and State Transitions](DaC/generated_diagrams/figure_4_2_lifecycle_management_transitions.png)
*Figure 4.2: Advanced lifecycle management patterns you'll implement*

### **Exercise 1.1: Foundation Infrastructure with Implicit Dependencies**

#### **Create Project Structure**
```bash
# Create lab directory structure
mkdir -p terraform-resource-management-lab/{modules/{network,security,database,application},environments/{dev,staging,prod}}
cd terraform-resource-management-lab

# Create main configuration files
touch {main.tf,variables.tf,outputs.tf,locals.tf,data.tf,versions.tf}
```

#### **Configure Provider and Data Sources**
```hcl
# versions.tf - Provider configuration
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
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      LabTopic    = "resource-management-dependencies"
      LabVersion  = "4.1"
    }
  }
}

# data.tf - Data sources for dependency analysis
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

#### **Define Complex Variable Structure**
```hcl
# variables.tf - Advanced variable definitions
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource identification"
  type        = string
  default     = "fintech-platform"
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

# Complex application configuration
variable "applications" {
  description = "Application tier configurations"
  type = map(object({
    instance_type     = string
    min_capacity      = number
    max_capacity      = number
    desired_capacity  = number
    health_check_path = string
    port              = number
    protocol          = string
    environment_vars  = map(string)
    security_groups   = list(string)
    subnets          = string
    enable_monitoring = bool
    backup_required   = bool
    dependencies     = list(string)
  }))
  
  default = {
    web = {
      instance_type     = "t3.medium"
      min_capacity      = 2
      max_capacity      = 10
      desired_capacity  = 3
      health_check_path = "/health"
      port              = 80
      protocol          = "HTTP"
      environment_vars = {
        APP_ENV = "production"
        LOG_LEVEL = "info"
      }
      security_groups   = ["web", "common"]
      subnets          = "public"
      enable_monitoring = true
      backup_required   = false
      dependencies     = []
    }
    api = {
      instance_type     = "t3.large"
      min_capacity      = 3
      max_capacity      = 15
      desired_capacity  = 5
      health_check_path = "/api/health"
      port              = 8080
      protocol          = "HTTP"
      environment_vars = {
        APP_ENV = "production"
        LOG_LEVEL = "warn"
        DB_POOL_SIZE = "20"
      }
      security_groups   = ["api", "database", "common"]
      subnets          = "private"
      enable_monitoring = true
      backup_required   = true
      dependencies     = ["database"]
    }
    worker = {
      instance_type     = "t3.xlarge"
      min_capacity      = 1
      max_capacity      = 5
      desired_capacity  = 2
      health_check_path = "/worker/health"
      port              = 9090
      protocol          = "HTTP"
      environment_vars = {
        APP_ENV = "production"
        LOG_LEVEL = "debug"
        WORKER_THREADS = "8"
      }
      security_groups   = ["worker", "database", "queue", "common"]
      subnets          = "private"
      enable_monitoring = true
      backup_required   = true
      dependencies     = ["database", "queue"]
    }
  }
}

# Database configuration
variable "database_config" {
  description = "Database configuration"
  type = object({
    engine                  = string
    engine_version         = string
    instance_class         = string
    allocated_storage      = number
    max_allocated_storage  = number
    backup_retention_period = number
    backup_window         = string
    maintenance_window    = string
    multi_az              = bool
    storage_encrypted     = bool
    deletion_protection   = bool
  })
  
  default = {
    engine                  = "mysql"
    engine_version         = "8.0"
    instance_class         = "db.t3.medium"
    allocated_storage      = 100
    max_allocated_storage  = 1000
    backup_retention_period = 30
    backup_window         = "03:00-04:00"
    maintenance_window    = "sun:04:00-sun:05:00"
    multi_az              = true
    storage_encrypted     = true
    deletion_protection   = true
  }
}

# Feature flags for conditional resources
variable "feature_flags" {
  description = "Feature flags for optional resources"
  type = object({
    enable_monitoring     = bool
    enable_backup        = bool
    enable_cdn           = bool
    enable_waf           = bool
    enable_elasticsearch = bool
    enable_redis_cache   = bool
    enable_queue         = bool
  })
  
  default = {
    enable_monitoring     = true
    enable_backup        = true
    enable_cdn           = false
    enable_waf           = true
    enable_elasticsearch = false
    enable_redis_cache   = true
    enable_queue         = true
  }
}
```

#### **Implement Local Values for Dependency Management**
```hcl
# locals.tf - Complex local values and dependency management
locals {
  # Environment and project configuration
  environment = var.environment
  project     = var.project_name
  region      = data.aws_region.current.name
  account_id  = data.aws_caller_identity.current.account_id
  
  # Availability zones (use first 3)
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  az_count          = length(local.availability_zones)
  
  # Resource naming conventions
  name_prefix = "${local.environment}-${local.project}"
  
  # Network configuration
  vpc_cidr = "10.0.0.0/16"
  
  # Calculate subnet CIDRs
  public_subnet_cidrs = [
    for i in range(local.az_count) :
    cidrsubnet(local.vpc_cidr, 8, i)
  ]
  
  private_subnet_cidrs = [
    for i in range(local.az_count) :
    cidrsubnet(local.vpc_cidr, 8, i + 10)
  ]
  
  database_subnet_cidrs = [
    for i in range(local.az_count) :
    cidrsubnet(local.vpc_cidr, 8, i + 20)
  ]
  
  # Security group configurations
  security_groups = {
    web = {
      name        = "web"
      description = "Security group for web servers"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP from internet"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS from internet"
        }
      ]
    }
    api = {
      name        = "api"
      description = "Security group for API servers"
      ingress_rules = [
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "API port from VPC"
        }
      ]
    }
    worker = {
      name        = "worker"
      description = "Security group for worker servers"
      ingress_rules = [
        {
          from_port   = 9090
          to_port     = 9090
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "Worker port from VPC"
        }
      ]
    }
    database = {
      name        = "database"
      description = "Security group for database servers"
      ingress_rules = [
        {
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "MySQL from VPC"
        }
      ]
    }
    queue = {
      name        = "queue"
      description = "Security group for queue services"
      ingress_rules = [
        {
          from_port   = 5672
          to_port     = 5672
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "RabbitMQ from VPC"
        }
      ]
    }
    common = {
      name        = "common"
      description = "Common security group for all servers"
      ingress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
          description = "SSH from VPC"
        }
      ]
    }
  }
  
  # Dependency analysis
  dependency_order = [
    "network",     # VPC, subnets, gateways
    "security",    # Security groups
    "database",    # RDS, ElastiCache
    "queue",       # SQS, SNS
    "application"  # EC2, ALB, ASG
  ]
  
  # Common tags
  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "terraform"
    Region      = local.region
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    LabTopic    = "resource-management-dependencies"
  }
}
```

### **Exercise 1.2: Network Infrastructure with Implicit Dependencies**

#### **Create VPC and Network Resources**
```hcl
# main.tf - Network infrastructure with implicit dependencies
# VPC (foundation resource)
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
    Type = "network"
    Tier = "foundation"
  })
}

# Internet Gateway (implicitly depends on VPC)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Implicit dependency

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
    Type = "network"
    Tier = "foundation"
  })
}

# Public Subnets (implicitly depend on VPC)
resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id                  = aws_vpc.main.id  # Implicit dependency
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    Type = "public"
    AZ   = local.availability_zones[count.index]
    Tier = "network"
  })
}

# Private Subnets (implicitly depend on VPC)
resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.main.id  # Implicit dependency
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
    Type = "private"
    AZ   = local.availability_zones[count.index]
    Tier = "network"
  })
}

# Database Subnets (implicitly depend on VPC)
resource "aws_subnet" "database" {
  count = local.az_count

  vpc_id            = aws_vpc.main.id  # Implicit dependency
  cidr_block        = local.database_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-subnet-${count.index + 1}"
    Type = "database"
    AZ   = local.availability_zones[count.index]
    Tier = "data"
  })
}

# Elastic IPs for NAT Gateways (implicitly depend on IGW)
resource "aws_eip" "nat" {
  count = local.az_count

  domain = "vpc"

  depends_on = [aws_internet_gateway.main]  # Explicit dependency

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    Type = "network"
    AZ   = local.availability_zones[count.index]
  })
}

# NAT Gateways (implicitly depend on public subnets and EIPs)
resource "aws_nat_gateway" "main" {
  count = local.az_count

  allocation_id = aws_eip.nat[count.index].id      # Implicit dependency
  subnet_id     = aws_subnet.public[count.index].id # Implicit dependency

  depends_on = [aws_internet_gateway.main]  # Explicit dependency

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-gateway-${count.index + 1}"
    Type = "network"
    AZ   = local.availability_zones[count.index]
  })
}
```

#### **Create Security Groups with Complex Dependencies**
```hcl
# Security Groups (implicitly depend on VPC)
resource "aws_security_group" "main" {
  for_each = local.security_groups

  name_prefix = "${local.name_prefix}-${each.key}-"
  description = each.value.description
  vpc_id      = aws_vpc.main.id  # Implicit dependency

  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Common egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}-sg"
    Type = "security"
    Tier = each.key
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Cross-security group rules (explicit dependencies)
resource "aws_security_group_rule" "web_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.main["web"].id
  security_group_id        = aws_security_group.main["api"].id
  description              = "API access from web tier"
}

resource "aws_security_group_rule" "api_from_worker" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.main["worker"].id
  security_group_id        = aws_security_group.main["api"].id
  description              = "API access from worker tier"
}
```

### **Exercise 1.3: Dependency Graph Analysis**

#### **Generate and Analyze Dependency Graph**
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Generate dependency graph
terraform graph > dependency_graph.dot

# Convert to PNG for visualization
dot -Tpng dependency_graph.dot -o dependency_graph.png

# Generate plan to see dependency order
terraform plan -out=tfplan

# Analyze the plan
terraform show -json tfplan | jq '.planned_values.root_module.resources[] | {address: .address, type: .type, name: .name}'
```

#### **Dependency Analysis Exercise**
```bash
# Create dependency analysis script
cat > analyze_dependencies.sh << 'EOF'
#!/bin/bash

echo "=== Terraform Dependency Analysis ==="
echo

echo "1. Resource Count by Type:"
terraform state list | cut -d. -f1 | sort | uniq -c | sort -nr

echo
echo "2. Implicit Dependencies (resource references):"
grep -r "aws_.*\." *.tf | grep -v "data\." | grep -v "resource \"" | head -10

echo
echo "3. Explicit Dependencies (depends_on):"
grep -r "depends_on" *.tf

echo
echo "4. Lifecycle Rules:"
grep -A 5 -B 1 "lifecycle" *.tf

echo
echo "5. Meta-Arguments Usage:"
echo "  - count: $(grep -c "count =" *.tf)"
echo "  - for_each: $(grep -c "for_each =" *.tf)"
echo "  - depends_on: $(grep -c "depends_on =" *.tf)"
echo "  - lifecycle: $(grep -c "lifecycle {" *.tf)"

EOF

chmod +x analyze_dependencies.sh
./analyze_dependencies.sh
```

---

## ⚙️ **Lab Exercise 2: Advanced Lifecycle Management**

### **Objective**
Implement sophisticated lifecycle management patterns for zero-downtime deployments and enterprise-grade infrastructure management.

![Figure 4.3: Meta-Arguments and Advanced Control](DaC/generated_diagrams/figure_4_3_meta_arguments_control.png)
*Figure 4.3: Advanced meta-argument patterns you'll implement*

### **Exercise 2.1: Database with Lifecycle Protection**

#### **Create Protected Database Infrastructure**
```hcl
# Database subnet group (implicitly depends on database subnets)
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id  # Implicit dependency

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
    Type = "database"
    Tier = "data"
  })
}

# KMS key for database encryption
resource "aws_kms_key" "database" {
  description             = "KMS key for database encryption"
  deletion_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-kms-key"
    Type = "security"
    Purpose = "database-encryption"
  })
}

resource "aws_kms_alias" "database" {
  name          = "alias/${local.name_prefix}-database"
  target_key_id = aws_kms_key.database.key_id
}

# Production database with comprehensive lifecycle protection
resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-main-db"

  # Engine configuration
  engine         = var.database_config.engine
  engine_version = var.database_config.engine_version
  instance_class = var.database_config.instance_class

  # Storage configuration
  allocated_storage     = var.database_config.allocated_storage
  max_allocated_storage = var.database_config.max_allocated_storage
  storage_encrypted     = var.database_config.storage_encrypted
  kms_key_id           = aws_kms_key.database.arn

  # Database configuration
  db_name  = "fintech_db"
  username = "admin"
  password = "changeme123!"  # In production, use AWS Secrets Manager

  # Network configuration (implicit dependencies)
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main["database"].id]

  # Backup and maintenance
  backup_retention_period = var.database_config.backup_retention_period
  backup_window          = var.database_config.backup_window
  maintenance_window     = var.database_config.maintenance_window

  # High availability
  multi_az = var.database_config.multi_az

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval         = 60

  # Deletion protection
  deletion_protection = var.database_config.deletion_protection
  skip_final_snapshot = false
  final_snapshot_identifier = "${local.name_prefix}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Advanced lifecycle management
  lifecycle {
    prevent_destroy = true  # Prevent accidental destruction
    ignore_changes = [
      password,              # Ignore password changes
      latest_restorable_time,
      final_snapshot_identifier
    ]
  }

  # Explicit dependencies for proper ordering
  depends_on = [
    aws_db_subnet_group.main,
    aws_security_group.main,
    aws_kms_key.database
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-main-database"
    Type = "database"
    Critical = "true"
    Tier = "data"
  })
}
```

### **Exercise 2.2: Application Infrastructure with Rolling Updates**

#### **Create Launch Templates with Lifecycle Management**
```hcl
# Launch templates for each application tier
resource "aws_launch_template" "apps" {
  for_each = var.applications

  name_prefix   = "${local.name_prefix}-${each.key}-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type
  key_name      = "terraform-lab-key"

  # Security group assignment (implicit dependencies)
  vpc_security_group_ids = [
    for sg_name in each.value.security_groups :
    aws_security_group.main[sg_name].id
  ]

  # User data with environment variables
  user_data = base64encode(templatefile("${path.module}/user_data/${each.key}.sh", {
    environment_vars = each.value.environment_vars
    app_name        = each.key
    database_endpoint = aws_db_instance.main.endpoint
  }))

  # Monitoring configuration
  monitoring {
    enabled = each.value.enable_monitoring
  }

  # Instance metadata service configuration
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 1
  }

  # Lifecycle management for rolling updates
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name        = "${local.name_prefix}-${each.key}-instance"
      Application = each.key
      Tier        = each.key
      Monitoring  = each.value.enable_monitoring ? "enabled" : "disabled"
    })
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main["web"].id]
  subnets            = aws_subnet.public[*].id  # Implicit dependency

  enable_deletion_protection = false

  # Lifecycle management for smooth updates
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
    Type = "load-balancer"
    Tier = "network"
  })
}

# Target groups for each application
resource "aws_lb_target_group" "apps" {
  for_each = var.applications

  name     = "${local.name_prefix}-${each.key}-tg"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = aws_vpc.main.id  # Implicit dependency

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = each.value.health_check_path
    matcher             = "200"
    protocol            = each.value.protocol
  }

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-${each.key}-target-group"
    Application = each.key
    Type        = "load-balancer"
  })
}

# Auto Scaling Groups with advanced lifecycle management
resource "aws_autoscaling_group" "apps" {
  for_each = var.applications

  name                = "${local.name_prefix}-${each.key}-asg"
  vpc_zone_identifier = each.value.subnets == "public" ? aws_subnet.public[*].id : aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.apps[each.key].arn]

  min_size         = each.value.min_capacity
  max_size         = each.value.max_capacity
  desired_capacity = each.value.desired_capacity

  # Health check configuration
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.apps[each.key].id
    version = "$Latest"
  }

  # Instance refresh for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup       = 300
      checkpoint_delay       = 600
    }
    triggers = ["tag"]
  }

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity  # Allow auto scaling to manage capacity
    ]
  }

  # Explicit dependencies for proper ordering
  depends_on = [
    aws_db_instance.main,  # Ensure database is ready
    aws_lb_target_group.apps
  ]

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-${each.key}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = each.key
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = each.key
    propagate_at_launch = true
  }

  tag {
    key                 = "BackupRequired"
    value               = each.value.backup_required ? "true" : "false"
    propagate_at_launch = true
  }
}
```

### **Exercise 2.3: Conditional Resources with Feature Flags**

#### **Implement Feature Flag-Based Resources**
```hcl
# Conditional ElastiCache cluster
resource "aws_elasticache_subnet_group" "main" {
  count = var.feature_flags.enable_redis_cache ? 1 : 0

  name       = "${local.name_prefix}-cache-subnet"
  subnet_ids = aws_subnet.private[*].id  # Implicit dependency
}

resource "aws_elasticache_cluster" "main" {
  count = var.feature_flags.enable_redis_cache ? 1 : 0

  cluster_id           = "${local.name_prefix}-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main[0].name
  security_group_ids   = [aws_security_group.main["queue"].id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cache"
    Type = "cache"
    Tier = "data"
  })
}

# Conditional CloudWatch monitoring
resource "aws_cloudwatch_dashboard" "main" {
  count = var.feature_flags.enable_monitoring ? 1 : 0

  dashboard_name = "${local.name_prefix}-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Application Load Balancer Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.main.id],
            [".", "DatabaseConnections", ".", "."],
            [".", "ReadLatency", ".", "."],
            [".", "WriteLatency", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Database Metrics"
          period  = 300
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-dashboard"
    Type = "monitoring"
  })
}

# Conditional backup resources
resource "aws_backup_vault" "main" {
  count = var.feature_flags.enable_backup ? 1 : 0

  name        = "${local.name_prefix}-backup-vault"
  kms_key_arn = aws_kms_key.backup[0].arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backup-vault"
    Type = "backup"
  })
}

resource "aws_kms_key" "backup" {
  count = var.feature_flags.enable_backup ? 1 : 0

  description             = "KMS key for backup encryption"
  deletion_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backup-kms-key"
    Type = "security"
    Purpose = "backup-encryption"
  })
}
```

---

## 🎯 **Lab Exercise 3: Resource Targeting and Selective Operations**

### **Objective**
Master resource targeting strategies for efficient infrastructure management and precise operational control.

![Figure 4.4: Resource Targeting and Selective Operations](DaC/generated_diagrams/figure_4_4_resource_targeting_operations.png)
*Figure 4.4: Resource targeting strategies you'll implement*

### **Exercise 3.1: Basic Resource Targeting**

#### **Single Resource Targeting**
```bash
# Apply only VPC and related network resources
terraform apply -target=aws_vpc.main

# Apply only security groups
terraform apply -target=aws_security_group.main

# Apply specific application tier
terraform apply -target=aws_autoscaling_group.apps["web"]

# Apply database infrastructure only
terraform apply -target=aws_db_instance.main
```

#### **Multiple Resource Targeting**
```bash
# Apply network foundation (VPC, subnets, gateways)
terraform apply \
  -target=aws_vpc.main \
  -target=aws_subnet.public \
  -target=aws_subnet.private \
  -target=aws_internet_gateway.main \
  -target=aws_nat_gateway.main

# Apply security infrastructure
terraform apply \
  -target=aws_security_group.main \
  -target=aws_security_group_rule.web_from_alb \
  -target=aws_security_group_rule.api_from_worker

# Apply application infrastructure for specific tier
terraform apply \
  -target=aws_launch_template.apps["api"] \
  -target=aws_autoscaling_group.apps["api"] \
  -target=aws_lb_target_group.apps["api"]
```

### **Exercise 3.2: Advanced Targeting Scenarios**

#### **Environment-Specific Targeting**
```bash
# Create targeting script for different scenarios
cat > target_operations.sh << 'EOF'
#!/bin/bash

# Function to apply network infrastructure
apply_network() {
    echo "Applying network infrastructure..."
    terraform apply -auto-approve \
        -target=aws_vpc.main \
        -target=aws_subnet.public \
        -target=aws_subnet.private \
        -target=aws_subnet.database \
        -target=aws_internet_gateway.main \
        -target=aws_eip.nat \
        -target=aws_nat_gateway.main
}

# Function to apply security infrastructure
apply_security() {
    echo "Applying security infrastructure..."
    terraform apply -auto-approve \
        -target=aws_security_group.main \
        -target=aws_security_group_rule.web_from_alb \
        -target=aws_security_group_rule.api_from_worker
}

# Function to apply data infrastructure
apply_data() {
    echo "Applying data infrastructure..."
    terraform apply -auto-approve \
        -target=aws_kms_key.database \
        -target=aws_kms_alias.database \
        -target=aws_db_subnet_group.main \
        -target=aws_db_instance.main
}

# Function to apply application infrastructure
apply_application() {
    local app_name=$1
    echo "Applying application infrastructure for: $app_name"
    terraform apply -auto-approve \
        -target=aws_launch_template.apps[\"$app_name\"] \
        -target=aws_lb_target_group.apps[\"$app_name\"] \
        -target=aws_autoscaling_group.apps[\"$app_name\"]
}

# Function to apply conditional resources
apply_conditional() {
    echo "Applying conditional resources..."
    terraform apply -auto-approve \
        -target=aws_elasticache_subnet_group.main \
        -target=aws_elasticache_cluster.main \
        -target=aws_cloudwatch_dashboard.main \
        -target=aws_backup_vault.main
}

# Main execution
case "$1" in
    network)
        apply_network
        ;;
    security)
        apply_security
        ;;
    data)
        apply_data
        ;;
    app)
        apply_application "$2"
        ;;
    conditional)
        apply_conditional
        ;;
    all)
        apply_network
        apply_security
        apply_data
        apply_application "web"
        apply_application "api"
        apply_application "worker"
        apply_conditional
        ;;
    *)
        echo "Usage: $0 {network|security|data|app <app_name>|conditional|all}"
        echo "Available apps: web, api, worker"
        exit 1
        ;;
esac

EOF

chmod +x target_operations.sh
```

### **Exercise 3.3: Production Deployment Scenarios**

#### **Rolling Update Scenario**
```bash
# Scenario: Update application version with zero downtime
# Step 1: Update launch template
terraform apply -target=aws_launch_template.apps["web"]

# Step 2: Trigger instance refresh
aws autoscaling start-instance-refresh \
    --auto-scaling-group-name $(terraform output -raw web_asg_name) \
    --preferences MinHealthyPercentage=50,InstanceWarmup=300

# Step 3: Monitor the refresh
aws autoscaling describe-instance-refreshes \
    --auto-scaling-group-name $(terraform output -raw web_asg_name)
```

#### **Emergency Patch Scenario**
```bash
# Scenario: Apply emergency security patch
# Step 1: Create emergency security group rule
terraform apply -target=aws_security_group_rule.emergency_patch

# Step 2: Update specific instances
terraform apply -target=aws_autoscaling_group.apps["api"]

# Step 3: Verify patch deployment
./verify_patch_deployment.sh
```

---

## 🔧 **Lab Exercise 4: Dependency Troubleshooting**

### **Objective**
Develop expertise in diagnosing and resolving complex dependency issues in production-like environments.

![Figure 4.5: Troubleshooting and Resolution Patterns](DaC/generated_diagrams/figure_4_5_troubleshooting_resolution_patterns.png)
*Figure 4.5: Dependency troubleshooting patterns you'll implement*

### **Exercise 4.1: Dependency Issue Simulation**

#### **Create Problematic Configuration**
```hcl
# Create intentional circular dependency for troubleshooting practice
# problematic_resources.tf (DO NOT APPLY - FOR ANALYSIS ONLY)

# PROBLEMATIC: Circular dependency example
resource "aws_security_group" "problematic_web" {
  name_prefix = "problematic-web-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.problematic_alb.id]  # Circular dependency
  }
}

resource "aws_security_group" "problematic_alb" {
  name_prefix = "problematic-alb-"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.problematic_web.id]  # Circular dependency
  }
}
```

#### **Diagnostic Commands and Analysis**
```bash
# Create comprehensive troubleshooting script
cat > troubleshoot_dependencies.sh << 'EOF'
#!/bin/bash

echo "=== Terraform Dependency Troubleshooting ==="
echo

# 1. Validate configuration
echo "1. Configuration Validation:"
terraform validate
echo

# 2. Generate dependency graph
echo "2. Generating dependency graph..."
terraform graph > dependency_graph.dot
echo "Dependency graph saved to dependency_graph.dot"

# 3. Convert graph to visual format
if command -v dot &> /dev/null; then
    dot -Tpng dependency_graph.dot -o dependency_graph.png
    echo "Visual dependency graph saved to dependency_graph.png"
else
    echo "Graphviz not installed. Install with: sudo apt-get install graphviz"
fi

# 4. Analyze resource dependencies
echo
echo "3. Resource Dependency Analysis:"
echo "Total resources: $(terraform state list | wc -l)"
echo "Resource types:"
terraform state list | cut -d. -f1 | sort | uniq -c | sort -nr

# 5. Check for circular dependencies
echo
echo "4. Circular Dependency Check:"
terraform graph | grep -E "digraph|->|}" | head -20

# 6. Analyze implicit dependencies
echo
echo "5. Implicit Dependencies (resource references):"
grep -r "aws_.*\." *.tf | grep -v "data\." | grep -v "resource \"" | head -10

# 7. Check explicit dependencies
echo
echo "6. Explicit Dependencies:"
grep -r "depends_on" *.tf || echo "No explicit dependencies found"

# 8. Lifecycle rule analysis
echo
echo "7. Lifecycle Rules:"
grep -A 5 -B 1 "lifecycle" *.tf || echo "No lifecycle rules found"

# 9. Meta-argument usage
echo
echo "8. Meta-Argument Usage:"
echo "  - count: $(grep -c "count =" *.tf)"
echo "  - for_each: $(grep -c "for_each =" *.tf)"
echo "  - depends_on: $(grep -c "depends_on =" *.tf)"
echo "  - lifecycle: $(grep -c "lifecycle {" *.tf)"

# 10. State analysis
echo
echo "9. State Analysis:"
if [ -f terraform.tfstate ]; then
    echo "State file exists"
    echo "Resources in state: $(terraform state list | wc -l)"
    echo "Last modified: $(stat -c %y terraform.tfstate)"
else
    echo "No state file found"
fi

# 11. Plan analysis
echo
echo "10. Plan Analysis:"
terraform plan -detailed-exitcode > plan_output.txt 2>&1
plan_exit_code=$?
case $plan_exit_code in
    0)
        echo "No changes needed"
        ;;
    1)
        echo "Error in plan:"
        cat plan_output.txt
        ;;
    2)
        echo "Changes detected:"
        grep -E "(Plan:|Error:|Warning:)" plan_output.txt
        ;;
esac

echo
echo "=== Troubleshooting Complete ==="
echo "Review dependency_graph.png for visual analysis"
echo "Check plan_output.txt for detailed plan information"

EOF

chmod +x troubleshoot_dependencies.sh
./troubleshoot_dependencies.sh
```

### **Exercise 4.2: Resolution Strategies**

#### **State Management Solutions**
```bash
# Create state management script
cat > manage_state.sh << 'EOF'
#!/bin/bash

# Function to backup state
backup_state() {
    if [ -f terraform.tfstate ]; then
        cp terraform.tfstate "terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)"
        echo "State backed up successfully"
    else
        echo "No state file to backup"
    fi
}

# Function to refresh state
refresh_state() {
    echo "Refreshing state..."
    terraform refresh
    echo "State refresh complete"
}

# Function to import resource
import_resource() {
    local resource_address=$1
    local resource_id=$2

    if [ -z "$resource_address" ] || [ -z "$resource_id" ]; then
        echo "Usage: import_resource <resource_address> <resource_id>"
        return 1
    fi

    echo "Importing resource: $resource_address"
    terraform import "$resource_address" "$resource_id"
}

# Function to move resource in state
move_resource() {
    local old_address=$1
    local new_address=$2

    if [ -z "$old_address" ] || [ -z "$new_address" ]; then
        echo "Usage: move_resource <old_address> <new_address>"
        return 1
    fi

    echo "Moving resource from $old_address to $new_address"
    terraform state mv "$old_address" "$new_address"
}

# Function to remove resource from state
remove_resource() {
    local resource_address=$1

    if [ -z "$resource_address" ]; then
        echo "Usage: remove_resource <resource_address>"
        return 1
    fi

    echo "Removing resource from state: $resource_address"
    terraform state rm "$resource_address"
}

# Function to show resource details
show_resource() {
    local resource_address=$1

    if [ -z "$resource_address" ]; then
        echo "Usage: show_resource <resource_address>"
        return 1
    fi

    terraform state show "$resource_address"
}

# Main execution
case "$1" in
    backup)
        backup_state
        ;;
    refresh)
        refresh_state
        ;;
    import)
        import_resource "$2" "$3"
        ;;
    move)
        move_resource "$2" "$3"
        ;;
    remove)
        remove_resource "$2"
        ;;
    show)
        show_resource "$2"
        ;;
    list)
        terraform state list
        ;;
    *)
        echo "Usage: $0 {backup|refresh|import|move|remove|show|list}"
        echo ""
        echo "Commands:"
        echo "  backup                     - Backup current state"
        echo "  refresh                    - Refresh state from infrastructure"
        echo "  import <address> <id>      - Import existing resource"
        echo "  move <old> <new>          - Move resource in state"
        echo "  remove <address>          - Remove resource from state"
        echo "  show <address>            - Show resource details"
        echo "  list                      - List all resources in state"
        exit 1
        ;;
esac

EOF

chmod +x manage_state.sh
```

### **Exercise 4.3: Validation and Testing**

#### **Comprehensive Validation Script**
```bash
# Create validation and testing script
cat > validate_infrastructure.sh << 'EOF'
#!/bin/bash

echo "=== Infrastructure Validation and Testing ==="
echo

# 1. Terraform validation
echo "1. Terraform Configuration Validation:"
terraform validate
if [ $? -eq 0 ]; then
    echo "✅ Configuration is valid"
else
    echo "❌ Configuration validation failed"
    exit 1
fi
echo

# 2. Format check
echo "2. Format Check:"
terraform fmt -check -recursive
if [ $? -eq 0 ]; then
    echo "✅ Code is properly formatted"
else
    echo "⚠️  Code formatting issues found. Run 'terraform fmt -recursive' to fix"
fi
echo

# 3. Plan validation
echo "3. Plan Validation:"
terraform plan -detailed-exitcode > plan_validation.txt 2>&1
plan_exit_code=$?
case $plan_exit_code in
    0)
        echo "✅ No changes needed - infrastructure is up to date"
        ;;
    1)
        echo "❌ Plan failed:"
        cat plan_validation.txt
        exit 1
        ;;
    2)
        echo "⚠️  Changes detected:"
        grep -E "(Plan:|will be)" plan_validation.txt | head -10
        ;;
esac
echo

# 4. Dependency graph validation
echo "4. Dependency Graph Validation:"
terraform graph > validation_graph.dot 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Dependency graph generated successfully"
    # Check for potential circular dependencies
    if grep -q "cycle" validation_graph.dot; then
        echo "❌ Potential circular dependencies detected"
    else
        echo "✅ No circular dependencies detected"
    fi
else
    echo "❌ Failed to generate dependency graph"
fi
echo

# 5. Resource count validation
echo "5. Resource Count Validation:"
if [ -f terraform.tfstate ]; then
    resource_count=$(terraform state list | wc -l)
    echo "Resources in state: $resource_count"

    if [ $resource_count -gt 0 ]; then
        echo "✅ Resources exist in state"
        echo "Resource breakdown:"
        terraform state list | cut -d. -f1 | sort | uniq -c | sort -nr | head -5
    else
        echo "⚠️  No resources in state"
    fi
else
    echo "⚠️  No state file found"
fi
echo

# 6. Security validation
echo "6. Security Validation:"
echo "Checking for common security issues..."

# Check for hardcoded passwords
if grep -r "password.*=" *.tf | grep -v "var\." | grep -v "data\."; then
    echo "❌ Hardcoded passwords found"
else
    echo "✅ No hardcoded passwords detected"
fi

# Check for public access
if grep -r "0\.0\.0\.0/0" *.tf; then
    echo "⚠️  Public access (0.0.0.0/0) detected - review security groups"
else
    echo "✅ No unrestricted public access detected"
fi

# Check for encryption
if grep -r "storage_encrypted.*true" *.tf; then
    echo "✅ Storage encryption enabled"
else
    echo "⚠️  Storage encryption not explicitly enabled"
fi
echo

# 7. Best practices validation
echo "7. Best Practices Validation:"

# Check for tags
if grep -r "tags.*=" *.tf; then
    echo "✅ Resource tagging implemented"
else
    echo "⚠️  Resource tagging not found"
fi

# Check for lifecycle rules
if grep -r "lifecycle" *.tf; then
    echo "✅ Lifecycle rules implemented"
else
    echo "⚠️  No lifecycle rules found"
fi

# Check for explicit dependencies
if grep -r "depends_on" *.tf; then
    echo "✅ Explicit dependencies used"
else
    echo "⚠️  No explicit dependencies found"
fi

echo
echo "=== Validation Complete ==="
echo "Review plan_validation.txt for detailed plan output"
echo "Review validation_graph.dot for dependency analysis"

EOF

chmod +x validate_infrastructure.sh
./validate_infrastructure.sh
```

---

## 🧹 **Lab Cleanup and Assessment**

### **Exercise 4.4: Controlled Infrastructure Cleanup**

#### **Selective Cleanup Strategy**
```bash
# Create cleanup script with dependency awareness
cat > cleanup_infrastructure.sh << 'EOF'
#!/bin/bash

echo "=== Infrastructure Cleanup ==="
echo "This script will destroy resources in dependency-aware order"
echo

# Function to confirm destruction
confirm_destroy() {
    local resource_type=$1
    echo "About to destroy: $resource_type"
    read -p "Continue? (y/N): " confirm
    if [[ $confirm != [yY] ]]; then
        echo "Skipping $resource_type destruction"
        return 1
    fi
    return 0
}

# Cleanup in reverse dependency order
echo "1. Destroying application infrastructure..."
if confirm_destroy "Application Infrastructure"; then
    terraform destroy -auto-approve \
        -target=aws_autoscaling_group.apps \
        -target=aws_launch_template.apps \
        -target=aws_lb_target_group.apps
fi

echo "2. Destroying load balancer..."
if confirm_destroy "Load Balancer"; then
    terraform destroy -auto-approve \
        -target=aws_lb.main
fi

echo "3. Destroying conditional resources..."
if confirm_destroy "Conditional Resources"; then
    terraform destroy -auto-approve \
        -target=aws_cloudwatch_dashboard.main \
        -target=aws_backup_vault.main \
        -target=aws_elasticache_cluster.main \
        -target=aws_elasticache_subnet_group.main
fi

echo "4. Destroying database infrastructure..."
if confirm_destroy "Database Infrastructure"; then
    # Remove lifecycle protection first
    echo "Removing lifecycle protection from database..."
    sed -i 's/prevent_destroy = true/prevent_destroy = false/' main.tf
    terraform apply -auto-approve -target=aws_db_instance.main

    terraform destroy -auto-approve \
        -target=aws_db_instance.main \
        -target=aws_db_subnet_group.main \
        -target=aws_kms_key.database
fi

echo "5. Destroying security infrastructure..."
if confirm_destroy "Security Infrastructure"; then
    terraform destroy -auto-approve \
        -target=aws_security_group_rule.web_from_alb \
        -target=aws_security_group_rule.api_from_worker \
        -target=aws_security_group.main
fi

echo "6. Destroying network infrastructure..."
if confirm_destroy "Network Infrastructure"; then
    terraform destroy -auto-approve \
        -target=aws_nat_gateway.main \
        -target=aws_eip.nat \
        -target=aws_subnet.database \
        -target=aws_subnet.private \
        -target=aws_subnet.public \
        -target=aws_internet_gateway.main \
        -target=aws_vpc.main
fi

echo "7. Final cleanup..."
if confirm_destroy "All Remaining Resources"; then
    terraform destroy -auto-approve
fi

echo
echo "=== Cleanup Complete ==="
echo "Verifying cleanup..."
terraform state list
if [ $? -eq 0 ] && [ $(terraform state list | wc -l) -eq 0 ]; then
    echo "✅ All resources successfully destroyed"
else
    echo "⚠️  Some resources may remain - check manually"
fi

EOF

chmod +x cleanup_infrastructure.sh
```

---

## 📊 **Lab Assessment and Validation**

### **Completion Checklist**

#### **✅ Dependency Graph Management**
- [ ] Complex dependency relationships implemented successfully
- [ ] Implicit dependencies properly configured and analyzed
- [ ] Explicit dependencies used where appropriate
- [ ] Dependency graph generated and visualized
- [ ] Circular dependency detection and resolution demonstrated

#### **✅ Advanced Lifecycle Control**
- [ ] Database with lifecycle protection implemented
- [ ] Rolling update strategy for application tiers
- [ ] create_before_destroy patterns applied correctly
- [ ] ignore_changes rules implemented appropriately
- [ ] Conditional resource creation with feature flags

#### **✅ Meta-Argument Mastery**
- [ ] for_each used for complex resource creation
- [ ] count implemented for simple resource scaling
- [ ] depends_on used for explicit dependency management
- [ ] lifecycle rules applied to critical resources
- [ ] Dynamic blocks implemented for complex configurations

#### **✅ Resource Targeting Strategies**
- [ ] Single resource targeting demonstrated
- [ ] Multiple resource targeting implemented
- [ ] Module-level targeting executed
- [ ] Production deployment scenarios practiced
- [ ] Emergency update procedures validated

#### **✅ Dependency Troubleshooting**
- [ ] Diagnostic tools and commands mastered
- [ ] State management operations performed
- [ ] Circular dependency issues resolved
- [ ] Validation and testing procedures implemented
- [ ] Cleanup procedures executed successfully

### **Performance Metrics**
- **Infrastructure Deployment Time**: < 15 minutes for complete infrastructure
- **Dependency Resolution Accuracy**: 100% successful dependency management
- **Targeting Efficiency**: 75% reduction in deployment time for selective operations
- **Troubleshooting Success Rate**: 95% successful issue resolution

---

## 🎯 **Lab Summary and Next Steps**

### **Key Achievements**
- ✅ **Complex Dependency Management**: Successfully implemented and analyzed multi-tier dependency relationships
- ✅ **Advanced Lifecycle Control**: Mastered sophisticated lifecycle patterns for enterprise scenarios
- ✅ **Meta-Argument Expertise**: Demonstrated advanced meta-argument combinations for complex resource management
- ✅ **Targeting Mastery**: Implemented precise resource targeting for efficient operations
- ✅ **Troubleshooting Proficiency**: Developed comprehensive dependency troubleshooting capabilities

### **Skills Developed**
1. **Dependency Analysis**: Complete understanding of implicit and explicit dependency relationships
2. **Lifecycle Management**: Advanced lifecycle control for zero-downtime deployments
3. **Resource Targeting**: Precise operational control for large-scale infrastructure
4. **Troubleshooting**: Comprehensive approach to dependency issue resolution
5. **Enterprise Patterns**: Scalable patterns for production-grade infrastructure management

### **Next Steps**
- **Topic 5**: Variables and Outputs - Advanced variable patterns and output strategies
- **Practice**: Continue experimenting with complex dependency scenarios
- **Exploration**: Investigate Terraform modules for dependency encapsulation
- **Community**: Share your dependency management patterns and learn from others

---

*This comprehensive lab provides hands-on experience with advanced resource management and dependency patterns, directly supporting the theoretical concepts covered in the Concept.md file and preparing you for enterprise-scale infrastructure management.*
```
```
```
