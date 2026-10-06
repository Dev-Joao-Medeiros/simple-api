#variavel chamada cluster_name que é do tipo string e espera uma string.
variable "cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

# variavel service_name que é do tipo string e espera uma string
variable "service_name" {
  description = "Nome do serviço ECS (também usado como family da task definition)"
  type        = string
}

# variavel region que é do tipo string e recebe uma string para definir a regiao
variable "region" {
  description = "Região AWS usada para configuração de logs"
  type        = string
}

# container_name que e do tipo string e espera uma strng 
variable "container_name" {
  description = "Nome do container dentro da task definition"
  type        = string
}

# container_image pe do tipo string e espera receber uma string, nesse caso a url da imagem do container
variable "container_image" {
  description = "URI da imagem do container (ex: ECR)"
  type        = string
}

# container_port é do tipo number e esperar receber um number, por padrão está a porta 3000 para acesso dentro do container
variable "container_port" {
  description = "Porta em que a aplicação escuta dentro do container"
  type        = number
  default     = 3000
}

# task_cpu é do tipo number e espera receber um numero que reprensenta a unidade de cpu alocada para a task, nesse caso 256
variable "task_cpu" {
  description = "CPU alocada para a task (unidades Fargate)"
  type        = number
  default     = 256
}

# task_memory é do tipo number e espera receber um numero que reprensenta a quantidade de memoria alocada, nesse caso 512
variable "task_memory" {
  description = "Memória alocada para a task (MiB)"
  type        = number
  default     = 512
}

# desired_count é um number e espera um number que representa a quantidade de task que o ecs vai execultar, nesse caso 1
variable "desired_count" {
  description = "Quantidade desejada de tasks em execução"
  type        = number
  default     = 1
}

# execution_role_arn espera receber uma string que seria a arn do meu IAM de exculção da minha task
variable "execution_role_arn" {
  description = "ARN da IAM Role de execução da task (pull de imagem, logs, secrets)"
  type        = string
}

# task_role_arn diferente do execution_role_arn, que é da task essa é da aplicação em si, e espera receber uma string, caso não receba a string assume um padrão default null.
variable "task_role_arn" {
  description = "ARN da IAM Role da aplicação (permissões em runtime)"
  type        = string
  default     = null
}

# subnet_ids é do tipo lista de string pois ira receber listas de subnets
variable "subnet_ids" {
  description = "Lista de subnets onde as tasks serão executadas"
  type        = list(string)
}

# O código define uma lista de strings com os Security Groups associados às tasks.
variable "security_group_ids" {
  description = "Lista de Security Groups associados às tasks"
  type        = list(string)
}

# assign_public_ip espera receber um booleano, que seria um True ou False, o IP público é atribuído à interface de rede da task quando habilitado, normalmente para permitir acesso direto à internet em subnets públicas sem NAT.
variable "assign_public_ip" {
  description = "Se as tasks devem receber IP público (necessário em subnets públicas sem NAT)"
  type        = bool
  default     = false
}

# target_group_arn é do tipo string, recebe o arn do target group, e vem por padrão null
variable "target_group_arn" {
  description = "ARN do Target Group para registrar as tasks (null quando não há LB)"
  type        = string
  default     = null
}

# environment_variables é do tipo de lista de objeto pois recebe um lista com objetos com nome e valor para especificar o as variaveis de ambientes que serão usadas no container, por padrão ela vem vazia
variable "environment_variables" {
  description = "Variáveis de ambiente injetadas no container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# secrets é do tipo de lista de objeto pois recebe um lista com objetos com name e valueFrom, dados das secrets que serão usadas no container, por padrão vem vazia
variable "secrets" {
  description = "Secrets injetados no container a partir do SSM/Secrets Manager"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# container_insights espera receber um booleano para Habilitar ou desabilitar o container Insights do cluster
variable "container_insights" {
  description = "Habilita o Container Insights no cluster"
  type        = bool
  default     = false
}

# log_retention_in_days espera receber um number que representa a quantidade de dias de retenção dos logs, nesse caso o valor é 14 dias por padrão
variable "log_retention_in_days" {
  description = "Retenção dos logs no CloudWatch"
  type        = number
  default     = 14
}

# tags espera receber um map(string) é usado para adicionar tags nos recursos, vem vazio por padrão.
variable "tags" {
  description = "Tags aplicadas aos recursos ECS"
  type        = map(string)
  default     = {}
}
