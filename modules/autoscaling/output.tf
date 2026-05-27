output "scale_out_policy_arn" {
  description = "ARN of the scale-out autoscaling policy"
  value       = aws_appautoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "ARN of the scale-in autoscaling policy"
  value       = aws_appautoscaling_policy.scale_in.arn
}

output "cpu_high_alarm_arn" {
  description = "ARN of the high-CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "cpu_low_alarm_arn" {
  description = "ARN of the low-CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_low.arn
}
