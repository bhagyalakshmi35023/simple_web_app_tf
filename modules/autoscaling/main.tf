resource "aws_appautoscaling_target" "main" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

# Scale-out — adds tasks when CPU is high
resource "aws_appautoscaling_policy" "scale_out" {
  name               = "${var.service_name}-scale-out"
  service_namespace  = aws_appautoscaling_target.main.service_namespace
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  policy_type        = var.policy_type

  step_scaling_policy_configuration {
    adjustment_type         = var.adjustment_type
    cooldown                = var.scale_out_cooldown
    metric_aggregation_type = var.metric_aggregation_type

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.scale_out_adjustment
    }
  }
}

# Scale-in — removes tasks when CPU is low
resource "aws_appautoscaling_policy" "scale_in" {
  name               = "${var.service_name}-scale-in"
  service_namespace  = aws_appautoscaling_target.main.service_namespace
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  policy_type        = var.policy_type

  step_scaling_policy_configuration {
    adjustment_type         = var.adjustment_type
    cooldown                = var.scale_in_cooldown
    metric_aggregation_type = var.metric_aggregation_type

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scale_in_adjustment
    }
  }
}

# Scale-out alarm — triggers scale-out policy
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.service_name}-cpu-high"
  alarm_description   = "Scale out ${var.service_name} — CPU above ${var.scale_out_cpu_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.scale_out_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_out_period
  statistic           = var.scale_out_statistic
  threshold           = var.scale_out_cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_out.arn]

  tags = merge(var.tags, { Name = "${var.service_name}-cpu-high" })
}

# Scale-in alarm — triggers scale-in policy
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.service_name}-cpu-low"
  alarm_description   = "Scale in ${var.service_name} — CPU below ${var.scale_in_cpu_threshold}%"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.scale_in_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_in_period
  statistic           = var.scale_in_statistic
  threshold           = var.scale_in_cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_in.arn]

  tags = merge(var.tags, { Name = "${var.service_name}-cpu-low" })
}
