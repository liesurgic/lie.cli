# lie CLI Framework

A powerful, modular command-line interface framework that provides infrastructure for creating, installing, and managing shell script commands. Install once, extend infinitely!

## Overview

The lie CLI framework is designed to be a clean, extensible foundation for creating modular command-line tools. It installs to `$HOME/.lie` and provides:

- **Interactive Command Creation** - Create new commands with guided prompts for description and flags
- **Modular command system** - Install and manage commands independently
- **Common utilities** - Shared functions for consistent command behavior
- **Configuration management** - JSON-based configuration system
- **Logging system** - Built-in logging with configurable levels
- **Template system** - Templates for creating new commands
- **Full test coverage** - Comprehensive testing for reliability

## 🛸 Features

- **Interactive Command Creation** - Create new commands with guided prompts
- **Modular Command System** - Install and manage commands independently
- **Rich Utility Library** - Comprehensive set of shared functions
- **Smart Configuration** - JSON-based configuration with automatic management
- **Built-in Logging** - Configurable logging with multiple levels
- **Template System** - Pre-built templates for rapid development
- **Full Test Suite** - Comprehensive testing for reliability
- **Clean Installation** - One-command install/uninstall with PATH management

## 📦 Installation

```bash
# Clone the repository
git clone <repository-url>
cd liecli

# Install the framework
./install.sh
```

The installer automatically:
- Creates `$HOME/.lie` directory structure
- Installs framework files and utilities
- Creates a wrapper script in `$HOME/.local/bin`
- Adds the bin directory to your PATH using safe block markers
- Sets up initial configuration

## 🏁 Quick Start

```bash
# Show framework help
lie --help

# Create your first command interactively
lie create my-awesome-command

# Install and test it
lie install ./my-awesome-command.sh
lie my-awesome-command

# List all installed commands
lie list
```

## 🛠️ Core Commands

### Framework Management
```bash
lie --help              # Show framework help
lie list                # List installed commands
lie info <command>      # Show command information
```

### Command Lifecycle
```bash
lie create <name>       # Interactive command creation
lie install <script>    # Install a command script
lie uninstall <name>    # Remove a command
```

### Command Execution
```bash
lie <command-name>      # Execute an installed command
lie <command-name> --help  # Show command help
```

## 🎨 Interactive Command Creation

The `lie create` command provides a guided experience for building new commands:

```bash
$ lie create my-tool
Creating command: my-tool

→ Command description (what does this command do?):
A tool for managing my projects

→ Add flags (e.g., verbose, quiet, force) or press Enter to skip:
Flag name (or Enter to finish): verbose
Flag description: Enable verbose output
Shorthand (e.g., v for verbose, or Enter to skip): v
✓ Added flag: --verbose
  Shorthand: -v

Flag name (or Enter to finish): force
Flag description: Force operation without confirmation
Shorthand (e.g., v for verbose, or Enter to skip): f
✓ Added flag: --force
  Shorthand: -f

Flag name (or Enter to finish):
✅ Created command: ./my-tool.sh

Next steps:
  1. Review and edit the generated command
  2. Install with: lie install ./my-tool.sh
  3. Test with: lie my-tool
```

The generated command includes:
- ✅ Proper `LIE_HOME` assignment
- ✅ Common utilities sourcing
- ✅ Command metadata
- ✅ Interactive flag parsing
- ✅ Help system
- ✅ Error handling
- ✅ Utility function integration

## 📁 Framework Structure

```
$HOME/.lie/
├── lie                    # Main dispatcher script
├── commands/              # Installed commands
├── utils/                 # Utility functions
│   └── common.sh         # Common utilities
├── templates/             # Command templates
│   └── command_template.sh
├── config/               # Configuration
│   └── config.json       # Framework configuration
└── examples/             # Example commands
    └── hello.sh          # Hello world example
```

## 🔧 Available Utilities

The framework provides a rich set of utilities in `$LIE_HOME/utils/common.sh`:

### 🎨 Output Functions
```bash
print_success "✅ Success message"
print_error "❌ Error message"
print_warning "⚠️  Warning message"
print_info "ℹ️  Info message"
```

