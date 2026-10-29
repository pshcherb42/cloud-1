PROJECT_NAME = cloud-1

all: help

setup:
	@bash scripts/setup.sh

setup-dev:
	@bash scripts/setup.sh -dev

lint:
	@uv run pre-commit run --all-files

help:
	@echo "Available commands:"
	@echo "make setup		- Installs project dependencies"
	@echo "make setup-dev	- Also installs 'multipass' (macOS only) for local VMs"
	@echo "make lint		- Runs every pre-commit check on ALL files"

.PHONY: all help setup setup-dev lint
