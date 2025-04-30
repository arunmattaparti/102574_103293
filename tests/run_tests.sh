#!/bin/bash
# Master test script to run all tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Running all tests for Jenkins pipeline${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Make all test scripts executable
chmod +x ./test_*.sh

# Run AWS Secrets Manager test
echo -e "${YELLOW}Running AWS Secrets Manager test...${NC}"
./test_secrets_manager.sh
SECRETS_RESULT=$?
echo ""

# Run CloudWatch logging test
echo -e "${YELLOW}Running CloudWatch logging test...${NC}"
./test_cloudwatch_logging.sh
CLOUDWATCH_RESULT=$?
echo ""

# Run SonarQube and Snyk test
echo -e "${YELLOW}Running SonarQube and Snyk test...${NC}"
./test_sonarqube_snyk.sh
SONARQUBE_SNYK_RESULT=$?
echo ""

# Print summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}=========================================${NC}"

if [ $SECRETS_RESULT -eq 0 ]; then
    echo -e "AWS Secrets Manager: ${GREEN}PASSED${NC}"
else
    echo -e "AWS Secrets Manager: ${RED}FAILED${NC}"
fi

if [ $CLOUDWATCH_RESULT -eq 0 ]; then
    echo -e "CloudWatch Logging: ${GREEN}PASSED${NC}"
else
    echo -e "CloudWatch Logging: ${RED}FAILED${NC}"
fi

if [ $SONARQUBE_SNYK_RESULT -eq 0 ]; then
    echo -e "SonarQube and Snyk: ${GREEN}PASSED${NC}"
else
    echo -e "SonarQube and Snyk: ${RED}FAILED${NC}"
fi

echo -e "${BLUE}=========================================${NC}"

# Exit with overall status
if [ $SECRETS_RESULT -eq 0 ] && [ $CLOUDWATCH_RESULT -eq 0 ] && [ $SONARQUBE_SNYK_RESULT -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
fi