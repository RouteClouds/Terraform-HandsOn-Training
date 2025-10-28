# CloudWatch Monitoring Resources
# Project 1: Multi-Tier Web Application Infrastructure

# ========================================
# CloudWatch Log Group for Application
# ========================================

resource "aws_cloudwatch_log_group" "application" {
  name              = local.log_group_name
  retention_in_days = 7
  kms_key_id        = aws_kms_key.main.arn
  
  tags = merge(
    local.common_tags,
    {
      Name = local.log_group_name
    }
  )
}

# ========================================
# SNS Topic for Alarms
# ========================================

resource "aws_sns_topic" "alarms" {
  count = var.alarm_email != "" ? 1 : 0
  
  name              = local.sns_topic_name
  display_name      = "Alarms for ${local.name_prefix}"
  kms_master_key_id = aws_kms_key.main.id
  
  tags = merge(
    local.common_tags,
    {
      Name = local.sns_topic_name
    }
  )
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "alarms_email" {
  count = var.alarm_email != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ========================================
# CloudWatch Dashboard
# ========================================

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }],
            [".", "HTTPCode_Target_2XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_4XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average" }],
            [".", "NetworkIn", { stat = "Sum" }],
            [".", "NetworkOut", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average" }],
            [".", "DatabaseConnections", { stat = "Average" }],
            [".", "FreeStorageSpace", { stat = "Average" }],
            [".", "ReadLatency", { stat = "Average" }],
            [".", "WriteLatency", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/CloudFront", "Requests", { stat = "Sum" }],
            [".", "BytesDownloaded", { stat = "Sum" }],
            [".", "4xxErrorRate", { stat = "Average" }],
            [".", "5xxErrorRate", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "CloudFront Metrics"
        }
      }
    ]
  })
}

# ========================================
# CloudWatch Alarms for ALB
# ========================================

# ALB Unhealthy Target Count
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${local.name_prefix}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "This metric monitors ALB unhealthy target count"
  alarm_actions       = local.alarm_actions
  
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.main.arn_suffix
  }
  
  tags = local.common_tags
}

# ALB Target Response Time
resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${local.name_prefix}-alb-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = local.alarm_actions
  
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
  
  tags = local.common_tags
}

# ALB 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${local.name_prefix}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "This metric monitors ALB 5XX errors"
  alarm_actions       = local.alarm_actions
  
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
  
  tags = local.common_tags
}

# ========================================
# CloudWatch Alarms for CloudFront
# ========================================

# CloudFront 5XX Error Rate
resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_errors" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${local.name_prefix}-cloudfront-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "This metric monitors CloudFront 5XX error rate"
  alarm_actions       = local.alarm_actions
  
  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
  }
  
  tags = local.common_tags
}

# ========================================
# CloudWatch Metric Filters
# ========================================

# Error Log Metric Filter
resource "aws_cloudwatch_log_metric_filter" "error_logs" {
  name           = "${local.name_prefix}-error-logs"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "[time, request_id, event_type = ERROR*, ...]"
  
  metric_transformation {
    name      = "ErrorCount"
    namespace = "${local.name_prefix}/Application"
    value     = "1"
    unit      = "Count"
  }
}

# Error Log Alarm
resource "aws_cloudwatch_metric_alarm" "error_logs" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${local.name_prefix}-error-logs"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorCount"
  namespace           = "${local.name_prefix}/Application"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "This metric monitors application error logs"
  alarm_actions       = local.alarm_actions
  
  tags = local.common_tags
}

# ========================================
# CloudWatch Insights Queries
# ========================================

resource "aws_cloudwatch_query_definition" "top_errors" {
  name = "${local.name_prefix}-top-errors"
  
  log_group_names = [
    aws_cloudwatch_log_group.application.name
  ]
  
  query_string = <<-QUERY
    fields @timestamp, @message
    | filter @message like /ERROR/
    | stats count() by @message
    | sort count desc
    | limit 20
  QUERY
}

resource "aws_cloudwatch_query_definition" "slow_requests" {
  name = "${local.name_prefix}-slow-requests"
  
  log_group_names = [
    aws_cloudwatch_log_group.application.name
  ]
  
  query_string = <<-QUERY
    fields @timestamp, request_id, duration
    | filter duration > 1000
    | sort duration desc
    | limit 20
  QUERY
}

# ========================================
# CloudWatch Composite Alarm
# ========================================

resource "aws_cloudwatch_composite_alarm" "application_health" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${local.name_prefix}-application-health"
  alarm_description   = "Composite alarm for overall application health"
  actions_enabled     = true
  alarm_actions       = local.alarm_actions
  
  alarm_rule = join(" OR ", [
    "ALARM(${aws_cloudwatch_metric_alarm.alb_unhealthy_targets[0].alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.cpu_high.alarm_name})",
    "ALARM(${aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name})"
  ])
  
  tags = local.common_tags
}

# ========================================
# EventBridge Rule for Auto Scaling Events
# ========================================

resource "aws_cloudwatch_event_rule" "asg_events" {
  name        = "${local.name_prefix}-asg-events"
  description = "Capture Auto Scaling events"
  
  event_pattern = jsonencode({
    source      = ["aws.autoscaling"]
    detail-type = ["EC2 Instance Launch Successful", "EC2 Instance Terminate Successful"]
    detail = {
      AutoScalingGroupName = [aws_autoscaling_group.main.name]
    }
  })
  
  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "asg_events_sns" {
  count = var.alarm_email != "" ? 1 : 0
  
  rule      = aws_cloudwatch_event_rule.asg_events.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.alarms[0].arn
}

