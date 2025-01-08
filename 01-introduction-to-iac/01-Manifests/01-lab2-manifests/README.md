# Lab 2: Documentation and Version Control Setup

This lab demonstrates how to set up infrastructure for maintaining documentation with version control using S3.

## Resources Created
- S3 Bucket with versioning enabled
- Documentation storage configuration
- Access management setup

## Prerequisites
- AWS Account
- Terraform installed
- AWS CLI configured
- Basic understanding of S3 and versioning

## Usage

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review Configuration
```bash
terraform plan
```

### 3. Apply Configuration
```bash
terraform apply
```

### 4. Upload Documentation
After applying, you can upload documentation using AWS CLI:
```bash
aws s3 cp ./docs/ s3://[bucket-name]/ --recursive
```

## Variables
- aws_region: AWS region for deployment
- environment: Environment name (dev, prod, etc.)
- project_name: Project name for resource naming
- bucket_versioning: Enable/disable bucket versioning
- tags: Common tags for resources

## Outputs
- docs_bucket_name: Name of created S3 bucket
- docs_bucket_arn: ARN of S3 bucket
- bucket_versioning_status: Versioning status
- bucket_region: Bucket region

## Best Practices
1. Always enable versioning for documentation
2. Use meaningful tags for resource management
3. Implement proper access controls
4. Regular backup and monitoring

## Clean Up
To destroy the created resources:
```bash
terraform destroy
``` 