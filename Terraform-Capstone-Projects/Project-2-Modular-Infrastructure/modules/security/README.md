# Security Module

This module creates security groups, IAM roles, and KMS keys for the infrastructure.

## Features

- ✅ Security groups for ALB, EC2, RDS, and other services
- ✅ IAM roles and instance profiles for EC2
- ✅ IAM policies with least privilege
- ✅ KMS keys for encryption
- ✅ Security group rules with proper ingress/egress
- ✅ Configurable CIDR blocks for access control
- ✅ Customizable tags

## Usage

### Basic Example

```hcl
module "security" {
  source = "./modules/security"
  
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr
  allowed_cidr_blocks = ["0.0.0.0/0"]  # Restrict in production
  
  enable_kms_encryption = true
  
  tags = {
    Environment = "dev"
    Project     = "modular-infrastructure"
  }
}
```

### Production Example with Restricted Access

```hcl
module "security" {
  source = "./modules/security"
  
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr
  allowed_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]  # Internal only
  
  enable_kms_encryption = true
  kms_key_deletion_window = 30
  
  enable_ec2_ssm = true  # Enable Systems Manager access
  
  tags = {
    Environment = "production"
    Project     = "modular-infrastructure"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.0 |
| aws | >= 6.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.12.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID | `string` | n/a | yes |
| vpc_cidr | VPC CIDR block | `string` | n/a | yes |
| allowed_cidr_blocks | List of CIDR blocks allowed to access ALB | `list(string)` | `["0.0.0.0/0"]` | no |
| enable_kms_encryption | Enable KMS encryption | `bool` | `true` | no |
| kms_key_deletion_window | KMS key deletion window in days | `number` | `10` | no |
| enable_ec2_ssm | Enable EC2 Systems Manager access | `bool` | `true` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_security_group_id | ALB security group ID |
| ec2_security_group_id | EC2 security group ID |
| rds_security_group_id | RDS security group ID |
| ec2_iam_role_arn | EC2 IAM role ARN |
| ec2_iam_role_name | EC2 IAM role name |
| ec2_instance_profile_name | EC2 instance profile name |
| ec2_instance_profile_arn | EC2 instance profile ARN |
| kms_key_id | KMS key ID |
| kms_key_arn | KMS key ARN |

## Resources Created

This module creates the following resources:

- 3 Security Groups (ALB, EC2, RDS)
- Security Group Rules (ingress/egress)
- 1 IAM Role (EC2)
- 2+ IAM Policies (EC2, SSM)
- 1 IAM Instance Profile
- 1 KMS Key (optional)
- 1 KMS Key Alias (optional)

## Security Groups

### ALB Security Group
- **Ingress**: HTTP (80), HTTPS (443) from allowed CIDR blocks
- **Egress**: All traffic to VPC CIDR

### EC2 Security Group
- **Ingress**: HTTP (80) from ALB security group
- **Egress**: All traffic

### RDS Security Group
- **Ingress**: PostgreSQL (5432) from EC2 security group
- **Egress**: None (database doesn't initiate outbound connections)

## IAM Roles

### EC2 IAM Role
Allows EC2 instances to:
- Access S3 buckets
- Write CloudWatch logs
- Access Systems Manager (optional)
- Decrypt KMS keys

## Examples

### Example 1: Development Environment

```hcl
module "security" {
  source = "./modules/security"
  
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = "10.0.0.0/16"
  allowed_cidr_blocks = ["0.0.0.0/0"]
  
  enable_kms_encryption = false  # Disable for dev
  enable_ec2_ssm        = true
  
  tags = {
    Environment = "dev"
  }
}
```

### Example 2: Production Environment

```hcl
module "security" {
  source = "./modules/security"
  
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = "10.0.0.0/16"
  allowed_cidr_blocks = ["10.0.0.0/8"]  # Internal only
  
  enable_kms_encryption   = true
  kms_key_deletion_window = 30
  enable_ec2_ssm          = true
  
  tags = {
    Environment = "production"
    Compliance  = "required"
  }
}
```

### Example 3: Using Security Group Outputs

```hcl
# Create ALB with security group from module
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security.alb_security_group_id]
  subnets            = module.vpc.public_subnet_ids
}

# Create EC2 instance with security group and IAM role
resource "aws_instance" "web" {
  ami                    = "ami-12345678"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.security.ec2_security_group_id]
  iam_instance_profile   = module.security.ec2_instance_profile_name
}

# Create RDS with security group
resource "aws_db_instance" "main" {
  identifier             = "main-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  vpc_security_group_ids = [module.security.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}
```

## Security Best Practices

This module implements the following security best practices:

✅ **Least Privilege**: IAM policies grant minimum required permissions  
✅ **Network Segmentation**: Separate security groups for each tier  
✅ **Encryption**: KMS encryption for data at rest  
✅ **Access Control**: Configurable CIDR blocks for ingress rules  
✅ **Logging**: CloudWatch Logs access for EC2 instances  
✅ **Systems Manager**: SSM access for secure instance management  
✅ **No Hardcoded Credentials**: Uses IAM roles instead  

## Notes

- **ALB Security Group**: Allows HTTP/HTTPS from specified CIDR blocks. Restrict `allowed_cidr_blocks` in production.
- **EC2 Security Group**: Only allows traffic from ALB. No direct internet access.
- **RDS Security Group**: Only allows traffic from EC2 instances. No public access.
- **KMS Keys**: Enable for production to encrypt EBS volumes, RDS, and S3.
- **IAM Roles**: Follow least privilege principle. Add only required permissions.

## Testing

### Validate Module

```bash
cd modules/security
terraform init
terraform validate
```

### Plan Module

```bash
terraform plan -var-file="../../examples/security/terraform.tfvars"
```

## Troubleshooting

### Issue: Security group rules conflict

**Solution**: Ensure no overlapping CIDR blocks in ingress rules.

### Issue: IAM role permissions denied

**Solution**: Check IAM policy permissions and resource ARNs.

### Issue: KMS key access denied

**Solution**: Ensure IAM role has `kms:Decrypt` permission for the key.

## Version History

- **v1.0.0** (2025-10-27): Initial release

## Authors

RouteCloud Training Team

## License

This module is part of the Terraform Capstone Projects training material.

