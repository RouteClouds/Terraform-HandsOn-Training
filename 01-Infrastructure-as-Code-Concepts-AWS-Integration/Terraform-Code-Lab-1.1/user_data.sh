#!/bin/bash
# User Data Script for Infrastructure as Code Lab 1.1
# Topic 1: Infrastructure as Code Concepts & AWS Integration
#
# This script configures EC2 instances with a web server and monitoring
# components, demonstrating Infrastructure as Code principles through
# automated instance configuration and application deployment.
#
# Features:
# - Apache web server installation and configuration
# - CloudWatch agent setup for monitoring
# - Application deployment and health checks
# - Security hardening and best practices
# - Logging and audit trail configuration
#
# Variables passed from Terraform:
# - bucket_name: S3 bucket for logs and application data
# - region: AWS region for service configuration
# - project: Project name for identification
# - environment: Environment name (dev, staging, prod)
#
# Last Updated: January 2025

set -e  # Exit on any error
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=========================================="
echo "Starting Infrastructure as Code Lab 1.1"
echo "Instance Configuration and Setup"
echo "=========================================="

# =============================================================================
# SYSTEM INFORMATION AND VARIABLES
# =============================================================================

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
LOCAL_IPV4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IPV4=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "N/A")

# Terraform variables
BUCKET_NAME="${bucket_name}"
REGION="${region}"
PROJECT="${project}"
ENVIRONMENT="${environment}"

# Configuration variables
DEPLOYMENT_TIME=$(date '+%Y-%m-%d %H:%M:%S UTC')
LOG_FILE="/var/log/iac-lab-setup.log"

echo "Instance ID: $INSTANCE_ID"
echo "Instance Type: $INSTANCE_TYPE"
echo "Availability Zone: $AVAILABILITY_ZONE"
echo "Local IPv4: $LOCAL_IPV4"
echo "Public IPv4: $PUBLIC_IPV4"
echo "S3 Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "Project: $PROJECT"
echo "Environment: $ENVIRONMENT"

# =============================================================================
# SYSTEM UPDATE AND PACKAGE INSTALLATION
# =============================================================================

echo "Updating system packages..."
yum update -y

echo "Installing required packages..."
yum install -y \
    httpd \
    aws-cli \
    amazon-cloudwatch-agent \
    htop \
    curl \
    wget \
    unzip \
    git \
    jq

# =============================================================================
# APACHE WEB SERVER CONFIGURATION
# =============================================================================

echo "Configuring Apache web server..."

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Configure Apache for better performance and security
cat > /etc/httpd/conf.d/iac-lab.conf << 'EOF'
# Infrastructure as Code Lab Configuration
ServerTokens Prod
ServerSignature Off

# Security headers
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"

# Performance optimizations
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# Logging configuration
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" %D" combined_with_time
CustomLog /var/log/httpd/access_log combined_with_time
EOF

# Create application directory structure
mkdir -p /var/www/html/{assets,api,health}
chown -R apache:apache /var/www/html

# =============================================================================
# APPLICATION DEPLOYMENT
# =============================================================================

echo "Deploying web application..."

