#!/bin/zsh

# Test runner for lie CLI framework
# Runs all test suites and provides a summary

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TEST_DIR="$(dirname "$0")"
TMP_DIR="$TEST_DIR/.tmp"

echo -e "${BLUE}🧪 lie CLI Framework Test Suite${NC}"
echo "====================================="
echo ""

# Ensure tmp directory exists
mkdir -p "$TMP_DIR"

# Test results tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_file="$2"
    
    echo -e "${BLUE}📋 Running: $test_name${NC}"
    echo -e "${YELLOW}File: $test_file${NC}"
    echo ""
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ./"$test_file"; then
        echo -e "${GREEN}✅ $test_name: PASSED${NC}"
        echo ""
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ $test_name: FAILED${NC}"
        echo ""
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Run all tests
cd "$TEST_DIR"

echo -e "${BLUE}🚀 Starting test execution...${NC}"
echo ""

run_test "Basic Workflow Test" "test_new_workflow.sh"
run_test "Comprehensive Test" "test_comprehensive.sh"

# Summary
echo -e "${BLUE}📊 Test Summary${NC}"
echo "================"
echo -e "Tests Run: $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    echo -e "${BLUE}✅ Framework is working correctly${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo -e "${YELLOW}Please check the output above for details${NC}"
    exit 1
fi 