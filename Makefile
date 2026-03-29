.PHONY: pdf html dev list all clean install help

SHELL := /bin/bash

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

pdf: ## Build PDF: make pdf BOOK="Book Title"
	@test -n "$(BOOK)" || (echo 'Usage: make pdf BOOK="Book Title"' && exit 1)
	@bash scripts/build.sh "$(BOOK)" pdf

html: ## Build HTML: make html BOOK="Book Title"
	@test -n "$(BOOK)" || (echo 'Usage: make html BOOK="Book Title"' && exit 1)
	@bash scripts/build.sh "$(BOOK)" html

dev: ## Dev server with hot reload: make dev BOOK="Book Title"
	@test -n "$(BOOK)" || (echo 'Usage: make dev BOOK="Book Title"' && exit 1)
	@bash scripts/dev.sh "$(BOOK)"

list: ## List all books in the repository
	@bash scripts/list-books.sh

all: ## Build PDFs for all books
	@bash scripts/list-books.sh | while IFS=' —' read -r name _rest; do \
		echo "Building: $$name"; \
		bash scripts/build.sh "$$name" pdf; \
	done

clean: ## Remove all .build directories
	@find . -name '.build' -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "Cleaned all build artifacts."

install: ## Install local dev dependencies
	npm install
	@echo ""
	@echo "For PDF builds, you also need pandoc and texlive:"
	@echo "  sudo apt install pandoc texlive-xetex texlive-latex-extra texlive-fonts-recommended"
