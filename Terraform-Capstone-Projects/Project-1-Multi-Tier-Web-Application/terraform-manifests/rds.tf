# RDS Database Resources
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# DB Subnet Group
# ========================================

resource "aws_db_subnet_group" "main" {
  name       = local.db_subnet_group_name
  subnet_ids = aws_subnet.private[*].id
  
  tags = merge(
    local.common_tags,
    {
      Name = local.db_subnet_group_name
    }
  )
}

# ========================================
# DB Parameter Group
# ========================================

resource "aws_db_parameter_group" "main" {
  name   = local.db_parameter_group_name
  family = var.db_engine == "postgres" ? "postgres15" : "mysql8.0"
  
  description = "Custom parameter group for ${local.name_prefix}"
  
  # PostgreSQL parameters
  dynamic "parameter" {
    for_each = var.db_engine == "postgres" ? [1] : []
    content {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    }
  }
  
  dynamic "parameter" {
    for_each = var.db_engine == "postgres" ? [1] : []
    content {
      name  = "log_statement"
      value = "all"
    }
  }
  
  dynamic "parameter" {
    for_each = var.db_engine == "postgres" ? [1] : []
    content {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  }
  
  # MySQL parameters
  dynamic "parameter" {
    for_each = var.db_engine == "mysql" ? [1] : []
    content {
      name  = "slow_query_log"
      value = "1"
    }
  }
  
  dynamic "parameter" {
    for_each = var.db_engine == "mysql" ? [1] : []
    content {
      name  = "long_query_time"
      value = "2"
    }
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = local.db_parameter_group_name
    }
  )
}

# ========================================
# DB Option Group (for MySQL)
# ========================================

resource "aws_db_option_group" "main" {
  count = var.db_engine == "mysql" ? 1 : 0
  
  name                     = "${local.name_prefix}-db-options"
  option_group_description = "Option group for ${local.name_prefix}"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-db-options"
    }
  )
}

# ========================================
# RDS Instance
# ========================================

resource "aws_db_instance" "main" {
  identifier = local.rds_identifier
  
  # Engine configuration
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true
  kms_key_id           = aws_kms_key.main.arn
  
  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_engine == "postgres" ? 5432 : 3306
  
  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  
  # High availability
  multi_az = var.db_multi_az
  
  # Backup configuration
  backup_retention_period   = var.db_backup_retention_period
  backup_window             = "03:00-04:00"
  maintenance_window        = "mon:04:00-mon:05:00"
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = var.environment == "dev" ? true : false
  final_snapshot_identifier = var.environment == "dev" ? null : "${local.rds_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # Parameter and option groups
  parameter_group_name = aws_db_parameter_group.main.name
  option_group_name    = var.db_engine == "mysql" ? aws_db_option_group.main[0].name : null
  
  # Monitoring
  enabled_cloudwatch_logs_exports = var.db_engine == "postgres" ? ["postgresql", "upgrade"] : ["error", "general", "slowquery"]
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.main.arn
  performance_insights_retention_period = 7
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = true
  
  # Deletion protection
  deletion_protection = var.environment == "prod" ? true : false
  
  tags = merge(
    local.common_tags,
    {
      Name = local.rds_identifier
    }
  )
  
  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}

# ========================================
# IAM Role for RDS Enhanced Monitoring
# ========================================

resource "aws_iam_role" "rds_monitoring" {
  name = "${local.name_prefix}-rds-monitoring-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ========================================
# RDS Read Replica (Optional)
# ========================================

resource "aws_db_instance" "read_replica" {
  count = var.environment == "prod" ? 1 : 0
  
  identifier             = "${local.rds_identifier}-read-replica"
  replicate_source_db    = aws_db_instance.main.identifier
  instance_class         = var.db_instance_class
  publicly_accessible    = false
  skip_final_snapshot    = true
  
  # Monitoring
  monitoring_interval  = 60
  monitoring_role_arn  = aws_iam_role.rds_monitoring.arn
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.rds_identifier}-read-replica"
      Type = "ReadReplica"
    }
  )
}

# ========================================
# CloudWatch Alarms for RDS
# ========================================

# High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.name_prefix}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = local.alarm_actions
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
  
  tags = local.common_tags
}

# Low Free Storage Space Alarm
resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${local.name_prefix}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5000000000  # 5 GB in bytes
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = local.alarm_actions
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
  
  tags = local.common_tags
}

# High Database Connections Alarm
resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${local.name_prefix}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors RDS database connections"
  alarm_actions       = local.alarm_actions
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
  
  tags = local.common_tags
}

