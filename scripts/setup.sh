#!/bin/bash

set -e
set -u          # using an unset variable is an error (catches typos)
set -o pipefail # a pipe fails if any command in it fails (e.g. curl | sh)

cd "$(dirname "$0")/.."

OS="$(uname -s)"
echo "Detected operating system: $OS"

DEV=false
if [ "${1:-}" = "-dev" ]; then
    DEV=true
    echo "Devmode ON"
fi

if ! command -v uv > /dev/null; then
    echo "The project needs uv to run."
    echo "Attempting uv installation..."
    if [ "$OS" = "Darwin" ]; then
        brew install uv
    elif [ "$OS" = "Linux" ]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "Unsupported operating system: $OS"
        exit 1
    fi
    # brew and curl failures already exit; this catches uv installed but not on PATH
    command -v uv > /dev/null || { echo "uv was installed but is not on PATH; open a new terminal or add its install folder to PATH"; exit 1; }
fi

if [ "$DEV" = true ]; then
    if [ "$OS" = "Darwin" ]; then
        command -v multipass > /dev/null || brew install --cask multipass # install multipass only if it isn't already on PATH

    else
        echo "Skipping multipass: use your Mac for local VMs"
        echo "If you're using your own Linux please run 'sudo snap install multipass'"
    fi
fi

uv sync --locked
uv run pre-commit install

echo "Setup finished successfully!"
echo "Please run 'source .venv/bin/activate' to start ansible"
