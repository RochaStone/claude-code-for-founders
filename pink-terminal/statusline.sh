#!/usr/bin/env bash
# statusline.sh: a hot pink status line for Claude Code.
# Claude Code pipes session JSON to stdin. This prints one line:
#   🐆 <model> · ctx <used>% · $<cost> · <n> open · <stamp>
# Each part shows only when the data is there. Open items come from the never-ask-twice file.
# Colours and the stamp word come from your style.json (see STYLE.md): palette.hero, palette.ink,
# palette.accent, palette.marker and lines.stamp. No style.json means the bundled Rocha Coded look.
#
# Settings: OPEN_ITEMS_FILE (default ~/.claude/OPEN_ITEMS.md), NO_COLOR=1 for plain text,
#           PINK_TERMINAL_ASCII=1 to swap the leopard emoji for =^.^=, ROCHA_CODED_STYLE=<file>
HERE="$(cd "$(dirname "$0")" && pwd)"
input=$(cat)

if command -v jq >/dev/null 2>&1; then
  IFS=$'\x1f' read -r model cost used ctxin ctxsize cwd < <(printf '%s' "$input" | jq -r '[
      (.model.display_name // .model.id // ""),
      (.cost.total_cost_usd // ""),
      (.context_window.used_percentage // ""),
      (.context_window.total_input_tokens // ""),
      (.context_window.context_window_size // ""),
      (.workspace.current_dir // .cwd // "")
    ] | map(tostring) | join("\u001f")' 2>/dev/null)
else
  IFS=$'\x1f' read -r model cost used ctxin ctxsize cwd < <(printf '%s' "$input" | python3 -c '
import json, sys
try: d = json.load(sys.stdin)
except Exception: d = {}
m, c, w = d.get("model") or {}, d.get("cost") or {}, d.get("context_window") or {}
vals = [m.get("display_name") or m.get("id") or "", c.get("total_cost_usd", ""),
        w.get("used_percentage", ""), w.get("total_input_tokens", ""), w.get("context_window_size", ""),
        (d.get("workspace") or {}).get("current_dir") or d.get("cwd") or ""]
print("\x1f".join("" if v is None else str(v) for v in vals))' 2>/dev/null)
fi

# Style: the first style.json found wins. Missing or malformed COLOURS fall back to Rocha Coded.
# Words never do: a style.json without lines.stamp shows no stamp, never hers.
style=""
for f in "${ROCHA_CODED_STYLE:-}" "${cwd:+$cwd/style.json}" "$HOME/.rocha-coded/style.json" \
         "$HERE/style.rocha-coded.json" "$HERE/../examples/style.rocha-coded.json"; do
  [ -n "$f" ] && [ -f "$f" ] && { style="$f"; break; }
done
s_hero="" s_ink="" s_accent="" s_marker="" stamp=""
if [ -n "$style" ]; then
  if command -v jq >/dev/null 2>&1; then
    IFS=$'\x1f' read -r s_hero s_ink s_accent s_marker stamp < <(jq -r '[(.palette.hero // ""), (.palette.ink // ""),
      (.palette.accent // ""), (.palette.marker // ""), (.lines.stamp // "")] | map(tostring) | join("\u001f")' "$style" 2>/dev/null)
  else
    IFS=$'\x1f' read -r s_hero s_ink s_accent s_marker stamp < <(python3 -c '
import json, sys
try: d = json.load(open(sys.argv[1]))
except Exception: d = {}
p, l = d.get("palette") or {}, d.get("lines") or {}
print("\x1f".join(str(x or "") for x in [p.get("hero"), p.get("ink"), p.get("accent"), p.get("marker"), l.get("stamp")]))' "$style" 2>/dev/null)
  fi
fi
rgb() { # $1 hex, $2 fallback hex -> "r;g;b"
  local h="$1"; case "$h" in \#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]) ;; *) h="$2" ;; esac
  printf '%d;%d;%d' "0x${h:1:2}" "0x${h:3:2}" "0x${h:5:2}"
}
HERO=$(rgb "$s_hero" "#FF2D8A"); INK=$(rgb "$s_ink" "#111111"); ACC=$(rgb "$s_accent" "#FFB3D1"); MARK=$(rgb "$s_marker" "#E0202E")

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
[ -n "$stamp" ] && parts+=("$stamp")
line=""
for p in "${parts[@]}"; do line="${line:+$line · }$p"; done

if [ -n "${NO_COLOR:-}" ]; then
  printf '%s %s\n' "$glyph" "$line"
else
  PINK="\033[48;2;${HERO}m\033[38;2;${INK}m"   # hero colour paper, ink text
  HOT="\033[1;38;2;${HERO}m"                    # hero colour text
  CANDY="\033[38;2;${ACC}m"                     # accent text
  RESET="\033[0m"
  warn=""; [ -n "$ctx" ] && [ "$ctx" -ge 80 ] 2>/dev/null && warn="\033[38;2;${MARK}m"   # marker colour when context runs low
  printf "%b %s %b %b%s%b %b\n" "$PINK" "$glyph" "$RESET" "${warn:-$HOT}" "$line" "$RESET" "${CANDY}♡${RESET}"
fi