### 📝 Logging System
```bash
log debug "Debug message"
log info "Info message"
log warn "Warning message"
log error "Error message"
```

### 📁 File Operations
```bash
file_exists "/path/to/file"
dir_exists "/path/to/directory"
ensure_dir "/path/to/directory"
```

### 👤 User Interaction
```bash
get_input "Enter your name" "default"
confirm "Continue?" "y"
```

### ⚙️ Configuration Management
```bash
parse_json "config.json" "key"
save_json "config.json" "key" "value"
```

## 📋 Command Structure

Generated commands follow this robust structure:

```bash
#!/bin/zsh

# Generated command for lie CLI Framework
LIE_HOME="${LIE_HOME:-$HOME/.lie}"
# Source common utilities
source "$LIE_HOME/utils/common.sh"

# Command metadata
COMMAND_NAME="my-tool"
COMMAND_VERSION="1.0.0"
COMMAND_DESCRIPTION="A tool for managing my projects"

# Show command help
show_help() {
    echo -e "${BLUE}$COMMAND_NAME v$COMMAND_VERSION${NC}"
    echo ""
    echo "Description: $COMMAND_DESCRIPTION"
    echo ""
    echo "Usage: lie $COMMAND_NAME [options]"
    echo ""
    echo "Options:"
    echo "  --verbose, -v    Enable verbose output"
    echo "  --force, -f      Force operation without confirmation"
    echo "  --help, -h       Show this help message"
}

# Main command logic
main_command() {
    local verbose_flag=false
    local force_flag=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose|-v)
                verbose_flag=true
                shift
                ;;
            --force|-f)
                force_flag=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    # Your command logic goes here
    print_info "Hello from $COMMAND_NAME!"
    print_success "Command executed successfully"
}

# Main execution
main() {
    if [ $# -eq 0 ]; then
        main_command
        exit 0
    fi
    
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi
    
    main_command "$@"
}

main "$@"
```

## 📋 Examples

### Hello World Command
```bash
$ lie hello
✅ Hello, World!

$ lie hello Alice
✅ Hello, Alice!

$ lie hello Albert --formal
✅ Good day, Albert!

$ lie hello Charlie --loud
✅ Hello, Charlie!!!
```

### Creating a Project Manager
```bash
$ lie create project-manager
# Follow the interactive prompts...

$ lie install ./project-manager.sh
$ lie project-manager --help
$ lie project-manager create my-project
```

## ⚙️ Configuration

The framework configuration is stored in `$HOME/.lie/config/config.json`:

```json
{
  "framework": {
    "version": "1.0.0",
    "commands_dir": "commands",
    "utils_dir": "utils",
    "templates_dir": "templates"
  },
  "settings": {
    "log_level": "info",
    "timeout": 30
  }
}
```

### Log Levels
- `debug` - Show all messages
- `info` - Show info, warnings, and errors
- `warn` - Show warnings and errors only
- `error` - Show errors only

## 🧪 Testing

The framework includes comprehensive test suites:

```bash
# Run all tests
make test

# Run command flow tests
./tests/test_command_flow.sh

# Run framework tests
./tests/test_framework.sh
```

## 🗑️ Uninstallation

```bash
# Run the uninstaller
./uninstall.sh
```

This will:
- Remove the framework from `$HOME/.lie`
- Remove the wrapper script from `$HOME/.local/bin`
- Clean up PATH entries from `~/.zshrc`
- Preserve your installed commands (backup recommended)

## 🛠️ Development

### Makefile Targets
```bash
make install      # Install the framework
make uninstall    # Uninstall the framework
make test         # Run all tests
make clean        # Clean up test files
make dev          # Development workflow
```

### Adding New Utilities

1. Create new utility files in `$HOME/.lie/utils/`
2. Source them in your commands: `source "$LIE_HOME/utils/new_utility.sh"`

### Extending the Framework

The framework is designed to be extensible. You can:
- Add new command types beyond `.sh` files
- Implement command repositories
- Add autocomplete generation
- Create command validation systems
- Build command marketplaces

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly with `make test`
5. Submit a pull request

## 📄 License

[Add your license here]

---

**Happy Hacking! ☠️**

The lie CLI Framework - Where modularity meets simplicity. 