# Terraform Code Lab 3.1: Core Terraform Operations

## 📋 **Overview**

This Terraform Code Lab demonstrates comprehensive implementation of core Terraform operations including resource lifecycle management, data sources, provisioners, meta-arguments, and enterprise resource organization patterns. The lab provides hands-on experience with advanced Terraform features and real-world infrastructure deployment scenarios.

## 🎯 **Learning Objectives**

By completing this code lab, you will gain practical experience with:

1. **Resource Lifecycle Management** - Complete resource creation, updates, and destruction workflows
2. **Data Source Integration** - Dynamic configuration using AWS data sources and external data
3. **Meta-Argument Implementation** - Advanced resource control using count, for_each, depends_on, and lifecycle
4. **Provisioner Configuration** - Local and remote provisioners for configuration management
5. **Enterprise Organization** - Scalable patterns for production-grade infrastructure management

## 🏗️ **Infrastructure Components**

This lab creates a comprehensive multi-tier AWS infrastructure:

### **Network Infrastructure**
- **VPC**: Custom VPC with DNS support and hostnames enabled
- **Subnets**: Public, private, and database subnets across multiple AZs
- **Gateways**: Internet Gateway and NAT Gateways for connectivity
- **Routing**: Route tables and associations for traffic management
- **Security**: Security groups with tier-specific access controls

### **Compute Infrastructure**
- **Web Servers**: EC2 instances in public subnets with load balancer integration
- **Application Servers**: EC2 instances in private subnets for backend processing
- **Load Balancer**: Application Load Balancer with health checks and target groups
- **Auto Scaling**: Configurable instance counts with lifecycle management

### **Database Infrastructure**
- **RDS Instance**: MySQL database with encryption and backup configuration
- **Subnet Group**: Database subnet group for multi-AZ deployment
- **Security**: Database-specific security group with restricted access

### **Monitoring and Logging**
- **CloudWatch Logs**: Application and system logging (optional)
- **VPC Flow Logs**: Network traffic monitoring and security analysis
- **Monitoring**: Detailed CloudWatch monitoring for all resources

## 📁 **File Structure**

```
Terraform-Code-Lab-3.1/
├── README.md                 # This documentation file
├── providers.tf              # Terraform and provider configuration
├── variables.tf              # Input variable definitions
├── locals.tf                 # Local values and computed configurations
├── data.tf                   # Data sources and external integration
├── main.tf                   # Main infrastructure resources
├── outputs.tf                # Output value definitions
├── terraform.tfvars          # Variable values (example configuration)
├── scripts/                  # User data and configuration scripts
│   ├── web_server.sh         # Web server configuration script
│   ├── app_server.sh         # Application server configuration script
│   └── database.sh           # Database configuration script
└── templates/                # Template files for dynamic configuration
    ├── web_user_data.sh.tpl  # Web server user data template
    ├── app_user_data.sh.tpl  # Application server user data template
    ├── nginx.conf.tpl        # Nginx configuration template
    └── cloudwatch_agent.json.tpl # CloudWatch agent configuration
```

## 🚀 **Quick Start Guide**

### **Prerequisites**
1. **Terraform CLI**: Version ~> 1.13.0 installed and configured
2. **AWS CLI**: Version 2.15.0+ with configured credentials
3. **AWS Account**: Active account with appropriate permissions
4. **SSH Key Pair**: EC2 key pair for instance access

### **Step 1: Clone and Setup**
```bash
# Navigate to the lab directory
cd 03-Core-Terraform-Operations/Terraform-Code-Lab-3.1

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
terraform output -raw load_balancer_configuration | jq -r '.load_balancer.dns_name'

# Test application
curl -s http://$(terraform output -raw load_balancer_configuration | jq -r '.load_balancer.dns_name')

# View all outputs
terraform output
```

## 🔧 **Configuration Options**

### **Environment-Specific Configuration**
```bash
# Development environment
terraform apply -var="environment=dev" -var-file="terraform.tfvars"

# Staging environment
terraform apply -var="environment=staging" -var-file="terraform.tfvars"

# Production environment
terraform apply -var="environment=prod" -var-file="terraform.tfvars"
```

### **Feature Flags**
```hcl
# Enable/disable specific features in terraform.tfvars
feature_flags = {
  enable_auto_scaling      = true
  enable_cloudwatch_logs   = true
  enable_ssl_termination   = false
  enable_waf              = false
  enable_backup_automation = true
  enable_cost_optimization = true
}
```

### **Instance Scaling**
```hcl
# Adjust instance counts in terraform.tfvars
instance_count = {
  web = 3  # Number of web servers
  app = 2  # Number of application servers
}
```

## 🔐 **Security Best Practices**

