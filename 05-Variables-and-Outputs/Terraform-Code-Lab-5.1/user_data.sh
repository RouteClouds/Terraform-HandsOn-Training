#!/bin/bash
# Terraform Code Lab 5.1: Advanced Variables and Outputs
# EC2 Instance User Data Script
#
# This script demonstrates how variables can be passed to EC2 instances
# through user data, showing the integration between Terraform variables
# and runtime configuration.

# Variables passed from Terraform
APP_NAME="${app_name}"
APP_PORT="${app_port}"
ENVIRONMENT="${environment}"

# Log all output for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script execution..."
echo "Application: $APP_NAME"
echo "Port: $APP_PORT"
echo "Environment: $ENVIRONMENT"

# Update system packages
echo "Updating system packages..."
yum update -y

# Install required packages
echo "Installing required packages..."
yum install -y \
    httpd \
    wget \
    curl \
    unzip \
    jq \
    awscli \
    amazon-cloudwatch-agent

# Configure Apache web server
echo "Configuring Apache web server..."
systemctl enable httpd
systemctl start httpd

# Create a simple web application
echo "Creating web application..."
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$APP_NAME - Terraform Variables Lab</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            color: #232F3E;
            border-bottom: 2px solid #FF9900;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .info-card {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #FF9900;
        }
        .info-label {
            font-weight: bold;
            color: #232F3E;
        }
        .info-value {
            color: #666;
            margin-top: 5px;
        }
        .status {
            background-color: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Terraform Variables and Outputs Lab</h1>
            <h2>Application: $APP_NAME</h2>
        </div>
        
        <div class="status">
            ✅ Application is running successfully!
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <div class="info-label">Application Name</div>
                <div class="info-value">$APP_NAME</div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Environment</div>
                <div class="info-value">$ENVIRONMENT</div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Port</div>
                <div class="info-value">$APP_PORT</div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Instance ID</div>
                <div class="info-value" id="instance-id">Loading...</div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Availability Zone</div>
                <div class="info-value" id="availability-zone">Loading...</div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Instance Type</div>
                <div class="info-value" id="instance-type">Loading...</div>
            </div>
        </div>
        
        <div style="margin-top: 30px; text-align: center; color: #666;">
            <p>This page demonstrates how Terraform variables are passed to EC2 instances</p>
            <p>Lab: Topic 5 - Variables and Outputs</p>
        </div>
    </div>
    
    <script>
        // Fetch instance metadata
        fetch('/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data)
            .catch(error => document.getElementById('instance-id').textContent = 'N/A');
            
        fetch('/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('availability-zone').textContent = data)
            .catch(error => document.getElementById('availability-zone').textContent = 'N/A');
            
        fetch('/latest/meta-data/instance-type')
            .then(response => response.text())
            .then(data => document.getElementById('instance-type').textContent = data)
            .catch(error => document.getElementById('instance-type').textContent = 'N/A');
    </script>
</body>
</html>
EOF

# Create health check endpoint
echo "Creating health check endpoint..."
cat > /var/www/html/health << EOF
{
    "status": "healthy",
    "application": "$APP_NAME",
    "environment": "$ENVIRONMENT",
    "port": $APP_PORT,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "version": "1.0.0"
}
EOF

# Create readiness check endpoint
cat > /var/www/html/ready << EOF
{
    "status": "ready",
    "application": "$APP_NAME",
    "environment": "$ENVIRONMENT",
    "checks": {
        "httpd": "$(systemctl is-active httpd)",
        "disk_space": "$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')% used"
    },
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Configure CloudWatch agent (if in production)
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "Configuring CloudWatch agent for production..."
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "metrics": {
        "namespace": "AWS/EC2/Custom",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
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
            "mem": {
                "measurement": [
                    "mem_used_percent"
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
                        "log_group_name": "/aws/ec2/$APP_NAME/httpd/access",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/$APP_NAME/httpd/error",
                        "log_stream_name": "{instance_id}"
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
fi

# Set up log rotation
echo "Configuring log rotation..."
cat > /etc/logrotate.d/app-logs << EOF
/var/log/httpd/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 apache apache
    postrotate
        systemctl reload httpd
    endscript
}
EOF

# Create application-specific configuration
echo "Creating application configuration..."
mkdir -p /opt/$APP_NAME/config
cat > /opt/$APP_NAME/config/app.conf << EOF
[application]
name = $APP_NAME
environment = $ENVIRONMENT
port = $APP_PORT

[logging]
level = $([ "$ENVIRONMENT" = "dev" ] && echo "debug" || echo "info")
format = json

[monitoring]
enabled = $([ "$ENVIRONMENT" = "prod" ] && echo "true" || echo "false")
metrics_interval = 60

[security]
encryption = true
audit_logging = $([ "$ENVIRONMENT" = "prod" ] && echo "true" || echo "false")
EOF

# Set proper permissions
echo "Setting file permissions..."
chown -R apache:apache /var/www/html
chmod -R 644 /var/www/html
chmod 755 /var/www/html

# Restart services
echo "Restarting services..."
systemctl restart httpd

# Verify installation
echo "Verifying installation..."
if systemctl is-active --quiet httpd; then
    echo "✅ Apache HTTP server is running"
else
    echo "❌ Apache HTTP server failed to start"
    exit 1
fi

# Test health endpoint
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ Health check endpoint is responding"
else
    echo "❌ Health check endpoint is not responding"
fi

# Final status
echo "User data script completed successfully!"
echo "Application $APP_NAME is ready on port $APP_PORT in $ENVIRONMENT environment"

# Signal completion
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource AutoScalingGroup --region ${AWS::Region} 2>/dev/null || true
