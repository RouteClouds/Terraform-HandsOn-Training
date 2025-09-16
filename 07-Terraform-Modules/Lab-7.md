# Lab 7: Terraform Modules

## 🎯 **Lab Objectives**

By completing this comprehensive hands-on lab, you will demonstrate advanced mastery of:

1. **Module Architecture Design** - Create sophisticated module architectures for enterprise environments
2. **Module Composition Patterns** - Implement complex module composition and dependency management
3. **Versioning and Lifecycle** - Establish comprehensive versioning strategies and lifecycle workflows
4. **Testing and Validation** - Build robust testing frameworks and quality assurance processes
5. **Enterprise Governance** - Design enterprise-grade governance frameworks with module registries
6. **Advanced Module Patterns** - Apply advanced patterns including factories, proxies, and dynamic composition

### **Measurable Outcomes**
- **100% successful** module architecture implementation with enterprise patterns
- **95% accuracy** in module composition and dependency management
- **90% efficiency** in testing framework implementation and validation
- **100% compliance** with enterprise governance and registry standards

---

## 📋 **Lab Scenario**

### **Business Context**
You are a Senior Infrastructure Architect at GlobalTech Solutions, a multinational technology company with 75,000+ employees across 30 countries. The company is implementing a next-generation cloud platform requiring sophisticated module architecture, multi-team collaboration, and enterprise-grade governance frameworks. Your current challenges include:

- **Module Standardization**: Creating reusable modules for 25+ development teams
- **Complex Dependencies**: Managing intricate dependencies between infrastructure layers
- **Quality Assurance**: Implementing comprehensive testing and validation frameworks
- **Enterprise Governance**: Establishing module registries and approval workflows

### **Success Criteria**
Your task is to implement an advanced Terraform module system that achieves:
- **Zero module conflicts** across all teams and environments
- **95% code reusability** through well-designed module interfaces
- **90% reduction** in infrastructure deployment time through module composition
- **100% compliance** with enterprise governance and quality standards

![Figure 7.1: Module Architecture and Design Patterns](DaC/generated_diagrams/figure_7_1_module_architecture_patterns.png)
*Figure 7.1: The comprehensive module architecture you'll implement in this lab*

---

## 🛠️ **Prerequisites and Setup**

### **Required Tools and Versions**
- **Operating System**: Windows 10+, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **Terraform CLI**: Version ~> 1.13.0 (installed and configured from previous labs)
- **AWS CLI**: Version 2.15.0+ with configured credentials
- **Git**: Version 2.40+ for version control and module management
- **Text Editor**: VS Code with HashiCorp Terraform extension v2.29.0+
- **Testing Tools**: Go 1.21+ for Terratest, Python 3.9+ for validation scripts

### **AWS Account Requirements**
- **AWS Account**: Active AWS account with administrative access
- **IAM Permissions**: Full access to VPC, EC2, RDS, S3, IAM, CloudWatch, and Route53
- **Budget Alert**: $150 monthly budget configured for lab resources
- **Region**: All resources will be created in us-east-1
- **Multi-Environment Setup**: Support for development, staging, and production environments

### **Pre-Lab Verification**
```bash
# Verify Terraform installation and version
terraform version
# Expected: Terraform v1.13.x

# Verify AWS CLI configuration
aws sts get-caller-identity
aws configure get region
# Expected: us-east-1

# Install testing tools
# Go for Terratest
go version
# Expected: go1.21+

# Python for validation scripts
python3 --version
# Expected: Python 3.9+

# Verify Git configuration
git --version
git config --global user.name
git config --global user.email
# Expected: Latest version with proper configuration
```

---

## 🚀 **Lab Exercise 1: Foundation Module Development**

### **Objective**
Design and implement a comprehensive foundation module that provides core infrastructure components with advanced configuration options and enterprise-grade features.

![Figure 7.2: Module Composition and Dependency Management](DaC/generated_diagrams/figure_7_2_module_composition_dependency.png)
*Figure 7.2: Module composition patterns and dependency management you'll implement*

### **Exercise 1.1: VPC Foundation Module**

#### **Create Module Structure**
```bash
# Create comprehensive lab directory structure
mkdir -p terraform-modules-lab/{modules,environments,tests,docs}
cd terraform-modules-lab

# Create foundation modules
mkdir -p modules/{vpc,security,dns,monitoring}
mkdir -p modules/vpc/{examples,docs,test}

# Create environment configurations
mkdir -p environments/{dev,staging,prod}/{foundation,platform,applications}

# Create testing infrastructure
mkdir -p tests/{unit,integration,e2e}
```

