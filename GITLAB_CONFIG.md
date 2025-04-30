# GitLab Configuration for Terraform Deployment

This document explains how to use GitLab configuration for setting up a GitLab instance that can deploy the Terraform ECS infrastructure to AWS.

## What is GitLab Configuration as Code?

GitLab provides several ways to configure your GitLab instance and projects programmatically:

- **GitLab CI/CD Configuration**: Define your CI/CD pipelines as YAML files
- **GitLab API**: Automate GitLab configuration through REST API calls
- **GitLab Terraform Provider**: Manage GitLab resources using Terraform
- **GitLab Project Templates**: Create standardized project templates

These approaches allow you to:

- Version control your GitLab configuration
- Easily replicate GitLab projects and pipelines
- Automate the setup of GitLab
- Ensure consistent configuration across projects

## Prerequisites

1. GitLab instance (self-managed or GitLab.com)
2. Docker installed on GitLab Runners (for running the Terraform container)
3. AWS account with appropriate permissions
4. Git repository containing the Terraform code

## Setting Up GitLab for Terraform Deployment

### Step 1: Configure GitLab Runners

Ensure you have GitLab Runners configured with Docker executor:

1. Install GitLab Runner on your server
2. Register the runner with your GitLab instance:

```bash
gitlab-runner register \
  --url https://gitlab.example.com/ \
  --registration-token YOUR_REGISTRATION_TOKEN \
  --executor docker \
  --docker-image alpine:latest \
  --description "Docker Runner" \
  --tag-list "docker" \
  --run-untagged
```

### Step 2: Configure CI/CD Variables

Set up the required CI/CD variables in your GitLab project:

1. Navigate to Settings > CI/CD > Variables
2. Add the following variables:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `TF_STATE_BUCKET`: S3 bucket for Terraform state
   - `SONAR_HOST_URL`: URL of your SonarQube server
   - `SONAR_TOKEN`: SonarQube authentication token
   - `SNYK_TOKEN`: Snyk authentication token

### Step 3: Import the Project Template

If you're using GitLab project templates:

1. Create a new project in GitLab
2. Select "Import project from template"
3. Choose the "Terraform ECS Infrastructure" template
4. Follow the setup wizard to configure your project

### Step 4: Configure GitLab Environments

Set up environments for your deployments:

1. Navigate to Operations > Environments
2. Create environments for dev, staging, and prod
3. Configure deployment approvals for staging and prod environments:
   - Go to Settings > CI/CD > Protected environments
   - Add "staging" and "prod" as protected environments
   - Specify which roles can deploy to these environments

### Step 5: Verify the Configuration

After setting up the configuration:

1. Check that the CI/CD pipeline is properly configured
2. Verify that the AWS credentials are available to the pipeline
3. Ensure the Terraform tool is properly configured in the pipeline
4. Test the pipeline by making a small change and pushing it

## Using the GitLab Terraform Provider

You can also manage your GitLab configuration using Terraform with the GitLab provider:

```hcl
terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 3.0"
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
  base_url = "https://gitlab.example.com/api/v4/"
}

resource "gitlab_project" "terraform_ecs_project" {
  name        = "terraform-ecs-infrastructure"
  description = "Terraform ECS Infrastructure Deployment"
  visibility_level = "private"
  
  # Enable CI/CD features
  builds_enabled = true
  issues_enabled = true
  merge_requests_enabled = true
  
  # Configure CI/CD settings
  ci_config_path = ".gitlab-ci.yml"
}

resource "gitlab_project_variable" "aws_access_key" {
  project = gitlab_project.terraform_ecs_project.id
  key     = "AWS_ACCESS_KEY_ID"
  value   = var.aws_access_key_id
  protected = true
  masked = true
}

resource "gitlab_project_variable" "aws_secret_key" {
  project = gitlab_project.terraform_ecs_project.id
  key     = "AWS_SECRET_ACCESS_KEY"
  value   = var.aws_secret_access_key
  protected = true
  masked = true
}
```

## Customizing the Configuration

You can customize the GitLab configuration to fit your specific needs:

- Modify the `.gitlab-ci.yml` file to add more stages or jobs
- Configure additional CI/CD variables for your specific requirements
- Set up branch protection rules for your main branch
- Configure merge request approvals
- Set up GitLab webhooks for notifications

## Troubleshooting

If you encounter issues with the GitLab configuration:

1. Check the GitLab Runner logs for errors
2. Verify that all required CI/CD variables are set
3. Ensure that the YAML syntax in `.gitlab-ci.yml` is correct
4. Check that GitLab Runners are properly configured and running
5. Verify that Docker is working correctly on the runner

## Best Practices

1. **Version Control**: Keep your GitLab CI/CD configuration in version control
2. **Environment Separation**: Use different GitLab environments for different deployment targets
3. **Secrets Management**: Use GitLab CI/CD variables for secrets or integrate with a secure vault solution
4. **Backup**: Regularly backup your GitLab configuration
5. **Testing**: Test configuration changes in a non-production GitLab instance first

## References

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [GitLab Terraform Provider Documentation](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs)
- [GitLab API Documentation](https://docs.gitlab.com/ee/api/)
- [GitLab Project Templates](https://docs.gitlab.com/ee/user/project/working_with_projects.html#project-templates)