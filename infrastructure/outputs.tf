output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS público do Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL HTTP pública da aplicação"
  value       = "http://${module.alb.alb_dns_name}"
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = module.ecs.service_name
}

output "target_group_arn" {
  description = "ARN do target group associado ao ECS"
  value       = module.target_group.target_group_arn
}