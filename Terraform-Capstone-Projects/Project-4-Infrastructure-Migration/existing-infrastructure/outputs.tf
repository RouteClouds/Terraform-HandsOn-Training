# Outputs for Existing Infrastructure
# These IDs will be used for importing resources

# ============================================================================
# VPC Resources (Scenario 1)
# ============================================================================

output "vpc_id" {
  description = "VPC ID for import"
  value       = aws_vpc.existing.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID for import"
  value       = aws_internet_gateway.existing.id
}

output "public_subnet_1_id" {
  description = "Public Subnet 1 ID for import"
  value       = aws_subnet.existing_public_1.id
}

output "public_subnet_2_id" {
  description = "Public Subnet 2 ID for import"
  value       = aws_subnet.existing_public_2.id
}

output "private_subnet_1_id" {
  description = "Private Subnet 1 ID for import"
  value       = aws_subnet.existing_private_1.id
}

output "private_subnet_2_id" {
  description = "Private Subnet 2 ID for import"
  value       = aws_subnet.existing_private_2.id
}

output "public_route_table_id" {
  description = "Public Route Table ID for import"
  value       = aws_route_table.existing_public.id
}

output "public_route_table_association_1_id" {
  description = "Public Route Table Association 1 ID for import"
  value       = aws_route_table_association.existing_public_1.id
}

output "public_route_table_association_2_id" {
  description = "Public Route Table Association 2 ID for import"
  value       = aws_route_table_association.existing_public_2.id
}

# ============================================================================
# EC2 Resources (Scenario 2)
# ============================================================================

output "web_security_group_id" {
  description = "Web Security Group ID for import"
  value       = aws_security_group.existing_web.id
}

output "web_instance_1_id" {
  description = "Web Instance 1 ID for import"
  value       = aws_instance.existing_web_1.id
}

output "web_instance_2_id" {
  description = "Web Instance 2 ID for import"
  value       = aws_instance.existing_web_2.id
}

# ============================================================================
# RDS Resources (Scenario 3)
# ============================================================================

output "db_subnet_group_name" {
  description = "DB Subnet Group name for import"
  value       = aws_db_subnet_group.existing.name
}

output "db_security_group_id" {
  description = "DB Security Group ID for import"
  value       = aws_security_group.existing_db.id
}

output "db_instance_identifier" {
  description = "DB Instance identifier for import"
  value       = aws_db_instance.existing.identifier
}

output "db_endpoint" {
  description = "DB endpoint"
  value       = aws_db_instance.existing.endpoint
}

# ============================================================================
# S3 Resources (Scenario 4)
# ============================================================================

output "data_bucket_name" {
  description = "Data bucket name for import"
  value       = aws_s3_bucket.existing_data.id
}

output "logs_bucket_name" {
  description = "Logs bucket name for import"
  value       = aws_s3_bucket.existing_logs.id
}

# ============================================================================
# IAM Resources (Scenario 5)
# ============================================================================

output "app_role_name" {
  description = "App role name for import"
  value       = aws_iam_role.existing_app.name
}

output "app_policy_arn" {
  description = "App policy ARN for import"
  value       = aws_iam_policy.existing_app.arn
}

output "app_role_policy_attachment" {
  description = "Role policy attachment for import"
  value       = "${aws_iam_role.existing_app.name}/${aws_iam_policy.existing_app.arn}"
}

# ============================================================================
# Import Commands
# ============================================================================

output "import_commands" {
  description = "Terraform import commands for all resources"
  value = <<-EOT
    # Scenario 1: VPC Import Commands
    terraform import aws_vpc.main ${aws_vpc.existing.id}
    terraform import aws_internet_gateway.main ${aws_internet_gateway.existing.id}
    terraform import 'aws_subnet.public[0]' ${aws_subnet.existing_public_1.id}
    terraform import 'aws_subnet.public[1]' ${aws_subnet.existing_public_2.id}
    terraform import 'aws_subnet.private[0]' ${aws_subnet.existing_private_1.id}
    terraform import 'aws_subnet.private[1]' ${aws_subnet.existing_private_2.id}
    terraform import aws_route_table.public ${aws_route_table.existing_public.id}
    
    # Scenario 2: EC2 Import Commands
    terraform import aws_security_group.web ${aws_security_group.existing_web.id}
    terraform import 'aws_instance.web[0]' ${aws_instance.existing_web_1.id}
    terraform import 'aws_instance.web[1]' ${aws_instance.existing_web_2.id}
    
    # Scenario 3: RDS Import Commands
    terraform import aws_db_subnet_group.main ${aws_db_subnet_group.existing.name}
    terraform import aws_security_group.db ${aws_security_group.existing_db.id}
    terraform import aws_db_instance.main ${aws_db_instance.existing.identifier}
    
    # Scenario 4: S3 Import Commands
    terraform import aws_s3_bucket.data ${aws_s3_bucket.existing_data.id}
    terraform import aws_s3_bucket_versioning.data ${aws_s3_bucket.existing_data.id}
    terraform import aws_s3_bucket.logs ${aws_s3_bucket.existing_logs.id}
    
    # Scenario 5: IAM Import Commands
    terraform import aws_iam_role.app ${aws_iam_role.existing_app.name}
    terraform import aws_iam_policy.app ${aws_iam_policy.existing_app.arn}
    terraform import aws_iam_role_policy_attachment.app ${aws_iam_role.existing_app.name}/${aws_iam_policy.existing_app.arn}
  EOT
}

