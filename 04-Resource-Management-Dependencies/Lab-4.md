# Lab 4: Resource Management & Dependencies

## 🎯 Lab Objectives

By completing this lab, you will:

1. **Master resource dependency management** with implicit and explicit dependency patterns
2. **Implement advanced meta-arguments** including count, for_each, lifecycle, and depends_on
3. **Design complex resource relationships** with proper ordering and dependency resolution
4. **Optimize resource lifecycle management** with sophisticated lifecycle rules and patterns
5. **Handle dependency conflicts** and circular dependency resolution strategies
6. **Apply enterprise resource organization** patterns for scalable infrastructure management

**Duration**: 120-150 minutes  
**Difficulty**: Intermediate to Advanced  
**Prerequisites**: Completed Topics 1-3, understanding of Terraform core operations

## 💰 Cost Estimates

### Expected AWS Costs for this Lab:
- **EC2 instances (t3.micro)**: ~$0.0116/hour × 6 instances = ~$0.070/hour
- **RDS instance (db.t3.micro)**: ~$0.017/hour
- **Application Load Balancer**: ~$0.0225/hour
- **NAT Gateway**: ~$0.045/hour (optional)
- **S3 buckets**: ~$0.023/GB/month (minimal usage)
- **CloudWatch logs**: ~$0.50/GB ingested (minimal for lab)
- **Total estimated cost**: **$1.00 - $2.00/day** (with auto-shutdown)

**💡 Cost Optimization Note**: This lab includes auto-shutdown after 4 hours and uses minimal resources with cost-optimized configurations.

## 🏗️ Lab Architecture Overview

In this lab, you'll build a comprehensive multi-tier application demonstrating:

1. **Complex dependency management** across database, application, and presentation tiers
2. **Advanced meta-arguments** with count, for_each, and lifecycle patterns
3. **Resource lifecycle optimization** with create_before_destroy and prevent_destroy
4. **Dependency resolution** for circular and complex dependency scenarios
5. **Enterprise patterns** for scalable resource organization

![Lab Architecture](../DaC/generated_diagrams/lab4_architecture.png)
*Figure 4.1: Lab 4 Resource Management & Dependencies Architecture*

## 📋 Prerequisites Setup

### 1. Verify Environment
```bash
# Check Terraform version
terraform version

# Verify AWS authentication
aws sts get-caller-identity

# Set lab environment variables
export LAB_NAME="resource-management-dependencies"
export STUDENT_NAME="your-name"  # Replace with your name
export AWS_REGION="us-east-1"
```

### 2. Create Lab Directory
```bash
# Create and navigate to lab directory
mkdir -p terraform-resource-management-lab
cd terraform-resource-management-lab

# Initialize git for version control
git init
echo "*.tfstate*" > .gitignore
echo ".terraform/" >> .gitignore
echo "*.log" >> .gitignore
```

## 🚀 Part 1: Implicit Dependencies and Resource Relationships

### Step 1: Foundation Infrastructure with Implicit Dependencies

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
      Project     = "resource-management-dependencies"
      Environment = var.environment
      Student     = var.student_name
      Lab         = "resource-management-dependencies"
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

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "database_config" {
  description = "Database configuration"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
    username       = string
    password       = string
  })
  default = {
    engine         = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    username       = "admin"
    password       = "changeme123!"
  }
}

variable "application_tiers" {
  description = "Application tier configurations"
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    desired_capacity = number
  }))
  default = {
    web = {
      instance_type = "t3.micro"
      min_size      = 2
      max_size      = 6
      desired_capacity = 3
    }
    app = {
      instance_type = "t3.small"
      min_size      = 2
      max_size      = 4
      desired_capacity = 2
    }
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false  # Disabled for cost optimization
}
EOF
```

#### 1.3 Create terraform.tfvars
```bash
cat > terraform.tfvars << EOF
student_name = "$STUDENT_NAME"
environment  = "lab"
aws_region   = "$AWS_REGION"
availability_zones = ["us-east-1a", "us-east-1b"]
EOF
```

#### 1.4 Create Foundation Infrastructure
```bash
cat > foundation.tf << 'EOF'
# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC - Foundation resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "lab-vpc-${random_id.suffix.hex}"
  }
}

# Internet Gateway - Implicit dependency on VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Creates implicit dependency
  
  tags = {
    Name = "lab-igw-${random_id.suffix.hex}"
  }
}

# Public Subnets - Implicit dependency on VPC
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  
  vpc_id                  = aws_vpc.main.id  # Implicit dependency
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "lab-public-subnet-${count.index + 1}-${random_id.suffix.hex}"
    Type = "public"
    AZ   = var.availability_zones[count.index]
  }
}

