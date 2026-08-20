resource "aws_route_table" "this" {
  count  = length(var.subnet_ids)
  vpc_id = var.vpc_id
  tags   = var.tags
}