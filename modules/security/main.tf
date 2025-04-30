# Security module - Creates IAM roles, security groups, etc.

# ECS task execution role
resource "aws_iam_role" "execution_role" {
  name = "${var.name_prefix}-ecs-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
  
  tags = var.tags
}

# Attach the ECS task execution role policy
resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create a policy for accessing secrets
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.name_prefix}-secrets-access-policy"
  description = "Policy to allow access to specific secrets in Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = var.secrets_arns
      }
    ]
  })
  
  tags = var.tags
}

# Attach the secrets access policy to the execution role
resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

# ECS task role
resource "aws_iam_role" "task_role" {
  name = "${var.name_prefix}-ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
  
  tags = var.tags
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name_prefix}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-tasks-sg"
  })
}

# Security group for the load balancer
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for the application load balancer"
  vpc_id      = var.vpc_id
  
  # Allow HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTPS traffic from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

# Allow inbound traffic from the ALB to the ECS tasks
resource "aws_security_group_rule" "ecs_from_alb" {
  security_group_id        = aws_security_group.ecs_tasks.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow inbound traffic from ALB"
}