# AWS Terraform Training - Topic 3: Core Terraform Operations
# Terraform Code Lab 3.1 - Output Definitions
#
# This file defines comprehensive output values for core Terraform operations,
# demonstrating best practices for output organization, data exposure, and
# integration with external systems and downstream configurations.
#
# Learning Objectives:
# 1. Comprehensive output value definition and organization
# 2. Sensitive data handling and security considerations
# 3. Structured outputs for automation and integration
# 4. Resource information exposure for monitoring and management
# 5. Cross-reference outputs for modular architecture

# =============================================================================
# NETWORK INFRASTRUCTURE OUTPUTS
# =============================================================================

output "vpc_configuration" {
  description = "VPC configuration and network details"
  value = {
    # VPC identification
    vpc_id         = aws_vpc.main.id
    vpc_arn        = aws_vpc.main.arn
    vpc_cidr_block = aws_vpc.main.cidr_block
    
    # DNS configuration
    dns_hostnames_enabled = aws_vpc.main.enable_dns_hostnames
    dns_support_enabled   = aws_vpc.main.enable_dns_support
    
    # Network metadata
    region             = data.aws_region.current.name
    availability_zones = local.availability_zones
    az_count          = local.az_count
    
    # Subnet information
    public_subnet_ids    = aws_subnet.public[*].id
    private_subnet_ids   = aws_subnet.private[*].id
    database_subnet_ids  = aws_subnet.database[*].id
    
    # CIDR allocations
    public_subnet_cidrs   = local.public_subnet_cidrs
    private_subnet_cidrs  = local.private_subnet_cidrs
    database_subnet_cidrs = local.database_subnet_cidrs
    
    # Gateway configuration
    internet_gateway_id = aws_internet_gateway.main.id
    nat_gateway_ids     = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
    nat_gateway_enabled = var.enable_nat_gateway
    
    # Route table information
    public_route_table_id  = aws_route_table.public.id
    private_route_table_ids = aws_route_table.private[*].id
  }
}

output "security_configuration" {
  description = "Security group configuration and details"
  value = {
    # Security group mappings
    security_group_ids = {
      for name, sg in aws_security_group.main : name => sg.id
    }
    
    security_group_arns = {
      for name, sg in aws_security_group.main : name => sg.arn
    }
    
    # Security group details
    security_groups = {
      for name, sg in aws_security_group.main : name => {
        id          = sg.id
        arn         = sg.arn
        name        = sg.name
        description = sg.description
        vpc_id      = sg.vpc_id
      }
    }
    
    # Security configuration summary
    total_security_groups = length(aws_security_group.main)
    vpc_flow_logs_enabled = var.enable_flow_logs
    encryption_enabled    = local.security_config.encryption_at_rest
  }
}

# =============================================================================
# COMPUTE INFRASTRUCTURE OUTPUTS
# =============================================================================

output "instance_configuration" {
  description = "EC2 instance configuration and details"
  value = {
    # Web server instances
    web_instances = {
      for name, instance in aws_instance.web : name => {
        id                = instance.id
        arn               = instance.arn
        instance_type     = instance.instance_type
        ami_id           = instance.ami
        availability_zone = instance.availability_zone
        private_ip       = instance.private_ip
        public_ip        = instance.public_ip
        subnet_id        = instance.subnet_id
        security_groups  = instance.vpc_security_group_ids
        monitoring       = instance.monitoring
        key_name         = instance.key_name
      }
    }
    
    # Application server instances
    app_instances = {
      for name, instance in aws_instance.app : name => {
        id                = instance.id
        arn               = instance.arn
        instance_type     = instance.instance_type
        ami_id           = instance.ami
        availability_zone = instance.availability_zone
        private_ip       = instance.private_ip
        subnet_id        = instance.subnet_id
        security_groups  = instance.vpc_security_group_ids
        monitoring       = instance.monitoring
        key_name         = instance.key_name
      }
    }
    
    # Instance summary
    total_instances = length(aws_instance.web) + length(aws_instance.app)
    web_instance_count = length(aws_instance.web)
    app_instance_count = length(aws_instance.app)
    
    # Instance types used
    instance_types = local.instance_types
    
    # AMI information
    ami_info = local.ami_info
  }
}

