# Terraform Code Lab 1.1 - Infrastructure as Code Concepts & AWS Integration

## 🎯 **Lab Overview**

This directory contains complete, production-ready Terraform code for **Lab 1.1: Infrastructure as Code Concepts & AWS Integration**. The implementation demonstrates enterprise-grade Infrastructure as Code practices with a three-tier web application architecture on AWS.

### **Learning Objectives**
- Deploy AWS infrastructure using Terraform with latest versions (1.13.0 + AWS Provider 6.12.0)
- Implement security best practices and cost optimization strategies
- Configure monitoring, logging, and operational excellence
- Understand Infrastructure as Code principles through hands-on implementation

---

## 🏗️ **Architecture Overview**

### **Three-Tier Architecture Components**

#### **Web Tier (Public Subnets)**
- Application Load Balancer (ALB) with health checks
- SSL termination and traffic distribution
- Public internet access and CDN integration ready

#### **Application Tier (Private Subnets)**
- Auto Scaling Group with EC2 instances
- Apache web servers with custom application
- CloudWatch monitoring and logging
- IAM roles with least privilege access

#### **Data Tier (Database Subnets)**
- RDS MySQL instance with automated backups
- Multi-AZ deployment option for high availability
- Encryption at rest and security group isolation
- Performance Insights for optimization

#### **Supporting Infrastructure**
- VPC with DNS resolution and hostnames
- NAT Gateways for private subnet internet access
- S3 bucket with lifecycle policies and encryption
- CloudWatch logs and metrics collection
- Comprehensive tagging for cost allocation

---

## 📁 **File Structure and Purpose**

```
Terraform-Code-Lab-1.1/
├── providers.tf              # Provider configuration and version constraints
├── variables.tf               # Input variables with validation and documentation
├── main.tf                   # Core infrastructure resources and configuration
├── outputs.tf                # Output values for integration and troubleshooting
├── terraform.tfvars.example  # Example variable values and configurations
├── user_data.sh              # EC2 instance initialization and application setup
└── README.md                 # This comprehensive documentation
```

### **File Descriptions**

#### **providers.tf**
- Terraform and AWS provider version constraints (~> 1.13.0, ~> 6.12.0)
- Default tags for consistent resource management
- Backend configuration for state management
- Provider validation and information gathering

#### **variables.tf**
- 40+ input variables with comprehensive validation
- Enterprise-grade configuration options
- Security, cost, and operational parameters
- Detailed descriptions and examples

#### **main.tf**
- Complete three-tier architecture implementation
- Networking (VPC, subnets, gateways, routing)
- Security (security groups, IAM roles, encryption)
- Compute (ALB, Auto Scaling, EC2 instances)
- Storage (S3 bucket with lifecycle policies)
- Database (RDS with backup and monitoring)
- Monitoring (CloudWatch logs and metrics)

#### **outputs.tf**
- 25+ output values for operational visibility
- Network, security, and application endpoints
- Cost estimation and optimization information
- Integration points and troubleshooting data

#### **terraform.tfvars.example**
- Example configurations for different environments
- Cost optimization settings and best practices
- Security and compliance configuration options
- Detailed comments and usage instructions

#### **user_data.sh**
- Automated EC2 instance configuration
- Apache web server setup and security hardening
- CloudWatch agent installation and configuration
- Application deployment and health checks
- Comprehensive logging and monitoring setup

---

## 🚀 **Quick Start Guide**

### **Prerequisites**
- AWS CLI configured with appropriate permissions
- Terraform ~> 1.13.0 installed
- Basic understanding of AWS services and networking

### **Deployment Steps**

#### **1. Clone and Navigate**
```bash
# Navigate to the lab directory
cd 01-Infrastructure-as-Code-Concepts-AWS-Integration/Terraform-Code-Lab-1.1
```

#### **2. Configure Variables**
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration for your environment
nano terraform.tfvars
```

#### **3. Initialize Terraform**
```bash
# Initialize Terraform and download providers
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt
```

#### **4. Plan and Deploy**
```bash
# Review planned changes
terraform plan -var-file="terraform.tfvars"

# Deploy infrastructure
terraform apply -var-file="terraform.tfvars"
```

#### **5. Verify Deployment**
```bash
# Get application URL
terraform output application_url

# Test application
curl -I $(terraform output -raw application_url)

# Check Auto Scaling Group health
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names $(terraform output -raw auto_scaling_group_name)
```

---

## 💰 **Cost Management**

### **Estimated Monthly Costs**

#### **Development Environment**
- **EC2 Instances (2x t3.micro)**: ~$17.00
- **RDS (1x db.t3.micro)**: ~$12.50
- **Application Load Balancer**: ~$16.20
- **NAT Gateways (2)**: ~$64.80
- **S3 Storage and Requests**: ~$2.00
- **Data Transfer**: ~$5.00
- **Total**: ~$117.50/month

#### **Cost Optimization Features**
- Auto-shutdown scheduling for non-production environments
- S3 lifecycle policies (IA after 30 days, Glacier after 90 days)
- Right-sized instance types for workload requirements
- Comprehensive cost allocation tags
- Budget alerts and monitoring

### **Cost Reduction Strategies**
```bash
# Enable single NAT Gateway for development
single_nat_gateway = true  # Saves ~$32.40/month

# Use smaller instance types
instance_type = "t3.micro"
db_instance_class = "db.t3.micro"

