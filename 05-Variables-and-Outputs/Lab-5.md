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

## 🆕 **Bonus Section: Advanced Variable Management Patterns (2025)**

### **Part 6: Enhanced Validation with Business Logic (20 minutes)**

**Step 1: Advanced Multi-Validation Patterns**
```bash
# Create advanced validation configuration
cat > advanced-validation.tf << 'EOF'
# Complex infrastructure deployment variable with multiple validations
variable "infrastructure_deployment" {
  description = "Complete infrastructure deployment configuration with business rules"
  type = object({
    environment = string
    region      = string

    compute_config = object({
      instance_type     = string
      min_capacity      = number
      max_capacity      = number
      desired_capacity  = number
      enable_spot       = bool
    })

    database_config = object({
      engine_version    = string
      instance_class    = string
      allocated_storage = number
      backup_retention  = number
      multi_az         = bool
    })

    security_config = object({
      enable_waf           = bool
      enable_shield        = bool
      ssl_policy          = string
      encryption_at_rest  = bool
      encryption_in_transit = bool
    })
  })

  # Environment validation
  validation {
    condition = contains(["development", "staging", "production"], var.infrastructure_deployment.environment)
    error_message = "Environment must be development, staging, or production."
  }

  # Capacity validation with business logic
  validation {
    condition = var.infrastructure_deployment.compute_config.min_capacity <= var.infrastructure_deployment.compute_config.desired_capacity
    error_message = "Minimum capacity must be less than or equal to desired capacity."
  }

  validation {
    condition = var.infrastructure_deployment.compute_config.desired_capacity <= var.infrastructure_deployment.compute_config.max_capacity
    error_message = "Desired capacity must be less than or equal to maximum capacity."
  }

  # Production-specific validations
  validation {
    condition = var.infrastructure_deployment.database_config.backup_retention >= (var.infrastructure_deployment.environment == "production" ? 7 : 1)
    error_message = "Production environments require minimum 7 days backup retention."
  }

  validation {
    condition = var.infrastructure_deployment.security_config.encryption_at_rest == true || var.infrastructure_deployment.environment != "production"
    error_message = "Production environments must have encryption at rest enabled."
  }

  validation {
    condition = var.infrastructure_deployment.database_config.multi_az == true || var.infrastructure_deployment.environment != "production"
    error_message = "Production environments must have Multi-AZ enabled for high availability."
  }

  # Instance type validation based on environment
  validation {
    condition = var.infrastructure_deployment.environment == "production" ? !can(regex("^t2\\.", var.infrastructure_deployment.compute_config.instance_type)) : true
    error_message = "Production environments should not use t2 instance types. Use t3 or higher."
  }
}

# Test the validation with different configurations
variable "test_configs" {
  description = "Test configurations for validation"
  type = map(object({
    environment = string
    region      = string

    compute_config = object({
      instance_type     = string
      min_capacity      = number
      max_capacity      = number
      desired_capacity  = number
      enable_spot       = bool
    })

    database_config = object({
      engine_version    = string
      instance_class    = string
      allocated_storage = number
      backup_retention  = number
      multi_az         = bool
    })

    security_config = object({
      enable_waf           = bool
      enable_shield        = bool
      ssl_policy          = string
      encryption_at_rest  = bool
      encryption_in_transit = bool
    })
  }))

  default = {
    development = {
      environment = "development"
      region      = "us-east-1"

      compute_config = {
        instance_type     = "t3.micro"
        min_capacity      = 1
        max_capacity      = 3
        desired_capacity  = 1
        enable_spot       = true
      }

      database_config = {
        engine_version    = "8.0"
        instance_class    = "db.t3.micro"
        allocated_storage = 20
        backup_retention  = 1
        multi_az         = false
      }

      security_config = {
        enable_waf           = false
        enable_shield        = false
        ssl_policy          = "ELBSecurityPolicy-TLS-1-2-2017-01"
        encryption_at_rest  = false
        encryption_in_transit = true
      }
    }

    production = {
      environment = "production"
      region      = "us-east-1"

      compute_config = {
        instance_type     = "t3.large"
        min_capacity      = 2
        max_capacity      = 10
        desired_capacity  = 3
        enable_spot       = false
      }

      database_config = {
        engine_version    = "8.0"
        instance_class    = "db.t3.medium"
        allocated_storage = 100
        backup_retention  = 7
        multi_az         = true
      }

      security_config = {
        enable_waf           = true
        enable_shield        = true
        ssl_policy          = "ELBSecurityPolicy-TLS-1-2-2017-01"
        encryption_at_rest  = true
        encryption_in_transit = true
      }
    }
  }
}

# Output validation results
output "validation_test_results" {
  description = "Results of validation testing"
  value = {
    for env, config in var.test_configs : env => {
      environment = config.environment
      passes_validation = true  # If we get here, validation passed
      config_summary = {
        compute_instance_type = config.compute_config.instance_type
        database_multi_az = config.database_config.multi_az
        encryption_enabled = config.security_config.encryption_at_rest
        backup_retention = config.database_config.backup_retention
      }
    }
  }
}
EOF

# Test validation with different configurations
terraform plan -var="infrastructure_deployment=$(cat <<JSON
{
  "environment": "development",
  "region": "us-east-1",
  "compute_config": {
    "instance_type": "t3.micro",
    "min_capacity": 1,
    "max_capacity": 3,
    "desired_capacity": 1,
    "enable_spot": true
  },
  "database_config": {
    "engine_version": "8.0",
    "instance_class": "db.t3.micro",
    "allocated_storage": 20,
    "backup_retention": 1,
    "multi_az": false
  },
  "security_config": {
    "enable_waf": false,
    "enable_shield": false,
    "ssl_policy": "ELBSecurityPolicy-TLS-1-2-2017-01",
    "encryption_at_rest": false,
    "encryption_in_transit": true
  }
}
JSON
)"
```

