#!/bin/bash

set -e
set -u          # using an unset variable is an error (catches typos)
set -o pipefail # a pipe fails if any command in it fails (e.g. curl | sh)

cd "$(dirname "$0")/.."

# Colors only when printing to a terminal (not when output is piped or logged)
if [ -t 1 ]; then # -t 1 checks if is file descriptor 1 (stdout)
    BLUE=$'\033[34m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    RED=$'\033[31m'
    RESET=$'\033[0m'
else
    BLUE="" GREEN="" YELLOW="" RED="" RESET=""
fi

OS="$(uname -s)"
echo "${BLUE}Detected operating system: $OS${RESET}"

DEV=false
if [ "${1:-}" = "-dev" ]; then
    DEV=true
    echo "${BLUE}Devmode ON${RESET}"
fi

if ! command -v uv > /dev/null; then
    echo "${YELLOW}The project needs uv to run.${RESET}"
    echo "${YELLOW}Attempting uv installation...${RESET}"
    if [ "$OS" = "Darwin" ]; then
        brew install uv
    elif [ "$OS" = "Linux" ]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "${RED}Unsupported operating system: $OS${RESET}"
        exit 1
    fi
    # brew and curl failures already exit; this catches uv installed but not on PATH
    command -v uv > /dev/null || { echo "${RED}uv was installed but is not on PATH; open a new terminal or add its install folder to PATH${RESET}"; exit 1; }
fi

if [ "$DEV" = true ]; then
    if [ "$OS" = "Darwin" ]; then
        command -v multipass > /dev/null || brew install --cask multipass # install multipass only if it isn't already on PATH

    else
        echo "${YELLOW}Skipping multipass: use your Mac for local VMs${RESET}"
        echo "${YELLOW}If you're using your own Linux please run 'sudo snap install multipass'${RESET}"
    fi
fi

uv sync --locked
uv run pre-commit install

echo "${GREEN}Setup finished successfully!${RESET}"
echo "${GREEN}Please run 'source .venv/bin/activate' to start ansible${RESET}"
