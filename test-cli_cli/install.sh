#!/bin/zsh

# Install script for test-cli CLI
LIE_HOME="${LIE_HOME:-$HOME/.lie}"
MODULES_DIR="$LIE_HOME/modules"

echo "Installing test-cli CLI..."

# Create module directory
mkdir -p "$MODULES_DIR/test-cli"

# Copy module script
cp ".cli/test-cli.sh" "$MODULES_DIR/test-cli/"

# Copy commands.sh file
cp "commands.sh" "$MODULES_DIR/test-cli/"

echo "✅ test-cli CLI installed successfully!"
echo "Run 'lie test-cli help' to see available commands"
