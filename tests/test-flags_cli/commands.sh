#!/bin/zsh

# Commands for test-flags module
# Generated from test-flags.json
# Define your subcommand functions here

deploy() {
    print_info "Running deploy..."
    # Your deploy logic here
    print_success "deploy completed!"
}

environment() {
    print_info "Running environment..."
    # Your environment logic here
    print_success "environment completed!"
}

force() {
    print_info "Running force..."
    # Your force logic here
    print_success "force completed!"
}

build() {
    print_info "Running build..."
    # Your build logic here
    print_success "build completed!"
}

production() {
    print_info "Running production..."
    # Your production logic here
    print_success "production completed!"
}

test() {
    print_info "Running test..."
    # Your test logic here
    print_success "test completed!"
}

help() {
    print_info "Available commands:"
    print_info "  deploy   - Run deploy command"
    print_info "  environment   - Run environment command"
    print_info "  force   - Run force command"
    print_info "  build   - Run build command"
    print_info "  production   - Run production command"
    print_info "  test   - Run test command"
    print_info "  help    - Show this help message"
}
