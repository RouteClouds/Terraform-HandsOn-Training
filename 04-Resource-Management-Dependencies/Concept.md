# Topic 4: Resource Management & Dependencies

## 📋 **Learning Objectives**

By mastering this topic, you will develop advanced expertise in:

1. **Dependency Graph Management** - Understanding how Terraform builds and manages complex dependency relationships between resources
2. **Advanced Lifecycle Control** - Implementing sophisticated lifecycle management patterns for enterprise-scale infrastructure
3. **Meta-Argument Mastery** - Leveraging advanced meta-argument combinations for complex resource scenarios
4. **Resource Targeting Strategies** - Executing precise, selective operations for efficient infrastructure management
5. **Dependency Troubleshooting** - Diagnosing and resolving complex dependency issues in production environments

### **Professional Competency Standards**
- **98% accuracy** in dependency analysis and graph management
- **95% efficiency** in implementing advanced lifecycle patterns
- **100% compliance** with enterprise resource management standards
- **90% optimization** in resource targeting and selective operations

---

## 🔗 **Understanding Terraform Dependency Management**

### **Dependency Graph Fundamentals**

Terraform builds a comprehensive dependency graph to determine the correct order for resource operations. This graph represents the relationships between resources and ensures that dependencies are satisfied before dependent resources are created or modified.

![Figure 4.1: Terraform Dependency Graph and Resource Relationships](DaC/generated_diagrams/figure_4_1_dependency_graph_relationships.png)
*Figure 4.1: How Terraform analyzes, builds, and executes dependency graphs*

### **Implicit Dependencies**

Implicit dependencies are automatically detected by Terraform when one resource references attributes of another resource. These dependencies are the most common and reliable form of dependency management.

```hcl
# VPC creates the foundation
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "main-vpc"
  }
}

# Subnet implicitly depends on VPC
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id  # Implicit dependency
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "private-subnet"
  }
}

# Security group implicitly depends on VPC
resource "aws_security_group" "app" {
  name_prefix = "app-sg-"
  vpc_id      = aws_vpc.main.id  # Implicit dependency
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private.cidr_block]  # Implicit dependency on subnet
  }
  
  tags = {
    Name = "app-security-group"
  }
}

# EC2 instance with multiple implicit dependencies
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id              # Implicit dependency
  vpc_security_group_ids = [aws_security_group.app.id]       # Implicit dependency
  
  tags = {
    Name = "app-server"
  }
}
```

### **Explicit Dependencies**

Explicit dependencies are created using the `depends_on` meta-argument when Terraform cannot automatically detect the relationship or when you need to enforce a specific order.

```hcl
# S3 bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "my-app-data-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name = "app-data-bucket"
  }
}

# S3 bucket policy
resource "aws_s3_bucket_policy" "app_data_policy" {
  bucket = aws_s3_bucket.app_data.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.app_role.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.app_data.arn}/*"
      }
    ]
  })
}

# IAM role for EC2 instances
resource "aws_iam_role" "app_role" {
  name = "app-role"
  
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

# IAM instance profile
resource "aws_iam_instance_profile" "app_profile" {
  name = "app-profile"
  role = aws_iam_role.app_role.name
}

# EC2 instance with explicit dependencies
resource "aws_instance" "app_with_storage" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t3.micro"
  subnet_id            = aws_subnet.private.id
  iam_instance_profile = aws_iam_instance_profile.app_profile.name
  
  # Explicit dependencies ensure S3 setup is complete
  depends_on = [
    aws_s3_bucket.app_data,
    aws_s3_bucket_policy.app_data_policy,
    aws_iam_instance_profile.app_profile
  ]
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    bucket_name = aws_s3_bucket.app_data.bucket
  }))
  
  tags = {
    Name = "app-server-with-storage"
  }
}
```

### **Complex Dependency Scenarios**

In enterprise environments, dependency relationships can become complex, involving multiple layers of infrastructure and cross-service dependencies.

