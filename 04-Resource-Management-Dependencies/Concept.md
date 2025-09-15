# Resource Management & Dependencies

## 🎯 Learning Objectives

By the end of this module, you will be able to:

1. **Master resource dependency management** with implicit and explicit dependency patterns
2. **Implement advanced meta-arguments** including count, for_each, lifecycle, and depends_on
3. **Design complex resource relationships** with proper ordering and dependency resolution
4. **Optimize resource lifecycle management** with sophisticated lifecycle rules and patterns
5. **Handle dependency conflicts** and circular dependency resolution strategies
6. **Apply enterprise resource organization** patterns for scalable infrastructure management

## 📋 Understanding Resource Dependencies

### The Foundation of Infrastructure Orchestration

Resource dependencies form the backbone of Terraform's infrastructure orchestration capabilities. Understanding how resources relate to each other, when they should be created, updated, or destroyed, and how to manage complex interdependencies is crucial for building robust, maintainable infrastructure.

#### **Dependency Types in Terraform**

Terraform manages two fundamental types of dependencies:

1. **Implicit Dependencies**: Automatically detected through resource attribute references
2. **Explicit Dependencies**: Manually declared using the `depends_on` meta-argument

## 🔗 Implicit Dependencies

### Automatic Dependency Detection

Terraform automatically creates dependencies when one resource references attributes of another resource. This creates a natural dependency graph that ensures proper resource ordering.

#### **Basic Implicit Dependency Pattern**
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

# Subnet implicitly depends on VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id  # Creates implicit dependency
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "PublicSubnet"
  }
}

# Internet Gateway implicitly depends on VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Creates implicit dependency
  
  tags = {
    Name = "MainIGW"
  }
}
```

#### **Complex Implicit Dependency Chains**
```hcl
# Data source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group depends on VPC
resource "aws_security_group" "web" {
  name_prefix = "web-sg-"
  vpc_id      = aws_vpc.main.id  # Implicit dependency on VPC
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance depends on subnet, security group, and AMI
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id  # Implicit dependency on data source
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id          # Implicit dependency on subnet
  vpc_security_group_ids = [aws_security_group.web.id]   # Implicit dependency on security group
  
  tags = {
    Name = "WebServer"
  }
}
```

### **Benefits of Implicit Dependencies**
- **Automatic Detection**: No manual configuration required
- **Natural Relationships**: Reflects actual infrastructure relationships
- **Maintainable**: Changes in references automatically update dependencies
- **Error Prevention**: Prevents creation of resources without required dependencies

## 📌 Explicit Dependencies

### Manual Dependency Declaration

Sometimes dependencies exist that Terraform cannot automatically detect. The `depends_on` meta-argument allows you to explicitly declare these relationships.

#### **When to Use Explicit Dependencies**
1. **Hidden Dependencies**: When resources depend on each other but don't reference attributes
2. **Ordering Requirements**: When specific creation order is required for business logic
3. **External Dependencies**: When depending on resources managed outside Terraform
4. **Complex Workflows**: When orchestrating complex deployment sequences

#### **Basic Explicit Dependency**
```hcl
# S3 bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "my-app-data-bucket"
  
  tags = {
    Name = "ApplicationData"
  }
}

# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "EC2ApplicationRole"
  
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

# EC2 instance with explicit dependencies
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  
  # Explicit dependencies on resources that don't have attribute references
  depends_on = [
    aws_s3_bucket.app_data,
    aws_iam_role.ec2_role
  ]
  
  tags = {
    Name = "ApplicationServer"
  }
}
```

#### **Advanced Explicit Dependency Patterns**
```hcl
# Database subnet group
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  
  tags = {
    Name = "MainDBSubnetGroup"
  }
}

# RDS instance
resource "aws_db_instance" "main" {
  identifier     = "main-database"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp2"
  
  db_name  = "maindb"
  username = "admin"
  password = "changeme123!"
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  
  skip_final_snapshot = true
  
  tags = {
    Name = "MainDatabase"
  }
}

