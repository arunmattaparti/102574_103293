# Terraform ECS Infrastructure

This repository contains Terraform code to deploy an Amazon ECS (Elastic Container Service) infrastructure following best practices.

## Features

- **Modular Architecture**: Code is organized into reusable modules
- **State Management**: Configured for remote state with locking
- **Security**: Uses AWS Secrets Manager for sensitive data
- **Cost Optimization**: Implements right-sizing, autoscaling, and cost tracking tags
- **Infrastructure as Code**: Complete infrastructure defined as code
- **CI/CD Pipeline**: Jenkins pipeline for automated deployment
- **Configuration as Code**: Jenkins Configuration as Code (JCasC) template
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
├── Jenkinsfile             # Jenkins CI/CD pipeline definition
├── jenkins-pipeline.yaml   # Jenkins Configuration as Code template
├── JENKINS_PIPELINE.md     # Jenkins pipeline documentation
├── JENKINS_CASC.md         # Jenkins Configuration as Code documentation
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
- Jenkins server (for CI/CD pipeline)
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

### Automated Deployment with Jenkins

This repository includes two options for Jenkins automation:

#### Option 1: Jenkins Pipeline

1. Set up Jenkins with required plugins (see JENKINS_PIPELINE.md)
2. Create a new pipeline job pointing to this repository
3. Run the pipeline with appropriate parameters

For detailed instructions on using the Jenkins pipeline, see [JENKINS_PIPELINE.md](JENKINS_PIPELINE.md).

#### Option 2: Jenkins Configuration as Code

1. Set up Jenkins with the Configuration as Code plugin
2. Use the provided `jenkins-pipeline.yaml` template to configure Jenkins
3. Run the automatically created pipeline job

For detailed instructions on using Jenkins Configuration as Code, see [JENKINS_CASC.md](JENKINS_CASC.md).

## Modules

Each module has its own README with specific documentation.

## Testing

The repository includes integration tests for the Jenkins pipeline components:

1. AWS Secrets Manager integration
2. CloudWatch logging integration
3. SonarQube and Snyk integration

To run the tests, see the instructions in [tests/README.md](tests/README.md).
