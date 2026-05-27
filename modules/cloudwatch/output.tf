output "cpu_alarm_arn" {
  description = "ARN of the high CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "memory_alarm_arn" {
  description = "ARN of the high memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.memory_high.arn
}

output "task_count_alarm_arn" {
  description = "ARN of the low running task count alarm"
  value       = aws_cloudwatch_metric_alarm.running_task_count_low.arn
}
