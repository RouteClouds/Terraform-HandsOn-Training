# Security Module Outputs

# Security Group Outputs
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "alb_security_group_arn" {
  description = "ALB security group ARN"
  value       = aws_security_group.alb.arn
}

output "ec2_security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2.id
}

output "ec2_security_group_arn" {
  description = "EC2 security group ARN"
  value       = aws_security_group.ec2.arn
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "rds_security_group_arn" {
  description = "RDS security group ARN"
  value       = aws_security_group.rds.arn
}

# IAM Role Outputs
output "ec2_iam_role_arn" {
  description = "EC2 IAM role ARN"
  value       = aws_iam_role.ec2.arn
}

output "ec2_iam_role_name" {
  description = "EC2 IAM role name"
  value       = aws_iam_role.ec2.name
}

output "ec2_iam_role_id" {
  description = "EC2 IAM role ID"
  value       = aws_iam_role.ec2.id
}

# Instance Profile Outputs
output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN"
  value       = aws_iam_instance_profile.ec2.arn
}

output "ec2_instance_profile_id" {
  description = "EC2 instance profile ID"
  value       = aws_iam_instance_profile.ec2.id
}

# KMS Outputs
output "kms_key_id" {
  description = "KMS key ID"
  value       = var.enable_kms_encryption ? aws_kms_key.main[0].key_id : null
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = var.enable_kms_encryption ? aws_kms_key.main[0].arn : null
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = var.enable_kms_encryption ? aws_kms_alias.main[0].name : null
}

