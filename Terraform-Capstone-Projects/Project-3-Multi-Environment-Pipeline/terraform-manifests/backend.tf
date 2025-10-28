# Backend Configuration
# This file defines the remote state backend
# Actual values are provided via backend-config.hcl files

terraform {
  backend "s3" {
    # Configuration provided via -backend-config flag
    # See environments/{env}/backend-config.hcl
  }
}

