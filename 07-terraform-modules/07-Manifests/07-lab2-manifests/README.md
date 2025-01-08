# Lab 2: Creating Custom EC2 Instance Module

## Overview
This lab demonstrates how to create and use a custom Terraform module for AWS EC2 instances with enhanced features and best practices.

## Module Structure
plaintext
.
├── modules/
│   └── aws-ec2-instance/          # Custom EC2 Instance Module
│       ├── main.tf                # Main module configuration
│       ├── variables.tf           # Input variables
│       ├── outputs.tf             # Output definitions
│       └── README.md              # Module documentation
└── root/                          # Root Configuration
    ├── main.tf                    # Main configuration
    ├── variables.tf               # Root variables
    ├── outputs.tf                 # Root outputs
    └── backend.tf                 # Backend configuration
```

## Module Features
1. **Instance Management**
   - AMI data source for latest Amazon Linux 2
   - Configurable instance type
   - User data support
   - Key pair integration

2. **Storage Options**
   - Configurable root volume size
   - Optional EBS volume attachment
   - Volume encryption

3. **Network Configuration**
   - VPC and subnet placement
   - Security group association
   - Optional public IP assignment

4. **Monitoring & Security**
   - Detailed monitoring option
   - IMDSv2 requirement
   - Encrypted volumes

## Usage Example

1. **Basic Usage**
```hcl
module "web_server" {
  source = "./modules/aws-ec2-instance"

  instance_name    = "web-server"
  instance_type    = "t2.micro"
  subnet_id        = "subnet-12345"
  
  vpc_security_group_ids = ["sg-12345"]
  associate_public_ip    = true
}
```

2. **Advanced Usage**
```hcl
module "application_server" {
  source = "./modules/aws-ec2-instance"

  instance_name    = "app-server"
  instance_type    = "t3.small"
  subnet_id        = "subnet-12345"
  
  vpc_security_group_ids = ["sg-12345"]
  key_name              = "app-key"
  
  root_volume_size = 20
  root_volume_type = "gp3"
  
  create_ebs_volume = true
  ebs_volume_size   = 50
  
  enable_detailed_monitoring = true

  user_data = file("scripts/setup.sh")

  tags = {
    Environment = "production"
    Role        = "application"
  }
}
```

## Implementation Steps

1. **Create Module Structure**
```bash
mkdir -p modules/aws-ec2-instance
cd modules/aws-ec2-instance
```

2. **Initialize Terraform**
```bash
terraform init
```

3. **Apply Configuration**
```bash
terraform apply
```

## Module Variables

### Required Variables
- `instance_name`: Name tag for the EC2 instance
- `subnet_id`: Subnet ID for instance placement
- `vpc_security_group_ids`: List of security group IDs

### Optional Variables
- `instance_type`: EC2 instance type (default: "t2.micro")
- `key_name`: SSH key pair name
- `user_data`: Instance user data script
- `root_volume_size`: Size of root volume in GB (default: 8)
- `create_ebs_volume`: Whether to create additional EBS volume (default: false)

## Module Outputs
- `instance_id`: ID of the created EC2 instance
- `private_ip`: Private IP address
- `public_ip`: Public IP address (if enabled)
- `instance_state`: Current instance state

## Security Considerations
1. **Network Security**
   - Use specific security group rules
   - Limit SSH access to known IPs
   - Enable HTTPS for web traffic

2. **Storage Security**
   - Enable volume encryption
   - Use gp3 volumes for better performance

3. **Instance Security**
   - Enable IMDSv2
   - Regular AMI updates
   - Proper IAM roles

## Best Practices
1. **Module Design**
   - Keep modules focused and single-purpose
   - Use clear variable names
   - Provide comprehensive documentation
   - Implement proper validation

2. **Resource Management**
   - Use create_before_destroy lifecycle
   - Enable proper monitoring
   - Implement proper tagging

3. **Error Handling**
   - Validate input variables
   - Use proper error messages
   - Implement proper state handling

## Troubleshooting

### Common Issues
1. **AMI Not Found**
```bash
# Verify AMI filters
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2"
```

2. **Security Group Issues**
```bash
# Verify security group rules
aws ec2 describe-security-groups \
  --group-ids <security-group-id>
```

3. **Volume Attachment Issues**
```bash
# Check volume state
aws ec2 describe-volumes \
  --volume-ids <volume-id>
```

## Clean Up
```bash
# Destroy resources
terraform destroy -auto-approve
```

## Additional Resources
- [EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [EBS Volume Types](https://aws.amazon.com/ebs/volume-types/)
- [EC2 User Data Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
```