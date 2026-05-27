variable "service_name" {
  description = "ECS service name — used in alarm names and dimensions"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name — used in CloudWatch dimensions"
  type        = string
}

# ── CPU alarm ────────────────────────────────────────────────
variable "cpu_alarm_threshold" {
  description = "CPU % that triggers the high-CPU alert alarm"
  type        = number
}

variable "cpu_alarm_evaluation_periods" {
  description = "Consecutive periods CPU must exceed threshold before alarm fires"
  type        = number
}

variable "cpu_alarm_period" {
  description = "Period in seconds for each CPU evaluation"
  type        = number
}

variable "cpu_alarm_statistic" {
  description = "Statistic for CPU alarm: Average, Sum, Maximum, Minimum, SampleCount"
  type        = string
}

# ── Memory alarm ─────────────────────────────────────────────
variable "memory_alarm_threshold" {
  description = "Memory % that triggers the high-memory alert alarm"
  type        = number
}

variable "memory_alarm_evaluation_periods" {
  description = "Consecutive periods memory must exceed threshold before alarm fires"
  type        = number
}

variable "memory_alarm_period" {
  description = "Period in seconds for each memory evaluation"
  type        = number
}

variable "memory_alarm_statistic" {
  description = "Statistic for memory alarm: Average, Sum, Maximum, Minimum, SampleCount"
  type        = string
}

# ── Task count alarm ─────────────────────────────────────────
variable "task_count_alarm_threshold" {
  description = "Minimum number of running tasks — alarm fires if count drops below this"
  type        = number
}

variable "task_count_evaluation_periods" {
  description = "Consecutive periods task count must be below threshold before alarm fires"
  type        = number
}

variable "task_count_period" {
  description = "Period in seconds for each task count evaluation"
  type        = number
}

# ── Notification ─────────────────────────────────────────────
variable "sns_topic_arn" {
  description = "SNS topic ARN to notify when any alarm fires or clears"
  type        = string
}

variable "tags" {
  description = "Tags to apply to CloudWatch alarms"
  type        = map(string)
  default     = {}
}
