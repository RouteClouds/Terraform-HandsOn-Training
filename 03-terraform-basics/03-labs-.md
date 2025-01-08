# Terraform Basics - Labs

## Lab 1: Basic Terraform Commands
**Duration:** 45 minutes
![Basic Terraform Commands](/03-terraform-basics/03-diagrams/03-labs-diagrams/terraform_basics_lab.png)
### Prerequisites
- AWS CLI configured
- Terraform installed
- Basic understanding of AWS S3

### Tasks
1. Initialize Terraform Working Directory
```bash
terraform init
```

2. Create Basic S3 Bucket Configuration
```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-terraform-demo-bucket-${random_string.random.result}"
  
  tags = {
    Environment = "Dev"
    Created_By  = "Terraform"
  }
}
```

3. Plan and Apply Changes
```bash
terraform plan
terraform apply
```

4. Verify Resources
```bash
terraform show
terraform state list
```

5. Clean Up Resources
```bash
terraform destroy
```

### Validation
- [ ] Terraform initialized successfully
- [ ] Configuration applied without errors
- [ ] S3 bucket created and visible in AWS Console
- [ ] Resources destroyed successfully

## Lab 2: Working with Variables and Outputs
**Duration:** 60 minutes

### Prerequisites
- Completed Lab 1
- Understanding of Terraform syntax

### Tasks
1. Create Variable Definitions
```hcl
# variables.tf
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
```

2. Implement Variable Usage
```hcl
# main.tf
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}
```

3. Define Outputs
```hcl
# outputs.tf
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}
```

### Validation
- [ ] Variables properly defined
- [ ] Resources created using variables
- [ ] Outputs displayed correctly

## Lab 3: Resource Dependencies
**Duration:** 75 minutes

### Prerequisites
- Completed Labs 1 and 2
- Understanding of AWS VPC

### Tasks
1. Create VPC Resources
```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
}
```

2. Implement Explicit Dependencies
```hcl
resource "aws_security_group" "web" {
  depends_on = [aws_vpc.main]
  vpc_id     = aws_vpc.main.id
}
```

### Validation
- [ ] Resources created in correct order
- [ ] Dependencies properly managed
- [ ] Infrastructure deployed successfully

## Lab 4: State Management
**Duration:** 60 minutes

### Prerequisites
- Completed Labs 1-3
- Understanding of Terraform state

### Tasks
1. Examine State File
```bash
terraform show
terraform state list
```

2. Move Resources in State
```bash
terraform state mv aws_instance.web aws_instance.application
```

3. Remove Resources from State
```bash
terraform state rm aws_instance.application
```

### Validation
- [ ] State operations completed successfully
- [ ] Resources properly tracked in state
- [ ] State modifications verified

## Additional Resources
- [Terraform CLI Documentation](https://www.terraform.io/docs/cli/index.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
