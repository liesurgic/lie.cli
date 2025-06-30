#!/bin/zsh

# Module Lister Utility for lie CLI Framework

list_modules() {
    echo -e "${BLUE}Installed Modules:${NC}"
    echo ""
    
    if [ ! -d "$MODULES_DIR" ] || [ -z "$(ls -A "$MODULES_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}No modules installed yet.${NC}"
        echo "Use 'lie create <module>' to create your first module."
        return
    fi
    
    for module in "$MODULES_DIR"/*; do
        if [ -d "$module" ]; then
            module_name=$(basename "$module")
            echo -e "  ${GREEN}$module_name${NC}"
            
            # List subcommands
            local subcommands_dir="$module/subcommands"
            if [ -d "$subcommands_dir" ]; then
                for subcmd in "$subcommands_dir"/*.sh; do
                    if [ -f "$subcmd" ]; then
                        subcmd_name=$(basename "$subcmd" .sh)
                        echo -e "    - $subcmd_name"
                    fi
                done
            fi
        fi
    done
} 