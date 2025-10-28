locals {
  common_tags = merge(
    var.tags,
    {
      Module = "monitoring"
    }
  )
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/${var.name_prefix}/application"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-log-group"
    }
  )
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  count = var.alarm_email != null ? 1 : 0
  
  name = "${var.name_prefix}-alarms"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-alarms-topic"
    }
  )
}

resource "aws_sns_topic_subscription" "alarms_email" {
  count = var.alarm_email != null ? 1 : 0
  
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name_prefix}-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ALB Metrics"
        }
      }
    ]
  })
}

data "aws_region" "current" {}

