#!/bin/bash
# User Data Script for EC2 Instances
# Project 1: Multi-Tier Web Application Infrastructure

set -e

# Variables from Terraform
ENVIRONMENT="${environment}"
PROJECT_NAME="${project_name}"
REGION="${region}"
DB_ENDPOINT="${db_endpoint}"
DB_NAME="${db_name}"
S3_BUCKET="${s3_bucket}"

# Log output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========================================="
echo "Starting User Data Script"
echo "Environment: $ENVIRONMENT"
echo "Project: $PROJECT_NAME"
echo "Region: $REGION"
echo "========================================="

# Update system
echo "Updating system packages..."
dnf update -y

# Install required packages
echo "Installing required packages..."
dnf install -y \
    httpd \
    mod_ssl \
    postgresql15 \
    python3 \
    python3-pip \
    amazon-cloudwatch-agent \
    aws-cli \
    git \
    htop \
    vim

# Install Node.js (optional for modern web apps)
echo "Installing Node.js..."
dnf install -y nodejs npm

# Configure Apache
echo "Configuring Apache..."
systemctl enable httpd
systemctl start httpd

# Create a simple health check endpoint
cat > /var/www/html/health <<'EOF'
OK
EOF

# Create a sample index page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>$PROJECT_NAME - $ENVIRONMENT</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .info { margin: 20px 0; }
        .label { font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to $PROJECT_NAME</h1>
        <div class="info">
            <p><span class="label">Environment:</span> $ENVIRONMENT</p>
            <p><span class="label">Region:</span> $REGION</p>
            <p><span class="label">Instance ID:</span> <span id="instance-id">Loading...</span></p>
            <p><span class="label">Availability Zone:</span> <span id="az">Loading...</span></p>
        </div>
        <p>This is a multi-tier web application deployed with Terraform.</p>
    </div>
    
    <script>
        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data);
    </script>
</body>
</html>
EOF

# Configure CloudWatch Agent
echo "Configuring CloudWatch Agent..."
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/$PROJECT_NAME-$ENVIRONMENT",
            "log_stream_name": "{instance_id}/apache-access",
            "retention_in_days": 7
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/$PROJECT_NAME-$ENVIRONMENT",
            "log_stream_name": "{instance_id}/apache-error",
            "retention_in_days": 7
          },
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/aws/ec2/$PROJECT_NAME-$ENVIRONMENT",
            "log_stream_name": "{instance_id}/user-data",
            "retention_in_days": 7
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "$PROJECT_NAME/$ENVIRONMENT",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_IDLE",
            "unit": "Percent"
          },
          "cpu_usage_iowait"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DISK_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MEM_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent
echo "Starting CloudWatch Agent..."
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

# Set up database connection test script
cat > /usr/local/bin/test-db-connection.sh <<EOF
#!/bin/bash
PGPASSWORD=\$DB_PASSWORD psql -h $DB_ENDPOINT -U \$DB_USERNAME -d $DB_NAME -c "SELECT version();"
EOF
chmod +x /usr/local/bin/test-db-connection.sh

# Create application directory
mkdir -p /var/www/app
chown -R apache:apache /var/www/app

# Set up log rotation
cat > /etc/logrotate.d/webapp <<EOF
/var/log/webapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 apache apache
    sharedscripts
}
EOF

# Configure firewall (if needed)
echo "Configuring firewall..."
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Set timezone
timedatectl set-timezone America/New_York

# Enable and start services
systemctl enable httpd
systemctl restart httpd

echo "========================================="
echo "User Data Script Completed Successfully"
echo "========================================="

