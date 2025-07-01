#!/bin/zsh

# Completion generator for lie CLI framework
# Generates zsh completion functions for installed modules

LIE_HOME="${LIE_HOME:-$HOME/.lie}"
COMPLETIONS_DIR="$LIE_HOME/completions"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Extract commands from JSON config
extract_commands_from_config() {
    local config_file="$1"
    if [ ! -f "$config_file" ]; then
        return 1
    fi
    
    # Extract command names from JSON and return as space-separated string
    awk '/"commands": \[/,/^\s*\]/' "$config_file" | grep '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/' | tr '\n' ' '
}

# Extract flags from JSON config for a specific command
extract_flags_from_config() {
    local config_file="$1"
    local command_name="$2"
    
    if [ ! -f "$config_file" ]; then
        return 1
    fi
    
    # Find the command and extract its flags
    awk -v cmd="$command_name" '
    /"name": "'"$command_name"'"/ {
        in_command = 1
        next
    }
    in_command && /"flags": \[/ {
        in_flags = 1
        next
    }
    in_command && in_flags && /"name": "/ {
        gsub(/.*"name": *"([^"]*)".*/, "\\1")
        print
    }
    in_command && in_flags && /^\s*\]/ {
        in_flags = 0
        in_command = 0
    }
    in_command && /^\s*}/ {
        in_command = 0
    }
    ' "$config_file"
}

# Generate completion function for a module
generate_module_completion() {
    local module_name="$1"
    local config_file="$2"
    local completion_file="$COMPLETIONS_DIR/_lie-$module_name"
    
    # Extract commands from config
    local commands_str=$(extract_commands_from_config "$config_file")
    local commands=($=commands_str)
    
    if [ ${#commands[@]} -eq 0 ]; then
        print_warn "No commands found in config for $module_name"
        return 1
    fi
    
    # Create completion file
    cat > "$completion_file" <<EOF
#compdef lie-$module_name

# Completion function for lie $module_name module
_lie_${module_name}_commands() {
    local commands=(
EOF
    
    # Add commands
    for cmd in "${commands[@]}"; do
        echo "        '$cmd:Run $cmd command'" >> "$completion_file"
    done
    
    cat >> "$completion_file" <<EOF
    )
    _describe 'commands' commands
}

# Main completion function
_lie_${module_name}() {
    local line state
    _arguments -C \\
        '1: :->cmds' \\
        '*:: :->args'
    
    case "\$state" in
        cmds)
            _lie_${module_name}_commands
            ;;
        args)
            case "\$line[1]" in
EOF
    
    # Add command-specific completions
    for cmd in "${commands[@]}"; do
        local flags=($(extract_flags_from_config "$config_file" "$cmd"))
        if [ ${#flags[@]} -gt 0 ]; then
            echo "                $cmd)" >> "$completion_file"
            echo "                    _arguments \\" >> "$completion_file"
            for flag in "${flags[@]}"; do
                echo "                        '--$flag[Flag description]' \\" >> "$completion_file"
            done
            echo "                    ;;" >> "$completion_file"
        fi
    done
    
    cat >> "$completion_file" <<EOF
            esac
            ;;
    esac
}

# Register the completion
compdef _lie_${module_name} lie-$module_name
EOF
    
    print_success "Generated completion for module: $module_name"
}

# Generate completion for alias commands
generate_alias_completion() {
    local alias_name="$1"
    local module_name="$2"
    local config_file="$3"
    local completion_file="$COMPLETIONS_DIR/_$alias_name"
    
    # Extract commands from config
    local commands_str=$(extract_commands_from_config "$config_file")
    local commands=($=commands_str)
    
    if [ ${#commands[@]} -eq 0 ]; then
        print_warn "No commands found in config for alias $alias_name"
        return 1
    fi
    
    # Create completion file
    cat > "$completion_file" <<EOF
#compdef $alias_name

# Completion function for $alias_name alias
_${alias_name}_commands() {
    local commands=(
EOF
    
    # Add commands
    for cmd in "${commands[@]}"; do
        echo "        '$cmd:Run $cmd command'" >> "$completion_file"
    done
    
    cat >> "$completion_file" <<EOF
    )
    _describe 'commands' commands
}

# Main completion function
_${alias_name}() {
    local line state
    _arguments -C \\
        '1: :->cmds' \\
        '*:: :->args'
    
    case "\$state" in
        cmds)
            _${alias_name}_commands
            ;;
        args)
            case "\$line[1]" in
EOF
    
    # Add command-specific completions
    for cmd in "${commands[@]}"; do
        local flags=($(extract_flags_from_config "$config_file" "$cmd"))
        if [ ${#flags[@]} -gt 0 ]; then
            echo "                $cmd)" >> "$completion_file"
            echo "                    _arguments \\" >> "$completion_file"
            for flag in "${flags[@]}"; do
                echo "                        '--$flag[Flag description]' \\" >> "$completion_file"
            done
            echo "                    ;;" >> "$completion_file"
        fi
    done
    
    cat >> "$completion_file" <<EOF
            esac
            ;;
    esac
}

# Register the completion
compdef _${alias_name} $alias_name
EOF
    
    print_success "Generated completion for alias: $alias_name"
}

# Generate completions for all installed modules
generate_all_completions() {
    print_info "Generating completions for all modules..."
    
    # Create completions directory
    mkdir -p "$COMPLETIONS_DIR"
    
    # Find all JSON configs in the current directory
    local configs=($(find . -maxdepth 1 -name "*.json" -type f))
    
    if [ ${#configs[@]} -eq 0 ]; then
        print_warn "No JSON config files found in current directory"
        return 1
    fi
    
    local generated=0
    
    for config_file in "${configs[@]}"; do
        local module_name=$(basename "$config_file" .json)
        
        # Extract alias from config
        local alias_name=$(grep '"alias"' "$config_file" | sed 's/.*"alias": *"\([^"]*\)".*/\1/')
        
        # Generate module completion
        if generate_module_completion "$module_name" "$config_file"; then
            generated=$((generated + 1))
        fi
        
        # Generate alias completion if alias exists
        if [ -n "$alias_name" ] && [ "$alias_name" != "null" ]; then
            if generate_alias_completion "$alias_name" "$module_name" "$config_file"; then
                generated=$((generated + 1))
            fi
        fi
    done
    
    if [ $generated -gt 0 ]; then
        print_success "Generated $generated completion files"
        print_info "To enable completions, add to your ~/.zshrc:"
        echo "  fpath=(\$HOME/.lie/completions \$fpath)"
        echo "  autoload -U compinit && compinit"
    else
        print_warn "No completions were generated"
    fi
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        generate_all_completions
    else
        case "$1" in
            --help|-h)
                echo "Usage: lie auto [options]"
                echo ""
                echo "Generate zsh completions for lie modules"
                echo ""
                echo "Options:"
                echo "  --help, -h    Show this help message"
                echo ""
                echo "This command generates completion functions for all JSON config files"
                echo "in the current directory and their associated aliases."
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    fi
}

main "$@" 