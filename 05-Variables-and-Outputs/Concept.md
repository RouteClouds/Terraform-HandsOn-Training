# AWS Terraform Training - Variables and Outputs

## 🎯 **Topic 5: Advanced Variable Management and Output Patterns**

### **Master Dynamic Configuration, Data Flow, and Enterprise Variable Strategies**

This comprehensive module provides deep expertise in Terraform variable management and output patterns, focusing on enterprise-grade configuration strategies, sensitive data handling, advanced validation techniques, and seamless integration with AWS services for dynamic infrastructure management.

---

## 📋 **Learning Objectives**

By completing this topic, you will achieve measurable mastery in:

### **Primary Learning Outcomes**
1. **Advanced Variable Patterns** - Design complex variable structures with comprehensive validation and type constraints
2. **Dynamic Configuration Management** - Implement environment-specific configurations with automated parameter management
3. **Sensitive Data Security** - Master secure handling of sensitive variables with AWS integration
4. **Output Chaining Strategies** - Create sophisticated output patterns for module integration and automation
5. **Enterprise Variable Architecture** - Implement scalable variable organization for large-scale infrastructure

### **Measurable Success Criteria**
- **Configuration Flexibility**: Support 10+ environments with 95% code reuse through variable patterns
- **Security Compliance**: 100% secure handling of sensitive data with AWS Secrets Manager integration
- **Validation Effectiveness**: Prevent 90% of configuration errors through comprehensive validation rules
- **Automation Integration**: Enable seamless CI/CD integration with structured output patterns
- **Maintainability**: Reduce configuration management overhead by 60% through organized variable architecture

---

## 🏗️ **Enterprise Variable Architecture**

### **1. Advanced Variable Types and Patterns**

![Variable Architecture](DaC/generated_diagrams/variable_architecture.png)
*Figure 5.1: Enterprise variable architecture with type hierarchies, validation layers, and security controls*

