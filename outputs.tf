output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.ecs.task_definition_arn
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.ecs.load_balancer_dns
}

output "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  value       = module.autoscaling.autoscaling_group_name
}

output "secrets_arns" {
  description = "ARNs of the created secrets"
  value       = module.secrets.secret_arns
  sensitive   = true
}

output "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.security.execution_role_arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.security.task_role_arn
}