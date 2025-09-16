# AWS Terraform Training - Topic 3: Core Terraform Operations
# Terraform Code Lab 3.1 - Data Sources and External Integration
#
# This file demonstrates comprehensive data source usage patterns for core
# Terraform operations, including AWS data sources, external data integration,
# and dynamic configuration based on external systems.
#
# Learning Objectives:
# 1. AWS data source implementation and usage patterns
# 2. External data source integration for dynamic configuration
# 3. HTTP data sources for API integration
# 4. Template data sources for dynamic content generation
# 5. Data source validation and error handling

# =============================================================================
# AWS INFRASTRUCTURE DISCOVERY DATA SOURCES
# =============================================================================

# Current AWS account and region information
data "aws_caller_identity" "current" {
  provider = aws
}

data "aws_region" "current" {
  provider = aws
}

# Available availability zones in the current region
data "aws_availability_zones" "available" {
  provider = aws
  state    = "available"
  
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Latest Ubuntu AMI (alternative option)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# AWS EC2 instance types available in the region
data "aws_ec2_instance_types" "available" {
  filter {
    name   = "instance-type"
    values = ["t3.*", "t2.*", "m5.*"]
  }
}

# AWS RDS engine versions
data "aws_rds_engine_versions" "mysql" {
  engine = "mysql"
  
  filter {
    name   = "engine-mode"
    values = ["provisioned"]
  }
}

# =============================================================================
# EXTERNAL DATA SOURCES FOR DYNAMIC CONFIGURATION
# =============================================================================

# External data source for environment information
data "external" "environment_info" {
  program = ["python3", "-c", <<-EOT
import json
import os
import socket
import datetime

try:
    # Gather environment information
    env_data = {
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
        "user": os.environ.get("USER", "unknown"),
        "hostname": socket.gethostname(),
        "working_directory": os.getcwd(),
        "python_version": f"{os.sys.version_info.major}.{os.sys.version_info.minor}.{os.sys.version_info.micro}",
        "platform": os.name
    }
    
    print(json.dumps(env_data))
except Exception as e:
    # Fallback data in case of errors
    fallback_data = {
        "timestamp": "unknown",
        "user": "unknown",
        "hostname": "unknown",
        "working_directory": "unknown",
        "python_version": "unknown",
        "platform": "unknown",
        "error": str(e)
    }
    print(json.dumps(fallback_data))
EOT
  ]
}

# External data source for Git information
data "external" "git_info" {
  program = ["bash", "-c", <<-EOT
#!/bin/bash
set -e

# Initialize JSON object
echo "{"

# Get Git branch
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    REPO_URL=$(git config --get remote.origin.url 2>/dev/null || echo "unknown")
    
    echo "  \"branch\": \"$BRANCH\","
    echo "  \"commit\": \"$COMMIT\","
    echo "  \"repository_url\": \"$REPO_URL\","
    echo "  \"git_available\": \"true\""
else
    echo "  \"branch\": \"unknown\","
    echo "  \"commit\": \"unknown\","
    echo "  \"repository_url\": \"unknown\","
    echo "  \"git_available\": \"false\""
fi

echo "}"
EOT
  ]
}

# External data source for system information
data "external" "system_info" {
  program = ["bash", "-c", <<-EOT
#!/bin/bash

# Detect operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    DISTRO=$(lsb_release -si 2>/dev/null || echo "unknown")
    VERSION=$(lsb_release -sr 2>/dev/null || echo "unknown")
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    DISTRO="macOS"
    VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
    DISTRO="Windows"
    VERSION="unknown"
else
    OS="unknown"
    DISTRO="unknown"
    VERSION="unknown"
fi

# Get CPU information
CPU_COUNT=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "unknown")

# Get memory information (in GB)
if command -v free >/dev/null 2>&1; then
    MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
elif command -v vm_stat >/dev/null 2>&1; then
    MEMORY_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
    MEMORY_GB=$((MEMORY_BYTES / 1024 / 1024 / 1024))
else
    MEMORY_GB="unknown"
fi

cat << EOF
{
  "operating_system": "$OS",
  "distribution": "$DISTRO",
  "version": "$VERSION",
  "cpu_count": "$CPU_COUNT",
  "memory_gb": "$MEMORY_GB"
}
EOF
EOT
  ]
}

# =============================================================================
# HTTP DATA SOURCES FOR EXTERNAL API INTEGRATION
# =============================================================================

# Get public IP address
data "http" "public_ip" {
  url = "https://ipv4.icanhazip.com"
  
  request_headers = {
    Accept = "text/plain"
    User-Agent = "Terraform/1.13.0"
  }
  
  # Retry configuration
  retry {
    attempts = 3
    min_delay_ms = 1000
    max_delay_ms = 3000
  }
}

# Get AWS IP ranges (for security group configuration)
data "http" "aws_ip_ranges" {
  url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
  
  request_headers = {
    Accept = "application/json"
    User-Agent = "Terraform/1.13.0"
  }
}

# Get current time from world time API
data "http" "world_time" {
  url = "http://worldtimeapi.org/api/timezone/UTC"
  
  request_headers = {
    Accept = "application/json"
  }
}

