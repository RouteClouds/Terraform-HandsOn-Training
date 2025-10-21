# Topic 9 Lab: Terraform Import & State Manipulation
# main.tf - EC2 Instance and Security Group Configuration

# Security Group for EC2 instance
resource "aws_security_group" "lab" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Terraform import lab"
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name}-sg"
    }
  )
}

# EC2 Instance - This resource will be imported
resource "aws_instance" "lab" {
  # After import, populate these values from actual instance
  ami                    = var.ami_id
  instance_type          = var.instance_type
  monitoring             = var.enable_monitoring
  vpc_security_group_ids = [aws_security_group.lab.id]
  
  # User data script for basic setup
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Terraform Import Lab Instance" > /var/www/html/index.html
              EOF
  )
  
  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )
  
  lifecycle {
    # Prevent accidental destruction
    prevent_destroy = false
  }
}

# Example: Resource targeting demonstration
# This resource shows how to use -target flag
resource "aws_instance" "target_example" {
  count              = 0 # Set to 1 to create
  ami                = var.ami_id
  instance_type      = "t2.micro"
  security_groups    = [aws_security_group.lab.name]
  
  tags = {
    Name = "target-example"
  }
}

# Example: State manipulation - Renamed resource
# Use: terraform state mv aws_instance.lab aws_instance.imported
# Then update this resource name
resource "aws_instance" "imported" {
  count = 0 # Not used in this example
  
  # This demonstrates how to rename after import
  # Uncomment and use after state mv command
  # ami           = var.ami_id
  # instance_type = var.instance_type
}

