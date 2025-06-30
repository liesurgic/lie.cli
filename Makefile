# lie CLI Framework Makefile

.PHONY: help install uninstall test clean version status dev-install dev-test

# Default target
help:
	@echo "lie CLI Framework - Available targets:"
	@echo ""
	@echo "  install    - Install the framework to ~/.lie"
	@echo "  uninstall  - Remove the framework from ~/.lie"
	@echo "  test       - Run the test suite"
	@echo "  clean      - Remove temporary files"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make install"
	@echo "  make test"
	@echo "  make uninstall"

# Install the framework
install:
	@echo "Installing lie CLI Framework..."
	@./install.sh

# Uninstall the framework
uninstall:
	@echo "Uninstalling lie CLI Framework..."
	@./uninstall.sh

reinstall: uninstall install
	@echo "Reloading shell configuration..."
	@zsh -c "source ~/.zshrc"

# Run tests
test:
	@echo "Running lie CLI Framework tests..."
	@./tests/run_tests.sh

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.bak" -delete
	@find . -name ".DS_Store" -delete
	@echo "✅ Clean complete"

# Development targets
dev-install: install
	@echo "Installing example command for development..."
	@lie install examples/hello.sh

dev-test: dev-install
	@echo "Testing with example command..."
	@lie hello
	@lie hello Alice
	@lie uninstall hello

# Show version
version:
	@echo "lie CLI Framework v$(shell cat VERSION)"

# Show framework status
status:
	@echo "Framework Status:"
	@if [ -d "$(HOME)/.lie" ]; then \
		echo "✅ Framework installed at $(HOME)/.lie"; \
		echo "📦 Installed commands:"; \
		if [ -d "$(HOME)/.lie/commands" ]; then \
			ls -1 "$(HOME)/.lie/commands"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$$//' | sed 's/^/  - /' || echo "  (none)"; \
		else \
			echo "  (none)"; \
		fi; \
	else \
		echo "❌ Framework not installed"; \
	fi 