# Private Subnets - Implicit dependency on VPC
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id  # Implicit dependency
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "lab-private-subnet-${count.index + 1}-${random_id.suffix.hex}"
    Type = "private"
    AZ   = var.availability_zones[count.index]
  }
}

# Database Subnets - Implicit dependency on VPC
resource "aws_subnet" "database" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.main.id  # Implicit dependency
  cidr_block        = "10.0.${count.index + 20}.0/24"
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "lab-database-subnet-${count.index + 1}-${random_id.suffix.hex}"
    Type = "database"
    AZ   = var.availability_zones[count.index]
  }
}
EOF
```

### Step 2: Routing and Network Dependencies

#### 2.1 Create Routing Infrastructure
```bash
cat > routing.tf << 'EOF'
# Public Route Table - Implicit dependency on VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  # Implicit dependency
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id  # Implicit dependency on IGW
  }
  
  tags = {
    Name = "lab-public-rt-${random_id.suffix.hex}"
    Type = "public"
  }
}

# Public Route Table Associations - Implicit dependencies on subnets and route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id      # Implicit dependency
  route_table_id = aws_route_table.public.id              # Implicit dependency
}

# NAT Gateway (optional) - Multiple implicit dependencies
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0
  
  domain = "vpc"
  
  # Implicit dependency on IGW through depends_on
  depends_on = [aws_internet_gateway.main]
  
  tags = {
    Name = "lab-nat-eip-${count.index + 1}-${random_id.suffix.hex}"
  }
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0
  
  allocation_id = aws_eip.nat[count.index].id           # Implicit dependency
  subnet_id     = aws_subnet.public[count.index].id    # Implicit dependency
  
  tags = {
    Name = "lab-nat-gw-${count.index + 1}-${random_id.suffix.hex}"
  }
}

# Private Route Tables - Conditional routing based on NAT Gateway
resource "aws_route_table" "private" {
  count = length(var.availability_zones)
  
  vpc_id = aws_vpc.main.id  # Implicit dependency
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id  # Implicit dependency
    }
  }
  
  tags = {
    Name = "lab-private-rt-${count.index + 1}-${random_id.suffix.hex}"
    Type = "private"
  }
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
EOF
```

### Step 3: Test Implicit Dependencies

#### 3.1 Initialize and Plan
```bash
# Initialize Terraform
terraform init

# Create dependency graph
terraform graph | dot -Tpng > implicit_dependencies.png

# Plan infrastructure
terraform plan
```

#### 3.2 Apply Foundation
```bash
# Apply foundation infrastructure
terraform apply

# Verify implicit dependencies
terraform state list
terraform state show aws_subnet.public[0]
```

## 🔗 Part 2: Explicit Dependencies and Complex Relationships

### Step 4: Database Tier with Explicit Dependencies

#### 4.1 Create Database Infrastructure
```bash
cat > database.tf << 'EOF'
# Database Subnet Group - Implicit dependency on database subnets
resource "aws_db_subnet_group" "main" {
  name       = "lab-db-subnet-group-${random_id.suffix.hex}"
  subnet_ids = aws_subnet.database[*].id  # Implicit dependency
  
  tags = {
    Name = "lab-db-subnet-group-${random_id.suffix.hex}"
  }
}

# Database Security Group - Implicit dependency on VPC
resource "aws_security_group" "database" {
  name_prefix = "lab-db-sg-"
  vpc_id      = aws_vpc.main.id  # Implicit dependency
  description = "Security group for database tier"
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]  # Implicit dependency on app SG
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "lab-db-sg-${random_id.suffix.hex}"
    Tier = "database"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance - Multiple dependencies
