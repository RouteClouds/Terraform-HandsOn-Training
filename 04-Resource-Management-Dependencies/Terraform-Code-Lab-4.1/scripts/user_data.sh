#!/bin/bash
# AWS Terraform Training - Resource Management & Dependencies
# Lab 4.1: User Data Script for Multi-Tier Application
# This script sets up tier-specific applications demonstrating dependency relationships

# Set error handling
set -e

# Variables from Terraform template
TIER_NAME="${tier_name}"
TIER_PORT="${tier_port}"
DATABASE_ENDPOINT="${database_endpoint}"
STUDENT_NAME="${student_name}"
PROJECT_NAME="${project_name}"

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting User Data Script Execution"
echo "Tier: $TIER_NAME"
echo "Port: $TIER_PORT"
echo "Database: $DATABASE_ENDPOINT"
echo "Student: $STUDENT_NAME"
echo "Project: $PROJECT_NAME"
echo "Timestamp: $(date)"
echo "=========================================="

# Update system packages
echo "Updating system packages..."
yum update -y

# Install common packages
echo "Installing common packages..."
yum install -y httpd curl wget jq awscli mysql telnet nc

# Get instance metadata
echo "Retrieving instance metadata..."
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "N/A")
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)

echo "Instance Metadata Retrieved:"
echo "  Instance ID: $INSTANCE_ID"
echo "  Instance Type: $INSTANCE_TYPE"
echo "  Availability Zone: $AVAILABILITY_ZONE"
echo "  Public IP: $PUBLIC_IP"
echo "  Private IP: $PRIVATE_IP"
echo "  AMI ID: $AMI_ID"

# Configure tier-specific applications
echo "Configuring $TIER_NAME tier application..."

