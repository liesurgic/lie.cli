#!/bin/zsh

# Test script for lie CLI Framework

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing lie CLI Framework...${NC}"

# Test 1: Install framework
echo -e "${YELLOW}Test 1: Installing framework...${NC}"
./install.sh

# Test 2: Check if lie command is available
echo -e "${YELLOW}Test 2: Checking lie command...${NC}"
if command -v lie >/dev/null 2>&1; then
    echo -e "${GREEN}✅ lie command is available${NC}"
else
    echo -e "${RED}❌ lie command not found${NC}"
    exit 1
fi

# Test 3: Check framework help
echo -e "${YELLOW}Test 3: Testing framework help...${NC}"
if lie --help | grep -q "lie CLI Framework"; then
    echo -e "${GREEN}✅ Framework help works${NC}"
else
    echo -e "${RED}❌ Framework help failed${NC}"
    exit 1
fi

# Test 4: Check list command
echo -e "${YELLOW}Test 4: Testing list command...${NC}"
if lie list | grep -q "No commands installed yet" || lie list | grep -q "Installed Commands:"; then
    echo -e "${GREEN}✅ List command works${NC}"
else
    echo -e "${RED}❌ List command failed${NC}"
    exit 1
fi

# Test 5: Install example command
echo -e "${YELLOW}Test 5: Installing example command...${NC}"
lie install examples/hello.sh

# Test 6: Check if command was installed
echo -e "${YELLOW}Test 6: Verifying command installation...${NC}"
if lie list | grep -q "hello"; then
    echo -e "${GREEN}✅ Example command installed${NC}"
else
    echo -e "${RED}❌ Example command not found in list${NC}"
    exit 1
fi

# Test 7: Test example command
echo -e "${YELLOW}Test 7: Testing example command...${NC}"
if lie hello | grep -q "Hello, World!"; then
    echo -e "${GREEN}✅ Example command works${NC}"
else
    echo -e "${RED}❌ Example command failed${NC}"
    exit 1
fi

# Test 8: Test command with arguments
echo -e "${YELLOW}Test 8: Testing command with arguments...${NC}"
if lie hello Alice | grep -q "Hello, Alice!"; then
    echo -e "${GREEN}✅ Command with arguments works${NC}"
else
    echo -e "${RED}❌ Command with arguments failed${NC}"
    exit 1
fi

# Test 9: Test command info
echo -e "${YELLOW}Test 9: Testing command info...${NC}"
if lie info hello | grep -q "Command: hello"; then
    echo -e "${GREEN}✅ Command info works${NC}"
else
    echo -e "${RED}❌ Command info failed${NC}"
    exit 1
fi

# Test 10: Uninstall command
echo -e "${YELLOW}Test 10: Uninstalling command...${NC}"
lie uninstall hello

if ! lie list | grep -q "hello"; then
    echo -e "${GREEN}✅ Command uninstalled successfully${NC}"
else
    echo -e "${RED}❌ Command uninstall failed${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 All tests passed! Framework is working correctly.${NC}"
echo -e "${BLUE}You can now start using the lie CLI framework!${NC}" 