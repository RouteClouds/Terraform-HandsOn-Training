# AWS Terraform Training - Resource Management & Dependencies

## 🎯 Lab 4.1: Advanced Resource Dependencies and Meta-Arguments

### **Master Complex Dependency Patterns and Advanced Meta-Arguments**

This lab provides comprehensive hands-on experience with Terraform's advanced resource management capabilities, including complex dependency patterns, sophisticated meta-arguments usage, and enterprise-grade lifecycle management strategies.

---

## 📋 **Lab Overview**

### **Learning Objectives**
By completing this lab, you will:

1. **Master complex dependency management** with implicit and explicit dependency patterns
2. **Implement advanced meta-arguments** including count, for_each, lifecycle, and depends_on
3. **Design sophisticated resource relationships** with proper ordering and dependency resolution
4. **Optimize resource lifecycle management** with enterprise-grade lifecycle rules
5. **Handle dependency conflicts** and circular dependency resolution strategies
6. **Apply advanced resource organization** patterns for scalable infrastructure management

### **Architecture Deployed**
- **Multi-tier VPC architecture** with foundation, network, security, data, application, presentation, and monitoring tiers
- **Complex dependency chains** demonstrating 8 distinct dependency tiers
- **Advanced meta-arguments** with count for subnets, for_each for application tiers, lifecycle for critical resources
- **Database tier** with RDS MySQL and complex security group dependencies
- **Application tiers** (web, app, api) with Auto Scaling Groups and Launch Templates
- **Load balancer tier** with Application Load Balancer and target groups
- **Monitoring tier** with CloudWatch logs and optional VPC flow logs

### **Duration**: 150-180 minutes
### **Difficulty**: Advanced
### **Cost**: $1.00 - $3.00/day (with auto-shutdown enabled)

---

## 🏗️ **Infrastructure Architecture**

```
┌─────────────────────────────────────────────────────────────────┐
│                Resource Management & Dependencies Lab            │
├─────────────────────────────────────────────────────────────────┤
│  Tier 8: Monitoring                                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ CloudWatch Logs │ VPC Flow Logs │ IAM Roles          │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Tier 7: Presentation (depends_on: ASG, IGW, Route Assoc)      │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Application Load Balancer │ Target Groups │ Listeners  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Tier 6: Application (depends_on: Database, Launch Templates)  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Auto Scaling Groups (for_each) │ Launch Templates      │    │
│  │ Web Tier │ App Tier │ API Tier                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Tier 5: Data (depends_on: Subnet Group, Security Group)       │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ RDS MySQL Database │ DB Subnet Group                   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Tier 4: Security (implicit: VPC)                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Security Groups (for_each) │ Database SG │ ALB SG      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Tier 3: Routing (implicit: Subnets, IGW)                      │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Route Tables │ Route Associations │ NAT Gateways       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Tier 2: Network (implicit: VPC)                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Public Subnets (count) │ Private Subnets │ DB Subnets  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Tier 1: Foundation                                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ VPC │ Internet Gateway │ Random Resources               │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 **Quick Start Guide**

### **Prerequisites**
- **AWS Account** with appropriate permissions
- **Terraform CLI** installed (version ~> 1.13.0)
- **AWS CLI** configured with credentials
- **Understanding** of Terraform core operations from Topics 1-3

### **1. Clone and Setup**
```bash
# Navigate to the lab directory
cd 04-Resource-Management-Dependencies/Terraform-Code-Lab-4.1

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit variables with your information
nano terraform.tfvars  # Update student_name and owner_email
```

### **2. Initialize Terraform**
```bash
# Initialize Terraform with provider downloads
terraform init

# Verify initialization and providers
terraform providers
ls -la .terraform/
```

### **3. Analyze Dependencies**
```bash
# Generate dependency graph
terraform graph | dot -Tpng > dependencies.png

# Validate configuration
terraform validate

# Create execution plan
terraform plan
```

### **4. Deploy Infrastructure by Tiers**
```bash
# Deploy foundation tier
terraform apply -target=aws_vpc.main -target=aws_internet_gateway.main

# Deploy network tier
terraform apply -target=aws_subnet.public -target=aws_subnet.private -target=aws_subnet.database

# Deploy routing tier
terraform apply -target=aws_route_table.public -target=aws_route_table_association.public

# Deploy security tier
terraform apply -target=aws_security_group.app_tiers -target=aws_security_group.database

# Deploy data tier
terraform apply -target=aws_db_instance.main

# Deploy application tier
terraform apply -target=aws_autoscaling_group.app_tiers

# Deploy presentation tier
terraform apply -target=aws_lb.main

# Complete deployment
terraform apply
```

### **5. Test and Validate**
```bash
# View dependency analysis
terraform output dependency_analysis

