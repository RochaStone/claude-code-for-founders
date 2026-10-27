#!/usr/bin/env bash
# session-start.sh: Claude Code SessionStart hook. Prints your open items in one compact block,
# so Claude sees them before your first message. Whatever this prints becomes session context.
#
# It prints inside a tiny y2k-blog window, with a visitor counter that counts your sessions:
#   +-[ open-items.txt ]----------------------------------------------[_][o][x]-+
#   | 3 open, 0 parked                                         never ask twice |
#   | #3 [CLAUDE] Pick the header colour... | default: Use candy pink...       |
#   +--------------------------------------------------------------------------+
#    you are visitor no. 000,042 *
#
# File: $OPEN_ITEMS_FILE, else ~/.claude/OPEN_ITEMS.md
# Counter: $OPEN_ITEMS_VISITS_FILE, else .open-items-visits next to the open items file.
# Shows at most $OPEN_ITEMS_MAX open items (default 12). Never fails the session: always exits 0.
FILE="${OPEN_ITEMS_FILE:-$HOME/.claude/OPEN_ITEMS.md}"
MAX="${OPEN_ITEMS_MAX:-12}"
VISITS="${OPEN_ITEMS_VISITS_FILE:-$(dirname "$FILE")/.open-items-visits}"
case "$MAX" in ''|*[!0-9]*) MAX=12 ;; esac

if [ ! -f "$FILE" ]; then
  echo "Open items: none yet. (No $FILE. Create it from the never-ask-twice template when you have one.)"
  exit 0
fi

visits=0
if [ -f "$VISITS" ]; then visits=$(tr -cd '0-9' < "$VISITS"); fi
visits=$(( ${visits:-0} + 1 ))
printf '%s\n' "$visits" > "$VISITS" 2>/dev/null

awk -v max="$MAX" -v file="$FILE" -v visits="$visits" '
  function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
  function cut(s, n) { return length(s) > n ? substr(s, 1, n - 3) "..." : s }
  function row(s) { printf "| %-" W "s |\n", cut(s, W) }
  BEGIN { W = 96 }
  /^## / { section = tolower(trim(substr($0, 4))); next }
  /^\|/ {
    if ($0 ~ /^\|[ \t:|-]+\|?[ \t]*$/) next                     # separator row
    n = split($0, c, "|")
    id = trim(c[2]); item = trim(c[3])
    if (id == "#" || tolower(id) == "id" || item == "" || tolower(item) == "item") next   # header row
    if (section ~ /^open/) {
      open++
      if (open <= max) rows[open] = sprintf("#%s [%s] %s | default: %s", id, trim(c[4]), cut(item, 40), cut(trim(c[5]), 40))
    } else if (section ~ /^parked/) parked++
  }
  END {
    title = "+-[ open-items.txt ]"; buttons = "[_][o][x]-+"
    bar = ""; for (i = length(title) + length(buttons); i < W + 4; i++) bar = bar "-"
    print title bar buttons
    left = sprintf("%d open, %d parked", open, parked); right = "never ask twice"
    printf "| %s%" (W - length(left)) "s |\n", left, right
    for (i = 1; i <= open && i <= max; i++) row(rows[i])
    if (open > max) row(sprintf("+%d more in %s", open - max, file))
    if (open > 0) {
      row("Protocol: do every CLAUDE item whose default is unblocked, report in one short block.")
      row("ME items: once per session, one line each. Max 3 flags per reply. Unanswered = take the default.")
    }
    line = "+"; for (i = 0; i < W + 2; i++) line = line "-"
    print line "+"
    n = sprintf("%06d", visits)
    printf " you are visitor no. %s,%s *\n", substr(n, 1, 3), substr(n, 4, 3)
  }
' "$FILE"
exit 0
