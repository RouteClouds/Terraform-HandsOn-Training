# VPC Module

This module creates a complete VPC infrastructure with public and private subnets, Internet Gateway, NAT Gateways, and route tables.

## Features

- ✅ Configurable VPC CIDR block
- ✅ Multiple availability zones support
- ✅ Public and private subnets
- ✅ Internet Gateway for public subnets
- ✅ NAT Gateways for private subnets (one per AZ or single)
- ✅ Route tables with proper routing
- ✅ VPC Flow Logs (optional)
- ✅ S3 VPC Endpoint (optional)
- ✅ DNS hostnames and DNS support enabled
- ✅ Customizable tags

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name           = "my-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = false  # One NAT gateway per AZ
  
  tags = {
    Environment = "dev"
    Project     = "modular-infrastructure"
  }
}
```

### Advanced Example with Flow Logs

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name           = "production-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_flow_logs     = true
  enable_s3_endpoint   = true
  
  tags = {
    Environment = "production"
    Project     = "modular-infrastructure"
    ManagedBy   = "Terraform"
  }
}
```

### Cost-Optimized Example (Single NAT Gateway)

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name           = "dev-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true  # Single NAT gateway for cost savings
  
  tags = {
    Environment = "dev"
    Project     = "modular-infrastructure"
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
| vpc_name | Name of the VPC | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | n/a | yes |
| availability_zones | List of availability zones | `list(string)` | n/a | yes |
| public_subnet_cidrs | List of CIDR blocks for public subnets | `list(string)` | n/a | yes |
| private_subnet_cidrs | List of CIDR blocks for private subnets | `list(string)` | n/a | yes |
| enable_nat_gateway | Enable NAT Gateways for private subnets | `bool` | `true` | no |
| single_nat_gateway | Use a single NAT Gateway for all private subnets | `bool` | `false` | no |
| enable_dns_hostnames | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Enable DNS support in the VPC | `bool` | `true` | no |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `false` | no |
| flow_logs_retention_days | VPC Flow Logs retention in days | `number` | `7` | no |
| enable_s3_endpoint | Enable S3 VPC Endpoint | `bool` | `false` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr | The CIDR block of the VPC |
| vpc_arn | The ARN of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| public_subnet_cidrs | List of public subnet CIDR blocks |
| private_subnet_cidrs | List of private subnet CIDR blocks |
| internet_gateway_id | The ID of the Internet Gateway |
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_gateway_public_ips | List of NAT Gateway public IPs |
| public_route_table_id | The ID of the public route table |
| private_route_table_ids | List of private route table IDs |
| flow_logs_log_group_name | VPC Flow Logs CloudWatch Log Group name |
| s3_endpoint_id | S3 VPC Endpoint ID |

## Resources Created

This module creates the following resources:

- 1 VPC
- N Public Subnets (based on availability_zones)
- N Private Subnets (based on availability_zones)
- 1 Internet Gateway
- 1 or N NAT Gateways (based on single_nat_gateway)
- N Elastic IPs (for NAT Gateways)
- 1 Public Route Table
- N Private Route Tables
- Route Table Associations
- VPC Flow Logs (optional)
- CloudWatch Log Group (for Flow Logs, optional)
- IAM Role for Flow Logs (optional)
- S3 VPC Endpoint (optional)

## Architecture

```
VPC (10.0.0.0/16)
│
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
│   ├── Internet Gateway
│   ├── Public Route Table
│   └── NAT Gateways (1 or 3)
│
└── Private Subnets (10.0.11.0/24, 10.0.12.0/24, 10.0.13.0/24)
    ├── Private Route Tables (1 per subnet)
    └── Routes to NAT Gateways
```

## Examples

### Example 1: Development Environment (Single AZ, Single NAT)

```hcl
module "dev_vpc" {
  source = "./modules/vpc"
  
  vpc_name           = "dev-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a"]
  
  public_subnet_cidrs  = ["10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
  
  tags = {
    Environment = "dev"
  }
}
```

### Example 2: Production Environment (Multi-AZ, Multiple NATs)

```hcl
module "prod_vpc" {
  source = "./modules/vpc"
  
  vpc_name           = "prod-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = false  # High availability
  enable_flow_logs     = true
  enable_s3_endpoint   = true
  
  tags = {
    Environment = "production"
  }
}
```

### Example 3: Accessing Module Outputs

```hcl
# Use VPC outputs in other resources
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"
  vpc_id      = module.vpc.vpc_id
  
  # ... security group rules
}

resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  subnet_id     = module.vpc.private_subnet_ids[0]
  
  # ... other instance configuration
}
```

## Notes

- **NAT Gateway Costs**: Each NAT Gateway costs ~$0.045/hour (~$32/month) plus data transfer charges. Use `single_nat_gateway = true` for development to save costs.
- **High Availability**: For production, use `single_nat_gateway = false` to create one NAT Gateway per AZ for high availability.
- **VPC Flow Logs**: Enable flow logs for security monitoring and troubleshooting. Logs are stored in CloudWatch Logs.
- **S3 Endpoint**: Enable S3 VPC Endpoint to avoid data transfer charges when accessing S3 from private subnets.
- **Subnet Sizing**: Ensure subnet CIDR blocks don't overlap and fit within the VPC CIDR block.

## Testing

### Validate Module

```bash
cd modules/vpc
terraform init
terraform validate
```

### Plan Module

```bash
terraform plan -var-file="../../examples/vpc/terraform.tfvars"
```

### Test Module

```bash
terraform apply -var-file="../../examples/vpc/terraform.tfvars"
terraform destroy -var-file="../../examples/vpc/terraform.tfvars"
```

## Troubleshooting

### Issue: Subnet CIDR blocks overlap

**Solution**: Ensure all subnet CIDR blocks are unique and don't overlap.

### Issue: NAT Gateway creation fails

**Solution**: Ensure you have enough Elastic IPs available in your AWS account.

### Issue: VPC Flow Logs not working

**Solution**: Check IAM role permissions for Flow Logs.

## Version History

- **v1.0.0** (2025-10-27): Initial release

## Authors

RouteCloud Training Team

## License

This module is part of the Terraform Capstone Projects training material.

