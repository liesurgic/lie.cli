#!/bin/zsh

# Common utility functions for lie CLI commands
# Source this file in your commands: source "$LIE_HOME/utils/common.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Framework paths (will be set by the main lie script)
LIE_HOME="${LIE_HOME:-$HOME/.lie}"
CONFIG_FILE="$LIE_HOME/config/config.json"

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # Simple JSON parsing for basic config
        FRAMEWORK_VERSION=$(grep '"version"' "$CONFIG_FILE" | sed 's/.*"version": *"\([^"]*\)".*/\1/')
        LOG_LEVEL=$(grep '"log_level"' "$CONFIG_FILE" | sed 's/.*"log_level": *"\([^"]*\)".*/\1/')
        TIMEOUT=$(grep '"timeout"' "$CONFIG_FILE" | sed 's/.*"timeout": *\([0-9]*\).*/\1/')
    else
        FRAMEWORK_VERSION="1.0.0"
        LOG_LEVEL="info"
        TIMEOUT=30
    fi
}

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    
    case $level in
        debug)
            if [ "$LOG_LEVEL" = "debug" ]; then
                echo -e "${BLUE}[DEBUG]${NC} $message"
            fi
            ;;
        info)
            if [ "$LOG_LEVEL" = "debug" ] || [ "$LOG_LEVEL" = "info" ]; then
                echo -e "${GREEN}[INFO]${NC} $message"
            fi
            ;;
        warn)
            if [ "$LOG_LEVEL" != "error" ]; then
                echo -e "${YELLOW}[WARN]${NC} $message"
            fi
            ;;
        error)
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
    esac
}

# Print colored output
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

# Create directory if it doesn't exist
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log debug "Created directory: $1"
    fi
}

# Get user input with prompt
get_input() {
    local prompt="$1"
    local default="$2"
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        echo "${input:-$default}"
    else
        read -p "$prompt: " input
        echo "$input"
    fi
}

# Get user confirmation
confirm() {
    local prompt="$1"
    local default="${2:-y}"
    
    if [ "$default" = "y" ]; then
        read -p "$prompt [Y/n]: " response
        case $response in
            [nN]|[nN][oO]) return 1 ;;
            *) return 0 ;;
        esac
    else
        read -p "$prompt [y/N]: " response
        case $response in
            [yY]|[yY][eE][sS]) return 0 ;;
            *) return 1 ;;
        esac
    fi
}

# Execute command with timeout
execute_with_timeout() {
    local timeout="$1"
    shift
    local cmd="$*"
    
    timeout "$timeout" $cmd
    return $?
}

# Parse JSON (simple implementation)
parse_json() {
    local json_file="$1"
    local key="$2"
    
    if [ -f "$json_file" ]; then
        grep "\"$key\"" "$json_file" | sed 's/.*"'$key'": *"\([^"]*\)".*/\1/'
    fi
}

# Save to JSON (simple implementation)
save_json() {
    local json_file="$1"
    local key="$2"
    local value="$3"
    
    if [ ! -f "$json_file" ]; then
        echo "{}" > "$json_file"
    fi
    
    # Simple replacement - this is basic and may not work for complex JSON
    if grep -q "\"$key\"" "$json_file"; then
        sed -i.bak "s/\"$key\": *\"[^\"]*\"/\"$key\": \"$value\"/" "$json_file"
    else
        # Add new key-value pair
        sed -i.bak 's/}$/  "'$key'": "'$value'"\n}/' "$json_file"
    fi
}

# Show progress bar
show_progress() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '#'
    printf "%${empty}s" | tr ' ' '-'
    printf "] %d%%" $percentage
    
    if [ "$current" -eq "$total" ]; then
        echo
    fi
}

# Load configuration when this file is sourced
load_config 