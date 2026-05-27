resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  tags = merge(var.tags, { Name = var.cluster_name })
}

resource "aws_cloudwatch_log_group" "main" {
  name              = var.log_group
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = var.log_group })
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.task_family
  requires_compatibilities = [var.launch_type]
  network_mode             = var.network_mode
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = var.container_protocol
        }
      ]

      logConfiguration = {
        logDriver = var.log_driver
        options = {
          "awslogs-group"         = var.log_group
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.log_stream_prefix
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = var.task_family })
}

resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [aws_ecs_task_definition.main]

  tags = merge(var.tags, { Name = var.service_name })
}
