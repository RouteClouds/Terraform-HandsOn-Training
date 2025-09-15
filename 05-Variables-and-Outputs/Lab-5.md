# AWS Terraform Training - Variables and Outputs Lab

## 🎯 **Lab 5: Advanced Variable Management and Output Patterns**

### **Master Dynamic Configuration and Enterprise Variable Strategies**

**Duration**: 90-120 minutes  
**Difficulty**: Intermediate to Advanced  
**Prerequisites**: Completion of Labs 1-4, AWS CLI configured, Terraform ~> 1.13.0

---

## 📋 **Lab Objectives**

By completing this lab, you will:

1. **Implement Complex Variable Structures** - Create sophisticated variable patterns with comprehensive validation
2. **Master Sensitive Data Handling** - Securely manage sensitive variables with AWS integration
3. **Design Output Chaining Patterns** - Build structured outputs for module integration and automation
4. **Configure Environment-Specific Variables** - Implement dynamic configuration management across environments
5. **Integrate AWS Parameter Store** - Connect Terraform with AWS Systems Manager for dynamic parameter management

---

## 🏗️ **Lab Architecture**

![Lab Architecture](DaC/generated_diagrams/lab_5_architecture.png)
*Figure 5.1: Complete lab architecture showing variable flow, AWS integration, and output patterns*

This lab implements a comprehensive multi-tier application infrastructure with:
- **Dynamic Variable Management**: Environment-specific configurations with inheritance
- **Secure Parameter Handling**: AWS Secrets Manager and Parameter Store integration
- **Output Chaining**: Structured outputs for downstream module consumption
- **Cost Optimization**: Variable-driven resource sizing and optimization
- **Compliance Integration**: Security and compliance through variable validation

---

## 🚀 **Exercise 1: Complex Variable Structures and Validation**

### **Objective**
Implement enterprise-grade variable patterns with comprehensive validation rules and type constraints.

### **Tasks**

#### **Task 1.1: Define Complex Variable Types**
Create sophisticated variable structures for infrastructure configuration:

```hcl
# In variables.tf - Complex infrastructure configuration
variable "infrastructure_config" {
  description = "Complete infrastructure configuration with validation"
  type = object({
    environment = object({
      name         = string
      tier         = string
      region       = string
      multi_az     = bool
    })
    
    compute = object({
      web_tier = object({
        instance_type    = string
        min_capacity     = number
        max_capacity     = number
        desired_capacity = number
      })
      
      app_tier = object({
        instance_type    = string
        min_capacity     = number
        max_capacity     = number
        desired_capacity = number
      })
    })
    
    networking = object({
      vpc_cidr             = string
      availability_zones   = list(string)
      public_subnet_cidrs  = list(string)
      private_subnet_cidrs = list(string)
    })
    
    database = object({
      engine            = string
      instance_class    = string
      allocated_storage = number
      backup_retention  = number
      multi_az         = bool
    })
  })
  
  # Comprehensive validation rules
  validation {
    condition = contains([
      "development", "staging", "production"
    ], var.infrastructure_config.environment.name)
    error_message = "Environment must be development, staging, or production."
  }
  
  validation {
    condition = can(cidrhost(var.infrastructure_config.networking.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
  
  validation {
    condition = length(var.infrastructure_config.networking.availability_zones) >= 2
    error_message = "At least 2 availability zones required for high availability."
  }
  
  validation {
    condition = var.infrastructure_config.compute.web_tier.min_capacity <= var.infrastructure_config.compute.web_tier.max_capacity
    error_message = "Web tier min_capacity must be <= max_capacity."
  }
}
```

#### **Task 1.2: Environment-Specific Variable Maps**
Implement environment-specific configuration overrides:

