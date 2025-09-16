# Test Your Understanding: Topic 5 - Variables and Outputs

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your mastery of advanced Terraform variable and output management concepts. The test covers enterprise-scale variable systems, sophisticated output patterns, local value optimization, variable precedence management, and governance frameworks.

### **Assessment Structure**
- **Total Questions**: 50 questions across 5 sections
- **Time Limit**: 90 minutes
- **Passing Score**: 85% (43/50 correct answers)
- **Question Types**: Multiple choice, scenario-based, hands-on coding, and enterprise case studies

### **Learning Objectives Assessed**
1. **Variable Type System Mastery** (20% - 10 questions)
2. **Output Value Management** (20% - 10 questions)
3. **Local Value Optimization** (20% - 10 questions)
4. **Variable Precedence Control** (20% - 10 questions)
5. **Enterprise Variable Governance** (20% - 10 questions)

---

## 📊 **Section 1: Variable Type System Mastery (20 points)**

### **Question 1** (2 points)
Which validation rule correctly ensures an environment variable only accepts "dev", "staging", or "prod"?

**A)**
```hcl
validation {
  condition = var.environment == "dev" || var.environment == "staging" || var.environment == "prod"
  error_message = "Environment must be dev, staging, or prod."
}
```

**B)**
```hcl
validation {
  condition = contains(["dev", "staging", "prod"], var.environment)
  error_message = "Environment must be dev, staging, or prod."
}
```

**C)**
```hcl
validation {
  condition = can(regex("^(dev|staging|prod)$", var.environment))
  error_message = "Environment must be dev, staging, or prod."
}
```

**D)** Both B and C are correct

**Correct Answer: D** - Both `contains()` and `regex()` approaches are valid for this validation.

### **Question 2** (2 points)
What is the correct way to define a complex object variable with nested validation?

**A)**
```hcl
variable "app_config" {
  type = object({
    name = string
    port = number
  })
  
  validation {
    condition = var.app_config.port >= 1024 && var.app_config.port <= 65535
    error_message = "Port must be between 1024 and 65535."
  }
}
```

**B)**
```hcl
variable "app_config" {
  type = map(object({
    name = string
    port = number
  }))
  
  validation {
    condition = alltrue([
      for app in var.app_config :
      app.port >= 1024 && app.port <= 65535
    ])
    error_message = "All ports must be between 1024 and 65535."
  }
}
```

**C)**
```hcl
variable "app_config" {
  type = object({
    name = string
    port = number
  })
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.app_config.name))
    error_message = "Name must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition = var.app_config.port >= 1024 && var.app_config.port <= 65535
    error_message = "Port must be between 1024 and 65535."
  }
}
```

**D)** All of the above are correct

**Correct Answer: D** - All examples show valid object variable definitions with appropriate validation patterns.

### **Question 3** (2 points)
Which CIDR validation pattern is most comprehensive for a VPC CIDR block?

**A)**
```hcl
validation {
  condition = can(cidrhost(var.vpc_cidr, 0))
  error_message = "Must be a valid CIDR block."
}
```

**B)**
```hcl
validation {
  condition = can(cidrhost(var.vpc_cidr, 0)) && 
              tonumber(split("/", var.vpc_cidr)[1]) >= 16 && 
              tonumber(split("/", var.vpc_cidr)[1]) <= 24
  error_message = "Must be a valid CIDR block with prefix between /16 and /24."
}
```

**C)**
```hcl
validation {
  condition = can(regex("^10\\.|^172\\.(1[6-9]|2[0-9]|3[01])\\.|^192\\.168\\.", var.vpc_cidr))
  error_message = "Must be a private IP range."
}
```

**D)** Both B and C combined

**Correct Answer: D** - The most comprehensive validation includes both CIDR format validation and private IP range checking.

### **Question 4** (2 points)
What is the correct way to validate email addresses in a list variable?

**A)**
```hcl
validation {
  condition = alltrue([
    for email in var.email_list :
    can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
  ])
  error_message = "All emails must be valid email addresses."
}
```