**Step 2: Dynamic Variable Processing with Functions**
```bash
# Create dynamic processing configuration
cat > dynamic-processing.tf << 'EOF'
# Environment-specific configurations
locals {
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

  # Dynamic configuration selection
  selected_config = local.environment_configs[var.environment]

  # Advanced variable processing
  computed_variables = {
    # Dynamic instance type selection based on workload
    optimal_instance_type = var.enable_cost_optimization ?
      local.selected_config.instance_types[0] :
      local.selected_config.instance_types[length(local.selected_config.instance_types) - 1]

    # Dynamic storage configuration
    storage_configuration = {
      type = local.selected_config.storage_types[0]
      size = var.database_storage_size
      iops = contains(local.selected_config.storage_types, "io1") ?
        max(100, var.database_storage_size * 3) : null
      throughput = contains(local.selected_config.storage_types, "gp3") ? 125 : null
    }

    # Dynamic security configuration
    security_settings = {
      enable_detailed_monitoring = local.selected_config.monitoring_level == "comprehensive"
      enable_cloudtrail = var.environment == "production"
      enable_config_rules = var.environment != "development"
      enable_guardduty = var.environment == "production"
      enable_security_hub = var.environment == "production"
    }

    # Dynamic backup configuration
    backup_settings = {
      retention_days = var.environment == "production" ? 30 : (var.environment == "staging" ? 7 : 3)
      backup_window = var.environment == "production" ? "03:00-04:00" : "02:00-03:00"
      maintenance_window = var.environment == "production" ? "sun:04:00-sun:05:00" : "sun:03:00-sun:04:00"
      delete_automated_backups = var.environment == "development"
    }
  }
}

# Output dynamic configurations
output "dynamic_configuration_results" {
  description = "Results of dynamic configuration processing"
  value = {
    environment = var.environment
    selected_config = local.selected_config
    computed_variables = local.computed_variables

    recommendations = {
      instance_type = local.computed_variables.optimal_instance_type
      storage_type = local.computed_variables.storage_configuration.type
      monitoring_level = local.selected_config.monitoring_level
      security_features = length([
        for k, v in local.computed_variables.security_settings : k if v == true
      ])
    }
  }
}
EOF

# Test dynamic processing
terraform plan
```

