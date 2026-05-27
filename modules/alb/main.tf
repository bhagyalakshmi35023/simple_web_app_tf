resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_lb_target_group" "main" {
  for_each = var.target_groups

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  health_check {
    path                = each.value.health_check_path
    protocol            = each.value.protocol
    matcher             = each.value.health_check_matcher
    interval            = each.value.health_check_interval
    timeout             = each.value.health_check_timeout
    healthy_threshold   = each.value.healthy_threshold
    unhealthy_threshold = each.value.unhealthy_threshold
  }

  tags = merge(var.tags, { Name = each.value.name })
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[var.default_target_group_key].arn
  }

  tags = merge(var.tags, { Name = "${var.name}-listener" })
}

resource "aws_lb_listener_rule" "main" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.main.arn
  priority     = each.value.priority

  condition {
    path_pattern {
      values = [each.value.path_pattern]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.value.target_group_key].arn
  }
}
