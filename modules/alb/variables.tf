variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
}

variable "load_balancer_type" {
  description = "Type of load balancer: application, network, or gateway"
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the target groups"
  type        = string
}

variable "listener_port" {
  description = "Port the ALB listener listens on"
  type        = number
}

variable "listener_protocol" {
  description = "Protocol for the ALB listener"
  type        = string
}

variable "default_target_group_key" {
  description = "Key in var.target_groups to use as the default listener action"
  type        = string
}

variable "target_groups" {
  description = "Map of target group configurations — one per container service"
  type = map(object({
    name                = string
    port                = number
    protocol            = string
    target_type         = string
    health_check_path   = string
    health_check_matcher = string
    health_check_interval = number
    health_check_timeout  = number
    healthy_threshold     = number
    unhealthy_threshold   = number
  }))
}

variable "listener_rules" {
  description = "Map of path-based listener rules. Each rule routes a path pattern to a target group key."
  type = map(object({
    priority         = number
    path_pattern     = string
    target_group_key = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all ALB resources"
  type        = map(string)
  default     = {}
}
