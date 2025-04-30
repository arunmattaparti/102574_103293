output "autoscaling_target_id" {
  description = "ID of the autoscaling target"
  value       = aws_appautoscaling_target.ecs_target.id
}

output "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  value       = aws_appautoscaling_target.ecs_target.resource_id
}

output "cpu_scale_up_policy_arn" {
  description = "ARN of the CPU scale up policy"
  value       = aws_appautoscaling_policy.scale_up.arn
}

output "cpu_scale_down_policy_arn" {
  description = "ARN of the CPU scale down policy"
  value       = aws_appautoscaling_policy.scale_down.arn
}

output "cpu_tracking_policy_arn" {
  description = "ARN of the CPU target tracking policy"
  value       = aws_appautoscaling_policy.cpu_tracking.arn
}

output "memory_tracking_policy_arn" {
  description = "ARN of the memory target tracking policy"
  value       = aws_appautoscaling_policy.memory_tracking.arn
}