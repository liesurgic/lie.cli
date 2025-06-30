# lie CLI Framework - Test Suite

This directory contains comprehensive tests for the lie CLI framework.

## Test Files

- `test_simple.sh` - Basic workflow test (create → package → install → run)
- `test_flags.sh` - Flag parsing test with various flag combinations
- `test_new_workflow.sh` - New workflow test
- `test_completions.sh` - **COMPLETIONS TEST (PARTIALLY WORKING)**
- `run_tests.sh` - Test runner that executes all tests

## Completions Functionality Status

### ✅ What Works

1. **Completion Generator Structure**
   - `framework/utils/completion_generator.sh` - Main completion generator
   - `framework/utils/completions.sh` - Zsh setup script
   - `lie auto [directory]` - Generates completions from JSON configs
   - `lie completions` - Adds completion setup to ~/.zshrc

2. **Command Extraction**
   - Robust extraction of command names from JSON configs
   - Avoids extracting flag names (only gets top-level commands)
   - Uses portable grep+sed approach (works on macOS and Linux)

3. **Framework Integration**
   - Completion commands integrated into main `lie` dispatcher
   - Directory support for `lie auto` (can specify where to look for JSON configs)
   - Idempotent zsh setup (won't add duplicate blocks to ~/.zshrc)

4. **Test Infrastructure**
   - Comprehensive test suite in `test_completions.sh`
   - Tests both completion generation and zsh setup
   - Isolated test environment using `.tmp` directory

### ❌ What's Broken

1. **Array Expansion Error**
   - Persistent "bad math expression: operator expected at `descriptio...'" error
   - Occurs in `generate_module_completion` function
   - Prevents completion files from being generated properly

2. **Alias Completion Generation**
   - `_tc` file not being generated/updated correctly
   - Module completion (`_lie-test_completions`) works partially
   - Alias completion completely fails

3. **Test Failures**
   - `test_completions.sh` currently fails 2 out of 4 tests
   - Module completion file format test fails
   - Alias completion file not found

### 🔧 Technical Details

**Error Location:**
- Error occurs in `framework/utils/completion_generator.sh`
- Line 57 mentioned in error, but actual issue is in array expansion
- Happens when script is sourced, not when functions are called

**Array Expansion Attempts:**
- Tried: `local commands=($=commands_str)` (zsh-specific)
- Tried: `IFS=' ' read -r -a commands <<< "$commands_str"` (bash-specific)
- Tried: `local commands=(${(s: :)commands_str})` (zsh-specific)
- All failed with "bad math expression" or "bad option: -a"

**Current Implementation:**
```bash
# Extract commands from config
local commands_str=$(extract_commands_from_config "$config_file")
# Zsh-compatible array assignment
local commands=(${=commands_str})
```

## Next Steps for Debugging

### 1. Immediate Debugging
- Find the exact line causing the "bad math expression" error
- Check if there are hidden characters or syntax issues
- Verify the script works when run directly vs sourced

### 2. Alternative Approaches
- **Option A**: Rewrite completion generator in Python/Node.js
- **Option B**: Use simpler shell constructs (avoid complex array operations)
- **Option C**: Use `jq` for JSON parsing instead of grep/sed

### 3. Simplified Solution
- Focus on getting basic completion working first
- Generate static completion files without dynamic array expansion
- Add complexity incrementally

## Test Commands

```bash
# Run all tests
./run_tests.sh

# Run just completions test
./test_completions.sh

# Manual testing
cd .tmp
lie auto .  # Generate completions from current directory
lie completions  # Setup zsh completions
```

## Files Generated

When working correctly, the completion generator should create:
- `$HOME/.lie/completions/_lie-{module_name}` - Module completion
- `$HOME/.lie/completions/_{alias_name}` - Alias completion

## Zsh Setup

The `lie completions` command adds this block to `~/.zshrc`:
```bash
# >>> liecli completion setup >>>
fpath=($HOME/.lie/completions $fpath)
autoload -U compinit && compinit
# <<< liecli completion setup <<<
```

## Last Updated

July 1, 2024 - Completions functionality partially implemented but has persistent array expansion errors preventing full functionality. 