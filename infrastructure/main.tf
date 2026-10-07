#define as dependencias do terraform, ou seja versão maior ou igual a 1.5.0, e define qual é o provedor usado, nesse caso o aws.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# define a regiao da aws, esse valor vem de uma variavel
provider "aws" {
  region = var.region
}

# define "variaveis auxiliares", ou seja, diferente das variaveis que declaramos antes, essas são calculadas pelo terraform para serem usadas, e essas variaveis são: 
# name_prefix Prefixo para o nome dos recursos, 
# private_subnet_ids Transforma os IDs das subnets privadas no seu nome, 
# public_route_json procura o arquivo para ler e substitui pelo ID do internet gateway gerado pelo modulo, nesse caso, está substituido o internet gateway, 
# o private_route_json faz a mesma coisa, no entanto, está substituido o texto pelo que foi gerado pelo modulo do id do NAT gateway, 
# o alb_rules e o ecs_rules carregam e decodificam os arquivos JSON que contêm as regras desses grupos.
# o ecs_ingress_rules pegar as regras do entrada do ecs e o merge substitui o campo security_groups de cada regra pelo ID real do Security Group do ALB.
# no application_environment estamos passando as variaveis de ambiente que será usada no container da aplicação, nesse caso, a Porta da aplicação e a porta do Database que possui um valor estabelecido de 5432, 
# assume_ecs_tasks_policy é uma política de confiança que permite ao serviço ecs-tasks.amazonaws.com assumir a role. execution_policy também possui permissões do CloudWatch Logs: logs:CreateLogStream e logs:PutLogEvents, e tem permissões como ecr:GetAuthorizationToken, ecr:BatchCheckLayerAvailability, ecr:GetDownloadUrlForLayer, ecr:BatchGetImage
# task_policy cria uma política de task sem permissões adicionais. Por enquanto, essa Task Role não possui permissões adicionais definidas por essa política.
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  public_subnet_ids = [
    for name in var.public_subnet_names : module.public_subnets.subnet_id[name]
  ]

  private_subnet_ids = [
    for name in var.private_subnet_names : module.private_subnets.subnet_id[name]
  ]

  public_route_json = replace(
    file("${path.module}/config/routes/public.json"),
    "$${IGW_ID}",
    module.internet_gateway.internet_gateway_id
  )

  private_route_json = replace(
    file("${path.module}/config/routes/private.json"),
    "$${NAT_GW_ID}",
    module.nat_gateway.nat_gateway_id
  )

  alb_rules = jsondecode(file("${path.module}/config/security_rules/rules-sg-alb.json"))
  ecs_rules = jsondecode(file("${path.module}/config/security_rules/rules-sg-ecs.json"))

  ecs_ingress_rules = [
    for rule in local.ecs_rules.ingress : merge(rule, {
      security_groups = [module.alb_security_group.security_group_id]
    })
  ]
  ecs_egress_rules = concat(
    local.ecs_rules.egress,
    [
      {
        description = "Allow ECS to PostgreSQL RDS"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr_block]
      }
    ]
  )
  application_environment = concat([
    {
      name  = "API_PORT"
      value = tostring(var.container_port)
    },
    {
      name  = "DB_PORT"
      value = "5432"
    },
    {
      name  = "DB_HOST"
      value = module.rds.address
    },
    {
      name  = "DB_DATABASE"
      value = var.db_name
    },
    {
      name  = "DB_USER"
      value = var.db_username
    }
  ], var.extra_environment_variables)

  assume_ecs_tasks_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  execution_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = module.db_password_parameter.arn
    }]
  })

  task_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
    }]
  })
}

# chama o modulo da vpc
module "vpc" {
  source         = "./modules/network/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  tags           = var.tags_vpc
}

# chama o modulo da subnets publicas
module "public_subnets" {
  source            = "./modules/network/subnet"
  subnet_name       = var.public_subnet_names
  subnet_cidr       = var.subnet_cidr_blocks_public
  availability_zone = var.availability_zones_public
  vpc_id            = module.vpc.vpc_id
  tags              = var.tags_public_subnet
}

# chama o modulo da subnets privadas
module "private_subnets" {
  source            = "./modules/network/subnet"
  subnet_name       = var.private_subnet_names
  subnet_cidr       = var.subnet_cidr_blocks_private
  availability_zone = var.availability_zones_private
  vpc_id            = module.vpc.vpc_id
  tags              = var.tags_private_subnet
}

#chama o modulo do internet gateway
module "internet_gateway" {
  source = "./modules/network/internet-gateway"
  vpc_id = module.vpc.vpc_id
  tags   = var.tags_internet_gateway
}

# chama o modulo do nat gateway
module "nat_gateway" {
  source           = "./modules/network/nat-gateway"
  public_subnet_id = local.public_subnet_ids[0]
  tags             = { Name = "${local.name_prefix}-nat-gateway" }
}

# chama o modulo do routes table publicas
module "public_route_tables" {
  source     = "./modules/network/route-table"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = local.public_subnet_ids
  azs        = var.availability_zones_public
  tags       = var.tags_rt_public
}

