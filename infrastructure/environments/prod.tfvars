#==========================================================================
# PROJECT CONFIGURATION
#==========================================================================
project_name = "simple-api"
environment  = "prod"
region       = "us-east-1"

#==========================================================================
# NETWORK CONFIGURATION
#==========================================================================
# VPC Configuration
vpc_cidr_block = "10.120.0.0/16"

# Subnets
availability_zones_public  = ["us-east-1a", "us-east-1b"]
availability_zones_private = ["us-east-1a", "us-east-1b"]
public_subnet_names        = ["public-subnet-1a", "public-subnet-1b"]
private_subnet_names       = ["private-subnet-1a", "private-subnet-1b"]
subnet_cidr_blocks_public  = ["10.120.1.0/24", "10.120.2.0/24"]
subnet_cidr_blocks_private = ["10.120.11.0/24", "10.120.12.0/24"]

# Network Tags
tags_vpc = {
  Name = "simple-api-vpc-prod"
  Type = "vpc"
}

tags_public_subnet = {
  Name = "simple-api-public-subnet-prod"
  Type = "public"
}

tags_private_subnet = {
  Name = "simple-api-private-subnet-prod"
  Type = "private"
}

tags_internet_gateway = {
  Name = "simple-api-igw-prod"
  Type = "internet-gateway"
}

tags_rt_public = {
  Name = "simple-api-public-rt-prod"
  Type = "public"
}

tags_rt_private = {
  Name = "simple-api-private-rt-prod"
  Type = "private"
}
#==========================================================================
# TODO: crie as demais variáveis dos módulos (ALB, Target Group, Listener,
# Security Groups, ECS, IAM, Parameter Store, RDS, etc.) seguindo o mesmo
# padrão de organização acima.
#==========================================================================
