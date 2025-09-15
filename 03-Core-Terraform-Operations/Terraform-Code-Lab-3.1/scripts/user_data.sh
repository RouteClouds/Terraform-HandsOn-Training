#!/bin/bash
# AWS Terraform Training - Core Terraform Operations
# Lab 3.1: User Data Script for EC2 Instances
# This script sets up a simple web server for testing Terraform operations

# Set error handling
set -e

# Variables from Terraform template
INSTANCE_NUMBER="${instance_number}"
STUDENT_NAME="${student_name}"
PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting User Data Script Execution"
echo "Instance Number: $INSTANCE_NUMBER"
echo "Student Name: $STUDENT_NAME"
echo "Project: $PROJECT_NAME"
echo "Environment: $ENVIRONMENT"
echo "Timestamp: $(date)"
echo "=========================================="

# Update system packages
echo "Updating system packages..."
yum update -y

# Install required packages
echo "Installing required packages..."
yum install -y httpd curl wget jq awscli

# Get instance metadata
echo "Retrieving instance metadata..."
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)

echo "Instance Metadata Retrieved:"
echo "  Instance ID: $INSTANCE_ID"
echo "  Instance Type: $INSTANCE_TYPE"
echo "  Availability Zone: $AVAILABILITY_ZONE"
echo "  Public IP: $PUBLIC_IP"
echo "  Private IP: $PRIVATE_IP"
echo "  AMI ID: $AMI_ID"

