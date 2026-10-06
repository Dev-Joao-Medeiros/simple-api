# DIZ PARA A AWS CRIAR O RECURSO CLUSTER (ECS),
# O NOME DO CLUSTER VEM DA VARIAVEL cluster_name,
# APLICA TAGS NO CLUSTER, NESSE CASO VINDO DA VARIAVEL tags
# SETTING CRIA UM BLOCO DE CONFIG. ADICIONAIS, NESSE CASO O name Ativa ou desativa o Amazon CloudWatch Container Insights E O value FAZ UM IF, ENTÃO ELE VERIFICA SE A VARIAVEL container_insights É VERDADEIRA, CASO FOR "enable", CASO CONTRARIO "disabled" 

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
  tags = var.tags

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }
}

# DIZ PARA A AWS CRIAR O SERVIÇO DE LOGS DO CloudWatch, ESSA CRIAÇÃO REQUER O name, retention_in_days DEFINE A QUANTIDADE DE DIAS QUE OS LOGS FICARAM RETIDOS.

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# GERENCIA UMA REVISÃO DE DEFINIÇÃO DE UMA TASK ECS PARA SER USADO NO SERVIÇO aws_ecs_service
# family NOME EXCLUSIVO PARA DEFINIÇÃO DA SUA TASK, requires_compatibilities CONJUNTO DE TIPOS DE INICIALIZAÇÃO REQUERIDO PELA TASK, VALIDA COMPATIBILIDADE COM O FARGATE, network_mode É valor real é "awsvpc", que é o modo de rede obrigatório para Fargate, AS OUTRA SÃO AUTO EXPLICATIVAS, COMO memory, cpu, container_definitions SÃO PEGAS COMO VARIAVEIS, COM EXCESÃO DO CO container_definitions que tem valores setados, execution_role_arn ARN DA FUNÇÃO DE EXECULÇÃO DE TASKS QUE O AGENTE DE CONTEINER DO ECS E O DEAMON DO DOCKER PODEM ASSUMIR, task_role_arn ARN DO IAM QUE PERMITE QUE O ECS FAÇA CHAMADA PARA O AWS SERVICE.

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  tags                     = var.tags

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = var.environment_variables
      secrets     = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# PROVISIONA UM SERVIÇO ECS

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # CRIA AS CONFIGURAÇÕES DE REDE, QUE SÃO PEGOS PELAS VARIAVEIS

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  # CRIA UM LOAD BALANCE DINAMICO, PARA DISTRIBUIR TRAFIGOS DE REDE AUTOMATICAMENTE  

  dynamic "load_balancer" {
    for_each = var.target_group_arn == null ? [] : [1]
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [desired_count]
  }
}
