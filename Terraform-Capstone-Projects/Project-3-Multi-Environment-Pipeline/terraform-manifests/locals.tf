# Local Values

locals {
  # Common naming prefix
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Workspace   = terraform.workspace
    }
  )
  
  # Environment-specific configurations
  env_config = {
    dev = {
      instance_type              = "t3.micro"
      min_size                   = 1
      max_size                   = 2
      desired_capacity           = 1
      db_instance_class          = "db.t3.micro"
      db_multi_az                = false
      enable_enhanced_monitoring = false
      single_nat_gateway         = true
      az_count                   = 1
    }
    staging = {
      instance_type              = "t3.small"
      min_size                   = 2
      max_size                   = 4
      desired_capacity           = 2
      db_instance_class          = "db.t3.small"
      db_multi_az                = true
      enable_enhanced_monitoring = false
      single_nat_gateway         = false
      az_count                   = 2
    }
    prod = {
      instance_type              = "t3.medium"
      min_size                   = 2
      max_size                   = 6
      desired_capacity           = 3
      db_instance_class          = "db.t3.medium"
      db_multi_az                = true
      enable_enhanced_monitoring = true
      single_nat_gateway         = false
      az_count                   = 3
    }
  }
  
  # Get current environment config
  current_env_config = local.env_config[var.environment]
  
  # Availability zones to use
  azs_to_use = slice(var.availability_zones, 0, local.current_env_config.az_count)
  
  # Subnet CIDRs to use
  public_subnets_to_use  = slice(var.public_subnet_cidrs, 0, local.current_env_config.az_count)
  private_subnets_to_use = slice(var.private_subnet_cidrs, 0, local.current_env_config.az_count)
  
  # NAT Gateway configuration
  nat_gateway_count = var.enable_nat_gateway ? (
    local.current_env_config.single_nat_gateway ? 1 : local.current_env_config.az_count
  ) : 0
}