```hcl
# Database subnet group
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id
  
  tags = {
    Name = "main-db-subnet-group"
  }
}

# RDS instance with complex dependencies
resource "aws_db_instance" "main" {
  identifier = "main-database"
  
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_encrypted = true
  
  db_name  = "appdb"
  username = "admin"
  password = var.database_password
  
  # Network dependencies
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  
  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Explicit dependencies for proper ordering
  depends_on = [
    aws_db_subnet_group.main,
    aws_security_group.database,
    aws_kms_key.database_encryption
  ]
  
  tags = {
    Name = "main-database"
  }
}

# Application load balancer with health checks
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  
  enable_deletion_protection = false
  
  tags = {
    Name = "main-alb"
  }
}

# Target group for application servers
resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = 8080
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
    protocol            = "HTTP"
  }
  
  tags = {
    Name = "app-target-group"
  }
}

# Auto Scaling Group with complex dependencies
resource "aws_autoscaling_group" "app" {
  name                = "app-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  min_size         = 2
  max_size         = 10
  desired_capacity = 3
  
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  
  # Ensure all dependencies are ready
  depends_on = [
    aws_db_instance.main,           # Database must be ready
    aws_lb_target_group.app,        # Target group must exist
    aws_launch_template.app         # Launch template must be configured
  ]
  
  tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
  }
}
```

---

## 🔄 **Advanced Resource Lifecycle Management**

### **Lifecycle States and Transitions**

Understanding resource lifecycle states is crucial for managing complex infrastructure changes and ensuring smooth operations.

![Figure 4.2: Resource Lifecycle Management and State Transitions](DaC/generated_diagrams/figure_4_2_lifecycle_management_transitions.png)
*Figure 4.2: Advanced lifecycle management patterns and state transitions*

### **Lifecycle Meta-Argument Patterns**

The `lifecycle` meta-argument provides fine-grained control over how Terraform manages resource lifecycle events.

#### **create_before_destroy Pattern**

This pattern is essential for zero-downtime deployments and resources that cannot have gaps in availability.

```hcl
# Launch template with versioning strategy
resource "aws_launch_template" "app" {
  name_prefix   = "app-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    app_version = var.app_version
    environment = var.environment
  }))
  
  # Ensure new template is created before destroying old one
  lifecycle {
    create_before_destroy = true
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
      Version = var.app_version
    }
  }
}

# Auto Scaling Group with rolling update strategy
resource "aws_autoscaling_group" "app" {
  name                = "app-asg-${aws_launch_template.app.latest_version}"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]
  
  min_size         = 2
  max_size         = 10
  desired_capacity = 3
  
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  
  # Enable rolling updates
  lifecycle {
    create_before_destroy = true
  }
  
  # Instance refresh configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup       = 300
    }
  }
  
  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}
```

#### **prevent_destroy Pattern**

Critical resources require protection against accidental destruction, especially in production environments.

```hcl
# Production database with destruction protection
resource "aws_db_instance" "production" {
  identifier = "production-database"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.r5.xlarge"

  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_encrypted     = true
  kms_key_id           = aws_kms_key.database.arn

  db_name  = "production_db"
  username = "admin"
  password = var.database_password

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.production.name
  vpc_security_group_ids = [aws_security_group.database.id]

  # Backup and maintenance
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # High availability
  multi_az = true

  # Performance monitoring
  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn        = aws_iam_role.rds_monitoring.arn

  # Prevent accidental destruction
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      password,  # Ignore password changes managed externally
      latest_restorable_time
    ]
  }

  tags = {
    Name        = "production-database"
    Environment = "production"
    Critical    = "true"
  }
}

# S3 bucket for critical data with versioning
resource "aws_s3_bucket" "critical_data" {
  bucket = "critical-data-${var.environment}-${random_id.bucket_suffix.hex}"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "critical-data-bucket"
    Environment = var.environment
    DataClass   = "critical"
  }
}

resource "aws_s3_bucket_versioning" "critical_data" {
  bucket = aws_s3_bucket.critical_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "critical_data" {
  bucket = aws_s3_bucket.critical_data.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
```

#### **ignore_changes Pattern**

