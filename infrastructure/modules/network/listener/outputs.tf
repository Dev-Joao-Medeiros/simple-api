output "listener_arn" {
  description = "ARN do listener do ALB"
  value       = aws_lb_listener.this.arn
}
