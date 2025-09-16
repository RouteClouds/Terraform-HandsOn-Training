# Test Your Understanding - Topic 1: Infrastructure as Code Concepts & AWS Integration

## 📋 **Assessment Overview**

**Duration**: 45-60 minutes  
**Total Points**: 100 points  
**Passing Score**: 80%  
**Question Types**: Multiple Choice, Scenario-Based, Hands-On Exercises  

### **Learning Objectives Assessed**
1. **Conceptual Understanding** (25 points): IaC principles, evolution, and business value quantification
2. **Technical Implementation** (30 points): AWS integration, Terraform ~> 1.13.0, and AWS Provider ~> 6.12.0
3. **Security and Compliance** (20 points): AWS security best practices and automated governance
4. **Cost Optimization** (15 points): Financial management, ROI calculation, and automated optimization
5. **Practical Application** (10 points): Real-world scenario analysis and enterprise implementation

### **Assessment Integration with Visual Learning**
This assessment directly references the professional diagrams created in the DaC implementation:
- **Figure 1.1**: IaC Evolution and Benefits (Questions 1-5)
- **Figure 1.2**: AWS IaC Ecosystem (Questions 6-10)
- **Figure 1.3**: Terraform vs CloudFormation (Questions 11-15)
- **Figure 1.4**: Enterprise IaC Workflow (Scenario-based challenges)
- **Figure 1.5**: Cost Optimization through IaC (ROI calculations)

---

## 📚 **Section A: Multiple Choice Questions (50 points)**

### **Question 1** (3 points)
What is the primary benefit of Infrastructure as Code compared to manual infrastructure management?

A) Lower initial setup costs  
B) Faster hardware procurement  
C) Consistent and repeatable deployments  
D) Reduced need for documentation  

**Correct Answer**: C  
**Explanation**: IaC ensures consistent, repeatable deployments by defining infrastructure through code, eliminating configuration drift and human errors.

---

### **Question 2** (3 points)
Which Terraform version constraint ensures compatibility with the latest stable features while preventing breaking changes in 2025?

A) `= 1.13.2`
B) `>= 1.13.0`
C) `~> 1.13.0`
D) `< 1.14.0`

**Correct Answer**: C
**Explanation**: The `~> 1.13.0` constraint allows patch-level updates (1.13.x) while preventing minor version changes that could introduce breaking changes. This is the recommended approach for production environments using Terraform 1.13.x series.

---

### **Question 3** (4 points)
In the three-tier architecture implemented in Lab 1.1, which AWS service provides high availability and automatic scaling for the application tier?

A) Elastic Load Balancer  
B) Auto Scaling Group  
C) RDS Multi-AZ  
D) CloudWatch  

**Correct Answer**: B  
**Explanation**: Auto Scaling Groups automatically adjust the number of EC2 instances based on demand and health checks, providing both high availability and scaling.

---

### **Question 4** (3 points)
Which AWS Provider version should be used with Terraform ~> 1.13.0 for optimal compatibility and latest AWS service features in 2025?

A) `~> 5.0.0`
B) `~> 6.0.0`
C) `~> 6.12.0`
D) `>= 6.12.0`

**Correct Answer**: C
**Explanation**: AWS Provider version ~> 6.12.0 is the latest stable version (published September 2025) that provides optimal compatibility with Terraform 1.13.x and includes the newest AWS service features and security enhancements.

---

### **Question 5** (4 points)
What is the recommended approach for managing sensitive data like database passwords in Terraform?

A) Store in terraform.tfvars file  
B) Hard-code in main.tf  
C) Use random_password resource with sensitive output  
D) Store in plain text variables  

**Correct Answer**: C  
**Explanation**: Using `random_password` resource with `sensitive = true` output ensures passwords are generated securely and not displayed in logs.

---

### **Question 5** (4 points)
Which AWS service combination provides the most cost-effective solution for private subnet internet access?

A) Internet Gateway + Route Tables  
B) NAT Gateway + Elastic IP  
C) VPC Endpoints + Private Link  
D) Direct Connect + Virtual Private Gateway  

**Correct Answer**: B  
**Explanation**: NAT Gateway with Elastic IP provides secure, managed internet access for private subnets, though VPC Endpoints can be more cost-effective for specific AWS services.

---

### **Question 6** (4 points)
What is the primary purpose of applying default tags in the AWS provider configuration?

A) Improve resource performance  
B) Enable cost allocation and governance  
C) Increase security  
D) Reduce deployment time  

**Correct Answer**: B  
**Explanation**: Default tags ensure consistent cost allocation, governance, and resource management across all AWS resources.

---

### **Question 7** (4 points)
In the context of Infrastructure as Code, what does "idempotency" mean?

A) Infrastructure can be deployed only once  
B) Running the same configuration multiple times produces the same result  
C) Infrastructure automatically scales based on demand  
D) Configuration files are encrypted  

**Correct Answer**: B  
**Explanation**: Idempotency ensures that applying the same Terraform configuration multiple times results in the same infrastructure state.

---

### **Question 8** (4 points)
Which security principle is demonstrated by the security group configuration in Lab 1.1?

