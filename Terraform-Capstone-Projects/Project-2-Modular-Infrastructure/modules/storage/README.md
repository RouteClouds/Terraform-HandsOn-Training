# Storage Module

This module creates S3 buckets with versioning, encryption, and lifecycle policies.

## Features

- ✅ S3 bucket creation
- ✅ Versioning support
- ✅ KMS encryption
- ✅ Lifecycle policies
- ✅ Access logging
- ✅ Customizable tags

## Usage

```hcl
module "storage" {
  source = "./modules/storage"
  
  bucket_name         = "my-app-bucket"
  enable_versioning   = true
  enable_encryption   = true
  kms_key_id          = module.security.kms_key_id
  
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

## Version History

- **v1.0.0** (2025-10-27): Initial release

## Authors

RouteCloud Training Team

