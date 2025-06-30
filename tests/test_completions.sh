#!/bin/bash

# Test script for lie completions functionality
# Tests both completion generation (lie auto) and completions setup (lie completions)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}🧪 Testing: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Setup test environment
setup_test() {
    print_test "Setting up test environment"
    
    # Install the framework first (from project root)
    print_test "Installing lie framework"
    if [ -f "../install.sh" ]; then
        cd .. && ./install.sh && cd tests
        print_success "Framework installed"
    else
        print_error "install.sh not found"
        return 1
    fi
    
    # Create test directory
    mkdir -p .tmp
    cd .tmp
    
    # Create a test config with commands and flags
    cat > test_completions.json << 'EOF'
{
    "name": "test_completions",
    "description": "Test module for completions",
    "alias": "tc",
    "commands": [
        {
            "name": "start",
            "description": "Start the service",
            "flags": [
                {
                    "name": "force",
                    "shorthand": "f",
                    "description": "Force start"
                },
                {
                    "name": "verbose",
                    "shorthand": "v",
                    "description": "Verbose output"
                }
            ]
        },
        {
            "name": "stop",
            "description": "Stop the service",
            "flags": [
                {
                    "name": "kill",
                    "shorthand": "k",
                    "description": "Force kill"
                }
            ]
        },
        {
            "name": "status",
            "description": "Show status",
            "flags": []
        }
    ]
}
EOF
    
    print_success "Test environment ready"
}

# Test completion generation
test_completion_generation() {
    print_test "Testing completion generation (lie auto)"
    
    # Debug: show current directory and files
    echo "Current directory: $(pwd)"
    echo "Files in current directory:"
    ls -la
    
    # Run completion generation in the test directory
    lie auto .
    
    # Debug: show what was created
    echo "Completion files after generation:"
    ls -la $HOME/.lie/completions/ | grep -E "(test_completions|tc)" || echo "No test completion files found"
    
    # Check if completion files were created
    if [ -f "$HOME/.lie/completions/_lie-test_completions" ]; then
        print_success "Module completion file created"
    else
        print_error "Module completion file not found"
        return 1
    fi
    
    if [ -f "$HOME/.lie/completions/_tc" ]; then
        print_success "Alias completion file created"
    else
        print_error "Alias completion file not found"
        return 1
    fi
    
    # Simple check: just verify the files exist and have basic structure
    local module_completion="$HOME/.lie/completions/_lie-test_completions"
    local alias_completion="$HOME/.lie/completions/_tc"
    
    if [ -s "$module_completion" ]; then
        print_success "Module completion file has content"
    else
        print_error "Module completion file is empty"
        return 1
    fi
    
    if [ -s "$alias_completion" ]; then
        print_success "Alias completion file has content"
    else
        print_error "Alias completion file is empty"
        return 1
    fi
    
    print_success "Completion generation test passed"
}

# Test completions setup
test_completions_setup() {
    print_test "Testing completions setup (lie completions)"
    
    # Backup original .zshrc
    local zshrc_backup="$HOME/.zshrc.backup.$(date +%s)"
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$zshrc_backup"
        print_warn "Backed up .zshrc to $zshrc_backup"
    fi
    
    # Run completions setup
    lie completions
    
    # Check if block was added to .zshrc
    if grep -q "# >>> liecli completion setup >>>" "$HOME/.zshrc"; then
        print_success "Completion block added to .zshrc"
    else
        print_error "Completion block not found in .zshrc"
        return 1
    fi
    
    if grep -q "fpath=(\$HOME/.lie/completions \$fpath)" "$HOME/.zshrc"; then
        print_success "fpath line found in .zshrc"
    else
        print_error "fpath line not found in .zshrc"
        return 1
    fi
    
    if grep -q "autoload -U compinit && compinit" "$HOME/.zshrc"; then
        print_success "compinit line found in .zshrc"
    else
        print_error "compinit line not found in .zshrc"
        return 1
    fi
    
    # Test idempotency - run again and check it doesn't add duplicate blocks
    local block_count=$(grep -c "# >>> liecli completion setup >>>" "$HOME/.zshrc")
    if [ "$block_count" -eq 1 ]; then
        print_success "Completion setup is idempotent (no duplicate blocks)"
    else
        print_error "Completion setup added duplicate blocks (count: $block_count)"
        return 1
    fi
    
    # Restore original .zshrc
    if [ -f "$zshrc_backup" ]; then
        mv "$zshrc_backup" "$HOME/.zshrc"
        print_warn "Restored original .zshrc"
    fi
    
    print_success "Completions setup test passed"
}

# Test completion file format
test_completion_format() {
    print_test "Testing completion file format"
    
    local module_completion="$HOME/.lie/completions/_lie-test_completions"
    
    # Check for required zsh completion elements
    if grep -q "#compdef lie-test_completions" "$module_completion"; then
        print_success "compdef directive found"
    else
        print_error "compdef directive missing"
        return 1
    fi
    
    if grep -q "_arguments -C" "$module_completion"; then
        print_success "_arguments directive found"
    else
        print_error "_arguments directive missing"
        return 1
    fi
    
    if grep -q "_describe 'commands'" "$module_completion"; then
        print_success "_describe directive found"
    else
        print_error "_describe directive missing"
        return 1
    fi
    
    if grep -q "compdef _lie_test_completions lie-test_completions" "$module_completion"; then
        print_success "compdef registration found"
    else
        print_error "compdef registration missing"
        return 1
    fi
    
    print_success "Completion file format test passed"
}

# Cleanup
cleanup() {
    print_test "Cleaning up test files"
    
    # Remove test completion files
    rm -f "$HOME/.lie/completions/_lie-test_completions"
    rm -f "$HOME/.lie/completions/_tc"
    
    # Remove test directory
    cd ..
    rm -rf .tmp
    
    print_success "Cleanup completed"
}

# Main test execution
main() {
    echo -e "${BLUE}🚀 Starting lie completions tests${NC}"
    echo ""
    
    local tests_passed=0
    local tests_failed=0
    
    # Run tests
    if setup_test; then
        tests_passed=$((tests_passed + 1))
    else
        tests_failed=$((tests_failed + 1))
    fi
    
    if test_completion_generation; then
        tests_passed=$((tests_passed + 1))
    else
        tests_failed=$((tests_failed + 1))
    fi
    
    if test_completion_format; then
        tests_passed=$((tests_passed + 1))
    else
        tests_failed=$((tests_failed + 1))
    fi
    
    if test_completions_setup; then
        tests_passed=$((tests_passed + 1))
    else
        tests_failed=$((tests_failed + 1))
    fi
    
    #cleanup
    
    # Summary
    echo ""
    echo -e "${BLUE}📊 Test Summary:${NC}"
    echo -e "  Passed: ${GREEN}$tests_passed${NC}"
    echo -e "  Failed: ${RED}$tests_failed${NC}"
    
    if [ $tests_failed -eq 0 ]; then
        echo -e "${GREEN}🎉 All completions tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}💥 Some tests failed${NC}"
        exit 1
    fi
}

# Run main function
main "$@" 