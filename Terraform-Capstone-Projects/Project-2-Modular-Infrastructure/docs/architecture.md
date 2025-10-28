# Project 2: Modular Infrastructure - Architecture Documentation

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [Module Design](#module-design)
4. [Module Composition](#module-composition)
5. [Infrastructure Components](#infrastructure-components)
6. [Module Dependencies](#module-dependencies)
7. [Data Flow](#data-flow)
8. [Security Architecture](#security-architecture)
9. [High Availability](#high-availability)
10. [Scalability](#scalability)

---

## OVERVIEW

Project 2 demonstrates a **modular infrastructure approach** using Terraform modules. The project creates a library of 8 reusable modules that can be composed into a complete, production-ready infrastructure.

### Key Architectural Goals

- **Modularity**: Each component is a self-contained, reusable module
- **Composability**: Modules can be combined to create complex infrastructures
- **Reusability**: Modules can be used across different projects and environments
- **Maintainability**: Changes to modules are isolated and easy to manage
- **Testability**: Each module can be tested independently

---

## ARCHITECTURE PRINCIPLES

### 1. DRY (Don't Repeat Yourself)

Modules eliminate code duplication by encapsulating common patterns:

```hcl
# Instead of repeating VPC configuration in every project
module "vpc" {
  source = "./modules/vpc"
  # Configuration
}
```

### 2. Separation of Concerns

Each module has a single, well-defined responsibility:

- **VPC Module**: Network infrastructure only
- **Security Module**: Security groups, IAM, KMS only
- **Compute Module**: EC2 and Auto Scaling only

### 3. Loose Coupling

Modules communicate through well-defined interfaces (inputs/outputs):

```hcl
# VPC module outputs
output "vpc_id" { ... }
output "subnet_ids" { ... }

# Compute module inputs
variable "vpc_id" { ... }
variable "subnet_ids" { ... }
```

### 4. High Cohesion

Related resources are grouped together within modules:

- VPC, subnets, gateways, route tables → VPC Module
- Security groups, IAM roles, KMS keys → Security Module

---

## MODULE DESIGN

### Module Structure

Each module follows a standard structure:

```
module-name/
├── README.md          # Module documentation
├── versions.tf        # Terraform and provider versions
├── variables.tf       # Input variables
├── main.tf            # Resource definitions
└── outputs.tf         # Output values
```

### Module Interface

**Inputs** (variables.tf):
- Required variables (no defaults)
- Optional variables (with defaults)
- Variable validation rules

**Outputs** (outputs.tf):
- Resource IDs
- Resource ARNs
- Computed values

**Resources** (main.tf):
- AWS resources
- Data sources
- Local values

---

## MODULE COMPOSITION

### Root Module

The root module composes all child modules:

```hcl
module "vpc" { ... }
module "security" { ... }
module "compute" { ... }
module "load_balancer" { ... }
module "database" { ... }
module "storage" { ... }
module "monitoring" { ... }
module "dns" { ... }
```

### Module Dependencies

```
VPC Module
  ↓
Security Module
  ↓
├─→ Compute Module
├─→ Load Balancer Module
├─→ Database Module
└─→ Storage Module
  ↓
Monitoring Module
  ↓
DNS Module
```

---

## INFRASTRUCTURE COMPONENTS

### 1. VPC Module

**Purpose**: Network foundation

**Resources**:
- 1 VPC (10.0.0.0/16)
- 3 Public Subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
- 3 Private Subnets (10.0.11.0/24, 10.0.12.0/24, 10.0.13.0/24)
- 1 Internet Gateway
- 3 NAT Gateways (or 1 for cost savings)
- Route Tables

**Key Features**:
- Multi-AZ deployment
- Public/private subnet separation
- VPC Flow Logs (optional)
- S3 VPC Endpoint (optional)

### 2. Security Module

**Purpose**: Security controls

**Resources**:
- ALB Security Group
- EC2 Security Group
- RDS Security Group
- EC2 IAM Role
- EC2 Instance Profile
- KMS Key (optional)

**Key Features**:
- Least privilege security groups
- IAM roles for EC2
- KMS encryption
- Systems Manager access

### 3. Compute Module

**Purpose**: Application servers

**Resources**:
- Launch Template
- Auto Scaling Group
- Scaling Policies
- CloudWatch Alarms

**Key Features**:
- Auto scaling (2-6 instances)
- CPU-based scaling
- IMDSv2 enforcement
- EBS encryption

### 4. Load Balancer Module

**Purpose**: Traffic distribution

**Resources**:
- Application Load Balancer
- Target Group
- HTTP Listener
- HTTPS Listener (optional)

**Key Features**:
- Health checks
- SSL/TLS support
- Cross-zone load balancing

### 5. Database Module

**Purpose**: Data persistence

**Resources**:
- RDS Instance
- DB Subnet Group
- Enhanced Monitoring (optional)

**Key Features**:
- Multi-AZ deployment (optional)
- Automated backups
- KMS encryption
- PostgreSQL/MySQL/MariaDB support

### 6. Storage Module

**Purpose**: Object storage

**Resources**:
- S3 Bucket
- Bucket Versioning
- Encryption Configuration
- Lifecycle Policies

**Key Features**:
- Versioning
- KMS encryption
- Lifecycle management
- Public access blocking

### 7. Monitoring Module

**Purpose**: Observability

**Resources**:
- CloudWatch Dashboard
- CloudWatch Log Group
- SNS Topic
- Email Subscription

**Key Features**:
- Centralized logging
- Metrics visualization
- Alarm notifications

### 8. DNS Module

**Purpose**: Domain management

**Resources**:
- Route53 Hosted Zone
- A Records
- WWW Record

**Key Features**:
- DNS management
- ALB alias records
- Health checks

---

## MODULE DEPENDENCIES

### Explicit Dependencies

Modules declare dependencies using `depends_on`:

```hcl
module "compute" {
  source = "./modules/compute"
  # ...
  depends_on = [module.security]
}
```

### Implicit Dependencies

Modules depend on each other through outputs:

```hcl
module "compute" {
  source = "./modules/compute"
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.ec2_security_group_id]
}
```

---

## DATA FLOW

### Request Flow

```
User → Route53 → ALB → EC2 Instances → RDS Database
                  ↓
                  S3 Bucket
                  ↓
                  CloudWatch
```

### Module Data Flow

```
Root Module Variables
  ↓
Module Inputs
  ↓
Module Resources
  ↓
Module Outputs
  ↓
Root Module Outputs
```

---

## SECURITY ARCHITECTURE

### Network Security

- **Public Subnets**: ALB only
- **Private Subnets**: EC2, RDS
- **Security Groups**: Least privilege rules
- **NACLs**: Default allow (can be customized)

### Identity and Access Management

- **EC2 IAM Role**: S3, CloudWatch, SSM access
- **RDS IAM Authentication**: Optional
- **KMS Keys**: Encryption at rest

### Encryption

- **In Transit**: HTTPS (optional)
- **At Rest**: EBS, RDS, S3 (KMS)

---

## HIGH AVAILABILITY

### Multi-AZ Deployment

- **VPC**: 3 Availability Zones
- **ALB**: Cross-zone load balancing
- **EC2**: Distributed across AZs
- **RDS**: Multi-AZ (optional)
- **NAT Gateways**: One per AZ (optional)

### Fault Tolerance

- **Auto Scaling**: Replaces unhealthy instances
- **ALB Health Checks**: Routes traffic to healthy instances
- **RDS Failover**: Automatic failover to standby

---

## SCALABILITY

### Horizontal Scaling

- **Auto Scaling Group**: 2-6 instances
- **Scaling Policies**: CPU-based
- **Load Balancer**: Distributes traffic

### Vertical Scaling

- **Instance Types**: Configurable
- **RDS Instance Class**: Configurable
- **Storage**: Auto-scaling (optional)

---

## DIAGRAMS

See the `diagrams/` directory for visual representations:

- `hld.png` - High-Level Design
- `lld.png` - Low-Level Design
- `module_architecture.png` - Module Architecture
- `module_dependencies.png` - Module Dependencies
- `vpc_module_design.png` - VPC Module Design
- `compute_module_design.png` - Compute Module Design
- `database_module_design.png` - Database Module Design
- `module_composition.png` - Module Composition
- `testing_strategy.png` - Testing Strategy

---

## BEST PRACTICES

### Module Design

✅ **Single Responsibility**: Each module has one purpose  
✅ **Standard Structure**: Consistent file organization  
✅ **Input Validation**: Validate all inputs  
✅ **Comprehensive Outputs**: Expose all useful values  
✅ **Documentation**: README for each module  

### Module Usage

✅ **Version Pinning**: Pin module versions  
✅ **Variable Defaults**: Provide sensible defaults  
✅ **Explicit Dependencies**: Use depends_on when needed  
✅ **Testing**: Test modules independently  
✅ **Semantic Versioning**: Follow semver for module versions  

---

**Document Version**: 1.0  
**Last Updated**: October 27, 2025  
**Author**: RouteCloud Training Team

