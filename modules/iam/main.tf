resource "aws_iam_role" "main" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, { Name = var.role_name })
}

resource "aws_iam_role_policy_attachment" "main" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.main.name
  policy_arn = each.value
}
