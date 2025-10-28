# Database Module

This module creates an RDS database instance with configurable engine and Multi-AZ support.

## Features

- ✅ Configurable database engine (PostgreSQL, MySQL, MariaDB)
- ✅ Multi-AZ deployment for high availability
- ✅ Automated backups with configurable retention
- ✅ KMS encryption at rest
- ✅ DB subnet group creation
- ✅ Parameter group customization
- ✅ Enhanced monitoring (optional)
- ✅ Read replica support (optional)
- ✅ Customizable tags

## Usage

### Basic Example

```hcl
module "database" {
  source = "./modules/database"
  
  identifier          = "myapp-db"
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  
  db_name  = "myappdb"
  username = "admin"
  password = var.db_password  # Use sensitive variable
  
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.rds_security_group_id]
  
  multi_az = false
  
  tags = {
    Environment = "dev"
    Project     = "modular-infrastructure"
  }
}
```

### Production Example with Multi-AZ

```hcl
module "database" {
  source = "./modules/database"
  
  identifier          = "prod-db"
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = "db.t3.small"
  allocated_storage   = 100
  max_allocated_storage = 500  # Enable storage autoscaling
  
  db_name  = "proddb"
  username = "admin"
  password = var.db_password
  
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.rds_security_group_id]
  
  multi_az                  = true
  backup_retention_period   = 30
  enabled_cloudwatch_logs_exports = ["postgresql"]
  enable_enhanced_monitoring = true
  
  kms_key_id = module.security.kms_key_id
  
  tags = {
    Environment = "production"
    Project     = "modular-infrastructure"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.0 |
| aws | >= 6.12.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identifier | Database identifier | `string` | n/a | yes |
| engine | Database engine | `string` | `"postgres"` | no |
| engine_version | Database engine version | `string` | n/a | yes |
| instance_class | Database instance class | `string` | n/a | yes |
| allocated_storage | Allocated storage in GB | `number` | `20` | no |
| max_allocated_storage | Maximum storage for autoscaling | `number` | `null` | no |
| db_name | Database name | `string` | n/a | yes |
| username | Master username | `string` | n/a | yes |
| password | Master password | `string` | n/a | yes |
| vpc_id | VPC ID | `string` | n/a | yes |
| subnet_ids | List of subnet IDs | `list(string)` | n/a | yes |
| security_group_ids | List of security group IDs | `list(string)` | n/a | yes |
| multi_az | Enable Multi-AZ | `bool` | `false` | no |
| backup_retention_period | Backup retention in days | `number` | `7` | no |
| kms_key_id | KMS key ID for encryption | `string` | `null` | no |
| enable_enhanced_monitoring | Enable enhanced monitoring | `bool` | `false` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | Database instance ID |
| db_instance_arn | Database instance ARN |
| db_instance_endpoint | Database endpoint |
| db_instance_address | Database address |
| db_instance_port | Database port |
| db_subnet_group_name | DB subnet group name |

## Resources Created

- 1 RDS DB Instance
- 1 DB Subnet Group
- 1 DB Parameter Group (optional)
- 1 IAM Role for Enhanced Monitoring (optional)

## Examples

### Example 1: Development Database

```hcl
module "dev_db" {
  source = "./modules/database"
  
  identifier        = "dev-db"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  
  db_name  = "devdb"
  username = "admin"
  password = var.db_password
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.rds_security_group_id]
  
  multi_az                = false
  backup_retention_period = 1
  
  tags = {
    Environment = "dev"
  }
}
```

### Example 2: Production Database with Read Replica

```hcl
# Primary database
module "prod_db" {
  source = "./modules/database"
  
  identifier        = "prod-db"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.r6g.large"
  allocated_storage = 500
  
  db_name  = "proddb"
  username = "admin"
  password = var.db_password
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.rds_security_group_id]
  
  multi_az                  = true
  backup_retention_period   = 30
  enable_enhanced_monitoring = true
  
  tags = {
    Environment = "production"
  }
}
```

## Notes

- **Password Security**: Always use sensitive variables for passwords
- **Multi-AZ**: Enable for production for high availability
- **Backups**: Configure appropriate retention period
- **Encryption**: Enable KMS encryption for production
- **Monitoring**: Enable enhanced monitoring for production

## Version History

- **v1.0.0** (2025-10-27): Initial release

## Authors

RouteCloud Training Team

