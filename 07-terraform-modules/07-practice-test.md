# Terraform Modules - Practice Test

## Section 1: Multiple Choice Questions (25 points)

1. What is the primary purpose of Terraform modules?
   - [ ] To encrypt state files
   - [x] To organize and reuse Terraform code
   - [ ] To manage providers
   - [ ] To store remote state

   **Explanation:** Modules help organize code and enable reuse of infrastructure patterns.

2. Which file is required in a Terraform module?
   - [x] main.tf
   - [ ] providers.tf
   - [ ] backend.tf
   - [ ] versions.tf

   **Explanation:** main.tf is the only required file in a module, containing the main resource definitions.

3. How do you reference an output from a child module?
   - [ ] var.module_name.output_name
   - [x] module.module_name.output_name
   - [ ] output.module_name.value
   - [ ] data.module_name.output_name

   **Explanation:** Module outputs are referenced using module.module_name.output_name syntax.

4. Which source type is NOT valid for modules?
   - [ ] Local path
   - [ ] Git repository
   - [ ] Terraform Registry
   - [x] S3 bucket

   **Explanation:** S3 bucket is not a valid module source type in Terraform.

5. What is the correct way to set module input variables?
   ```hcl
   module "example" {
     source = "./modules/example"
     ______ = "value"
   }
   ```
   - [ ] var.name
   - [ ] variable "name"
   - [x] name
   - [ ] input.name

   **Explanation:** Module inputs are set directly as arguments in the module block.

6. Which of the following is a valid module source?
   - [x] git::https://github.com/example/module.git
   - [ ] ftp://example.com/module
   - [ ] s3://bucket/module
   - [ ] http://example.com/module

   **Explanation:** Git repositories with HTTPS are valid module sources in Terraform.

7. What happens if you don't specify a version for a registry module?
   - [ ] The module won't work
   - [ ] It uses version 1.0.0
   - [x] It uses the latest version
   - [ ] Terraform throws an error

   **Explanation:** Without version constraints, Terraform uses the latest version, which is not recommended for production.

8. How do you make a module input variable required?
   - [ ] required = true
   - [x] Remove the default value
   - [ ] Set validation rules
   - [ ] Mark as mandatory

   **Explanation:** Variables without default values become required inputs.

9. Which statement about module outputs is correct?
   - [ ] All module resources are automatically output
   - [x] Only explicitly defined outputs are accessible
   - [ ] Outputs are optional in modules
   - [ ] Outputs can't reference module variables

   **Explanation:** Modules only expose values that are explicitly defined in outputs.

10. What is the correct way to use count with modules?
    ```hcl
    module "servers" {
      source = "./app-server"
      count  = 3
      name   = ______
    }
    ```
    - [ ] var.name
    - [ ] "server-${count}"
    - [x] "server-${count.index}"
    - [ ] count.name

    **Explanation:** count.index provides the current index in module repetition.

## Section 2: Hands-on Exercises (40 points)

### Exercise 1: Create a Custom VPC Module (15 points)

Create a VPC module with the following requirements:
hcl
# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Usage
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = "10.0.0.0/16"
  environment  = "production"
}
```

### Exercise 2: Module Composition (15 points)

Create a web application stack using multiple modules:
```hcl
module "vpc" {
  source = "./modules/vpc"
  # ...
}

module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  # ...
}