#### **Implement VPC Foundation Module**
```hcl
# modules/vpc/versions.tf - Version constraints
terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
    }
  }
}

# modules/vpc/variables.tf - Comprehensive variable definitions
variable "vpc_configuration" {
  description = "Comprehensive VPC configuration parameters"
  type = object({
    # Core VPC settings
    name               = string
    cidr_block         = string
    availability_zones = list(string)
    
    # DNS configuration
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    enable_ipv6          = optional(bool, false)
    
    # Subnet configuration
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
      one_nat_gateway_per_az = true
    })
    
    # VPC Endpoints configuration
    vpc_endpoints = optional(object({
      s3 = optional(object({
        enabled         = bool
        policy          = optional(string, null)
        route_table_ids = optional(list(string), [])
      }), { enabled = false })
      
      dynamodb = optional(object({
        enabled         = bool
        policy          = optional(string, null)
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
      enabled                   = bool
      log_destination_type      = optional(string, "cloud-watch-logs")
      log_destination           = optional(string, null)
      iam_role_arn             = optional(string, null)
      log_format               = optional(string, null)
      traffic_type             = optional(string, "ALL")
      max_aggregation_interval = optional(number, 600)
    }), { enabled = false })
    
    # Network ACL configuration
    network_acls = optional(object({
      public_dedicated  = optional(bool, false)
      private_dedicated = optional(bool, false)
      database_dedicated = optional(bool, true)
      
      # Custom ACL rules
      public_inbound = optional(list(object({
        rule_number = number
        protocol    = string
        rule_action = string
        cidr_block  = string
        from_port   = optional(number, null)
        to_port     = optional(number, null)
      })), [])
      
      public_outbound = optional(list(object({
        rule_number = number
        protocol    = string
        rule_action = string
        cidr_block  = string
        from_port   = optional(number, null)
        to_port     = optional(number, null)
      })), [])
    }), {})
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
    condition = length(var.vpc_configuration.availability_zones) <= 6
    error_message = "Maximum 6 availability zones are supported."
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
    condition = alltrue([
      for cidr in var.vpc_configuration.database_subnet_cidrs :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All database subnet CIDRs must be valid IPv4 CIDRs."
  }
  
  validation {
    condition = contains(["ALL", "ACCEPT", "REJECT"], var.vpc_configuration.flow_logs.traffic_type)
    error_message = "Flow logs traffic type must be ALL, ACCEPT, or REJECT."
  }
  
  validation {
    condition = contains(["cloud-watch-logs", "s3"], var.vpc_configuration.flow_logs.log_destination_type)
    error_message = "Flow logs destination type must be cloud-watch-logs or s3."
  }
}

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

# modules/vpc/locals.tf - Local value computations
locals {
  # Common tags for all resources
  common_tags = merge(var.tags, {
    Environment = var.environment
    Module      = "vpc"
    ManagedBy   = "terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })
  
  # Availability zone mapping
  az_count = length(var.vpc_configuration.availability_zones)
  
  # Subnet calculations
  public_subnet_count   = length(var.vpc_configuration.public_subnet_cidrs)
  private_subnet_count  = length(var.vpc_configuration.private_subnet_cidrs)
  database_subnet_count = length(var.vpc_configuration.database_subnet_cidrs)
  
  # NAT Gateway configuration
  nat_gateway_count = var.vpc_configuration.nat_gateway_configuration.enabled ? (
    var.vpc_configuration.nat_gateway_configuration.single_nat_gateway ? 1 : (
      var.vpc_configuration.nat_gateway_configuration.one_nat_gateway_per_az ? local.az_count : local.public_subnet_count
    )
  ) : 0
  
  # VPC Endpoints configuration
  vpc_endpoints_enabled = {
    s3       = var.vpc_configuration.vpc_endpoints.s3.enabled
    dynamodb = var.vpc_configuration.vpc_endpoints.dynamodb.enabled
    ec2      = var.vpc_configuration.vpc_endpoints.ec2.enabled
  }
  
  # Flow logs configuration
  flow_logs_enabled = var.vpc_configuration.flow_logs.enabled
  
  # Network ACL configuration
  network_acls_config = var.vpc_configuration.network_acls
}

# modules/vpc/main.tf - Core VPC resource implementation
# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_configuration.cidr_block
  enable_dns_hostnames = var.vpc_configuration.enable_dns_hostnames
  enable_dns_support   = var.vpc_configuration.enable_dns_support

  tags = merge(local.common_tags, {
    Name = var.vpc_configuration.name
    Type = "vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-igw"
    Type = "internet-gateway"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = local.public_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_configuration.public_subnet_cidrs[count.index]
  availability_zone       = var.vpc_configuration.availability_zones[count.index % local.az_count]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-public-${count.index + 1}"
    Type = "public-subnet"
    Tier = "public"
    AZ   = var.vpc_configuration.availability_zones[count.index % local.az_count]
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count = local.private_subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_configuration.private_subnet_cidrs[count.index]
  availability_zone = var.vpc_configuration.availability_zones[count.index % local.az_count]

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-private-${count.index + 1}"
    Type = "private-subnet"
    Tier = "private"
    AZ   = var.vpc_configuration.availability_zones[count.index % local.az_count]
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count = local.database_subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_configuration.database_subnet_cidrs[count.index]
  availability_zone = var.vpc_configuration.availability_zones[count.index % local.az_count]

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-database-${count.index + 1}"
    Type = "database-subnet"
    Tier = "database"
    AZ   = var.vpc_configuration.availability_zones[count.index % local.az_count]
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-nat-eip-${count.index + 1}"
    Type = "elastic-ip"
  })

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % local.public_subnet_count].id

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-nat-${count.index + 1}"
    Type = "nat-gateway"
  })

  depends_on = [aws_internet_gateway.main]
}

# Route Tables - Public
resource "aws_route_table" "public" {
  count = local.public_subnet_count > 0 ? 1 : 0

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-public-rt"
    Type = "route-table"
    Tier = "public"
  })
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  count = local.public_subnet_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Route Tables - Private
resource "aws_route_table" "private" {
  count = local.private_subnet_count

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = local.nat_gateway_count > 0 ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[
        var.vpc_configuration.nat_gateway_configuration.single_nat_gateway ? 0 : count.index % local.nat_gateway_count
      ].id
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-private-rt-${count.index + 1}"
    Type = "route-table"
    Tier = "private"
  })
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  count = local.private_subnet_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Route Tables - Database
resource "aws_route_table" "database" {
  count = local.database_subnet_count

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-database-rt-${count.index + 1}"
    Type = "route-table"
    Tier = "database"
  })
}

# Route Table Associations - Database
resource "aws_route_table_association" "database" {
  count = local.database_subnet_count

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

# Database Subnet Group
resource "aws_db_subnet_group" "database" {
  count = local.database_subnet_count > 0 ? 1 : 0

  name       = "${var.vpc_configuration.name}-database-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(local.common_tags, {
    Name = "${var.vpc_configuration.name}-database-subnet-group"
    Type = "db-subnet-group"
  })
}
```

