# saida do cluster, nesse caso o id do cluster
output "cluster_id" {
  description = "ID do cluster ECS"
  value       = aws_ecs_cluster.this.id
}

# exibe o arn do cluster ecs
output "cluster_arn" {
  description = "ARN do cluster ECS"
  value       = aws_ecs_cluster.this.arn
}

# exibe o nome do cluster ecs
output "cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.this.name
}

# exibe o nome do servico ecs
output "service_name" {
  description = "Nome do serviço ECS"
  value       = aws_ecs_service.this.name
}

# exporta apenas o ARN da task definition. O ARN contém a família e a revisão, mas o output não as expõe separadamente.
output "task_definition_arn" {
  description = "ARN da task definition"
  value       = aws_ecs_task_definition.this.arn
}

# exibe o log group do CloudWatch
output "log_group_name" {
  description = "Nome do CloudWatch Log Group do serviço"
  value       = aws_cloudwatch_log_group.this.name
}
