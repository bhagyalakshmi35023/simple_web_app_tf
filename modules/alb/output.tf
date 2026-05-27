output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB — use this as the application entry point"
  value       = aws_lb.main.dns_name
}

# Map of target group ARNs keyed by logical name (e.g. "web", "api")
# ECS services reference this via: module.alb[key].target_group_arns["web"]
output "target_group_arns" {
  description = "Map of target group ARNs keyed by logical name"
  value       = { for k, tg in aws_lb_target_group.main : k => tg.arn }
}

output "listener_arn" {
  value = aws_lb_listener.main.arn
}
