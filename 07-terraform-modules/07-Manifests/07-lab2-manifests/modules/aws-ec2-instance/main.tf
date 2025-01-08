# Custom EC2 Instance Module - Main Configuration

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance Resource
resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = var.vpc_security_group_ids
  key_name              = var.key_name
  user_data             = var.user_data

  associate_public_ip_address = var.associate_public_ip

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring = var.enable_detailed_monitoring

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EBS Volume (Optional)
resource "aws_ebs_volume" "this" {
  count = var.create_ebs_volume ? 1 : 0

  availability_zone = aws_instance.this.availability_zone
  size             = var.ebs_volume_size
  type             = var.ebs_volume_type
  encrypted        = true

  tags = merge(
    {
      Name = "${var.instance_name}-ebs"
    },
    var.tags
  )
}

# Volume Attachment (Optional)
resource "aws_volume_attachment" "this" {
  count = var.create_ebs_volume ? 1 : 0

  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.this[0].id
  instance_id = aws_instance.this.id
} 