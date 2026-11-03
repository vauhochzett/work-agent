#!/usr/bin/env bash

# Install the work agent and skill into the local opencode config.

usage() {
    echo "Usage: $0 [--copy]" >&2
    exit 1
}

set -euo pipefail

LINK=true
acting="symlinking"
case "${1:-}" in
    "") ;;
    --copy)
        LINK=false
        acting="copying"
        ;;
    *)
        usage
        ;;
esac

echo "Installing by $acting to local OpenCode config directory..."

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"

mkdir -p "$CONFIG_DIR/agents" "$CONFIG_DIR/skills"

install_item() {
    local src="$1" dest="$2"
    # Replace any previous install (copy or symlink)
    if [[ -e "$dest" || -L "$dest" ]]; then
        read -r -p "Replace existing $dest? [y/N] " answer || answer=""
        if [[ "$answer" != [yY] ]]; then
            echo "Skipped: $dest"
            return
        fi
        rm -rf "$dest"
    fi
    if $LINK; then
        ln -s "$src" "$dest"
    else
        cp -r "$src" "$dest"
    fi
    echo "Installed: $dest"
}

install_item "$SRC_DIR/agents/work.md" "$CONFIG_DIR/agents/work.md"
install_item "$SRC_DIR/skills/work" "$CONFIG_DIR/skills/work"