resource "aws_db_instance" "main" {
  identifier = "lab-database-${random_id.suffix.hex}"
  
  engine         = var.database_config.engine
  engine_version = var.database_config.engine_version
  instance_class = var.database_config.instance_class
  
  allocated_storage = var.database_config.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true
  
  db_name  = "labdb"
  username = var.database_config.username
  password = var.database_config.password
  
  db_subnet_group_name   = aws_db_subnet_group.main.name      # Implicit dependency
  vpc_security_group_ids = [aws_security_group.database.id]  # Implicit dependency
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = true
  deletion_protection = false
  
  # Explicit dependencies to ensure proper setup order
  depends_on = [
    aws_db_subnet_group.main,
    aws_security_group.database
  ]
  
  lifecycle {
    prevent_destroy = false  # Set to true in production
    ignore_changes = [
      password  # Ignore password changes to prevent unnecessary updates
    ]
  }
  
  tags = {
    Name = "lab-database-${random_id.suffix.hex}"
    Tier = "database"
  }
}
EOF
```

### Step 5: Application Tier with For_Each Meta-Argument

#### 5.1 Create Application Infrastructure
```bash
cat > application.tf << 'EOF'
# Application Security Groups using for_each
resource "aws_security_group" "app_tiers" {
  for_each = var.application_tiers
  
  name_prefix = "lab-${each.key}-sg-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for ${each.key} tier"
  
  # Dynamic ingress rules based on tier
  dynamic "ingress" {
    for_each = each.key == "web" ? [80, 443] : [8080]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = each.key == "web" ? ["0.0.0.0/0"] : [var.vpc_cidr]
    }
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "lab-${each.key}-sg-${random_id.suffix.hex}"
    Tier = each.key
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Convenience reference for app security group
resource "aws_security_group" "app" {
  name_prefix = "lab-app-sg-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for application tier"
  
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tiers["web"].id]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "lab-app-sg-${random_id.suffix.hex}"
    Tier = "application"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Launch Templates for each tier
resource "aws_launch_template" "app_tiers" {
  for_each = var.application_tiers
  
  name_prefix   = "lab-${each.key}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type
  
  vpc_security_group_ids = [aws_security_group.app_tiers[each.key].id]
  
  user_data = base64encode(templatefile("${path.module}/scripts/user_data_${each.key}.sh", {
    tier_name = each.key
    database_endpoint = aws_db_instance.main.endpoint
  }))
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "lab-${each.key}-instance-${random_id.suffix.hex}"
      Tier = each.key
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
  
  # Explicit dependency on database
  depends_on = [aws_db_instance.main]
}

# Auto Scaling Groups for each tier
resource "aws_autoscaling_group" "app_tiers" {
  for_each = var.application_tiers
  
  name                = "lab-${each.key}-asg-${random_id.suffix.hex}"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = each.key == "web" ? [aws_lb_target_group.web.arn] : []
  health_check_type   = each.key == "web" ? "ELB" : "EC2"
  
  min_size         = each.value.min_size
  max_size         = each.value.max_size
  desired_capacity = each.value.desired_capacity
  
  launch_template {
    id      = aws_launch_template.app_tiers[each.key].id
    version = "$Latest"
  }
  
  # Explicit dependencies
  depends_on = [
    aws_db_instance.main,
    aws_launch_template.app_tiers
  ]
  
  tag {
    key                 = "Name"
    value               = "lab-${each.key}-asg-${random_id.suffix.hex}"
    propagate_at_launch = false
  }
  
  tag {
    key                 = "Tier"
    value               = each.key
    propagate_at_launch = true
  }
}
EOF
```

### Step 6: Load Balancer with Complex Dependencies

#### 6.1 Create Load Balancer Infrastructure
```bash
cat > load_balancer.tf << 'EOF'
# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name_prefix = "lab-alb-sg-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Application Load Balancer"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "lab-alb-sg-${random_id.suffix.hex}"
    Tier = "load-balancer"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer with complex dependencies
resource "aws_lb" "main" {
  name               = "lab-alb-${random_id.suffix.hex}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  
  enable_deletion_protection = false
  
  # Complex explicit dependencies
  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.public,
    aws_autoscaling_group.app_tiers
  ]
  
  tags = {
    Name = "lab-alb-${random_id.suffix.hex}"
    Tier = "load-balancer"
  }
}

# Target Group for web tier
resource "aws_lb_target_group" "web" {
  name     = "lab-web-tg-${random_id.suffix.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
  
  tags = {
    Name = "lab-web-tg-${random_id.suffix.hex}"
    Tier = "web"
  }
}

# ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
  
  # Explicit dependency on target group
  depends_on = [aws_lb_target_group.web]
}
EOF
```

## 🔄 Part 3: Advanced Lifecycle Management

### Step 7: Create User Data Scripts

#### 7.1 Create Scripts Directory and Files
```bash
mkdir -p scripts

# Web tier user data
cat > scripts/user_data_web.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

cat > /var/www/html/index.html << HTML
<!DOCTYPE html>
<html>
<head><title>Web Tier - ${tier_name}</title></head>
<body>
<h1>Web Tier Server</h1>
<p>Tier: ${tier_name}</p>
<p>Database: ${database_endpoint}</p>
<p>Time: $(date)</p>
</body>
</html>
HTML

cat > /var/www/html/health << HTML
OK
HTML
EOF

# App tier user data
cat > scripts/user_data_app.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y java-11-amazon-corretto

