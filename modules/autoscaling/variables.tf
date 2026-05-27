variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service to scale"
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
}

variable "policy_type" {
  description = "Scaling policy type: StepScaling or TargetTrackingScaling"
  type        = string
}

variable "adjustment_type" {
  description = "How scaling adjustment is applied: ChangeInCapacity, ExactCapacity, or PercentChangeInCapacity"
  type        = string
}

variable "metric_aggregation_type" {
  description = "Aggregation type for the metric: Average, Minimum, or Maximum"
  type        = string
}

# ── Scale-out ────────────────────────────────────────────────
variable "scale_out_cpu_threshold" {
  description = "CPU % that triggers scale-out (add tasks)"
  type        = number
}

variable "scale_out_evaluation_periods" {
  description = "Consecutive periods CPU must be above threshold before scale-out fires"
  type        = number
}

variable "scale_out_period" {
  description = "Period in seconds for each scale-out evaluation"
  type        = number
}

variable "scale_out_statistic" {
  description = "Statistic for scale-out alarm: Average, Sum, Maximum, Minimum, SampleCount"
  type        = string
}

variable "scale_out_cooldown" {
  description = "Seconds to wait after a scale-out before another can happen"
  type        = number
}

variable "scale_out_adjustment" {
  description = "Number of tasks to add on scale-out"
  type        = number
}

# ── Scale-in ─────────────────────────────────────────────────
variable "scale_in_cpu_threshold" {
  description = "CPU % that triggers scale-in (remove tasks)"
  type        = number
}

variable "scale_in_evaluation_periods" {
  description = "Consecutive periods CPU must be below threshold before scale-in fires"
  type        = number
}

variable "scale_in_period" {
  description = "Period in seconds for each scale-in evaluation"
  type        = number
}

variable "scale_in_statistic" {
  description = "Statistic for scale-in alarm: Average, Sum, Maximum, Minimum, SampleCount"
  type        = string
}

variable "scale_in_cooldown" {
  description = "Seconds to wait after a scale-in before another can happen"
  type        = number
}

variable "scale_in_adjustment" {
  description = "Number of tasks to remove on scale-in (negative value)"
  type        = number
}

variable "tags" {
  description = "Tags to apply to autoscaling resources"
  type        = map(string)
  default     = {}
}
