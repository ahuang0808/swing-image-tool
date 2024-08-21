POETRY_RUN := poetry run
VERSION := $(shell poetry version -s)

.DEFAULT_GOAL := help

help:  ## print this help
	@# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""
.PHONY: help

init:    ## Init the dev env
	poetry install
	poetry shell
	pre-commit install
	pre-commit install --hook-type commit-msg
.PHONY: init

lint:    ## Check lint
	$(POETRY_RUN) black . --diff
	$(POETRY_RUN) isort . --check --diff || true
	$(POETRY_RUN) flake8
.PHONY: lint

format:    ## Fix lint
	$(POETRY_RUN) black .
	$(POETRY_RUN) isort .
	$(POETRY_RUN) flake8
.PHONY: format

build:    ## Build the packages and binary into dist folder
	poetry build
	$(POETRY_RUN) pyinstaller --onefile --name swing_cli-$(VERSION) swing_tool/cli.py
.PHONY: build

release:    ## Create new tag
	git tag v${VERSION}
	git push origin v${VERSION}
.PHONY: release
