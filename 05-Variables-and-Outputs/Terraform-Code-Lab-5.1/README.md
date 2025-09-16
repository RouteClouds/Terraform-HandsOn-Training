# Terraform Code Lab 5.1: Advanced Variables and Outputs

## 🎯 **Lab Overview**

This hands-on code lab demonstrates advanced Terraform variable and output management patterns through a comprehensive enterprise-scale infrastructure deployment. You'll implement sophisticated variable validation, complex output structures, local value optimization, and enterprise governance patterns.

## 📋 **Lab Objectives**

By completing this lab, you will:

1. **Implement Advanced Variable Types** - Create comprehensive variable definitions with complex validation rules
2. **Design Sophisticated Output Patterns** - Build advanced output structures for cross-module integration
3. **Optimize Local Value Usage** - Leverage local values for performance and maintainability
4. **Master Variable Precedence** - Implement enterprise configuration hierarchy and precedence management
5. **Apply Governance Frameworks** - Establish enterprise-grade variable governance and compliance patterns

## 🏗️ **Infrastructure Architecture**

This lab deploys a complete enterprise infrastructure including:

- **Network Layer**: VPC with public, private, and database subnets across multiple AZs
- **Compute Layer**: Auto Scaling Groups with Application Load Balancer
- **Database Layer**: RDS MySQL with Multi-AZ configuration
- **Security Layer**: Security Groups, NACLs, and IAM roles
- **Monitoring Layer**: CloudWatch dashboards and alarms

## 📁 **File Structure**

```
Terraform-Code-Lab-5.1/
├── README.md                 # This documentation
├── providers.tf              # Provider configuration and versions
├── variables.tf              # Comprehensive variable definitions
├── locals.tf                 # Local value computations and optimizations
├── main.tf                   # Primary infrastructure resources
├── data.tf                   # Data source definitions
├── outputs.tf                # Advanced output patterns
├── terraform.tfvars          # Development environment variables
└── versions.tf               # Terraform and provider version constraints
```

## 🚀 **Getting Started**

### **Prerequisites**
- Terraform CLI v1.13.0+
- AWS CLI configured with appropriate permissions
- AWS account with administrative access
- Git for version control

### **Setup Instructions**

1. **Clone and Navigate**
```bash
cd 05-Variables-and-Outputs/Terraform-Code-Lab-5.1
```

2. **Initialize Terraform**
```bash
terraform init
```

3. **Validate Configuration**
```bash
terraform validate
```

4. **Review Plan**
```bash
terraform plan
```

5. **Apply Configuration**
```bash
terraform apply
```

## 🔧 **Key Learning Components**

### **1. Advanced Variable Validation**
- Complex object validation with nested rules
- Cross-field validation dependencies
- Conditional validation based on environment
- Comprehensive error messaging

### **2. Sophisticated Output Patterns**
- Hierarchical output structures
- Cross-module integration patterns
- Sensitive data handling
- Computed value transformations

### **3. Local Value Optimization**
- Performance-optimized computations
- Reusable value patterns
- Complex data transformations
- Error-safe operations

### **4. Enterprise Governance**
- Naming convention enforcement
- Compliance validation rules
- Audit trail requirements
- Change management patterns

## 📊 **Variable Categories**

### **Organization Configuration**
- Global organization settings
- Compliance and governance requirements
- Security baseline configurations
- Cost management parameters

### **Environment Configuration**
- Environment-specific settings
- Resource sizing and scaling
- Feature flag management
- Monitoring and alerting levels

### **Application Configuration**
- Application metadata and versioning
- Infrastructure requirements
- Security and compliance settings
- Monitoring and logging configuration

### **Network Configuration**
- VPC and subnet definitions
- Gateway and routing configuration
- Security group and NACL rules
- DNS and connectivity settings

### **Database Configuration**
- Engine and version specifications
- Performance and monitoring settings
- Backup and recovery configuration
- Security and encryption requirements

