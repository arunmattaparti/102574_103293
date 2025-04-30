# Jenkins CI/CD Pipeline for Terraform ECS Infrastructure

This document explains how to set up and use the Jenkins pipeline for deploying the Terraform ECS infrastructure to AWS.

## Prerequisites

1. Jenkins server with the following plugins installed:
   - Pipeline
   - Docker Pipeline
   - AWS Credentials Plugin
   - Credentials Plugin
   - Pipeline: AWS Steps
   - SonarQube Scanner
   - Snyk Security
   - AWS CloudWatch Logs Publisher

2. AWS credentials configured in Jenkins:
   - Create credentials of type "AWS Credentials" with ID `aws-credentials` and `aws-secret-access-key`

3. S3 bucket and DynamoDB table for Terraform state management:
   - S3 bucket for storing Terraform state
   - DynamoDB table with a primary key named "LockID" for state locking

4. SonarQube server:
   - Configure SonarQube server URL and token in Jenkins credentials

5. Snyk account:
   - Configure Snyk API token in Jenkins credentials

## Pipeline Configuration

The pipeline is defined in the `Jenkinsfile` at the root of the repository. It uses a Docker container with Terraform installed to run the deployment process.

### Pipeline Parameters

The pipeline accepts the following parameters:

- **ENVIRONMENT**: Environment to deploy to (dev, staging, prod)
- **AWS_REGION**: AWS region to deploy to (default: us-east-1)
- **TF_STATE_BUCKET**: S3 bucket for Terraform state
- **TF_STATE_KEY**: S3 key for Terraform state (default: ecs-infrastructure/terraform.tfstate)
- **TF_LOCK_TABLE**: DynamoDB table for state locking (default: terraform-state-lock)
- **CONTAINER_IMAGE**: Container image to deploy (default: nginx:latest)

### Pipeline Stages

The pipeline includes the following stages:

1. **Setup**: Installs required tools and sets up CloudWatch logging
2. **Checkout**: Checks out the code from the repository
3. **Fetch Secrets**: Retrieves secrets from AWS Secrets Manager
4. **SonarQube Analysis**: Performs code quality analysis using SonarQube
5. **Snyk Security Scan**: Performs security scanning using Snyk
6. **Terraform Init**: Initializes Terraform with the specified backend configuration
7. **Terraform Validate**: Validates the Terraform code
8. **Terraform Format Check**: Checks that the Terraform code is properly formatted
9. **Terraform Plan**: Creates a plan of the changes to be applied
10. **Approval**: Requires manual approval for staging and prod environments
11. **Terraform Apply**: Applies the Terraform plan to create/update the infrastructure

## Setting Up the Pipeline in Jenkins

1. In Jenkins, create a new Pipeline job
2. Configure the job to use "Pipeline script from SCM"
3. Set the SCM to Git and provide your repository URL
4. Set the Script Path to "Jenkinsfile"
5. Save the job

## Running the Pipeline

1. Navigate to the Jenkins job
2. Click "Build with Parameters"
3. Fill in the parameters:
   - Select the environment (dev, staging, prod)
   - Enter the AWS region
   - Enter the S3 bucket name for Terraform state
   - Enter the DynamoDB table name for state locking
   - Enter the container image to deploy
4. Click "Build"

## Best Practices

1. **Environment Separation**: Use different state files for different environments
2. **Approval Process**: Require manual approval for production deployments
3. **Monitoring**: Monitor the pipeline execution and set up notifications for failures
4. **Secrets Management**: Use AWS Secrets Manager for sensitive information
5. **Testing**: Add automated tests to verify the infrastructure works as expected
6. **Code Quality**: Use SonarQube to ensure code quality standards are met
7. **Security Scanning**: Use Snyk to identify security vulnerabilities
8. **Logging**: Use CloudWatch to monitor pipeline execution and troubleshoot issues

## Troubleshooting

If the pipeline fails, check the following:

1. AWS credentials are correctly configured in Jenkins
2. S3 bucket and DynamoDB table exist and are accessible
3. Terraform code is valid and properly formatted
4. Jenkins has sufficient permissions to run Docker containers
5. SonarQube server is accessible and token is valid
6. Snyk token is valid
7. AWS Secrets Manager contains the required secrets
8. CloudWatch logs for detailed execution information

For more detailed logs, check the CloudWatch log group `/jenkins/pipeline` or the console output of the Jenkins job.