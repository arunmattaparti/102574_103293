pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:1.0.0'
            args '--entrypoint="" -v ${WORKSPACE}:/workspace -w /workspace'
        }
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Environment to deploy to'
        )
        string(
            name: 'AWS_REGION',
            defaultValue: 'us-east-1',
            description: 'AWS region to deploy to'
        )
        string(
            name: 'TF_STATE_BUCKET',
            defaultValue: '',
            description: 'S3 bucket for Terraform state'
        )
        string(
            name: 'TF_STATE_KEY',
            defaultValue: 'ecs-infrastructure/terraform.tfstate',
            description: 'S3 key for Terraform state'
        )
        string(
            name: 'TF_LOCK_TABLE',
            defaultValue: 'terraform-state-lock',
            description: 'DynamoDB table for state locking'
        )
        string(
            name: 'CONTAINER_IMAGE',
            defaultValue: 'nginx:latest',
            description: 'Container image to deploy'
        )
    }

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_VAR_environment = "${params.ENVIRONMENT}"
        TF_VAR_aws_region = "${params.AWS_REGION}"
        TF_VAR_container_image = "${params.CONTAINER_IMAGE}"
        // AWS credentials will be injected by Jenkins credentials plugin
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Configure the backend if S3 bucket is provided
                    if (params.TF_STATE_BUCKET) {
                        sh """
                        terraform init \
                            -backend-config="bucket=${params.TF_STATE_BUCKET}" \
                            -backend-config="key=${params.TF_STATE_KEY}" \
                            -backend-config="region=${params.AWS_REGION}" \
                            -backend-config="dynamodb_table=${params.TF_LOCK_TABLE}" \
                            -backend-config="encrypt=true"
                        """
                    } else {
                        sh "terraform init"
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
                sh 'terraform show -no-color tfplan > tfplan.txt'
                archiveArtifacts artifacts: 'tfplan.txt', allowEmptyArchive: true
            }
        }

        stage('Approval') {
            when {
                expression { params.ENVIRONMENT == 'staging' || params.ENVIRONMENT == 'prod' }
            }
            steps {
                input message: "Deploy to ${params.ENVIRONMENT}?"
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}