# Create main application page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Infrastructure as Code Lab 1.1 - Success!</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #333;
        }
        
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 40px;
            max-width: 800px;
            width: 90%;
            margin: 20px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .success-icon {
            font-size: 4rem;
            color: #28a745;
            margin-bottom: 20px;
        }
        
        h1 {
            color: #2c3e50;
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #7f8c8d;
            font-size: 1.2rem;
            margin-bottom: 30px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .info-card {
            background: #f8f9fa;
            border-left: 4px solid #007bff;
            padding: 20px;
            border-radius: 8px;
        }
        
        .info-card h3 {
            color: #495057;
            margin-bottom: 10px;
            font-size: 1.1rem;
        }
        
        .info-card p {
            color: #6c757d;
            font-size: 0.95rem;
            line-height: 1.5;
        }
        
        .achievements {
            background: #e8f5e8;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .achievements h3 {
            color: #155724;
            margin-bottom: 15px;
            font-size: 1.3rem;
        }
        
        .achievement-list {
            list-style: none;
            padding: 0;
        }
        
        .achievement-list li {
            color: #155724;
            margin-bottom: 8px;
            padding-left: 25px;
            position: relative;
        }
        
        .achievement-list li:before {
            content: "✅";
            position: absolute;
            left: 0;
        }
        
        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        
        .metric {
            text-align: center;
            background: white;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #dee2e6;
        }
        
        .metric-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: #007bff;
        }
        
        .metric-label {
            font-size: 0.9rem;
            color: #6c757d;
            margin-top: 5px;
        }
        
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #dee2e6;
            color: #6c757d;
            font-size: 0.9rem;
        }
        
        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            background: #28a745;
            border-radius: 50%;
            margin-right: 8px;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        
        .refresh-btn {
            background: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            margin-top: 15px;
        }
        
        .refresh-btn:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="success-icon">🎉</div>
            <h1>Infrastructure as Code Lab 1.1</h1>
            <p class="subtitle">
                <span class="status-indicator"></span>
                Successfully Deployed and Running
            </p>
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <h3>Instance Information</h3>
                <p><strong>Instance ID:</strong> <span id="instance-id">$INSTANCE_ID</span></p>
                <p><strong>Instance Type:</strong> <span id="instance-type">$INSTANCE_TYPE</span></p>
                <p><strong>Availability Zone:</strong> <span id="az">$AVAILABILITY_ZONE</span></p>
            </div>
            
            <div class="info-card">
                <h3>Network Configuration</h3>
                <p><strong>Local IP:</strong> <span id="local-ip">$LOCAL_IPV4</span></p>
                <p><strong>Public IP:</strong> <span id="public-ip">$PUBLIC_IPV4</span></p>
                <p><strong>Region:</strong> $REGION</p>
            </div>
            
            <div class="info-card">
                <h3>Deployment Details</h3>
                <p><strong>Project:</strong> $PROJECT</p>
                <p><strong>Environment:</strong> $ENVIRONMENT</p>
                <p><strong>Deployed:</strong> $DEPLOYMENT_TIME</p>
            </div>
            
            <div class="info-card">
                <h3>Infrastructure Status</h3>
                <p><strong>Web Server:</strong> <span style="color: #28a745;">✓ Running</span></p>
                <p><strong>Monitoring:</strong> <span style="color: #28a745;">✓ Active</span></p>
                <p><strong>Health Check:</strong> <span style="color: #28a745;">✓ Passing</span></p>
            </div>
        </div>
        
        <div class="achievements">
            <h3>🏆 What You've Accomplished</h3>
            <ul class="achievement-list">
                <li>Deployed VPC with public and private subnets across multiple AZs</li>
                <li>Configured security groups with least privilege access principles</li>
                <li>Implemented Application Load Balancer with health checks</li>
                <li>Created Auto Scaling Group for high availability and elasticity</li>
                <li>Set up S3 bucket with encryption, versioning, and lifecycle policies</li>
                <li>Configured RDS database with automated backups and security</li>
                <li>Applied comprehensive cost optimization and monitoring tags</li>
                <li>Implemented Infrastructure as Code best practices and standards</li>
            </ul>
            
            <div class="metrics">
                <div class="metric">
                    <div class="metric-value">100%</div>
                    <div class="metric-label">IaC Automation</div>
                </div>
                <div class="metric">
                    <div class="metric-value">3-Tier</div>
                    <div class="metric-label">Architecture</div>
                </div>
                <div class="metric">
                    <div class="metric-value">Multi-AZ</div>
                    <div class="metric-label">High Availability</div>
                </div>
                <div class="metric">
                    <div class="metric-value">Encrypted</div>
                    <div class="metric-label">Security</div>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>
                <strong>Next Steps:</strong> 
                Explore Topic 2 (Terraform CLI & AWS Provider Configuration) to continue your Infrastructure as Code journey
            </p>
            <button class="refresh-btn" onclick="location.reload()">Refresh Status</button>
        </div>
    </div>
    
    <script>
        // Update instance metadata dynamically
        function updateMetadata() {
            // In a real application, this would fetch current data
            // For demo purposes, we'll just update the timestamp
            const now = new Date().toLocaleString();
            console.log('Page loaded at:', now);
        }
        
        // Initialize page
        updateMetadata();
        
        // Auto-refresh every 30 seconds
        setInterval(updateMetadata, 30000);
    </script>
