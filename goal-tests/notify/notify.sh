#!/usr/bin/env bash
# notify.sh SUBJECT BODY_FILE CONFIG
# Sends one notice through every channel listed in goal-tests.config.json under notify.channels.
# Channels: stdout, macos, webhook, smtp. One failing channel never stops the others.
set -u
SUBJECT="$1"; BODY_FILE="$2"; CONFIG="${3:-}"
HERE="$(cd "$(dirname "$0")" && pwd)"
channels=$(python3 "$HERE/../lib/ledger.py" channels "$CONFIG" 2>/dev/null) || channels="stdout"
[ -z "$channels" ] && channels="stdout"
while IFS= read -r ch; do
  case "$ch" in
    stdout)  bash "$HERE/stdout.sh" "$SUBJECT" "$BODY_FILE" ;;
    macos)   bash "$HERE/macos.sh" "$SUBJECT" "$BODY_FILE" || echo "notify: macos channel failed" >&2 ;;
    webhook) bash "$HERE/webhook.sh" "$SUBJECT" "$BODY_FILE" "$CONFIG" || echo "notify: webhook channel failed" >&2 ;;
    smtp)    python3 "$HERE/smtp.py" "$SUBJECT" "$BODY_FILE" "$CONFIG" || echo "notify: smtp channel failed" >&2 ;;
    "") ;;
    *) echo "notify: unknown channel '$ch' (use stdout, macos, webhook or smtp)" >&2 ;;
  esac
done <<< "$channels"
exit 0