### **Exercise 1.2: Module Testing Implementation**

#### **Unit Testing with Terratest**
```go
// tests/unit/vpc_test.go - Comprehensive unit tests
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/aws"
    "github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
    t.Parallel()

    // Define test configuration
    terraformOptions := &terraform.Options{
        TerraformDir: "../../modules/vpc/examples/basic",
        Vars: map[string]interface{}{
            "vpc_configuration": map[string]interface{}{
                "name":               "test-vpc",
                "cidr_block":         "10.0.0.0/16",
                "availability_zones": []string{"us-east-1a", "us-east-1b"},
                "public_subnet_cidrs":  []string{"10.0.1.0/24", "10.0.2.0/24"},
                "private_subnet_cidrs": []string{"10.0.11.0/24", "10.0.12.0/24"},
                "nat_gateway_configuration": map[string]interface{}{
                    "enabled": true,
                    "one_nat_gateway_per_az": true,
                },
            },
            "environment": "test",
        },
    }

    // Clean up resources after test
    defer terraform.Destroy(t, terraformOptions)

    // Deploy the infrastructure
    terraform.InitAndApply(t, terraformOptions)

    // Validate VPC creation
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)

    // Validate VPC properties
    vpc := aws.GetVpcById(t, vpcId, "us-east-1")
    assert.Equal(t, "10.0.0.0/16", vpc.CidrBlock)
    assert.True(t, vpc.EnableDnsHostnames)
    assert.True(t, vpc.EnableDnsSupport)

    // Validate subnet creation
    publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
    assert.Len(t, publicSubnetIds, 2)

    privateSubnetIds := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
    assert.Len(t, privateSubnetIds, 2)

    // Validate NAT Gateway creation
    natGatewayIds := terraform.OutputList(t, terraformOptions, "nat_gateway_ids")
    assert.Len(t, natGatewayIds, 2)

    // Validate Internet Gateway
    igwId := terraform.Output(t, terraformOptions, "internet_gateway_id")
    assert.NotEmpty(t, igwId)
}

func TestVPCModuleWithEndpoints(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../../modules/vpc/examples/advanced",
        Vars: map[string]interface{}{
            "vpc_configuration": map[string]interface{}{
                "name":               "test-vpc-endpoints",
                "cidr_block":         "10.1.0.0/16",
                "availability_zones": []string{"us-east-1a", "us-east-1b"},
                "public_subnet_cidrs":  []string{"10.1.1.0/24", "10.1.2.0/24"},
                "private_subnet_cidrs": []string{"10.1.11.0/24", "10.1.12.0/24"},
                "vpc_endpoints": map[string]interface{}{
                    "s3": map[string]interface{}{
                        "enabled": true,
                    },
                    "dynamodb": map[string]interface{}{
                        "enabled": true,
                    },
                },
            },
            "environment": "test",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Validate VPC endpoints
    s3EndpointId := terraform.Output(t, terraformOptions, "s3_endpoint_id")
    assert.NotEmpty(t, s3EndpointId)

    dynamodbEndpointId := terraform.Output(t, terraformOptions, "dynamodb_endpoint_id")
    assert.NotEmpty(t, dynamodbEndpointId)
}
```
```
