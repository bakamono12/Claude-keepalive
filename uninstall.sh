#!/usr/bin/env bash
# uninstall.sh
set -euo pipefail

UNIT_DIR="${HOME}/.config/systemd/user"
BIN_DIR="${HOME}/.local/bin"

echo ">> Stopping and disabling timer..."
systemctl --user disable --now claude-keepalive.timer 2>/dev/null || true

echo ">> Removing unit and script files..."
rm -f "${UNIT_DIR}/claude-keepalive.timer"
rm -f "${UNIT_DIR}/claude-keepalive.service"
rm -f "${BIN_DIR}/claude-keepalive.sh"

systemctl --user daemon-reload
echo ">> Done. Log at ~/.claude-keepalive.log left in place (delete manually if you want)."