# View meta-arguments demonstration
terraform output meta_arguments_demonstration

# Test application tiers
curl http://$(terraform output -json | jq -r '.load_balancer_configuration.value.load_balancer.dns_name')/

# Test health endpoints
curl http://$(terraform output -json | jq -r '.load_balancer_configuration.value.load_balancer.dns_name')/health
```

### **6. Cleanup**
```bash
# Destroy in reverse dependency order
terraform destroy -target=aws_lb.main
terraform destroy -target=aws_autoscaling_group.app_tiers
terraform destroy -target=aws_db_instance.main
terraform destroy

# Verify complete cleanup
terraform state list
```

---

## 📁 **File Structure and Components**

### **Core Terraform Files**
```
Terraform-Code-Lab-4.1/
├── providers.tf                  # Advanced provider configuration with dependency tracking
├── variables.tf                  # 40+ variables with comprehensive validation and business context
├── main.tf                      # Complex multi-tier infrastructure with 8 dependency tiers
├── outputs.tf                   # 20+ outputs with dependency analysis and troubleshooting info
├── terraform.tfvars.example     # Multiple scenario configurations with dependency patterns
├── scripts/                     # Supporting scripts
│   └── user_data.sh             # Advanced multi-tier application initialization
└── README.md                    # This comprehensive documentation
```

### **Key Infrastructure Components**

#### **1. Foundation Tier (Tier 1)**
- **VPC** with comprehensive DNS configuration
- **Internet Gateway** with proper VPC attachment
- **Random resources** for unique naming and testing

#### **2. Network Tier (Tier 2)**
- **Public subnets** using count meta-argument across multiple AZs
- **Private subnets** for application tier isolation
- **Database subnets** for data tier security

#### **3. Routing Tier (Tier 3)**
- **Route tables** with public and private routing
- **Route table associations** with implicit subnet dependencies
- **NAT Gateways** (optional) with complex explicit dependencies

#### **4. Security Tier (Tier 4)**
- **Application security groups** using for_each meta-argument
- **Database security group** with inter-tier dependencies
- **Load balancer security group** with presentation tier rules

#### **5. Data Tier (Tier 5)**
- **RDS MySQL database** with lifecycle management
- **DB subnet group** with multi-AZ configuration
- **Complex explicit dependencies** on routing and security

#### **6. Application Tier (Tier 6)**
- **Launch templates** for each application tier using for_each
- **Auto Scaling Groups** with sophisticated lifecycle rules
- **Multi-tier applications** (web, app, api) with tier-specific configurations

#### **7. Presentation Tier (Tier 7)**
- **Application Load Balancer** with complex explicit dependencies
- **Target groups** with health check configuration
- **Listeners** with proper dependency ordering

#### **8. Monitoring Tier (Tier 8)**
- **CloudWatch log groups** for application monitoring
- **VPC Flow Logs** (optional) with IAM role dependencies
- **Monitoring integration** across all tiers

---

## ⚙️ **Meta-Arguments Demonstration**

### **Count Meta-Argument Usage**
```hcl
# Public Subnets with count
resource "aws_subnet" "public" {
  count = length(var.subnet_configurations.public.cidr_blocks)
  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_configurations.public.cidr_blocks[count.index]
  # ... configuration
}

# Reference: aws_subnet.public[0], aws_subnet.public[1], etc.
# All instances: aws_subnet.public[*].id
```

### **For_Each Meta-Argument Usage**
```hcl
# Security Groups with for_each
resource "aws_security_group" "app_tiers" {
  for_each = var.application_tiers
  
  name_prefix = "${var.resource_prefix}-${each.key}-sg-"
  vpc_id      = aws_vpc.main.id
  # ... configuration
}

# Reference: aws_security_group.app_tiers["web"]
# All instances: {for k, v in aws_security_group.app_tiers : k => v.id}
```

### **Lifecycle Meta-Argument Usage**
```hcl
# Database with lifecycle management
resource "aws_db_instance" "main" {
  # ... configuration
  
  lifecycle {
    prevent_destroy = false  # Set to true in production
    ignore_changes = [
      password,  # Ignore password changes
      snapshot_identifier
    ]
  }
}