### **Authentication and Access**
- **IAM Roles**: Use IAM roles instead of access keys where possible
- **MFA**: Enable multi-factor authentication for administrative access
- **Least Privilege**: Apply minimal required permissions
- **Key Management**: Secure SSH key storage and rotation

### **Network Security**
- **Security Groups**: Restrictive rules with specific port and protocol access
- **VPC Flow Logs**: Network traffic monitoring and analysis
- **Private Subnets**: Application and database tiers in private subnets
- **NAT Gateways**: Controlled outbound internet access

### **Data Protection**
- **Encryption**: Database encryption at rest and in transit
- **Backup**: Automated backup with retention policies
- **Secrets Management**: Use AWS Secrets Manager for production passwords
- **Access Logging**: Comprehensive audit trails

## 💰 **Cost Management**

### **Cost Optimization Features**
- **Instance Right-sizing**: Environment-appropriate instance types
- **Resource Scheduling**: Auto-shutdown for development environments
- **Storage Optimization**: Appropriate storage classes and lifecycle policies
- **Monitoring**: Cost tracking and budget alerts

### **Estimated Monthly Costs**
- **Development**: ~$50-75/month
- **Staging**: ~$100-150/month
- **Production**: ~$200-300/month

*Costs vary based on usage, region, and configuration options*

## 🧪 **Testing and Validation**

### **Infrastructure Testing**
```bash
# Validate Terraform configuration
terraform validate

# Check formatting
terraform fmt -check -recursive

# Security scanning (if tools available)
tfsec .
checkov -f main.tf

# Plan validation
terraform plan -detailed-exitcode
```

### **Application Testing**
```bash
# Test load balancer health
LB_DNS=$(terraform output -raw load_balancer_configuration | jq -r '.load_balancer.dns_name')
curl -s http://$LB_DNS/health

# Test individual instances
for instance in $(terraform output -json instance_configuration | jq -r '.web_instances | keys[]'); do
    echo "Testing instance: $instance"
    INSTANCE_IP=$(terraform output -json instance_configuration | jq -r ".web_instances[\"$instance\"].public_ip")
    curl -s http://$INSTANCE_IP --connect-timeout 5 || echo "Instance $instance not accessible"
done
```

### **Database Connectivity**
```bash
# Test database connectivity (from application server)
DB_ENDPOINT=$(terraform output -json database_configuration | jq -r '.connection.endpoint')
echo "Database endpoint: $DB_ENDPOINT"

# Connect via SSH tunnel for testing
ssh -i ~/.ssh/terraform-lab-key.pem -L 3306:$DB_ENDPOINT:3306 ec2-user@<app-server-ip>
```

## 🔄 **Lifecycle Management**

### **Resource Updates**
```bash
# Update specific resources
terraform apply -target=aws_instance.web -var-file="terraform.tfvars.local"

# Replace specific instances
terraform apply -replace=aws_instance.web["web-1"] -var-file="terraform.tfvars.local"

# Update with new AMI
terraform apply -var="force_ami_update=true" -var-file="terraform.tfvars.local"
```

### **State Management**
```bash
# View state
terraform show

# List resources
terraform state list

# Show specific resource
terraform state show aws_vpc.main

# Move resources in state
terraform state mv aws_instance.old aws_instance.new

# Remove from state (without destroying)
terraform state rm aws_instance.temporary
```

## 🧹 **Cleanup**

### **Resource Destruction**
```bash
# Destroy all resources
terraform destroy -var-file="terraform.tfvars.local"

# Selective destruction
terraform destroy -target=aws_instance.web -var-file="terraform.tfvars.local"

# Force destruction (bypass lifecycle protection)
terraform destroy -var-file="terraform.tfvars.local" -auto-approve
```

### **State Cleanup**
```bash
# Clean up local state files
rm -f terraform.tfstate*
rm -f tfplan
rm -rf .terraform/

# Clean up deployment logs
rm -f deployment.log
```

## 📚 **Additional Resources**

### **Documentation**
- [Terraform Core Documentation](https://www.terraform.io/docs/language/index.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### **Training Materials**
- **Concept.md**: Theoretical foundation and best practices
- **Lab-3.md**: Hands-on exercises and guided implementation
- **Test-Your-Understanding-Topic-3.md**: Assessment and validation

### **Community Resources**
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
- [AWS Terraform Examples](https://github.com/hashicorp/terraform-provider-aws/tree/main/examples)
- [Terraform Registry](https://registry.terraform.io/)

---

## 📞 **Support**

For questions or issues with this lab:
1. Review the troubleshooting section in Lab-3.md
2. Check the main training documentation
3. Consult the official Terraform and AWS documentation
4. Follow enterprise development standards and practices

---

*This code lab provides comprehensive, hands-on experience with core Terraform operations, supporting the theoretical concepts covered in Topic 3 and preparing you for advanced infrastructure management scenarios.*