# Create simple health check
mkdir -p /opt/app
cat > /opt/app/health.sh << 'HEALTH'
#!/bin/bash
echo "OK"
HEALTH
chmod +x /opt/app/health.sh

# Create systemd service for health check
cat > /etc/systemd/system/app-health.service << 'SERVICE'
[Unit]
Description=Application Health Check
After=network.target

[Service]
Type=simple
ExecStart=/opt/app/health.sh
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

systemctl enable app-health
systemctl start app-health
EOF
```

### Step 8: Apply and Test Dependencies

#### 8.1 Apply Complete Infrastructure
```bash
# Plan the complete infrastructure
terraform plan

# Apply with dependency tracking
terraform apply

# Generate dependency graph
terraform graph | dot -Tpng > complete_dependencies.png
```

#### 8.2 Test Dependency Behavior
```bash
# Test targeted operations
terraform plan -target=aws_db_instance.main
terraform plan -target=aws_autoscaling_group.app_tiers

# Test dependency chain
terraform apply -target=aws_vpc.main
terraform apply -target=aws_subnet.public
terraform apply -target=aws_db_instance.main
```

## 🧪 Part 4: Advanced Meta-Arguments and Lifecycle Testing

### Step 9: Lifecycle Management Testing

#### 9.1 Test Create Before Destroy
```bash
# Modify launch template to trigger replacement
cat >> application.tf << 'EOF'

# Test resource with create_before_destroy
resource "aws_launch_template" "test_lifecycle" {
  name_prefix   = "test-lifecycle-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "test-lifecycle-${random_id.suffix.hex}"
    Test = "lifecycle"
  }
}
EOF

# Apply and observe behavior
terraform apply
```

#### 9.2 Test Prevent Destroy
```bash
# Add prevent_destroy to critical resource
terraform apply
```

### Step 10: Complex Dependency Resolution

#### 10.1 Create Circular Dependency Scenario
```bash
cat > circular_test.tf << 'EOF'
# Example of resolving circular dependencies with data sources

# Data source to break circular dependency
data "aws_security_group" "existing_web" {
  count = length(aws_security_group.app_tiers) > 0 ? 1 : 0
  id    = aws_security_group.app_tiers["web"].id
}

# Resource that would create circular dependency
resource "aws_security_group_rule" "app_to_web" {
  count = length(data.aws_security_group.existing_web) > 0 ? 1 : 0
  
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = data.aws_security_group.existing_web[0].id
}
EOF
```

## 📊 Part 5: Validation and Testing

### Step 11: Comprehensive Testing

#### 11.1 Dependency Validation
```bash
# Validate all dependencies
terraform validate

# Check state consistency
terraform plan

# Test resource targeting
terraform apply -target=aws_lb.main

# Verify dependency chain
terraform state list | grep -E "(vpc|subnet|security_group|db_instance|autoscaling_group|lb)"
```

#### 11.2 Performance Testing
```bash
# Test parallel operations
time terraform plan -parallelism=20

# Test dependency resolution speed
time terraform apply -target=aws_autoscaling_group.app_tiers
```

### Step 12: Create Outputs for Validation

#### 12.1 Create Comprehensive Outputs
```bash
cat > outputs.tf << 'EOF'
output "dependency_summary" {
  description = "Summary of resource dependencies created"
  value = {
    vpc_id = aws_vpc.main.id
    database_endpoint = aws_db_instance.main.endpoint
    load_balancer_dns = aws_lb.main.dns_name
    
    implicit_dependencies = {
      subnets_depend_on_vpc = length(aws_subnet.public) + length(aws_subnet.private)
      security_groups_depend_on_vpc = length(aws_security_group.app_tiers) + 2
      asg_depends_on_launch_templates = length(aws_autoscaling_group.app_tiers)
    }
    
    explicit_dependencies = {
      database_depends_on = ["subnet_group", "security_group"]
      alb_depends_on = ["igw", "route_associations", "asg"]
      launch_templates_depend_on = ["database"]
    }
    
    meta_arguments_used = {
      count_resources = ["subnets", "route_tables", "nat_gateways"]
      for_each_resources = ["security_groups", "launch_templates", "autoscaling_groups"]
      lifecycle_managed = ["launch_templates", "security_groups", "database"]
    }
  }
}

output "resource_addresses" {
  description = "Resource addresses demonstrating meta-argument patterns"
  value = {
    count_examples = {
      public_subnets = aws_subnet.public[*].id
      private_subnets = aws_subnet.private[*].id
    }
    
    for_each_examples = {
      app_security_groups = {
        for k, v in aws_security_group.app_tiers : k => v.id
      }
      autoscaling_groups = {
        for k, v in aws_autoscaling_group.app_tiers : k => v.name
      }
    }
  }
}

