#!/usr/bin/env bash
# install.sh -- installs the claude-keepalive user service on Ubuntu 24.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
UNIT_DIR="${HOME}/.config/systemd/user"

echo ">> Installing claude-keepalive..."

mkdir -p "${BIN_DIR}" "${UNIT_DIR}"

install -m 0755 "${SCRIPT_DIR}/claude-keepalive.sh" "${BIN_DIR}/claude-keepalive.sh"
install -m 0644 "${SCRIPT_DIR}/claude-keepalive.service" "${UNIT_DIR}/claude-keepalive.service"
install -m 0644 "${SCRIPT_DIR}/claude-keepalive.timer"   "${UNIT_DIR}/claude-keepalive.timer"

echo ">> Reloading systemd user daemon..."
systemctl --user daemon-reload

echo ">> Enabling and starting timer..."
systemctl --user enable --now claude-keepalive.timer

# Lingering lets the timer run even when you're not logged in graphically.
# Needs sudo; offered, not forced.
if ! loginctl show-user "$(whoami)" 2>/dev/null | grep -q 'Linger=yes'; then
    echo ""
    echo ">> NOTE: user lingering is OFF."
    echo "   Without it, the timer only runs while you have an active login session."
    echo "   To keep it firing even when logged out, run:"
    echo "     sudo loginctl enable-linger $(whoami)"
fi

echo ""
echo ">> Done. Status:"
systemctl --user status claude-keepalive.timer --no-pager || true

echo ""
echo ">> Next fire times:"
systemctl --user list-timers claude-keepalive.timer --no-pager || true

echo ""
echo ">> To test a ping right now:"
echo "   systemctl --user start claude-keepalive.service"
echo "   tail -f ~/.claude-keepalive.log"
