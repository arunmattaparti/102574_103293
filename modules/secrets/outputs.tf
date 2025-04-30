output "secret_arns" {
  description = "ARNs of the created secrets"
  value       = [for secret in aws_secretsmanager_secret.secret : secret.arn]
  sensitive   = true
}

output "secret_names" {
  description = "Names of the created secrets"
  value       = [for secret in aws_secretsmanager_secret.secret : secret.name]
}

output "secret_map" {
  description = "Map of secret names to their ARNs for use in ECS task definitions"
  value = {
    for name in var.secret_names : name => aws_secretsmanager_secret.secret[name].arn
  }
  sensitive = true
}