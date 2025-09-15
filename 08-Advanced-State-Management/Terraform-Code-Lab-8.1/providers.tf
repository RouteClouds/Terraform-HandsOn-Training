# ============================================================================
# TERRAFORM AND PROVIDER CONFIGURATION
# Topic 8: Advanced State Management with AWS
# ============================================================================

terraform {
  # Terraform version constraint - ensures compatibility and stability
  required_version = "~> 1.13.0"
  
  # Required providers with version constraints
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.12.0"
      
      # Provider configuration aliases for multi-region and disaster recovery
      configuration_aliases = [
        aws.primary,
        aws.disaster_recovery,
        aws.monitoring
      ]
    }
    
    # Random provider for generating unique resource names
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    
    # Local provider for local file operations and data processing
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    # Time provider for time-based resources and delays
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10.0"
    }
    
    # Archive provider for creating zip files
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
    
    # TLS provider for certificate generation
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
  }

  # Backend configuration will be provided via backend config file
  # This allows for flexible backend configuration per environment
  backend "s3" {
    # Configuration provided via backend.hcl file or CLI parameters
    # bucket         = "terraform-state-bucket"
    # key            = "advanced-state-management/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-locks"
    # encrypt        = true
    # kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/..."
  }
}

# ============================================================================
# PRIMARY AWS PROVIDER CONFIGURATION
# ============================================================================

# Primary AWS provider configuration for us-east-1
provider "aws" {
  alias  = "primary"
  region = var.aws_region

  # Maximum retries for API calls
  max_retries = var.max_retries
  retry_mode  = var.retry_mode

  # Default tags applied to all resources
  default_tags {
    tags = {
      Project              = var.project_name
      Environment          = var.environment
      Owner                = var.owner
      CostCenter           = var.cost_center
      ManagedBy            = "Terraform"
      TrainingModule       = "Topic-8-Advanced-State-Management"
      CreatedDate          = formatdate("YYYY-MM-DD", timestamp())
      Workspace            = terraform.workspace
      TerraformVersion     = "~> 1.13.0"
      ProviderVersion      = "~> 6.12.0"
      StateManagement      = "Advanced"
      SecurityLevel        = var.security_level
      ComplianceScope      = var.compliance_scope
      DataClassification   = var.data_classification
      BackupRequired       = "true"
      MonitoringEnabled    = "true"
      EncryptionRequired   = "true"
    }
  }

  # Assume role configuration for cross-account access
  dynamic "assume_role" {
    for_each = var.assume_role_arn != "" ? [1] : []
    content {
      role_arn     = var.assume_role_arn
      session_name = "terraform-state-management-session"
      external_id  = var.external_id
      
      tags = {
        Purpose     = "state-management"
        Environment = var.environment
        Student     = var.student_name
      }
    }
  }

  # Ignore specific tags that may be added by other AWS services
  ignore_tags {
    key_prefixes = ["aws:", "kubernetes.io/", "k8s.io/"]
    keys         = ["CreatedBy", "LastModified"]
  }
}

# ============================================================================
# DISASTER RECOVERY PROVIDER CONFIGURATION
# ============================================================================

# Disaster recovery AWS provider configuration for us-west-2
provider "aws" {
  alias  = "disaster_recovery"
  region = var.dr_region

  max_retries = var.max_retries
  retry_mode  = var.retry_mode

  default_tags {
    tags = {
      Project              = var.project_name
      Environment          = "${var.environment}-dr"
      Owner                = var.owner
      CostCenter           = var.cost_center
      ManagedBy            = "Terraform"
      TrainingModule       = "Topic-8-Advanced-State-Management"
      CreatedDate          = formatdate("YYYY-MM-DD", timestamp())
      Workspace            = terraform.workspace
      TerraformVersion     = "~> 1.13.0"
      ProviderVersion      = "~> 6.12.0"
      StateManagement      = "Advanced"
      SecurityLevel        = var.security_level
      ComplianceScope      = var.compliance_scope
      DataClassification   = var.data_classification
      DisasterRecovery     = "true"
      BackupRequired       = "true"
      MonitoringEnabled    = "true"
      EncryptionRequired   = "true"
      ReplicationSource    = var.aws_region
    }
  }

  # Cross-region assume role configuration
  dynamic "assume_role" {
    for_each = var.dr_assume_role_arn != "" ? [1] : []
    content {
      role_arn     = var.dr_assume_role_arn
      session_name = "terraform-dr-state-management-session"
      external_id  = var.external_id
      
      tags = {
        Purpose     = "disaster-recovery-state-management"
        Environment = "${var.environment}-dr"
        Student     = var.student_name
      }
    }
  }

  ignore_tags {
    key_prefixes = ["aws:", "kubernetes.io/", "k8s.io/"]
    keys         = ["CreatedBy", "LastModified"]
  }
}

