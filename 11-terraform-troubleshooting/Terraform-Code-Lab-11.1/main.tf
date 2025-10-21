# Topic 11 Lab: Terraform Troubleshooting & Debugging
# main.tf - Infrastructure with Troubleshooting Scenarios

# Security Group
resource "aws_security_group" "troubleshooting" {
  name        = "terraform-troubleshooting-sg"
  description = "Security group for troubleshooting lab"
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
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
      Name = "terraform-troubleshooting-sg"
    }
  )
}

# EC2 Instances for troubleshooting
resource "aws_instance" "troubleshooting" {
  count                = var.instance_count
  ami                  = var.ami_id
  instance_type        = var.instance_type
  monitoring           = var.enable_detailed_monitoring
  vpc_security_group_ids = [aws_security_group.troubleshooting.id]
  
  tags = merge(
    var.tags,
    {
      Name = "terraform-troubleshooting-${count.index + 1}"
    }
  )
  
  lifecycle {
    prevent_destroy = false
  }
}

# CloudWatch Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count               = var.instance_count
  alarm_name          = "terraform-troubleshooting-cpu-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when CPU exceeds 80%"
  
  dimensions = {
    InstanceId = aws_instance.troubleshooting[count.index].id
  }
  
  tags = var.tags
}

# Example: Intentional error for troubleshooting practice
# Uncomment to test error handling
# resource "aws_instance" "error_example" {
#   ami           = "ami-invalid"  # Invalid AMI ID
#   instance_type = "t2.micro"
# }

# Example: Resource with potential drift
resource "aws_instance" "drift_example" {
  count              = 0  # Set to 1 to create
  ami                = var.ami_id
  instance_type      = var.instance_type
  
  tags = {
    Name = "drift-example"
  }
}

