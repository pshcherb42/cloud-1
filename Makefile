PROJECT_NAME = cloud-1

BLUE  := $(shell printf '\033[34m')
RESET := $(shell printf '\033[0m')

all: help

setup:
	@bash scripts/setup.sh

setup-dev:
	@bash scripts/setup.sh -dev

lint:
	@uv run pre-commit run --all-files

clean:
	@rm -rf .ansible

fclean: clean
	@rm -rf .venv .git/hooks/pre-commit ~/.cache/pre-commit

help:
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║              ██████╗██╗      ██████╗ ██╗   ██╗██████╗        ██╗             ║$(RESET)"
	@echo "$(BLUE)║             ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗      ███║             ║$(RESET)"
	@echo "$(BLUE)║             ██║     ██║     ██║   ██║██║   ██║██║  ██║█████╗╚██║             ║$(RESET)"
	@echo "$(BLUE)║             ██║     ██║     ██║   ██║██║   ██║██║  ██║╚════╝ ██║             ║$(RESET)"
	@echo "$(BLUE)║             ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝       ██║             ║$(RESET)"
	@echo "$(BLUE)║              ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝        ╚═╝             ║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║$(RESET)                 ~ $(PROJECT_NAME) :: INFRASTRUCTURE CONTROL PANEL ~                  $(BLUE)║$(RESET)"
	@echo "$(BLUE)╠══════════════════════════════════════════════════════════════════════════════╣$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║$(RESET)  AVAILABLE COMMANDS:                                                         $(BLUE)║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make setup     $(RESET) Installs project dependencies                           $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make setup-dev $(RESET) Also installs 'multipass' (macOS only) for local VMs    $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make lint      $(RESET) Runs every pre-commit check on ALL files                $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make clean     $(RESET) Removes the local ansible cache (.ansible)              $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make fclean    $(RESET) clean + removes the virtual environment                 $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)                      and the git hook (run make setup again!)                $(BLUE)║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════════════════════╝$(RESET)"

.PHONY: all help setup setup-dev lint clean fclean
