# Terraform Code Lab 4.1: Resource Management & Dependencies

## 📋 **Overview**

This Terraform Code Lab demonstrates advanced resource management and dependency patterns for enterprise-scale infrastructure. The lab implements a comprehensive multi-tier financial services platform showcasing complex dependency relationships, advanced lifecycle management, meta-argument patterns, and sophisticated resource targeting strategies.

## 🎯 **Learning Objectives**

By completing this code lab, you will gain hands-on experience with:

1. **Complex Dependency Management** - Implementing intricate implicit and explicit dependency relationships
2. **Advanced Lifecycle Control** - Managing sophisticated lifecycle patterns for zero-downtime deployments
3. **Meta-Argument Mastery** - Utilizing advanced meta-argument combinations for complex resource scenarios
4. **Resource Targeting Strategies** - Executing precise, selective operations for efficient infrastructure management
5. **Enterprise Organization** - Implementing scalable patterns for production-grade infrastructure management

## 🏗️ **Infrastructure Components**

This lab creates a comprehensive multi-tier AWS infrastructure:

### **Network Infrastructure (Foundation Tier)**
- **VPC**: Custom VPC with DNS support and multi-AZ design
- **Subnets**: Public, private, and database subnets across 3 availability zones
- **Gateways**: Internet Gateway and NAT Gateways for connectivity
- **Routing**: Route tables and associations for traffic management
- **Security**: Comprehensive security groups with tier-specific access controls

### **Application Infrastructure (Application Tier)**
- **Web Tier**: Auto Scaling Group with Application Load Balancer integration
- **API Tier**: Private subnet deployment with database connectivity
- **Worker Tier**: Background processing with queue integration
- **Load Balancer**: Application Load Balancer with health checks and target groups
- **Launch Templates**: Versioned templates with rolling update capabilities

### **Data Infrastructure (Data Tier)**
- **RDS Instance**: MySQL database with encryption, backup, and monitoring
- **ElastiCache**: Redis cluster for caching (conditional)
- **Subnet Groups**: Database and cache subnet groups for multi-AZ deployment
- **Encryption**: KMS keys for database and backup encryption

### **Security Infrastructure (Security Tier)**
- **Security Groups**: Tier-specific security groups with dynamic rules
- **Cross-SG Rules**: Complex security group rule dependencies
- **KMS Keys**: Encryption keys for data protection
- **IAM Integration**: Service roles and policies (referenced)

## 📁 **File Structure**

```
Terraform-Code-Lab-4.1/
├── README.md                 # This documentation file
├── providers.tf              # Terraform and provider configuration
├── variables.tf              # Comprehensive variable definitions
├── locals.tf                 # Local values and computed configurations
├── data.tf                   # Data sources and external integration
├── main.tf                   # Main infrastructure resources
├── outputs.tf                # Structured output definitions
└── terraform.tfvars          # Example variable values
```

## 🚀 **Quick Start Guide**

### **Prerequisites**
1. **Terraform CLI**: Version ~> 1.13.0 installed and configured
2. **AWS CLI**: Version 2.15.0+ with configured credentials
3. **AWS Account**: Active account with administrative permissions
4. **SSH Key Pair**: EC2 key pair for instance access

### **Step 1: Setup and Configuration**
```bash
# Navigate to the lab directory
cd 04-Resource-Management-Dependencies/Terraform-Code-Lab-4.1

# Copy example variables file
cp terraform.tfvars terraform.tfvars.local

# Edit variables for your environment
nano terraform.tfvars.local
```

### **Step 2: Configure AWS Authentication**
```bash
# Option 1: AWS CLI Profile
aws configure --profile terraform-lab
export AWS_PROFILE=terraform-lab

# Option 2: Environment Variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Verify authentication
aws sts get-caller-identity
```

### **Step 3: Create SSH Key Pair**
```bash
# Create EC2 key pair if it doesn't exist
aws ec2 create-key-pair --key-name terraform-lab-key --query 'KeyMaterial' --output text > ~/.ssh/terraform-lab-key.pem
chmod 400 ~/.ssh/terraform-lab-key.pem

# Verify key pair exists
aws ec2 describe-key-pairs --key-names terraform-lab-key
```