# chama o modulo do routes table privado
module "private_route_tables" {
  source     = "./modules/network/route-table"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = local.private_subnet_ids
  azs        = var.availability_zones_private
  tags       = var.tags_rt_private
}

# chama o modulo da rota publica
module "public_route" {
  for_each       = module.public_route_tables.route_table_ids_by_az
  source         = "./modules/network/route"
  route_table_id = each.value
  routes_json    = local.public_route_json
  route_keys     = ["default_igw"]
}

# chama o modulo das rotas privadas
module "private_route" {
  for_each       = module.private_route_tables.route_table_ids_by_az
  source         = "./modules/network/route"
  route_table_id = each.value
  routes_json    = local.private_route_json
  route_keys     = ["default_nat"]
}

#chama o modulo de associação das routas publicas
module "public_route_association" {
  source          = "./modules/network/route-table-association"
  subnet_ids      = local.public_subnet_ids
  route_table_ids = module.public_route_tables.route_table_ids
}

#chama o modulo de associação das routas privadas
module "private_route_association" {
  source          = "./modules/network/route-table-association"
  subnet_ids      = local.private_subnet_ids
  route_table_ids = module.private_route_tables.route_table_ids
}

# chama o modulo do security group do alb
module "alb_security_group" {
  source        = "./modules/security/security-group"
  name          = "${local.name_prefix}-alb-sg"
  description   = "Security group do Application Load Balancer"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = local.alb_rules.ingress
  egress_rules  = local.alb_rules.egress
}

# chama o modulo do ecs security group
module "ecs_security_group" {
  source        = "./modules/security/security-group"
  name          = "${local.name_prefix}-ecs-sg"
  description   = "Security group das tasks ECS"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = local.ecs_ingress_rules
  egress_rules  = local.ecs_egress_rules
}

module "db_password_parameter" {
  source      = "./modules/security/parameter-store"
  name        = "/${var.project_name}/${var.environment}/db-password"
  description = "Senha do PostgreSQL usada pela aplicação"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Component   = "database"
    ManagedBy   = "terraform"
  }
}

module "rds_security_group" {
  source      = "./modules/security/security-group"
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group do PostgreSQL RDS"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description     = "Permitir PostgreSQL somente a partir do ECS"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [module.ecs_security_group.security_group_id]
    }
  ]

  egress_rules = [
    {
      description = "Allow RDS outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Component   = "database"
    ManagedBy   = "terraform"
  }
}

# chama o modulo do alb
module "alb" {
  source             = "./modules/network/alb"
  name               = "${local.name_prefix}-alb"
  internal           = false
  security_group_ids = [module.alb_security_group.security_group_id]
  subnet_ids         = local.public_subnet_ids
}

module "rds" {
  source = "./modules/database/rds"

  identifier        = "${local.name_prefix}-postgres"
  subnet_group_name = "${local.name_prefix}-db-subnet-group"
  subnet_ids        = local.private_subnet_ids

  security_group_ids = [
    module.rds_security_group.security_group_id
  ]

  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  tags = var.tags_rds
}

# chama o modulo do target group
module "target_group" {
  source            = "./modules/network/target-group"
  name              = "${local.name_prefix}-tg"
  port              = var.container_port
  vpc_id            = module.vpc.vpc_id
  target_type       = "ip"
  health_check_path = "/"
}

# chama o modulo do listener
module "listener" {
  source            = "./modules/network/listener"
  load_balancer_arn = module.alb.alb_arn
  target_group_arn  = module.target_group.target_group_arn
  port              = 80
  protocol          = "HTTP"
}

# chama o modulo de execução do ecs
module "ecs_execution_role" {
  source                  = "./modules/security/iam-role"
  role_name               = "${local.name_prefix}-ecs-execution"
  assume_role_policy_json = local.assume_ecs_tasks_policy
  policy_json             = local.execution_policy
  tags                    = var.tags_ecs
}

# chama o modulo das tasks do ecs
module "ecs_task_role" {
  source                  = "./modules/security/iam-role"
  role_name               = "${local.name_prefix}-ecs-task"
  assume_role_policy_json = local.assume_ecs_tasks_policy
  policy_json             = local.task_policy
  tags                    = var.tags_ecs
}

resource "aws_ecr_repository" "simple_api" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# chama o modulo do ecs
module "ecs" {
  source                = "./modules/ecs"
  cluster_name          = "${local.name_prefix}-cluster"
  service_name          = "${local.name_prefix}-service"
  region                = var.region
  container_name        = var.project_name
  container_image       = "${aws_ecr_repository.simple_api.repository_url}:${var.container_image_tag}"
  container_port        = var.container_port
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  desired_count         = var.desired_count
  execution_role_arn    = module.ecs_execution_role.role_arn
  task_role_arn         = module.ecs_task_role.role_arn
  subnet_ids            = local.private_subnet_ids
  security_group_ids    = [module.ecs_security_group.security_group_id]
  target_group_arn      = module.target_group.target_group_arn
  environment_variables = local.application_environment
  secrets = [
    {
      name      = "DB_PASSWORD"
      valueFrom = module.db_password_parameter.arn
    }
  ]
  tags = var.tags_ecs
}