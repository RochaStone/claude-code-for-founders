#!/usr/bin/env bash
# statusline.sh: a hot pink status line for Claude Code.
# Claude Code pipes session JSON to stdin. This prints one line:
#   🐆 <model> · ctx <used>% · $<cost> · <n> open
# Each part shows only when the data is there. Open items come from the never-ask-twice file.
#
# Settings: OPEN_ITEMS_FILE (default ~/.claude/OPEN_ITEMS.md), NO_COLOR=1 for plain text,
#           PINK_TERMINAL_ASCII=1 to swap the leopard emoji for =^.^=
input=$(cat)

if command -v jq >/dev/null 2>&1; then
  IFS=$'\x1f' read -r model cost used ctxin ctxsize < <(printf '%s' "$input" | jq -r '[
      (.model.display_name // .model.id // ""),
      (.cost.total_cost_usd // ""),
      (.context_window.used_percentage // ""),
      (.context_window.total_input_tokens // ""),
      (.context_window.context_window_size // "")
    ] | map(tostring) | join("\u001f")' 2>/dev/null)
else
  IFS=$'\x1f' read -r model cost used ctxin ctxsize < <(printf '%s' "$input" | python3 -c '
import json, sys
try: d = json.load(sys.stdin)
except Exception: d = {}
m, c, w = d.get("model") or {}, d.get("cost") or {}, d.get("context_window") or {}
vals = [m.get("display_name") or m.get("id") or "", c.get("total_cost_usd", ""),
        w.get("used_percentage", ""), w.get("total_input_tokens", ""), w.get("context_window_size", "")]
print("\x1f".join("" if v is None else str(v) for v in vals))' 2>/dev/null)
fi

# Context: use the percentage when Claude Code sends it, else work it out from the token counts.
ctx=""
if [ -n "${used:-}" ]; then ctx=$(printf '%.0f' "$used" 2>/dev/null)
elif [ -n "${ctxin:-}" ] && [ -n "${ctxsize:-}" ] && [ "${ctxsize:-0}" != "0" ]; then
  ctx=$(awk -v a="$ctxin" -v b="$ctxsize" 'BEGIN { printf "%.0f", a * 100 / b }' 2>/dev/null)
fi
money=""
if [ -n "${cost:-}" ]; then money=$(awk -v c="$cost" 'BEGIN { if (c + 0 > 0) printf "$%.2f", c }' 2>/dev/null); fi

# Open items: the rows in the Open table of OPEN_ITEMS.md.
items_file="${OPEN_ITEMS_FILE:-$HOME/.claude/OPEN_ITEMS.md}"
open=""
if [ -f "$items_file" ]; then
  open=$(awk '
    /^## / { s = tolower($0); next }
    s ~ /^## open/ && /^\|/ && $0 !~ /^\|[ \t:|-]+\|?[ \t]*$/ {
      split($0, c, "|"); id = c[2]; gsub(/[ \t]/, "", id)
      if (id != "#" && id != "") n++
    }
    END { print n + 0 }' "$items_file")
fi

glyph="🐆"; [ "${PINK_TERMINAL_ASCII:-0}" = "1" ] && glyph="=^.^="
parts=()
[ -n "${model:-}" ] && parts+=("$model")
[ -n "$ctx" ] && parts+=("ctx ${ctx}%")
[ -n "$money" ] && parts+=("$money")
[ -n "$open" ] && parts+=("$open open")
line=""
for p in "${parts[@]}"; do line="${line:+$line · }$p"; done

if [ -n "${NO_COLOR:-}" ]; then
  printf '%s %s\n' "$glyph" "$line"
else
  PINK=$'\033[48;2;255;45;138m\033[38;2;17;17;17m'   # hot pink paper, ink text
  HOT=$'\033[1;38;2;255;45;138m'                     # hot pink text
  CANDY=$'\033[38;2;255;179;209m'                    # candy pink text
  RESET=$'\033[0m'
  warn=""; [ -n "$ctx" ] && [ "$ctx" -ge 80 ] 2>/dev/null && warn=$'\033[38;2;224;32;46m'   # marker red when context runs low
  printf '%s %s %s %s%s%s %s\n' "$PINK" "$glyph" "$RESET" "${warn:-$HOT}" "$line" "$RESET" "${CANDY}♡${RESET}"
fi
