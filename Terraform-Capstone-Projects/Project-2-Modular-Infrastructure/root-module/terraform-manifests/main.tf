# Root Module - Module Composition

# Local values
locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )
  
  name_prefix = "${var.project_name}-${var.environment}"
}

# ============================================================================
# VPC MODULE
# ============================================================================

module "vpc" {
  source = "../../modules/vpc"
  
  vpc_name           = "${local.name_prefix}-vpc"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  enable_flow_logs    = var.environment == "prod" ? true : false
  enable_s3_endpoint  = true
  
  tags = local.common_tags
}

# ============================================================================
# SECURITY MODULE
# ============================================================================

module "security" {
  source = "../../modules/security"
  
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr
  allowed_cidr_blocks = var.allowed_cidr_blocks
  
  enable_kms_encryption   = var.enable_kms_encryption
  kms_key_deletion_window = var.environment == "prod" ? 30 : 10
  enable_ec2_ssm          = true
  
  tags = local.common_tags
  
  depends_on = [module.vpc]
}

# ============================================================================
# COMPUTE MODULE
# ============================================================================

module "compute" {
  source = "../../modules/compute"
  
  name_prefix         = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.ec2_security_group_id]
  instance_profile_name = module.security.ec2_instance_profile_name
  
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  
  enable_scaling           = true
  scale_up_cpu_threshold   = 75
  scale_down_cpu_threshold = 25
  
  enable_monitoring = var.environment == "prod" ? true : false
  
  tags = local.common_tags
  
  depends_on = [module.security]
}

# ============================================================================
# LOAD BALANCER MODULE
# ============================================================================

module "load_balancer" {
  source = "../../modules/load-balancer"
  
  name               = "${local.name_prefix}-alb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security.alb_security_group_id]
  
  enable_https    = var.enable_https
  certificate_arn = var.certificate_arn
  
  tags = local.common_tags
  
  depends_on = [module.security]
}

# Attach ASG to ALB Target Group
resource "aws_autoscaling_attachment" "asg_alb" {
  autoscaling_group_name = module.compute.autoscaling_group_name
  lb_target_group_arn    = module.load_balancer.target_group_arn
}

# ============================================================================
# DATABASE MODULE
# ============================================================================

module "database" {
  source = "../../modules/database"
  
  identifier        = "${local.name_prefix}-db"
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.rds_security_group_id]
  
  multi_az                = var.db_multi_az
  backup_retention_period = var.environment == "prod" ? 30 : 7
  
  kms_key_id                      = var.enable_kms_encryption ? module.security.kms_key_id : null
  enable_enhanced_monitoring      = var.environment == "prod" ? true : false
  enabled_cloudwatch_logs_exports = var.db_engine == "postgres" ? ["postgresql"] : []
  
  tags = local.common_tags
  
  depends_on = [module.security]
}

# ============================================================================
# STORAGE MODULE
# ============================================================================

module "storage" {
  source = "../../modules/storage"
  
  bucket_name       = "${local.name_prefix}-assets-${data.aws_caller_identity.current.account_id}"
  enable_versioning = var.enable_versioning
  enable_encryption = var.enable_kms_encryption
  kms_key_id        = var.enable_kms_encryption ? module.security.kms_key_id : null
  
  lifecycle_rules = var.environment == "prod" ? [
    {
      id      = "archive-old-objects"
      enabled = true
      transitions = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]
      expiration_days = 365
    }
  ] : []
  
  tags = local.common_tags
  
  depends_on = [module.security]
}

# ============================================================================
# MONITORING MODULE
# ============================================================================

module "monitoring" {
  source = "../../modules/monitoring"
  
  name_prefix            = local.name_prefix
  alb_arn                = module.load_balancer.alb_arn
  autoscaling_group_name = module.compute.autoscaling_group_name
  db_instance_id         = module.database.db_instance_id
  
  alarm_email         = var.alarm_email
  log_retention_days  = var.environment == "prod" ? 30 : 7
  
  tags = local.common_tags
  
  depends_on = [
    module.load_balancer,
    module.compute,
    module.database
  ]
}

# ============================================================================
# DNS MODULE (Optional)
# ============================================================================

module "dns" {
  count  = var.domain_name != null ? 1 : 0
  source = "../../modules/dns"
  
  domain_name        = var.domain_name
  create_hosted_zone = var.create_hosted_zone
  
  alb_dns_name = module.load_balancer.alb_dns_name
  alb_zone_id  = module.load_balancer.alb_zone_id
  
  create_www_record = true
  
  tags = local.common_tags
  
  depends_on = [module.load_balancer]
}

# ============================================================================
# DATA SOURCES
# ============================================================================

data "aws_caller_identity" "current" {}

