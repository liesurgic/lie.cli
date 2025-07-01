#!/bin/zsh

# Install script for test-flags CLI
LIE_HOME="${LIE_HOME:-$HOME/.lie}"
MODULES_DIR="$LIE_HOME/modules"
BIN_DIR="$HOME/.local/bin"

echo "Installing test-flags CLI..."

# Create module directory
mkdir -p "$MODULES_DIR/test-flags"

# Copy module script and commands
cp ".cli/test-flags.sh" "$MODULES_DIR/test-flags/"
cp "commands.sh" "$MODULES_DIR/test-flags/"

# Create alias if specified
if [ -n "testflags" ]; then
    mkdir -p "$BIN_DIR"
    cat > "$BIN_DIR/testflags" <<'ALIAS_EOF'
#!/bin/zsh
"$HOME/.lie/modules/test-flags/test-flags.sh" "$@"
ALIAS_EOF
    chmod +x "$BIN_DIR/testflags"
    echo "Created alias: testflags"
fi

echo "✅ test-flags CLI installed successfully!"
if [ -n "testflags" ]; then
    echo "Run 'testflags help' to see available commands"
else
    echo "Run 'lie test-flags help' to see available commands"
fi
