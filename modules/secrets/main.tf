# Secrets module - Creates and manages secrets in AWS Secrets Manager

# Generate random passwords for each secret
resource "random_password" "secret_value" {
  for_each = toset(var.secret_names)
  
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create secrets in AWS Secrets Manager
resource "aws_secretsmanager_secret" "secret" {
  for_each = toset(var.secret_names)
  
  name        = "${var.secrets_prefix}${each.key}"
  description = "Secret for ${each.key}"
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
  })
}

# Store the secret values
resource "aws_secretsmanager_secret_version" "secret_version" {
  for_each = toset(var.secret_names)
  
  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = random_password.secret_value[each.key].result
}