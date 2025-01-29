#!/usr/bin/xcrun make -f

.PHONY: all
all: help

.PHONY: test
test:
	@Scripts/public/test.sh

.PHONY: check-quality
check-quality:
	@Scripts/public/check-quality.sh

.PHONY: fix-quality
fix-quality:
	@Scripts/public/fix-quality.sh

.PHONY: git-hook-install
git-hook-install:
	@Scripts/public/git-hooks.sh -i

.PHONY: git-hook-uninstall
git-hook-uninstall:
	@Scripts/public/git-hooks.sh -u

.PHONY: clean-imports
clean-imports:
	@Scripts/public/clean-imports.sh

.PHONY: find-dead-code
find-dead-code:
	@Scripts/public/find-dead-code.sh

.PHONY: help
help:
	@echo "Available targets:"
	@echo
	@echo "Default:"
	@echo "  all                            Default target"
	@echo
	@echo "Test:"
	@echo "  test                           Build & run unit tests"
	@echo
	@echo "Quality:"
	@echo "  check-quality                  Run quality checks"
	@echo "  fix-quality                    Automatically fix quality issues"
	@echo
	@echo "Git Hooks:"
	@echo "  git-hook-install               Install custom hooks from ./hooks"
	@echo "  git-hook-uninstall             Revert to default hooks"
	@echo
	@echo "Utilities:"
	@echo "  clean-imports                  Remove unused imports"
	@echo "  find-dead-code                 Locate dead code"
	@echo
	@echo "Other:"
	@echo "  help                           Show this help message"
