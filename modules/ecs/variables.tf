variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "desired_count" {
  description = "Number of task instances to run"
  type        = number
}

variable "launch_type" {
  description = "Launch type: FARGATE or EC2"
  type        = string
}

variable "network_mode" {
  description = "Docker networking mode for the task: awsvpc, bridge, host, or none"
  type        = string
}

variable "subnets" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to ECS tasks"
  type        = bool
}

variable "task_family" {
  description = "Family name for the ECS task definition"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = string
}

variable "task_memory" {
  description = "Memory in MB for the task (512, 1024, 2048, etc.)"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role (used by ECS agent)"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role (used by the container at runtime)"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image URI (ECR or Docker Hub)"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "container_protocol" {
  description = "Protocol for the container port mapping (tcp or udp)"
  type        = string
}

variable "log_group" {
  description = "CloudWatch log group name for container logs"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
}

variable "log_driver" {
  description = "Log driver for the container (e.g. awslogs, splunk)"
  type        = string
}

variable "log_stream_prefix" {
  description = "Prefix for CloudWatch log streams"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch log driver configuration"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to register this service with"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all ECS resources"
  type        = map(string)
  default     = {}
}
