#!/usr/bin/env bash
set -euo pipefail

STATUS="${1:?Usage: set-status.sh <Status>}"

INPUT=$(cat)

CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
  exit 0
fi

DIRNAME="data.json" #$(basename "$CWD")
GIT_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
STATUS_DIR="$GIT_ROOT/.claude/claude-status"

echo "DEBUG: CWD=$CWD GIT_ROOT=$GIT_ROOT STATUS_DIR=$STATUS_DIR PWD=$(pwd)" >> /tmp/claude-status-debug.log

mkdir -p "$STATUS_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TMPFILE=$(mktemp "$STATUS_DIR/.tmp.XXXXXX")
jq -n \
  --arg status "$STATUS" \
  --arg session_id "$SESSION_ID" \
  --arg cwd "$CWD" \
  --arg dirname "$DIRNAME" \
  --arg timestamp "$TIMESTAMP" \
  '{status: $status, session_id: $session_id, cwd: $cwd, dirname: $dirname, timestamp: $timestamp}' \
  >"$TMPFILE"

mv "$TMPFILE" "$STATUS_DIR/${DIRNAME}.json"
