#!/bin/zsh

# Module: hello_example
# Generated by lie CLI Framework from config

LIE_HOME="${LIE_HOME:-$HOME/.lie}"
source "$LIE_HOME/utils/common.sh"

MODULE_NAME="hello_example"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Example hello command
Starts the hello_example
Force start even if already running
Stops the hello_example
Shows the status of hello_example"

# Source user commands
CLI_DIR="$(dirname "$0")"
source "$CLI_DIR/commands.sh"

show_help() {
    echo -e "${BLUE}$MODULE_NAME v$MODULE_VERSION${NC}"
    echo "Description: $MODULE_DESCRIPTION"
    echo ""
    echo "Usage: $MODULE_NAME <subcommand>"
    echo ""
    echo "Subcommands:"
    echo "  start   - Run start command"
    echo "  force   - Run force command"
    echo "  stop   - Run stop command"
    echo "  status   - Run status command"
    echo "  help    - Show this help message"
}

show_status() {
    echo -e "${BLUE}Status for $MODULE_NAME${NC}"
    echo "Module: $MODULE_NAME"
    echo "Version: $MODULE_VERSION"
    echo "Commands file: $CLI_DIR/commands.sh"
}

execute_subcommand() {
    local subcommand="$1"
    shift
    
    case $subcommand in
        help|--help|-h)
            help
            ;;
        status)
            show_status
            ;;
        start)
            # Execute the function with remaining arguments
            "$subcommand" "$@"
            ;;
        force)
            # Execute the function with remaining arguments
            "$subcommand" "$@"
            ;;
        stop)
            # Execute the function with remaining arguments
            "$subcommand" "$@"
            ;;
        status)
            # Execute the function with remaining arguments
            "$subcommand" "$@"
            ;;
        *)
            echo -e "${RED}Error: Unknown subcommand '$subcommand'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    execute_subcommand "$@"
}

main "$@"
