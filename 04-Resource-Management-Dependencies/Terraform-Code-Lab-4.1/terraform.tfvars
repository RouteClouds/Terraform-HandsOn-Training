# AWS Terraform Training - Topic 4: Resource Management & Dependencies
# Terraform Code Lab 4.1 - Variable Values Configuration
#
# This file provides example variable values for the Resource Management & Dependencies
# lab. It demonstrates enterprise-grade configuration patterns, environment-specific
# settings, and comprehensive infrastructure parameters.

# ============================================================================
# ENVIRONMENT AND PROJECT CONFIGURATION
# ============================================================================

# Environment configuration (dev, staging, prod)
environment = "dev"

# Project identification
project_name = "fintech-platform"

# AWS region for deployment
aws_region = "us-east-1"

# Owner and cost center information
owner_email = "devops@fintech-innovations.com"
cost_center = "engineering"

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

# VPC CIDR block
vpc_cidr = "10.0.0.0/16"

# Availability zones for multi-AZ deployment
availability_zones = [
  "us-east-1a",
  "us-east-1b", 
  "us-east-1c"
]

# Network features
enable_nat_gateway = true
enable_vpn_gateway = false

# ============================================================================
# APPLICATION CONFIGURATION
# ============================================================================

# Complex application tier configurations
applications = {
  web = {
    instance_type     = "t3.medium"
    min_capacity      = 2
    max_capacity      = 10
    desired_capacity  = 3
    health_check_path = "/health"
    port              = 80
    protocol          = "HTTP"
    environment_vars = {
      APP_ENV     = "development"
      LOG_LEVEL   = "info"
      PORT        = "80"
      NODE_ENV    = "development"
      API_TIMEOUT = "30000"
    }
    security_groups   = ["web", "common"]
    subnets          = "public"
    enable_monitoring = true
    backup_required   = false
    dependencies     = []
    scaling_policy = {
      target_cpu_utilization = 70
      scale_up_cooldown      = 300
      scale_down_cooldown    = 300
    }
  }
  
  api = {
    instance_type     = "t3.large"
    min_capacity      = 3
    max_capacity      = 15
    desired_capacity  = 5
    health_check_path = "/api/health"
    port              = 8080
    protocol          = "HTTP"
    environment_vars = {
      APP_ENV      = "development"
      LOG_LEVEL    = "debug"
      DB_POOL_SIZE = "10"
      PORT         = "8080"
      API_VERSION  = "v1"
      CACHE_TTL    = "3600"
    }
    security_groups   = ["api", "database", "common"]
    subnets          = "private"
    enable_monitoring = true
    backup_required   = true
    dependencies     = ["database"]
    scaling_policy = {
      target_cpu_utilization = 60
      scale_up_cooldown      = 180
      scale_down_cooldown    = 300
    }
  }
  
  worker = {
    instance_type     = "t3.xlarge"
    min_capacity      = 1
    max_capacity      = 5
    desired_capacity  = 2
    health_check_path = "/worker/health"
    port              = 9090
    protocol          = "HTTP"
    environment_vars = {
      APP_ENV        = "development"
      LOG_LEVEL      = "debug"
      WORKER_THREADS = "4"
      PORT           = "9090"
      QUEUE_SIZE     = "500"
      BATCH_SIZE     = "10"
    }
    security_groups   = ["worker", "database", "queue", "common"]
    subnets          = "private"
    enable_monitoring = true
    backup_required   = true
    dependencies     = ["database", "queue"]
    scaling_policy = {
      target_cpu_utilization = 80
      scale_up_cooldown      = 120
      scale_down_cooldown    = 600
    }
  }
}

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================

# Comprehensive database configuration
database_config = {
  engine                  = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"    # Development size
  allocated_storage      = 20               # Minimum for development
  max_allocated_storage  = 100              # Auto-scaling limit
  backup_retention_period = 7               # 1 week for development
  backup_window         = "03:00-04:00"
  maintenance_window    = "sun:04:00-sun:05:00"
  multi_az              = false             # Single AZ for development
  storage_encrypted     = true
  deletion_protection   = false             # Allow deletion in development
  performance_insights  = false             # Disabled for cost savings
  monitoring_interval   = 0                 # Basic monitoring
  auto_minor_version_upgrade = true
}

# ============================================================================
# FEATURE FLAGS CONFIGURATION
# ============================================================================

# Feature flags for optional infrastructure components
feature_flags = {
  enable_monitoring     = true
  enable_backup        = false              # Disabled for development
  enable_cdn           = false              # Not needed for development
  enable_waf           = false              # Not needed for development
  enable_elasticsearch = false              # Not needed for development
  enable_redis_cache   = true               # Useful for development
  enable_queue         = true               # Needed for worker testing
  enable_secrets_manager = false            # Use simple passwords for dev
  enable_parameter_store = false            # Use environment variables for dev
  enable_cloudtrail    = false              # Not needed for development
}

