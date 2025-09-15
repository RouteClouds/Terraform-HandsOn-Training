# AWS Terraform Training - Variables and Outputs Assessment

## 🎯 **Topic 5: Advanced Variable Management and Output Patterns**

### **Test Your Understanding - Comprehensive Assessment**

**Duration**: 45 minutes  
**Total Points**: 100 points  
**Passing Score**: 80 points  

---

## 📝 **Part A: Multiple Choice Questions (40 points)**

### **Question 1** (4 points)
Which variable type is most appropriate for defining a complex infrastructure configuration with nested objects?

A) `string`  
B) `list(string)`  
C) `map(string)`  
D) `object({})`  

**Answer**: D) `object({})` - Object types allow for complex nested structures with different data types.

### **Question 2** (4 points)
What is the primary purpose of variable validation blocks in Terraform?

A) To set default values  
B) To prevent invalid configurations at plan time  
C) To encrypt sensitive variables  
D) To improve performance  

**Answer**: B) To prevent invalid configurations at plan time - Validation blocks catch errors early.

### **Question 3** (4 points)
Which meta-attribute should be used to mark variables containing passwords or API keys?

A) `encrypted = true`  
B) `private = true`  
C) `sensitive = true`  
D) `secure = true`  

**Answer**: C) `sensitive = true` - This prevents values from being displayed in logs and output.

### **Question 4** (4 points)
What is the best practice for handling database passwords in Terraform?

A) Store them in terraform.tfvars  
B) Use AWS Secrets Manager with random password generation  
C) Hard-code them in variables.tf  
D) Pass them as environment variables  

**Answer**: B) Use AWS Secrets Manager with random password generation - Most secure approach.

### **Question 5** (4 points)
Which output configuration enables module chaining and automation integration?

A) Simple string outputs  
B) Structured object outputs with nested data  
C) Sensitive outputs only  
D) List outputs only  

**Answer**: B) Structured object outputs with nested data - Provides comprehensive information for downstream consumption.

### **Question 6** (4 points)
How should environment-specific configurations be managed in Terraform?

A) Separate files for each environment  
B) Variable maps with environment-specific overrides  
C) Hard-coded values per environment  
D) Environment variables only  

**Answer**: B) Variable maps with environment-specific overrides - Enables code reuse with environment flexibility.

### **Question 7** (4 points)
What is the purpose of local values in Terraform?

A) To store sensitive data  
B) To compute derived values from variables  
C) To define resource dependencies  
D) To configure providers  

**Answer**: B) To compute derived values from variables - Locals process and transform variable data.

### **Question 8** (4 points)
Which AWS service is best for storing non-sensitive configuration parameters?

A) AWS Secrets Manager  
B) AWS Systems Manager Parameter Store  
C) AWS S3  
D) AWS DynamoDB  

**Answer**: B) AWS Systems Manager Parameter Store - Designed for configuration management.

### **Question 9** (4 points)
What is the recommended approach for variable validation with complex business rules?

A) Single validation block with all rules  
B) Multiple validation blocks with specific error messages  
C) No validation (rely on AWS validation)  
D) External validation scripts  

**Answer**: B) Multiple validation blocks with specific error messages - Provides clear, actionable feedback.

### **Question 10** (4 points)
How should outputs be structured for maximum reusability across modules?

A) Flat structure with simple values  
B) Hierarchical structure grouped by service/function  
C) Single output with all information  
D) Separate outputs for each resource  

**Answer**: B) Hierarchical structure grouped by service/function - Organized and easy to consume.

---

## 🛠️ **Part B: Scenario-Based Questions (30 points)**

### **Scenario 1: Multi-Environment Variable Management** (10 points)

You need to design a variable structure that supports three environments (dev, staging, prod) with different instance types, scaling configurations, and security settings.

**Question**: Design a variable structure that allows:
- Environment-specific instance types
- Different scaling parameters per environment
- Security configurations that vary by environment
- Cost optimization settings per environment

