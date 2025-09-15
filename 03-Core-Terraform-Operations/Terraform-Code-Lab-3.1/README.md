# AWS Terraform Training - Core Terraform Operations

## 🎯 Lab 3.1: Core Workflow and Resource Lifecycle Management

### **Master Terraform's Core Operations with Real-World Infrastructure**

This lab provides hands-on experience with Terraform's core workflow operations (init, plan, apply, destroy), resource lifecycle management, dependency handling, and performance optimization using a complete web application infrastructure.

---

## 📋 **Lab Overview**

### **Learning Objectives**
By completing this lab, you will:

1. **Master the core Terraform workflow** with init, plan, apply, and destroy operations
2. **Implement resource lifecycle management** with creation, updates, and deletion patterns
3. **Configure dependency management** with implicit and explicit dependencies
4. **Optimize Terraform performance** with parallelism and targeting techniques
5. **Handle errors and recovery scenarios** with systematic troubleshooting approaches
6. **Apply enterprise workflow patterns** for production-ready deployments

### **Architecture Deployed**
- **VPC with public and private subnets** across multiple availability zones
- **EC2 instances** with auto-scaling capability and lifecycle management
- **Application Load Balancer** with health checks and target groups
- **S3 bucket** with versioning and encryption for application data
- **CloudWatch monitoring** with log groups and optional VPC flow logs
- **Security groups** with proper ingress and egress rules

### **Duration**: 90-120 minutes
### **Difficulty**: Intermediate
### **Cost**: $0.50 - $1.50/day (with auto-shutdown enabled)

---

## 🏗️ **Infrastructure Architecture**

```
┌─────────────────────────────────────────────────────────────────┐
│                    Core Terraform Operations Lab                │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                      VPC (10.0.0.0/16)                 │    │
│  │  ┌─────────────────┐           ┌─────────────────┐     │    │
│  │  │ Public Subnet   │           │ Private Subnet  │     │    │
│  │  │ 10.0.1.0/24     │           │ 10.0.10.0/24    │     │    │
│  │  │ ┌─────────────┐ │           │                 │     │    │
│  │  │ │ EC2 Web #1  │ │           │                 │     │    │
│  │  │ └─────────────┘ │           │                 │     │    │
│  │  └─────────────────┘           └─────────────────┘     │    │
│  │  ┌─────────────────┐           ┌─────────────────┐     │    │
│  │  │ Public Subnet   │           │ Private Subnet  │     │    │
│  │  │ 10.0.2.0/24     │           │ 10.0.20.0/24    │     │    │
│  │  │ ┌─────────────┐ │           │                 │     │    │
│  │  │ │ EC2 Web #2  │ │           │                 │     │    │
│  │  │ └─────────────┘ │           │                 │     │    │
│  │  └─────────────────┘           └─────────────────┘     │    │
│  │                                                         │    │
│  │  ┌─────────────────────────────────────────────────┐   │    │
│  │  │          Application Load Balancer              │   │    │
│  │  └─────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    External Services                    │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │    │
│  │  │ S3 Bucket   │ │ CloudWatch  │ │ Internet        │   │    │
│  │  │ App Data    │ │ Logs        │ │ Gateway         │   │    │
│  │  └─────────────┘ └─────────────┘ └─────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 **Quick Start Guide**

### **Prerequisites**
- **AWS Account** with appropriate permissions
- **Terraform CLI** installed (version ~> 1.13.0)
- **AWS CLI** configured with credentials
- **Basic understanding** of Terraform concepts from Topics 1-2

### **1. Clone and Setup**
```bash
# Navigate to the lab directory
cd 03-Core-Terraform-Operations/Terraform-Code-Lab-3.1

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit variables with your information
nano terraform.tfvars  # Update student_name and owner_email
```

### **2. Initialize Terraform**
```bash
# Initialize Terraform with provider downloads
terraform init

# Verify initialization
terraform providers
ls -la .terraform/
```

### **3. Plan and Validate**
```bash
# Validate configuration
terraform validate

# Create execution plan
terraform plan

# Save plan to file for review
terraform plan -out=lab.tfplan
terraform show lab.tfplan
```

### **4. Deploy Infrastructure**
```bash
# Apply configuration with confirmation
terraform apply

# Or apply saved plan (no confirmation needed)
terraform apply lab.tfplan

# Monitor progress
terraform apply | tee apply.log
```

### **5. Test and Validate**
```bash
# View outputs
terraform output