# ============================================================================
# SECURITY CONFIGURATION
# ============================================================================

# Allowed CIDR blocks for access
allowed_cidr_blocks = [
  "10.0.0.0/8",      # Private networks
  "172.16.0.0/12",   # Private networks
  "192.168.0.0/16"   # Private networks
]

# EC2 key pair for SSH access
key_pair_name = "terraform-lab-key"

# ============================================================================
# MONITORING CONFIGURATION
# ============================================================================

# Monitoring and alerting configuration
monitoring_config = {
  enable_detailed_monitoring = true
  log_retention_days        = 7              # Short retention for development
  alarm_email_endpoints     = [
    "devops@fintech-innovations.com"
  ]
  dashboard_refresh_interval = "1m"
}

# ============================================================================
# BACKUP CONFIGURATION
# ============================================================================

# Backup and disaster recovery configuration
backup_config = {
  backup_schedule           = "cron(0 6 * * ? *)"  # Daily at 6 AM
  backup_retention_days     = 7                    # 1 week for development
  cross_region_backup      = false                 # Not needed for development
  backup_vault_kms_key_id  = ""                    # Use default key
}

# ============================================================================
# DEVELOPMENT-SPECIFIC OVERRIDES
# ============================================================================

# Development environment specific configurations:
#
# 1. Cost Optimization:
#    - Smaller instance types (t3.micro, t3.small)
#    - Single AZ deployment for database
#    - Reduced backup retention
#    - Disabled expensive features (CloudTrail, WAF)
#
# 2. Development Convenience:
#    - Deletion protection disabled
#    - Debug logging enabled
#    - Detailed monitoring for troubleshooting
#    - Redis cache for testing
#
# 3. Security Considerations:
#    - Private network access only
#    - Encryption enabled for data at rest
#    - Proper security group segmentation
#    - SSH key access for debugging
#
# 4. Dependency Management:
#    - Clear application dependencies defined
#    - Proper tier separation (web, api, worker)
#    - Database dependencies explicit
#    - Queue dependencies for worker tier
#
# 5. Scaling Configuration:
#    - Conservative scaling policies
#    - Appropriate cooldown periods
#    - CPU-based scaling triggers
#    - Environment-specific capacity limits

# ============================================================================
# STAGING ENVIRONMENT EXAMPLE
# ============================================================================

# For staging environment, modify these values:
# environment = "staging"
# database_config.instance_class = "db.t3.small"
# database_config.multi_az = false
# database_config.backup_retention_period = 14
# feature_flags.enable_backup = true
# feature_flags.enable_monitoring = true
# applications.web.instance_type = "t3.small"
# applications.api.instance_type = "t3.medium"
# applications.worker.instance_type = "t3.large"

# ============================================================================
# PRODUCTION ENVIRONMENT EXAMPLE
# ============================================================================

# For production environment, modify these values:
# environment = "prod"
# database_config.instance_class = "db.t3.medium"
# database_config.multi_az = true
# database_config.backup_retention_period = 30
# database_config.deletion_protection = true
# database_config.performance_insights = true
# database_config.monitoring_interval = 60
# feature_flags.enable_backup = true
# feature_flags.enable_monitoring = true
# feature_flags.enable_waf = true
# feature_flags.enable_cloudtrail = true
# feature_flags.enable_secrets_manager = true
# applications.web.instance_type = "t3.medium"
# applications.api.instance_type = "t3.large"
# applications.worker.instance_type = "t3.xlarge"
# applications.web.desired_capacity = 3
# applications.api.desired_capacity = 5
# applications.worker.desired_capacity = 2

# ============================================================================
# USAGE INSTRUCTIONS
# ============================================================================

# 1. Copy this file to terraform.tfvars.local for customization
# 2. Modify values according to your environment requirements
# 3. Ensure AWS credentials are configured
# 4. Create EC2 key pair if it doesn't exist:
#    aws ec2 create-key-pair --key-name terraform-lab-key
# 5. Run terraform commands:
#    terraform init
#    terraform plan -var-file="terraform.tfvars.local"
#    terraform apply -var-file="terraform.tfvars.local"

# ============================================================================
# SECURITY NOTES
# ============================================================================

# 1. Never commit sensitive values to version control
# 2. Use AWS Secrets Manager for production passwords
# 3. Implement proper IAM roles and policies
# 4. Enable CloudTrail for production environments
# 5. Use VPN or bastion hosts for SSH access
# 6. Regularly rotate access keys and passwords
# 7. Monitor resource usage and costs
# 8. Implement proper backup and disaster recovery procedures
