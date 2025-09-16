# Terraform Code Lab 5.1: Advanced Variables and Outputs
# Development Environment Configuration
#
# This file provides example variable values for the development environment.
# It demonstrates comprehensive variable configuration patterns and serves as
# a template for other environments (staging, production).

# AWS Configuration
aws_region = "us-east-1"

# Environment Configuration
environment = "dev"

# Organization Configuration
organization_config = {
  # Basic organization information
  name                = "Global Financial Services"
  domain              = "globalfinancial.com"
  primary_region      = "us-east-1"
  backup_region       = "us-west-2"
  compliance_level    = "medium"
  cost_center_default = "development"
  data_classification = "internal"
  
  # Governance and change management
  governance = {
    change_approval_required = false  # Relaxed for development
    multi_environment_sync   = false
    audit_logging_enabled    = true
    compliance_scanning      = false  # Disabled for development
    policy_enforcement       = false
    automated_remediation    = false
  }
  
  # Security baseline requirements
  security_baseline = {
    encryption_required       = true
    mfa_required             = false  # Relaxed for development
    network_isolation        = false
    data_loss_prevention     = false
    vulnerability_scanning   = false  # Disabled for development
    penetration_testing      = false
    security_monitoring      = true
    incident_response        = false
  }
  
  # Compliance and regulatory requirements
  compliance = {
    gdpr_required     = false
    hipaa_required    = false
    sox_required      = false
    pci_dss_required  = false
    iso27001_required = false
    fedramp_required  = false
  }
  
  # Cost management and optimization
  cost_management = {
    budget_alerts_enabled    = true
    cost_optimization       = false  # Disabled for development
    resource_tagging_required = true
    spend_analysis          = false
    rightsizing_enabled     = false
  }
}

# Network Configuration
network_configuration = {
  # VPC configuration
  vpc = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"
  }
  
  # Subnet configuration
  subnets = {
    # Public subnets for load balancers and NAT gateways
    public = [
      {
        name              = "public-subnet-1"
        cidr_block        = "10.0.1.0/24"
        availability_zone = "us-east-1a"
        map_public_ip     = true
      },
      {
        name              = "public-subnet-2"
        cidr_block        = "10.0.2.0/24"
        availability_zone = "us-east-1b"
        map_public_ip     = true
      }
    ]
    
    # Private subnets for application servers
    private = [
      {
        name              = "private-subnet-1"
        cidr_block        = "10.0.11.0/24"
        availability_zone = "us-east-1a"
      },
      {
        name              = "private-subnet-2"
        cidr_block        = "10.0.12.0/24"
        availability_zone = "us-east-1b"
      }
    ]
    
    # Database subnets for RDS instances
    database = [
      {
        name              = "database-subnet-1"
        cidr_block        = "10.0.21.0/24"
        availability_zone = "us-east-1a"
      },
      {
        name              = "database-subnet-2"
        cidr_block        = "10.0.22.0/24"
        availability_zone = "us-east-1b"
      }
    ]
  }
  
  # Gateway configuration
  gateways = {
    internet_gateway = {
      enabled = true
    }
    
    nat_gateway = {
      enabled = false  # Disabled for development to save costs
      type    = "gateway"
      high_availability = false
    }
    
    vpn_gateway = {
      enabled = false
      type    = "ipsec.1"
      amazon_side_asn = 65000
    }
  }
  
  # Security and monitoring configuration
  security = {
    flow_logs_enabled = false  # Disabled for development
    flow_logs_destination = "cloud-watch-logs"
    
    # Network ACL configuration
    network_acls = [
      {
        name = "public-nacl"
        rules = [
          {
            rule_number = 100
            protocol    = "tcp"
            rule_action = "allow"
            cidr_block  = "0.0.0.0/0"
            from_port   = 80
            to_port     = 80
          },
          {
            rule_number = 110
            protocol    = "tcp"
            rule_action = "allow"
            cidr_block  = "0.0.0.0/0"
            from_port   = 443
            to_port     = 443
          },
          {
            rule_number = 120
            protocol    = "tcp"
            rule_action = "allow"
            cidr_block  = "10.0.0.0/16"
            from_port   = 22
            to_port     = 22
          }
        ]
      }
    ]
    
    # Security baseline enforcement
    security_baseline = {
      restrict_default_sg = true
      enable_guardduty   = false  # Disabled for development
      enable_config      = false
      enable_cloudtrail  = true
    }
  }
}