## 📤 **Output Categories**

### **Network Outputs**
- VPC and subnet information
- Gateway and routing details
- Security group configurations
- DNS and connectivity data

### **Compute Outputs**
- Instance and scaling group details
- Load balancer configurations
- Application endpoint information
- Health check and monitoring data

### **Database Outputs**
- Connection information (sensitive)
- Performance metrics
- Backup and recovery details
- Security configuration status

### **Integration Outputs**
- Cross-module data passing
- External system integration
- API endpoint configurations
- Monitoring and alerting setup

## 🔍 **Validation and Testing**

### **Variable Validation Tests**
```bash
# Test valid configuration
terraform validate

# Test invalid environment
terraform plan -var="environment=invalid"
# Expected: Validation error

# Test invalid CIDR
terraform plan -var='network_configuration={vpc={cidr_block="invalid"}}'
# Expected: CIDR validation error

# Test invalid email
terraform plan -var='applications={test={metadata={team_email="invalid"}}}'
# Expected: Email validation error
```

### **Output Verification**
```bash
# View all outputs
terraform output

# View specific output
terraform output network_configuration

# View sensitive outputs
terraform output -json | jq '.database_connection.value'
```

### **Local Value Testing**
```bash
# Test local value computations
terraform console
> local.computed_configurations
> local.performance_metrics
> local.cost_analysis
```

## 🎓 **Learning Exercises**

### **Exercise 1: Variable Validation**
1. Modify the environment variable to an invalid value
2. Observe the validation error message
3. Fix the validation and test again

### **Exercise 2: Output Transformation**
1. Add a new computed output for cost estimation
2. Include multiple data transformations
3. Test the output with different configurations

### **Exercise 3: Local Value Optimization**
1. Identify repeated computations in the configuration
2. Extract them to local values
3. Measure the performance improvement

### **Exercise 4: Governance Implementation**
1. Add new compliance validation rules
2. Implement naming convention enforcement
3. Test with non-compliant configurations

## 🔧 **Customization Guide**

### **Adding New Variables**
1. Define the variable in `variables.tf`
2. Add comprehensive validation rules
3. Document usage and dependencies
4. Update `terraform.tfvars` with example values

### **Creating New Outputs**
1. Define the output in `outputs.tf`
2. Structure data for maximum utility
3. Handle sensitive information appropriately
4. Test with different configurations

### **Optimizing Local Values**
1. Identify computation patterns
2. Extract to reusable local values
3. Optimize for performance
4. Validate error handling

## 🚨 **Troubleshooting**

### **Common Issues**

**Validation Errors**
- Check variable types and constraints
- Verify CIDR block formats
- Validate email address formats
- Ensure enum values are from allowed lists

**Output Errors**
- Verify resource dependencies
- Check for circular references
- Ensure sensitive data is properly marked
- Validate computed expressions

**Local Value Issues**
- Check for undefined variables
- Verify function syntax
- Test error handling with try() and can()
- Validate complex transformations

### **Debug Commands**
```bash
# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# Debug with console
terraform console

# Detailed logging
TF_LOG=DEBUG terraform plan
```

## 📚 **Additional Resources**

- [Terraform Variable Documentation](https://www.terraform.io/docs/language/values/variables.html)
- [Terraform Output Documentation](https://www.terraform.io/docs/language/values/outputs.html)
- [Terraform Local Values](https://www.terraform.io/docs/language/values/locals.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🎯 **Success Criteria**

Upon completion, you should be able to:
- ✅ Implement complex variable validation patterns
- ✅ Design sophisticated output structures
- ✅ Optimize local value usage for performance
- ✅ Apply enterprise governance frameworks
- ✅ Handle variable precedence and configuration hierarchy
- ✅ Troubleshoot variable and output issues effectively

---

*This lab provides hands-on experience with advanced Terraform variable and output management patterns essential for enterprise-scale infrastructure deployments.*
