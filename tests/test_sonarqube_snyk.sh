#!/bin/bash
# Test script for SonarQube and Snyk integration

# Set variables
SONAR_HOST_URL=${SONAR_HOST_URL:-"http://localhost:9000"}
SONAR_TOKEN=${SONAR_TOKEN:-""}
SNYK_TOKEN=${SNYK_TOKEN:-""}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing SonarQube and Snyk Integration${NC}"
echo "----------------------------------------"

# Test SonarQube connection
echo "Testing SonarQube connection..."
if [ -z "${SONAR_TOKEN}" ]; then
    echo -e "${YELLOW}SONAR_TOKEN environment variable is not set. Skipping SonarQube test.${NC}"
else
    # Test SonarQube connection using curl
    SONAR_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H "Authorization: Bearer ${SONAR_TOKEN}" "${SONAR_HOST_URL}/api/system/status")
    
    if [ "${SONAR_RESPONSE}" == "200" ]; then
        echo -e "${GREEN}SonarQube connection test passed!${NC}"
        
        # Get SonarQube version
        SONAR_VERSION=$(curl -s -H "Authorization: Bearer ${SONAR_TOKEN}" "${SONAR_HOST_URL}/api/system/status" | jq -r '.version')
        echo "SonarQube version: ${SONAR_VERSION}"
    else
        echo -e "${RED}SonarQube connection test failed! HTTP response code: ${SONAR_RESPONSE}${NC}"
        echo "Please check your SonarQube URL and token."
    fi
fi

echo ""

# Test Snyk CLI
echo "Testing Snyk CLI..."
if [ -z "${SNYK_TOKEN}" ]; then
    echo -e "${YELLOW}SNYK_TOKEN environment variable is not set. Skipping Snyk test.${NC}"
else
    # Check if Snyk CLI is installed
    if ! command -v snyk &> /dev/null; then
        echo -e "${YELLOW}Snyk CLI is not installed. Installing it now...${NC}"
        npm install -g snyk || {
            echo -e "${RED}Failed to install Snyk CLI. Please install it manually.${NC}"
            exit 1
        }
    fi
    
    # Test Snyk authentication
    echo "Authenticating with Snyk..."
    SNYK_OUTPUT=$(snyk auth "${SNYK_TOKEN}" 2>&1)
    
    if echo "${SNYK_OUTPUT}" | grep -q "Your account has been authenticated"; then
        echo -e "${GREEN}Snyk authentication test passed!${NC}"
        
        # Get Snyk version
        SNYK_VERSION=$(snyk --version)
        echo "Snyk version: ${SNYK_VERSION}"
        
        # Create a simple test file for Snyk to scan
        echo "Creating test file for Snyk scan..."
        mkdir -p /tmp/snyk-test
        cat > /tmp/snyk-test/package.json << EOF
{
  "name": "snyk-test",
  "version": "1.0.0",
  "dependencies": {
    "lodash": "4.17.15"
  }
}
EOF
        
        # Run a test scan
        echo "Running test Snyk scan..."
        cd /tmp/snyk-test
        SNYK_SCAN_OUTPUT=$(snyk test --json 2>&1)
        
        if echo "${SNYK_SCAN_OUTPUT}" | grep -q "vulnerabilities"; then
            echo -e "${GREEN}Snyk scan test passed! Vulnerabilities were detected as expected.${NC}"
        else
            echo -e "${YELLOW}Snyk scan did not detect vulnerabilities in the test file.${NC}"
        fi
        
        # Clean up
        cd - > /dev/null
        rm -rf /tmp/snyk-test
    else
        echo -e "${RED}Snyk authentication test failed!${NC}"
        echo "Please check your Snyk token."
    fi
fi

echo "----------------------------------------"
echo -e "${GREEN}Test completed.${NC}"