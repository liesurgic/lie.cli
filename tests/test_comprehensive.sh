#!/bin/zsh

# Comprehensive test for the lie CLI framework
# Tests all major functionality and edge cases

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TEST_MODULE="comprehensive-test"
TEST_ALIAS="ct"
LIE_HOME="$HOME/.lie"
TEST_TMP_DIR="$(dirname "$0")/.tmp"

echo -e "${BLUE}🧪 Comprehensive Test Suite${NC}"
echo "============================="

# Cleanup
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up...${NC}"
    rm -rf "$TEST_TMP_DIR/${TEST_MODULE}.json" "$TEST_TMP_DIR/${TEST_MODULE}_cli"
    rm -rf "$LIE_HOME/modules/$TEST_MODULE"
    rm -f "$HOME/.local/bin/$TEST_ALIAS"
}

cleanup

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

# Test 1: Create config with complex structure
test_step "1. Create Complex Config" "Creating config with multiple commands and flags"
lie create -y $TEST_MODULE

cat > "${TEST_MODULE}.json" <<EOF
{
    "name": "$TEST_MODULE",
    "description": "Comprehensive test module with complex commands",
    "alias": "$TEST_ALIAS",
    "commands": [
        {
            "name": "deploy",
            "description": "Deploy the application",
            "flags": [
                {
                    "name": "environment",
                    "shorthand": "e",
                    "description": "Target environment"
                },
                {
                    "name": "force",
                    "shorthand": "f",
                    "description": "Force deployment"
                }
            ]
        },
        {
            "name": "build",
            "description": "Build the application",
            "flags": [
                {
                    "name": "production",
                    "shorthand": "p",
                    "description": "Build for production"
                }
            ]
        },
        {
            "name": "test",
            "description": "Run tests",
            "flags": []
        },
        {
            "name": "status",
            "description": "Show status",
            "flags": []
        }
    ]
}
EOF
test_success "Complex config created"

# Test 2: Generate package
test_step "2. Generate Package" "Creating CLI package from complex config"
lie package $TEST_MODULE

if [ ! -d "${TEST_MODULE}_cli" ]; then
    test_error "CLI package not created"
fi

# Verify all commands were generated
for cmd in deploy build test status; do
    if ! grep -q "^$cmd()" "${TEST_MODULE}_cli/commands.sh"; then
        test_error "Command $cmd not generated"
    fi
done
test_success "Package generated with all commands"

# Test 3: Add complex logic
test_step "3. Add Complex Logic" "Adding logic that handles flags and arguments"
cat > "${TEST_MODULE}_cli/commands.sh" <<EOF
#!/bin/zsh

deploy() {
    local environment=""
    local force="false"
    
    # Parse arguments
    while [[ \$# -gt 0 ]]; do
        case \$1 in
            -e|--environment)
                environment="\$2"
                shift 2
                ;;
            -f|--force)
                force="true"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    print_info "Deploying to environment: \${environment:-default}"
    if [ "\$force" = "true" ]; then
        print_warn "Force mode enabled"
    fi
    print_success "Deployed successfully!"
}

build() {
    local production="false"
    
    # Parse arguments
    while [[ \$# -gt 0 ]]; do
        case \$1 in
            -p|--production)
                production="true"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    print_info "Building application..."
    if [ "\$production" = "true" ]; then
        print_info "Production build enabled"
    fi
    print_success "Build completed!"
}

test() {
    print_info "Running tests..."
    print_success "All tests passed!"
}

status() {
    print_info "Checking application status..."
    print_success "Status: Healthy"
}

help() {
    print_info "Available commands:"
    print_info "  deploy  - Deploy the application"
    print_info "  build   - Build the application"
    print_info "  test    - Run tests"
    print_info "  status  - Show status"
    print_info "  help    - Show this help"
}
EOF
test_success "Complex logic added"

# Test 4: Install
test_step "4. Install" "Installing the complex package"
cd "${TEST_MODULE}_cli"
./install.sh
cd ../..
test_success "Package installed"

# Test 5: Test all commands with flags
test_step "5. Test Commands with Flags" "Testing all commands with various flag combinations"

# Test deploy with flags
output=$($TEST_ALIAS deploy --environment prod --force 2>&1)
if ! echo "$output" | grep -q "Deploying to environment: prod"; then
    test_error "deploy with environment flag failed"
fi

# Test build with production flag
output=$($TEST_ALIAS build --production 2>&1)
if ! echo "$output" | grep -q "Building application"; then
    test_error "build command failed"
fi

# Test simple commands
$TEST_ALIAS test > /dev/null 2>&1
$TEST_ALIAS status > /dev/null 2>&1

test_success "All commands working"

# Test 6: Test lie prefix
test_step "6. Test Lie Prefix" "Testing lie prefix with complex commands"
lie $TEST_MODULE deploy -e staging > /dev/null 2>&1
lie $TEST_MODULE build -p > /dev/null 2>&1
test_success "Lie prefix with flags working"

# Test 7: Test help system
test_step "7. Test Help System" "Testing help and documentation"
output=$($TEST_ALIAS help 2>&1)
if ! echo "$output" | grep -q "Available commands"; then
    test_error "Help system not working"
fi
test_success "Help system working"

# Test 8: Test module listing
test_step "8. Test Module Management" "Testing module listing and management"
lie list | grep -q "$TEST_MODULE"
test_success "Module appears in list"

# Test 9: Test error handling
test_step "9. Test Error Handling" "Testing invalid commands and arguments"
if $TEST_ALIAS invalid-command > /dev/null 2>&1; then
    test_error "Invalid command should fail"
fi
test_success "Error handling working"

# Test 10: Test alias persistence
test_step "10. Test Alias Persistence" "Testing alias works after shell restart simulation"
if [ ! -x "$HOME/.local/bin/$TEST_ALIAS" ]; then
    test_error "Alias not executable"
fi
test_success "Alias persistent and executable"

echo -e "${GREEN}🎉 All Comprehensive Tests Passed!${NC}"
echo "====================================="
echo ""
echo -e "${BLUE}✅ Framework Features Validated:${NC}"
echo "  • Complex config creation with multiple commands"
echo "  • Flag parsing and argument handling"
echo "  • Package generation from complex configs"
echo "  • Custom logic with flag processing"
echo "  • Installation and alias creation"
echo "  • Both alias and lie prefix access"
echo "  • Help system and documentation"
echo "  • Error handling and validation"
echo "  • Module management and listing"
echo "  • Persistence and executable permissions"
echo ""
cleanup
echo -e "${GREEN}🎯 Comprehensive test completed successfully!${NC}" 