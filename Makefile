PROJECT_NAME = cloud-1

BLUE    := $(shell printf '\033[34m')
MAGENTA := $(shell printf '\033[35m')
RESET   := $(shell printf '\033[0m')

VAULT_FILE = group_vars/all/vault.yml
VAULT_PASS = --vault-password-file .vault_pass

all: help

setup:
	@bash scripts/setup.sh

setup-dev:
	@bash scripts/setup.sh -dev
	@$(MAKE) vms-up
	@echo "$(MAGENTA)VMs ready. Run 'make help' to see the VM commands$(RESET)"

vms-up:
	@bash scripts/vms.sh up

vms-down:
	@bash scripts/vms.sh down

vms-destroy:
	@bash scripts/vms.sh destroy

lint:
	@uv run pre-commit run --all-files

vault-view:
	@uv run ansible-vault view $(VAULT_FILE) $(VAULT_PASS)

vault-edit:
	@uv run ansible-vault edit $(VAULT_FILE) $(VAULT_PASS)

deploy:
	@uv run ansible-playbook -i inventory/aws.ini site.yml $(VAULT_PASS)

check:
	@uv run ansible-playbook -i inventory/aws.ini site.yml --check --diff $(VAULT_PASS)

deploy-local: vms-up
	@uv run ansible-playbook -i inventory/local.ini site.yml $(VAULT_PASS)

check-local: vms-up
	@uv run ansible-playbook -i inventory/local.ini site.yml --check --diff $(VAULT_PASS)

clean:
	@rm -rf .ansible

devclean: clean vms-destroy

fclean: devclean
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
	@echo "$(BLUE)║  SETUP:                                                                      ║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make setup       $(RESET) Installs project dependencies                         $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(MAGENTA)make setup-dev   $(RESET) setup + multipass + creates the VMs.                  $(BLUE)║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║$(RESET)$(MAGENTA)  LOCAL VMs (multipass, dev only):                                            $(RESET)$(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(MAGENTA)make vms-up      $(RESET) Creates the VMs, or starts them if they exist         $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(MAGENTA)make vms-down    $(RESET) Stops the VMs (their disks are kept)                  $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(MAGENTA)make vms-destroy $(RESET) Deletes the VMs permanently                           $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(MAGENTA)make deploy-local$(RESET) Runs the playbook on the VMs                          $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(MAGENTA)make check-local $(RESET) Previews the playbook on the VMs, changes nothing     $(BLUE)║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║  CLOUD (AWS, inventory/aws.ini):                                             ║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make deploy      $(RESET) Runs the playbook on the AWS servers                  $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make check       $(RESET) Previews the playbook on AWS (run after a deploy)     $(BLUE)║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║  QUALITY:                                                                    ║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make lint        $(RESET) Runs every pre-commit check on ALL files              $(BLUE)║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║  SECRETS:                                                                    ║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make vault-view  $(RESET) Shows the decrypted secrets (vault.yml)               $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make vault-edit  $(RESET) Edits the secrets, re-encrypts them on save           $(BLUE)║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)║  CLEANUP:                                                                    ║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make clean       $(RESET) Removes the local ansible cache (.ansible)            $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(MAGENTA)make devclean    $(RESET) clean + destroys the VMs                              $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)   >  $(BLUE)make fclean      $(RESET) devclean + removes the virtual environment            $(BLUE)║$(RESET)"
	@echo "$(BLUE)║$(RESET)                        and the git hook (run make setup again!)              $(BLUE)║$(RESET)"
	@echo "$(BLUE)║                                                                              ║$(RESET)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════════════════════╝$(RESET)"

.PHONY: all help setup setup-dev lint vault-view vault-edit deploy deploy-local check check-local clean fclean vms-up vms-down vms-destroy devclean
