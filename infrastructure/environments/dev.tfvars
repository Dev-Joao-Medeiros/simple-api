#==========================================================================
# PROJECT CONFIGURATION
#==========================================================================
project_name = "simple-api"
environment  = "dev"
region       = "us-east-1"

#==========================================================================
# NETWORK CONFIGURATION
#==========================================================================

# VPC Configuration
vpc_cidr_block = "10.100.0.0/16"

# Subnets
availability_zones_public  = ["us-east-1a", "us-east-1b"]
availability_zones_private = ["us-east-1a", "us-east-1b"]
public_subnet_names        = ["public-subnet-1a", "public-subnet-1b"]
private_subnet_names       = ["private-subnet-1a", "private-subnet-1b"]
subnet_cidr_blocks_public  = ["10.100.1.0/24", "10.100.2.0/24"]
subnet_cidr_blocks_private = ["10.100.11.0/24", "10.100.12.0/24"]

# Network Tags
tags_vpc = {
  Name = "simple-api-vpc-dev"
  Type = "vpc"
}

tags_public_subnet = {
  Name = "simple-api-public-subnet-dev"
  Type = "public"
}

tags_private_subnet = {
  Name = "simple-api-private-subnet-dev"
  Type = "private"
}

tags_internet_gateway = {
  Name = "simple-api-igw-dev"
  Type = "internet-gateway"
}

tags_rt_public = {
  Name = "simple-api-public-rt-dev"
  Type = "public"
}

tags_rt_private = {
  Name = "simple-api-private-rt-dev"
  Type = "private"
}

#==========================================================================
# TODO: crie as demais variáveis dos módulos (ALB, Target Group, Listener,
# Security Groups, ECS, IAM, Parameter Store, RDS, etc.) seguindo o mesmo
# padrão de organização acima.
#==========================================================================

#  O que fiz:
# As configurações de rede e ECS abaixo são específicas do ambiente.
# ALB, Target Group, Listener, Security Groups e IAM são compostos
# na raiz e utilizam valores fixos ou arquivos JSON de configuração.

#==========================================================================
# ECS / CONTAINER CONFIGURATION
#==========================================================================

# O Terraform combina esta tag com a URI do repositório ECR criado pela raiz.
container_image_tag = "dev"

# A porta deve ser a mesma em que a aplicação escuta dentro do container.
container_port = 3000

# recursos do fargate para desenvolvimento: 0.25 vCPG 512 MiB.
task_cpu      = 256
task_memory   = 512
desired_count = 1

tags_ecs = {
  Name        = "simple-api-ecs-dev"
  Environment = "dev"
  Component   = "compute"
  ManagedBy   = "terraform"
}

# Variaveis API_PORT e DB_PORT são adicionadas automaticamente pelo modulo
extra_environment_variables = [
  {
    name  = "NODE_ENV"
    value = "development"
  },
  {
    name  = "LOG_LEVEL"
    value = "debug"
  }
]

#========================================================================== 
# DATABASE CONFIGURATION
#========================================================================== 
# A senha fica em environments/dev.secrets.tfvars e é injetada pelo SSM.

db_name              = "simple_api"
db_username          = "app_user"
db_engine_version    = "16"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20

tags_rds = {
  Name        = "simple-api-rds-dev"
  Environment = "dev"
  Component   = "database"
  ManagedBy   = "terraform"
}

#==========================================================================
# SECURITY GROUPS
#==========================================================================
# As regras do ALB e do ECS são carregadas automaticamente de:
# - config/security_rules/rules-sg-alb.json
# - config/security_rules/rules-sg-ecs.json
# O ALB fica nas subnets públicas; as tasks ECS ficam nas subnets privadas.