#!/usr/bin/env bash
# statusline.sh: the cyberpunk status line for Claude Code. A plum CRT strip with cream type.
# Claude Code pipes session JSON to stdin. This prints one line:
#   ░▒▓ ᓚᘏᗢ rocheverse:~$ <model> · ctx █████░░░░░ 42% · $<cost> · <stamp> ▓▒░  [ <n> open ] █
# The ░▒▓ dither is the soft scanline edge of the screen. ᓚᘏᗢ is the pixel leopard. Context fills
# a 10-block bar. The open-items count sits in its own accent chip, and the cursor block is accent too.
# Each part shows only when the data is there. Open items come from the never-ask-twice file.
# Colours and words come from your style.json (see STYLE.md): palette.hero is the ground,
# palette.paper the type, palette.wine the dither edge, palette.gold the prompt and the low-context
# warning, palette.accent the chip and cursor (palette.ink type), lines.stamp the badge, and
# lines.magazine (or your style's name) the prompt. No style.json means the bundled Rocha Coded look.
# Plain mode (NO_COLOR=1) prints: ᓚᘏᗢ <model> · ctx █████░░░░░ 42% · $<cost> · <n> open · <stamp>
#
# Settings: OPEN_ITEMS_FILE (default ~/.claude/OPEN_ITEMS.md), NO_COLOR=1 for plain text,
#           PINK_TERMINAL_GLYPH=pixel|emoji|ascii (ᓚᘏᗢ, 🐆 or =^.^=; PINK_TERMINAL_ASCII=1 still means ascii),
#           ROCHA_CODED_STYLE=<file>
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
s_hero="" s_paper="" s_accent="" s_ink="" s_gold="" s_wine="" stamp="" s_mag="" s_name=""
if [ -n "$style" ]; then
  if command -v jq >/dev/null 2>&1; then
    IFS=$'\x1f' read -r s_hero s_paper s_accent s_ink s_gold s_wine stamp s_mag s_name < <(jq -r '[(.palette.hero // ""),
      (.palette.paper // ""), (.palette.accent // ""), (.palette.ink // ""), (.palette.gold // ""), (.palette.wine // ""),
      (.lines.stamp // ""), (.lines.magazine // ""), (.name // "")] | map(tostring) | join("\u001f")' "$style" 2>/dev/null)
  else
    IFS=$'\x1f' read -r s_hero s_paper s_accent s_ink s_gold s_wine stamp s_mag s_name < <(python3 -c '
import json, sys
try: d = json.load(open(sys.argv[1]))
except Exception: d = {}
p, l = d.get("palette") or {}, d.get("lines") or {}
print("\x1f".join(str(x or "") for x in [p.get("hero"), p.get("paper"), p.get("accent"), p.get("ink"), p.get("gold"), p.get("wine"),
                                  l.get("stamp"), l.get("magazine"), d.get("name")]))' "$style" 2>/dev/null)
  fi
fi
rgb() { # $1 hex, $2 fallback hex -> "r;g;b"
  local h="$1"; case "$h" in \#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]) ;; *) h="$2" ;; esac
  printf '%d;%d;%d' "0x${h:1:2}" "0x${h:3:2}" "0x${h:5:2}"
}
GROUND=$(rgb "$s_hero" "#50163C"); PAPER=$(rgb "$s_paper" "#FFF7F4"); ACC=$(rgb "$s_accent" "#FE9DCA")
INK=$(rgb "$s_ink" "#3B1230"); GOLD=$(rgb "$s_gold" "#E9B949"); WINE=$(rgb "$s_wine" "#682047")
# The prompt name: lines.magazine, else your style's name, lowercased with dashes. Never borrowed from Rocha's.
world=$(printf '%s' "${s_mag:-${s_name:-you}}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//; s/-*$//')

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

glyph_mode="${PINK_TERMINAL_GLYPH:-pixel}"; [ "${PINK_TERMINAL_ASCII:-0}" = "1" ] && glyph_mode="ascii"
case "$glyph_mode" in emoji) glyph="🐆" ;; ascii) glyph="=^.^=" ;; *) glyph="ᓚᘏᗢ" ;; esac
bar=""
if [ -n "$ctx" ]; then   # ten blocks, one per 10% of context used
  filled=$(( (ctx + 5) / 10 )); [ "$filled" -gt 10 ] && filled=10; [ "$filled" -lt 0 ] && filled=0
  i=0; while [ "$i" -lt 10 ]; do if [ "$i" -lt "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi; i=$((i + 1)); done
fi
parts=()
[ -n "${model:-}" ] && parts+=("$model")
[ -n "$ctx" ] && parts+=("ctx $bar ${ctx}%")
[ -n "$money" ] && parts+=("$money")
[ -n "$open" ] && parts+=("$open open")
[ -n "$stamp" ] && parts+=("$stamp")
line=""
for p in "${parts[@]}"; do line="${line:+$line · }$p"; done

if [ -n "${NO_COLOR:-}" ]; then
  printf '%s %s\n' "$glyph" "$line"
else
  main=""
  for p in "${parts[@]}"; do [ "$p" = "$open open" ] && continue; main="${main:+$main · }$p"; done
  R="\033[0m"
  EDGE_IN="\033[38;2;${WINE}m░▒\033[38;2;${GROUND}m▓"            # dither from the desk into the screen
  EDGE_OUT="\033[38;2;${GROUND}m▓\033[38;2;${WINE}m▒░"
  SCREEN="\033[48;2;${GROUND}m"
  TYPE="\033[38;2;${PAPER}m"
  [ -n "$ctx" ] && [ "$ctx" -ge 80 ] 2>/dev/null && TYPE="\033[38;2;${GOLD}m"   # gold when context runs low
  PROMPT="\033[38;2;${GOLD}m${world}:~\$"
  ITEMS=""
  [ -n "$open" ] && [ "$open" != "0" ] && ITEMS=" \033[48;2;${ACC}m\033[38;2;${INK}m\033[1m ${open} open ${R}"
  CURSOR=" \033[38;2;${ACC}m█${R}"
  printf '%b%b %b%s %b %b%s %b%b%b%b\n' "$EDGE_IN" "$SCREEN" "\033[38;2;${GOLD}m" "$glyph" "$PROMPT" "$TYPE" "$main" "$R" "$EDGE_OUT$R" "$ITEMS" "$CURSOR"
fi