#### **Complex Variable Type Definitions**
```hcl
# Enterprise-grade variable patterns with comprehensive validation
variable "infrastructure_config" {
  description = "Complete infrastructure configuration object"
  type = object({
    # Environment configuration
    environment = object({
      name         = string
      tier         = string
      region       = string
      multi_az     = bool
      backup_enabled = bool
    })
    
    # Compute configuration
    compute = object({
      web_tier = object({
        instance_type    = string
        min_capacity     = number
        max_capacity     = number
        desired_capacity = number
        ami_id          = optional(string)
      })
      
      app_tier = object({
        instance_type    = string
        min_capacity     = number
        max_capacity     = number
        desired_capacity = number
        ami_id          = optional(string)
      })
    })
    
    # Network configuration
    networking = object({
      vpc_cidr             = string
      availability_zones   = list(string)
      public_subnet_cidrs  = list(string)
      private_subnet_cidrs = list(string)
      enable_nat_gateway   = bool
      enable_vpn_gateway   = bool
    })
    
    # Database configuration
    database = object({
      engine               = string
      engine_version       = string
      instance_class       = string
      allocated_storage    = number
      backup_retention     = number
      multi_az            = bool
      encryption_enabled   = bool
    })
    
    # Monitoring configuration
    monitoring = object({
      enable_detailed_monitoring = bool
      log_retention_days         = number
      enable_cloudtrail         = bool
      enable_config             = bool
      alert_email               = string
    })
  })
  
  # Comprehensive validation rules
  validation {
    condition = contains([
      "development", "staging", "production", "disaster-recovery"
    ], var.infrastructure_config.environment.name)
    error_message = "Environment name must be development, staging, production, or disaster-recovery."
  }
  
  validation {
    condition = contains([
      "basic", "standard", "premium", "enterprise"
    ], var.infrastructure_config.environment.tier)
    error_message = "Environment tier must be basic, standard, premium, or enterprise."
  }
  
  validation {
    condition = can(cidrhost(var.infrastructure_config.networking.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
  
  validation {
    condition = length(var.infrastructure_config.networking.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for high availability."
  }
  
  validation {
    condition = var.infrastructure_config.compute.web_tier.min_capacity <= var.infrastructure_config.compute.web_tier.max_capacity
    error_message = "Web tier min_capacity must be less than or equal to max_capacity."
  }
  
  validation {
    condition = contains([
      "mysql", "postgres", "mariadb", "oracle-ee", "sqlserver-ee"
    ], var.infrastructure_config.database.engine)
    error_message = "Database engine must be a supported RDS engine type."
  }
  
  validation {
    condition = var.infrastructure_config.database.backup_retention >= 1 && var.infrastructure_config.database.backup_retention <= 35
    error_message = "Database backup retention must be between 1 and 35 days."
  }
}

# Environment-specific variable maps
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
      enable_waf           = bool
      enable_shield        = bool
      ssl_policy          = string
      backup_frequency    = string
    })
    
    cost_config = object({
      enable_spot_instances = bool
      reserved_capacity     = number
      budget_limit_usd     = number
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
        enable_waf        = false
        enable_shield     = false
        ssl_policy       = "ELBSecurityPolicy-TLS-1-2-2017-01"
        backup_frequency = "daily"
      }
      cost_config = {
        enable_spot_instances = true
        reserved_capacity     = 0
        budget_limit_usd     = 100
      }
    }
    
    staging = {
      instance_types = {
        web = "t3.small"
        app = "t3.medium"
        db  = "db.t3.small"
      }
      scaling_config = {
        web_min = 2
        web_max = 6
        app_min = 2
        app_max = 4
      }
      security_config = {
        enable_waf        = true
        enable_shield     = false
        ssl_policy       = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
        backup_frequency = "daily"
      }
      cost_config = {
        enable_spot_instances = true
        reserved_capacity     = 25
        budget_limit_usd     = 500
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
        enable_waf        = true
        enable_shield     = true
        ssl_policy       = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
        backup_frequency = "continuous"
      }
      cost_config = {
        enable_spot_instances = false
        reserved_capacity     = 75
        budget_limit_usd     = 5000
      }
    }
  }
  
  validation {
    condition = alltrue([
      for env_name, config in var.environment_configs : contains([
        "t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge"
      ], config.instance_types.web)
    ])
    error_message = "Web instance types must be valid t3 instance types."
  }
  
  validation {
    condition = alltrue([
      for env_name, config in var.environment_configs : 
      config.scaling_config.web_min <= config.scaling_config.web_max
    ])
    error_message = "Web tier min capacity must be less than or equal to max capacity for all environments."
  }
  
  validation {
    condition = alltrue([
      for env_name, config in var.environment_configs : 
      config.cost_config.budget_limit_usd > 0
    ])
    error_message = "Budget limit must be greater than 0 for all environments."
  }
}
```

#### **Sensitive Variable Management with AWS Integration**
```hcl
# Sensitive variables with comprehensive security
variable "database_credentials" {
  description = "Database master credentials"
  type = object({
    username = string
    password = string
  })
  sensitive = true
  
  validation {
    condition     = length(var.database_credentials.password) >= 12
    error_message = "Database password must be at least 12 characters long."
  }
  
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_credentials.username))
    error_message = "Database username must start with a letter and contain only alphanumeric characters and underscores."
  }
}

# API keys and secrets management
variable "api_credentials" {
  description = "External API credentials and keys"
  type = map(object({
    api_key    = string
    secret_key = string
    endpoint   = string
    region     = optional(string, "us-east-1")
  }))
  sensitive = true
  
  validation {
    condition = alltrue([
      for service, creds in var.api_credentials : 
      length(creds.api_key) >= 20 && length(creds.secret_key) >= 40
    ])
    error_message = "API keys must be at least 20 characters and secret keys at least 40 characters."
  }
}

# SSL/TLS certificate configuration
variable "ssl_certificates" {
  description = "SSL certificate configuration for load balancers"
  type = map(object({
    domain_name       = string
    subject_alternative_names = list(string)
    validation_method = string
    key_algorithm     = optional(string, "RSA_2048")
  }))
  sensitive = true
  
  validation {
    condition = alltrue([
      for cert_name, cert in var.ssl_certificates : 
      contains(["DNS", "EMAIL"], cert.validation_method)
    ])
    error_message = "SSL certificate validation method must be DNS or EMAIL."
  }
  
  validation {
    condition = alltrue([
      for cert_name, cert in var.ssl_certificates : 
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\\.[a-zA-Z]{2,}$", cert.domain_name))
    ])
    error_message = "Domain names must be valid FQDN format."
  }
}
```

