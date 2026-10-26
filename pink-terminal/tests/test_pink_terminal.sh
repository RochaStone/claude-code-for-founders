#!/usr/bin/env bash
# Tests the status line on sample Claude Code JSON, the theme files, and the installer.
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d "${TMPDIR:-/tmp}/pt-test.XXXXXX"); trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
check(){ if eval "$2"; then echo "  ok   $1"; PASS=$((PASS+1)); else echo "  FAIL $1"; FAIL=$((FAIL+1)); fi; }
echo "pink-terminal"
ITEMS="$HERE/../never-ask-twice/templates/OPEN_ITEMS.md"
export ROCHA_CODED_STYLE="$HERE/../examples/style.rocha-coded.json"   # your own style.json never changes the results
sl() { printf '%s' "$1" | OPEN_ITEMS_FILE="$ITEMS" NO_COLOR=1 bash "$HERE/statusline.sh"; }

out=$(sl '{"model":{"display_name":"Opus"},"cost":{"total_cost_usd":0.4213},"context_window":{"used_percentage":42.4}}')
check "full JSON: model, context, cost and open count" "[ \"\$out\" = '🐆 Opus · ctx 42% · \$0.42 · 3 open · LORE' ]"
out=$(sl '{"model":{"display_name":"Sonnet"},"context_window":{"used_percentage":12}}')
check "missing cost: no empty slot, fields stay in place" "[ \"\$out\" = '🐆 Sonnet · ctx 12% · 3 open · LORE' ]"
out=$(sl '{"model":{"display_name":"Opus"},"context_window":{"total_input_tokens":50000,"context_window_size":200000}}')
check "context worked out from token counts when no percentage" "printf '%s' \"\$out\" | grep -q 'ctx 25%'"
printf '{"lines":{"stamp":""}}' > "$T/nostamp.json"
out=$(printf '{}' | ROCHA_CODED_STYLE="$T/nostamp.json" OPEN_ITEMS_FILE="$T/none.md" NO_COLOR=1 PINK_TERMINAL_ASCII=1 bash "$HERE/statusline.sh")
check "empty JSON and no items file: just the glyph, ASCII mode" "[ \"\$out\" = '=^.^= ' ]"
out=$(printf '{"model":{"display_name":"Opus"}}' | OPEN_ITEMS_FILE="$T/none.md" bash "$HERE/statusline.sh")
check "colour mode uses hot pink truecolor" "printf '%s' \"\$out\" | grep -q '255;45;138'"
out=$(printf 'garbage' | NO_COLOR=1 bash "$HERE/statusline.sh"); rc=$?
check "garbage input never breaks the line" "[ $rc -eq 0 ]"

# Make it yours: a second palette changes the status line, the themes and the wallpaper.
cat > "$T/style.json" <<'JSON'
{ "name": "Ocean Desk", "palette": { "hero": "#0077B6", "accent": "#90E0EF", "paper": "#FFFFFF", "paper_pink": "#E6F4F9",
  "ink": "#03045E", "marker": "#D62828", "plum": "#023E8A", "gold": "#F4A261", "cool": "#CAF0F8" },
  "lines": { "headline": "SEA YOU AT THE SUMMIT", "scrawl": "salt water heals", "stamp": "TIDE", "masthead": "THE HARBOUR POST", "affirm": "calm seas ahead" } }
