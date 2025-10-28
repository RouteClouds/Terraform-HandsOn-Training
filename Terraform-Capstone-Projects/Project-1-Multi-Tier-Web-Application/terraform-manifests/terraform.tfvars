# Terraform Variables - Default Values
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# General Configuration
# ========================================

aws_region   = "us-east-1"
environment  = "dev"
project_name = "webapp"

# ========================================
# VPC Configuration
# ========================================

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24"
]

enable_nat_gateway   = true
single_nat_gateway   = false  # Set to true for cost optimization (dev/test)
enable_dns_hostnames = true
enable_dns_support   = true

# ========================================
# EC2 Compute Configuration
# ========================================

instance_type = "t3.micro"
ami_id        = ""  # Leave empty to use latest Amazon Linux 2023
key_name      = ""  # Optional: Specify EC2 key pair name for SSH access

# Auto Scaling Group Configuration
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 2

# ========================================
# RDS Database Configuration
# ========================================

db_engine               = "postgres"
db_engine_version       = "15.4"
db_instance_class       = "db.t3.micro"
db_name                 = "webapp"
db_username             = "admin"
db_password             = "ChangeMe123!"  # IMPORTANT: Change this in production!
db_allocated_storage    = 20
db_multi_az             = true
db_backup_retention_period = 7

# ========================================
# S3 Configuration
# ========================================

s3_bucket_name        = ""  # Leave empty to auto-generate unique name
s3_versioning_enabled = true

# ========================================
# CloudFront Configuration
# ========================================

cloudfront_price_class = "PriceClass_100"  # Use PriceClass_All for global distribution

# ========================================
# Route53 Configuration
# ========================================

domain_name          = ""     # Optional: Specify your domain name (e.g., "example.com")
create_route53_zone  = false  # Set to true to create a new hosted zone

# ========================================
# Monitoring Configuration
# ========================================

enable_cloudwatch_alarms = true
alarm_email              = ""  # Optional: Email address for alarm notifications

# ========================================
# Common Tags
# ========================================

common_tags = {
  Terraform   = "true"
  Project     = "Capstone-1"
  Description = "Multi-Tier Web Application"
  Owner       = "DevOps-Team"
  CostCenter  = "Training"
}

# ========================================
# NOTES
# ========================================

# 1. Backend Configuration:
#    - Create S3 bucket manually: terraform-state-capstone-projects
#    - Create DynamoDB table manually: terraform-state-lock
#    - Update bucket name in providers.tf if different
#
# 2. Database Password:
#    - Change db_password to a strong password
#    - Consider using AWS Secrets Manager for production
#    - Never commit passwords to version control
#
# 3. Domain Configuration:
#    - If using a custom domain, set domain_name
#    - Ensure ACM certificate exists in the same region
#    - Update DNS nameservers if creating new hosted zone
#
# 4. Cost Optimization:
#    - Set single_nat_gateway = true for dev/test (saves ~$90/month)
#    - Use smaller instance types for dev/test
#    - Set db_multi_az = false for dev/test
#    - Adjust asg_min_size and asg_max_size based on needs
#
# 5. High Availability:
#    - Keep single_nat_gateway = false for production
#    - Set db_multi_az = true for production
#    - Use at least 2 availability zones
#    - Configure appropriate asg_min_size (minimum 2)
#
# 6. Security:
#    - Review security group rules
#    - Enable VPC Flow Logs
#    - Configure CloudWatch alarms
#    - Use KMS encryption for sensitive data
#    - Enable MFA for AWS account
#
# 7. Monitoring:
#    - Set alarm_email to receive notifications
#    - Review CloudWatch dashboard after deployment
#    - Configure log retention periods
#    - Set up SNS subscriptions
#
# 8. Backup and Recovery:
#    - RDS automated backups enabled (7 days retention)
#    - S3 versioning enabled
#    - Consider implementing disaster recovery plan
#
# 9. Deployment:
#    - Run terraform init first
#    - Review terraform plan output
#    - Apply changes during maintenance window
#    - Test thoroughly before production deployment
#
# 10. Cleanup:
#     - Run terraform destroy to remove all resources
#     - Verify all resources are deleted in AWS console
#     - Check for any orphaned resources
#     - Review AWS bill after cleanup

