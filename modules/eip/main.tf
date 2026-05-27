resource "aws_eip" "main" {
  domain = var.domain

  tags = {
    Name = var.name
  }
}
