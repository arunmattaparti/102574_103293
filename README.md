# Terraform ECS Infrastructure

This repository contains Terraform code to deploy an Amazon ECS (Elastic Container Service) infrastructure following best practices.

## Features

- **Modular Architecture**: Code is organized into reusable modules
- **State Management**: Configured for remote state with locking
- **Security**: Uses AWS Secrets Manager for sensitive data
- **Cost Optimization**: Implements right-sizing, autoscaling, and cost tracking tags
- **Infrastructure as Code**: Complete infrastructure defined as code
- **CI/CD Pipeline**: GitLab CI/CD pipeline for automated deployment
- **Configuration as Code**: GitLab configuration templates
- **Code Quality**: SonarQube integration for code quality analysis
- **Security Scanning**: Snyk integration for security vulnerability detection
- **Approval Gates**: Manual approval required for production deployments
- **Logging & Monitoring**: CloudWatch integration for pipeline execution monitoring

## Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars.example # Example variable values
├── backend.tf              # State configuration
├── providers.tf            # Provider configuration
├── .gitlab-ci.yml          # GitLab CI/CD pipeline definition
├── gitlab-ci-template.yml  # GitLab CI/CD template
├── GITLAB_CI_CD.md         # GitLab CI/CD documentation
├── GITLAB_CONFIG.md        # GitLab configuration documentation
├── modules/                # Reusable modules
│   ├── ecs/                # ECS cluster and service
│   ├── networking/         # VPC, subnets, etc.
│   ├── security/           # IAM roles, security groups
│   ├── autoscaling/        # Scaling policies
│   └── secrets/            # AWS Secrets Manager
├── examples/               # Example configurations
└── tests/                  # Integration tests
    ├── test_secrets_manager.sh    # AWS Secrets Manager tests
    ├── test_cloudwatch_logging.sh # CloudWatch logging tests
    ├── test_sonarqube_snyk.sh     # SonarQube and Snyk tests
    └── run_tests.sh               # Test runner script
```

## Prerequisites

- Terraform v1.0+
- AWS CLI configured with appropriate permissions
- S3 bucket and DynamoDB table for remote state (optional)
- GitLab instance or GitLab.com account (for CI/CD pipeline)
- SonarQube server (for code quality analysis)
- Snyk account (for security scanning)

## Usage

### Manual Deployment

1. Clone this repository
2. Configure your AWS credentials
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and adjust values
4. Run `terraform init` to initialize
5. Run `terraform plan` to preview changes
6. Run `terraform apply` to deploy infrastructure

### Automated Deployment with GitLab CI/CD

This repository includes two options for GitLab CI/CD automation:

#### Option 1: GitLab CI/CD Pipeline

1. Set up GitLab with required runners (see GITLAB_CI_CD.md)
2. Configure CI/CD variables in your GitLab project
3. Push your code to GitLab to trigger the pipeline

For detailed instructions on using the GitLab CI/CD pipeline, see [GITLAB_CI_CD.md](GITLAB_CI_CD.md).

#### Option 2: GitLab Configuration Template

1. Set up GitLab with the appropriate configuration
2. Use the provided `gitlab-ci-template.yml` template to configure your pipeline
3. Customize the template for your specific needs

For detailed instructions on using GitLab configuration, see [GITLAB_CONFIG.md](GITLAB_CONFIG.md).

## Modules

Each module has its own README with specific documentation.

## Testing

The repository includes integration tests for the GitLab CI/CD pipeline components:

1. AWS Secrets Manager integration
2. CloudWatch logging integration
3. SonarQube and Snyk integration

To run the tests, see the instructions in [tests/README.md](tests/README.md).