# Launch Templates with create_before_destroy
resource "aws_launch_template" "app_tiers" {
  # ... configuration
  
  lifecycle {
    create_before_destroy = true
  }
}
```

### **Depends_On Meta-Argument Usage**
```hcl
# Load Balancer with explicit dependencies
resource "aws_lb" "main" {
  # ... configuration
  
  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.public,
    aws_autoscaling_group.app_tiers
  ]
}
```

---

## 🔧 **Dependency Management Patterns**

### **1. Implicit Dependencies**
- **VPC → Subnets**: Subnets reference VPC ID
- **Subnets → Route Tables**: Route table associations reference subnet IDs
- **Security Groups → Database**: Database references security group IDs
- **Launch Templates → Auto Scaling Groups**: ASGs reference launch template IDs

### **2. Explicit Dependencies**
- **NAT Gateway → Internet Gateway**: Ensures proper setup order
- **Database → Route Associations**: Ensures network connectivity
- **Launch Templates → Database**: Ensures database availability
- **Load Balancer → Auto Scaling Groups**: Ensures application tier readiness

### **3. Circular Dependency Resolution**
- **Data sources** to break circular references
- **Separate apply operations** for complex scenarios
- **Resource targeting** for phased deployments

### **4. Dependency Tier Organization**
1. **Foundation**: VPC, IGW, Random resources
2. **Network**: Subnets across multiple AZs
3. **Routing**: Route tables and associations
4. **Security**: Security groups with inter-tier rules
5. **Data**: Database and storage resources
6. **Application**: Compute and scaling resources
7. **Presentation**: Load balancing and traffic distribution
8. **Monitoring**: Logging and observability

---

## 🔍 **Testing and Validation**

### **Dependency Testing Commands**
```bash
# Generate and analyze dependency graph
terraform graph | dot -Tpng > dependencies.png
terraform graph | grep -E "(vpc|subnet|database|autoscaling|lb)"

# Test resource targeting by dependency tier
terraform plan -target=aws_vpc.main
terraform plan -target=aws_subnet.public
terraform plan -target=aws_db_instance.main
terraform plan -target=aws_autoscaling_group.app_tiers

# Test meta-arguments
terraform state show 'aws_subnet.public[0]'
terraform state show 'aws_security_group.app_tiers["web"]'
terraform state list | grep -E "(count|for_each)"

# Test lifecycle behavior
terraform apply -replace=aws_launch_template.app_tiers["web"]
terraform plan  # Should show create_before_destroy behavior
```

### **Application Testing**
```bash
# Test web tier
curl http://$(terraform output -json | jq -r '.load_balancer_configuration.value.load_balancer.dns_name')/

# Test health endpoints
curl http://$(terraform output -json | jq -r '.load_balancer_configuration.value.load_balancer.dns_name')/health

# Test individual tiers (if accessible)
# Web tier instances through load balancer
# App tier instances through internal networking
# API tier instances through service discovery
```

---

## 📊 **Cost Optimization Features**

### **1. Automated Cost Controls**
- **Auto-shutdown after 4 hours**: Prevents runaway costs
- **Right-sized instances**: t3.micro and t3.small for cost efficiency
- **Optional NAT Gateways**: Disabled by default to save ~$135/month
- **Single-AZ RDS**: Multi-AZ disabled for cost optimization

### **2. Cost Monitoring**
```bash
# View cost optimization settings
terraform output infrastructure_summary

# Monitor resource costs by tier
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE
```

### **3. Resource Cleanup**
```bash
# Automated cleanup with dependency-aware destruction
terraform destroy

# Verify cleanup by tier
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=resource-management-dependencies"
```

---

## 📚 **Learning Resources and Next Steps**

### **Immediate Next Steps**
1. **Practice dependency analysis** with different infrastructure patterns
2. **Experiment with meta-arguments** in various scenarios
3. **Test lifecycle management** with production-like configurations
4. **Implement circular dependency resolution** techniques
5. **Optimize performance** with advanced dependency patterns

### **Advanced Learning Opportunities**
1. **Create custom modules** with dependency-aware interfaces
2. **Implement cross-region dependencies** for disaster recovery
3. **Add automated testing** with dependency validation
4. **Integrate with CI/CD pipelines** for dependency-aware deployments
5. **Implement advanced monitoring** with dependency tracking

---

## 🎯 **Success Criteria**

Upon successful completion, you should have:

- ✅ **Mastered complex dependency management** with 8-tier architecture
- ✅ **Implemented advanced meta-arguments** with count, for_each, lifecycle, depends_on
- ✅ **Designed sophisticated resource relationships** with proper ordering
- ✅ **Optimized resource lifecycle management** with enterprise patterns
- ✅ **Handled dependency conflicts** and circular dependency resolution
- ✅ **Applied advanced resource organization** for scalable infrastructure
- ✅ **Deployed multi-tier application** with complex dependency chains
- ✅ **Validated functionality** through comprehensive testing

---

**Lab Version**: 4.1  
**Last Updated**: January 2025  
**Terraform Version**: ~> 1.13.0  
**AWS Provider Version**: ~> 6.12.0  
**Compatibility**: Multi-platform (Linux, macOS, Windows WSL)
