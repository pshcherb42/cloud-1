PROJECT_NAME = cloud-1

all: help

setup:
	@bash scripts/setup.sh

setup-dev:
	@bash scripts/setup.sh -dev

help:
	@echo "Available commands:"
	@echo "make setup		- Installs project dependencies"
	@echo "make setup-dev	- Same + some development and testing tools"

.PHONY: all help setup setup-dev
