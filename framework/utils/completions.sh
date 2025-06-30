#!/bin/zsh

# lie completions setup script (zsh only)

ZSHRC="$HOME/.zshrc"
BLOCK_START="# >>> liecli completion setup >>>"
BLOCK_END="# <<< liecli completion setup <<<"
COMPLETION_BLOCK="$BLOCK_START\nfpath=(\$HOME/.lie/completions \$fpath)\nautoload -U compinit && compinit\n$BLOCK_END"

# Check if block already exists
if grep -q "$BLOCK_START" "$ZSHRC"; then
    echo "[lie] Completions block already present in $ZSHRC."
else
    echo "[lie] Adding completions block to $ZSHRC..."
    echo -e "\n$COMPLETION_BLOCK\n" >> "$ZSHRC"
    echo "[lie] Completions enabled! Please restart your shell or run: source $ZSHRC"
fi 