### **Part 7: AWS Integration with Parameter Store and Secrets Manager (15 minutes)**

**Step 1: Dynamic Parameter Management**
```bash
# Create AWS integration configuration
cat > aws-integration.tf << 'EOF'
# Dynamic parameter retrieval from AWS Parameter Store
data "aws_ssm_parameters_by_path" "app_config" {
  path = "/${var.environment}/app-config"

  # Only retrieve if environment-specific parameters exist
  count = var.environment != "development" ? 1 : 0
}

# Create environment-specific parameters
resource "aws_ssm_parameter" "app_config" {
  for_each = {
    "database-url" = "mysql://localhost:3306/app_${var.environment}"
    "api-endpoint" = "https://api-${var.environment}.example.com"
    "cache-ttl" = var.environment == "production" ? "3600" : "300"
    "log-level" = var.environment == "production" ? "INFO" : "DEBUG"
  }

  name  = "/${var.environment}/app-config/${each.key}"
  type  = "String"
  value = each.value

  tags = merge(local.common_tags, {
    Environment = var.environment
    ParameterType = "app-config"
  })
}

# Dynamic secrets management
resource "aws_secretsmanager_secret" "dynamic_secrets" {
  for_each = toset([
    "database-credentials",
    "api-keys",
    "encryption-keys"
  ])

  name = "${local.name_prefix}-${each.key}"
  description = "Dynamic secret for ${each.key} in ${var.environment}"

  # Environment-specific rotation
  rotation_rules {
    automatically_after_days = var.environment == "production" ? 30 : 90
  }

  tags = merge(local.common_tags, {
    SecretType = each.key
    Environment = var.environment
  })
}

# Generate random passwords for secrets
resource "random_password" "secret_values" {
  for_each = aws_secretsmanager_secret.dynamic_secrets

  length  = 32
  special = true
}

# Store secret values
resource "aws_secretsmanager_secret_version" "secret_values" {
  for_each = aws_secretsmanager_secret.dynamic_secrets

  secret_id = each.value.id
  secret_string = jsonencode({
    password = random_password.secret_values[each.key].result
    created_date = timestamp()
    environment = var.environment
  })
}

# Output AWS integration results
output "aws_integration_results" {
  description = "Results of AWS Parameter Store and Secrets Manager integration"
  value = {
    parameters_created = length(aws_ssm_parameter.app_config)
    secrets_created = length(aws_secretsmanager_secret.dynamic_secrets)

    parameter_names = [
      for param in aws_ssm_parameter.app_config : param.name
    ]

    secret_arns = {
      for k, secret in aws_secretsmanager_secret.dynamic_secrets : k => secret.arn
    }

    integration_summary = {
      environment = var.environment
      parameters_path = "/${var.environment}/app-config"
      secrets_prefix = local.name_prefix
      rotation_enabled = var.environment == "production"
    }
  }

  sensitive = false
}
EOF

# Apply AWS integration
terraform plan -target=aws_ssm_parameter.app_config
terraform apply -target=aws_ssm_parameter.app_config -auto-approve
```

### **Part 8: Advanced Output Patterns with Conditional Logic (10 minutes)**

