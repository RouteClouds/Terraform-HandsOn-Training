output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "network_details" {
  description = "Network configuration details"
  value = {
    vpc = {
      id         = aws_vpc.main.id
      cidr_block = aws_vpc.main.cidr_block
    }
    subnet = {
      id         = aws_subnet.public.id
      cidr_block = aws_subnet.public.cidr_block
    }
    security_group = {
      id   = aws_security_group.web.id
      name = aws_security_group.web.name
    }
    instance = {
      id        = aws_instance.web.id
      public_ip = aws_instance.web.public_ip
    }
  }
} 