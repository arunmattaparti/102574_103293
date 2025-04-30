# Complete ECS Infrastructure Example

This example demonstrates how to use all the modules together to create a complete ECS infrastructure.

## Features

- VPC with public and private subnets
- ECS cluster with Fargate launch type
- Application Load Balancer
- Auto Scaling based on CPU and memory utilization
- AWS Secrets Manager integration
- Comprehensive tagging for cost tracking

## Usage

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Clean up when done
terraform destroy
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| AWS Region | Region to deploy resources | us-east-1 |
| VPC CIDR | CIDR block for the VPC | 10.0.0.0/16 |
| Container Image | Docker image for the ECS task | nginx:latest |
| Container Port | Port exposed by the container | 80 |

## Outputs

| Name | Description |
|------|-------------|
| load_balancer_dns | DNS name of the load balancer |
| ecs_cluster_name | Name of the ECS cluster |
| secret_names | Names of the created secrets |

## Notes

- This example uses the Fargate launch type for ECS tasks
- Auto scaling is configured to scale based on CPU and memory utilization
- Secrets are stored in AWS Secrets Manager and injected into the container
- All resources are tagged for cost tracking