### **Step 4: Initialize and Deploy**
```bash
# Initialize Terraform working directory
terraform init

# Validate configuration
terraform validate

# Format configuration files
terraform fmt -recursive

# Generate execution plan
terraform plan -var-file="terraform.tfvars.local"

# Apply configuration (after reviewing plan)
terraform apply -var-file="terraform.tfvars.local"
```

### **Step 5: Verify Deployment**
```bash
# List created resources
terraform state list

# Get load balancer URL
terraform output -raw load_balancer_configuration

# Test application endpoints
LB_DNS=$(terraform output -json load_balancer_configuration | jq -r '.load_balancer.dns_name')
curl -s http://$LB_DNS/health

# View dependency analysis
terraform output dependency_analysis
```

## 🔧 **Advanced Configuration Options**

### **Environment-Specific Deployment**
```bash
# Development environment
terraform apply -var="environment=dev" -var-file="terraform.tfvars.local"

# Staging environment
terraform apply -var="environment=staging" -var-file="terraform.tfvars.local"

# Production environment
terraform apply -var="environment=prod" -var-file="terraform.tfvars.local"
```

### **Feature Flag Configuration**
```hcl
# Enable/disable specific features in terraform.tfvars.local
feature_flags = {
  enable_monitoring     = true
  enable_backup        = true
  enable_redis_cache   = true
  enable_queue         = true
  enable_waf           = false
  enable_cdn           = false
}
```

### **Application Scaling Configuration**
```hcl
# Adjust application configurations in terraform.tfvars.local
applications = {
  web = {
    instance_type    = "t3.medium"
    desired_capacity = 3
    max_capacity     = 10
    # ... other configuration
  }
  # ... other applications
}
```

## 🎯 **Resource Targeting Examples**

### **Selective Deployment**
```bash
# Deploy only network infrastructure
terraform apply -target=aws_vpc.main -target=aws_subnet.public -target=aws_subnet.private

# Deploy only security infrastructure
terraform apply -target=aws_security_group.main

# Deploy specific application tier
terraform apply -target=aws_autoscaling_group.apps["web"]

# Deploy database infrastructure
terraform apply -target=aws_db_instance.main
```

### **Rolling Updates**
```bash
# Update launch template for web tier
terraform apply -target=aws_launch_template.apps["web"]

# Trigger instance refresh
aws autoscaling start-instance-refresh \
    --auto-scaling-group-name $(terraform output -json application_configuration | jq -r '.auto_scaling_groups.web.name')
```

## 🔍 **Dependency Analysis**

### **Generate Dependency Graph**
```bash
# Generate dependency graph
terraform graph > dependency_graph.dot

# Convert to PNG (requires Graphviz)
dot -Tpng dependency_graph.dot -o dependency_graph.png

# View dependency analysis
terraform output dependency_analysis
```

### **Analyze Resource Dependencies**
```bash
# List resources by dependency tier
terraform state list | grep -E "(vpc|subnet|security_group|db_instance|autoscaling_group)"

# Show specific resource dependencies
terraform state show aws_autoscaling_group.apps[\"api\"]

# Analyze implicit dependencies
grep -r "aws_.*\." *.tf | grep -v "data\." | head -10
```

## 🧪 **Testing and Validation**

### **Infrastructure Testing**
```bash
# Validate Terraform configuration
terraform validate

# Check formatting
terraform fmt -check -recursive

# Plan validation
terraform plan -detailed-exitcode

# Dependency graph validation
terraform graph | grep -E "digraph|->|}" | head -20
```

### **Application Testing**
```bash
# Test load balancer health
LB_DNS=$(terraform output -json load_balancer_configuration | jq -r '.load_balancer.dns_name')
curl -s http://$LB_DNS/health

# Test application endpoints
for app in web api worker; do
    echo "Testing $app endpoint..."
    curl -s http://$LB_DNS/$(terraform output -json load_balancer_configuration | jq -r ".endpoints.health_check_urls.$app" | sed 's|.*://[^/]*||')
done
```

