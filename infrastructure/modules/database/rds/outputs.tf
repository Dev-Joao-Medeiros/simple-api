output "address" {
  description = "Endpoint DNS do RDS"
  value       = aws_db_instance.this.address
}

output "endpoint" {
  description = "Endpoint completo do RDS"
  value       = aws_db_instance.this.endpoint
}

output "port" {
  description = "Porta do RDS"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Nome do banco"
  value       = aws_db_instance.this.db_name
}