variable "subnet_name" {
  description = "Lista com os nomes das subnets (ex: ['public-1a', 'public-1b'])"
  type        = list(string)
}

variable "subnet_cidr" {
  description = "Lista com os blocos CIDR para as subnets (ex: ['10.0.1.0/24', '10.0.2.0/24'])"
  type        = list(string)
}

variable "vpc_id" {
  description = "O ID da VPC onde as subnets serão criadas"
  type        = string
}

variable "availability_zone" {
  description = "Lista das zonas de disponibilidade (ex: ['us-east-1a', 'us-east-1b'])"
  type        = list(string)
}

variable "map_public_ip_on_launch" {
  description = "Indica se as instâncias lançadas na subnet devem receber um IP público automaticamente"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Um mapa de tags base (common_tags) para atribuir às subnets"
  type        = map(string)
  default     = {}
}