JSON
out=$(printf '{"model":{"display_name":"Opus"},"workspace":{"current_dir":"%s"}}' "$T" | ROCHA_CODED_STYLE= OPEN_ITEMS_FILE="$T/none.md" bash "$HERE/statusline.sh")
check "./style.json in the session folder sets the colours and stamp" "printf '%s' \"\$out\" | grep -q '0;119;182' && printf '%s' \"\$out\" | grep -q 'TIDE'"
printf '{"palette":{"hero":"pink","ink":"#12"}}' > "$T/bad.json"
out=$(printf '{"model":{"display_name":"Opus"}}' | ROCHA_CODED_STYLE="$T/bad.json" OPEN_ITEMS_FILE="$T/none.md" bash "$HERE/statusline.sh")
check "malformed colours fall back to the bundled look" "printf '%s' \"\$out\" | grep -q '255;45;138'"
python3 "$HERE/themes/make-themes.py" --style "$T/style.json" --out "$T/themes" > /dev/null
check "generator writes all three themes named after the style" "[ -f '$T/themes/ocean-desk.itermcolors' ] && [ -f '$T/themes/ocean-desk.ghostty' ] && [ -f '$T/themes/ocean-desk.yaml' ]"
if command -v plutil >/dev/null 2>&1; then
  check "generated iTerm2 plist from a second palette is lint-clean" "plutil -lint '$T/themes/ocean-desk.itermcolors' >/dev/null"
