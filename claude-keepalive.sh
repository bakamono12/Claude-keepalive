#!/usr/bin/env bash
# claude-keepalive.sh
# Fires a minimal headless Claude Code prompt to start/refresh a 5h usage window.
# Designed to be invoked by a systemd user timer on weekdays.

set -u
# NOTE: no `set -e` -- we want to log failures, not crash silently.

LOG_FILE="${HOME}/.claude-keepalive.log"
CLAUDE_BIN="$(command -v claude || true)"
PROMPT="."

ts() { date '+%Y-%m-%d %H:%M:%S %Z'; }

log() {
    echo "[$(ts)] $*" >> "${LOG_FILE}"
}

# Rotate log if it crosses ~1 MiB, keep one backup.
if [[ -f "${LOG_FILE}" ]] && [[ $(stat -c%s "${LOG_FILE}" 2>/dev/null || echo 0) -gt 1048576 ]]; then
    mv -f "${LOG_FILE}" "${LOG_FILE}.1"
fi

if [[ -z "${CLAUDE_BIN}" ]]; then
    log "ERROR: 'claude' not found on PATH (PATH=${PATH}). Aborting."
    exit 127
fi

log "START ping via ${CLAUDE_BIN}"

# Headless, non-interactive. --print exits after response; no TTY needed.
# Timeout guards against network hangs. Output captured into log.
OUTPUT="$(timeout 60s "${CLAUDE_BIN}" --print --model sonnet "${PROMPT}" 2>&1)"
RC=$?

if [[ ${RC} -eq 0 ]]; then
    # Strip newlines for a tidy single-line log entry; truncate long replies.
    SUMMARY="$(printf '%s' "${OUTPUT}" | tr '\n' ' ' | cut -c1-200)"
    log "OK  reply='${SUMMARY}'"
else
    log "FAIL rc=${RC} output='$(printf '%s' "${OUTPUT}" | tr '\n' ' ' | cut -c1-500)'"
fi

exit ${RC}