**B)**
```hcl
validation {
  condition = length(var.email_list) > 0
  error_message = "At least one email must be provided."
}
```

**C)**
```hcl
validation {
  condition = alltrue([
    for email in var.email_list :
    length(email) <= 254
  ])
  error_message = "Email addresses must not exceed 254 characters."
}
```

**D)** All of the above should be used together

**Correct Answer: D** - Comprehensive email validation includes format, presence, and length checks.

### **Question 5** (2 points)
Which approach correctly implements conditional validation based on environment?

**A)**
```hcl
validation {
  condition = var.environment == "prod" ? var.backup_retention >= 30 : var.backup_retention >= 1
  error_message = "Production requires 30+ day retention, others require 1+ day."
}
```

**B)**
```hcl
validation {
  condition = var.environment != "prod" || var.backup_retention >= 30
  error_message = "Production environments require backup retention of at least 30 days."
}
```

**C)**
```hcl
validation {
  condition = contains(["dev", "staging"], var.environment) ? true : var.backup_retention >= 30
  error_message = "Production environments require backup retention of at least 30 days."
}
```

**D)** All approaches are equivalent and correct

**Correct Answer: D** - All three approaches correctly implement conditional validation logic.

---

## 📤 **Section 2: Output Value Management (20 points)**

### **Question 6** (2 points)
What is the best practice for outputting sensitive database connection information?

**A)**
```hcl
output "database_connection" {
  value = {
    endpoint = aws_db_instance.main.endpoint
    username = aws_db_instance.main.username
    password = aws_db_instance.main.password
  }
}
```

**B)**
```hcl
output "database_connection" {
  value = {
    endpoint = aws_db_instance.main.endpoint
    username = aws_db_instance.main.username
    password = aws_db_instance.main.password
  }
  sensitive = true
}
```

**C)**
```hcl
output "database_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "database_username" {
  value = aws_db_instance.main.username
}

# Password should be retrieved from AWS Secrets Manager
```

**D)** Both B and C are acceptable approaches

**Correct Answer: D** - Both marking outputs as sensitive and separating sensitive data are valid approaches.

### **Question 7** (2 points)
Which output pattern best supports module composition and reusability?

**A)**
```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.main[*].id
}
```

**B)**
```hcl
output "network_config" {
  value = {
    vpc_id = aws_vpc.main.id
    subnet_ids = aws_subnet.main[*].id
    security_group_ids = aws_security_group.main[*].id
  }
}
```

**C)**
```hcl
output "network_config" {
  value = {
    vpc = {
      id = aws_vpc.main.id
      arn = aws_vpc.main.arn
      cidr_block = aws_vpc.main.cidr_block
    }
    subnets = {
      for subnet in aws_subnet.main :
      subnet.tags.Name => {
        id = subnet.id
        cidr_block = subnet.cidr_block
        availability_zone = subnet.availability_zone
      }
    }
    security_groups = {
      for sg in aws_security_group.main :
      sg.tags.Name => sg.id
    }
  }
}
```

**D)** C provides the most comprehensive and reusable output structure

**Correct Answer: D** - Structured, hierarchical outputs with detailed information support better module composition.

### **Question 8** (2 points)
How should you handle conditional outputs based on feature flags?

**A)**
```hcl
output "nat_gateway_ips" {
  value = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : null
}
```

**B)**
```hcl
output "nat_gateway_ips" {
  value = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}
```

**C)**
```hcl
output "nat_gateway_ips" {
  value = try(aws_eip.nat[*].public_ip, [])
}
```

**D)** Both B and C are good approaches

**Correct Answer: D** - Both empty list and try() function provide safe handling of conditional resources.

### **Question 9** (2 points)
What is the correct way to output computed values with complex transformations?

**A)**
```hcl
output "application_urls" {
  value = {
    for app_name, app_config in var.applications :
    app_name => "https://${aws_lb.main.dns_name}${app_config.path}"
  }
}
```

