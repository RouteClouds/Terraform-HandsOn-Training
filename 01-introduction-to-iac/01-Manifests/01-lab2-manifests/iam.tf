# Create IAM role for documentation access
resource "aws_iam_role" "docs_access" {
  name = "${var.project_name}-docs-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Create IAM policy for S3 access
resource "aws_iam_policy" "docs_access" {
  name        = "${var.project_name}-docs-access-policy"
  description = "Policy for documentation bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.docs.arn,
          "${aws_s3_bucket.docs.arn}/*"
        ]
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "docs_access" {
  role       = aws_iam_role.docs_access.name
  policy_arn = aws_iam_policy.docs_access.arn
} 