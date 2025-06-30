#!/bin/zsh

# Subcommand Creator Utility for lie CLI Framework

add_subcommand() {
    local module_name="$1"
    if [ -z "$module_name" ]; then
        echo -e "${RED}Error: Please specify a module name${NC}"
        echo "Usage: lie add-command <module-name>"
        exit 1
    fi
    
    local module_dir="$MODULES_DIR/$module_name"
    if [ ! -d "$module_dir" ]; then
        echo -e "${RED}Error: Module '$module_name' not found${NC}"
        echo "Create it first with: lie create $module_name"
        exit 1
    fi
    
    echo -e "${BLUE}Adding subcommand to module: $module_name${NC}"
    echo ""
    
    local subcommand_name=""
    local description=""
    
    echo -e "${YELLOW}→ Command name:${NC}"
    read -r subcommand_name
    
    if [ -z "$subcommand_name" ]; then
        echo -e "${RED}Error: Subcommand name cannot be empty${NC}"
        exit 1
    fi
    
    local subcommand_script="$module_dir/subcommands/$subcommand_name.sh"
    if [ -f "$subcommand_script" ]; then
        echo -e "${RED}Error: Subcommand '$subcommand_name' already exists in module '$module_name'${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}→ Command description (what does this command do?):${NC}"
    read -r description
    
    cat > "$subcommand_script" <<EOF
#!/bin/zsh

# Subcommand: $subcommand_name
# Module: $module_name

LIE_HOME="\${LIE_HOME:-\$HOME/.lie}"
source "\$LIE_HOME/utils/common.sh"

SUBCOMMAND_NAME="$subcommand_name"
SUBCOMMAND_DESCRIPTION="$description"
SUBCOMMAND_VERSION="1.0.0"

show_subcommand_help() {
    echo -e "\${BLUE}\$SUBCOMMAND_NAME v\$SUBCOMMAND_VERSION\${NC}"
    echo "Description: \$SUBCOMMAND_DESCRIPTION"
    echo ""
    echo "Usage: lie $module_name \$SUBCOMMAND_NAME [options]"
    echo ""
    echo "Options:"
    echo "  --help, -h       Show this help message"
}

main_subcommand() {
    while [[ \$# -gt 0 ]]; do
        case \$1 in
            --help|-h)
                show_subcommand_help
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Your subcommand logic goes here
    print_info "Hello from \$SUBCOMMAND_NAME!"
    print_success "Subcommand executed successfully"
}

main_subcommand "\$@"
EOF
    
    chmod +x "$subcommand_script"
    
    echo -e "${GREEN}✅ Added subcommand '$subcommand_name' to module '$module_name'${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Edit the subcommand: $subcommand_script"
    echo "  2. Test with: lie $module_name $subcommand_name"
} 