A) Defense in depth  
B) Least privilege access  
C) Zero trust architecture  
D) Multi-factor authentication  

**Correct Answer**: B  
**Explanation**: Security groups are configured with minimal required access - ALB only accepts HTTP/HTTPS, web servers only accept traffic from ALB, database only accepts connections from web servers.

---

### **Question 9** (5 points)
What is the estimated monthly cost savings when using a single NAT Gateway instead of multiple NAT Gateways in a development environment?

A) $16.20  
B) $32.40  
C) $48.60  
D) $64.80  

**Correct Answer**: B  
**Explanation**: Each NAT Gateway costs approximately $32.40/month. Using one instead of two saves $32.40/month.

---

### **Question 10** (5 points)
Which combination of AWS services provides comprehensive monitoring and logging for the deployed infrastructure?

A) CloudWatch + CloudTrail + S3  
B) X-Ray + CloudFormation + SNS  
C) Config + Inspector + GuardDuty  
D) Systems Manager + Trusted Advisor + Cost Explorer  

**Correct Answer**: A  
**Explanation**: CloudWatch provides metrics and logs, CloudTrail provides audit trails, and S3 stores logs with lifecycle management.

---

### **Question 11** (5 points)
What is the primary advantage of using Terraform over AWS CloudFormation for Infrastructure as Code?

A) Better AWS service integration  
B) Multi-cloud support and portability  
C) Lower cost  
D) Faster deployment speed  

**Correct Answer**: B  
**Explanation**: Terraform supports multiple cloud providers, making skills and configurations more portable across different cloud platforms.

---

### **Question 12** (5 points)
In the S3 bucket lifecycle configuration, what happens to objects in the "logs/" prefix after 90 days?

A) They are deleted  
B) They are moved to Standard-IA  
C) They are moved to Glacier  
D) They are replicated to another region  

**Correct Answer**: C  
**Explanation**: The lifecycle policy transitions objects to Glacier storage class after 90 days for long-term, cost-effective archival.

---

### **Question 13** (5 points)
Which IAM permissions are granted to EC2 instances in the lab configuration?

A) Full administrative access  
B) CloudWatch metrics, logs, and S3 bucket access  
C) Only S3 access  
D) Only CloudWatch access  

**Correct Answer**: B  
**Explanation**: The IAM policy grants specific permissions for CloudWatch metrics/logs and S3 bucket operations, following least privilege principles.

---

## 🎯 **Section B: Scenario-Based Questions (30 points)**

### **Scenario 1: Enterprise Migration Planning** (10 points)

**Context**: A financial services company with 500 employees wants to migrate from manually managed infrastructure to Infrastructure as Code. They have compliance requirements (SOC 2), need high availability, and want to optimize costs.

**Question 14** (5 points)
What should be the first phase of their IaC migration strategy?

A) Migrate all production workloads immediately  
B) Conduct infrastructure audit and team training  
C) Purchase enterprise Terraform licenses  
D) Hire external consultants  

**Correct Answer**: B  
**Explanation**: Assessment and planning phase should include infrastructure audit, team training, and establishing foundation before migration.

**Question 15** (5 points)
Which compliance and security features should be prioritized for this financial services company?

A) Basic monitoring and standard encryption  
B) Enhanced monitoring, audit logging, and comprehensive encryption  
C) Cost optimization over security  
D) Public cloud deployment without restrictions  

**Correct Answer**: B  
**Explanation**: Financial services require enhanced security, comprehensive audit trails, and strict compliance controls for SOC 2 certification.

---

### **Scenario 2: Cost Optimization Challenge** (10 points)

**Context**: A startup has deployed the Lab 1.1 infrastructure but is concerned about monthly costs. They need to reduce expenses while maintaining functionality for their development environment.

**Question 16** (5 points)
Which configuration changes would provide the most significant cost reduction?

A) Remove monitoring and logging  
B) Use single NAT Gateway and enable auto-shutdown  
C) Eliminate security groups  
D) Use larger instance types  

**Correct Answer**: B  
**Explanation**: Single NAT Gateway saves $32.40/month, and auto-shutdown can save 60-70% on compute costs during non-business hours.

**Question 17** (5 points)
What is the estimated monthly cost reduction percentage when implementing all cost optimization features?

A) 15-20%  
B) 25-35%  
C) 40-50%  
D) 60-70%  

**Correct Answer**: C  
**Explanation**: Combining single NAT Gateway, auto-shutdown, right-sizing, and lifecycle policies can reduce costs by 40-50% in development environments.

---

### **Scenario 3: Security Incident Response** (10 points)

**Context**: A security audit revealed that an application deployed using Lab 1.1 configuration had unauthorized access attempts. The security team needs to enhance monitoring and implement additional controls.

**Question 18** (5 points)
Which immediate actions should be taken to improve security monitoring?

A) Enable CloudTrail, Config, and enhanced CloudWatch monitoring  
B) Remove all security groups  
C) Allow all traffic for easier troubleshooting  
D) Disable logging to reduce costs  

**Correct Answer**: A  
**Explanation**: Enhanced monitoring through CloudTrail (audit), Config (compliance), and CloudWatch (metrics) provides comprehensive security visibility.

