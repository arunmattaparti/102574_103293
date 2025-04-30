variable "secrets_prefix" {
  description = "Prefix for secrets in AWS Secrets Manager"
  type        = string
  default     = "/"
}

variable "secret_names" {
  description = "List of secret names to create in AWS Secrets Manager"
  type        = list(string)
  default     = []
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}