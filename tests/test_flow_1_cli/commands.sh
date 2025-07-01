#!/bin/zsh

# Commands for test_flow_1 module
# Generated from test_flow_1.json
# Define your subcommand functions here

start() {
    local \1=""
    local \1=""
    local \1=""
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -\1|--\1)
                \1="$2"
                shift 2
                ;;
            --\1)
                \1="$2"
                shift 2
                ;;
            --\1)
                \1="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: start [options]"
                echo ""
                echo "Options:"
                -\1, --\1    \1
                --\1    
                --\1    
                --help, -h       Show this help message
                ;;
            *)
                break
                ;;
        esac
    done
    print_info "Running start..."
    # Your start logic here
    print_success "start completed!"
}

force() {
    local \1=""
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --\1)
                \1="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: force [options]"
                echo ""
                echo "Options:"
                --\1    
                --help, -h       Show this help message
                ;;
            *)
                break
                ;;
        esac
    done
    print_info "Running force..."
    # Your force logic here
    print_success "force completed!"
}

stop() {
    local \1=""
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --\1)
                \1="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: stop [options]"
                echo ""
                echo "Options:"
                --\1    
                --help, -h       Show this help message
                ;;
            *)
                break
                ;;
        esac
    done
    print_info "Running stop..."
    # Your stop logic here
    print_success "stop completed!"
}

status() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                echo "Usage: status [options]"
                echo ""
                echo "Options:"
                --help, -h       Show this help message
                ;;
            *)
                break
                ;;
        esac
    done
    print_info "Running status..."
    # Your status logic here
    print_success "status completed!"
}

help() {
    print_info "Available commands:"
    print_info "  start   - Run start command"
    print_info "  force   - Run force command"
    print_info "  stop   - Run stop command"
    print_info "  status   - Run status command"
    print_info "  help    - Show this help message"
}
