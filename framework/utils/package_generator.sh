#!/bin/zsh

# Package Generator Utility for lie CLI Framework

# Function to extract flags for a specific command from JSON config
extract_flags_for_command() {
    local config_file="$1"
    local command_name="$2"
    
    # Use awk to parse JSON and extract flags for the specific command
    awk -v cmd="$command_name" '
    BEGIN { in_command = 0; in_flags = 0; found_cmd = 0 }
    /"name": "'"$command_name"'"/ { in_command = 1; found_cmd = 1 }
    in_command && /"flags": \[/ { in_flags = 1 }
    in_command && in_flags && /"name": "/ {
        gsub(/.*"name": "([^"]*)".*/, "\\1")
        flag_name = $0
        getline
        if ($0 ~ /"shorthand": "/) {
            gsub(/.*"shorthand": "([^"]*)".*/, "\\1")
            shorthand = $0
        } else {
            shorthand = ""
        }
        getline
        if ($0 ~ /"description": "/) {
            gsub(/.*"description": "([^"]*)".*/, "\\1")
            description = $0
        } else {
            description = ""
        }
        print flag_name ":" shorthand ":" description
    }
    in_command && in_flags && /^\s*\]/ { in_flags = 0 }
    in_command && /^\s*}/ { in_command = 0 }
    ' "$config_file"
}

package_from_config() {
    local module_name="$1"
    if [ -z "$module_name" ]; then
        echo -e "${RED}Error: Please specify a module name${NC}"
        echo "Usage: lie package <module-name>"
        exit 1
    fi
    
    local config_file="${module_name}.json"
    if [ ! -f "$config_file" ]; then
        echo -e "${RED}Error: Config file '$config_file' not found${NC}"
        echo "Create it first with: lie create $module_name"
        exit 1
    fi
    
    echo -e "${BLUE}Generating CLI package from config: $config_file${NC}"
    echo ""
    
    # Parse JSON config (simple parsing)
    local module_description=$(grep '"description"' "$config_file" | sed 's/.*"description": *"\([^"]*\)".*/\1/')
    local module_alias=$(grep '"alias"' "$config_file" | sed 's/.*"alias": *"\([^"]*\)".*/\1/')
    
    local cli_dir="${module_name}_cli"
    local commands_file="$cli_dir/commands.sh"
    local cli_internal_dir="$cli_dir/.cli"
    
    # Remove existing CLI directory if it exists
    if [ -d "$cli_dir" ]; then
        rm -rf "$cli_dir"
    fi
    
    # Create CLI directory structure
    mkdir -p "$cli_internal_dir"
    
    # Generate commands.sh with basic function stubs
    cat > "$commands_file" <<EOF
#!/bin/zsh

# Commands for $module_name module
# Generated from $config_file
# Define your subcommand functions here

EOF
    
    # Extract all command names from JSON and generate function stubs with flag parsing
    awk '/"commands": \[/,/^\s*\]/' "$config_file" | grep '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/' | while read -r cmd_name; do
        # Extract flags for this command
        flags_output=$(extract_flags_for_command "$config_file" "$cmd_name")
        
        # Start the command function
        cat >> "$commands_file" <<EOF
$cmd_name() {
EOF
        # Declare flag variables
        if [ -n "$flags_output" ]; then
            echo "$flags_output" | while IFS=':' read -r flag_name shorthand description; do
                if [ -n "$flag_name" ]; then
                    var_name=$(echo "$flag_name" | tr '-' '_')
                    echo "    local $var_name=\"\"" >> "$commands_file"
                fi
            done
        fi
        cat >> "$commands_file" <<EOF
    # Parse arguments
    while [[ \$# -gt 0 ]]; do
        case \$1 in
EOF
        # Add flag parsing cases
        if [ -n "$flags_output" ]; then
            echo "$flags_output" | while IFS=':' read -r flag_name shorthand description; do
                if [ -n "$flag_name" ]; then
                    var_name=$(echo "$flag_name" | tr '-' '_')
                    if [ -n "$shorthand" ]; then
                        echo "            -$shorthand|--$flag_name)" >> "$commands_file"
                        echo "                $var_name=\"\$2\"" >> "$commands_file"
                        echo "                shift 2" >> "$commands_file"
                        echo "                ;;" >> "$commands_file"
                    else
                        echo "            --$flag_name)" >> "$commands_file"
                        echo "                $var_name=\"\$2\"" >> "$commands_file"
                        echo "                shift 2" >> "$commands_file"
                        echo "                ;;" >> "$commands_file"
                    fi
                fi
            done
        fi
        cat >> "$commands_file" <<EOF
            --help|-h)
                echo "Usage: $cmd_name [options]"
                echo ""
                echo "Options:"
EOF
        # Add help text for flags
        if [ -n "$flags_output" ]; then
            echo "$flags_output" | while IFS=':' read -r flag_name shorthand description; do
                if [ -n "$flag_name" ]; then
                    if [ -n "$shorthand" ]; then
                        echo "                -$shorthand, --$flag_name    $description" >> "$commands_file"
                    else
                        echo "                --$flag_name    $description" >> "$commands_file"
                    fi
                fi
            done
        fi
        cat >> "$commands_file" <<EOF
                --help, -h       Show this help message
                ;;
            *)
                break
                ;;
        esac
    done
    print_info "Running $cmd_name..."
    # Your $cmd_name logic here
    print_success "$cmd_name completed!"
}

EOF
    done
    
    cat >> "$commands_file" <<EOF
help() {
    print_info "Available commands:"
EOF
    
    # Add help entries for each command
    awk '/"commands": \[/,/^\s*\]/' "$config_file" | grep '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/' | while read -r cmd_name; do
        echo "    print_info \"  $cmd_name   - Run $cmd_name command\"" >> "$commands_file"
    done
    
    cat >> "$commands_file" <<EOF
    print_info "  help    - Show this help message"
}
EOF
    
    chmod +x "$commands_file"
    
    # Create the main module script
    local module_script="$cli_internal_dir/$module_name.sh"
    cat > "$module_script" <<EOF
#!/bin/zsh

# Module: $module_name
# Generated by lie CLI Framework from config

LIE_HOME="\${LIE_HOME:-\$HOME/.lie}"
source "\$LIE_HOME/utils/common.sh"

MODULE_NAME="$module_name"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="$module_description"

# Source user commands
CLI_DIR="\$(dirname "\$0")"
source "\$CLI_DIR/commands.sh"

show_help() {
    echo -e "\${BLUE}\$MODULE_NAME v\$MODULE_VERSION\${NC}"
    echo "Description: \$MODULE_DESCRIPTION"
    echo ""
    echo "Usage: \$MODULE_NAME <subcommand>"
    echo ""
    echo "Subcommands:"
EOF
    
    # Add help entries for each command
    awk '/"commands": \[/,/^\s*\]/' "$config_file" | grep '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/' | while read -r cmd_name; do
        echo "    echo \"  $cmd_name   - Run $cmd_name command\"" >> "$module_script"
    done
    
    cat >> "$module_script" <<EOF
    echo "  help    - Show this help message"
}

show_status() {
    echo -e "\${BLUE}Status for \$MODULE_NAME\${NC}"
    echo "Module: \$MODULE_NAME"
    echo "Version: \$MODULE_VERSION"
    echo "Commands file: \$CLI_DIR/commands.sh"
}

execute_subcommand() {
    local subcommand="\$1"
    shift
    
    case \$subcommand in
        help|--help|-h)
            help
            ;;
        status)
            show_status
            ;;
