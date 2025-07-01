# Tests

This directory contains the test suites for the lie CLI framework.

## Test Structure

- `run_tests.sh` - Main test runner that executes all test suites
- `test_new_workflow.sh` - Tests the basic config-driven workflow
- `test_comprehensive.sh` - Tests advanced functionality and edge cases
- `.tmp/` - Directory for test artifacts (git ignored)

## Running Tests

```bash
# Run all tests
./tests/run_tests.sh

# Run individual tests
./tests/test_new_workflow.sh
./tests/test_comprehensive.sh
```

## Test Coverage

### Basic Workflow Test (`test_new_workflow.sh`)
- ✅ Config creation with interactive prompts
- ✅ Config editing and customization
- ✅ Package generation from config
- ✅ Custom logic addition
- ✅ Package installation
- ✅ Alias creation and direct access
- ✅ Both alias and lie prefix access
- ✅ Module listing

### Comprehensive Test (`test_comprehensive.sh`)
- ✅ Complex config creation with multiple commands
- ✅ Flag parsing and argument handling
- ✅ Package generation from complex configs
- ✅ Custom logic with flag processing
- ✅ Installation and alias creation
- ✅ Both alias and lie prefix access
- ✅ Help system and documentation
- ✅ Error handling and validation
- ✅ Module management and listing
- ✅ Persistence and executable permissions

## Test Artifacts

Test artifacts are created in the `.tmp/` directory and automatically cleaned up after each test run. This includes:
- Generated JSON config files
- Generated CLI packages
- Temporary module installations

## Adding New Tests

To add a new test:

1. Create a new test script in this directory
2. Use the `TEST_TMP_DIR` variable for test artifacts
3. Include proper cleanup in the test
4. Add the test to `run_tests.sh`
5. Update this README with test coverage information 