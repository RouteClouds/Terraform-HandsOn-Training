# Local Values
# Project 1: Multi-Tier Web Application Infrastructure

locals {
  # Naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Region      = data.aws_region.current.name
      AccountId   = data.aws_caller_identity.current.account_id
    }
  )
  
  # VPC configuration
  vpc_name = "${local.name_prefix}-vpc"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  
  # Subnet configuration
  public_subnet_names = [
    for idx, az in local.azs : "${local.name_prefix}-public-${element(split("-", az), length(split("-", az)) - 1)}"
  ]
  
  private_subnet_names = [
    for idx, az in local.azs : "${local.name_prefix}-private-${element(split("-", az), length(split("-", az)) - 1)}"
  ]
  
  # Security group names
  alb_sg_name = "${local.name_prefix}-alb-sg"
  ec2_sg_name = "${local.name_prefix}-ec2-sg"
  rds_sg_name = "${local.name_prefix}-rds-sg"
  
  # Resource names
  alb_name              = "${local.name_prefix}-alb"
  target_group_name     = "${local.name_prefix}-tg"
  launch_template_name  = "${local.name_prefix}-lt"
  asg_name              = "${local.name_prefix}-asg"
  rds_identifier        = "${local.name_prefix}-db"
  s3_bucket_name        = var.s3_bucket_name != "" ? var.s3_bucket_name : "${local.name_prefix}-static-assets-${data.aws_caller_identity.current.account_id}"
  cloudfront_origin_id  = "S3-${local.s3_bucket_name}"
  
  # IAM role names
  ec2_role_name = "${local.name_prefix}-ec2-role"
  
  # CloudWatch configuration
  log_group_name = "/aws/ec2/${local.name_prefix}"
  
  # SNS topic name
  sns_topic_name = "${local.name_prefix}-alarms"
  
  # User data for EC2 instances
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    environment    = var.environment
    project_name   = var.project_name
    log_group_name = local.log_group_name
    region         = var.aws_region
  }))
  
  # Database configuration
  db_subnet_group_name    = "${local.name_prefix}-db-subnet-group"
  db_parameter_group_name = "${local.name_prefix}-db-params"
  
  # Route53 configuration
  domain_name = var.domain_name != "" ? var.domain_name : "${local.name_prefix}.example.com"
  
  # ALB target health check
  health_check = {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
  }
  
  # Auto Scaling configuration
  asg_tags = [
    {
      key                 = "Name"
      value               = "${local.name_prefix}-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "ManagedBy"
      value               = "Terraform"
      propagate_at_launch = true
    }
  ]
  
  # CloudFront configuration
  cloudfront_comment = "CDN for ${local.name_prefix} static assets"
  
  # Monitoring configuration
  alarm_actions = var.alarm_email != "" ? [aws_sns_topic.alarms[0].arn] : []
}