EOF
    
    # Add case entries for each command
    awk '/"commands": \[/,/^\s*\]/' "$config_file" | grep '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/' | while read -r cmd_name; do
        echo "        $cmd_name)" >> "$module_script"
        echo "            # Execute the function with remaining arguments" >> "$module_script"
        echo "            \"\$subcommand\" \"\$@\"" >> "$module_script"
        echo "            ;;" >> "$module_script"
    done
    
    cat >> "$module_script" <<EOF
        *)
            echo -e "\${RED}Error: Unknown subcommand '\$subcommand'\${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
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
    
    # Create install script
    local install_script="$cli_dir/install.sh"
    cat > "$install_script" <<EOF
#!/bin/zsh

# Install script for $module_name CLI
LIE_HOME="\${LIE_HOME:-\$HOME/.lie}"
MODULES_DIR="\$LIE_HOME/modules"
BIN_DIR="\$HOME/.local/bin"

echo "Installing $module_name CLI..."

# Create module directory
mkdir -p "\$MODULES_DIR/$module_name"

# Copy module script and commands
cp ".cli/$module_name.sh" "\$MODULES_DIR/$module_name/"
cp "commands.sh" "\$MODULES_DIR/$module_name/"

EOF
    
    # Add alias creation if specified
    if [ -n "$module_alias" ]; then
        cat >> "$install_script" <<EOF
# Create alias if specified
if [ -n "$module_alias" ]; then
    mkdir -p "\$BIN_DIR"
    cat > "\$BIN_DIR/$module_alias" <<'ALIAS_EOF'
#!/bin/zsh
"\$HOME/.lie/modules/$module_name/$module_name.sh" "\$@"
ALIAS_EOF
    chmod +x "\$BIN_DIR/$module_alias"
    echo "Created alias: $module_alias"
fi

EOF
    fi
    
    cat >> "$install_script" <<EOF
echo "✅ $module_name CLI installed successfully!"
if [ -n "$module_alias" ]; then
    echo "Run '$module_alias help' to see available commands"
else
    echo "Run 'lie $module_name help' to see available commands"
fi
EOF
    
    chmod +x "$install_script"
    
    echo -e "${GREEN}✅ Generated CLI package: $cli_dir${NC}"
    echo ""
    echo -e "${BLUE}Structure created:${NC}"
    echo "  $cli_dir/"
    echo "  ├── commands.sh     (edit this to add your logic)"
    echo "  ├── install.sh      (run this to install)"
    echo "  └── .cli/           (framework files - don't touch)"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Edit $cli_dir/commands.sh to add your subcommand logic"
    echo "  2. Run ./$cli_dir/install.sh to install the module"
    if [ -n "$module_alias" ]; then
        echo "  3. Test with: $module_alias help"
    else
        echo "  3. Test with: lie $module_name help"
    fi
} 