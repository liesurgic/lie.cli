#!/bin/zsh

# Command Template for lie CLI Framework
# Copy this file and modify it to create your own command

# Source common utilities
source "$LIE_HOME/utils/common.sh"

# Command metadata
COMMAND_NAME="$(basename "$0" .sh)"
COMMAND_VERSION="1.0.0"
COMMAND_DESCRIPTION="A template command for the lie CLI framework"

# Show command help
show_help() {
    echo -e "${BLUE}$COMMAND_NAME v$COMMAND_VERSION${NC}"
    echo ""
    echo "Description: $COMMAND_DESCRIPTION"
    echo ""
    echo "Usage: lie $COMMAND_NAME [subcommand] [options]"
    echo ""
    echo "Subcommands:"
    echo "  help     Show this help message"
    echo "  version  Show version information"
    echo "  status   Show status information"
    echo ""
    echo "Options:"
    echo "  --verbose, -v    Enable verbose output"
    echo "  --quiet, -q      Suppress output"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  lie $COMMAND_NAME status"
    echo "  lie $COMMAND_NAME --verbose"
}

# Show version information
show_version() {
    echo -e "${BLUE}$COMMAND_NAME v$COMMAND_VERSION${NC}"
    echo "Framework version: $FRAMEWORK_VERSION"
}

# Show status information
show_status() {
    echo -e "${BLUE}Status for $COMMAND_NAME${NC}"
    echo "Command: $COMMAND_NAME"
    echo "Version: $COMMAND_VERSION"
    echo "Framework: $FRAMEWORK_VERSION"
    echo "Config file: $CONFIG_FILE"
    echo "Log level: $LOG_LEVEL"
}

# Main command logic
main_command() {
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
                show_help
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Your command logic goes here
    if [ "$verbose" = true ]; then
        log info "Running $COMMAND_NAME in verbose mode"
    fi
    
    if [ "$quiet" = false ]; then
        print_info "Hello from $COMMAND_NAME!"
        print_success "Command executed successfully"
    fi
}

# Main execution
main() {
    # Show help if no arguments provided
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    COMMAND="$1"
    shift
    
    case $COMMAND in
        help|--help|-h)
            show_help
            ;;
        version)
            show_version
            ;;
        status)
            show_status
            ;;
        *)
            # Pass all arguments to main command logic
            main_command "$COMMAND" "$@"
            ;;
    esac
}

# Run main function with all arguments
main "$@" 