# Application Load Balancer with complex dependencies
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  
  # Explicit dependency to ensure proper setup order
  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.public_a,
    aws_route_table_association.public_b,
    aws_db_instance.main  # Wait for database before setting up load balancer
  ]
  
  tags = {
    Name = "MainALB"
  }
}
```

## 🔄 Meta-Arguments for Resource Management

### The Power of Resource Meta-Arguments

Meta-arguments provide powerful capabilities for controlling resource behavior, lifecycle, and creation patterns. They operate at the resource level and affect how Terraform manages the entire resource.

## 📊 Count Meta-Argument

### Creating Multiple Resource Instances

The `count` meta-argument allows you to create multiple instances of a resource using a numeric value.

#### **Basic Count Usage**
```hcl
# Create multiple EC2 instances
resource "aws_instance" "web" {
  count = 3
  
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  
  tags = {
    Name = "WebServer-${count.index + 1}"
    Role = "web"
  }
}

# Reference specific instances
output "first_instance_ip" {
  value = aws_instance.web[0].public_ip
}

output "all_instance_ips" {
  value = aws_instance.web[*].public_ip
}
```

#### **Advanced Count Patterns**
```hcl
# Variable-driven count
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

# Conditional count
variable "create_instances" {
  description = "Whether to create instances"
  type        = bool
  default     = true
}

resource "aws_instance" "conditional" {
  count = var.create_instances ? var.instance_count : 0
  
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  tags = {
    Name = "ConditionalInstance-${count.index + 1}"
  }
}

# Count with complex logic
locals {
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

resource "aws_subnet" "multi_az" {
  count = length(local.availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = local.availability_zones[count.index]
  
  tags = {
    Name = "Subnet-${local.availability_zones[count.index]}"
    AZ   = local.availability_zones[count.index]
  }
}
```

## 🗂️ For_Each Meta-Argument

### Dynamic Resource Creation with Maps and Sets

The `for_each` meta-argument provides more flexible resource creation using maps or sets, offering stable resource addresses.

#### **For_Each with Sets**
```hcl
# Create S3 buckets for different purposes
variable "bucket_names" {
  description = "Set of bucket names to create"
  type        = set(string)
  default     = ["logs", "backups", "data", "artifacts"]
}

resource "aws_s3_bucket" "app_buckets" {
  for_each = var.bucket_names
  
  bucket = "myapp-${each.key}-${random_string.suffix.result}"
  
  tags = {
    Name    = "MyApp-${title(each.key)}-Bucket"
    Purpose = each.key
  }
}

# Reference specific buckets
output "logs_bucket_name" {
  value = aws_s3_bucket.app_buckets["logs"].bucket
}
```

#### **For_Each with Maps**
```hcl
# Complex environment configuration
variable "environments" {
  description = "Environment configurations"
  type = map(object({
    instance_type = string
    instance_count = number
    environment_type = string
    monitoring_enabled = bool
  }))
  
  default = {
    dev = {
      instance_type = "t3.micro"
      instance_count = 1
      environment_type = "development"
      monitoring_enabled = false
    }
    staging = {
      instance_type = "t3.small"
      instance_count = 2
      environment_type = "staging"
      monitoring_enabled = true
    }
    prod = {
      instance_type = "t3.medium"
      instance_count = 3
      environment_type = "production"
      monitoring_enabled = true
    }
  }
}

# Create VPCs for each environment
resource "aws_vpc" "environments" {
  for_each = var.environments
  
  cidr_block           = "10.${index(keys(var.environments), each.key) + 1}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${each.key}-vpc"
    Environment = each.value.environment_type
  }
}

# Create instances for each environment
resource "aws_instance" "environment_instances" {
  for_each = {
    for env_name, env_config in var.environments : env_name => env_config
    if env_config.instance_count > 0
  }
  
  count = each.value.instance_count
  
  ami           = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type
  
  monitoring = each.value.monitoring_enabled
  
  tags = {
    Name        = "${each.key}-instance-${count.index + 1}"
    Environment = each.value.environment_type
  }
}
```

## ♻️ Lifecycle Meta-Argument

### Advanced Resource Lifecycle Management

The `lifecycle` meta-argument provides fine-grained control over resource creation, updates, and destruction patterns.

#### **Create Before Destroy**
```hcl
# Launch configuration with create_before_destroy
resource "aws_launch_configuration" "web" {
  name_prefix     = "web-lc-"
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.web.id]
  
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group using the launch configuration
resource "aws_autoscaling_group" "web" {
  name                = "web-asg"
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  
  min_size         = 2
  max_size         = 6
  desired_capacity = 3
  
  launch_configuration = aws_launch_configuration.web.name
  
  lifecycle {
    create_before_destroy = true
  }
  
  tag {
    key                 = "Name"
    value               = "WebServer"
    propagate_at_launch = true
  }
}
```

#### **Prevent Destroy**
```hcl
# Critical database with prevent_destroy
resource "aws_db_instance" "critical" {
  identifier     = "critical-database"
  engine         = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp2"
  
  db_name  = "criticaldb"
  username = "admin"
  password = var.db_password
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  lifecycle {
    prevent_destroy = true
  }
  
  tags = {
    Name        = "CriticalDatabase"
    Environment = "production"
    Critical    = "true"
  }
}
```

#### **Ignore Changes**
```hcl
# EC2 instance with ignore_changes for specific attributes
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    app_version = var.app_version
  }))
  
  lifecycle {
    ignore_changes = [
      ami,           # Ignore AMI changes to prevent unnecessary replacements
      user_data,     # Ignore user_data changes after initial creation
      tags["LastUpdated"]  # Ignore specific tag changes
    ]
  }
  
  tags = {
    Name        = "ApplicationServer"
    Environment = var.environment
    LastUpdated = timestamp()
  }
}
```

#### **Replace Triggered By**
```hcl
# Certificate resource
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
}