**B)**
```hcl
output "application_urls" {
  value = [
    for app_name, app_config in var.applications :
    {
      name = app_name
      url = "https://${aws_lb.main.dns_name}${app_config.path}"
      health_check = "https://${aws_lb.main.dns_name}${app_config.health_check_path}"
    }
  ]
}
```

**C)**
```hcl
output "application_urls" {
  value = {
    for app_name, app_config in var.applications :
    app_name => {
      base_url = "https://${aws_lb.main.dns_name}"
      app_url = "https://${aws_lb.main.dns_name}${app_config.path}"
      health_check_url = "https://${aws_lb.main.dns_name}${app_config.health_check_path}"
      internal_url = "http://${aws_lb.main.dns_name}${app_config.path}"
    }
  }
}
```

**D)** C provides the most comprehensive URL information

**Correct Answer: D** - Comprehensive output with multiple URL variants provides maximum utility for consumers.

### **Question 10** (2 points)
Which approach correctly implements cross-module data passing?

**A)**
```hcl
# Module A outputs
output "network_info" {
  value = {
    vpc_id = aws_vpc.main.id
    subnet_ids = aws_subnet.main[*].id
  }
}

# Module B usage
module "network" {
  source = "./modules/network"
}

resource "aws_instance" "app" {
  subnet_id = module.network.network_info.subnet_ids[0]
  vpc_security_group_ids = [module.network.network_info.security_group_id]
}
```

**B)**
```hcl
# Module A outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.main[*].id
}

# Module B usage
module "network" {
  source = "./modules/network"
}

resource "aws_instance" "app" {
  subnet_id = module.network.subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.app.id]
}
```

**C)**
```hcl
# Using data sources for cross-module communication
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.network.outputs.subnet_ids[0]
}
```

**D)** All approaches are valid for different scenarios

**Correct Answer: D** - Module outputs, individual outputs, and remote state are all valid cross-module communication patterns.

---

## 🏗️ **Section 3: Local Value Optimization (20 points)**

### **Question 11** (2 points)
Which local value pattern provides the best performance for complex computations?

**A)**
```hcl
locals {
  instance_configs = {
    for app_name, app_config in var.applications :
    app_name => merge(app_config, {
      full_name = "${var.environment}-${app_name}"
      tags = merge(var.common_tags, app_config.tags)
    })
  }
}
```

**B)**
```hcl
locals {
  # Pre-compute common values
  name_prefix = "${var.environment}-${var.project}"
  
  instance_configs = {
    for app_name, app_config in var.applications :
    app_name => merge(app_config, {
      full_name = "${local.name_prefix}-${app_name}"
      tags = merge(local.common_tags, app_config.tags)
    })
  }
  
  common_tags = merge(var.base_tags, {
    Environment = var.environment
    Project = var.project
  })
}
```

**C)**
```hcl
locals {
  instance_configs = [
    for app_name, app_config in var.applications : {
      name = app_name
      config = merge(app_config, {
        full_name = "${var.environment}-${app_name}"
        tags = merge(var.common_tags, app_config.tags)
      })
    }
  ]
}
```

**D)** B provides the best performance through value reuse

**Correct Answer: D** - Pre-computing common values and reusing them provides better performance and maintainability.

### **Question 12** (2 points)
What is the most efficient way to handle conditional logic in local values?

**A)**
```hcl
locals {
  database_config = var.environment == "prod" ? {
    instance_class = "db.r5.xlarge"
    multi_az = true
    backup_retention = 30
  } : var.environment == "staging" ? {
    instance_class = "db.t3.medium"
    multi_az = false
    backup_retention = 7
  } : {
    instance_class = "db.t3.micro"
    multi_az = false
    backup_retention = 1
  }
}
```

