# Sentinel Policy Configuration
# This file defines the policy set and enforcement levels for HCP Terraform

# Policy: Require S3 Encryption
# Ensures all S3 buckets have server-side encryption enabled
policy "require-s3-encryption" {
    source            = "./require-s3-encryption.sentinel"
    enforcement_level = "hard-mandatory"
}

# Policy: Cost Limit
# Prevents infrastructure deployments exceeding monthly cost threshold
policy "cost-limit" {
    source            = "./cost-limit.sentinel"
    enforcement_level = "soft-mandatory"
}

# Policy: Require Tags
# Enforces required tags on all AWS resources
policy "require-tags" {
    source            = "./require-tags.sentinel"
    enforcement_level = "hard-mandatory"
}

# Policy: Restrict Instance Types
# Limits EC2 instance types based on workspace/environment
policy "restrict-instance-types" {
    source            = "./restrict-instance-types.sentinel"
    enforcement_level = "soft-mandatory"
}

# Policy: Restrict Regions
# Limits AWS deployments to approved regions
policy "restrict-regions" {
    source            = "./restrict-regions.sentinel"
    enforcement_level = "hard-mandatory"
}

