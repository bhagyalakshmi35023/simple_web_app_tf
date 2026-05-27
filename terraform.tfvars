project_name = "si-prod"
aws_region   = "us-east-1"

common_tags = {
  Project     = "si-prod"
  Environment = "production"
}

# ============================================================
# VPC
# ============================================================
vpc_cidr_block       = "10.0.0.0/21"
vpc_name             = "si-prod-vpc"
enable_dns_support   = true
enable_dns_hostnames = true

# ============================================================
# SUBNETS
# ============================================================
subnets = [
  {
    name                    = "si-prod-public-az-a"
    cidr_block              = "10.0.0.0/23"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true
  },
  {
    name                    = "si-prod-public-az-b"
    cidr_block              = "10.0.2.0/23"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true
  },
  {
    name                    = "si-prod-private-az-a"
    cidr_block              = "10.0.4.0/23"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = false
  },
  {
    name                    = "si-prod-private-az-b"
    cidr_block              = "10.0.6.0/23"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = false
  }
]

# ============================================================
# EIP
# ============================================================
eip_name   = "si-prod-nat-eip"
eip_domain = "vpc"

# ============================================================
# NAT GATEWAY
# ============================================================
nat_gateway_name = "si-prod-nat-gateway"

# ============================================================
# INTERNET GATEWAY
# ============================================================
internet_gateway_name = "si-prod-igw"

# ============================================================
# ROUTE TABLES
# ============================================================
route_table_cidr_block   = "0.0.0.0/0"
public_route_table_name  = "si-prod-public-rt"
private_route_table_name = "si-prod-private-rt"

# ============================================================
# SECURITY GROUPS
# ============================================================
alb_security_group_key = "alb"