Some resource attributes are managed by external systems or should not trigger updates when changed.

```hcl
# Auto Scaling Group with external capacity management
resource "aws_autoscaling_group" "app_managed" {
  name                = "app-managed-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]

  min_size         = 2
  max_size         = 20
  desired_capacity = 3

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Ignore capacity changes made by auto scaling policies
  lifecycle {
    ignore_changes = [
      desired_capacity,  # Managed by auto scaling policies
      target_group_arns  # May be modified by deployment tools
    ]
  }

  tag {
    key                 = "Name"
    value               = "app-managed-instance"
    propagate_at_launch = true
  }
}

# EC2 instance with external tag management
resource "aws_instance" "monitored" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private[0].id

  vpc_security_group_ids = [aws_security_group.app.id]

  tags = {
    Name        = "monitored-instance"
    Environment = var.environment
    # Additional tags may be added by monitoring systems
  }

  # Ignore tag changes made by external monitoring systems
  lifecycle {
    ignore_changes = [
      tags["LastPatched"],
      tags["PatchGroup"],
      tags["MonitoringAgent"],
      tags["BackupStatus"]
    ]
  }
}
```

#### **replace_triggered_by Pattern**

This advanced pattern allows you to trigger resource replacement based on changes to other resources or variables.

```hcl
# Configuration template that triggers instance replacement
resource "aws_s3_object" "app_config" {
  bucket = aws_s3_bucket.app_config.bucket
  key    = "config/app.json"

  content = jsonencode({
    database_url = aws_db_instance.main.endpoint
    cache_url    = aws_elasticache_cluster.main.cache_nodes[0].address
    app_version  = var.app_version
    environment  = var.environment
  })

  etag = md5(jsonencode({
    database_url = aws_db_instance.main.endpoint
    cache_url    = aws_elasticache_cluster.main.cache_nodes[0].address
    app_version  = var.app_version
    environment  = var.environment
  }))

  tags = {
    Name = "app-configuration"
  }
}

# EC2 instance that gets replaced when configuration changes
resource "aws_instance" "app_with_config" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private[0].id

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    config_bucket = aws_s3_bucket.app_config.bucket
    config_key    = aws_s3_object.app_config.key
  }))

  # Replace instance when configuration changes
  lifecycle {
    replace_triggered_by = [
      aws_s3_object.app_config
    ]
  }

  tags = {
    Name = "app-with-config"
    ConfigVersion = aws_s3_object.app_config.etag
  }
}
```

---

## 🎛️ **Advanced Meta-Argument Patterns**

### **Complex Meta-Argument Combinations**

Advanced infrastructure scenarios often require sophisticated combinations of meta-arguments to achieve the desired behavior.

![Figure 4.3: Meta-Arguments and Advanced Resource Control](DaC/generated_diagrams/figure_4_3_meta_arguments_control.png)
*Figure 4.3: Advanced meta-argument patterns and their interactions in complex scenarios*

### **Dynamic Resource Creation with for_each**

The `for_each` meta-argument enables sophisticated resource creation patterns based on complex data structures.

