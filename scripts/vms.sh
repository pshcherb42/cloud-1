#!/bin/bash

set -euo pipefail # all three flags in one (check setup.sh for more)

cd "$(dirname "$0")/.."

if [ -t 1 ]; then # -t 1 checks if is file descriptor 1 (stdout)
    BLUE=$'\033[34m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    RED=$'\033[31m'
    RESET=$'\033[0m'
else
    BLUE="" GREEN="" YELLOW="" RED="" RESET=""
fi

ACTION="${1:-up}"
NODES="node1 node2"

if ! command -v multipass > /dev/null; then
    if [ "$ACTION" = "up" ]; then
        echo "${RED}Multipass not detected: run 'make setup-dev' to install/get instructions${RESET}"
        exit 1
    elif [ "$ACTION" = "down" ] || [ "$ACTION" = "destroy" ]; then
        echo "${YELLOW}Multipass not installed: no VMs to $ACTION${RESET}"
        exit 0
    fi
    # unknown actions fall through to the error at the bottom
fi

if [ "$ACTION" = "up" ]; then
    for node in $NODES; do
        if ! multipass info "$node" > /dev/null 2>&1; then
            multipass launch 22.04 --name "$node" --cloud-init cloud-init.yml
        elif [ "$(multipass list | awk -v n="$node" '$1 == n {print $2}')" = "Running" ]; then
            echo "${BLUE}$node is already running${RESET}"
        else
            multipass start "$node"
        fi
    done
elif [ "$ACTION" = "down" ]; then
    for node in $NODES; do
        if multipass info "$node" > /dev/null 2>&1; then
            multipass stop "$node"
        fi
    done
elif [ "$ACTION" = "destroy" ]; then
    for node in $NODES; do
        if multipass info "$node" > /dev/null 2>&1; then
            echo "${BLUE}Deleting $node...${RESET}"
            multipass delete --purge "$node"
        fi
    done
else
    echo "${RED}Unknown action: $ACTION${RESET}"
    exit 1
fi