# =============================================================================
# TEMPLATE DATA SOURCES FOR DYNAMIC CONTENT
# =============================================================================

# User data template for web servers
data "template_file" "web_user_data" {
  template = file("${path.module}/templates/web_user_data.sh.tpl")
  
  vars = {
    environment       = var.environment
    project_name      = var.project_name
    database_endpoint = "placeholder"  # Will be replaced in resource
    region           = data.aws_region.current.name
    availability_zone = "placeholder"  # Will be replaced per instance
    instance_type    = "placeholder"   # Will be replaced per instance
  }
}

# User data template for application servers
data "template_file" "app_user_data" {
  template = file("${path.module}/templates/app_user_data.sh.tpl")
  
  vars = {
    environment       = var.environment
    project_name      = var.project_name
    database_endpoint = "placeholder"  # Will be replaced in resource
    region           = data.aws_region.current.name
  }
}

# Nginx configuration template
data "template_file" "nginx_config" {
  template = file("${path.module}/templates/nginx.conf.tpl")
  
  vars = {
    server_name = "localhost"
    environment = var.environment
    project     = var.project_name
  }
}

# CloudWatch agent configuration template
data "template_file" "cloudwatch_config" {
  count = var.feature_flags.enable_cloudwatch_logs ? 1 : 0
  
  template = file("${path.module}/templates/cloudwatch_agent.json.tpl")
  
  vars = {
    log_group_name = "/aws/ec2/${var.project_name}"
    region        = data.aws_region.current.name
  }
}

# =============================================================================
# DATA SOURCE VALIDATION AND PROCESSING
# =============================================================================

# Local values for data source processing
locals {
  # Process availability zones
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 3)
  az_count          = length(local.availability_zones)
  
  # Process AMI information
  selected_ami = data.aws_ami.amazon_linux.id
  ami_info = {
    id           = data.aws_ami.amazon_linux.id
    name         = data.aws_ami.amazon_linux.name
    description  = data.aws_ami.amazon_linux.description
    architecture = data.aws_ami.amazon_linux.architecture
    creation_date = data.aws_ami.amazon_linux.creation_date
  }
  
  # Process external data
  deployment_info = {
    timestamp    = data.external.environment_info.result.timestamp
    deployed_by  = data.external.environment_info.result.user
    hostname     = data.external.environment_info.result.hostname
    platform     = data.external.system_info.result.operating_system
    git_branch   = data.external.git_info.result.branch
    git_commit   = data.external.git_info.result.commit
    public_ip    = chomp(data.http.public_ip.response_body)
  }
  
  # Process AWS IP ranges for security groups
  aws_ip_ranges = jsondecode(data.http.aws_ip_ranges.response_body)
  cloudfront_ips = [
    for prefix in local.aws_ip_ranges.prefixes :
    prefix.ip_prefix
    if prefix.service == "CLOUDFRONT"
  ]
  
  # Instance type selection based on environment
  instance_types = {
    web = var.instance_types[var.environment].web
    app = var.instance_types[var.environment].app
    database = var.instance_types[var.environment].database
  }
}

# =============================================================================
# DATA SOURCE OUTPUTS FOR VALIDATION
# =============================================================================

output "data_source_validation" {
  description = "Data source validation and information"
  value = {
    # AWS data sources
    account_id         = data.aws_caller_identity.current.account_id
    region            = data.aws_region.current.name
    availability_zones = local.availability_zones
    selected_ami      = local.ami_info
    
    # External data sources
    deployment_info   = local.deployment_info
    
    # HTTP data sources
    public_ip         = chomp(data.http.public_ip.response_body)
    cloudfront_ip_count = length(local.cloudfront_ips)
    
    # Template data sources
    templates_available = {
      web_user_data     = data.template_file.web_user_data.rendered != ""
      app_user_data     = data.template_file.app_user_data.rendered != ""
      nginx_config      = data.template_file.nginx_config.rendered != ""
    }
    
    # Data source summary
    total_data_sources = 15
    aws_data_sources   = 6
    external_data_sources = 3
    http_data_sources  = 3
    template_data_sources = 3
  }
}

# Data source error handling and validation
output "data_source_health" {
  description = "Data source health and error status"
  value = {
    # Validation checks
    ami_available = data.aws_ami.amazon_linux.id != ""
    az_count_valid = local.az_count >= 2
    external_data_valid = data.external.environment_info.result.user != "unknown"
    public_ip_valid = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", chomp(data.http.public_ip.response_body)))
    
    # Error indicators
    errors = [
      for check in [
        data.aws_ami.amazon_linux.id == "" ? "AMI not found" : "",
        local.az_count < 2 ? "Insufficient availability zones" : "",
        data.external.environment_info.result.user == "unknown" ? "External data unavailable" : "",
        !can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", chomp(data.http.public_ip.response_body))) ? "Invalid public IP" : ""
      ] : check if check != ""
    ]
    
    # Overall health status
    overall_status = length([
      for check in [
        data.aws_ami.amazon_linux.id != "",
        local.az_count >= 2,
        data.external.environment_info.result.user != "unknown",
        can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", chomp(data.http.public_ip.response_body)))
      ] : check if check
    ]) == 4 ? "HEALTHY" : "DEGRADED"
  }
}