**B)**
```hcl
locals {
  environment_configs = {
    prod = {
      instance_class = "db.r5.xlarge"
      multi_az = true
      backup_retention = 30
    }
    staging = {
      instance_class = "db.t3.medium"
      multi_az = false
      backup_retention = 7
    }
    dev = {
      instance_class = "db.t3.micro"
      multi_az = false
      backup_retention = 1
    }
  }
  
  database_config = local.environment_configs[var.environment]
}
```

**C)**
```hcl
locals {
  database_config = merge(
    var.base_database_config,
    lookup({
      prod = {
        instance_class = "db.r5.xlarge"
        multi_az = true
        backup_retention = 30
      }
      staging = {
        instance_class = "db.t3.medium"
        multi_az = false
        backup_retention = 7
      }
    }, var.environment, {
      instance_class = "db.t3.micro"
      multi_az = false
      backup_retention = 1
    })
  )
}
```

**D)** B provides the cleanest and most maintainable approach

**Correct Answer: D** - Using a lookup map is cleaner and more maintainable than nested ternary operators.

### **Question 13** (2 points)
Which pattern correctly implements complex data transformations in local values?

**A)**
```hcl
locals {
  subnet_configs = [
    for i, az in data.aws_availability_zones.available.names : {
      name = "subnet-${i+1}"
      cidr_block = cidrsubnet(var.vpc_cidr, 8, i)
      availability_zone = az
      type = i < 2 ? "public" : "private"
    }
  ]
}
```

**B)**
```hcl
locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  
  public_subnets = [
    for i, az in local.availability_zones : {
      name = "public-subnet-${i+1}"
      cidr_block = cidrsubnet(var.vpc_cidr, 8, i)
      availability_zone = az
    }
  ]
  
  private_subnets = [
    for i, az in local.availability_zones : {
      name = "private-subnet-${i+1}"
      cidr_block = cidrsubnet(var.vpc_cidr, 8, i + 10)
      availability_zone = az
    }
  ]
}
```

**C)**
```hcl
locals {
  subnet_matrix = {
    for subnet_type in ["public", "private", "database"] :
    subnet_type => [
      for i, az in slice(data.aws_availability_zones.available.names, 0, 3) : {
        name = "${subnet_type}-subnet-${i+1}"
        cidr_block = cidrsubnet(var.vpc_cidr, 8, 
          subnet_type == "public" ? i :
          subnet_type == "private" ? i + 10 : i + 20
        )
        availability_zone = az
        type = subnet_type
      }
    ]
  }
}
```

**D)** C provides the most flexible and scalable approach

**Correct Answer: D** - The matrix approach provides maximum flexibility for different subnet types and scales well.

### **Question 14** (2 points)
How should you optimize local values for large-scale deployments?

**A)** Use as many local values as possible to break down complexity
**B)** Minimize local values to reduce computation overhead
**C)** Use local values strategically for reused computations and complex transformations
**D)** Always prefer variables over local values

**Correct Answer: C** - Strategic use of local values for reused computations provides the best balance of performance and maintainability.

### **Question 15** (2 points)
Which approach correctly handles error-prone computations in local values?

**A)**
```hcl
locals {
  parsed_config = jsondecode(var.config_json)
}
```

**B)**
```hcl
locals {
  parsed_config = try(jsondecode(var.config_json), {})
}
```

**C)**
```hcl
locals {
  parsed_config = can(jsondecode(var.config_json)) ? jsondecode(var.config_json) : {}
}
```

**D)** Both B and C provide safe error handling

**Correct Answer: D** - Both `try()` and `can()` functions provide safe error handling for potentially failing operations.

---

## 📊 **Section 4: Variable Precedence Control (20 points)**

### **Question 16** (2 points)
What is the correct order of variable precedence from highest to lowest?

**A)** Environment variables → Command line → terraform.tfvars → Variable defaults
**B)** Command line → Environment variables → terraform.tfvars → Variable defaults
**C)** terraform.tfvars → Command line → Environment variables → Variable defaults
**D)** Variable defaults → terraform.tfvars → Environment variables → Command line

**Correct Answer: B** - Command line has highest precedence, followed by environment variables, then terraform.tfvars, then defaults.