case $TIER_NAME in
  "web")
    echo "Setting up Web Tier (Frontend)..."
    
    # Configure Apache for web tier
    systemctl start httpd
    systemctl enable httpd
    
    # Create web tier application
    cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resource Management & Dependencies Lab - Web Tier</title>
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
        .tier-badge {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            color: white;
            background: #e74c3c;
            margin: 10px 0;
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
            border-bottom: 2px solid #e74c3c;
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
        .dependency-flow {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            margin: 15px 0;
        }
        .dependency-arrow {
            text-align: center;
            font-size: 1.5em;
            color: #e74c3c;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div style="font-size: 4em; margin-bottom: 10px;">🌐</div>
            <h1>Resource Management & Dependencies Lab</h1>
            <div class="tier-badge">WEB TIER - PRESENTATION LAYER</div>
            <p>Instance: $INSTANCE_ID | Student: $STUDENT_NAME</p>
        </div>
        
        <div class="content">
            <div class="card">
                <h2>🖥️ Web Tier Information</h2>
                <div class="info-grid">
                    <span class="info-label">Tier Name:</span>
                    <span class="info-value">$TIER_NAME</span>
                    
                    <span class="info-label">Service Port:</span>
                    <span class="info-value">$TIER_PORT</span>
                    
                    <span class="info-label">Instance ID:</span>
                    <span class="info-value">$INSTANCE_ID</span>
                    
                    <span class="info-label">Instance Type:</span>
                    <span class="info-value">$INSTANCE_TYPE</span>
                    
                    <span class="info-label">Availability Zone:</span>
                    <span class="info-value">$AVAILABILITY_ZONE</span>
                    
                    <span class="info-label">Private IP:</span>
                    <span class="info-value">$PRIVATE_IP</span>
                </div>
            </div>
            
            <div class="card">
                <h2>🔗 Dependency Chain</h2>
                <div class="dependency-flow">
                    <div><strong>Load Balancer</strong></div>
                    <div class="dependency-arrow">⬇️ depends_on</div>
                    <div><strong>Web Tier (This Instance)</strong></div>
                    <div class="dependency-arrow">⬇️ implicit</div>
                    <div><strong>Application Tier</strong></div>
                    <div class="dependency-arrow">⬇️ depends_on</div>
                    <div><strong>Database Tier</strong></div>
                </div>
                <p><strong>Database Endpoint:</strong> $DATABASE_ENDPOINT</p>
            </div>
            
            <div class="card">
                <h2>📊 Meta-Arguments Used</h2>
                <ul>
                    <li><strong>for_each:</strong> Security groups and launch templates</li>
                    <li><strong>count:</strong> Subnets and route tables</li>
                    <li><strong>lifecycle:</strong> create_before_destroy enabled</li>
                    <li><strong>depends_on:</strong> Explicit database dependency</li>
                </ul>
            </div>
            
            <div class="card">
                <h2>🔧 Resource Management</h2>
                <div class="info-grid">
                    <span class="info-label">Dependency Tier:</span>
                    <span class="info-value">Presentation (Tier 7)</span>
                    
                    <span class="info-label">Launch Template:</span>
                    <span class="info-value">for_each managed</span>
                    
                    <span class="info-label">Auto Scaling:</span>
                    <span class="info-value">Enabled</span>
                    
                    <span class="info-label">Health Checks:</span>
                    <span class="info-value">ELB + EC2</span>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Auto-refresh every 30 seconds to show dynamic updates
        setTimeout(function() {
            location.reload();
        }, 30000);
    </script>
</body>
</html>
EOF
    
    # Create health check endpoint
    cat > /var/www/html/health << EOF
{
  "status": "healthy",
  "tier": "$TIER_NAME",
  "instance_id": "$INSTANCE_ID",
  "timestamp": "$(date -Iseconds)",
  "dependencies": {
    "database": "$DATABASE_ENDPOINT",
    "tier_port": $TIER_PORT
  }
}
EOF
    ;;
    
  "app")
    echo "Setting up Application Tier (Backend)..."
    
    # Install Java for application tier
    yum install -y java-11-amazon-corretto
    
    # Create application service
    mkdir -p /opt/app
    cat > /opt/app/app.py << EOF
#!/usr/bin/env python3
import http.server
import socketserver
import json
import os
from datetime import datetime

class AppHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {
                "status": "healthy",
                "tier": "$TIER_NAME",
                "instance_id": "$INSTANCE_ID",
                "timestamp": datetime.now().isoformat(),
                "database_endpoint": "$DATABASE_ENDPOINT",
                "port": $TIER_PORT
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            html = f"""
            <html>
            <head><title>Application Tier</title></head>
            <body>
            <h1>Application Tier - Backend Services</h1>
            <p>Instance: $INSTANCE_ID</p>
            <p>Tier: $TIER_NAME</p>
            <p>Database: $DATABASE_ENDPOINT</p>
            <p>Time: {datetime.now()}</p>
            </body>
            </html>
            """
            self.wfile.write(html.encode())

PORT = $TIER_PORT
with socketserver.TCPServer(("", PORT), AppHandler) as httpd:
    print(f"Application tier serving at port {PORT}")
    httpd.serve_forever()
EOF
    
    chmod +x /opt/app/app.py
    
    # Create systemd service
    cat > /etc/systemd/system/app-tier.service << EOF
[Unit]
Description=Application Tier Service
After=network.target

[Service]
Type=simple
User=ec2-user
ExecStart=/usr/bin/python3 /opt/app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl enable app-tier
    systemctl start app-tier
    ;;
    
  "api")
    echo "Setting up API Tier (Services)..."
    
    # Install Node.js for API tier
    curl -sL https://rpm.nodesource.com/setup_16.x | bash -
    yum install -y nodejs
    
    # Create API service
    mkdir -p /opt/api
    cat > /opt/api/server.js << EOF
const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    
    if (parsedUrl.pathname === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            status: 'healthy',
            tier: '$TIER_NAME',
            instance_id: '$INSTANCE_ID',
            timestamp: new Date().toISOString(),
            database_endpoint: '$DATABASE_ENDPOINT',
            port: $TIER_PORT
        }));
    } else {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(\`
        <html>
        <head><title>API Tier</title></head>
        <body>
        <h1>API Tier - Service Layer</h1>
        <p>Instance: $INSTANCE_ID</p>
        <p>Tier: $TIER_NAME</p>
        <p>Database: $DATABASE_ENDPOINT</p>
        <p>Time: \${new Date()}</p>
        </body>
        </html>
        \`);
    }
});

server.listen($TIER_PORT, () => {
    console.log(\`API tier server running on port $TIER_PORT\`);
});
EOF
    
    # Create systemd service
    cat > /etc/systemd/system/api-tier.service << EOF
[Unit]
Description=API Tier Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/api
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl enable api-tier
    systemctl start api-tier
    ;;
    
  *)
    echo "Unknown tier: $TIER_NAME, setting up generic web service..."
    systemctl start httpd
    systemctl enable httpd
    
    cat > /var/www/html/index.html << EOF
<html>
<head><title>$TIER_NAME Tier</title></head>
<body>
<h1>$TIER_NAME Tier</h1>
<p>Instance: $INSTANCE_ID</p>
<p>Database: $DATABASE_ENDPOINT</p>
</body>
</html>
EOF
    ;;
esac

# Configure firewall (if enabled)
if systemctl is-active --quiet firewalld; then
    echo "Configuring firewall for port $TIER_PORT..."
    firewall-cmd --permanent --add-port=$TIER_PORT/tcp
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi

# Test database connectivity if endpoint is provided
if [ "$DATABASE_ENDPOINT" != "localhost" ] && [ "$DATABASE_ENDPOINT" != "" ]; then
    echo "Testing database connectivity..."
    DB_HOST=$(echo $DATABASE_ENDPOINT | cut -d: -f1)
    DB_PORT=$(echo $DATABASE_ENDPOINT | cut -d: -f2)
    
    if nc -z $DB_HOST $DB_PORT; then
        echo "✅ Database connectivity test successful"
    else
        echo "❌ Database connectivity test failed"
    fi
fi

# Test tier service
echo "Testing $TIER_NAME tier service..."
sleep 5
if curl -f http://localhost:$TIER_PORT/health > /dev/null 2>&1; then
    echo "✅ $TIER_NAME tier service is responding correctly"
else
    echo "❌ $TIER_NAME tier service test failed"
    systemctl status httpd || systemctl status ${TIER_NAME}-tier || true
fi

# Create dependency information file
cat > /opt/dependency-info.json << EOF
{
  "tier": "$TIER_NAME",
  "instance_id": "$INSTANCE_ID",
  "database_endpoint": "$DATABASE_ENDPOINT",
  "tier_port": $TIER_PORT,
  "student_name": "$STUDENT_NAME",
  "project_name": "$PROJECT_NAME",
  "deployment_time": "$(date -Iseconds)",
  "dependencies": {
    "implicit": ["vpc", "subnet", "security_group", "launch_template"],
    "explicit": ["database", "route_table_associations"],
    "meta_arguments": ["for_each", "lifecycle", "depends_on"]
  }
}
EOF

echo "=========================================="
echo "User Data Script Execution Completed"
echo "Tier: $TIER_NAME"
echo "Service Port: $TIER_PORT"
echo "Instance: $INSTANCE_ID"
echo "Database: $DATABASE_ENDPOINT"
echo "Service URL: http://$PRIVATE_IP:$TIER_PORT/"
echo "Health Check: http://$PRIVATE_IP:$TIER_PORT/health"
echo "Timestamp: $(date)"
echo "=========================================="