# Enable auto-shutdown
auto_shutdown_enabled = true
auto_shutdown_schedule = "0 22 * * MON-FRI"
```

---

## 🔒 **Security Features**

### **Network Security**
- VPC isolation with private subnets for application and database tiers
- Security groups with least privilege access
- NAT Gateways for controlled internet access
- Network ACLs for additional security layers

### **Data Protection**
- Encryption at rest for S3 and RDS
- Encryption in transit with HTTPS/TLS
- S3 bucket public access blocking
- Database password generation and management

### **Access Control**
- IAM roles with minimal required permissions
- Instance profiles for secure AWS service access
- Security group rules based on application requirements
- CloudTrail logging for audit and compliance

### **Compliance Features**
```hcl
# Enable compliance features
data_classification = "internal"
compliance_scope = "soc2"
enable_cloudtrail = true
backup_required = "yes"
```

---

## 📊 **Monitoring and Observability**

### **CloudWatch Integration**
- Custom metrics namespace: `IaC-Lab-1/{project_name}`
- EC2 instance metrics (CPU, memory, disk, network)
- Application Load Balancer metrics and health checks
- RDS performance metrics and slow query logs

### **Logging Configuration**
- Apache access and error logs
- Application deployment and configuration logs
- CloudWatch log groups with configurable retention
- Centralized log aggregation and analysis

### **Health Checks and Alarms**
- ALB target group health checks
- Auto Scaling Group health monitoring
- RDS instance monitoring and alerting
- Custom application health endpoints

---

## 🔧 **Customization and Extension**

### **Environment-Specific Configurations**

#### **Development Environment**
```hcl
environment = "dev"
instance_type = "t3.micro"
min_size = 1
max_size = 2
desired_capacity = 1
single_nat_gateway = true
auto_shutdown_enabled = true
```

#### **Production Environment**
```hcl
environment = "prod"
instance_type = "t3.medium"
min_size = 2
max_size = 6
desired_capacity = 3
db_multi_az = true
enable_performance_insights = true
monitoring_level = "comprehensive"
```

### **Adding Custom Resources**
```hcl
# Example: Add CloudFront distribution
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "ALB-${local.name_prefix}"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  # Additional CloudFront configuration...
}
```

---

## 🧪 **Testing and Validation**

### **Automated Testing**
```bash
# Infrastructure validation
terraform validate
terraform plan -detailed-exitcode

# Application testing
curl -f $(terraform output -raw application_url)
curl -f $(terraform output -raw application_url)/health/

# Security testing
aws ec2 describe-security-groups \
    --group-ids $(terraform output -raw web_security_group_id)
```

### **Manual Verification Checklist**
- [ ] Application accessible via load balancer URL
- [ ] Health checks passing for all targets
- [ ] Auto Scaling Group instances healthy
- [ ] Database connectivity from application tier
- [ ] S3 bucket accessible with proper permissions
- [ ] CloudWatch logs and metrics flowing
- [ ] Security groups configured correctly
- [ ] Cost allocation tags applied consistently

---

## 🔄 **Maintenance and Updates**

### **Regular Maintenance Tasks**
- Update Terraform and provider versions quarterly
- Review and rotate database passwords
- Monitor cost trends and optimize resources
- Update security group rules as needed
- Review and update backup retention policies

### **Upgrade Procedures**
```bash
# Update provider versions
terraform init -upgrade

# Plan with new versions
terraform plan -var-file="terraform.tfvars"

# Apply updates
terraform apply -var-file="terraform.tfvars"
```

---

## 🧹 **Cleanup Instructions**

### **Complete Infrastructure Removal**
```bash
# Destroy all resources
terraform destroy -var-file="terraform.tfvars"

# Verify cleanup
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=iac-lab-1"
aws s3 ls | grep iac-lab-1

# Clean up Terraform state
rm -f terraform.tfstate*
rm -rf .terraform/
```

### **Selective Resource Removal**
```bash
# Remove specific resources
terraform destroy -target=aws_autoscaling_group.web
terraform destroy -target=aws_db_instance.main
```

---

## 📚 **Additional Resources**

### **Documentation Links**
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### **Related Training Materials**
- `../Concept.md` - Theoretical foundation and business value
- `../Lab-1.md` - Step-by-step implementation guide
- `../Test-Your-Understanding-Topic-1.md` - Assessment and validation
- `../DaC/` - Professional architectural diagrams

---

## 🆘 **Troubleshooting**

### **Common Issues and Solutions**

#### **Terraform Initialization Errors**
```bash
# Clear cache and reinitialize
rm -rf .terraform/
terraform init
```

#### **AWS Permission Errors**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check IAM permissions
aws iam simulate-principal-policy \
    --policy-source-arn $(aws sts get-caller-identity --query Arn --output text) \
    --action-names ec2:CreateVpc
```

#### **Resource Limit Errors**
```bash
# Check service limits
aws service-quotas get-service-quota \
    --service-code ec2 \
    --quota-code L-1216C47A  # Running On-Demand instances
```

### **Support and Community**
- GitHub Issues for bug reports and feature requests
- AWS Community Forums for AWS-specific questions
- HashiCorp Community for Terraform best practices
- Training platform support for educational assistance

---

**🎯 This comprehensive Terraform implementation provides a solid foundation for understanding Infrastructure as Code principles while demonstrating enterprise-grade AWS architecture patterns, security best practices, and operational excellence.**
