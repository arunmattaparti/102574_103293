# GitLab CI/CD Integration Tests

This directory contains test scripts to verify the integration of various components in the GitLab CI/CD pipeline.

## Available Tests

1. **AWS Secrets Manager Integration Test** (`test_secrets_manager.sh`)
   - Tests the ability to create, retrieve, and delete secrets in AWS Secrets Manager
   - Verifies that the pipeline can correctly access secrets

2. **CloudWatch Logging Integration Test** (`test_cloudwatch_logging.sh`)
   - Tests the ability to create log groups, streams, and send log events to CloudWatch
   - Verifies that the pipeline can correctly log its execution

3. **SonarQube and Snyk Integration Test** (`test_sonarqube_snyk.sh`)
   - Tests the connection to SonarQube server
   - Tests the authentication with Snyk
   - Verifies that both tools can perform scans

## Running the Tests

### Prerequisites

- AWS CLI installed and configured with appropriate permissions
- For SonarQube test: SonarQube server URL and token
- For Snyk test: Snyk API token and Node.js/npm installed

### Environment Variables

Set the following environment variables before running the tests:

```bash
export AWS_REGION=us-east-1  # Your AWS region
export SONAR_HOST_URL=http://your-sonarqube-server:9000
export SONAR_TOKEN=your-sonarqube-token
export SNYK_TOKEN=your-snyk-token
```

### Running All Tests

To run all tests at once:

```bash
cd /path/to/repository/tests
chmod +x run_tests.sh
./run_tests.sh
```

### Running Individual Tests

To run a specific test:

```bash
cd /path/to/repository/tests
chmod +x test_secrets_manager.sh
./test_secrets_manager.sh

# Or for CloudWatch logging test
chmod +x test_cloudwatch_logging.sh
./test_cloudwatch_logging.sh

# Or for SonarQube and Snyk test
chmod +x test_sonarqube_snyk.sh
./test_sonarqube_snyk.sh
```

## Test Results

Each test will output its results to the console, with colored output indicating success or failure. The `run_tests.sh` script will also provide a summary of all test results at the end.