security_groups = {
  "alb" = {
    name        = "si-prod-alb-sg"
    description = "allow http and https inbound from internet to alb"
    ingress = [
      { from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ]
    egress = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
  "ecs" = {
    name        = "si-prod-ecs-sg"
    description = "allow inbound from vpc cidr only — alb to ecs tasks"
    ingress = [
      { from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = ["10.0.0.0/21"] },
      { from_port = 3000, to_port = 3000, protocol = "tcp", cidr_blocks = ["10.0.0.0/21"] }
    ]
    egress = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
}

# ============================================================
# IAM
# ============================================================
iam_roles = {
  "ecs_task_execution" = {
    role_name = "si-prod-ecs-task-execution-role"
    policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    ]
  }
  "ecs_task" = {
    role_name = "si-prod-ecs-task-role"
    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
      "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
      "arn:aws:iam::aws:policy/CloudWatchFullAccess",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    ]
  }
}

# ============================================================
# ALB
# ============================================================
alb = {
  "primary" = {
    name                     = "si-prod-alb"
    internal                 = false
    load_balancer_type       = "application"
    listener_port            = 80
    listener_protocol        = "HTTP"
    default_target_group_key = "web"
    target_groups = {
      "web" = {
        name                  = "si-prod-web-tg"
        port                  = 8080
        protocol              = "HTTP"
        target_type           = "ip"
        health_check_path     = "/web/healthCheck"
        health_check_matcher  = "200"
        health_check_interval = 30
        health_check_timeout  = 5
        healthy_threshold     = 2
        unhealthy_threshold   = 2
      }
      "api" = {
        name                  = "si-prod-api-tg"
        port                  = 3000
        protocol              = "HTTP"
        target_type           = "ip"
        health_check_path     = "/api/healthCheck"
        health_check_matcher  = "200"
        health_check_interval = 30
        health_check_timeout  = 5
        healthy_threshold     = 2
        unhealthy_threshold   = 2
      }
    }
    listener_rules = {
      "api" = {
        priority         = 1
        path_pattern     = "/api/*"
        target_group_key = "api"
      }
    }
  }
}

# ============================================================
# ECS
# ============================================================
ecs_cluster_name = "si-prod-cluster"

ecs_services = {
  "web" = {
    service_name       = "si-prod-web-service"
    desired_count      = 2
    launch_type        = "FARGATE"
    network_mode       = "awsvpc"
    assign_public_ip   = false
    task_family        = "si-prod-web-task"
    task_cpu           = "256"
    task_memory        = "512"
    container_name     = "si-prod-web"
    container_image    = "nginx:latest"
    container_port     = 8080
    container_protocol = "tcp"
    log_group          = "/ecs/si-prod-web"
    log_retention_days = 30
    log_driver         = "awslogs"
    log_stream_prefix  = "ecs"
    execution_role_key = "ecs_task_execution"
    task_role_key      = "ecs_task"
    alb_key            = "primary"
    target_group_key   = "web"
    security_group_key = "ecs"
  }
  "api" = {
    service_name       = "si-prod-api-service"
    desired_count      = 2
    launch_type        = "FARGATE"
    network_mode       = "awsvpc"
    assign_public_ip   = false
    task_family        = "si-prod-api-task"
    task_cpu           = "512"
    task_memory        = "1024"
    container_name     = "si-prod-api"
    container_image    = "nginx:latest"
    container_port     = 3000
    container_protocol = "tcp"
    log_group          = "/ecs/si-prod-api"
    log_retention_days = 30
    log_driver         = "awslogs"
    log_stream_prefix  = "ecs"
    execution_role_key = "ecs_task_execution"
    task_role_key      = "ecs_task"
    alb_key            = "primary"
    target_group_key   = "api"
    security_group_key = "ecs"
  }
}

# ============================================================
# ECR
# ============================================================
ecr_repositories = {
  "web" = {
    name                           = "si-prod-web"
    image_tag_mutability           = "IMMUTABLE"
    scan_on_push                   = true
    max_image_count                = 10
    lifecycle_policy_rule_priority = 1
    lifecycle_tag_status           = "any"
    lifecycle_count_type           = "imageCountMoreThan"
    lifecycle_action_type          = "expire"
  }
  "api" = {
    name                           = "si-prod-api"
    image_tag_mutability           = "IMMUTABLE"
    scan_on_push                   = true
    max_image_count                = 10
    lifecycle_policy_rule_priority = 1
    lifecycle_tag_status           = "any"
    lifecycle_count_type           = "imageCountMoreThan"
    lifecycle_action_type          = "expire"
  }
}

# ============================================================
# AUTOSCALING
# ============================================================
autoscaling = {
  "web" = {
    min_capacity                 = 2
    max_capacity                 = 10
    policy_type                  = "StepScaling"
    adjustment_type              = "ChangeInCapacity"
    metric_aggregation_type      = "Average"
    scale_out_cpu_threshold      = 70
    scale_out_evaluation_periods = 2
    scale_out_period             = 60
    scale_out_statistic          = "Average"
    scale_out_cooldown           = 60
    scale_out_adjustment         = 1
    scale_in_cpu_threshold       = 30
    scale_in_evaluation_periods  = 5
    scale_in_period              = 60
    scale_in_statistic           = "Average"
    scale_in_cooldown            = 120
    scale_in_adjustment          = -1
  }
  "api" = {
    min_capacity                 = 2
    max_capacity                 = 10
    policy_type                  = "StepScaling"
    adjustment_type              = "ChangeInCapacity"
    metric_aggregation_type      = "Average"
    scale_out_cpu_threshold      = 70
    scale_out_evaluation_periods = 2
    scale_out_period             = 60
    scale_out_statistic          = "Average"
    scale_out_cooldown           = 60
    scale_out_adjustment         = 1
    scale_in_cpu_threshold       = 30
    scale_in_evaluation_periods  = 5
    scale_in_period              = 60
    scale_in_statistic           = "Average"
    scale_in_cooldown            = 120
    scale_in_adjustment          = -1
  }
}

# ============================================================
# CLOUDWATCH ALARMS
# ============================================================
cloudwatch_alarms = {
  "web" = {
    cpu_alarm_threshold             = 80
    cpu_alarm_evaluation_periods    = 2
    cpu_alarm_period                = 60
    cpu_alarm_statistic             = "Average"
    memory_alarm_threshold          = 80
    memory_alarm_evaluation_periods = 2
    memory_alarm_period             = 60
    memory_alarm_statistic          = "Average"
    task_count_alarm_threshold      = 1
    task_count_evaluation_periods   = 1
    task_count_period               = 60
    sns_topic_arn                   = "arn:aws:sns:us-east-1:123456789012:si-prod-alerts"
  }
  "api" = {
    cpu_alarm_threshold             = 80
    cpu_alarm_evaluation_periods    = 2
    cpu_alarm_period                = 60
    cpu_alarm_statistic             = "Average"
    memory_alarm_threshold          = 80
    memory_alarm_evaluation_periods = 2
    memory_alarm_period             = 60
    memory_alarm_statistic          = "Average"
    task_count_alarm_threshold      = 1
    task_count_evaluation_periods   = 1
    task_count_period               = 60
    sns_topic_arn                   = "arn:aws:sns:us-east-1:123456789012:si-prod-alerts"
  }
}