# ============================================================================
# MONITORING PROVIDER CONFIGURATION
# ============================================================================

# Monitoring AWS provider configuration (can be same or different region)
provider "aws" {
  alias  = "monitoring"
  region = var.monitoring_region

  max_retries = var.max_retries
  retry_mode  = var.retry_mode

  default_tags {
    tags = {
      Project              = var.project_name
      Environment          = "${var.environment}-monitoring"
      Owner                = var.owner
      CostCenter           = var.cost_center
      ManagedBy            = "Terraform"
      TrainingModule       = "Topic-8-Advanced-State-Management"
      CreatedDate          = formatdate("YYYY-MM-DD", timestamp())
      Workspace            = terraform.workspace
      TerraformVersion     = "~> 1.13.0"
      ProviderVersion      = "~> 6.12.0"
      StateManagement      = "Advanced"
      SecurityLevel        = var.security_level
      MonitoringPurpose    = "state-management"
      AlertingEnabled      = "true"
      DashboardEnabled     = "true"
      LoggingEnabled       = "true"
    }
  }

  ignore_tags {
    key_prefixes = ["aws:", "kubernetes.io/", "k8s.io/"]
    keys         = ["CreatedBy", "LastModified"]
  }
}

# ============================================================================
# DEFAULT PROVIDER CONFIGURATION
# ============================================================================

# Default AWS provider (uses primary configuration)
provider "aws" {
  region = var.aws_region

  max_retries = var.max_retries
  retry_mode  = var.retry_mode

  default_tags {
    tags = {
      Project              = var.project_name
      Environment          = var.environment
      Owner                = var.owner
      CostCenter           = var.cost_center
      ManagedBy            = "Terraform"
      TrainingModule       = "Topic-8-Advanced-State-Management"
      CreatedDate          = formatdate("YYYY-MM-DD", timestamp())
      Workspace            = terraform.workspace
      TerraformVersion     = "~> 1.13.0"
      ProviderVersion      = "~> 6.12.0"
      StateManagement      = "Advanced"
      SecurityLevel        = var.security_level
      ComplianceScope      = var.compliance_scope
      DataClassification   = var.data_classification
    }
  }

  # Assume role configuration for cross-account access
  dynamic "assume_role" {
    for_each = var.assume_role_arn != "" ? [1] : []
    content {
      role_arn     = var.assume_role_arn
      session_name = "terraform-default-state-management-session"
      external_id  = var.external_id
      
      tags = {
        Purpose     = "default-state-management"
        Environment = var.environment
        Student     = var.student_name
      }
    }
  }

  ignore_tags {
    key_prefixes = ["aws:", "kubernetes.io/", "k8s.io/"]
    keys         = ["CreatedBy", "LastModified"]
  }
}

# ============================================================================
# PROVIDER FEATURE CONFIGURATION
# ============================================================================

# Random provider configuration
provider "random" {
  # No specific configuration required
}

# Local provider configuration
provider "local" {
  # No specific configuration required
}

# Time provider configuration
provider "time" {
  # No specific configuration required
}

# Archive provider configuration
provider "archive" {
  # No specific configuration required
}

# TLS provider configuration
provider "tls" {
  # No specific configuration required
}
