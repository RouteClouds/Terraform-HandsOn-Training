# Meta-Arguments and Lifecycle Lab

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Example using count
resource "aws_instance" "count_example" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Example using for_each with map
resource "aws_instance" "foreach_map_example" {
  for_each      = var.instance_config
  ami           = var.ami_id
  instance_type = each.value.instance_type

  tags = {
    Name        = "${var.project_name}-${each.key}"
    Environment = each.value.environment
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags
    ]
  }
}

# Example using for_each with set
resource "aws_s3_bucket" "foreach_set_example" {
  for_each = toset(var.bucket_names)
  bucket   = "${var.project_name}-${each.key}-${random_string.suffix.result}"

  lifecycle {
    prevent_destroy = true
  }
}

# Example with depends_on
resource "aws_instance" "dependent_example" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type

  depends_on = [
    aws_s3_bucket.foreach_set_example
  ]

  tags = {
    Name = "${var.project_name}-dependent-${count.index + 1}"
  }
}

# Example with lifecycle rules
resource "aws_instance" "lifecycle_example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.project_name}-lifecycle"
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy      = false
    ignore_changes      = [
      tags,
      instance_type
    ]
  }
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
} 