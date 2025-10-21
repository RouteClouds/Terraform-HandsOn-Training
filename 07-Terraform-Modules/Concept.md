# Topic 7: Terraform Modules

## 🎯 **Learning Objectives**

By completing this comprehensive topic, you will master advanced Terraform module development concepts and enterprise-scale module architectures. This topic builds upon the foundation established in Topics 1-6, providing the critical knowledge needed for creating reusable, maintainable, and scalable infrastructure components.

### **Primary Learning Outcomes**
1. **Module Architecture Mastery** - Design and implement sophisticated module architectures for enterprise environments
2. **Composition Expertise** - Create complex module composition patterns and dependency management strategies
3. **Versioning and Lifecycle** - Implement comprehensive versioning strategies and lifecycle management workflows
4. **Testing and Validation** - Establish robust testing frameworks and quality assurance processes
5. **Enterprise Governance** - Design enterprise-grade governance frameworks with module registries and policies
6. **Advanced Patterns** - Apply advanced module patterns including factories, proxies, and dynamic composition

### **Advanced Competencies Developed**
- **Strategic Module Design**: Architecture patterns for scalable and maintainable infrastructure
- **Dependency Management**: Complex dependency resolution and composition strategies
- **Quality Engineering**: Comprehensive testing, validation, and quality assurance frameworks
- **Enterprise Integration**: Module governance, registries, and organizational policies
- **Performance Optimization**: Module efficiency, reusability, and operational excellence

---

## 📊 **Module Fundamentals and Architecture Patterns**

### **Understanding Terraform Modules**

Terraform modules are the fundamental building blocks for creating reusable infrastructure components. They enable teams to encapsulate complex infrastructure patterns into manageable, testable, and shareable units that promote consistency and reduce duplication across environments.

![Figure 7.1: Module Architecture and Design Patterns](DaC/generated_diagrams/figure_7_1_module_architecture_patterns.png)
*Figure 7.1: Comprehensive module architecture patterns, design principles, and enterprise structural organization*

#### **Module Design Principles**

```hcl
# Single Responsibility Principle - Each module should have one clear purpose
# Example: VPC Module focused solely on network infrastructure
module "vpc" {
  source = "./modules/vpc"
  
  # Clear, focused inputs
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  # Environment-specific configuration
  environment = var.environment
  project     = var.project
  
  # Consistent tagging strategy
  tags = merge(var.common_tags, {
    Module = "vpc"
    Layer  = "foundation"
  })
}

# Reusability - Parameterized for different environments and use cases
variable "vpc_configuration" {
  description = "VPC configuration parameters"
  type = object({
    cidr_block           = string
    availability_zones   = list(string)
    enable_dns_hostnames = bool
    enable_dns_support   = bool
    
    # Subnet configuration
    public_subnet_cidrs  = list(string)
    private_subnet_cidrs = list(string)
    database_subnet_cidrs = list(string)
    
    # NAT Gateway configuration
    enable_nat_gateway     = bool
    single_nat_gateway     = bool
    one_nat_gateway_per_az = bool
    
    # VPC Endpoints
    enable_s3_endpoint       = bool
    enable_dynamodb_endpoint = bool
    enable_ec2_endpoint      = bool
  })
  
  validation {
    condition = can(cidrhost(var.vpc_configuration.cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
  
  validation {
    condition = length(var.vpc_configuration.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for high availability."
  }
  
  validation {
    condition = length(var.vpc_configuration.public_subnet_cidrs) == length(var.vpc_configuration.availability_zones)
    error_message = "Number of public subnet CIDRs must match number of availability zones."
  }
}

# Composability - Designed to work with other modules
output "vpc_configuration" {
  description = "VPC configuration for consumption by other modules"
  value = {
    # Core VPC information
    vpc_id         = aws_vpc.main.id
    vpc_cidr_block = aws_vpc.main.cidr_block
    vpc_arn        = aws_vpc.main.arn
    
    # Subnet information organized by tier
    subnets = {
      public = {
        ids               = aws_subnet.public[*].id
        cidrs             = aws_subnet.public[*].cidr_block
        availability_zones = aws_subnet.public[*].availability_zone
        route_table_ids   = aws_route_table.public[*].id
      }
      private = {
        ids               = aws_subnet.private[*].id
        cidrs             = aws_subnet.private[*].cidr_block
        availability_zones = aws_subnet.private[*].availability_zone
        route_table_ids   = aws_route_table.private[*].id
      }
      database = {
        ids               = aws_subnet.database[*].id
        cidrs             = aws_subnet.database[*].cidr_block
        availability_zones = aws_subnet.database[*].availability_zone
        route_table_ids   = aws_route_table.database[*].id
        subnet_group_name = aws_db_subnet_group.database.name
      }
    }
    
    # Gateway and routing information
    gateways = {
      internet_gateway_id = aws_internet_gateway.main.id
      nat_gateway_ids     = aws_nat_gateway.main[*].id
      nat_gateway_ips     = aws_eip.nat[*].public_ip
    }
    
    # Security group defaults
    default_security_groups = {
      vpc_default_sg_id = aws_vpc.main.default_security_group_id
      web_sg_id         = aws_security_group.web_default.id
      app_sg_id         = aws_security_group.app_default.id
      db_sg_id          = aws_security_group.db_default.id
    }
    
    # VPC Endpoints
    vpc_endpoints = {
      s3_endpoint       = try(aws_vpc_endpoint.s3[0].id, null)
      dynamodb_endpoint = try(aws_vpc_endpoint.dynamodb[0].id, null)
      ec2_endpoint      = try(aws_vpc_endpoint.ec2[0].id, null)
    }
    
    # DNS and service discovery
    dns_configuration = {
      private_zone_id   = aws_route53_zone.private.zone_id
      private_zone_name = aws_route53_zone.private.name
      resolver_endpoints = aws_route53_resolver_endpoint.main[*].id
    }
  }
  
  # Mark sensitive if contains internal network details
  sensitive = var.expose_internal_details ? false : true
}
```