### **2. Advanced Output Patterns and Data Flow**

![Output Architecture](DaC/generated_diagrams/output_architecture.png)
*Figure 5.2: Enterprise output architecture with data flow patterns, module integration, and automation interfaces*

#### **Structured Output Patterns for Module Integration**
```hcl
# Comprehensive infrastructure outputs for module chaining
output "infrastructure_endpoints" {
  description = "Complete infrastructure endpoint information for downstream modules"
  value = {
    # Network endpoints
    networking = {
      vpc_id                = aws_vpc.main.id
      vpc_cidr_block       = aws_vpc.main.cidr_block
      internet_gateway_id  = aws_internet_gateway.main.id
      nat_gateway_ids      = aws_nat_gateway.main[*].id
      
      public_subnets = {
        ids          = aws_subnet.public[*].id
        cidr_blocks  = aws_subnet.public[*].cidr_block
        route_table_id = aws_route_table.public.id
      }
      
      private_subnets = {
        ids          = aws_subnet.private[*].id
        cidr_blocks  = aws_subnet.private[*].cidr_block
        route_table_ids = aws_route_table.private[*].id
      }
      
      security_groups = {
        web_sg_id = aws_security_group.web.id
        app_sg_id = aws_security_group.app.id
        db_sg_id  = aws_security_group.db.id
      }
    }
    
    # Compute endpoints
    compute = {
      web_tier = {
        load_balancer_arn     = aws_lb.web.arn
        load_balancer_dns     = aws_lb.web.dns_name
        load_balancer_zone_id = aws_lb.web.zone_id
        target_group_arn      = aws_lb_target_group.web.arn
        auto_scaling_group_arn = aws_autoscaling_group.web.arn
      }
      
      app_tier = {
        load_balancer_arn     = aws_lb.app.arn
        load_balancer_dns     = aws_lb.app.dns_name
        target_group_arn      = aws_lb_target_group.app.arn
        auto_scaling_group_arn = aws_autoscaling_group.app.arn
      }
    }
    
    # Database endpoints
    database = {
      primary = {
        endpoint = aws_rds_instance.main.endpoint
        port     = aws_rds_instance.main.port
        engine   = aws_rds_instance.main.engine
        version  = aws_rds_instance.main.engine_version
      }
      
      read_replicas = {
        endpoints = aws_rds_instance.read_replica[*].endpoint
        count     = length(aws_rds_instance.read_replica)
      }
      
      subnet_group_name = aws_db_subnet_group.main.name
      parameter_group_name = aws_db_parameter_group.main.name
    }
    
    # Storage endpoints
    storage = {
      s3_buckets = {
        assets = {
          bucket_name = aws_s3_bucket.assets.bucket
          bucket_arn  = aws_s3_bucket.assets.arn
          domain_name = aws_s3_bucket.assets.bucket_domain_name
        }
        
        logs = {
          bucket_name = aws_s3_bucket.logs.bucket
          bucket_arn  = aws_s3_bucket.logs.arn
        }
      }
      
      efs_file_systems = {
        shared_storage = {
          file_system_id = aws_efs_file_system.shared.id
          dns_name       = aws_efs_file_system.shared.dns_name
          mount_targets  = aws_efs_mount_target.shared[*].dns_name
        }
      }
    }
  }
  
  depends_on = [
    aws_vpc.main,
    aws_subnet.public,
    aws_subnet.private,
    aws_lb.web,
    aws_lb.app,
    aws_rds_instance.main
  ]
}

# Security and compliance outputs
output "security_configuration" {
  description = "Security configuration details for compliance and auditing"
  value = {
    # Encryption configuration
    encryption = {
      kms_keys = {
        ebs_key_id = aws_kms_key.ebs.id
        s3_key_id  = aws_kms_key.s3.id
        rds_key_id = aws_kms_key.rds.id
      }
      
      ssl_certificates = {
        for cert_name, cert in aws_acm_certificate.main : 
        cert_name => {
          arn    = cert.arn
          domain = cert.domain_name
          status = cert.status
        }
      }
    }
    
    # Access control
    access_control = {
      iam_roles = {
        ec2_role_arn      = aws_iam_role.ec2.arn
        lambda_role_arn   = aws_iam_role.lambda.arn
        rds_role_arn      = aws_iam_role.rds.arn
      }
      
      security_groups = {
        web_sg_rules = length(aws_security_group_rule.web)
        app_sg_rules = length(aws_security_group_rule.app)
        db_sg_rules  = length(aws_security_group_rule.db)
      }
    }
    
    # Monitoring and logging
    monitoring = {
      cloudwatch_log_groups = {
        application_logs = aws_cloudwatch_log_group.app.name
        access_logs      = aws_cloudwatch_log_group.access.name
        error_logs       = aws_cloudwatch_log_group.error.name
      }
      
      cloudtrail = {
        trail_arn    = aws_cloudtrail.main.arn
        s3_bucket    = aws_cloudtrail.main.s3_bucket_name
        kms_key_id   = aws_cloudtrail.main.kms_key_id
      }
    }
  }
  
  sensitive = false
}

# Sensitive outputs for secure data access
output "sensitive_configuration" {
  description = "Sensitive configuration data for secure access"
  value = {
    # Database connection information
    database_connections = {
      primary = {
        connection_string = "postgresql://${var.database_credentials.username}:${var.database_credentials.password}@${aws_rds_instance.main.endpoint}:${aws_rds_instance.main.port}/${aws_rds_instance.main.name}"
        jdbc_url = "jdbc:postgresql://${aws_rds_instance.main.endpoint}:${aws_rds_instance.main.port}/${aws_rds_instance.main.name}"
      }
    }
    
    # API endpoint configurations
    api_endpoints = {
      for service, config in var.api_credentials :
      service => {
        endpoint   = config.endpoint
        api_key    = config.api_key
        secret_key = config.secret_key
      }
    }
    
    # Secret manager references
    secrets_manager = {
      database_secret_arn = aws_secretsmanager_secret.database.arn
      api_keys_secret_arn = aws_secretsmanager_secret.api_keys.arn
    }
  }
  
  sensitive = true
}
```

