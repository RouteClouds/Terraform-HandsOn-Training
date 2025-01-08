# Custom EC2 Instance Module

## Overview
This module creates an EC2 instance with customizable configuration options including storage, networking, and monitoring.

## Features
- Automated AMI selection (Latest Amazon Linux 2)
- Configurable instance type and networking
- Optional EBS volume attachment
- Enhanced security features (IMDSv2, encryption)
- Detailed monitoring options
- Flexible tagging system

## Usage

```hcl
module "web_server" {
  source = "./modules/aws-ec2-instance"

  instance_name    = "web-server"
  instance_type    = "t2.micro"
  subnet_id        = "subnet-12345678"
  
  vpc_security_group_ids = ["sg-12345678"]
  associate_public_ip    = true
  
  root_volume_size = 20
  root_volume_type = "gp3"

  tags = {
    Environment = "dev"
    Role        = "web"
  }
}
```

## Requirements
- Terraform >= 1.0.0
- AWS Provider >= 4.0.0
- Valid AWS credentials

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_name | Name tag for the EC2 instance | string | n/a | yes |
| instance_type | EC2 instance type | string | "t2.micro" | no |
| subnet_id | Subnet ID for instance placement | string | n/a | yes |
| vpc_security_group_ids | List of security group IDs | list(string) | n/a | yes |
| key_name | Name of the SSH key pair | string | null | no |
| associate_public_ip | Whether to associate a public IP | bool | false | no |
| root_volume_size | Size of root volume in GB | number | 8 | no |
| root_volume_type | Type of root volume | string | "gp3" | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_arn | ARN of the EC2 instance |
| private_ip | Private IP of the instance |
| public_ip | Public IP of the instance |
| instance_state | Current state of the instance |
| ebs_volume_id | ID of the additional EBS volume (if created) | 