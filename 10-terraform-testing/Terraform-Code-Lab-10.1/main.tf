# Topic 10 Lab: Terraform Testing & Validation
# main.tf - Testable Infrastructure Configuration

# Security Group - Testable component
resource "aws_security_group" "testing" {
  name        = "terraform-testing-sg"
  description = "Security group for Terraform testing lab"
  
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
      Name = "terraform-testing-sg"
    }
  )
}

# EC2 Instances - Testable resources
resource "aws_instance" "testing" {
  count                = var.instance_count
  ami                  = var.ami_id
  instance_type        = var.instance_type
  monitoring           = var.enable_monitoring
  vpc_security_group_ids = [aws_security_group.testing.id]
  
  # EBS optimization for compliance
  ebs_optimized = true
  
  # Root volume encryption
  root_block_device {
    encrypted = true
  }
  
  tags = merge(
    var.tags,
    {
      Name = "terraform-testing-instance-${count.index + 1}"
    }
  )
  
  lifecycle {
    prevent_destroy = false
  }
}

# CloudWatch Alarms - Testable monitoring
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count               = var.instance_count
  alarm_name          = "terraform-testing-cpu-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when CPU exceeds 80%"
  
  dimensions = {
    InstanceId = aws_instance.testing[count.index].id
  }
  
  tags = var.tags
}