#### **Module Structure Standards**

```bash
# Standard module directory structure
modules/
├── vpc/                           # Module name (descriptive and clear)
│   ├── main.tf                   # Primary resource definitions
│   ├── variables.tf              # Input variable definitions
│   ├── outputs.tf                # Output value definitions
│   ├── versions.tf               # Provider version constraints
│   ├── locals.tf                 # Local value computations
│   ├── data.tf                   # Data source definitions
│   ├── README.md                 # Module documentation
│   ├── examples/                 # Usage examples
│   │   ├── basic/                # Basic usage example
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── advanced/             # Advanced usage example
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── complete/             # Complete usage example
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   ├── docs/                     # Additional documentation
│   │   ├── architecture.md       # Architecture documentation
│   │   ├── troubleshooting.md    # Troubleshooting guide
│   │   └── migration.md          # Migration guide
│   └── test/                     # Testing infrastructure
│       ├── fixtures/             # Test fixtures
│       ├── integration/          # Integration tests
│       └── unit/                 # Unit tests
```

#### **Interface Design Patterns**

```hcl
# Input Interface Design - variables.tf
variable "vpc_configuration" {
  description = "Comprehensive VPC configuration"
  type = object({
    # Required core configuration
    name               = string
    cidr_block         = string
    availability_zones = list(string)
    
    # Optional network configuration
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    enable_ipv6          = optional(bool, false)
    
    # Subnet configuration with defaults
    public_subnet_cidrs   = optional(list(string), [])
    private_subnet_cidrs  = optional(list(string), [])
    database_subnet_cidrs = optional(list(string), [])
    
    # NAT Gateway configuration
    nat_gateway_configuration = optional(object({
      enabled                = bool
      single_nat_gateway     = optional(bool, false)
      one_nat_gateway_per_az = optional(bool, true)
      reuse_nat_ips          = optional(bool, false)
      external_nat_ip_ids    = optional(list(string), [])
    }), {
      enabled = true
    })
    
    # VPC Endpoints configuration
    vpc_endpoints = optional(object({
      s3 = optional(object({
        enabled      = bool
        policy       = optional(string, null)
        route_table_ids = optional(list(string), [])
      }), { enabled = false })
      
      dynamodb = optional(object({
        enabled      = bool
        policy       = optional(string, null)
        route_table_ids = optional(list(string), [])
      }), { enabled = false })
      
      ec2 = optional(object({
        enabled             = bool
        policy              = optional(string, null)
        subnet_ids          = optional(list(string), [])
        security_group_ids  = optional(list(string), [])
        private_dns_enabled = optional(bool, true)
      }), { enabled = false })
    }), {})
    
    # Flow logs configuration
    flow_logs = optional(object({
      enabled                      = bool
      log_destination_type         = optional(string, "cloud-watch-logs")
      log_destination              = optional(string, null)
      iam_role_arn                = optional(string, null)
      log_format                  = optional(string, null)
      traffic_type                = optional(string, "ALL")
      max_aggregation_interval    = optional(number, 600)
    }), { enabled = false })
  })
  
  # Comprehensive validation rules
  validation {
    condition = can(cidrhost(var.vpc_configuration.cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
  
  validation {
    condition = length(var.vpc_configuration.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified for high availability."
  }
  
  validation {
    condition = alltrue([
      for cidr in var.vpc_configuration.public_subnet_cidrs :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet CIDRs must be valid IPv4 CIDRs."
  }
  
  validation {
    condition = alltrue([
      for cidr in var.vpc_configuration.private_subnet_cidrs :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All private subnet CIDRs must be valid IPv4 CIDRs."
  }
  
  validation {
    condition = contains(["ALL", "ACCEPT", "REJECT"], var.vpc_configuration.flow_logs.traffic_type)
    error_message = "Flow logs traffic type must be ALL, ACCEPT, or REJECT."
  }
}
```