**Sample Answer**:
```hcl
variable "environment_configs" {
  type = map(object({
    instance_types = object({
      web = string
      app = string
    })
    scaling_config = object({
      min_capacity = number
      max_capacity = number
    })
    security_config = object({
      enable_waf = bool
      ssl_policy = string
    })
    cost_config = object({
      enable_spot_instances = bool
      budget_limit = number
    })
  }))
  
  default = {
    development = {
      instance_types = { web = "t3.micro", app = "t3.small" }
      scaling_config = { min_capacity = 1, max_capacity = 2 }
      security_config = { enable_waf = false, ssl_policy = "basic" }
      cost_config = { enable_spot_instances = true, budget_limit = 100 }
    }
    # ... other environments
  }
}
```

### **Scenario 2: Sensitive Data Management** (10 points)

Your application requires database credentials, API keys for external services, and SSL certificates. Design a secure approach using AWS services.

**Question**: How would you securely manage and reference these sensitive values in Terraform?

**Sample Answer**:
```hcl
# Store in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project}-${var.environment}/database/credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })
}

# Reference in RDS
resource "aws_db_instance" "main" {
  username = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  # ... other configuration
}
```

### **Scenario 3: Output Chaining for Module Integration** (10 points)

Design outputs that enable seamless integration between a networking module and a compute module.

**Question**: Create outputs from a networking module that a compute module can consume effectively.

**Sample Answer**:
```hcl
output "networking_config" {
  value = {
    vpc_id = aws_vpc.main.id
    subnet_config = {
      public_subnet_ids = aws_subnet.public[*].id
      private_subnet_ids = aws_subnet.private[*].id
    }
    security_groups = {
      web_sg_id = aws_security_group.web.id
      app_sg_id = aws_security_group.app.id
    }
    network_metadata = {
      vpc_cidr = aws_vpc.main.cidr_block
      availability_zones = data.aws_availability_zones.available.names
    }
  }
}
```

---

## 🔧 **Part C: Hands-On Exercises (30 points)**

### **Exercise 1: Variable Validation Implementation** (10 points)

Create a variable with comprehensive validation for an AWS RDS configuration.

**Requirements**:
- Engine must be mysql, postgres, or mariadb
- Instance class must be valid RDS instance type
- Allocated storage between 20-1000 GB
- Backup retention between 1-35 days
- Custom error messages for each validation

**Solution Template**:
```hcl
variable "rds_config" {
  description = "RDS instance configuration"
  type = object({
    engine = string
    instance_class = string
    allocated_storage = number
    backup_retention = number
  })
  
  validation {
    condition = contains(["mysql", "postgres", "mariadb"], var.rds_config.engine)
    error_message = "Engine must be mysql, postgres, or mariadb."
  }
  
  validation {
    condition = can(regex("^db\\.", var.rds_config.instance_class))
    error_message = "Instance class must be a valid RDS instance type (starts with 'db.')."
  }
  
  validation {
    condition = var.rds_config.allocated_storage >= 20 && var.rds_config.allocated_storage <= 1000
    error_message = "Allocated storage must be between 20 and 1000 GB."
  }
  
  validation {
    condition = var.rds_config.backup_retention >= 1 && var.rds_config.backup_retention <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }
}
```

### **Exercise 2: Dynamic Configuration with Locals** (10 points)

Create local values that compute environment-specific configurations based on input variables.

**Requirements**:
- Compute instance types based on environment and cost optimization flags
- Calculate scaling parameters based on environment tier
- Determine security settings based on compliance requirements
- Generate appropriate tags for resources

