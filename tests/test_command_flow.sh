#!/bin/zsh
setopt +o nomatch

# Test script for lie CLI Framework - Command Flow Testing
# Tests the full flow: create -> install -> test -> uninstall

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing lie CLI Framework - Command Flow${NC}"
echo "================================================"
echo ""

# Ensure framework is installed
echo -e "${YELLOW}Ensuring framework is installed...${NC}"
if ! command -v lie >/dev/null 2>&1; then
    echo -e "${RED}Framework not installed. Running install...${NC}"
    ./install.sh
    source ~/.zshrc
fi
echo ""

# Clean up any existing test files
echo -e "${YELLOW}Cleaning up any existing test files...${NC}"
rm -f test_flow_*.sh
lie uninstall test_flow_1 2>/dev/null || true
lie uninstall test_flow_2 2>/dev/null || true
echo ""

# Test 1: Create a simple command
echo -e "${BLUE}Test 1: Creating a simple command${NC}"
cat <<EOF | lie create test_flow_1
simple test command

EOF

if [ -f "test_flow_1.sh" ]; then
    echo -e "${GREEN}✅ PASS: Command file created${NC}"
else
    echo -e "${RED}❌ FAIL: Command file not created${NC}"
    exit 1
fi

# Test 2: Install the command
echo -e "${BLUE}Test 2: Installing the command${NC}"
if lie install test_flow_1.sh 2>&1 | grep -q "Command 'test_flow_1' installed successfully"; then
    echo -e "${GREEN}✅ PASS: Command installed successfully${NC}"
else
    echo -e "${RED}❌ FAIL: Command installation failed${NC}"
    exit 1
fi

# Test 3: List commands
echo -e "${BLUE}Test 3: Listing commands${NC}"
if lie list | grep -q "test_flow_1"; then
    echo -e "${GREEN}✅ PASS: Command appears in list${NC}"
else
    echo -e "${RED}❌ FAIL: Command not found in list${NC}"
    exit 1
fi

# Test 4: Test command execution
echo -e "${BLUE}Test 4: Testing command execution${NC}"
if lie test_flow_1 2>&1 | grep -q "Hello from test_flow_1"; then
    echo -e "${GREEN}✅ PASS: Command executes correctly${NC}"
else
    echo -e "${RED}❌ FAIL: Command execution failed${NC}"
    exit 1
fi

# Test 5: Test command help
echo -e "${BLUE}Test 5: Testing command help${NC}"
if lie test_flow_1 --help 2>&1 | grep -q "test_flow_1"; then
    echo -e "${GREEN}✅ PASS: Command help works${NC}"
else
    echo -e "${RED}❌ FAIL: Command help failed${NC}"
    exit 1
fi

# Test 6: Uninstall command
echo -e "${BLUE}Test 6: Uninstalling command${NC}"
if lie uninstall test_flow_1 2>&1 | grep -q "Command 'test_flow_1' uninstalled successfully"; then
    echo -e "${GREEN}✅ PASS: Command uninstalled successfully${NC}"
else
    echo -e "${RED}❌ FAIL: Command uninstall failed${NC}"
    exit 1
fi

# Test 7: Verify command is uninstalled
echo -e "${BLUE}Test 7: Verifying command is uninstalled${NC}"
if lie list | grep -q "No commands installed yet"; then
    echo -e "${GREEN}✅ PASS: Command properly uninstalled${NC}"
else
    echo -e "${RED}❌ FAIL: Command still appears in list${NC}"
    exit 1
fi

# Cleanup
echo -e "${YELLOW}Cleaning up test files...${NC}"
rm -f test_flow_*.sh
echo ""

echo "================================================"
echo -e "${GREEN}🎉 All tests passed! Command flow is working correctly.${NC}" 