---

## 🔄 **Module Composition and Dependency Management**

### **Advanced Module Composition Patterns**

Module composition enables building complex infrastructure by combining simpler, focused modules. Understanding composition patterns is essential for creating maintainable and scalable infrastructure architectures.

![Figure 7.2: Module Composition and Dependency Management](DaC/generated_diagrams/figure_7_2_module_composition_dependency.png)
*Figure 7.2: Module composition patterns, dependency management strategies, and complex integration workflows*

#### **Hierarchical Module Composition**

```hcl
# Foundation Layer - Core infrastructure modules
# File: environments/production/foundation/main.tf
terraform {
  required_version = "~> 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }

  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "foundation/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

# Network Foundation Module
module "vpc" {
  source = "../../../modules/vpc"

  vpc_configuration = {
    name               = "production-vpc"
    cidr_block         = "10.0.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

    public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

    nat_gateway_configuration = {
      enabled                = true
      one_nat_gateway_per_az = true
    }

    vpc_endpoints = {
      s3 = { enabled = true }
      dynamodb = { enabled = true }
      ec2 = { enabled = true }
    }

    flow_logs = {
      enabled = true
      traffic_type = "ALL"
    }
  }

  environment = var.environment
  tags = local.common_tags
}

# Security Foundation Module
module "security" {
  source = "../../../modules/security"

  vpc_id = module.vpc.vpc_configuration.vpc_id

  security_configuration = {
    # KMS keys for different data classifications
    kms_keys = {
      general = {
        description = "General purpose encryption key"
        key_usage   = "ENCRYPT_DECRYPT"
        key_spec    = "SYMMETRIC_DEFAULT"
      }
      sensitive = {
        description = "Sensitive data encryption key"
        key_usage   = "ENCRYPT_DECRYPT"
        key_spec    = "SYMMETRIC_DEFAULT"
      }
      restricted = {
        description = "Restricted data encryption key"
        key_usage   = "ENCRYPT_DECRYPT"
        key_spec    = "SYMMETRIC_DEFAULT"
      }
    }

    # IAM roles for different service types
    iam_roles = {
      ec2_instance_role = {
        description = "Default EC2 instance role"
        policies = [
          "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        ]
      }
      lambda_execution_role = {
        description = "Default Lambda execution role"
        policies = [
          "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        ]
      }
      ecs_task_role = {
        description = "Default ECS task role"
        policies = [
          "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
        ]
      }
    }

    # Security group templates
    security_groups = {
      web_tier = {
        description = "Web tier security group"
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
      app_tier = {
        description = "Application tier security group"
        ingress_rules = [
          {
            from_port                = 8080
            to_port                  = 8080
            protocol                 = "tcp"
            source_security_group_id = "web_tier"
            description              = "Application port from web tier"
          }
        ]
      }
      db_tier = {
        description = "Database tier security group"
        ingress_rules = [
          {
            from_port                = 3306
            to_port                  = 3306
            protocol                 = "tcp"
            source_security_group_id = "app_tier"
            description              = "MySQL from application tier"
          }
        ]
      }
    }
  }

  environment = var.environment
  tags = local.common_tags

  depends_on = [module.vpc]
}

# DNS Foundation Module
module "dns" {
  source = "../../../modules/dns"

  vpc_id = module.vpc.vpc_configuration.vpc_id

  dns_configuration = {
    private_zone_name = "internal.company.com"

    # DNS records for internal services
    records = {
      database = {
        type = "CNAME"
        ttl  = 300
        records = ["db.internal.company.com"]
      }
      cache = {
        type = "CNAME"
        ttl  = 300
        records = ["cache.internal.company.com"]
      }
    }

    # Route53 resolver endpoints
    resolver_endpoints = {
      inbound = {
        direction = "INBOUND"
        ip_addresses = [
          {
            subnet_id = module.vpc.vpc_configuration.subnets.private.ids[0]
            ip        = "10.0.11.10"
          },
          {
            subnet_id = module.vpc.vpc_configuration.subnets.private.ids[1]
            ip        = "10.0.12.10"
          }
        ]
      }
      outbound = {
        direction = "OUTBOUND"
        ip_addresses = [
          {
            subnet_id = module.vpc.vpc_configuration.subnets.private.ids[0]
            ip        = "10.0.11.11"
          },
          {
            subnet_id = module.vpc.vpc_configuration.subnets.private.ids[1]
            ip        = "10.0.12.11"
          }
        ]
      }
    }
  }

  environment = var.environment
  tags = local.common_tags

  depends_on = [module.vpc, module.security]
}

# Foundation layer outputs for consumption by platform layer
output "foundation_configuration" {
  description = "Foundation layer configuration for platform consumption"
  value = {
    vpc = module.vpc.vpc_configuration
    security = module.security.security_configuration
    dns = module.dns.dns_configuration
  }
}
```

