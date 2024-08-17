POETRY_RUN := poetry run
VERSION := $(shell poetry version -s)

.DEFAULT_GOAL := help

help:  ## print this help
	@# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""
.PHONY: help

lint:    ## Check lint
	$(POETRY_RUN) ruff check
.PHONY: lint

format:    ## Fix lint
	$(POETRY_RUN) ruff format
.PHONY: format

build:    ## Build the packages and binary into dist folder
	poetry build
	$(POETRY_RUN) pyinstaller --onefile --name swing_cli-$(VERSION) swing_tool/cli.py --add-data "static:static"
.PHONY: build

release:    ## Create new tag
	git tag v${VERSION}
	git push origin v${VERSION}
.PHONY: release
