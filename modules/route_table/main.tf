resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = var.cidr_block
    gateway_id     = var.gateway_id
    nat_gateway_id = var.nat_gateway_id
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_route_table_association" "main" {
  for_each = var.subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.main.id
}