# Create web application
echo "Creating web application..."
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terraform Core Operations Lab - Instance $INSTANCE_NUMBER</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            margin-bottom: 30px;
            text-align: center;
        }
        .header h1 {
            color: #2c3e50;
            margin: 0 0 10px 0;
            font-size: 2.5em;
        }
        .header .subtitle {
            color: #7f8c8d;
            font-size: 1.2em;
            margin: 0;
        }
        .content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }
        .card {
            background: rgba(255, 255, 255, 0.95);
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        .card h2 {
            color: #2c3e50;
            margin-top: 0;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 10px;
            margin: 15px 0;
        }
        .info-label {
            font-weight: bold;
            color: #34495e;
        }
        .info-value {
            color: #2c3e50;
            font-family: 'Courier New', monospace;
            background: #ecf0f1;
            padding: 5px 10px;
            border-radius: 5px;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: bold;
            color: white;
            background: #27ae60;
        }
        .terraform-logo {
            width: 60px;
            height: 60px;
            margin: 0 auto 20px;
            display: block;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: rgba(255, 255, 255, 0.8);
        }
        @media (max-width: 768px) {
            .content {
                grid-template-columns: 1fr;
            }
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div style="font-size: 4em; margin-bottom: 10px;">🚀</div>
            <h1>Terraform Core Operations Lab</h1>
            <p class="subtitle">Instance $INSTANCE_NUMBER - Student: $STUDENT_NAME</p>
            <span class="status">✅ RUNNING</span>
        </div>
        
        <div class="content">
            <div class="card">
                <h2>🖥️ Instance Information</h2>
                <div class="info-grid">
                    <span class="info-label">Instance ID:</span>
                    <span class="info-value">$INSTANCE_ID</span>
                    
                    <span class="info-label">Instance Type:</span>
                    <span class="info-value">$INSTANCE_TYPE</span>
                    
                    <span class="info-label">AMI ID:</span>
                    <span class="info-value">$AMI_ID</span>
                    
                    <span class="info-label">Availability Zone:</span>
                    <span class="info-value">$AVAILABILITY_ZONE</span>
                </div>
            </div>
            
            <div class="card">
                <h2>🌐 Network Information</h2>
                <div class="info-grid">
                    <span class="info-label">Public IP:</span>
                    <span class="info-value">$PUBLIC_IP</span>
                    
                    <span class="info-label">Private IP:</span>
                    <span class="info-value">$PRIVATE_IP</span>
                    
                    <span class="info-label">Region:</span>
                    <span class="info-value">$(echo $AVAILABILITY_ZONE | sed 's/.$//')</span>
                </div>
            </div>
            
            <div class="card">
                <h2>📋 Lab Information</h2>
                <div class="info-grid">
                    <span class="info-label">Project:</span>
                    <span class="info-value">$PROJECT_NAME</span>
                    
                    <span class="info-label">Environment:</span>
                    <span class="info-value">$ENVIRONMENT</span>
                    
                    <span class="info-label">Student:</span>
                    <span class="info-value">$STUDENT_NAME</span>
                    
                    <span class="info-label">Instance Number:</span>
                    <span class="info-value">$INSTANCE_NUMBER</span>
                </div>
            </div>
            
            <div class="card">
                <h2>⏰ Deployment Information</h2>
                <div class="info-grid">
                    <span class="info-label">Deployed:</span>
                    <span class="info-value">$(date)</span>
                    
                    <span class="info-label">Uptime:</span>
                    <span class="info-value" id="uptime">Calculating...</span>
                    
                    <span class="info-label">Server Time:</span>
                    <span class="info-value" id="current-time">$(date)</span>
                </div>
            </div>
            
            <div class="card">
                <h2>🔧 Terraform Operations</h2>
                <p>This instance was created using Terraform core operations:</p>
                <ul>
                    <li><strong>terraform init</strong> - Initialized providers and backend</li>
                    <li><strong>terraform plan</strong> - Generated execution plan</li>
                    <li><strong>terraform apply</strong> - Created this infrastructure</li>
                </ul>
                <p>Test dependency management, lifecycle rules, and resource targeting with this instance.</p>
            </div>
            
            <div class="card">
                <h2>📊 Health Check</h2>
                <div class="info-grid">
                    <span class="info-label">HTTP Status:</span>
                    <span class="info-value">200 OK</span>
                    
                    <span class="info-label">Web Server:</span>
                    <span class="info-value">Apache/2.4 (Amazon Linux)</span>
                    
                    <span class="info-label">Load Balancer Ready:</span>
                    <span class="info-value">✅ Yes</span>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>🏗️ Infrastructure managed by Terraform | 🎓 AWS Training Lab</p>
            <p>Instance $INSTANCE_NUMBER of the Core Terraform Operations Lab</p>
        </div>
    </div>
    
    <script>
        // Update current time every second
        function updateTime() {
            document.getElementById('current-time').textContent = new Date().toLocaleString();
        }
        setInterval(updateTime, 1000);
        
        // Calculate and update uptime
        const startTime = new Date();
        function updateUptime() {
            const now = new Date();
            const uptimeMs = now - startTime;
            const uptimeSeconds = Math.floor(uptimeMs / 1000);
            const hours = Math.floor(uptimeSeconds / 3600);
            const minutes = Math.floor((uptimeSeconds % 3600) / 60);
            const seconds = uptimeSeconds % 60;
            document.getElementById('uptime').textContent = hours + 'h ' + minutes + 'm ' + seconds + 's';
        }
        setInterval(updateUptime, 1000);
    </script>
</body>
</html>
EOF

# Create health check endpoint
echo "Creating health check endpoint..."
cat > /var/www/html/health << EOF
{
  "status": "healthy",
  "instance_id": "$INSTANCE_ID",
  "instance_number": "$INSTANCE_NUMBER",
  "timestamp": "$(date -Iseconds)",
  "uptime_seconds": $(cat /proc/uptime | cut -d' ' -f1),
  "student": "$STUDENT_NAME",
  "project": "$PROJECT_NAME",
  "environment": "$ENVIRONMENT"
}
EOF

# Create API endpoint for instance metadata
echo "Creating API endpoint..."
cat > /var/www/html/api << EOF
{
  "instance": {
    "id": "$INSTANCE_ID",
    "type": "$INSTANCE_TYPE",
    "ami_id": "$AMI_ID",
    "availability_zone": "$AVAILABILITY_ZONE",
    "public_ip": "$PUBLIC_IP",
    "private_ip": "$PRIVATE_IP"
  },
  "lab": {
    "project": "$PROJECT_NAME",
    "environment": "$ENVIRONMENT",
    "student": "$STUDENT_NAME",
    "instance_number": "$INSTANCE_NUMBER"
  },
  "deployment": {
    "timestamp": "$(date -Iseconds)",
    "user_data_version": "3.1",
    "terraform_managed": true
  }
}
EOF

# Configure Apache
echo "Configuring Apache web server..."
systemctl start httpd
systemctl enable httpd

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 644 /var/www/html

# Configure firewall (if enabled)
if systemctl is-active --quiet firewalld; then
    echo "Configuring firewall..."
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi

# Create log entry
echo "User data script completed successfully at $(date)" >> /var/log/user-data.log

# Test web server
echo "Testing web server..."
sleep 5
if curl -f http://localhost/ > /dev/null 2>&1; then
    echo "✅ Web server is responding correctly"
else
    echo "❌ Web server test failed"
    systemctl status httpd
fi

echo "=========================================="
echo "User Data Script Execution Completed"
echo "Instance $INSTANCE_NUMBER is ready for testing"
echo "Web server accessible at: http://$PUBLIC_IP/"
echo "Health check: http://$PUBLIC_IP/health"
echo "API endpoint: http://$PUBLIC_IP/api"
echo "Timestamp: $(date)"
echo "=========================================="
