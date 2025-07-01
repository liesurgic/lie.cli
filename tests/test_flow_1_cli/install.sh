#!/bin/zsh

# Install script for test_flow_1 CLI
LIE_HOME="${LIE_HOME:-$HOME/.lie}"
MODULES_DIR="$LIE_HOME/modules"
BIN_DIR="$HOME/.local/bin"

echo "Installing test_flow_1 CLI..."

# Create module directory
mkdir -p "$MODULES_DIR/test_flow_1"

# Copy module script and commands
cp ".cli/test_flow_1.sh" "$MODULES_DIR/test_flow_1/"
cp "commands.sh" "$MODULES_DIR/test_flow_1/"

echo "✅ test_flow_1 CLI installed successfully!"
if [ -n "" ]; then
    echo "Run ' help' to see available commands"
else
    echo "Run 'lie test_flow_1 help' to see available commands"
fi
