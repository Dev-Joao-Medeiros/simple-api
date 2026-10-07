variable "identifier" {
  description = "Identificador da instância RDS"
  type        = string
}

variable "subnet_group_name" {
  description = "Nome do DB Subnet Group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas do RDS"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security Groups associados ao RDS"
  type        = list(string)
}

variable "db_name" {
  description = "Nome inicial do banco"
  type        = string
}

variable "username" {
  description = "Usuário administrador do banco"
  type        = string
}

variable "password" {
  description = "Senha do banco"
  type        = string
  sensitive   = true
}

variable "engine_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Armazenamento em GB"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags do RDS"
  type        = map(string)
  default     = {}
}