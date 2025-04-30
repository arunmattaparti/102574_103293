# Jenkins Configuration as Code for Terraform Deployment

This document explains how to use the Jenkins Configuration as Code (JCasC) YAML template for setting up a Jenkins instance that can deploy the Terraform ECS infrastructure to AWS.

## What is Jenkins Configuration as Code?

Jenkins Configuration as Code (JCasC) provides a way to define Jenkins configuration as a YAML file. This allows you to:

- Version control your Jenkins configuration
- Easily replicate Jenkins instances
- Automate the setup of Jenkins
- Ensure consistent configuration across environments

## Prerequisites

1. Jenkins server with the Configuration as Code plugin installed
2. Docker installed on the Jenkins server (for running the Terraform container)
3. AWS account with appropriate permissions
4. Git repository containing the Terraform code

## Setting Up Jenkins with JCasC

### Step 1: Install Required Plugins

Ensure the following plugins are installed on your Jenkins instance:

- Configuration as Code Plugin
- Pipeline Plugin
- Docker Pipeline Plugin
- AWS Credentials Plugin
- Terraform Plugin
- Git Plugin

### Step 2: Set Environment Variables

The JCasC YAML template uses environment variables for sensitive information. Set the following environment variables on your Jenkins server:

```bash
export CASC_JENKINS_CONFIG=/path/to/jenkins-pipeline.yaml
export ADMIN_PASSWORD=your-admin-password
export AWS_ACCESS_KEY_ID=your-aws-access-key
export AWS_SECRET_ACCESS_KEY=your-aws-secret-key
export TERRAFORM_BACKEND_KEY=your-backend-encryption-key
export GIT_REPO_URL=https://github.com/your-org/your-repo.git
```

### Step 3: Apply the Configuration

1. Place the `jenkins-pipeline.yaml` file in the location specified by `CASC_JENKINS_CONFIG`
2. Restart Jenkins or navigate to "Manage Jenkins" > "Configuration as Code" > "Reload existing configuration"

### Step 4: Verify the Configuration

After applying the configuration:

1. Check that the "terraform-ecs-infrastructure" job has been created
2. Verify that the AWS credentials are available
3. Ensure the Terraform tool is properly configured

## Using the Pipeline

Once the configuration is applied, you can use the pipeline as follows:

1. Navigate to the "terraform-ecs-infrastructure" job
2. Click "Build with Parameters"
3. Fill in the parameters:
   - Select the environment (dev, staging, prod)
   - Enter the AWS region
   - Enter the S3 bucket name for Terraform state
   - Enter the DynamoDB table name for state locking
   - Enter the container image to deploy
4. Click "Build"

## Customizing the Configuration

You can customize the JCasC YAML template to fit your specific needs:

- Add more parameters to the pipeline
- Configure additional security settings
- Add more jobs for different deployment scenarios
- Integrate with notification systems

## Troubleshooting

If you encounter issues with the JCasC configuration:

1. Check the Jenkins logs for errors
2. Verify that all required environment variables are set
3. Ensure that the YAML syntax is correct
4. Check that all referenced plugins are installed

## Best Practices

1. **Version Control**: Keep your JCasC YAML file in version control
2. **Environment Separation**: Use different Jenkins jobs for different environments
3. **Secrets Management**: Use a secure method for managing secrets (e.g., HashiCorp Vault)
4. **Backup**: Regularly backup your Jenkins configuration
5. **Testing**: Test configuration changes in a non-production Jenkins instance first

## References

- [Jenkins Configuration as Code Documentation](https://github.com/jenkinsci/configuration-as-code-plugin)
- [Terraform Jenkins Plugin Documentation](https://plugins.jenkins.io/terraform/)
- [AWS Credentials Plugin Documentation](https://plugins.jenkins.io/aws-credentials/)