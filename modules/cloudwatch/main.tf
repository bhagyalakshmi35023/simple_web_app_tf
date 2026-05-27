# High CPU utilization — notifies via SNS
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.service_name}-cpu-utilization-high"
  alarm_description   = "${var.service_name}: CPU above ${var.cpu_alarm_threshold}% for ${var.cpu_alarm_evaluation_periods} consecutive periods"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_alarm_period
  statistic           = var.cpu_alarm_statistic
  threshold           = var.cpu_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, { Name = "${var.service_name}-cpu-utilization-high" })
}

# High memory utilization — notifies via SNS
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.service_name}-memory-utilization-high"
  alarm_description   = "${var.service_name}: Memory above ${var.memory_alarm_threshold}% for ${var.memory_alarm_evaluation_periods} consecutive periods"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.memory_alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_alarm_period
  statistic           = var.memory_alarm_statistic
  threshold           = var.memory_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, { Name = "${var.service_name}-memory-utilization-high" })
}

# Low running task count — fires if tasks drop below threshold (crash loop / failed deploy)
resource "aws_cloudwatch_metric_alarm" "running_task_count_low" {
  alarm_name          = "${var.service_name}-running-tasks-low"
  alarm_description   = "${var.service_name}: Running tasks dropped below ${var.task_count_alarm_threshold}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.task_count_evaluation_periods
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = var.task_count_period
  statistic           = "Average"
  threshold           = var.task_count_alarm_threshold
  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, { Name = "${var.service_name}-running-tasks-low" })
}
