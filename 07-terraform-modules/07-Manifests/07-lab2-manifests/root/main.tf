# Root Configuration - Main

provider "aws" {
  region = var.aws_region
}

# Security Group for Web Server
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "Allow SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "${var.environment}-web-sg"
  }
}

# Web Server Instance using Custom Module
module "web_server" {
  source = "../modules/aws-ec2-instance"

  instance_name    = "${var.environment}-web-server"
  instance_type    = var.instance_type
  subnet_id        = var.subnet_id
  key_name         = var.key_name
  
  vpc_security_group_ids = [aws_security_group.web.id]
  associate_public_ip    = true
  
  root_volume_size = 20
  root_volume_type = "gp3"
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Custom EC2 Module</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Environment = var.environment
    Role        = "web"
  }
} 