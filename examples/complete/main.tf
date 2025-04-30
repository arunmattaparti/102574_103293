# Complete example of using the ECS infrastructure modules

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Environment = "example"
      Project     = "ecs-demo"
    }
  }
}

locals {
  name_prefix = "ecs-demo-example"
}

# Networking module
module "networking" {
  source = "../../modules/networking"
  
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  name_prefix          = local.name_prefix
  
  tags = {
    Environment = "example"
    Project     = "ecs-demo"
  }
}

# Secrets module
module "secrets" {
  source = "../../modules/secrets"
  
  secrets_prefix = "/ecs-demo/"
  secret_names   = ["db-password", "api-key"]
  name_prefix    = local.name_prefix
  
  tags = {
    Environment = "example"
    Project     = "ecs-demo"
  }
}

# Security module
module "security" {
  source = "../../modules/security"
  
  name_prefix  = local.name_prefix
  vpc_id       = module.networking.vpc_id
  secrets_arns = module.secrets.secret_arns
  
  tags = {
    Environment = "example"
    Project     = "ecs-demo"
  }
}

# ECS module
module "ecs" {
  source = "../../modules/ecs"
  
  cluster_name       = "${local.name_prefix}-cluster"
  name_prefix        = local.name_prefix
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  execution_role_arn = module.security.execution_role_arn
  task_role_arn      = module.security.task_role_arn
  security_group_id  = module.security.ecs_security_group_id
  container_image    = "nginx:latest"
  container_port     = 80
  container_cpu      = 256
  container_memory   = 512
  desired_count      = 2
  
  environment_variables = {
    ENVIRONMENT = "example"
  }
  
  secrets = module.secrets.secret_map
  
  tags = {
    Environment = "example"
    Project     = "ecs-demo"
    Service     = "web"
  }
}

# Autoscaling module
module "autoscaling" {
  source = "../../modules/autoscaling"
  
  name_prefix            = local.name_prefix
  ecs_cluster_name       = module.ecs.cluster_name
  ecs_service_name       = module.ecs.service_name
  min_capacity           = 2
  max_capacity           = 10
  cpu_scale_up_threshold = 70
  cpu_scale_down_threshold = 30
  
  tags = {
    Environment = "example"
    Project     = "ecs-demo"
  }
}

# Outputs
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.ecs.load_balancer_dns
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "secret_names" {
  description = "Names of the created secrets"
  value       = module.secrets.secret_names
}