```hcl
# Environment-specific configurations
variable "environment_configs" {
  description = "Environment-specific configuration overrides"
  type = map(object({
    instance_types = object({
      web = string
      app = string
      db  = string
    })
    
    scaling_config = object({
      web_min = number
      web_max = number
      app_min = number
      app_max = number
    })
    
    security_config = object({
      enable_waf    = bool
      ssl_policy    = string
      backup_freq   = string
    })
  }))
  
  default = {
    development = {
      instance_types = {
        web = "t3.micro"
        app = "t3.small"
        db  = "db.t3.micro"
      }
      scaling_config = {
        web_min = 1
        web_max = 3
        app_min = 1
        app_max = 2
      }
      security_config = {
        enable_waf  = false
        ssl_policy  = "ELBSecurityPolicy-TLS-1-2-2017-01"
        backup_freq = "daily"
      }
    }
    
    production = {
      instance_types = {
        web = "t3.large"
        app = "t3.xlarge"
        db  = "db.r5.large"
      }
      scaling_config = {
        web_min = 3
        web_max = 20
        app_min = 3
        app_max = 15
      }
      security_config = {
        enable_waf  = true
        ssl_policy  = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
        backup_freq = "continuous"
      }
    }
  }
}
```

### **Validation Steps**
- [ ] Complex variable types defined correctly
- [ ] Validation rules prevent invalid configurations
- [ ] Environment-specific overrides working
- [ ] Variable inheritance functioning properly

---

## 🔐 **Exercise 2: Sensitive Variable Management with AWS Integration**

### **Objective**
Implement secure handling of sensitive variables using AWS Secrets Manager and Parameter Store.

### **Tasks**

#### **Task 2.1: Define Sensitive Variables**
Create secure variable definitions for sensitive data:

```hcl
# Sensitive database credentials
variable "database_credentials" {
  description = "Database master credentials"
  type = object({
    username = string
    password = string
  })
  sensitive = true
  
  validation {
    condition     = length(var.database_credentials.password) >= 12
    error_message = "Password must be at least 12 characters long."
  }
}

# API keys and external service credentials
variable "api_credentials" {
  description = "External API credentials"
  type = map(object({
    api_key    = string
    secret_key = string
    endpoint   = string
  }))
  sensitive = true
}
```

#### **Task 2.2: AWS Secrets Manager Integration**
Implement AWS Secrets Manager for secure credential storage:

```hcl
# Create secrets in AWS Secrets Manager
resource "aws_secretsmanager_secret" "database_credentials" {
  name        = "${var.project_name}/${var.environment}/database/credentials"
  description = "Database master credentials"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    username = var.database_credentials.username
    password = var.database_credentials.password
  })
}

# API credentials secret
resource "aws_secretsmanager_secret" "api_credentials" {
  name        = "${var.project_name}/${var.environment}/api/credentials"
  description = "External API credentials"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "api_credentials" {
  secret_id     = aws_secretsmanager_secret.api_credentials.id
  secret_string = jsonencode(var.api_credentials)
}
```

#### **Task 2.3: Parameter Store Integration**
Configure AWS Systems Manager Parameter Store for dynamic configuration:

```hcl
# Application configuration parameters
resource "aws_ssm_parameter" "app_config" {
  for_each = {
    "app_version"     = "1.0.0"
    "feature_flags"   = jsonencode({
      enable_new_ui = true
      enable_analytics = false
    })
    "cache_config"    = jsonencode({
      ttl_seconds = 3600
      max_size_mb = 512
    })
  }
  
  name  = "/${var.project_name}/${var.environment}/app/${each.key}"
  type  = "String"
  value = each.value
  
  tags = local.common_tags
}

# Secure parameters for sensitive configuration
resource "aws_ssm_parameter" "secure_config" {
  for_each = {
    "database_endpoint" = aws_rds_instance.main.endpoint
    "redis_endpoint"    = aws_elasticache_cluster.main.cache_nodes[0].address
  }
  
  name  = "/${var.project_name}/${var.environment}/secure/${each.key}"
  type  = "SecureString"
  value = each.value
  
  tags = local.common_tags
}
```

### **Validation Steps**
- [ ] Sensitive variables properly marked and protected
- [ ] AWS Secrets Manager integration working
- [ ] Parameter Store parameters created
- [ ] Secure parameter retrieval functioning

---

## 📤 **Exercise 3: Advanced Output Patterns and Module Integration**

### **Objective**
Design sophisticated output patterns for module chaining and automation integration.