### **Question 17** (2 points)
Which command correctly demonstrates variable precedence testing?

**A)**
```bash
export TF_VAR_instance_type="t3.small"
terraform plan -var="instance_type=t3.large"
# Result: t3.large (command line overrides environment)
```

**B)**
```bash
echo 'instance_type = "t3.medium"' > terraform.tfvars
export TF_VAR_instance_type="t3.small"
terraform plan
# Result: t3.small (environment overrides tfvars)
```

**C)**
```bash
terraform plan -var="instance_type=t3.large" -var-file="custom.tfvars"
# Result: Values from custom.tfvars override -var flags
```

**D)** Both A and B demonstrate correct precedence

**Correct Answer: D** - Both examples correctly show command line overriding environment variables and environment variables overriding tfvars files.

### **Question 18** (2 points)
How should you structure variable files for multi-environment deployments?

**A)**
```
environments/
├── dev.tfvars
├── staging.tfvars
└── prod.tfvars
```

**B)**
```
environments/
├── global.auto.tfvars
├── dev/
│   ├── terraform.tfvars
│   └── secrets.auto.tfvars
├── staging/
│   ├── terraform.tfvars
│   └── secrets.auto.tfvars
└── prod/
    ├── terraform.tfvars
    └── secrets.auto.tfvars
```

**C)**
```
├── terraform.tfvars
├── dev.auto.tfvars
├── staging.auto.tfvars
└── prod.auto.tfvars
```

**D)** B provides the best organization for complex environments

**Correct Answer: D** - Hierarchical organization with global and environment-specific files provides the best structure for complex deployments.

### **Question 19** (2 points)
Which approach correctly implements configuration inheritance?

**A)**
```hcl
# global.auto.tfvars
common_tags = {
  Project = "enterprise-app"
  ManagedBy = "terraform"
}

# prod.auto.tfvars
environment = "prod"
instance_type = "t3.large"
```

**B)**
```hcl
# base.tfvars
base_config = {
  project = "enterprise-app"
  managed_by = "terraform"
}

# prod.tfvars
environment = "prod"
config = merge(var.base_config, {
  instance_type = "t3.large"
  monitoring = true
})
```

**C)**
```hcl
# locals.tf
locals {
  base_config = {
    project = var.project_name
    managed_by = "terraform"
  }
  
  environment_config = merge(local.base_config, var.environment_overrides)
}
```

**D)** C provides the most flexible inheritance pattern

**Correct Answer: D** - Using locals for inheritance provides the most flexibility and maintainability.

### **Question 20** (2 points)
What is the best practice for handling sensitive variables in different environments?

**A)** Store all sensitive values in terraform.tfvars files
**B)** Use environment variables for all sensitive data
**C)** Use AWS Systems Manager Parameter Store or Secrets Manager with data sources
**D)** Encrypt tfvars files with GPG

**Correct Answer: C** - Using AWS managed services for sensitive data provides the best security and auditability.

---

## 🏢 **Section 5: Enterprise Variable Governance (20 points)**

### **Question 21** (2 points)
Which naming convention best supports enterprise-scale variable management?

**A)** `var.env_prod_db_config`
**B)** `var.database_configuration_production_environment`
**C)** `var.org_enterprise_env_prod_database_config`
**D)** `var.prod_db_cfg`

**Correct Answer: C** - Hierarchical naming with organization, scope, environment, and component provides the best enterprise structure.

### **Question 22** (2 points)
How should you implement variable validation for compliance requirements?

**A)**
```hcl
validation {
  condition = var.data_classification == "confidential" ? var.encryption_enabled == true : true
  error_message = "Confidential data must be encrypted."
}
```

**B)**
```hcl
validation {
  condition = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
  error_message = "Data classification must be from approved list."
}

validation {
  condition = var.data_classification != "confidential" || var.encryption_enabled
  error_message = "Confidential data requires encryption."
}
```

