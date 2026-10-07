variable "project_name" {
  description = "Nome base dos recursos"
  type        = string
}

variable "environment" {
  description = "Ambiente da infraestrutura"
  type        = string
}

variable "region" {
  description = "Região AWS"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR da VPC"
  type        = string
}

variable "availability_zones_public" {
  description = "Zonas das subnets públicas"
  type        = list(string)
}

variable "availability_zones_private" {
  description = "Zonas das subnets privadas"
  type        = list(string)
}

variable "public_subnet_names" {
  description = "Nomes das subnets públicas"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Nomes das subnets privadas"
  type        = list(string)
}

variable "subnet_cidr_blocks_public" {
  description = "CIDRs das subnets públicas"
  type        = list(string)
}

variable "subnet_cidr_blocks_private" {
  description = "CIDRs das subnets privadas"
  type        = list(string)
}

variable "tags_vpc" {
  description = "Tags da VPC"
  type        = map(string)
  default     = {}
}

variable "tags_public_subnet" {
  description = "Tags das subnets públicas"
  type        = map(string)
  default     = {}
}

variable "tags_private_subnet" {
  description = "Tags das subnets privadas"
  type        = map(string)
  default     = {}
}

variable "tags_internet_gateway" {
  description = "Tags do Internet Gateway"
  type        = map(string)
  default     = {}
}

variable "tags_rt_public" {
  description = "Tags das route tables públicas"
  type        = map(string)
  default     = {}
}

variable "tags_rt_private" {
  description = "Tags das route tables privadas"
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "Porta em que a aplicação Node escuta"
  type        = number
  default     = 3000
}

variable "task_cpu" {
  description = "CPU da task Fargate"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memória da task Fargate em MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Quantidade desejada de tasks"
  type        = number
  default     = 1
}

variable "extra_environment_variables" {
  description = "Variáveis adicionais da aplicação"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags_ecs" {
  description = "Tags dos recursos ECS"
  type        = map(string)
  default     = {}
}

variable "container_image_tag" {
  description = "Tag da imagem Docker publicada no ECR"
  type        = string
  default     = "dev"
}

variable "db_name" {
  description = "Nome inicial do banco PostgreSQL"
  type        = string
}

variable "db_username" {
  description = "Usuário do banco PostgreSQL"
  type        = string
}

variable "db_password" {
  description = "Senha do banco PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_engine_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "16"
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento do RDS em GB"
  type        = number
  default     = 20
}


variable "tags_rds" {
  description = "Tags dos recursos RDS"
  type        = map(string)
  default     = {}
}