**Question 19** (5 points)
What additional security measures should be implemented in the Terraform configuration?

A) Remove encryption to improve performance  
B) Add WAF, enable GuardDuty, and implement VPC Flow Logs  
C) Use public subnets for all resources  
D) Disable backup and versioning  

**Correct Answer**: B  
**Explanation**: WAF protects against web attacks, GuardDuty provides threat detection, and VPC Flow Logs enable network traffic analysis.

---

## 🛠️ **Section C: Hands-On Exercises (20 points)**

### **Exercise 1: Configuration Modification** (10 points)

**Task**: Modify the Lab 1.1 Terraform configuration to add a CloudFront distribution for the web application.

**Requirements**:
- Origin should point to the Application Load Balancer
- Enable compression and caching
- Use HTTPS redirect
- Apply appropriate tags

**Evaluation Criteria**:
- Correct CloudFront resource configuration (4 points)
- Proper origin configuration with ALB (3 points)
- Security and performance settings (2 points)
- Consistent tagging (1 point)

**Sample Solution**:
```hcl
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
  
  enabled = true
  
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ALB-${local.name_prefix}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cloudfront"
    Type = "cdn"
  })
}
```

---

### **Exercise 2: Cost Analysis and Optimization** (10 points)

**Task**: Calculate the ROI for implementing Infrastructure as Code based on the following scenario:

**Scenario Data**:
- Manual infrastructure management: 40 hours/month at $75/hour
- IaC implementation cost: $25,000 (one-time)
- IaC maintenance: 8 hours/month at $75/hour
- Infrastructure cost reduction: 30%
- Current monthly infrastructure cost: $5,000

**Questions**:
1. Calculate monthly operational savings (3 points)
2. Calculate monthly infrastructure cost savings (3 points)
3. Determine payback period (2 points)
4. Calculate 12-month ROI percentage (2 points)

**Solution**:
1. **Monthly Operational Savings**: (40 - 8) × $75 = $2,400/month
2. **Monthly Infrastructure Savings**: $5,000 × 30% = $1,500/month
3. **Total Monthly Savings**: $2,400 + $1,500 = $3,900/month
4. **Payback Period**: $25,000 ÷ $3,900 = 6.4 months
5. **12-Month ROI**: (($3,900 × 12) - $25,000) ÷ $25,000 × 100% = 87.2%

---

## 📊 **Answer Key and Scoring Guide**

### **Section A: Multiple Choice (50 points)**
1. C (3 pts) | 2. C (3 pts) | 3. B (4 pts) | 4. C (4 pts) | 5. B (4 pts)
6. B (4 pts) | 7. B (4 pts) | 8. B (4 pts) | 9. B (5 pts) | 10. A (5 pts)
11. B (5 pts) | 12. C (5 pts) | 13. B (5 pts)

### **Section B: Scenario-Based (30 points)**
14. B (5 pts) | 15. B (5 pts) | 16. B (5 pts) | 17. C (5 pts) | 18. A (5 pts) | 19. B (5 pts)

### **Section C: Hands-On (20 points)**
- Exercise 1: CloudFront configuration (10 pts)
- Exercise 2: ROI calculation (10 pts)

### **Scoring Rubric**
- **90-100 points**: Excellent - Demonstrates mastery of IaC concepts and AWS integration
- **80-89 points**: Good - Shows solid understanding with minor gaps
- **70-79 points**: Satisfactory - Basic understanding, needs improvement in some areas
- **Below 70 points**: Needs Review - Requires additional study and practice

---

## 🎯 **Learning Outcomes Assessment**

### **Knowledge Retention Indicators**
- **Conceptual Understanding**: Questions 1, 7, 11 assess IaC principles
- **Technical Implementation**: Questions 2, 3, 4, 5 evaluate Terraform and AWS skills
- **Security Awareness**: Questions 6, 8, 13, 18, 19 test security best practices
- **Cost Management**: Questions 9, 16, 17, Exercise 2 measure financial optimization
- **Practical Application**: Scenarios and Exercise 1 assess real-world application

### **Remediation Recommendations**
- **Score < 80%**: Review Concept.md and repeat Lab-1.md
- **Weak in Security**: Focus on AWS security best practices and compliance
- **Weak in Cost**: Study AWS pricing models and optimization strategies
- **Weak in Technical**: Practice additional Terraform configurations

---

## 📚 **Additional Study Resources**

### **For Further Learning**
- **AWS Well-Architected Framework**: Security and Cost Optimization pillars
- **Terraform Documentation**: AWS Provider and best practices
- **AWS Pricing Calculator**: For cost estimation and optimization
- **AWS Security Best Practices**: For compliance and governance

### **Next Steps**
- **Topic 2**: Terraform CLI & AWS Provider Configuration
- **Advanced Labs**: Multi-environment deployments and CI/CD integration
- **Certification Prep**: AWS Solutions Architect or HashiCorp Terraform Associate

---

**🎓 Congratulations on completing the Infrastructure as Code Concepts & AWS Integration assessment! Your understanding of these foundational concepts will serve as the basis for more advanced Infrastructure as Code implementations.**