---

## 🔄 **Dynamic Configuration Patterns**

### **1. Environment-Specific Variable Management**

![Environment Configuration](DaC/generated_diagrams/environment_configuration.png)
*Figure 5.3: Environment-specific configuration management with inheritance patterns and override mechanisms*

#### **Hierarchical Configuration with Inheritance**
```hcl
# Base configuration that all environments inherit
locals {
  base_config = {
    # Common settings across all environments
    common = {
      project_name = var.project_name
      owner_email  = var.owner_email
      cost_center  = var.cost_center
      
      # Default tags applied to all resources
      default_tags = {
        Project     = var.project_name
        ManagedBy   = "terraform"
        Owner       = var.owner_email
        CostCenter  = var.cost_center
        Backup      = "required"
        Monitoring  = "enabled"
      }
      
      # Security defaults
      security_defaults = {
        encryption_enabled = true
        ssl_required      = true
        mfa_required      = false
        audit_logging     = true
      }
      
      # Network defaults
      network_defaults = {
        enable_dns_hostnames = true
        enable_dns_support   = true
        enable_nat_gateway   = true
        single_nat_gateway   = false
      }
    }
    
    # Environment-specific overrides
    environments = {
      development = merge(local.base_config.common, {
        # Development-specific settings
        environment_tier = "basic"
        
        # Relaxed security for development
        security_overrides = {
          mfa_required = false
          ssl_required = false
        }
        
        # Cost optimization for development
        cost_optimization = {
          enable_spot_instances = true
          single_nat_gateway   = true
          enable_auto_shutdown = true
        }
        
        # Development-specific tags
        environment_tags = {
          Environment = "development"
          Tier        = "basic"
          AutoShutdown = "enabled"
        }
      })
      
      staging = merge(local.base_config.common, {
        # Staging-specific settings
        environment_tier = "standard"
        
        # Production-like security
        security_overrides = {
          mfa_required = true
          ssl_required = true
        }
        
        # Balanced cost and performance
        cost_optimization = {
          enable_spot_instances = true
          single_nat_gateway   = false
          enable_auto_shutdown = false
        }
        
        # Staging-specific tags
        environment_tags = {
          Environment = "staging"
          Tier        = "standard"
          AutoShutdown = "disabled"
        }
      })
      
      production = merge(local.base_config.common, {
        # Production-specific settings
        environment_tier = "enterprise"
        
        # Maximum security for production
        security_overrides = {
          mfa_required = true
          ssl_required = true
        }
        
        # Performance and reliability focus
        cost_optimization = {
          enable_spot_instances = false
          single_nat_gateway   = false
          enable_auto_shutdown = false
        }
        
        # Production-specific tags
        environment_tags = {
          Environment = "production"
          Tier        = "enterprise"
          AutoShutdown = "disabled"
          Compliance  = "required"
        }
      })
    }
  }
  
  # Current environment configuration
  current_config = local.base_config.environments[var.environment]
  
  # Merged configuration with environment-specific overrides
  final_config = merge(
    local.base_config.common,
    local.current_config,
    {
      # Final computed values
      all_tags = merge(
        local.base_config.common.default_tags,
        local.current_config.environment_tags,
        var.additional_tags
      )
      
      security_config = merge(
        local.base_config.common.security_defaults,
        local.current_config.security_overrides
      )
      
      network_config = merge(
        local.base_config.common.network_defaults,
        local.current_config.cost_optimization
      )
    }
  )
}
```

