# ============================================================
# GLOBAL
# ============================================================
variable "project_name" {
  description = "Project name prefix used for all resource names."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
}

variable "common_tags" {
  description = "Tags applied to every resource. Merged with resource-specific Name tag."
  type        = map(string)
}

# ============================================================
# VPC
# ============================================================
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC."
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS resolution in the VPC."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for instances in the VPC."
  type        = bool
}

# ============================================================
# SUBNETS
# ============================================================
variable "subnets" {
  description = "Ordered list of subnet configs. Index position maps to local.tf references."
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

# ============================================================
# EIP
# ============================================================
variable "eip_name" {
  description = "Name tag for the NAT Gateway EIP."
  type        = string
}

variable "eip_domain" {
  description = "Domain for the EIP — always 'vpc' for VPC-attached resources."
  type        = string
}

# ============================================================
# NAT GATEWAY
# ============================================================
variable "nat_gateway_name" {
  description = "Name tag for the NAT Gateway."
  type        = string
}

# ============================================================
# INTERNET GATEWAY
# ============================================================
variable "internet_gateway_name" {
  description = "Name tag for the Internet Gateway."
  type        = string
}

# ============================================================
# ROUTE TABLES
# ============================================================
variable "route_table_cidr_block" {
  description = "Destination CIDR block for all default routes (e.g. 0.0.0.0/0)."
  type        = string
}

variable "public_route_table_name" {
  description = "Name tag for the public route table."
  type        = string
}

variable "private_route_table_name" {
  description = "Name tag for the private route table."
  type        = string
}

# ============================================================
# SECURITY GROUPS
# ============================================================
variable "alb_security_group_key" {
  description = "Key in var.security_groups to attach to the ALB."
  type        = string
}

variable "security_groups" {
  description = "Map of security group configurations."
  type = map(object({
    name        = string
    description = string
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}

# ============================================================
# IAM
# ============================================================
variable "iam_roles" {
  description = "Map of IAM role configurations."
  type = map(object({
    role_name   = string
    policy_arns = list(string)
  }))
}

# ============================================================
# ALB
# ============================================================
variable "alb" {
  description = "Map of ALB configurations."
  type = map(object({
    name                     = string
    internal                 = bool
    load_balancer_type       = string
    listener_port            = number
    listener_protocol        = string
    default_target_group_key = string
    target_groups = map(object({
      name                  = string
      port                  = number
      protocol              = string
      target_type           = string
      health_check_path     = string
      health_check_matcher  = string
      health_check_interval = number
      health_check_timeout  = number
      healthy_threshold     = number
      unhealthy_threshold   = number
    }))
    listener_rules = map(object({
      priority         = number
      path_pattern     = string
      target_group_key = string
    }))
  }))
}

# ============================================================
# ECS
# ============================================================
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "ecs_services" {
  description = "Map of ECS service + task definition configurations."
  type = map(object({
    service_name       = string
    desired_count      = number
    launch_type        = string
    network_mode       = string
    assign_public_ip   = bool
    task_family        = string
    task_cpu           = string
    task_memory        = string
    container_name     = string
    container_image    = string
    container_port     = number
    container_protocol = string
    log_group          = string
    log_retention_days = number
    log_driver         = string
    log_stream_prefix  = string
    execution_role_key = string
    task_role_key      = string
    alb_key            = string
    target_group_key   = string
    security_group_key = string
  }))
}

# ============================================================
# ECR
# ============================================================
variable "ecr_repositories" {
  description = "Map of ECR repository configurations."
  type = map(object({
    name                           = string
    image_tag_mutability           = string
    scan_on_push                   = bool
    max_image_count                = number
    lifecycle_policy_rule_priority = number
    lifecycle_tag_status           = string
    lifecycle_count_type           = string
    lifecycle_action_type          = string
  }))
}

# ============================================================
# AUTOSCALING
# ============================================================
variable "autoscaling" {
  description = "Map of ECS autoscaling configurations. Key must match a key in var.ecs_services."
  type = map(object({
    min_capacity                 = number
    max_capacity                 = number
    policy_type                  = string
    adjustment_type              = string
    metric_aggregation_type      = string
    scale_out_cpu_threshold      = number
    scale_out_evaluation_periods = number
    scale_out_period             = number
    scale_out_statistic          = string
    scale_out_cooldown           = number
    scale_out_adjustment         = number
    scale_in_cpu_threshold       = number
    scale_in_evaluation_periods  = number
    scale_in_period              = number
    scale_in_statistic           = string
    scale_in_cooldown            = number
    scale_in_adjustment          = number
  }))
}

# ============================================================
# CLOUDWATCH ALARMS
# ============================================================
variable "cloudwatch_alarms" {
  description = "Map of CloudWatch alarm configurations. Key must match a key in var.ecs_services."
  type = map(object({
    cpu_alarm_threshold             = number
    cpu_alarm_evaluation_periods    = number
    cpu_alarm_period                = number
    cpu_alarm_statistic             = string
    memory_alarm_threshold          = number
    memory_alarm_evaluation_periods = number
    memory_alarm_period             = number
    memory_alarm_statistic          = string
    task_count_alarm_threshold      = number
    task_count_evaluation_periods   = number
    task_count_period               = number
    sns_topic_arn                   = string
  }))
}