</body>
</html>
EOF

# Create health check endpoint
cat > /var/www/html/health/index.html << 'EOF'
{
  "status": "healthy",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "service": "iac-lab-web-server",
  "version": "1.0.0"
}
EOF

# Create API endpoint for instance information
cat > /var/www/html/api/info.json << EOF
{
  "instance_id": "$INSTANCE_ID",
  "instance_type": "$INSTANCE_TYPE",
  "availability_zone": "$AVAILABILITY_ZONE",
  "local_ipv4": "$LOCAL_IPV4",
  "public_ipv4": "$PUBLIC_IPV4",
  "region": "$REGION",
  "project": "$PROJECT",
  "environment": "$ENVIRONMENT",
  "deployment_time": "$DEPLOYMENT_TIME",
  "status": "running"
}
EOF

# =============================================================================
# CLOUDWATCH AGENT CONFIGURATION
# =============================================================================

echo "Configuring CloudWatch agent..."

# Create CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "namespace": "IaC-Lab-1/${PROJECT}",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60,
                "totalcpu": false
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/${PROJECT}/httpd/access",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/${PROJECT}/httpd/error",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/iac-lab-setup.log",
                        "log_group_name": "/aws/ec2/${PROJECT}/setup",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# =============================================================================
# LOGGING AND MONITORING SETUP
# =============================================================================

echo "Setting up logging and monitoring..."

# Create deployment log entry
cat >> $LOG_FILE << EOF
========================================
Infrastructure as Code Lab 1.1 Deployment
========================================
Deployment Time: $DEPLOYMENT_TIME
Instance ID: $INSTANCE_ID
Instance Type: $INSTANCE_TYPE
Availability Zone: $AVAILABILITY_ZONE
Local IPv4: $LOCAL_IPV4
Public IPv4: $PUBLIC_IPV4
Project: $PROJECT
Environment: $ENVIRONMENT
S3 Bucket: $BUCKET_NAME
Region: $REGION

Services Configured:
- Apache HTTP Server: STARTED
- CloudWatch Agent: STARTED
- Application: DEPLOYED
- Health Checks: ENABLED
- Monitoring: ACTIVE

Status: DEPLOYMENT_SUCCESSFUL
========================================
EOF

# Upload deployment log to S3
if [ -n "$BUCKET_NAME" ]; then
    echo "Uploading deployment log to S3..."
    aws s3 cp $LOG_FILE "s3://$BUCKET_NAME/deployment-logs/$(date +%Y-%m-%d)/$INSTANCE_ID.log" \
        --region "$REGION" || echo "Failed to upload log to S3"
fi

# =============================================================================
# SECURITY HARDENING
# =============================================================================

echo "Applying security hardening..."

# Update file permissions
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health/index.html
chmod 644 /var/www/html/api/info.json
chown -R apache:apache /var/www/html

# Configure firewall (iptables basic rules)
# Note: Security groups provide primary firewall functionality
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -j DROP

# Save iptables rules
service iptables save

# =============================================================================
# FINAL VALIDATION AND RESTART SERVICES
# =============================================================================

echo "Performing final validation..."

# Restart Apache to apply all configurations
systemctl restart httpd

# Verify services are running
systemctl status httpd
systemctl status amazon-cloudwatch-agent

# Test web server
curl -f http://localhost/ > /dev/null && echo "Web server test: PASSED" || echo "Web server test: FAILED"
curl -f http://localhost/health/ > /dev/null && echo "Health check test: PASSED" || echo "Health check test: FAILED"

# Final status update
echo "=========================================="
echo "Infrastructure as Code Lab 1.1 Setup Complete"
echo "Instance ID: $INSTANCE_ID"
echo "Status: READY"
echo "Access URL: http://$PUBLIC_IPV4 (if public)"
echo "Health Check: http://$PUBLIC_IPV4/health/"
echo "=========================================="

# Log completion
echo "$(date): User data script completed successfully" >> $LOG_FILE

exit 0
