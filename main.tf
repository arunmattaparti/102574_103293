locals {
  name_prefix = "${var.project}-${var.environment}"
  ecs_cluster_name = var.ecs_cluster_name != null ? var.ecs_cluster_name : "${local.name_prefix}-cluster"
  
  # Merge default and additional tags
  tags = merge(
    var.default_tags,
    var.additional_tags,
    {
      Environment = var.environment
      Project     = var.project
    }
  )
}

# Networking module - Creates VPC, subnets, route tables, etc.
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  name_prefix          = local.name_prefix
  tags                 = local.tags
}

# Security module - Creates IAM roles, security groups, etc.
module "security" {
  source = "./modules/security"
  
  name_prefix = local.name_prefix
  vpc_id      = module.networking.vpc_id
  tags        = local.tags
  
  # Pass the secrets ARNs to allow access
  secrets_arns = module.secrets.secret_arns
}

# Secrets module - Creates and manages secrets in AWS Secrets Manager
module "secrets" {
  source = "./modules/secrets"
  
  secrets_prefix = var.secrets_prefix
  secret_names   = var.secret_names
  name_prefix    = local.name_prefix
  tags           = local.tags
}

# ECS module - Creates ECS cluster, service, task definition, etc.
module "ecs" {
  source = "./modules/ecs"
  
  cluster_name        = local.ecs_cluster_name
  name_prefix         = local.name_prefix
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  private_subnet_ids  = module.networking.private_subnet_ids
  execution_role_arn  = module.security.execution_role_arn
  task_role_arn       = module.security.task_role_arn
  security_group_id   = module.security.ecs_security_group_id
  container_image     = var.container_image
  container_port      = var.container_port
  container_cpu       = var.container_cpu
  container_memory    = var.container_memory
  desired_count       = var.desired_capacity
  tags                = local.tags
  
  # Pass secrets to the container
  secrets = module.secrets.secret_map
}

# Autoscaling module - Creates autoscaling policies and alarms
module "autoscaling" {
  source = "./modules/autoscaling"
  
  name_prefix              = local.name_prefix
  ecs_cluster_name         = module.ecs.cluster_name
  ecs_service_name         = module.ecs.service_name
  min_capacity             = var.min_capacity
  max_capacity             = var.max_capacity
  cpu_scale_up_threshold   = var.cpu_scale_up_threshold
  cpu_scale_down_threshold = var.cpu_scale_down_threshold
  tags                     = local.tags
}