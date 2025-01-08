# EC2 Instances with Count
resource "aws_instance" "web_servers" {
  count         = var.instance_config.count
  ami           = var.instance_config.ami_id
  instance_type = var.instance_config.instance_type

  vpc_security_group_ids = [aws_security_group.web_server.id]

  tags = merge(
    var.instance_tags,
    {
      Name = "${var.instance_config.environment}-instance-${count.index + 1}"
    }
  )
} 