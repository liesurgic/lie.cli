#!/bin/zsh

# Module Template for lie CLI Framework
# This template creates a module with multiple subcommands

# Source common utilities
source "$LIE_HOME/utils/common.sh"

# Module metadata
MODULE_NAME="$(basename "$0" .sh)"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="A template module for the lie CLI framework"

# Subcommands configuration
declare -A SUBCOMMANDS
SUBCOMMANDS=(
    ["help"]="Show this help message"
    ["version"]="Show version information"
    ["status"]="Show status information"
)

# Show module help
show_help() {
    echo -e "${BLUE}$MODULE_NAME v$MODULE_VERSION${NC}"
    echo ""
    echo "Description: $MODULE_DESCRIPTION"
    echo ""
    echo "Usage: lie $MODULE_NAME <subcommand> [options]"
    echo ""
    echo "Subcommands:"
    for cmd in "${!SUBCOMMANDS[@]}"; do
        echo "  $cmd    ${SUBCOMMANDS[$cmd]}"
    done
    echo ""
    echo "Options:"
    echo "  --verbose, -v    Enable verbose output"
    echo "  --quiet, -q      Suppress output"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  lie $MODULE_NAME status"
    echo "  lie $MODULE_NAME --verbose"
}

# Show version information
show_version() {
    echo -e "${BLUE}$MODULE_NAME v$MODULE_VERSION${NC}"
    echo "Framework version: $FRAMEWORK_VERSION"
}

# Show status information
show_status() {
    echo -e "${BLUE}Status for $MODULE_NAME${NC}"
    echo "Module: $MODULE_NAME"
    echo "Version: $MODULE_VERSION"
    echo "Framework: $FRAMEWORK_VERSION"
    echo "Config file: $CONFIG_FILE"
    echo "Log level: $LOG_LEVEL"
    echo ""
    echo "Available subcommands:"
    for cmd in "${!SUBCOMMANDS[@]}"; do
        echo "  - $cmd"
    done
}

# Default subcommand handler
default_subcommand() {
    local subcommand="$1"
    shift
    
    case $subcommand in
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
            echo -e "${RED}Error: Unknown subcommand '$subcommand'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Main execution
main() {
    # Show help if no arguments provided
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Parse global options
    local verbose=false
    local quiet=false
    
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
    
    # Handle subcommand
    if [ $# -gt 0 ]; then
        default_subcommand "$@"
    else
        show_help
        exit 0
    fi
}

# Run main function with all arguments
main "$@" 