#### **Platform Layer Composition**

```hcl
# Platform Layer - Shared services built on foundation
# File: environments/production/platform/main.tf
terraform {
  required_version = "~> 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }

  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "platform/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

# Import foundation layer configuration
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "company-terraform-state"
    key    = "foundation/production/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  # Extract foundation configuration for easier access
  vpc_config = data.terraform_remote_state.foundation.outputs.foundation_configuration.vpc
  security_config = data.terraform_remote_state.foundation.outputs.foundation_configuration.security
  dns_config = data.terraform_remote_state.foundation.outputs.foundation_configuration.dns
}

# Monitoring Platform Module
module "monitoring" {
  source = "../../../modules/monitoring"

  vpc_configuration = local.vpc_config

  monitoring_configuration = {
    # CloudWatch configuration
    cloudwatch = {
      log_groups = {
        application = {
          name              = "/aws/application/production"
          retention_in_days = 30
          kms_key_id        = local.security_config.kms_keys.general.arn
        }
        infrastructure = {
          name              = "/aws/infrastructure/production"
          retention_in_days = 90
          kms_key_id        = local.security_config.kms_keys.general.arn
        }
        security = {
          name              = "/aws/security/production"
          retention_in_days = 365
          kms_key_id        = local.security_config.kms_keys.restricted.arn
        }
      }

      dashboards = {
        infrastructure = {
          name = "Infrastructure-Overview"
          widgets = [
            {
              type = "metric"
              properties = {
                metrics = [
                  ["AWS/EC2", "CPUUtilization"],
                  ["AWS/RDS", "CPUUtilization"],
                  ["AWS/ELB", "RequestCount"]
                ]
                period = 300
                stat   = "Average"
                region = "us-east-1"
                title  = "Infrastructure Metrics"
              }
            }
          ]
        }
      }
    }

    # Prometheus configuration for advanced metrics
    prometheus = {
      enabled = true
      storage_size = "100Gi"
      retention_period = "30d"

      # Service discovery configuration
      service_discovery = {
        kubernetes = {
          enabled = true
          namespaces = ["default", "monitoring", "application"]
        }
        ec2 = {
          enabled = true
          regions = ["us-east-1"]
          ports = [9100, 9090, 3000]
        }
      }
    }

    # Grafana configuration
    grafana = {
      enabled = true
      admin_password = var.grafana_admin_password

      # Data sources
      datasources = {
        prometheus = {
          url = "http://prometheus:9090"
          type = "prometheus"
          access = "proxy"
        }
        cloudwatch = {
          type = "cloudwatch"
          region = "us-east-1"
          access = "proxy"
        }
      }

      # Dashboard provisioning
      dashboards = {
        infrastructure = {
          folder = "Infrastructure"
          dashboards = [
            "aws-ec2-overview",
            "aws-rds-overview",
            "aws-elb-overview"
          ]
        }
        application = {
          folder = "Applications"
          dashboards = [
            "application-performance",
            "application-errors",
            "application-business-metrics"
          ]
        }
      }
    }
  }

  environment = var.environment
  tags = local.common_tags
}
```

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for key, value in var.tags :
      can(regex("^[a-zA-Z0-9\\s\\-\\._:/=+@]+$", key)) && can(regex("^[a-zA-Z0-9\\s\\-\\._:/=+@]*$", value))
    ])
    error_message = "Tag keys and values must contain only alphanumeric characters, spaces, and the following characters: - . _ : / = + @"
  }
}
```
