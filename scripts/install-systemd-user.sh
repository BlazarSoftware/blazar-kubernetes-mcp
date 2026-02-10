#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
UNIT_SRC="$REPO_DIR/systemd/kubernetes-mcp.service"
USER_SYSTEMD_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
UNIT_DST="$USER_SYSTEMD_DIR/kubernetes-mcp.service"

mkdir -p "$USER_SYSTEMD_DIR"
cp "$UNIT_SRC" "$UNIT_DST"

systemctl --user daemon-reload
systemctl --user enable --now kubernetes-mcp.service

# Allow the user service to run even when not logged in.
loginctl enable-linger "$USER" >/dev/null 2>&1 || true

systemctl --user status --no-pager kubernetes-mcp.service
