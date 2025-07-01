#!/bin/zsh

# Module Creator Utility for lie CLI Framework

# Create a new module
create_module() {
    local module_name="$1"
    if [ -z "$module_name" ]; then
        echo -e "${RED}Error: Please specify a module name${NC}"
        echo "Usage: lie create <module-name>"
        exit 1
    fi
    
    local module_dir="$MODULES_DIR/$module_name"
    if [ -d "$module_dir" ]; then
        echo -e "${RED}Error: Module '$module_name' already exists${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Creating module: $module_name${NC}"
    echo ""
    
    local description=""
    echo -e "${YELLOW}→ Module description (what does this module do?):${NC}"
    read -r description
    
    mkdir -p "$module_dir/subcommands"
    
    local module_script="$module_dir/$module_name.sh"
    cat > "$module_script" <<EOF
#!/bin/zsh

# Module: $module_name
LIE_HOME="\${LIE_HOME:-\$HOME/.lie}"
source "\$LIE_HOME/utils/common.sh"

MODULE_NAME="$module_name"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="$description"

# Get list of available subcommands
get_subcommands() {
    local subcommands_dir="\$LIE_HOME/modules/\$MODULE_NAME/subcommands"
    local subcommands=()
    
    if [ -d "\$subcommands_dir" ]; then
        for subcmd in "\$subcommands_dir"/*.sh; do
            if [ -f "\$subcmd" ]; then
                subcmd_name=\$(basename "\$subcmd" .sh)
                subcommands+=("\$subcmd_name")
            fi
        done
    fi
    
    # Add built-in subcommands
    subcommands+=("help" "status")
    echo "\${subcommands[@]}"
}

show_help() {
    echo -e "\${BLUE}\$MODULE_NAME v\$MODULE_VERSION\${NC}"
    echo "Description: \$MODULE_DESCRIPTION"
    echo ""
    echo "Usage: lie \$MODULE_NAME <subcommand>"
    echo ""
    echo "Subcommands:"
    
    # Show built-in subcommands
    echo "  help     Show this help message"
    echo "  status   Show status information"
    
    # Show custom subcommands
    local subcommands_dir="\$LIE_HOME/modules/\$MODULE_NAME/subcommands"
    if [ -d "\$subcommands_dir" ]; then
        for subcmd in "\$subcommands_dir"/*.sh; do
            if [ -f "\$subcmd" ]; then
                subcmd_name=\$(basename "\$subcmd" .sh)
                echo "  \$subcmd_name"
            fi
        done
    fi
}

show_status() {
    echo -e "\${BLUE}Status for \$MODULE_NAME\${NC}"
    echo "Module: \$MODULE_NAME"
    echo "Version: \$MODULE_VERSION"
    echo ""
    echo "Available subcommands:"
    
    # Show built-in subcommands
    echo "  - help"
    echo "  - status"
    
    # Show custom subcommands
    local subcommands_dir="\$LIE_HOME/modules/\$MODULE_NAME/subcommands"
    if [ -d "\$subcommands_dir" ]; then
        for subcmd in "\$subcommands_dir"/*.sh; do
            if [ -f "\$subcmd" ]; then
                subcmd_name=\$(basename "\$subcmd" .sh)
                echo "  - \$subcmd_name"
            fi
        done
    fi
}

execute_subcommand() {
    local subcommand="\$1"
    shift
    
    local subcommand_script="\$LIE_HOME/modules/\$MODULE_NAME/subcommands/\$subcommand.sh"
    if [ -f "\$subcommand_script" ]; then
        exec "\$subcommand_script" "\$@"
    else
        case \$subcommand in
            help|--help|-h)
                show_help
                ;;
            status)
                show_status
                ;;
            *)
                echo -e "\${RED}Error: Unknown subcommand '\$subcommand'\${NC}"
                echo ""
                show_help
                exit 1
                ;;
        esac
    fi
}

main() {
    if [ \$# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    execute_subcommand "\$@"
}

main "\$@"
EOF
    
    chmod +x "$module_script"
    
    echo -e "${GREEN}✅ Created module: $module_name${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Add subcommands with: lie add-command $module_name"
    echo "  2. Test with: lie $module_name help"
} 