**Step 1: Conditional and Structured Outputs**
```bash
# Create advanced output configuration
cat > advanced-outputs.tf << 'EOF'
# Conditional outputs based on environment and configuration
output "infrastructure_endpoints" {
  description = "Dynamic infrastructure endpoints based on deployment configuration"
  value = {
    # Conditional web endpoints
    web_endpoints = var.instance_count > 1 ? {
      load_balancer_dns = try(aws_lb.main[0].dns_name, null)
      load_balancer_zone_id = try(aws_lb.main[0].zone_id, null)
      health_check_url = try("https://${aws_lb.main[0].dns_name}/health", null)
      target_group_arn = try(aws_lb_target_group.web[0].arn, null)
    } : {
      instance_public_ip = try(aws_instance.web[0].public_ip, null)
      instance_private_ip = try(aws_instance.web[0].private_ip, null)
      direct_access_url = try("http://${aws_instance.web[0].public_ip}", null)
    }

    # Conditional database endpoints
    database_endpoints = var.enable_database ? {
      primary_endpoint = aws_db_instance.main[0].endpoint
      port = aws_db_instance.main[0].port
      reader_endpoint = var.enable_read_replica ? aws_db_instance.replica[0].endpoint : null
    } : null

    # Environment-specific monitoring endpoints
    monitoring_endpoints = var.environment == "production" ? {
      cloudwatch_dashboard = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${local.name_prefix}"
      parameter_store_path = "https://console.aws.amazon.com/systems-manager/parameters/?region=${var.aws_region}&tab=Table#list_parameter_filters=Name:Contains:${var.environment}"
      secrets_manager = "https://console.aws.amazon.com/secretsmanager/home?region=${var.aws_region}#/listSecrets"
    } : null
  }

  sensitive = false
}

# Advanced sensitive output handling
output "security_credentials" {
  description = "Security credentials and sensitive configuration data"
  value = var.output_sensitive_data ? {
    database_connection = var.enable_database ? {
      username = aws_db_instance.main[0].username
      endpoint = aws_db_instance.main[0].endpoint
      port     = aws_db_instance.main[0].port
      secret_arn = aws_secretsmanager_secret.dynamic_secrets["database-credentials"].arn
    } : null

    api_keys = {
      app_api_key_parameter = aws_ssm_parameter.app_config["api-endpoint"].name
      secrets_arns = {
        for k, v in aws_secretsmanager_secret.dynamic_secrets : k => v.arn
      }
    }

    encryption_keys = var.enable_encryption ? {
      kms_key_id = aws_kms_key.main[0].id
      kms_key_arn = aws_kms_key.main[0].arn
    } : null
  } : null

  sensitive = true
}

# Configuration summary output
output "deployment_summary" {
  description = "Comprehensive deployment summary"
  value = {
    environment = var.environment
    region = var.aws_region

    infrastructure = {
      compute_instances = var.instance_count
      database_enabled = var.enable_database
      load_balancer_enabled = var.instance_count > 1
      encryption_enabled = var.enable_encryption
    }

    configuration = {
      selected_config = local.selected_config
      computed_variables = local.computed_variables
      aws_integration = {
        parameters_count = length(aws_ssm_parameter.app_config)
        secrets_count = length(aws_secretsmanager_secret.dynamic_secrets)
      }
    }

    costs_estimate = {
      monthly_compute = var.instance_count * (var.environment == "production" ? 50 : 20)
      monthly_database = var.enable_database ? (var.environment == "production" ? 100 : 30) : 0
      monthly_storage = var.enable_database ? 10 : 0
      total_estimated = var.instance_count * (var.environment == "production" ? 50 : 20) +
                       (var.enable_database ? (var.environment == "production" ? 110 : 40) : 0)
    }
  }
}
EOF

# Test advanced outputs
terraform plan
terraform apply -auto-approve

# View outputs
terraform output infrastructure_endpoints
terraform output deployment_summary
```

### **Validation and Testing**

**Test All Advanced Features**:
```bash
# Test 1: Advanced validation patterns
terraform validate

# Test 2: Dynamic variable processing
terraform console << 'EOF'
local.computed_variables
local.selected_config
EOF

# Test 3: AWS integration
aws ssm get-parameters-by-path --path "/${var.environment}/app-config" --region us-east-1

# Test 4: Conditional outputs
terraform output -json | jq '.infrastructure_endpoints.value'

# Test 5: Sensitive data handling
terraform output -json security_credentials

echo "🎉 All advanced variable management patterns tested successfully!"
```

---

**Lab Duration**: 120-150 minutes
**Difficulty**: Intermediate to Advanced
**Next Topic**: State Management with AWS (Topic 6)
**Prerequisites for Next Lab**: Understanding of variable patterns and output structures
**🆕 2025 Features**: Advanced Validation, Dynamic Processing, AWS Integration