# Test web application
curl http://$(terraform output -json | jq -r '.compute_resources.value.instances[0].public_ip')/

# Test load balancer (if enabled)
curl http://$(terraform output -json | jq -r '.load_balancer_configuration.value.load_balancer.dns_name')/
```

### **6. Cleanup**
```bash
# Destroy all resources
terraform destroy

# Verify cleanup
terraform state list
```

---

## 📁 **File Structure and Components**

### **Core Terraform Files**
```
Terraform-Code-Lab-3.1/
├── providers.tf                  # Provider configuration with default tags
├── variables.tf                  # 35+ variables with comprehensive validation
├── main.tf                      # Complete infrastructure resources
├── outputs.tf                   # 15+ outputs with troubleshooting info
├── terraform.tfvars.example     # Multiple scenario configurations
├── scripts/                     # Supporting scripts
│   └── user_data.sh             # EC2 instance initialization script
└── README.md                    # This comprehensive documentation
```

### **Key Infrastructure Components**

#### **1. Networking Infrastructure**
- **VPC** with DNS support and proper CIDR allocation
- **Public and private subnets** across multiple availability zones
- **Internet Gateway** with proper routing configuration
- **Route tables** with public and private routing
- **Security groups** with least privilege access rules

#### **2. Compute Resources**
- **EC2 instances** with count meta-argument for scaling
- **Application Load Balancer** with health checks and target groups
- **Auto-scaling capability** (optional) for production scenarios
- **User data scripts** for automated application deployment

#### **3. Storage and Data**
- **S3 bucket** with versioning and encryption
- **EBS volumes** with GP3 optimization and encryption
- **CloudWatch log groups** for monitoring and troubleshooting

#### **4. Security and Compliance**
- **Security groups** with granular access control
- **Encryption at rest** for all storage resources
- **IAM roles** for service-to-service communication
- **VPC Flow Logs** (optional) for network monitoring

#### **5. Monitoring and Observability**
- **CloudWatch integration** for metrics and logs
- **Health check endpoints** for load balancer monitoring
- **Custom metrics** and alerting capabilities
- **Cost optimization** with auto-shutdown features

---

## ⚙️ **Configuration Scenarios**

### **Scenario 1: Basic Lab Setup (Default)**
```hcl
instance_count = 2
instance_type = "t3.micro"
enable_load_balancer = true
create_s3_bucket = true
auto_shutdown_enabled = true
auto_shutdown_hours = 4
```
**Use Case**: Individual learning and basic testing
**Estimated Cost**: $0.50-$1.00/day

### **Scenario 2: Enhanced Monitoring**
```hcl
monitoring_enabled = true
enable_vpc_flow_logs = true
log_retention_days = 14
enable_detailed_monitoring = true
```
**Use Case**: Advanced monitoring and troubleshooting practice
**Estimated Cost**: $1.00-$1.50/day

### **Scenario 3: Production-Like Environment**
```hcl
environment = "production"
instance_type = "t3.small"
instance_count = 3
enable_nat_gateway = true
backup_required = true
cost_optimization_level = "moderate"
```
**Use Case**: Enterprise patterns and production readiness
**Estimated Cost**: $3.00-$5.00/day

### **Scenario 4: Minimal Cost Configuration**
```hcl
instance_count = 1
enable_load_balancer = false
create_s3_bucket = false
monitoring_enabled = false
auto_shutdown_hours = 1
```
**Use Case**: Cost-conscious learning and basic operations
**Estimated Cost**: $0.10-$0.30/day

---

## 🔧 **Core Terraform Operations Testing**

### **1. Initialization and Planning**
```bash
# Test initialization
terraform init
terraform init -upgrade
terraform init -reconfigure

# Test planning
terraform plan
terraform plan -out=test.tfplan
terraform plan -target=aws_instance.web
terraform plan -var="instance_count=3"
```

### **2. Apply Operations**
```bash
# Test apply operations
terraform apply
terraform apply test.tfplan
terraform apply -target=aws_instance.web[0]
terraform apply -auto-approve
```

### **3. State Management**
```bash
# Test state operations
terraform state list
terraform state show aws_instance.web[0]
terraform refresh
terraform state rm aws_instance.web[2]
terraform import 'aws_instance.web[2]' i-1234567890abcdef0
```

### **4. Resource Lifecycle Testing**
```bash
# Test lifecycle management
# Modify instance_count in terraform.tfvars
terraform plan  # Shows planned changes
terraform apply  # Applies changes