```hcl
# Complex application configuration
variable "applications" {
  description = "Application configurations"
  type = map(object({
    instance_type     = string
    min_capacity      = number
    max_capacity      = number
    desired_capacity  = number
    health_check_path = string
    environment_vars  = map(string)
    security_groups   = list(string)
    subnets          = list(string)
    enable_monitoring = bool
    backup_required   = bool
  }))

  default = {
    web = {
      instance_type     = "t3.medium"
      min_capacity      = 2
      max_capacity      = 10
      desired_capacity  = 3
      health_check_path = "/health"
      environment_vars = {
        APP_ENV = "production"
        LOG_LEVEL = "info"
      }
      security_groups   = ["web", "common"]
      subnets          = ["public"]
      enable_monitoring = true
      backup_required   = false
    }
    api = {
      instance_type     = "t3.large"
      min_capacity      = 3
      max_capacity      = 15
      desired_capacity  = 5
      health_check_path = "/api/health"
      environment_vars = {
        APP_ENV = "production"
        LOG_LEVEL = "warn"
        DB_POOL_SIZE = "20"
      }
      security_groups   = ["api", "database", "common"]
      subnets          = ["private"]
      enable_monitoring = true
      backup_required   = true
    }
    worker = {
      instance_type     = "t3.xlarge"
      min_capacity      = 1
      max_capacity      = 5
      desired_capacity  = 2
      health_check_path = "/worker/health"
      environment_vars = {
        APP_ENV = "production"
        LOG_LEVEL = "debug"
        WORKER_THREADS = "8"
      }
      security_groups   = ["worker", "database", "common"]
      subnets          = ["private"]
      enable_monitoring = true
      backup_required   = true
    }
  }
}

# Launch templates for each application
resource "aws_launch_template" "apps" {
  for_each = var.applications

  name_prefix   = "${each.key}-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type

  vpc_security_group_ids = [
    for sg_name in each.value.security_groups :
    aws_security_group.app_security_groups[sg_name].id
  ]

  user_data = base64encode(templatefile("${path.module}/user_data/${each.key}.sh", {
    environment_vars = each.value.environment_vars
    app_name        = each.key
  }))

  monitoring {
    enabled = each.value.enable_monitoring
  }

  # Lifecycle management for rolling updates
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name        = "${each.key}-instance"
      Application = each.key
      Monitoring  = each.value.enable_monitoring ? "enabled" : "disabled"
    })
  }
}

# Auto Scaling Groups for each application
resource "aws_autoscaling_group" "apps" {
  for_each = var.applications

  name                = "${each.key}-asg"
  vpc_zone_identifier = [
    for subnet_type in each.value.subnets :
    aws_subnet.subnets[subnet_type][*].id
  ][0]

  min_size         = each.value.min_capacity
  max_size         = each.value.max_capacity
  desired_capacity = each.value.desired_capacity

  target_group_arns = [aws_lb_target_group.apps[each.key].arn]

  launch_template {
    id      = aws_launch_template.apps[each.key].id
    version = "$Latest"
  }

  # Health check configuration
  health_check_type         = "ELB"
  health_check_grace_period = 300

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity  # Allow auto scaling to manage capacity
    ]
  }

  # Explicit dependencies
  depends_on = [
    aws_lb_target_group.apps,
    aws_launch_template.apps
  ]

  tag {
    key                 = "Name"
    value               = "${each.key}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
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

### **Conditional Resource Creation**

Advanced conditional logic enables dynamic infrastructure based on environment, feature flags, or business requirements.

```hcl
# Environment-specific resource creation
locals {
  # Environment configuration
  environment_config = {
    dev = {
      create_monitoring = false
      create_backup     = false
      instance_count    = 1
      enable_multi_az   = false
    }
    staging = {
      create_monitoring = true
      create_backup     = false
      instance_count    = 2
      enable_multi_az   = false
    }
    prod = {
      create_monitoring = true
      create_backup     = true
      instance_count    = 3
      enable_multi_az   = true
    }
  }

  current_config = local.environment_config[var.environment]
}

# Conditional monitoring resources
resource "aws_cloudwatch_dashboard" "app_monitoring" {
  count = local.current_config.create_monitoring ? 1 : 0

  dashboard_name = "app-monitoring-${var.environment}"

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
      }
    ]
  })
}

# Conditional backup resources
resource "aws_backup_vault" "main" {
  count = local.current_config.create_backup ? 1 : 0

  name        = "main-backup-vault-${var.environment}"
  kms_key_arn = aws_kms_key.backup[0].arn

  tags = {
    Name        = "main-backup-vault"
    Environment = var.environment
  }
}

resource "aws_backup_plan" "main" {
  count = local.current_config.create_backup ? 1 : 0

  name = "main-backup-plan-${var.environment}"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main[0].name
    schedule          = "cron(0 5 ? * * *)"

    recovery_point_tags = {
      Environment = var.environment
      BackupType  = "daily"
    }

    lifecycle {
      cold_storage_after = 30
      delete_after       = 120
    }
  }

  tags = {
    Name        = "main-backup-plan"
    Environment = var.environment
  }
}

