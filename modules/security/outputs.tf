output "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.execution_role.arn
}

output "execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.execution_role.name
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.task_role.arn
}

output "task_role_name" {
  description = "Name of the ECS task role"
  value       = aws_iam_role.task_role.name
}

output "ecs_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}