### **Tasks**

#### **Task 3.1: Structured Infrastructure Outputs**
Create comprehensive outputs for downstream module consumption:

```hcl
# Complete infrastructure endpoints
output "infrastructure_endpoints" {
  description = "Complete infrastructure information for module chaining"
  value = {
    networking = {
      vpc_id              = aws_vpc.main.id
      vpc_cidr_block     = aws_vpc.main.cidr_block
      public_subnet_ids  = aws_subnet.public[*].id
      private_subnet_ids = aws_subnet.private[*].id
      security_group_ids = {
        web = aws_security_group.web.id
        app = aws_security_group.app.id
        db  = aws_security_group.db.id
      }
    }
    
    compute = {
      web_tier = {
        load_balancer_dns = aws_lb.web.dns_name
        target_group_arn  = aws_lb_target_group.web.arn
        asg_arn          = aws_autoscaling_group.web.arn
      }
      
      app_tier = {
        load_balancer_dns = aws_lb.app.dns_name
        target_group_arn  = aws_lb_target_group.app.arn
        asg_arn          = aws_autoscaling_group.app.arn
      }
    }
    
    database = {
      endpoint         = aws_rds_instance.main.endpoint
      port            = aws_rds_instance.main.port
      database_name   = aws_rds_instance.main.name
      subnet_group    = aws_db_subnet_group.main.name
    }
    
    storage = {
      s3_buckets = {
        assets = aws_s3_bucket.assets.bucket
        logs   = aws_s3_bucket.logs.bucket
      }
    }
  }
}

# Security and compliance outputs
output "security_configuration" {
  description = "Security configuration for compliance reporting"
  value = {
    encryption = {
      kms_key_ids = {
        ebs = aws_kms_key.ebs.id
        s3  = aws_kms_key.s3.id
        rds = aws_kms_key.rds.id
      }
    }
    
    access_control = {
      iam_roles = {
        ec2_role    = aws_iam_role.ec2.arn
        lambda_role = aws_iam_role.lambda.arn
      }
    }
    
    monitoring = {
      log_groups = {
        application = aws_cloudwatch_log_group.app.name
        access      = aws_cloudwatch_log_group.access.name
      }
      
      cloudtrail_arn = aws_cloudtrail.main.arn
    }
  }
}
```

#### **Task 3.2: Sensitive Outputs for Secure Access**
Implement secure outputs for sensitive information:

```hcl
# Sensitive configuration outputs
output "sensitive_configuration" {
  description = "Sensitive configuration for secure access"
  value = {
    database_connection = {
      connection_string = "postgresql://${var.database_credentials.username}:${var.database_credentials.password}@${aws_rds_instance.main.endpoint}:${aws_rds_instance.main.port}/${aws_rds_instance.main.name}"
      jdbc_url = "jdbc:postgresql://${aws_rds_instance.main.endpoint}:${aws_rds_instance.main.port}/${aws_rds_instance.main.name}"
    }
    
    secrets_manager = {
      database_secret_arn = aws_secretsmanager_secret.database_credentials.arn
      api_secret_arn      = aws_secretsmanager_secret.api_credentials.arn
    }
    
    parameter_store = {
      app_config_prefix    = "/${var.project_name}/${var.environment}/app/"
      secure_config_prefix = "/${var.project_name}/${var.environment}/secure/"
    }
  }
  
  sensitive = true
}
```

### **Validation Steps**
- [ ] Structured outputs created correctly
- [ ] Module integration patterns working
- [ ] Sensitive outputs properly protected
- [ ] Output chaining functioning

---

## 🔄 **Exercise 4: Dynamic Configuration with Local Values**

### **Objective**
Implement dynamic configuration management using local values and computed configurations.

### **Tasks**

#### **Task 4.1: Environment-Specific Local Values**
Create dynamic local values based on environment and variables:

