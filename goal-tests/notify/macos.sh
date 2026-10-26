#!/usr/bin/env bash
# macos.sh SUBJECT BODY_FILE: a Notification Centre banner on a Mac. Silent no-op elsewhere.
[ "$(uname -s)" = "Darwin" ] || exit 0
command -v osascript >/dev/null 2>&1 || exit 0
first=$(grep -m1 '^- ' "$2" | cut -c3-120)
# Text goes in as arguments, never pasted into the script, so quotes in a probe's output are harmless.
osascript - "$1" "${first:-open ledger.json for detail}" <<'APPLESCRIPT' >/dev/null
on run argv
  display notification (item 2 of argv) with title "Goal tests" subtitle (item 1 of argv) sound name "Glass"
end run
APPLESCRIPT
