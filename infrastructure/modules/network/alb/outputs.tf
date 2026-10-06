# saida do arn da aplicação do meu load balance
output "alb_arn" {
  description = "ARN do Application Load Balancer"
  value       = aws_lb.this.arn
}

# saida do nome DNS do meu load balance
output "alb_dns_name" {
  description = "DNS name público do ALB"
  value       = aws_lb.this.dns_name
}

# saida do ID da zona do meu load balance, para registo no Route53 alias
output "alb_zone_id" {
  description = "Zone ID do ALB (para registros Route53 alias)"
  value       = aws_lb.this.zone_id
}