### **2. AWS Parameter Store Integration**

#### **Dynamic Parameter Management with AWS Systems Manager**
```hcl
# Parameter Store integration for dynamic configuration
data "aws_ssm_parameter" "database_config" {
  for_each = toset([
    "database_engine",
    "database_version", 
    "database_instance_class",
    "backup_retention_period"
  ])
  
  name = "/${var.project_name}/${var.environment}/database/${each.key}"
}

data "aws_ssm_parameter" "application_config" {
  for_each = toset([
    "app_version",
    "feature_flags",
    "api_endpoints",
    "cache_configuration"
  ])
  
  name = "/${var.project_name}/${var.environment}/application/${each.key}"
}

# Secure parameter retrieval for sensitive data
data "aws_ssm_parameter" "database_password" {
  name            = "/${var.project_name}/${var.environment}/database/master_password"
  with_decryption = true
}

data "aws_ssm_parameter" "api_keys" {
  name            = "/${var.project_name}/${var.environment}/api/external_keys"
  with_decryption = true
}

# Local values computed from parameter store
locals {
  # Database configuration from Parameter Store
  database_config = {
    engine         = data.aws_ssm_parameter.database_config["database_engine"].value
    engine_version = data.aws_ssm_parameter.database_config["database_version"].value
    instance_class = data.aws_ssm_parameter.database_config["database_instance_class"].value
    backup_retention = tonumber(data.aws_ssm_parameter.database_config["backup_retention_period"].value)
    master_password = data.aws_ssm_parameter.database_password.value
  }
  
  # Application configuration from Parameter Store
  application_config = {
    version = data.aws_ssm_parameter.application_config["app_version"].value
    feature_flags = jsondecode(data.aws_ssm_parameter.application_config["feature_flags"].value)
    api_endpoints = jsondecode(data.aws_ssm_parameter.application_config["api_endpoints"].value)
    cache_config = jsondecode(data.aws_ssm_parameter.application_config["cache_configuration"].value)
  }
  
  # External API configuration
  external_apis = jsondecode(data.aws_ssm_parameter.api_keys.value)
}
```

---