```hcl
# Dynamic configuration based on environment
locals {
  # Current environment configuration
  current_env_config = var.environment_configs[var.environment]
  
  # Computed resource configurations
  web_instance_config = {
    instance_type = local.current_env_config.instance_types.web
    min_size     = local.current_env_config.scaling_config.web_min
    max_size     = local.current_env_config.scaling_config.web_max
    desired_size = local.current_env_config.scaling_config.web_min
  }
  
  app_instance_config = {
    instance_type = local.current_env_config.instance_types.app
    min_size     = local.current_env_config.scaling_config.app_min
    max_size     = local.current_env_config.scaling_config.app_max
    desired_size = local.current_env_config.scaling_config.app_min
  }
  
  # Dynamic tagging
  common_tags = merge(
    var.default_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      Tier        = local.current_env_config.security_config.ssl_policy
    }
  )
  
  # Security configuration
  security_config = {
    enable_waf = local.current_env_config.security_config.enable_waf
    ssl_policy = local.current_env_config.security_config.ssl_policy
    
    # Dynamic security group rules based on environment
    web_ingress_rules = var.environment == "production" ? [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ] : [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}
```

### **Validation Steps**
- [ ] Local values computed correctly
- [ ] Environment-specific configurations applied
- [ ] Dynamic tagging working
- [ ] Security configurations environment-appropriate

---

## 🧪 **Exercise 5: Testing and Validation**

### **Objective**
Validate variable configurations and test different scenarios.

### **Tasks**

#### **Task 5.1: Variable Validation Testing**
Test variable validation rules:

```bash
# Test invalid environment
terraform plan -var='infrastructure_config={
  environment = {
    name = "invalid"
    tier = "basic"
    region = "us-east-1"
    multi_az = true
  }
  # ... rest of config
}'

# Test invalid CIDR
terraform plan -var='infrastructure_config={
  # ... other config
  networking = {
    vpc_cidr = "invalid-cidr"
    # ... rest of networking
  }
}'

# Test capacity validation
terraform plan -var='infrastructure_config={
  # ... other config
  compute = {
    web_tier = {
      min_capacity = 5
      max_capacity = 3  # Invalid: min > max
      # ... rest of config
    }
  }
}'
```

#### **Task 5.2: Environment Testing**
Test different environment configurations:

```bash
# Development environment
terraform plan -var="environment=development"

# Production environment
terraform plan -var="environment=production"

# Compare outputs
terraform console
> local.current_env_config
> local.web_instance_config
```

### **Validation Steps**
- [ ] Validation rules catch invalid configurations
- [ ] Environment-specific configurations work correctly
- [ ] Variable precedence functioning properly
- [ ] Output values computed correctly

---

## 📊 **Lab Completion Checklist**

### **Infrastructure Validation**
- [ ] Complex variable structures implemented
- [ ] Validation rules preventing invalid configurations
- [ ] Sensitive variables properly secured
- [ ] AWS Secrets Manager integration working
- [ ] Parameter Store integration functioning
- [ ] Structured outputs created
- [ ] Environment-specific configurations applied
- [ ] Local values computed correctly

### **Security Validation**
- [ ] Sensitive data properly marked and protected
- [ ] AWS Secrets Manager storing credentials securely
- [ ] Parameter Store using SecureString for sensitive data
- [ ] Sensitive outputs properly protected
- [ ] IAM roles and policies correctly configured

### **Functionality Validation**
- [ ] Variable inheritance working across environments
- [ ] Output chaining patterns functional
- [ ] Dynamic configuration responding to environment changes
- [ ] Cost optimization variables affecting resource sizing
- [ ] Compliance validation rules enforced

---

## 🎯 **Key Takeaways**

1. **Complex Variable Patterns**: Enterprise infrastructure requires sophisticated variable structures with comprehensive validation
2. **Security Integration**: AWS services provide robust solutions for sensitive data management in Terraform
3. **Output Design**: Well-structured outputs enable seamless module integration and automation
4. **Dynamic Configuration**: Environment-specific variables enable code reuse while maintaining environment isolation
5. **Validation Importance**: Comprehensive validation prevents configuration errors and ensures compliance

---

**Lab Duration**: 90-120 minutes  
**Difficulty**: Intermediate to Advanced  
**Next Topic**: State Management with AWS (Topic 6)  
**Prerequisites for Next Lab**: Understanding of variable patterns and output structures
