# S3 Storage Resources
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# S3 Bucket for Static Assets
# ========================================

resource "aws_s3_bucket" "static_assets" {
  bucket = local.s3_bucket_name
  
  tags = merge(
    local.common_tags,
    {
      Name = local.s3_bucket_name
      Type = "StaticAssets"
    }
  )
}

# ========================================
# S3 Bucket Versioning
# ========================================

resource "aws_s3_bucket_versioning" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  
  versioning_configuration {
    status = var.s3_versioning_enabled ? "Enabled" : "Suspended"
  }
}

# ========================================
# S3 Bucket Encryption
# ========================================

resource "aws_s3_bucket_server_side_encryption_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

# ========================================
# S3 Bucket Public Access Block
# ========================================

resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ========================================
# S3 Bucket Lifecycle Configuration
# ========================================

resource "aws_s3_bucket_lifecycle_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  
  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 180
      storage_class = "GLACIER_IR"
    }
    
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  
  rule {
    id     = "delete-incomplete-multipart-uploads"
    status = "Enabled"
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ========================================
# S3 Bucket CORS Configuration
# ========================================

resource "aws_s3_bucket_cors_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# ========================================
# S3 Bucket Policy for CloudFront OAI
# ========================================

resource "aws_s3_bucket_policy" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAI"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.main.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_assets.arn}/*"
      },
      {
        Sid    = "AllowEC2ReadAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2.arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.static_assets.arn,
          "${aws_s3_bucket.static_assets.arn}/*"
        ]
      }
    ]
  })
  
  depends_on = [
    aws_s3_bucket_public_access_block.static_assets
  ]
}

# ========================================
# S3 Bucket Logging
# ========================================

resource "aws_s3_bucket" "logs" {
  bucket = "${local.name_prefix}-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-logs"
      Type = "Logs"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  rule {
    id     = "delete-old-logs"
    status = "Enabled"
    
    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_logging" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

# ========================================
# S3 Bucket Notification (Optional)
# ========================================

# Uncomment to enable S3 event notifications
# resource "aws_s3_bucket_notification" "static_assets" {
#   bucket = aws_s3_bucket.static_assets.id
#
#   topic {
#     topic_arn     = aws_sns_topic.s3_events.arn
#     events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#     filter_prefix = "uploads/"
#   }
# }

# ========================================
# S3 Bucket Inventory (Optional)
# ========================================

resource "aws_s3_bucket_inventory" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  name   = "EntireBucketInventory"
  
  included_object_versions = "All"
  
  schedule {
    frequency = "Weekly"
  }
  
  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.logs.arn
      prefix     = "inventory"
    }
  }
}

# ========================================
# S3 Bucket Metrics
# ========================================

resource "aws_s3_bucket_metric" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  name   = "EntireBucket"
}

# ========================================
# S3 Bucket Intelligent Tiering
# ========================================

resource "aws_s3_bucket_intelligent_tiering_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  name   = "EntireBucket"
  
  status = "Enabled"
  
  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
  
  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }
}