# Feature flag-based resource creation
variable "feature_flags" {
  description = "Feature flags for optional resources"
  type = object({
    enable_cdn           = bool
    enable_waf           = bool
    enable_elasticsearch = bool
    enable_redis_cache   = bool
  })

  default = {
    enable_cdn           = false
    enable_waf           = false
    enable_elasticsearch = false
    enable_redis_cache   = true
  }
}

# Conditional CloudFront distribution
resource "aws_cloudfront_distribution" "main" {
  count = var.feature_flags.enable_cdn ? 1 : 0

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "ALB-${aws_lb.main.name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ALB-${aws_lb.main.name}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "main-cdn"
    Environment = var.environment
  }
}

# Conditional ElastiCache cluster
resource "aws_elasticache_subnet_group" "main" {
  count = var.feature_flags.enable_redis_cache ? 1 : 0

  name       = "main-cache-subnet"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_elasticache_cluster" "main" {
  count = var.feature_flags.enable_redis_cache ? 1 : 0

  cluster_id           = "main-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main[0].name
  security_group_ids   = [aws_security_group.cache[0].id]

  tags = {
    Name        = "main-cache"
    Environment = var.environment
  }
}
```

---

## 🎯 **Resource Targeting and Selective Operations**

### **Strategic Resource Targeting**

Resource targeting allows precise control over which resources are affected by Terraform operations, enabling efficient management of large infrastructures.

![Figure 4.4: Resource Targeting and Selective Operations](DaC/generated_diagrams/figure_4_4_resource_targeting_operations.png)
*Figure 4.4: Resource targeting strategies and selective operations for precise infrastructure management*

### **Basic Targeting Patterns**

```bash
# Target specific resource
terraform apply -target=aws_instance.web

# Target multiple resources
terraform apply -target=aws_instance.web -target=aws_instance.app

# Target entire module
terraform apply -target=module.database

# Target resource with index
terraform apply -target=aws_instance.web[0]

# Target all instances of a resource
terraform apply -target=aws_instance.web

# Target with for_each key
terraform apply -target=aws_instance.apps["web"]
```

### **Advanced Targeting Scenarios**

```hcl
# Complex infrastructure with multiple tiers
module "network" {
  source = "./modules/network"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
}

module "security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id

  depends_on = [module.network]
}

module "database" {
  source = "./modules/database"

  vpc_id              = module.network.vpc_id
  database_subnet_ids = module.network.database_subnet_ids
  security_group_ids  = [module.security.database_security_group_id]

  depends_on = [module.network, module.security]
}

module "application" {
  source = "./modules/application"

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids
  security_group_ids = module.security.app_security_group_ids
  database_endpoint  = module.database.endpoint

  depends_on = [module.network, module.security, module.database]
}
```

### **Targeting Use Cases**

#### **Development and Testing**
```bash
# Rapid iteration on application tier only
terraform apply -target=module.application

# Test database changes without affecting application
terraform apply -target=module.database

# Update security groups without recreating instances
terraform apply -target=module.security
```

#### **Production Deployments**
```bash
# Rolling update of application instances
terraform apply -target=aws_autoscaling_group.app

# Update load balancer configuration
terraform apply -target=aws_lb.main -target=aws_lb_target_group.app

# Emergency security group update
terraform apply -target=aws_security_group.emergency_patch
```

#### **Troubleshooting and Recovery**
```bash
# Recreate specific failed instance
terraform apply -replace=aws_instance.app[2]

# Update only monitoring resources
terraform apply -target=aws_cloudwatch_dashboard.main

