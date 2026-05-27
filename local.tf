locals {

  # ============================================================
  # VPC
  # ============================================================
  vpc = {
    id = module.vpc.vpc_id
  }

  # ============================================================
  # SUBNETS
  # [0] public-az-a  — public, hosts NAT Gateway
  # [1] public-az-b  — public, second AZ for ALB
  # [2] private-az-a — private, ECS web tasks
  # [3] private-az-b — private, ECS api tasks
  # ============================================================
subnets = {
  public = {
    az_a = module.subnet[0].id
    az_b = module.subnet[1].id

    all = {
      az_a = module.subnet[0].id
      az_b = module.subnet[1].id
    }
  }

  private = {
    az_a = module.subnet[2].id
    az_b = module.subnet[3].id

    all = {
      az_a = module.subnet[2].id
      az_b = module.subnet[3].id
    }
  }
}

  # ============================================================
  # EIP
  # ============================================================
  eip = {
    nat_allocation_id = module.eip.allocation_id
  }

  # ============================================================
  # NAT GATEWAY
  # ============================================================
  nat_gateway = {
    id = module.nat_gateway.nat_gateway_id
  }

  # ============================================================
  # INTERNET GATEWAY
  # ============================================================
  internet_gateway = {
    id = module.internet_gateway.internet_gateway_id
  }

  # ============================================================
  # ROUTE TABLES
  # ============================================================
  public_route_tables = {
    public = {
      name       = var.public_route_table_name
      cidr_block = var.route_table_cidr_block
      gateway_id = local.internet_gateway.id
      subnet_ids = local.subnets.public.all
    }
  }

  private_route_tables = {
    private = {
      name           = var.private_route_table_name
      cidr_block     = var.route_table_cidr_block
      nat_gateway_id = local.nat_gateway.id
      subnet_ids     = local.subnets.private.all
    }
  }

  # ============================================================
  # SECURITY GROUPS
  # ============================================================
  security_groups = {
    for key, sg in var.security_groups : key => {
      name        = sg.name
      description = sg.description
      vpc_id      = local.vpc.id
      ingress     = sg.ingress
      egress      = sg.egress
      tags        = merge(var.common_tags, { Name = sg.name })
    }
  }

  # ============================================================
  # IAM
  # ============================================================
  iam = {
    for key, role in var.iam_roles : key => {
      role_name   = role.role_name
      policy_arns = role.policy_arns
      tags        = merge(var.common_tags, { Name = role.role_name })
    }
  }

  # ============================================================
  # ALB
  # ============================================================
  alb = {
    for key, alb in var.alb : key => {
      name                     = alb.name
      internal                 = alb.internal
      load_balancer_type       = alb.load_balancer_type
      security_groups          = [module.security_group[var.alb_security_group_key].security_group_id]
      subnets                  = local.subnets.public.all
      vpc_id                   = local.vpc.id
      listener_port            = alb.listener_port
      listener_protocol        = alb.listener_protocol
      default_target_group_key = alb.default_target_group_key
      target_groups            = alb.target_groups
      listener_rules           = alb.listener_rules
      tags                     = merge(var.common_tags, { Name = alb.name })
    }
  }

  # ============================================================
  # ECS
  # ============================================================
  ecs = {
    cluster_name = var.ecs_cluster_name

    services = {
      for key, svc in var.ecs_services : key => {
        service_name       = svc.service_name
        desired_count      = svc.desired_count
        launch_type        = svc.launch_type
        network_mode       = svc.network_mode
        assign_public_ip   = svc.assign_public_ip
        subnets            = local.subnets.private.all
        security_groups    = [module.security_group[svc.security_group_key].security_group_id]
        task_family        = svc.task_family
        task_cpu           = svc.task_cpu
        task_memory        = svc.task_memory
        execution_role_arn = module.iam[svc.execution_role_key].role_arn
        task_role_arn      = module.iam[svc.task_role_key].role_arn
        container_name     = svc.container_name
        container_image    = svc.container_image
        container_port     = svc.container_port
        container_protocol = svc.container_protocol
        log_group          = svc.log_group
        log_retention_days = svc.log_retention_days
        log_driver         = svc.log_driver
        log_stream_prefix  = svc.log_stream_prefix
        aws_region         = var.aws_region
        target_group_arn   = module.alb[svc.alb_key].target_group_arns[svc.target_group_key]
        tags               = merge(var.common_tags, { Name = svc.service_name })
      }
    }
  }

  # ============================================================
  # ECR
  # ============================================================
  ecr = {
    for key, repo in var.ecr_repositories : key => {
      name                           = repo.name
      image_tag_mutability           = repo.image_tag_mutability
      scan_on_push                   = repo.scan_on_push
      max_image_count                = repo.max_image_count
      lifecycle_policy_rule_priority = repo.lifecycle_policy_rule_priority
      lifecycle_tag_status           = repo.lifecycle_tag_status
      lifecycle_count_type           = repo.lifecycle_count_type
      lifecycle_action_type          = repo.lifecycle_action_type
      tags                           = merge(var.common_tags, { Name = repo.name })
    }
  }

  # ============================================================
  # AUTOSCALING
  # ============================================================
  autoscaling = {
    for key, asg in var.autoscaling : key => {
      cluster_name                 = var.ecs_cluster_name
      service_name                 = var.ecs_services[key].service_name
      min_capacity                 = asg.min_capacity
      max_capacity                 = asg.max_capacity
      policy_type                  = asg.policy_type
      adjustment_type              = asg.adjustment_type
      metric_aggregation_type      = asg.metric_aggregation_type
      scale_out_cpu_threshold      = asg.scale_out_cpu_threshold
      scale_out_evaluation_periods = asg.scale_out_evaluation_periods
      scale_out_period             = asg.scale_out_period
      scale_out_statistic          = asg.scale_out_statistic
      scale_out_cooldown           = asg.scale_out_cooldown
      scale_out_adjustment         = asg.scale_out_adjustment
      scale_in_cpu_threshold       = asg.scale_in_cpu_threshold
      scale_in_evaluation_periods  = asg.scale_in_evaluation_periods
      scale_in_period              = asg.scale_in_period
      scale_in_statistic           = asg.scale_in_statistic
      scale_in_cooldown            = asg.scale_in_cooldown
      scale_in_adjustment          = asg.scale_in_adjustment
      tags                         = merge(var.common_tags, { Name = "${var.ecs_services[key].service_name}-asg" })
    }
  }

  # ============================================================
  # CLOUDWATCH ALARMS
  # Keyed by ECS service key — must match keys in var.ecs_services
  # ============================================================
  cloudwatch_alarms = {
    for key, cw in var.cloudwatch_alarms : key => {
      cluster_name                    = var.ecs_cluster_name
      service_name                    = var.ecs_services[key].service_name
      cpu_alarm_threshold             = cw.cpu_alarm_threshold
      cpu_alarm_evaluation_periods    = cw.cpu_alarm_evaluation_periods
      cpu_alarm_period                = cw.cpu_alarm_period
      cpu_alarm_statistic             = cw.cpu_alarm_statistic
      memory_alarm_threshold          = cw.memory_alarm_threshold
      memory_alarm_evaluation_periods = cw.memory_alarm_evaluation_periods
      memory_alarm_period             = cw.memory_alarm_period
      memory_alarm_statistic          = cw.memory_alarm_statistic
      task_count_alarm_threshold      = cw.task_count_alarm_threshold
      task_count_evaluation_periods   = cw.task_count_evaluation_periods
      task_count_period               = cw.task_count_period
      sns_topic_arn                   = cw.sns_topic_arn
      tags                            = merge(var.common_tags, { Name = "${var.ecs_services[key].service_name}-alarms" })
    }
  }

}
