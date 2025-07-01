#!/bin/zsh

# Config Creator Utility for lie CLI Framework

create_config() {
    local module_name=""
    local skip_prompts=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--yes)
                skip_prompts=true
                shift
                ;;
            *)
                if [ -z "$module_name" ]; then
                    module_name="$1"
                fi
                shift
                ;;
        esac
    done
    
    if [ -z "$module_name" ]; then
        echo -e "${RED}Error: Please specify a module name${NC}"
        echo "Usage: lie create <module-name>"
        echo "       lie create -y <module-name>  # Skip prompts (for testing)"
        exit 1
    fi
    
    local config_file="${module_name}.json"
    if [ -f "$config_file" ]; then
        echo -e "${RED}Error: Config file '$config_file' already exists${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Creating config for module: $module_name${NC}"
    echo ""
    
    # Interactive prompts or default values
    local description=""
    local alias=""
    
    if [ "$skip_prompts" = true ]; then
        # Use default values for automated testing
        description="Test module for $module_name"
        alias="${module_name}_alias"
        echo -e "${YELLOW}Using default values (non-interactive mode)${NC}"
    else
        echo -e "${YELLOW}→ Module description (what does this module do?):${NC}"
        read -r description
        
        echo -e "${YELLOW}→ Alias (optional, for direct command access like 'hive start'):${NC}"
        read -r alias
    fi
    
    # Create initial config
    cat > "$config_file" <<EOF
{
    "name": "$module_name",
    "description": "$description",
    "alias": "$alias",
    "commands": [
        {
            "name": "start",
            "description": "Starts the $module_name",
            "flags": [
                {
                    "name": "force",
                    "shorthand": "f",
                    "description": "Force start even if already running"
                }
            ]
        },
        {
            "name": "stop",
            "description": "Stops the $module_name",
            "flags": []
        },
        {
            "name": "status",
            "description": "Shows the status of $module_name",
            "flags": []
        }
    ]
}
EOF
    
    echo -e "${GREEN}✅ Created config: $config_file${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Edit $config_file to customize commands and flags"
    echo "  2. Run 'lie package $module_name' to generate the CLI package"
    echo "  3. Edit the generated commands.sh to add your logic"
    echo "  4. Run 'lie install $module_name' to install"
    echo ""
    echo -e "${YELLOW}Example config structure:${NC}"
    echo "  - Add/remove commands"
    echo "  - Modify descriptions"
    echo "  - Add flags with shorthand options"
    echo "  - Set the alias for direct command access"
} 