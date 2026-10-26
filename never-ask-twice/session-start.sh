#!/usr/bin/env bash
# session-start.sh: Claude Code SessionStart hook. Prints your open items in one compact block,
# so Claude sees them before your first message. Whatever this prints becomes session context.
#
# File: $OPEN_ITEMS_FILE, else ~/.claude/OPEN_ITEMS.md
# Shows at most $OPEN_ITEMS_MAX open items (default 12). Never fails the session: always exits 0.
FILE="${OPEN_ITEMS_FILE:-$HOME/.claude/OPEN_ITEMS.md}"
MAX="${OPEN_ITEMS_MAX:-12}"
case "$MAX" in ''|*[!0-9]*) MAX=12 ;; esac

if [ ! -f "$FILE" ]; then
  echo "Open items: none yet. (No $FILE. Create it from the never-ask-twice template when you have one.)"
  exit 0
fi

awk -v max="$MAX" -v file="$FILE" '
  function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
  function cut(s, n) { return length(s) > n ? substr(s, 1, n - 3) "..." : s }
  /^## / { section = tolower(trim(substr($0, 4))); next }
  /^\|/ {
    if ($0 ~ /^\|[ \t:|-]+\|?[ \t]*$/) next                     # separator row
    n = split($0, c, "|")
    id = trim(c[2]); item = trim(c[3])
    if (id == "#" || tolower(id) == "id" || item == "" || tolower(item) == "item") next   # header row
    if (section ~ /^open/) {
      open++
      if (open <= max) rows[open] = sprintf("#%s [%s] %s | default: %s", id, trim(c[4]), cut(item, 90), cut(trim(c[5]), 90))
    } else if (section ~ /^parked/) parked++
  }
  END {
    printf "=== OPEN ITEMS: %d open, %d parked (never ask twice) ===\n", open, parked
    for (i = 1; i <= open && i <= max; i++) print rows[i]
    if (open > max) printf "+%d more in %s\n", open - max, file
    if (open > 0) {
      print "Protocol: do every CLAUDE item whose default is unblocked, report in one short block."
      print "ME items: one line each, at most once this session. Max 3 flags per reply. Unanswered = take the default."
    }
  }
' "$FILE"
exit 0