**Solution Template**:
```hcl
locals {
  # Environment-specific instance types
  instance_types = {
    web = var.cost_optimization.enable_spot ? "t3.small" : var.environment_configs[var.environment].instance_types.web
    app = var.cost_optimization.enable_spot ? "t3.medium" : var.environment_configs[var.environment].instance_types.app
  }
  
  # Computed scaling configuration
  scaling_config = {
    web_min = var.environment == "production" ? 3 : 1
    web_max = var.environment == "production" ? 20 : 5
    app_min = var.environment == "production" ? 2 : 1
    app_max = var.environment == "production" ? 15 : 3
  }
  
  # Security configuration based on compliance
  security_config = {
    encryption_required = var.compliance_framework != ""
    waf_enabled = var.environment == "production" || var.compliance_framework != ""
    ssl_policy = var.environment == "production" ? "ELBSecurityPolicy-FS-1-2-Res-2019-08" : "ELBSecurityPolicy-TLS-1-2-2017-01"
  }
  
  # Computed tags
  computed_tags = merge(var.default_tags, {
    Environment = var.environment
    CostOptimized = var.cost_optimization.enable_spot ? "true" : "false"
    ComplianceRequired = var.compliance_framework != "" ? "true" : "false"
    SecurityLevel = local.security_config.encryption_required ? "high" : "standard"
  })
}
```

### **Exercise 3: Comprehensive Output Design** (10 points)

Design outputs that support module chaining, automation integration, and operational visibility.

**Requirements**:
- Infrastructure endpoints for module chaining
- Security configuration for compliance reporting
- Cost information for budget tracking
- Monitoring configuration for observability setup

**Solution Template**:
```hcl
output "infrastructure_endpoints" {
  description = "Infrastructure endpoints for module chaining"
  value = {
    networking = {
      vpc_id = aws_vpc.main.id
      subnet_ids = {
        public = aws_subnet.public[*].id
        private = aws_subnet.private[*].id
      }
      security_group_ids = {
        web = aws_security_group.web.id
        app = aws_security_group.app.id
      }
    }
    storage = {
      s3_bucket_arns = { for k, v in aws_s3_bucket.main : k => v.arn }
    }
  }
}

output "security_configuration" {
  description = "Security configuration for compliance"
  value = {
    encryption_status = {
      ebs_encrypted = local.security_config.encryption_required
      s3_encrypted = true
      rds_encrypted = local.security_config.encryption_required
    }
    compliance_framework = var.compliance_framework
    waf_enabled = local.security_config.waf_enabled
  }
}

output "cost_information" {
  description = "Cost tracking and optimization data"
  value = {
    estimated_monthly_cost = local.estimated_monthly_cost
    cost_optimization = {
      spot_instances_enabled = var.cost_optimization.enable_spot
      reserved_capacity = var.cost_optimization.reserved_capacity
    }
    budget_configuration = {
      monthly_limit = var.cost_optimization.budget_limit
      alert_thresholds = [50, 80, 100]
    }
  }
}
```

---

## 📊 **Assessment Scoring Guide**

### **Part A: Multiple Choice (40 points)**
- Each question: 4 points
- Total: 10 questions × 4 points = 40 points

### **Part B: Scenarios (30 points)**
- Scenario 1: 10 points (Variable structure design and implementation)
- Scenario 2: 10 points (Sensitive data management approach)
- Scenario 3: 10 points (Output design for module integration)

### **Part C: Hands-On (30 points)**
- Exercise 1: 10 points (Variable validation implementation)
- Exercise 2: 10 points (Dynamic configuration with locals)
- Exercise 3: 10 points (Comprehensive output design)

### **Grading Criteria**
- **90-100 points**: Excellent - Demonstrates mastery of advanced variable and output patterns
- **80-89 points**: Good - Shows solid understanding with minor gaps
- **70-79 points**: Satisfactory - Basic understanding but needs improvement
- **Below 70 points**: Needs Review - Requires additional study and practice

---

## 🎯 **Key Learning Outcomes Assessed**

1. **Complex Variable Design** - Ability to create sophisticated variable structures
2. **Validation Implementation** - Skill in preventing configuration errors
3. **Sensitive Data Management** - Knowledge of secure credential handling
4. **Output Patterns** - Understanding of module integration and automation
5. **Dynamic Configuration** - Ability to create flexible, environment-aware configurations
6. **AWS Integration** - Knowledge of AWS services for configuration management
7. **Best Practices** - Application of enterprise-grade patterns and standards

---

**Assessment Version**: 5.0  
**Last Updated**: January 2025  
**Next Topic**: State Management with AWS (Topic 6)