output "testing_commands" {
  description = "Commands for testing dependencies and meta-arguments"
  value = [
    "# Test dependency graph:",
    "terraform graph | dot -Tpng > dependencies.png",
    "",
    "# Test resource targeting:",
    "terraform plan -target=aws_db_instance.main",
    "terraform plan -target=aws_autoscaling_group.app_tiers[\"web\"]",
    "",
    "# Test lifecycle behavior:",
    "terraform apply -replace=aws_launch_template.app_tiers[\"web\"]",
    "",
    "# Validate meta-arguments:",
    "terraform state show 'aws_subnet.public[0]'",
    "terraform state show 'aws_security_group.app_tiers[\"web\"]'",
    "",
    "# Test dependency resolution:",
    "terraform apply -target=aws_vpc.main",
    "terraform apply -target=aws_subnet.public",
    "terraform apply"
  ]
}
EOF
```

## 🧹 Part 6: Cleanup and Analysis

### Step 13: Systematic Cleanup

#### 13.1 Dependency-Aware Cleanup
```bash
# Destroy in reverse dependency order
terraform destroy -target=aws_lb.main
terraform destroy -target=aws_autoscaling_group.app_tiers
terraform destroy -target=aws_db_instance.main
terraform destroy

# Verify complete cleanup
terraform state list
```

### Step 14: Document Lessons Learned

#### 14.1 Create Lab Summary
```bash
cat > lab-summary.md << EOF
# Resource Management & Dependencies Lab Summary

## Completed Tasks
- ✅ Mastered implicit dependency patterns with VPC, subnets, and security groups
- ✅ Implemented explicit dependencies with depends_on meta-argument
- ✅ Used count meta-argument for multiple subnet and route table creation
- ✅ Applied for_each meta-argument for application tier resources
- ✅ Configured lifecycle management with create_before_destroy and prevent_destroy
- ✅ Resolved complex dependency chains across multi-tier architecture
- ✅ Tested dependency resolution and resource targeting

## Key Learnings
1. **Implicit Dependencies**: Automatic through resource attribute references
2. **Explicit Dependencies**: Manual control with depends_on for hidden relationships
3. **Count vs For_Each**: Count for simple scaling, for_each for stable addresses
4. **Lifecycle Management**: Critical for zero-downtime deployments
5. **Dependency Resolution**: Terraform automatically orders resource operations
6. **Resource Targeting**: Useful for debugging and partial deployments

## Architecture Deployed
- Multi-tier VPC with public, private, and database subnets
- RDS MySQL database with proper security group configuration
- Auto Scaling Groups for web and application tiers
- Application Load Balancer with health checks
- Complex dependency chains demonstrating enterprise patterns

## Meta-Arguments Mastered
- count: Used for subnets, route tables, and NAT gateways
- for_each: Used for security groups, launch templates, and ASGs
- lifecycle: Applied to critical resources for production safety
- depends_on: Used for complex dependency relationships

## Next Steps
- Explore Terraform modules for code organization
- Implement remote state management for team collaboration
- Add automated testing with dependency validation
- Practice with more complex circular dependency scenarios
EOF
```

## 📊 Lab Completion Summary

Upon successful completion, you should have:

- ✅ **Mastered resource dependency management** with both implicit and explicit patterns
- ✅ **Implemented advanced meta-arguments** including count, for_each, lifecycle, and depends_on
- ✅ **Designed complex resource relationships** with proper ordering and dependency resolution
- ✅ **Optimized resource lifecycle management** with sophisticated lifecycle rules
- ✅ **Handled dependency conflicts** and circular dependency resolution strategies
- ✅ **Applied enterprise resource organization** patterns for scalable infrastructure

### **Key Achievements:**
- **Multi-tier architecture** with database, application, and presentation layers
- **Complex dependency management** across 20+ interconnected resources
- **Advanced meta-arguments** with count, for_each, and lifecycle patterns
- **Enterprise lifecycle management** with create_before_destroy and prevent_destroy
- **Dependency resolution** for complex real-world scenarios

### **Next Steps:**
1. **Explore Terraform modules** for code organization and reusability
2. **Implement remote state management** for team collaboration
3. **Add automated testing** with dependency validation frameworks
4. **Practice advanced patterns** with conditional resources and dynamic blocks

---

**Lab Duration**: 120-150 minutes  
**Difficulty Level**: Intermediate to Advanced  
**Cost Impact**: $1.00 - $2.00/day  
**Learning Value**: Advanced resource management and enterprise patterns
