#!/bin/zsh

# Install script for test-auto CLI
LIE_HOME="${LIE_HOME:-$HOME/.lie}"
MODULES_DIR="$LIE_HOME/modules"
BIN_DIR="$HOME/.local/bin"

echo "Installing test-auto CLI..."

# Create module directory
mkdir -p "$MODULES_DIR/test-auto"

# Copy module script and commands
cp ".cli/test-auto.sh" "$MODULES_DIR/test-auto/"
cp "commands.sh" "$MODULES_DIR/test-auto/"

# Create alias if specified
if [ -n "ta" ]; then
    mkdir -p "$BIN_DIR"
    cat > "$BIN_DIR/ta" <<'ALIAS_EOF'
#!/bin/zsh
"$HOME/.lie/modules/test-auto/test-auto.sh" "$@"
ALIAS_EOF
    chmod +x "$BIN_DIR/ta"
    echo "Created alias: ta"
fi

echo "✅ test-auto CLI installed successfully!"
if [ -n "ta" ]; then
    echo "Run 'ta help' to see available commands"
else
    echo "Run 'lie test-auto help' to see available commands"
fi
