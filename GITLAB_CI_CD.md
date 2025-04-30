# GitLab CI/CD Pipeline for Terraform ECS Infrastructure

This document explains how to set up and use the GitLab CI/CD pipeline for deploying the Terraform ECS infrastructure to AWS.

## Prerequisites

1. GitLab instance with the following features enabled:
   - GitLab CI/CD
   - GitLab Runners (with Docker executor)
   - GitLab Environments

2. AWS credentials configured in GitLab CI/CD variables:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

3. S3 bucket and DynamoDB table for Terraform state management:
   - S3 bucket for storing Terraform state
   - DynamoDB table with a primary key named "LockID" for state locking

4. SonarQube server:
   - Configure `SONAR_HOST_URL` and `SONAR_TOKEN` in GitLab CI/CD variables

5. Snyk account:
   - Configure `SNYK_TOKEN` in GitLab CI/CD variables

## Pipeline Configuration

The pipeline is defined in the `.gitlab-ci.yml` file at the root of the repository. It uses Docker containers with Terraform installed to run the deployment process.

### Pipeline Variables

The pipeline uses the following variables:

- **ENVIRONMENT**: Environment to deploy to (dev, staging, prod)
- **AWS_REGION**: AWS region to deploy to (default: us-east-1)
- **TF_STATE_BUCKET**: S3 bucket for Terraform state
- **TF_STATE_KEY**: S3 key for Terraform state (default: ecs-infrastructure/terraform.tfstate)
- **TF_LOCK_TABLE**: DynamoDB table for state locking (default: terraform-state-lock)
- **CONTAINER_IMAGE**: Container image to deploy (default: nginx:latest)

### Pipeline Stages

The pipeline includes the following stages:

1. **Setup**: Installs required tools and sets up CloudWatch logging
2. **Validate**: Validates the Terraform code and checks formatting
3. **Quality**: Performs code quality analysis using SonarQube
4. **Security**: Performs security scanning using Snyk
5. **Plan**: Creates a Terraform plan for each environment
6. **Approve**: Requires manual approval for staging and prod environments
7. **Apply**: Applies the Terraform plan to create/update the infrastructure

## Setting Up the Pipeline in GitLab

1. Ensure your project is hosted on GitLab
2. Configure the required CI/CD variables in GitLab:
   - Go to Settings > CI/CD > Variables
   - Add the following variables:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`
     - `TF_STATE_BUCKET`
     - `SONAR_HOST_URL`
     - `SONAR_TOKEN`
     - `SNYK_TOKEN`
3. Ensure you have GitLab Runners configured with the Docker executor
4. Push your code to GitLab to trigger the pipeline

## Running the Pipeline

The pipeline will automatically run when changes are pushed to the repository:

1. For merge requests, it will run validation, formatting checks, SonarQube analysis, and Snyk security scanning
2. For the main branch, it will run the full pipeline including deployment to dev, staging, and prod environments

### Manual Approvals

For staging and production environments, the pipeline includes manual approval steps:

1. Navigate to the pipeline in GitLab CI/CD
2. Find the "approve_staging" or "approve_prod" job
3. Click the "Play" button to approve the deployment
4. The pipeline will continue with the deployment to the approved environment

## Environment Management

The pipeline creates GitLab environments for staging and production:

1. Navigate to Operations > Environments to see the deployed environments
2. Each environment shows the latest deployment status and commit
3. You can manually stop or re-deploy environments from this page

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

1. AWS credentials are correctly configured in GitLab CI/CD variables
2. S3 bucket and DynamoDB table exist and are accessible
3. Terraform code is valid and properly formatted
4. GitLab Runners are properly configured and running
5. SonarQube server is accessible and token is valid
6. Snyk token is valid
7. AWS Secrets Manager contains the required secrets
8. CloudWatch logs for detailed execution information

For more detailed logs, check the CloudWatch log group `/gitlab/pipeline` or the job logs in GitLab CI/CD.