**C)**
```hcl
validation {
  condition = alltrue([
    contains(["public", "internal", "confidential", "restricted"], var.data_classification),
    var.data_classification != "confidential" || var.encryption_enabled,
    var.data_classification != "restricted" || var.audit_logging_enabled
  ])
  error_message = "Data classification and security requirements must be met."
}
```

**D)** B provides the clearest and most maintainable validation

**Correct Answer: D** - Separate validation rules are clearer and provide better error messages than complex combined conditions.

### **Question 23** (2 points)
What is the best approach for implementing variable governance workflows?

**A)** Manual review of all variable changes
**B)** Automated validation with policy-as-code tools like OPA/Sentinel
**C)** Git hooks for variable validation
**D)** All of the above combined

**Correct Answer: D** - Comprehensive governance requires multiple layers including automated validation, policy enforcement, and human review.

### **Question 24** (2 points)
How should you document complex variable structures for enterprise use?

**A)**
```hcl
variable "app_config" {
  description = "Application configuration"
  type = object({...})
}
```

**B)**
```hcl
variable "app_config" {
  description = <<-EOT
    Comprehensive application configuration for enterprise deployment.
    
    This variable defines the complete configuration for application deployment
    including compute resources, networking, security, monitoring, and compliance
    requirements.
    
    Usage Examples:
    - Development: Minimal configuration with relaxed security
    - Production: Full configuration with all security features
    
    Dependencies:
    - Requires VPC and subnet configuration
    - Integrates with monitoring infrastructure
  EOT
  type = object({...})
}
```

**C)**
```hcl
# See documentation at: https://docs.company.com/terraform/variables
variable "app_config" {
  type = object({...})
}
```

**D)** B provides the most comprehensive inline documentation

**Correct Answer: D** - Comprehensive inline documentation with usage examples and dependencies provides the best developer experience.

### **Question 25** (2 points)
Which approach correctly implements variable change tracking and auditing?

**A)** Git commit messages for all variable changes
**B)** Terraform Cloud/Enterprise with policy enforcement and audit logs
**C)** Custom scripts to track variable modifications
**D)** All approaches combined for comprehensive auditing

**Correct Answer: D** - Comprehensive auditing requires multiple approaches including version control, platform audit logs, and custom tracking.

---

## 📊 **Assessment Results and Scoring**

### **Scoring Rubric**
- **90-100% (45-50 correct)**: **Expert Level** - Ready for enterprise-scale variable management and governance
- **85-89% (43-44 correct)**: **Advanced Level** - Strong understanding with minor knowledge gaps
- **75-84% (38-42 correct)**: **Intermediate Level** - Good foundation, requires additional study
- **65-74% (33-37 correct)**: **Beginner Level** - Basic understanding, significant study needed
- **Below 65% (<33 correct)**: **Needs Review** - Fundamental concepts require reinforcement

### **Answer Key Summary**
1. D  2. D  3. D  4. D  5. D
6. D  7. D  8. D  9. D  10. D
11. D  12. D  13. D  14. C  15. D
16. B  17. D  18. D  19. D  20. C
21. C  22. D  23. D  24. D  25. D

### **Knowledge Gap Analysis**
If you scored below 85%, focus additional study on these areas:
- **Variable Type System**: Review complex object validation patterns
- **Output Management**: Practice advanced output structuring and data flow
- **Local Values**: Master performance optimization techniques
- **Variable Precedence**: Understand enterprise configuration strategies
- **Governance**: Study compliance and audit requirements

### **Next Steps**
- **Expert Level**: Proceed to Topic 6 - State Management & Backends
- **Advanced Level**: Review missed concepts, then proceed to Topic 6
- **Intermediate/Beginner**: Complete additional hands-on exercises before advancing
- **Needs Review**: Revisit Topic 5 materials and complete all lab exercises

---

*This assessment validates your readiness for enterprise-scale Terraform variable and output management. Strong performance indicates mastery of advanced concepts needed for complex infrastructure deployments.*
