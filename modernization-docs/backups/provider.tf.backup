# Provider Configurations
provider "aws" {
  region = var.primary_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Region    = var.primary_region
        Provider  = "Primary"
        Lab       = "Multi-Provider"
      }
    )
  }
}

provider "aws" {
  alias  = "west"
  region = var.secondary_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Region    = var.secondary_region
        Provider  = "Secondary"
        Lab       = "Multi-Provider"
      }
    )
  }
}

# Provider Validations
data "aws_regions" "available" {}

locals {
  # Validate regions
  valid_regions = data.aws_regions.available.names
  is_primary_region_valid = contains(local.valid_regions, var.primary_region)
  is_secondary_region_valid = contains(local.valid_regions, var.secondary_region)
  
  # Validate CIDR blocks
  is_primary_vpc_cidr_valid = can(cidrhost(var.primary_vpc_cidr, 0))
  is_secondary_vpc_cidr_valid = can(cidrhost(var.secondary_vpc_cidr, 0))
  
  # Validate CIDR overlap
  cidr_overlap = cidrsubnet(var.primary_vpc_cidr, 0, 0) == cidrsubnet(var.secondary_vpc_cidr, 0, 0)

  # Validate AMIs per region
  primary_ami_validation = {
    region = var.primary_region
    ami_id = var.primary_ami_id
  }
  
  secondary_ami_validation = {
    region = var.secondary_region
    ami_id = var.secondary_ami_id
  }

  # Validate project name
  is_project_name_valid = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))

  # Required tags validation
  required_tags = ["Owner", "Environment", "Project"]
  has_required_tags = alltrue([
    for tag in local.required_tags : contains(keys(var.tags), tag)
  ])

  # Additional CIDR validations
  vpc_cidr_size_valid = {
    primary   = tonumber(split("/", var.primary_vpc_cidr)[1]) <= 16
    secondary = tonumber(split("/", var.secondary_vpc_cidr)[1]) <= 16
  }

  # Instance type validations
  allowed_instance_types = ["t2.micro", "t2.small", "t2.medium"]
  is_instance_type_valid = contains(local.allowed_instance_types, var.instance_type)

  # Cross-region validation
  regions_are_different = var.primary_region != var.secondary_region

  # AMI ownership validation
  ami_owner_id = "amazon"  # AWS owned AMIs
  primary_ami_exists = can(data.aws_ami.primary_ami[0].id)
  secondary_ami_exists = can(data.aws_ami.secondary_ami[0].id)

  # Tag value validations
  environment_values = ["Development", "Production", "Staging"]
  is_environment_valid = contains(local.environment_values, var.tags["Environment"])

  # Resource naming convention
  resource_name_pattern = "^[a-z][a-z0-9-]*[a-z0-9]$"
  resource_names_valid = {
    project = can(regex(local.resource_name_pattern, var.project_name))
    primary_vpc = can(regex(local.resource_name_pattern, "${var.project_name}-primary-vpc"))
    secondary_vpc = can(regex(local.resource_name_pattern, "${var.project_name}-secondary-vpc"))
  }

  # Cost tag validation
  cost_center_tags = ["CostCenter", "Department", "Project"]
  has_cost_tags = alltrue([
    for tag in local.cost_center_tags : contains(keys(var.tags), tag)
  ])

  # Security validation
  security_tags = ["Confidentiality", "Compliance"]
  has_security_tags = alltrue([
    for tag in local.security_tags : contains(keys(var.tags), tag)
  ])
}

# AMI validation data sources
data "aws_ami" "primary_ami" {
  count = 1
  owners = [local.ami_owner_id]
  filter {
    name   = "image-id"
    values = [var.primary_ami_id]
  }
}

data "aws_ami" "secondary_ami" {
  provider = aws.west
  count = 1
  owners = [local.ami_owner_id]
  filter {
    name   = "image-id"
    values = [var.secondary_ami_id]
  }
}

# Enhanced validation checks
resource "null_resource" "validations" {
  lifecycle {
    precondition {
      condition = (
        local.is_primary_region_valid &&
        local.is_secondary_region_valid &&
        local.is_primary_vpc_cidr_valid &&
        local.is_secondary_vpc_cidr_valid &&
        !local.cidr_overlap &&
        local.is_project_name_valid &&
        local.has_required_tags &&
        local.vpc_cidr_size_valid.primary &&
        local.vpc_cidr_size_valid.secondary &&
        local.is_instance_type_valid &&
        local.regions_are_different &&
        local.primary_ami_exists &&
        local.secondary_ami_exists &&
        local.is_environment_valid &&
        alltrue([for v in local.resource_names_valid : v]) &&
        local.has_cost_tags &&
        local.has_security_tags
      )
      error_message = "One or more validation checks failed. Please check your configuration."
    }
  }
}

# Enhanced validation outputs
output "validation_status" {
  value = {
    primary_region = {
      status  = local.is_primary_region_valid
      message = local.is_primary_region_valid ? "Valid" : "Invalid primary region specified"
    }
    secondary_region = {
      status  = local.is_secondary_region_valid
      message = local.is_secondary_region_valid ? "Valid" : "Invalid secondary region specified"
    }
    vpc_cidrs = {
      primary_valid   = local.is_primary_vpc_cidr_valid
      secondary_valid = local.is_secondary_vpc_cidr_valid
      no_overlap     = !local.cidr_overlap
      message        = local.cidr_overlap ? "VPC CIDR blocks overlap" : "VPC CIDR blocks are valid"
    }
    project_name = {
      status  = local.is_project_name_valid
      message = local.is_project_name_valid ? "Valid" : "Invalid project name format"
    }
    tags = {
      status  = local.has_required_tags
      message = local.has_required_tags ? "All required tags present" : "Missing required tags"
    }
    vpc_cidr_sizes = {
      primary   = local.vpc_cidr_size_valid.primary
      secondary = local.vpc_cidr_size_valid.secondary
      message   = alltrue([local.vpc_cidr_size_valid.primary, local.vpc_cidr_size_valid.secondary]) ? "Valid VPC CIDR sizes" : "VPC CIDR must be /16 or larger"
    }
    instance_type = {
      status  = local.is_instance_type_valid
      message = local.is_instance_type_valid ? "Valid instance type" : "Invalid instance type specified"
    }
    region_separation = {
      status  = local.regions_are_different
      message = local.regions_are_different ? "Regions are different" : "Primary and secondary regions must be different"
    }
    ami_validation = {
      primary   = local.primary_ami_exists
      secondary = local.secondary_ami_exists
      message   = alltrue([local.primary_ami_exists, local.secondary_ami_exists]) ? "Valid AMIs" : "One or more AMIs not found"
    }
    environment = {
      status  = local.is_environment_valid
      message = local.is_environment_valid ? "Valid environment value" : "Invalid environment specified"
    }
    resource_naming = {
      status  = alltrue([for v in local.resource_names_valid : v])
      details = local.resource_names_valid
      message = alltrue([for v in local.resource_names_valid : v]) ? "Valid resource names" : "One or more resource names invalid"
    }
    cost_tracking = {
      status  = local.has_cost_tags
      message = local.has_cost_tags ? "Cost tracking tags present" : "Missing required cost tracking tags"
    }
    security = {
      status  = local.has_security_tags
      message = local.has_security_tags ? "Security tags present" : "Missing required security tags"
    }
  }
} 