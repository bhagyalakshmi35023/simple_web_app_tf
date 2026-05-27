# ============================================================
# VPC
# ============================================================
module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = var.vpc_cidr_block
  name                 = var.vpc_name
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = var.common_tags
}

# ============================================================
# SUBNETS
# ============================================================
module "subnet" {
  source = "./modules/subnet"
  count  = length(var.subnets)

  vpc_id                  = local.vpc.id
  name                    = var.subnets[count.index].name
  cidr_block              = var.subnets[count.index].cidr_block
  availability_zone       = var.subnets[count.index].availability_zone
  map_public_ip_on_launch = var.subnets[count.index].map_public_ip_on_launch
  tags                    = var.common_tags
}

# ============================================================
# INTERNET GATEWAY
# ============================================================
module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = local.vpc.id
  name   = var.internet_gateway_name
  tags   = var.common_tags
}

# ============================================================
# EIP
# ============================================================
module "eip" {
  source = "./modules/eip"
  name   = var.eip_name
  domain = var.eip_domain
}

# ============================================================
# NAT GATEWAY
# ============================================================
module "nat_gateway" {
  source        = "./modules/nat_gateway"
  subnet_id     = local.subnets.public.az_a
  allocation_id = local.eip.nat_allocation_id
  name          = var.nat_gateway_name
  tags          = var.common_tags
}

# ============================================================
# ROUTE TABLES
# ============================================================
module "route_table_public" {
  source   = "./modules/route_table"
  for_each = local.public_route_tables

  vpc_id     = local.vpc.id
  name       = each.value.name
  cidr_block = each.value.cidr_block
  gateway_id = each.value.gateway_id
  subnet_ids = each.value.subnet_ids
  tags       = var.common_tags
}

module "route_table_private" {
  source   = "./modules/route_table"
  for_each = local.private_route_tables

  vpc_id         = local.vpc.id
  name           = each.value.name
  cidr_block     = each.value.cidr_block
  nat_gateway_id = each.value.nat_gateway_id
  subnet_ids     = each.value.subnet_ids
  tags           = var.common_tags
}

# ============================================================
# SECURITY GROUPS
# ============================================================
module "security_group" {
  source   = "./modules/security_group"
  for_each = local.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id
  ingress     = each.value.ingress
  egress      = each.value.egress
  tags        = each.value.tags
}

# ============================================================
# IAM
# ============================================================
module "iam" {
  source   = "./modules/iam"
  for_each = local.iam

  role_name   = each.value.role_name
  policy_arns = each.value.policy_arns
  tags        = each.value.tags
}

# ============================================================
# ALB
# ============================================================
module "alb" {
  source   = "./modules/alb"
  for_each = local.alb

  name                     = each.value.name
  internal                 = each.value.internal
  load_balancer_type       = each.value.load_balancer_type
  security_groups          = each.value.security_groups
  subnets                  = values(local.subnets.public.all)
  vpc_id                   = each.value.vpc_id
  listener_port            = each.value.listener_port
  listener_protocol        = each.value.listener_protocol
  default_target_group_key = each.value.default_target_group_key
  target_groups            = each.value.target_groups
  listener_rules           = each.value.listener_rules
  tags                     = each.value.tags
}

# ============================================================
# ECR
# ============================================================
module "ecr" {
  source   = "./modules/ecr"
  for_each = local.ecr

  name                           = each.value.name
  image_tag_mutability           = each.value.image_tag_mutability
  scan_on_push                   = each.value.scan_on_push
  max_image_count                = each.value.max_image_count
  lifecycle_policy_rule_priority = each.value.lifecycle_policy_rule_priority
  lifecycle_tag_status           = each.value.lifecycle_tag_status
  lifecycle_count_type           = each.value.lifecycle_count_type
  lifecycle_action_type          = each.value.lifecycle_action_type
  tags                           = each.value.tags
}

# ============================================================
# ECS
# ============================================================
module "ecs" {
  source   = "./modules/ecs"
  for_each = local.ecs.services

  cluster_name       = local.ecs.cluster_name
  service_name       = each.value.service_name
  desired_count      = each.value.desired_count
  launch_type        = each.value.launch_type
  network_mode       = each.value.network_mode
  subnets            = values(local.subnets.private.all)
  security_groups    = each.value.security_groups
  assign_public_ip   = each.value.assign_public_ip
  task_family        = each.value.task_family
  task_cpu           = each.value.task_cpu
  task_memory        = each.value.task_memory
  execution_role_arn = each.value.execution_role_arn
  task_role_arn      = each.value.task_role_arn
  container_name     = each.value.container_name
  container_image    = each.value.container_image
  container_port     = each.value.container_port
  container_protocol = each.value.container_protocol
  log_group          = each.value.log_group
  log_retention_days = each.value.log_retention_days
  log_driver         = each.value.log_driver
  log_stream_prefix  = each.value.log_stream_prefix
  aws_region         = each.value.aws_region
  target_group_arn   = each.value.target_group_arn
  tags               = each.value.tags
}

# ============================================================
# AUTOSCALING
# ============================================================
module "autoscaling" {
  source   = "./modules/autoscaling"
  for_each = local.autoscaling

  cluster_name                 = each.value.cluster_name
  service_name                 = each.value.service_name
  min_capacity                 = each.value.min_capacity
  max_capacity                 = each.value.max_capacity
  policy_type                  = each.value.policy_type
  adjustment_type              = each.value.adjustment_type
  metric_aggregation_type      = each.value.metric_aggregation_type
  scale_out_cpu_threshold      = each.value.scale_out_cpu_threshold
  scale_out_evaluation_periods = each.value.scale_out_evaluation_periods
  scale_out_period             = each.value.scale_out_period
  scale_out_statistic          = each.value.scale_out_statistic
  scale_out_cooldown           = each.value.scale_out_cooldown
  scale_out_adjustment         = each.value.scale_out_adjustment
  scale_in_cpu_threshold       = each.value.scale_in_cpu_threshold
  scale_in_evaluation_periods  = each.value.scale_in_evaluation_periods
  scale_in_period              = each.value.scale_in_period
  scale_in_statistic           = each.value.scale_in_statistic
  scale_in_cooldown            = each.value.scale_in_cooldown
  scale_in_adjustment          = each.value.scale_in_adjustment
  tags                         = each.value.tags

  depends_on = [module.ecs]
}

# ============================================================
# CLOUDWATCH ALARMS
# CPU, memory, and task count alarms per ECS service
# ============================================================
module "cloudwatch" {
  source   = "./modules/cloudwatch"
  for_each = local.cloudwatch_alarms

  cluster_name                    = each.value.cluster_name
  service_name                    = each.value.service_name
  cpu_alarm_threshold             = each.value.cpu_alarm_threshold
  cpu_alarm_evaluation_periods    = each.value.cpu_alarm_evaluation_periods
  cpu_alarm_period                = each.value.cpu_alarm_period
  cpu_alarm_statistic             = each.value.cpu_alarm_statistic
  memory_alarm_threshold          = each.value.memory_alarm_threshold
  memory_alarm_evaluation_periods = each.value.memory_alarm_evaluation_periods
  memory_alarm_period             = each.value.memory_alarm_period
  memory_alarm_statistic          = each.value.memory_alarm_statistic
  task_count_alarm_threshold      = each.value.task_count_alarm_threshold
  task_count_evaluation_periods   = each.value.task_count_evaluation_periods
  task_count_period               = each.value.task_count_period
  sns_topic_arn                   = each.value.sns_topic_arn
  tags                            = each.value.tags

  depends_on = [module.ecs]
}