module "web_servers" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  security_group_ids = [module.security_groups.web_sg_id]
  # ...
}
```

### Exercise 3: Module Versioning (10 points)

Configure a public registry module with version constraints:
```hcl
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "my-bucket"
  acl    = "private"
}
```

## Section 3: True/False Questions (15 points)

1. Modules can contain other modules.
   - [x] True
   - [ ] False
   
   **Explanation:** Modules can be nested within other modules, enabling complex compositions.

2. Every module requires a variables.tf file.
   - [ ] True
   - [x] False
   
   **Explanation:** variables.tf is optional; only main.tf is required.

3. Module source paths are always relative to the root module.
   - [ ] True
   - [x] False
   
   **Explanation:** Module source paths are relative to the module where they are declared.

## Section 4: Module Development (20 points)

### Task 1: Create Module Documentation

Create a README.md for a module with:
- Description
- Usage example
- Input variables
- Outputs
- Requirements

### Task 2: Implement Module Features

Add the following features to a module:
```hcl
variable "enabled" {
  description = "Whether to create resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

locals {
  common_tags = merge(
    var.tags,
    {
      Terraform   = "true"
      Environment = var.environment
    }
  )
}
```

## Section 5: Troubleshooting Scenarios

### Scenario 1: Module Source Error
```bash
Error: Module not found

Unable to find module "vpc" in any of the search locations.
```

**Solution Steps:**
1. Verify module path
2. Check source attribute
3. Run terraform init

### Scenario 2: Module Output Error
```bash
Error: Reference to undeclared output value

A managed resource "aws_instance" "example" has not been declared in module.web.
```

**Solution Steps:**
1. Check output definitions
2. Verify resource names
3. Ensure module initialization

## Additional Practice Tasks

### 1. Module Refactoring
Convert monolithic configuration to modules:
```hcl
# Before
resource "aws_vpc" "main" {
  # ...
}

# After
module "vpc" {
  source = "./modules/vpc"
  # ...
}
```

### 2. Module Testing
Create module tests:
```hcl
provider "aws" {
  region = "us-east-1"
}

module "test" {
  source = "../"
  # test inputs
}

# Assertions
output "test_output" {
  value = module.test.output_value
}
```

## Best Practices Checklist

- [ ] Use consistent naming conventions
- [ ] Implement proper variable validation
- [ ] Include comprehensive documentation
- [ ] Version modules appropriately
- [ ] Test modules thoroughly
- [ ] Follow single responsibility principle

## Section 6: Advanced Module Scenarios (30 points)

### Scenario 1: Dynamic Module Configuration
hcl
locals {
  environments = {
    dev  = { instance_type = "t2.micro",  count = 1 }
    prod = { instance_type = "t2.small",  count = 2 }
  }
}

module "app" {
  for_each = local.environments
  source   = "./modules/app"

  environment    = each.key
  instance_type  = each.value.instance_type
  instance_count = each.value.count
}
```

**Task:** Explain the benefits and potential issues of this approach.

### Scenario 2: Module Composition with Dependencies
```hcl
module "vpc" {
  source = "./modules/vpc"
}

module "database" {
  source     = "./modules/database"
  subnet_ids = module.vpc.private_subnet_ids
  depends_on = [module.vpc]
}

module "application" {
  source      = "./modules/application"
  db_endpoint = module.database.endpoint
  vpc_id      = module.vpc.vpc_id
}
```

**Task:** Identify potential improvements in this configuration.

## Section 7: Module Design Patterns (20 points)

### Pattern 1: Conditional Creation
```hcl
module "backup" {
  source = "./modules/backup"
  count  = var.environment == "production" ? 1 : 0

  bucket_name = "backup-${var.environment}"
  retention   = 30
}
```

### Pattern 2: Feature Toggles
```hcl
module "monitoring" {
  source = "./modules/monitoring"

  enable_logging    = true
  enable_alerting   = var.environment == "production"
  enable_dashboard  = var.environment != "development"
}
```

## Section 8: Module Validation (15 points)

### Task 1: Implement Input Validation
```hcl
variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Task 2: Output Validation
```hcl
output "instance_ids" {
  description = "List of created instance IDs"
  value       = aws_instance.app[*].id

  precondition {
    condition     = length(aws_instance.app) > 0
    error_message = "No instances were created."
  }
}
```

## Section 9: Module Refactoring Exercise (25 points)

Convert this monolithic configuration into modular design:

```hcl
# Current Configuration
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_instance" "app" {
  count         = 2
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[count.index].id
}

resource "aws_lb" "app" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
}
```

**Task:** Break this into appropriate modules with:
- Networking module
- Compute module
- Load balancer module
- Proper variable and output definitions
- README documentation
```