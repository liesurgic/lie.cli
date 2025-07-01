#!/bin/zsh

# Subcommand Template for lie CLI Framework
# This template creates a subcommand that can be added to a module

# Subcommand metadata
SUBCOMMAND_NAME="$(basename "$0" .sh)"
SUBCOMMAND_DESCRIPTION="A template subcommand for the lie CLI framework"
SUBCOMMAND_VERSION="1.0.0"

# Subcommand help
show_subcommand_help() {
    echo -e "${BLUE}$SUBCOMMAND_NAME v$SUBCOMMAND_VERSION${NC}"
    echo ""
    echo "Description: $SUBCOMMAND_DESCRIPTION"
    echo ""
    echo "Usage: lie <module> $SUBCOMMAND_NAME [options]"
    echo ""
    echo "Options:"
    echo "  --verbose, -v    Enable verbose output"
    echo "  --quiet, -q      Suppress output"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  lie <module> $SUBCOMMAND_NAME"
    echo "  lie <module> $SUBCOMMAND_NAME --verbose"
}

# Main subcommand logic
main_subcommand() {
    local verbose=false
    local quiet=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose|-v)
                verbose=true
                shift
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            --help|-h)
                show_subcommand_help
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Your subcommand logic goes here
    if [ "$verbose" = true ]; then
        log info "Running $SUBCOMMAND_NAME in verbose mode"
    fi
    
    if [ "$quiet" = false ]; then
        print_info "Hello from $SUBCOMMAND_NAME!"
        print_success "Subcommand executed successfully"
    fi
}

# Run the subcommand
main_subcommand "$@" 