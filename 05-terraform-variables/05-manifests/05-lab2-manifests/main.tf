# Variable Types and Validation Lab
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# EC2 Instance with complex type variables
resource "aws_instance" "example" {
  ami           = var.instance_config.ami_id
  instance_type = var.instance_config.instance_type
  count         = var.instance_config.count

  tags = merge(
    var.instance_tags,
    {
      Name = "${var.instance_config.environment}-instance-${count.index + 1}"
    }
  )
}

# Security Group with list variables
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
} 