fi
check "generated plist is valid for Python's plist reader too" "python3 -c 'import plistlib,sys; d=plistlib.load(open(sys.argv[1],\"rb\")); assert len([k for k in d if k.startswith(\"Ansi \")])==16; assert abs(d[\"Background Color\"][\"Blue Component\"]-0xF9/255)<1e-6' '$T/themes/ocean-desk.itermcolors'"
check "generated Ghostty and Warp themes carry the new palette" "grep -q '^background = #E6F4F9$' '$T/themes/ocean-desk.ghostty' && grep -q \"background: '#E6F4F9'\" '$T/themes/ocean-desk.yaml'"
python3 "$HERE/themes/make-themes.py" --style "$HERE/../examples/style.rocha-coded.json" --out "$T/rc" > /dev/null
check "the shipped themes are exactly the generator's output for Rocha's style" "cmp -s '$T/rc/rocha-coded.itermcolors' '$HERE/themes/rocha-coded.itermcolors' && cmp -s '$T/rc/rocha-coded.ghostty' '$HERE/themes/rocha-coded.ghostty' && cmp -s '$T/rc/rocha-coded.yaml' '$HERE/themes/rocha-coded.yaml'"
python3 "$HERE/make-wallpaper.py" --style "$T/style.json" --out "$T/wall.svg" > /dev/null
check "wallpaper from a second style uses its words and colours" "python3 -c 'import xml.dom.minidom,sys;xml.dom.minidom.parse(sys.argv[1])' '$T/wall.svg' && grep -q 'TIDE' '$T/wall.svg' && grep -q '#0077B6' '$T/wall.svg' && grep -q 'salt water heals' '$T/wall.svg'"
python3 "$HERE/make-wallpaper.py" --style "$HERE/../examples/style.rocha-coded.json" --out "$T/rc.svg" > /dev/null
# Inheritance rule: a user file borrows only missing palette colours and fonts, never her words.
printf '{"name":"","palette":{"hero":"#123456"},"lines":{}}' > "$T/partial.json"
check "loader: missing colours and fonts fall back, words and identity never do" "python3 -c '
import sys; sys.path.insert(0, sys.argv[1])
from rocha_style import load_style
s, _ = load_style(sys.argv[2])
assert s[\"palette\"][\"hero\"] == \"#123456\"
assert s[\"palette\"][\"ink\"] == \"#111111\" and s[\"fonts\"][\"masthead\"] == \"Playfair Display\"
assert not s.get(\"lines\") and not s.get(\"name\")
for k in (\"owner\", \"handle\", \"references\", \"notes\", \"site\"): assert k not in s, k
' '$HERE' '$T/partial.json'"
python3 "$HERE/make-wallpaper.py" --style "$T/partial.json" --out "$T/partial.svg" > /dev/null
check "wallpaper for a user without lines shows YOUR WORDS HERE, none of hers" "grep -q 'YOUR WORDS HERE' '$T/partial.svg' && ! grep -qiE 'founder world|rocheverse|lore|works out' '$T/partial.svg' && grep -q '#123456' '$T/partial.svg'"
python3 "$HERE/themes/make-themes.py" --style "$T/partial.json" --out "$T/pt" > /dev/null
check "themes for an unnamed user style are not named after hers" "[ -f '$T/pt/my-style.itermcolors' ] && ! ls '$T/pt' | grep -q rocha"
out=$(printf '{"model":{"display_name":"Opus"}}' | ROCHA_CODED_STYLE="$T/partial.json" OPEN_ITEMS_FILE="$T/none.md" NO_COLOR=1 bash "$HERE/statusline.sh")
check "status line for a user without a stamp shows no stamp, never hers" "[ \"\$out\" = '🐆 Opus' ]"
check "the shipped wallpaper.svg is the generator's output for Rocha's style" "cmp -s '$T/rc.svg' '$HERE/wallpaper.svg'"

if command -v plutil >/dev/null 2>&1; then
  check "iTerm2 theme passes plutil -lint" "plutil -lint '$HERE/themes/rocha-coded.itermcolors' >/dev/null"
fi
check "iTerm2 theme defines all 16 ANSI colours" "[ \$(grep -c '<key>Ansi [0-9]* Color</key>' '$HERE/themes/rocha-coded.itermcolors') -eq 16 ]"
check "Ghostty theme: 16 palette lines plus background and foreground" "[ \$(grep -cE '^palette = ([0-9]|1[0-5])=#[0-9A-F]{6}$' '$HERE/themes/rocha-coded.ghostty') -eq 16 ] && grep -q '^background = #FFE1EC$' '$HERE/themes/rocha-coded.ghostty'"
check "Warp theme parses with 8 normal and 8 bright colours" "ruby -ryaml -e 'd=YAML.load_file(ARGV[0]); exit(d[\"terminal_colors\"][\"normal\"].size==8 && d[\"terminal_colors\"][\"bright\"].size==8 && d[\"background\"]==\"#FFE1EC\" ? 0 : 1)' '$HERE/themes/rocha-coded.yaml' 2>/dev/null || python3 -c 'import yaml,sys;d=yaml.safe_load(open(sys.argv[1]));assert len(d[\"terminal_colors\"][\"normal\"])==8' '$HERE/themes/rocha-coded.yaml'"
check "wallpaper.svg is well-formed XML with her headline" "python3 -c 'import xml.dom.minidom,sys;xml.dom.minidom.parse(sys.argv[1])' '$HERE/wallpaper.svg' && grep -q 'FOUNDER WORLD' '$HERE/wallpaper.svg'"

mkdir -p "$T/claude"; echo '{"statusLine":{"type":"command","command":"echo old"}}' > "$T/claude/settings.json"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" > "$T/log" 2>&1
check "install copies the fallback style next to the status line" "[ -f '$T/claude/founders-kit/pink-terminal/style.rocha-coded.json' ]"
check "install replaces the old status line and keeps it in a backup" "grep -q 'founders-kit/pink-terminal/statusline.sh' '$T/claude/settings.json' && grep -q 'echo old' '$T/claude/'settings.json.backup-*"
cmd=$(python3 -c "import json;print(json.load(open('$T/claude/settings.json'))['statusLine']['command'])")
check "the registered command runs" "printf '{\"model\":{\"display_name\":\"Opus\"}}' | NO_COLOR=1 bash -c \"\$cmd\" | grep -q 'Opus'"
CLAUDE_DIR="$T/claude" GHOSTTY_THEMES_DIR="$T/gh" WARP_THEMES_DIR="$T/warp" bash "$HERE/install.sh" --themes > "$T/log" 2>&1
check "--themes copies Ghostty and Warp themes" "[ -f '$T/gh/rocha-coded' ] && [ -f '$T/warp/rocha-coded.yaml' ]"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --uninstall > "$T/log" 2>&1
check "uninstall removes the status line" "! grep -q statusLine '$T/claude/settings.json'"

echo "pink-terminal: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
