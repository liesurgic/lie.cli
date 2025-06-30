# lie - Modular CLI Framework

A powerful, config-driven CLI framework that allows you to create, install, and manage modular shell commands. Inspired by tools like `git`, `docker`, and `kubectl`, `lie` provides a clean, extensible architecture for building command-line tools.

## 🚀 Features

- **Config-Driven Development** - Define modules using JSON configuration files
- **Interactive Creation** - Guided setup with interactive prompts
- **Modular Architecture** - Create reusable CLI modules with subcommands
- **Dual Access Methods** - Use either direct aliases (`hive start`) or framework prefix (`lie hive start`)
- **Flag Support** - Built-in support for command flags and arguments
- **Extensible** - Easy to add new commands and functionality
- **Clean Separation** - Framework code separated from user logic

## 📦 Installation

```bash
# Clone the repository
git clone <repository-url>
cd liecli

# Install the framework
./install.sh
```

The framework installs to `$HOME/.lie` and adds `$HOME/.local/bin` to your PATH.

## 🎯 Quick Start

### 1. Create a Module

```bash
# Create a new module with interactive prompts
lie create my-module
```

This creates a `my-module.json` configuration file with basic structure.

### 2. Edit the Configuration

```json
{
    "name": "my-module",
    "description": "My awesome CLI module",
    "alias": "mm",
    "commands": [
        {
            "name": "start",
            "description": "Start the service",
            "flags": [
                {
                    "name": "port",
                    "shorthand": "p",
                    "description": "Port number"
                }
            ]
        },
        {
            "name": "stop",
            "description": "Stop the service",
            "flags": []
        }
    ]
}
```

### 3. Generate the CLI Package

```bash
# Generate the CLI package from your config
lie package my-module
```

This creates a `my-module_cli/` directory with:
- `commands.sh` - Your command logic (edit this)
- `install.sh` - Installation script
- `.cli/` - Framework files (don't touch)

### 4. Add Your Logic

Edit `my-module_cli/commands.sh` to implement your commands:

```bash
#!/bin/zsh

start() {
    local port="8080"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                port="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done
    
    print_info "Starting service on port $port..."
    print_success "Service started!"
}

stop() {
    print_info "Stopping service..."
    print_success "Service stopped!"
}

help() {
    print_info "Available commands:"
    print_info "  start   - Start the service"
    print_info "  stop    - Stop the service"
    print_info "  help    - Show this help"
}
```

### 5. Install and Use

```bash
# Install the module
cd my-module_cli
./install.sh

# Use with alias (if configured)
mm start --port 3000

# Or use with lie prefix
lie my-module start --port 3000
```

## 📚 Framework Commands

### Core Commands

- `lie create <module>` - Create a new module configuration
- `lie package <module>` - Generate CLI package from config
- `lie install <module>` - Install a module (alternative to running install.sh)
- `lie list` - List installed modules
- `lie --help` - Show framework help

### Module Commands

Once installed, modules support:
- `<alias> <command>` - Direct access via alias
- `lie <module> <command>` - Access via framework prefix
- `<alias> help` - Show module help
- `lie <module> help` - Show module help

## 🏗️ Architecture

### Directory Structure

```
$HOME/.lie/
├── framework/          # Framework source code
├── modules/           # Installed modules
│   └── my-module/
│       ├── my-module.sh    # Module entry point
│       └── commands.sh     # User commands
└── utils/             # Framework utilities
```

### Module Structure

```
my-module_cli/
├── commands.sh        # Your command logic
├── install.sh         # Installation script
└── .cli/             # Framework files
    └── my-module.sh   # Generated module script
```

## ⚙️ Configuration

### Module Configuration (JSON)

```json
{
    "name": "module-name",
    "description": "Module description",
    "alias": "short-alias",
    "commands": [
        {
            "name": "command-name",
            "description": "Command description",
            "flags": [
                {
                    "name": "flag-name",
                    "shorthand": "f",
                    "description": "Flag description"
                }
            ]
        }
    ]
}
```

### Command Functions

Each command in `commands.sh` should be a function:

```bash
command_name() {
    # Parse arguments and flags
    local flag_value=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--flag)
                flag_value="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Your command logic here
    print_info "Running command..."
    print_success "Command completed!"
}
```

## 🎨 Utility Functions

The framework provides utility functions for consistent output:

- `print_info "message"` - Info message (blue)
- `print_success "message"` - Success message (green)
- `print_warn "message"` - Warning message (yellow)
- `print_error "message"` - Error message (red)

## 🔧 Development Workflow

### 1. Create and Configure
```bash
lie create my-tool
# Edit my-tool.json
```

### 2. Generate and Develop
```bash
lie package my-tool
# Edit my-tool_cli/commands.sh
```

### 3. Install and Test
```bash
cd my-tool_cli
./install.sh
# Test with: my-tool help
```

### 4. Iterate
```bash
# Make changes to commands.sh
# Reinstall: ./install.sh
```

## 🧪 Testing

The framework includes comprehensive test suites in the `tests/` directory:

```bash
# Run all tests
./tests/run_tests.sh

# Run individual test suites
./tests/test_new_workflow.sh
./tests/test_comprehensive.sh
```

### Test Structure

```
tests/
├── run_tests.sh              # Test runner (runs all tests)
├── test_new_workflow.sh      # Basic workflow test
├── test_comprehensive.sh     # Advanced functionality test
└── .tmp/                     # Test artifacts (git ignored)
```

The `.tmp/` directory contains test-generated files and is automatically cleaned up after each test run.

## 📝 Examples

### Simple Module
```json
{
    "name": "greeter",
    "description": "A simple greeting tool",
    "alias": "hi",
    "commands": [
        {
            "name": "hello",
            "description": "Say hello",
            "flags": []
        }
    ]
}
```

### Complex Module
```json
{
    "name": "deployer",
    "description": "Deployment automation tool",
    "alias": "deploy",
    "commands": [
        {
            "name": "deploy",
            "description": "Deploy application",
            "flags": [
                {
                    "name": "environment",
                    "shorthand": "e",
                    "description": "Target environment"
                },
                {
                    "name": "force",
                    "shorthand": "f",
                    "description": "Force deployment"
                }
            ]
        },
        {
            "name": "rollback",
            "description": "Rollback deployment",
            "flags": []
        }
    ]
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request


## 🆘 Support

For issues and questions:
- Check the test files for examples
- Review the framework utilities in `framework/utils/`
- Run `lie --help` for framework commands 