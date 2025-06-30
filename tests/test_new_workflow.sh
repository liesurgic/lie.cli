#!/bin/zsh

# Test script for the new config-driven lie CLI workflow

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TEST_MODULE="test-workflow"
TEST_ALIAS="tw"
LIE_HOME="$HOME/.lie"
TEST_TMP_DIR="$(dirname "$0")/.tmp"

echo -e "${BLUE}🧪 Testing New Config-Driven Workflow${NC}"
echo "=========================================="

# Cleanup
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up...${NC}"
    rm -rf "$TEST_TMP_DIR/${TEST_MODULE}.json" "$TEST_TMP_DIR/${TEST_MODULE}_cli"
    rm -rf "$LIE_HOME/modules/$TEST_MODULE"
    rm -f "$HOME/.local/bin/$TEST_ALIAS"
}

# Test functions
test_step() {
    echo -e "${BLUE}📋 $1${NC}"
    echo -e "${YELLOW}$2${NC}"
}

test_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

test_error() {
    echo -e "${RED}❌ $1${NC}"
    cleanup
    exit 1
}

# Test 1: Create config
test_step "1. Create Config" "Creating config file"
cd "$TEST_TMP_DIR"
echo -e "Test workflow module\n$TEST_ALIAS" | lie create $TEST_MODULE

if [ ! -f "${TEST_MODULE}.json" ]; then
    test_error "Config file not created"
fi
test_success "Config created"

# Test 2: Edit config
test_step "2. Edit Config" "Adding custom commands"
cat > "${TEST_MODULE}.json" <<EOF
{
    "name": "$TEST_MODULE",
    "description": "Test workflow module",
    "alias": "$TEST_ALIAS",
    "commands": [
        {
            "name": "start",
            "description": "Starts the workflow",
            "flags": []
        },
        {
            "name": "build",
            "description": "Builds the workflow",
            "flags": []
        }
    ]
}
EOF
test_success "Config updated"

# Test 3: Generate package
test_step "3. Generate Package" "Creating CLI package"
lie package $TEST_MODULE

if [ ! -d "${TEST_MODULE}_cli" ]; then
    test_error "CLI package not created"
fi
test_success "Package generated"

# Test 4: Add logic
test_step "4. Add Logic" "Adding custom logic"
cat > "${TEST_MODULE}_cli/commands.sh" <<EOF
#!/bin/zsh

start() {
    print_info "Starting $TEST_MODULE..."
    print_success "Started!"
}

build() {
    print_info "Building $TEST_MODULE..."
    print_success "Built!"
}

help() {
    print_info "Available: start, build, help"
}
EOF
test_success "Logic added"

# Test 5: Install
test_step "5. Install" "Installing package"
cd "${TEST_MODULE}_cli"
./install.sh
cd ../..
test_success "Package installed"

# Test 6: Test alias
test_step "6. Test Alias" "Testing direct access"
if [ ! -f "$HOME/.local/bin/$TEST_ALIAS" ]; then
    test_error "Alias not created"
fi

$TEST_ALIAS start > /dev/null 2>&1
test_success "Alias works"

# Test 7: Test lie prefix
test_step "7. Test Lie Prefix" "Testing lie prefix"
lie $TEST_MODULE build > /dev/null 2>&1
test_success "Lie prefix works"

# Test 8: Test list
test_step "8. Test List" "Testing module listing"
lie list | grep -q "$TEST_MODULE"
test_success "Module listed"

echo -e "${GREEN}🎉 All Tests Passed!${NC}"
cleanup 