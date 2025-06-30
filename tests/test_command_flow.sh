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
cleanup
echo ""

# Test 1: Create a simple command
echo -e "${BLUE}Test 1: Creating a simple command${NC}"
echo -e "Test flow command\n" | lie create test_flow_1

if [ -f "test_flow_1.json" ]; then
    echo -e "${GREEN}✅ PASS: Config file created${NC}"
else
    echo -e "${RED}❌ FAIL: Config file not created${NC}"
    exit 1
fi

# Test 2: Generate package
echo -e "${BLUE}Test 2: Generating package${NC}"
lie package test_flow_1

if [ -d "test_flow_1_cli" ]; then
    echo -e "${GREEN}✅ PASS: Package generated${NC}"
else
    echo -e "${RED}❌ FAIL: Package not generated${NC}"
    exit 1
fi

# Test 3: Install the command
echo -e "${BLUE}Test 3: Installing the command${NC}"
cd test_flow_1_cli
./install.sh
cd ..

if [ -f "$HOME/.local/bin/test_flow_1" ]; then
    echo -e "${GREEN}✅ PASS: Command installed successfully${NC}"
else
    echo -e "${RED}❌ FAIL: Command installation failed${NC}"
    exit 1
fi

# Test 4: List commands
echo -e "${BLUE}Test 4: Listing commands${NC}"
if lie list | grep -q "test_flow_1"; then
    echo -e "${GREEN}✅ PASS: Command appears in list${NC}"
else
    echo -e "${RED}❌ FAIL: Command not found in list${NC}"
    exit 1
fi

# Test 5: Test command execution
echo -e "${BLUE}Test 5: Testing command execution${NC}"
if lie test_flow_1 2>&1 | grep -q "Running test_flow_1"; then
    echo -e "${GREEN}✅ PASS: Command executes correctly${NC}"
else
    echo -e "${RED}❌ FAIL: Command execution failed${NC}"
    exit 1
fi

# Test 6: Test command help
echo -e "${BLUE}Test 6: Testing command help${NC}"
if lie test_flow_1 --help 2>&1 | grep -q "test_flow_1"; then
    echo -e "${GREEN}✅ PASS: Command help works${NC}"
else
    echo -e "${RED}❌ FAIL: Command help failed${NC}"
    exit 1
fi

# Test 7: Clean up manually
echo -e "${BLUE}Test 7: Cleaning up${NC}"
cleanup
echo -e "${GREEN}✅ PASS: Cleanup completed${NC}"

echo "================================================"
echo -e "${GREEN}🎉 All tests passed! Command flow is working correctly.${NC}"

cleanup() {
    rm -f test_flow_*.sh test_flow_*.json
    rm -rf test_flow_*_cli
    rm -rf "$LIE_HOME/modules/test_flow_1"
    rm -f "$HOME/.local/bin/test_flow_1"
} 