### **Database Connectivity**
```bash
# Get database endpoint
DB_ENDPOINT=$(terraform output -json database_configuration | jq -r '.connection.endpoint')
echo "Database endpoint: $DB_ENDPOINT"

# Test connectivity (from application server)
# Note: Requires SSH access to application instances
```

## 🔄 **Lifecycle Management Examples**

### **Zero-Downtime Updates**
```bash
# Update application with create_before_destroy
terraform apply -target=aws_launch_template.apps["api"]

# Monitor instance refresh
aws autoscaling describe-instance-refreshes \
    --auto-scaling-group-name $(terraform output -json application_configuration | jq -r '.auto_scaling_groups.api.name')
```

### **Database Protection**
```bash
# Attempt to destroy protected database (will fail)
terraform destroy -target=aws_db_instance.main

# Remove protection and destroy (if needed)
# Edit main.tf to set prevent_destroy = false
terraform apply -target=aws_db_instance.main
terraform destroy -target=aws_db_instance.main
```

## 🧹 **Cleanup**

### **Selective Cleanup**
```bash
# Destroy application infrastructure first
terraform destroy -target=aws_autoscaling_group.apps

# Destroy load balancer
terraform destroy -target=aws_lb.main

# Remove database protection and destroy
# Edit main.tf to set prevent_destroy = false
terraform apply -target=aws_db_instance.main
terraform destroy -target=aws_db_instance.main

# Destroy remaining infrastructure
terraform destroy
```

### **Complete Cleanup**
```bash
# Remove lifecycle protection from database
sed -i 's/prevent_destroy = true/prevent_destroy = false/' main.tf
terraform apply -target=aws_db_instance.main

# Destroy all resources
terraform destroy -var-file="terraform.tfvars.local" -auto-approve

# Clean up local files
rm -f terraform.tfstate*
rm -f tfplan
rm -rf .terraform/
```

## 📊 **Key Features Demonstrated**

### **Dependency Management**
- ✅ Complex implicit dependencies between VPC, subnets, and security groups
- ✅ Explicit dependencies using `depends_on` for proper resource ordering
- ✅ Cross-resource dependencies with security group rules
- ✅ Multi-tier dependency relationships (network → security → data → application)

### **Lifecycle Management**
- ✅ `create_before_destroy` for zero-downtime updates
- ✅ `prevent_destroy` for critical database protection
- ✅ `ignore_changes` for externally managed attributes
- ✅ Instance refresh for rolling updates

### **Meta-Arguments**
- ✅ `for_each` for complex application configurations
- ✅ `count` for availability zone-based resources
- ✅ `depends_on` for explicit dependency management
- ✅ `lifecycle` rules for production-grade resource management

### **Resource Targeting**
- ✅ Single resource targeting for precise operations
- ✅ Multiple resource targeting for coordinated updates
- ✅ Tier-based targeting for infrastructure layers
- ✅ Application-specific targeting for selective deployments

## 📚 **Additional Resources**

### **Documentation**
- [Terraform Resource Dependencies](https://www.terraform.io/docs/language/resources/behavior.html#resource-dependencies)
- [Meta-Arguments](https://www.terraform.io/docs/language/meta-arguments/index.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### **Training Materials**
- **Concept.md**: Theoretical foundation and advanced patterns
- **Lab-4.md**: Comprehensive hands-on exercises and scenarios
- **Test-Your-Understanding-Topic-4.md**: Assessment and validation

---

## 📞 **Support**

For questions or issues with this code lab:
1. Review the troubleshooting section in Lab-4.md
2. Check the dependency analysis outputs
3. Consult the official Terraform and AWS documentation
4. Follow enterprise development standards and practices

---

*This code lab provides comprehensive, hands-on experience with advanced resource management and dependency patterns, directly supporting the theoretical concepts covered in Topic 4 and preparing you for enterprise-scale infrastructure management.*