# =============================================================================
# LOAD BALANCER OUTPUTS
# =============================================================================

output "load_balancer_configuration" {
  description = "Load balancer configuration and endpoints"
  value = {
    # Load balancer details
    load_balancer = {
      id               = aws_lb.main.id
      arn              = aws_lb.main.arn
      name             = aws_lb.main.name
      dns_name         = aws_lb.main.dns_name
      zone_id          = aws_lb.main.zone_id
      type             = aws_lb.main.load_balancer_type
      scheme           = aws_lb.main.scheme
      vpc_id           = aws_vpc.main.id
      subnets          = aws_lb.main.subnets
      security_groups  = aws_lb.main.security_groups
    }
    
    # Target group details
    target_group = {
      id       = aws_lb_target_group.web.id
      arn      = aws_lb_target_group.web.arn
      name     = aws_lb_target_group.web.name
      port     = aws_lb_target_group.web.port
      protocol = aws_lb_target_group.web.protocol
      vpc_id   = aws_lb_target_group.web.vpc_id
    }
    
    # Listener configuration
    listener = {
      id                = aws_lb_listener.web.id
      arn               = aws_lb_listener.web.arn
      load_balancer_arn = aws_lb_listener.web.load_balancer_arn
      port              = aws_lb_listener.web.port
      protocol          = aws_lb_listener.web.protocol
    }
    
    # Target attachments
    target_attachments = {
      for name, attachment in aws_lb_target_group_attachment.web : name => {
        target_group_arn = attachment.target_group_arn
        target_id        = attachment.target_id
        port             = attachment.port
      }
    }
    
    # Access URLs
    application_url = "http://${aws_lb.main.dns_name}"
    health_check_url = "http://${aws_lb.main.dns_name}/health"
  }
}

# =============================================================================
# DATABASE OUTPUTS
# =============================================================================

output "database_configuration" {
  description = "Database configuration and connection details"
  value = {
    # Database instance details
    database = {
      id                = aws_db_instance.main.id
      arn               = aws_db_instance.main.arn
      identifier        = aws_db_instance.main.identifier
      engine            = aws_db_instance.main.engine
      engine_version    = aws_db_instance.main.engine_version
      instance_class    = aws_db_instance.main.instance_class
      allocated_storage = aws_db_instance.main.allocated_storage
      storage_encrypted = aws_db_instance.main.storage_encrypted
      multi_az          = aws_db_instance.main.multi_az
      availability_zone = aws_db_instance.main.availability_zone
      port              = aws_db_instance.main.port
      db_name           = aws_db_instance.main.db_name
      username          = aws_db_instance.main.username
    }
    
    # Connection information (sensitive)
    connection = {
      endpoint = aws_db_instance.main.endpoint
      port     = aws_db_instance.main.port
      database = aws_db_instance.main.db_name
      username = aws_db_instance.main.username
    }
    
    # Subnet group details
    subnet_group = {
      id          = aws_db_subnet_group.main.id
      arn         = aws_db_subnet_group.main.arn
      name        = aws_db_subnet_group.main.name
      subnet_ids  = aws_db_subnet_group.main.subnet_ids
      vpc_id      = aws_vpc.main.id
    }
    
    # Backup configuration
    backup_config = {
      retention_period = aws_db_instance.main.backup_retention_period
      backup_window    = aws_db_instance.main.backup_window
      maintenance_window = aws_db_instance.main.maintenance_window
    }
  }
  
  sensitive = true
}

# =============================================================================
# MONITORING AND LOGGING OUTPUTS
# =============================================================================

output "monitoring_configuration" {
  description = "Monitoring and logging configuration details"
  value = {
    # CloudWatch log groups
    log_groups = var.feature_flags.enable_cloudwatch_logs ? {
      application = aws_cloudwatch_log_group.application[0].name
      vpc_flow_logs = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
    } : {}
    
    # VPC Flow Logs
    vpc_flow_logs = var.enable_flow_logs ? {
      id               = aws_flow_log.vpc[0].id
      arn              = aws_flow_log.vpc[0].arn
      log_destination  = aws_flow_log.vpc[0].log_destination
      traffic_type     = aws_flow_log.vpc[0].traffic_type
      vpc_id           = aws_flow_log.vpc[0].vpc_id
    } : null
    
    # Monitoring features
    features = {
      cloudwatch_logs_enabled = var.feature_flags.enable_cloudwatch_logs
      vpc_flow_logs_enabled   = var.enable_flow_logs
      detailed_monitoring     = var.monitoring_enabled
    }
  }
}

