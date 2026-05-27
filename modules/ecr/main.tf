resource "aws_ecr_repository" "main" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = var.lifecycle_policy_rule_priority
        description  = "Keep only the last ${var.max_image_count} images"
        selection = {
          tagStatus   = var.lifecycle_tag_status
          countType   = var.lifecycle_count_type
          countNumber = var.max_image_count
        }
        action = {
          type = var.lifecycle_action_type
        }
      }
    ]
  })
}