# Test create_before_destroy
# Change instance_type in terraform.tfvars
terraform plan  # Shows replacement strategy
terraform apply  # Executes replacement
```

### **5. Dependency Testing**
```bash
# Test dependency resolution
terraform graph | dot -Tpng > dependencies.png

# Test targeted operations
terraform apply -target=aws_vpc.main
terraform apply -target=aws_subnet.public
terraform apply -target=aws_instance.web
```

### **6. Performance Optimization**
```bash
# Test parallelism
time terraform plan
terraform apply -parallelism=20
time terraform apply -parallelism=20

# Test resource targeting
terraform apply -target=aws_instance.web -parallelism=10
```

---

## 🔍 **Troubleshooting Guide**

### **Common Issues and Solutions**

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Initialization Failed** | Provider download errors | Check internet connectivity and run `terraform init -upgrade` |
| **Plan Generation Failed** | Validation errors | Run `terraform validate` and fix configuration issues |
| **Apply Failed** | Resource creation errors | Check AWS permissions and resource limits |
| **State Lock Timeout** | Lock acquisition failed | Check for concurrent operations or use `terraform force-unlock` |
| **Instance Not Accessible** | HTTP connection timeout | Verify security groups and internet gateway configuration |
| **Load Balancer 503 Error** | Service unavailable | Check target group health and instance status |

### **Debugging Commands**
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH="./terraform.log"

# Validate configuration
terraform validate
terraform fmt -check

# Check AWS resources
aws ec2 describe-instances --filters "Name=tag:Project,Values=core-terraform-operations"
aws elbv2 describe-load-balancers
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Check Terraform state
terraform state list
terraform state show aws_instance.web[0]
terraform refresh
```

---

## 📊 **Cost Optimization Features**

### **1. Automated Cost Controls**
- **Auto-shutdown after specified hours**: Prevents runaway costs
- **Right-sized instances**: t3.micro for cost efficiency
- **GP3 EBS volumes**: Better price/performance ratio
- **Pay-per-request DynamoDB**: No fixed costs for state locking

### **2. Cost Monitoring**
```bash
# View cost optimization settings
terraform output cost_optimization_info

# Monitor resource costs
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost
```

### **3. Resource Cleanup**
```bash
# Automated cleanup with auto-shutdown
# Manual cleanup
terraform destroy

# Verify cleanup
aws ec2 describe-instances --filters "Name=tag:Project,Values=core-terraform-operations"
```

---

## 📚 **Learning Resources and Next Steps**

### **Immediate Next Steps**
1. **Practice all core operations** multiple times with different configurations
2. **Experiment with resource targeting** and partial deployments
3. **Test error scenarios** and recovery procedures
4. **Optimize performance** with parallelism and caching
5. **Implement monitoring** and observability practices

### **Advanced Learning Opportunities**
1. **Implement remote state backend** for team collaboration
2. **Create custom modules** for reusable infrastructure patterns
3. **Integrate with CI/CD pipelines** for automated deployments
4. **Add automated testing** with Terratest or similar tools
5. **Implement advanced lifecycle management** with complex dependencies

### **Recommended Reading**
- [Terraform Core Workflow](https://developer.hashicorp.com/terraform/intro/core-workflow)
- [Resource Lifecycle](https://developer.hashicorp.com/terraform/language/resources/behavior)
- [Terraform State](https://developer.hashicorp.com/terraform/language/state)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## 🎯 **Success Criteria**

Upon successful completion, you should have:

- ✅ **Mastered core Terraform workflow** with all four primary operations
- ✅ **Implemented resource lifecycle management** with creation, updates, and deletion
- ✅ **Configured dependency management** with both implicit and explicit patterns
- ✅ **Optimized performance** using parallelism and resource targeting
- ✅ **Handled error scenarios** with systematic recovery approaches
- ✅ **Applied enterprise patterns** for production-ready workflows
- ✅ **Deployed complete infrastructure** with networking, compute, and storage
- ✅ **Validated functionality** through comprehensive testing

---

**Lab Version**: 3.1  
**Last Updated**: January 2025  
**Terraform Version**: ~> 1.13.0  
**AWS Provider Version**: ~> 6.12.0  
**Compatibility**: Multi-platform (Linux, macOS, Windows WSL)
