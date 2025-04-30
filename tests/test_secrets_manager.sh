#!/bin/bash
# Test script for AWS Secrets Manager integration

# Set variables
TEST_SECRET_NAME="test-secret-$(date +%s)"
TEST_SECRET_VALUE="test-value-$(date +%s)"
AWS_REGION=${AWS_REGION:-"us-east-1"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing AWS Secrets Manager Integration${NC}"
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

echo "Creating test secret in AWS Secrets Manager..."
aws secretsmanager create-secret \
    --name "${TEST_SECRET_NAME}" \
    --description "Test secret for Jenkins pipeline" \
    --secret-string "{\"testKey\":\"${TEST_SECRET_VALUE}\"}" \
    --region "${AWS_REGION}" || {
        echo -e "${RED}Failed to create test secret.${NC}"
        exit 1
    }

echo "Test secret created successfully."

# Verify the secret exists
echo "Verifying secret exists..."
SECRET_ARN=$(aws secretsmanager describe-secret \
    --secret-id "${TEST_SECRET_NAME}" \
    --region "${AWS_REGION}" \
    --query 'ARN' \
    --output text) || {
        echo -e "${RED}Failed to verify test secret.${NC}"
        aws secretsmanager delete-secret \
            --secret-id "${TEST_SECRET_NAME}" \
            --force-delete-without-recovery \
            --region "${AWS_REGION}" &> /dev/null
        exit 1
    }

echo "Secret ARN: ${SECRET_ARN}"

# Create a test script that simulates the Jenkins pipeline's secret retrieval
echo "Creating test script for secret retrieval..."
cat > /tmp/test_retrieve_secret.sh << EOF
#!/bin/bash
SECRET_JSON=\$(aws secretsmanager get-secret-value --secret-id "${TEST_SECRET_NAME}" --region "${AWS_REGION}" --query SecretString --output text)
echo \$SECRET_JSON | jq -r '.testKey'
EOF

chmod +x /tmp/test_retrieve_secret.sh

# Execute the test script
echo "Retrieving secret value..."
RETRIEVED_VALUE=$(/tmp/test_retrieve_secret.sh)

# Verify the retrieved value matches the original
if [ "${RETRIEVED_VALUE}" == "${TEST_SECRET_VALUE}" ]; then
    echo -e "${GREEN}Test passed! Retrieved value matches the original.${NC}"
else
    echo -e "${RED}Test failed! Retrieved value does not match the original.${NC}"
    echo "Expected: ${TEST_SECRET_VALUE}"
    echo "Got: ${RETRIEVED_VALUE}"
fi

# Clean up
echo "Cleaning up test resources..."
aws secretsmanager delete-secret \
    --secret-id "${TEST_SECRET_NAME}" \
    --force-delete-without-recovery \
    --region "${AWS_REGION}" || {
        echo -e "${YELLOW}Warning: Failed to delete test secret. You may need to delete it manually.${NC}"
    }

rm -f /tmp/test_retrieve_secret.sh

echo "----------------------------------------"
echo -e "${GREEN}Test completed.${NC}"