# =============================================================================
# DATA SOURCE OUTPUTS
# =============================================================================

output "data_source_information" {
  description = "Data source results and external integration details"
  value = {
    # AWS account and region
    aws_info = {
      account_id = data.aws_caller_identity.current.account_id
      region     = data.aws_region.current.name
      user_id    = data.aws_caller_identity.current.user_id
      arn        = data.aws_caller_identity.current.arn
    }
    
    # AMI information
    ami_details = local.ami_info
    
    # External data integration
    deployment_metadata = local.deployment_info
    
    # HTTP data sources
    external_data = {
      public_ip = chomp(data.http.public_ip.response_body)
    }
    
    # Data source validation
    validation = data.aws_caller_identity.current.account_id != ""
  }
}

# =============================================================================
# RESOURCE SUMMARY OUTPUTS
# =============================================================================

output "resource_summary" {
  description = "Comprehensive summary of all created resources"
  value = {
    # Resource counts
    resource_counts = {
      vpc                = 1
      subnets           = local.az_count * 3
      security_groups   = length(aws_security_group.main)
      instances         = length(aws_instance.web) + length(aws_instance.app)
      load_balancers    = 1
      target_groups     = 1
      databases         = 1
      nat_gateways      = var.enable_nat_gateway ? local.az_count : 0
      internet_gateways = 1
      route_tables      = 1 + (var.enable_nat_gateway ? local.az_count : 1)
    }
    
    # Configuration summary
    configuration = {
      environment           = var.environment
      project              = var.project_name
      region               = data.aws_region.current.name
      availability_zones   = local.availability_zones
      vpc_cidr            = var.vpc_cidr
      nat_gateway_enabled = var.enable_nat_gateway
      monitoring_enabled  = var.monitoring_enabled
      backup_enabled      = var.backup_required
    }
    
    # Feature flags status
    features = var.feature_flags
    
    # Deployment information
    deployment = {
      timestamp   = local.timestamp
      deployed_by = data.external.environment_info.result.user
      git_branch  = data.external.git_info.result.branch
      git_commit  = data.external.git_info.result.commit
    }
    
    # Cost estimation
    estimated_monthly_cost = {
      instances     = "~$${(length(aws_instance.web) + length(aws_instance.app)) * 10}"
      load_balancer = "~$20"
      database      = "~$15"
      nat_gateways  = var.enable_nat_gateway ? "~$${local.az_count * 45}" : "$0"
      total_estimate = "~$${(length(aws_instance.web) + length(aws_instance.app)) * 10 + 20 + 15 + (var.enable_nat_gateway ? local.az_count * 45 : 0)}"
    }
  }
}

# =============================================================================
# INTEGRATION OUTPUTS FOR EXTERNAL SYSTEMS
# =============================================================================

output "integration_endpoints" {
  description = "Integration endpoints and connection information for external systems"
  value = {
    # Application endpoints
    endpoints = {
      load_balancer_dns = aws_lb.main.dns_name
      application_url   = "http://${aws_lb.main.dns_name}"
      health_check     = "http://${aws_lb.main.dns_name}/health"
    }
    
    # Network access points
    network = {
      vpc_id             = aws_vpc.main.id
      public_subnet_ids  = aws_subnet.public[*].id
      private_subnet_ids = aws_subnet.private[*].id
    }
    
    # Security access
    security = {
      web_security_group_id = aws_security_group.main["web"].id
      app_security_group_id = aws_security_group.main["app"].id
      db_security_group_id  = aws_security_group.main["database"].id
    }
    
    # Monitoring integration
    monitoring = {
      log_group_names = var.feature_flags.enable_cloudwatch_logs ? [
        aws_cloudwatch_log_group.application[0].name
      ] : []
    }
  }
}
