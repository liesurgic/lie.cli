#!/bin/zsh

# Example command for lie CLI Framework
# Demonstrates basic command structure and utilities

# Set LIE_HOME if not already set
LIE_HOME="${LIE_HOME:-$HOME/.lie}"

# Source common utilities
source "$LIE_HOME/utils/common.sh"

# Command metadata
COMMAND_NAME="hello"
COMMAND_VERSION="1.0.0"
COMMAND_DESCRIPTION="A simple hello command to demonstrate the framework"

# Show command help
show_help() {
    echo -e "${BLUE}$COMMAND_NAME v$COMMAND_VERSION${NC}"
    echo ""
    echo "Description: $COMMAND_DESCRIPTION"
    echo ""
    echo "Usage: lie $COMMAND_NAME [name] [options]"
    echo ""
    echo "Arguments:"
    echo "  name              Name to greet (default: World)"
    echo ""
    echo "Options:"
    echo "  --formal, -f      Use formal greeting"
    echo "  --loud, -l        Use exclamation marks"
    echo "  --help, -h        Show this help message"
    echo ""
    echo "Examples:"
    echo "  lie $COMMAND_NAME"
    echo "  lie $COMMAND_NAME Alice"
    echo "  lie $COMMAND_NAME Bob --formal"
    echo "  lie $COMMAND_NAME Charlie --loud"
}

# Main command logic
main_command() {
    local name="${1:-World}"
    local formal=false
    local loud=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --formal|-f)
                formal=true
                shift
                ;;
            --loud|-l)
                loud=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                exit 1
                ;;
            *)
                name="$1"
                shift
                ;;
        esac
    done
    
    # Build greeting
    local greeting=""
    if [ "$formal" = true ]; then
        greeting="Good day, $name"
    else
        greeting="Hello, $name"
    fi
    
    if [ "$loud" = true ]; then
        greeting="$greeting!!!"
    else
        greeting="$greeting!"
    fi
    
    # Output greeting
    print_success "$greeting"
    
    # Show some framework info in debug mode
    if [ "$LOG_LEVEL" = "debug" ]; then
        log debug "Command executed with name: $name"
        log debug "Formal mode: $formal"
        log debug "Loud mode: $loud"
    fi
}

# Main execution
main() {
    # Show help if no arguments provided
    if [ $# -eq 0 ]; then
        main_command
        exit 0
    fi
    
    # Check for help flag
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi
    
    # Pass all arguments to main command logic
    main_command "$@"
}

# Run main function with all arguments
main "$@" 