# Application Configuration
applications = {
  # Web Portal Application
  web_portal = {
    # Application metadata
    metadata = {
      name            = "web-portal"
      version         = "1.0.0"
      description     = "Customer web portal application for financial services"
      team_email      = "web-team@globalfinancial.com"
      repository_url  = "https://github.com/globalfinancial/web-portal"
      documentation_url = "https://docs.globalfinancial.com/web-portal"
      support_contact = "web-support@globalfinancial.com"
      business_unit   = "customer-experience"
      cost_center     = "development"
    }
    
    # Infrastructure configuration
    infrastructure = {
      instance_type     = "t3.micro"  # Small for development
      min_capacity      = 1
      max_capacity      = 3
      desired_capacity  = 1
      availability_zones = ["us-east-1a", "us-east-1b"]
      
      # Storage configuration
      storage = {
        root_volume_size = 20
        root_volume_type = "gp3"
        root_volume_encrypted = true
        additional_volumes = []  # No additional volumes for development
      }
      
      # Auto Scaling configuration
      auto_scaling = {
        scale_up_adjustment   = 1
        scale_down_adjustment = -1
        scale_up_cooldown    = 300
        scale_down_cooldown  = 300
        target_cpu_utilization = 70
        target_memory_utilization = 80
        predictive_scaling   = false  # Disabled for development
      }
    }
    
    # Network configuration
    network = {
      vpc_id              = ""  # Will be populated by outputs
      subnet_type         = "public"  # Public for development simplicity
      security_groups     = ["web", "common"]
      load_balancer_type  = "application"
      health_check_path   = "/health"
      health_check_interval = 30
      health_check_timeout  = 5
      
      # SSL/TLS configuration
      ssl_config = {
        certificate_arn = ""  # No SSL for development
        ssl_policy     = "ELBSecurityPolicy-TLS-1-2-2017-01"
        redirect_http  = false
        hsts_enabled   = false
      }
      
      # CDN configuration
      cdn_config = {
        enabled = false  # Disabled for development
        price_class = "PriceClass_100"
        geo_restriction = {
          restriction_type = "none"
          locations       = []
        }
      }
    }
    
    # Application-specific settings
    application = {
      port              = 3000
      protocol          = "HTTP"
      environment_vars = {
        NODE_ENV = "development"
        LOG_LEVEL = "debug"
        API_TIMEOUT = "30000"
        DATABASE_POOL_SIZE = "5"
      }
      secrets = ["database_password", "jwt_secret", "api_key"]
      configuration_files = ["app.conf", "logging.conf"]
      
      # Application performance
      performance = {
        cpu_request    = "100m"
        memory_request = "128Mi"
        cpu_limit      = "500m"
        memory_limit   = "512Mi"
        jvm_options    = "-Xms128m -Xmx512m"
      }
      
      # Health and readiness checks
      health_checks = {
        readiness_probe = {
          path               = "/ready"
          initial_delay_seconds = 30
          period_seconds     = 10
          timeout_seconds    = 5
          failure_threshold  = 3
        }
        liveness_probe = {
          path               = "/health"
          initial_delay_seconds = 60
          period_seconds     = 30
          timeout_seconds    = 10
          failure_threshold  = 3
        }
      }
    }
    
    # Monitoring configuration
    monitoring = {
      enable_detailed_monitoring = false  # Basic monitoring for development
      enable_container_insights  = false
      log_retention_days        = 7  # Short retention for development
      custom_metrics           = ["response_time", "error_rate"]
      
      # Alerting configuration
      alerting = {
        email_endpoints    = ["dev-team@globalfinancial.com"]
        slack_webhook_url  = ""  # No Slack integration for development
        pagerduty_key     = ""   # No PagerDuty for development
        alert_thresholds = {
          cpu_high        = 80
          memory_high     = 85
          disk_high       = 90
          error_rate_high = 5
          response_time_high = 2000
        }
      }
      
      # Logging configuration
      logging = {
        log_level        = "debug"
        structured_logs  = true
        log_aggregation  = false  # Disabled for development
        retention_policy = "7-days"
      }
    }
    
    # Security configuration
    security = {
      enable_waf           = false  # Disabled for development
      enable_ddos_protection = false
      enable_encryption    = true
      backup_required      = false  # No backups for development
      
      # Access control
      access_control = {
        authentication_method = "oauth2"
        authorization_policy  = "rbac"
        session_timeout      = 3600
        max_concurrent_sessions = 10
        mfa_required         = false  # Disabled for development
      }
      
      # Data protection
      data_protection = {
        encryption_at_rest   = true
        encryption_in_transit = true
        key_rotation_enabled = false  # Disabled for development
        data_masking        = false
      }
    }
    
    # Compliance configuration
    compliance = {
      data_classification   = "internal"
      retention_policy     = "30-days"
      audit_logging        = false  # Disabled for development
      compliance_scanning  = false
      
      # Regulatory requirements
      regulatory = {
        gdpr_compliant     = false
        hipaa_compliant    = false
        sox_compliant      = false
        pci_dss_compliant  = false
      }
      
      # Change management
      change_management = {
        approval_required = false  # Disabled for development
        testing_required  = true
        rollback_plan    = false
      }
    }
  }
}
