# Criação de uma aplicação do ALB, usando as variaveis definidas, para nome, ids do security groups, ids das subnets, tags, internal para verificar se o lb será interno e o tipo de load balance, nesse caso vai ser o application.
resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  tags = var.tags
}