# Restore from backup by targeting backup resources
terraform apply -target=aws_db_instance.restored
```

---

## 🔧 **Dependency Troubleshooting and Resolution**

### **Common Dependency Issues**

Understanding and resolving dependency issues is crucial for maintaining reliable infrastructure deployments.

![Figure 4.5: Dependency Troubleshooting and Resolution Patterns](DaC/generated_diagrams/figure_4_5_troubleshooting_resolution_patterns.png)
*Figure 4.5: Common dependency issues and their resolution patterns for effective troubleshooting*

### **Circular Dependency Detection and Resolution**

Circular dependencies occur when resources depend on each other in a way that creates a loop, preventing Terraform from determining the correct order of operations.

```hcl
# PROBLEMATIC: Circular dependency example
resource "aws_security_group" "web" {
  name_prefix = "web-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # Depends on ALB SG
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "alb-sg-"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]  # Depends on Web SG
  }
}

# SOLUTION: Break circular dependency with security group rules
resource "aws_security_group" "web" {
  name_prefix = "web-sg-"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "web-security-group"
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "alb-sg-"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "alb-security-group"
  }
}

# Separate security group rules to break circular dependency
resource "aws_security_group_rule" "web_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.web.id
}

resource "aws_security_group_rule" "alb_to_web" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.alb.id
}
```

### **Diagnostic Tools and Techniques**

```bash
# Generate dependency graph
terraform graph | dot -Tpng > dependency_graph.png

# Show detailed resource information
terraform show

# List all resources in state
terraform state list

# Show specific resource details
terraform state show aws_instance.web

# Validate configuration
terraform validate

# Plan with detailed output
terraform plan -detailed-exitcode

# Debug mode for detailed logging
TF_LOG=DEBUG terraform apply
```

### **Resolution Strategies**

#### **State Management Solutions**
```bash
# Refresh state to sync with actual infrastructure
terraform refresh

# Import existing resources
terraform import aws_instance.web i-1234567890abcdef0

# Move resources in state
terraform state mv aws_instance.old aws_instance.new

# Remove resources from state without destroying
terraform state rm aws_instance.temporary
```

#### **Dependency Injection Patterns**
```hcl
# Use data sources to break dependencies
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["existing-vpc"]
  }
}

# Reference existing resources instead of creating dependencies
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.existing.id  # Use existing subnet

  vpc_security_group_ids = [data.aws_security_group.existing.id]

  tags = {
    Name = "app-instance"
  }
}
```

---

## 📚 **Summary and Best Practices**

### **Key Concepts Mastered**

1. **Dependency Graph Management**: Complete understanding of how Terraform analyzes and builds dependency relationships
2. **Advanced Lifecycle Control**: Sophisticated lifecycle management patterns for enterprise-scale infrastructure
3. **Meta-Argument Mastery**: Advanced combinations of meta-arguments for complex resource scenarios
4. **Resource Targeting Strategies**: Precise, selective operations for efficient infrastructure management
5. **Dependency Troubleshooting**: Comprehensive approach to diagnosing and resolving dependency issues

### **Enterprise Best Practices**

- **Explicit Dependencies**: Use `depends_on` when implicit dependencies are insufficient
- **Lifecycle Management**: Implement appropriate lifecycle rules for critical resources
- **Resource Organization**: Structure resources logically with clear dependency hierarchies
- **State Management**: Maintain clean state with proper backup and recovery procedures
- **Targeting Strategy**: Use resource targeting judiciously for efficient operations

### **Integration with Training Progression**

This topic builds upon the foundation established in Topics 1-3, providing advanced resource management knowledge needed for:

- **Topic 5**: Variables and Outputs (dynamic configuration patterns)
- **Topic 6**: State Management (enterprise state strategies)
- **Topic 7**: Modules and Development (modular resource organization)
- **Topic 8**: Advanced State Management (complex state scenarios)

### **Practical Application**

The patterns and practices covered in this topic enable you to:
- Design and implement complex dependency relationships
- Manage sophisticated lifecycle requirements in production environments
- Implement advanced meta-argument patterns for dynamic infrastructure
- Execute precise resource targeting for efficient operations
- Troubleshoot and resolve complex dependency issues

---

*This comprehensive foundation in resource management and dependencies provides the advanced knowledge and practical skills needed for enterprise-scale infrastructure management and complex deployment scenarios.*
```
```
