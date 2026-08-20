variable "name" {
  description = "Nome do Application Load Balancer"
  type        = string
}

variable "internal" {
  description = "Define se o ALB é interno (true) ou voltado para a internet (false)"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Lista de Security Groups associados ao ALB"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnets onde o ALB será provisionado (públicas para ALB externo)"
  type        = list(string)
}

variable "tags" {
  description = "Tags aplicadas ao ALB"
  type        = map(string)
  default     = {}
}
