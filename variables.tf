variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "ecs-app"
}

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ECS variables
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = null # Will be generated from project and environment if null
}

variable "container_image" {
  description = "Docker image for the ECS task"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
  default     = 512
}

# Autoscaling variables
variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "cpu_scale_up_threshold" {
  description = "CPU utilization threshold for scaling up"
  type        = number
  default     = 70
}

variable "cpu_scale_down_threshold" {
  description = "CPU utilization threshold for scaling down"
  type        = number
  default     = 30
}

# Secrets variables
variable "secrets_prefix" {
  description = "Prefix for secrets in AWS Secrets Manager"
  type        = string
  default     = "/ecs-app/"
}

variable "secret_names" {
  description = "List of secret names to create in AWS Secrets Manager"
  type        = list(string)
  default     = ["db-password", "api-key"]
}

# Tagging variables
variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "terraform"
    Environment = "dev"
    Project     = "ecs-app"
    Owner       = "infrastructure-team"
    CostCenter  = "infrastructure"
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}