## 💰 **Cost Optimization Through Variable Management**

### **Dynamic Resource Sizing and Cost Controls**
```hcl
# Cost-aware variable patterns
variable "cost_optimization_config" {
  description = "Cost optimization configuration with budget controls"
  type = object({
    # Budget controls
    monthly_budget_limit = number
    cost_alert_thresholds = list(number)
    
    # Resource optimization
    enable_spot_instances = bool
    reserved_capacity_percentage = number
    auto_scaling_policies = object({
      scale_down_enabled = bool
      scale_down_cooldown = number
      target_utilization = number
    })
    
    # Storage optimization
    storage_optimization = object({
      enable_intelligent_tiering = bool
      lifecycle_policies_enabled = bool
      compression_enabled = bool
    })
    
    # Scheduling optimization
    scheduling = object({
      enable_auto_shutdown = bool
      shutdown_schedule = string
      startup_schedule = string
      weekend_shutdown = bool
    })
  })
  
  validation {
    condition = var.cost_optimization_config.monthly_budget_limit > 0
    error_message = "Monthly budget limit must be greater than 0."
  }
  
  validation {
    condition = var.cost_optimization_config.reserved_capacity_percentage >= 0 && var.cost_optimization_config.reserved_capacity_percentage <= 100
    error_message = "Reserved capacity percentage must be between 0 and 100."
  }
  
  validation {
    condition = var.cost_optimization_config.auto_scaling_policies.target_utilization >= 10 && var.cost_optimization_config.auto_scaling_policies.target_utilization <= 90
    error_message = "Target utilization must be between 10% and 90%."
  }
}

# Environment-specific cost optimization
locals {
  cost_optimized_config = {
    development = {
      instance_types = {
        web = var.cost_optimization_config.enable_spot_instances ? "t3.micro" : "t3.small"
        app = var.cost_optimization_config.enable_spot_instances ? "t3.small" : "t3.medium"
      }
      
      scaling_config = {
        min_capacity = 1
        max_capacity = var.cost_optimization_config.enable_spot_instances ? 2 : 3
        desired_capacity = 1
      }
      
      storage_config = {
        volume_type = "gp3"
        volume_size = 8
        iops = null
        throughput = null
      }
    }
    
    production = {
      instance_types = {
        web = var.cost_optimization_config.reserved_capacity_percentage > 50 ? "t3.large" : "t3.medium"
        app = var.cost_optimization_config.reserved_capacity_percentage > 50 ? "t3.xlarge" : "t3.large"
      }
      
      scaling_config = {
        min_capacity = var.cost_optimization_config.reserved_capacity_percentage > 50 ? 3 : 2
        max_capacity = 20
        desired_capacity = var.cost_optimization_config.reserved_capacity_percentage > 50 ? 5 : 3
      }
      
      storage_config = {
        volume_type = "gp3"
        volume_size = var.cost_optimization_config.reserved_capacity_percentage > 50 ? 50 : 30
        iops = 3000
        throughput = 125
      }
    }
  }
  
  # Current environment cost configuration
  current_cost_config = local.cost_optimized_config[var.environment]
}
```

---

---

## 🎯 **Advanced Use Cases and Integration Patterns**

### **1. Multi-Environment Variable Orchestration**
- Cross-environment variable inheritance and override patterns
- Centralized configuration management with AWS Parameter Store
- Dynamic environment provisioning with variable-driven templates
- Configuration drift detection and remediation

### **2. Module Integration and Output Chaining**
- Complex output structures for seamless module integration
- Data flow patterns between infrastructure layers
- Automated dependency resolution through output references
- Version-controlled configuration interfaces

### **3. Enterprise Security and Compliance**
- Sensitive data encryption and secure parameter management
- Compliance framework integration with variable validation
- Audit logging and configuration change tracking
- Role-based access control for variable management

---

**Topic Version**: 5.0
**Last Updated**: January 2025
**Terraform Version**: ~> 1.13.0
**AWS Provider Version**: ~> 6.12.0
**Compatibility**: Multi-platform (Linux, macOS, Windows WSL)
