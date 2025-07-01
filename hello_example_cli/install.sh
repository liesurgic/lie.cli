#!/bin/zsh

# Install script for hello_example CLI
LIE_HOME="${LIE_HOME:-$HOME/.lie}"
MODULES_DIR="$LIE_HOME/modules"
BIN_DIR="$HOME/.local/bin"

echo "Installing hello_example CLI..."

# Create module directory
mkdir -p "$MODULES_DIR/hello_example"

# Copy module script and commands
cp ".cli/hello_example.sh" "$MODULES_DIR/hello_example/"
cp "commands.sh" "$MODULES_DIR/hello_example/"

# Create alias if specified
if [ -n "hello" ]; then
    mkdir -p "$BIN_DIR"
    cat > "$BIN_DIR/hello" <<'ALIAS_EOF'
#!/bin/zsh
"$HOME/.lie/modules/hello_example/hello_example.sh" "$@"
ALIAS_EOF
    chmod +x "$BIN_DIR/hello"
    echo "Created alias: hello"
fi

echo "✅ hello_example CLI installed successfully!"
if [ -n "hello" ]; then
    echo "Run 'hello help' to see available commands"
else
    echo "Run 'lie hello_example help' to see available commands"
fi
