pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock --entrypoint=""'
        }
    }

    environment {
        AWS_REGION = "${params.AWS_REGION}"
        TF_IN_AUTOMATION = "true"
        SONAR_HOST_URL = credentials('sonar-host-url')
        SONAR_TOKEN = credentials('sonar-token')
        SNYK_TOKEN = credentials('snyk-token')
        PIPELINE_LOG_GROUP = "/jenkins/pipeline/${env.JOB_NAME}"
        PIPELINE_LOG_STREAM = "${env.BUILD_NUMBER}"
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Environment to deploy to')
        string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS region to deploy to')
        string(name: 'TF_STATE_BUCKET', description: 'S3 bucket for Terraform state')
        string(name: 'TF_STATE_KEY', defaultValue: 'ecs-infrastructure/terraform.tfstate', description: 'S3 key for Terraform state')
        string(name: 'TF_LOCK_TABLE', defaultValue: 'terraform-state-lock', description: 'DynamoDB table for state locking')
        string(name: 'CONTAINER_IMAGE', defaultValue: 'nginx:latest', description: 'Container image to deploy')
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
        ansiColor('xterm')
    }

    stages {
        stage('Setup') {
            steps {
                script {
                    // Create CloudWatch log group and stream for pipeline logging
                    sh """
                        aws logs create-log-group --log-group-name ${PIPELINE_LOG_GROUP} --region ${params.AWS_REGION} || true
                        aws logs create-log-stream --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --region ${params.AWS_REGION} || true
                    """
                    
                    // Log pipeline start
                    def startMessage = "Pipeline started for environment: ${params.ENVIRONMENT}"
                    sh """
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="${startMessage}" --region ${params.AWS_REGION}
                    """
                    
                    // Install required tools
                    sh '''
                        apk add --no-cache curl python3 py3-pip jq nodejs npm
                        pip3 install awscli
                        npm install -g snyk
                        curl -L https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip -o build-wrapper.zip
                        unzip build-wrapper.zip
                        curl -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip -o sonar-scanner.zip
                        unzip sonar-scanner.zip
                        mv sonar-scanner-4.7.0.2747-linux sonar-scanner
                    '''
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    sh """
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Code checkout completed" --region ${params.AWS_REGION}
                    """
                }
            }
        }

        stage('Fetch Secrets') {
            steps {
                script {
                    // Retrieve secrets from AWS Secrets Manager
                    def secretsJson = sh(
                        script: "aws secretsmanager get-secret-value --secret-id ${params.ENVIRONMENT}/terraform-ecs --region ${params.AWS_REGION} --query SecretString --output text || echo '{}'",
                        returnStdout: true
                    ).trim()
                    
                    if (secretsJson != '{}') {
                        def secrets = readJSON text: secretsJson
                        
                        // Set secrets as environment variables
                        secrets.each { key, value ->
                            env."${key}" = value
                        }
                        
                        echo "Secrets retrieved successfully from AWS Secrets Manager"
                        sh """
                            aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Secrets retrieved from AWS Secrets Manager" --region ${params.AWS_REGION}
                        """
                    } else {
                        echo "No secrets found or unable to retrieve secrets"
                        sh """
                            aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Warning: No secrets found or unable to retrieve secrets" --region ${params.AWS_REGION}
                        """
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    sh """
                        export PATH=\$PATH:\$WORKSPACE/sonar-scanner/bin
                        sonar-scanner \\
                          -Dsonar.projectKey=terraform-ecs-infrastructure \\
                          -Dsonar.projectName='Terraform ECS Infrastructure' \\
                          -Dsonar.sources=. \\
                          -Dsonar.host.url=\${SONAR_HOST_URL} \\
                          -Dsonar.login=\${SONAR_TOKEN} \\
                          -Dsonar.exclusions=**/*.md,**/*.zip,**/*.tar,**/*.gz
                        
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="SonarQube analysis completed" --region ${params.AWS_REGION}
                    """
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                script {
                    sh """
                        snyk auth \${SNYK_TOKEN}
                        snyk iac test --severity-threshold=high
                        
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Snyk security scan completed" --region ${params.AWS_REGION}
                    """
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    sh """
                        terraform init \\
                          -backend-config="bucket=${params.TF_STATE_BUCKET}" \\
                          -backend-config="key=${params.TF_STATE_KEY}" \\
                          -backend-config="region=${params.AWS_REGION}" \\
                          -backend-config="dynamodb_table=${params.TF_LOCK_TABLE}"
                        
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Terraform initialization completed" --region ${params.AWS_REGION}
                    """
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
                script {
                    sh """
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Terraform validation completed" --region ${params.AWS_REGION}
                    """
                }
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check -recursive'
                script {
                    sh """
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Terraform format check completed" --region ${params.AWS_REGION}
                    """
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    sh """
                        terraform plan \\
                          -var="environment=${params.ENVIRONMENT}" \\
                          -var="region=${params.AWS_REGION}" \\
                          -var="container_image=${params.CONTAINER_IMAGE}" \\
                          -out=tfplan
                        
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Terraform plan completed" --region ${params.AWS_REGION}
                    """
                }
            }
        }

        stage('Approval') {
            when {
                expression { return params.ENVIRONMENT != 'dev' }
            }
            steps {
                script {
                    sh """
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Waiting for deployment approval" --region ${params.AWS_REGION}
                    """
                }
                timeout(time: 24, unit: 'HOURS') {
                    input message: "Deploy to ${params.ENVIRONMENT}?", ok: 'Deploy'
                }
                script {
                    sh """
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Deployment approved" --region ${params.AWS_REGION}
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh """
                        terraform apply -auto-approve tfplan
                        
                        aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Terraform apply completed" --region ${params.AWS_REGION}
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                def status = currentBuild.result ?: 'SUCCESS'
                sh """
                    aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Pipeline finished with status: ${status}" --region ${params.AWS_REGION}
                """
            }
            cleanWs()
        }
        success {
            script {
                sh """
                    aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Pipeline succeeded" --region ${params.AWS_REGION}
                """
            }
        }
        failure {
            script {
                sh """
                    aws logs put-log-events --log-group-name ${PIPELINE_LOG_GROUP} --log-stream-name ${PIPELINE_LOG_STREAM} --log-events timestamp=$(date +%s000),message="Pipeline failed" --region ${params.AWS_REGION}
                """
            }
        }
    }
}