# Load balancer listener with replace_triggered_by
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.main.arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
  
  lifecycle {
    replace_triggered_by = [
      aws_acm_certificate.main
    ]
  }
}
```

## 🔧 Advanced Dependency Patterns

### Complex Real-World Scenarios

#### **Multi-Tier Application Dependencies**
```hcl
# Database tier
resource "aws_db_instance" "app_db" {
  identifier = "app-database"
  engine     = "mysql"
  # ... database configuration
  
  lifecycle {
    prevent_destroy = true
  }
}

# Application tier
resource "aws_instance" "app_servers" {
  count = 3
  
  ami           = data.aws_ami.app_server.id
  instance_type = "t3.medium"
  
  # Explicit dependency on database
  depends_on = [aws_db_instance.app_db]
  
  lifecycle {
    create_before_destroy = true
  }
}

# Load balancer tier
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  
  # Explicit dependency on application servers
  depends_on = [aws_instance.app_servers]
}

# CDN tier
resource "aws_cloudfront_distribution" "app_cdn" {
  origin {
    domain_name = aws_lb.app_lb.dns_name
    origin_id   = "ALB-${aws_lb.app_lb.name}"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  # ... CloudFront configuration
  
  # Explicit dependency on load balancer
  depends_on = [aws_lb.app_lb]
}
```

## 🎯 Best Practices for Resource Management

### Enterprise-Grade Patterns

#### **1. Dependency Organization**
- Use implicit dependencies whenever possible for maintainability
- Reserve explicit dependencies for hidden or complex relationships
- Document complex dependency chains with comments
- Use data sources to break circular dependencies

#### **2. Meta-Argument Selection**
- Choose `for_each` over `count` for stable resource addresses
- Use `count` for simple numeric scaling scenarios
- Implement lifecycle rules proactively for critical resources
- Plan for resource replacement scenarios

#### **3. Resource Lifecycle Planning**
- Identify critical resources that should never be destroyed
- Plan for zero-downtime deployments with create_before_destroy
- Use ignore_changes judiciously to prevent configuration drift
- Implement proper backup strategies before destructive changes

---

**Figure References:**
- Figure 4.1: Resource Dependency Graph (see `../DaC/generated_diagrams/dependency_graph.png`)
- Figure 4.2: Meta-Arguments Comparison (see `../DaC/generated_diagrams/meta_arguments.png`)
- Figure 4.3: Lifecycle Management Patterns (see `../DaC/generated_diagrams/lifecycle_patterns.png`)
- Figure 4.4: Complex Dependency Resolution (see `../DaC/generated_diagrams/complex_dependencies.png`)
- Figure 4.5: Resource Management Workflow (see `../DaC/generated_diagrams/resource_workflow.png`)
