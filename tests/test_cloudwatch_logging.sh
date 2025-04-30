#!/bin/bash
# Test script for CloudWatch logging integration

# Set variables
TEST_LOG_GROUP="/gitlab/pipeline/test-$(date +%s)"
TEST_LOG_STREAM="test-stream-$(date +%s)"
TEST_LOG_MESSAGE="Test message from GitLab CI/CD pipeline test script at $(date)"
AWS_REGION=${AWS_REGION:-"us-east-1"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing CloudWatch Logging Integration${NC}"
echo "----------------------------------------"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials are not configured or invalid.${NC}"
    exit 1
fi

echo "Creating test log group in CloudWatch..."
aws logs create-log-group \
    --log-group-name "${TEST_LOG_GROUP}" \
    --region "${AWS_REGION}" || {
        echo -e "${RED}Failed to create test log group.${NC}"
        exit 1
    }

echo "Creating test log stream..."
aws logs create-log-stream \
    --log-group-name "${TEST_LOG_GROUP}" \
    --log-stream-name "${TEST_LOG_STREAM}" \
    --region "${AWS_REGION}" || {
        echo -e "${RED}Failed to create test log stream.${NC}"
        aws logs delete-log-group \
            --log-group-name "${TEST_LOG_GROUP}" \
            --region "${AWS_REGION}" &> /dev/null
        exit 1
    }

echo "Sending test log message..."
TIMESTAMP=$(date +%s)000
aws logs put-log-events \
    --log-group-name "${TEST_LOG_GROUP}" \
    --log-stream-name "${TEST_LOG_STREAM}" \
    --log-events timestamp=${TIMESTAMP},message="${TEST_LOG_MESSAGE}" \
    --region "${AWS_REGION}" || {
        echo -e "${RED}Failed to send test log message.${NC}"
        aws logs delete-log-group \
            --log-group-name "${TEST_LOG_GROUP}" \
            --region "${AWS_REGION}" &> /dev/null
        exit 1
    }

echo "Verifying log message was sent..."
sleep 2 # Give CloudWatch a moment to process the log

# Get the log events
LOG_EVENTS=$(aws logs get-log-events \
    --log-group-name "${TEST_LOG_GROUP}" \
    --log-stream-name "${TEST_LOG_STREAM}" \
    --region "${AWS_REGION}" \
    --output json)

# Check if the message is in the log events
if echo "${LOG_EVENTS}" | grep -q "${TEST_LOG_MESSAGE}"; then
    echo -e "${GREEN}Test passed! Log message was successfully sent to CloudWatch.${NC}"
else
    echo -e "${RED}Test failed! Log message was not found in CloudWatch.${NC}"
    echo "Expected message: ${TEST_LOG_MESSAGE}"
    echo "Log events:"
    echo "${LOG_EVENTS}"
fi

# Clean up
echo "Cleaning up test resources..."
aws logs delete-log-group \
    --log-group-name "${TEST_LOG_GROUP}" \
    --region "${AWS_REGION}" || {
        echo -e "${YELLOW}Warning: Failed to delete test log group. You may need to delete it manually.${NC}"
    }

echo "----------------------------------------"
echo -e "${GREEN}Test completed.${NC}"