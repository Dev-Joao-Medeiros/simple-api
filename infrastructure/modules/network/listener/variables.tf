variable "load_balancer_arn" {
  description = "ARN do ALB ao qual o listener será associado"
  type        = string
}

variable "target_group_arn" {
  description = "ARN do target group para onde o listener encaminha o tráfego"
  type        = string
}

variable "port" {
  description = "Porta em que o listener escuta"
  type        = number
  default     = 80
}

variable "protocol" {
  description = "Protocolo do listener"
  type        = string
  default     = "HTTP"
}

variable "tags" {
  description = "Tags aplicadas ao listener"
  type        = map(string)
  default     = {}
}
