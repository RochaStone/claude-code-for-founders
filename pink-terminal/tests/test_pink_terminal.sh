#!/usr/bin/env bash
# Tests the status line on sample Claude Code JSON, the theme files, and the installer.
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d "${TMPDIR:-/tmp}/pt-test.XXXXXX"); trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
check(){ if eval "$2"; then echo "  ok   $1"; PASS=$((PASS+1)); else echo "  FAIL $1"; FAIL=$((FAIL+1)); fi; }
echo "pink-terminal"
ITEMS="$HERE/../never-ask-twice/templates/OPEN_ITEMS.md"
sl() { printf '%s' "$1" | OPEN_ITEMS_FILE="$ITEMS" NO_COLOR=1 bash "$HERE/statusline.sh"; }

out=$(sl '{"model":{"display_name":"Opus"},"cost":{"total_cost_usd":0.4213},"context_window":{"used_percentage":42.4}}')
check "full JSON: model, context, cost and open count" "[ \"\$out\" = '🐆 Opus · ctx 42% · \$0.42 · 3 open' ]"
out=$(sl '{"model":{"display_name":"Sonnet"},"context_window":{"used_percentage":12}}')
check "missing cost: no empty slot, fields stay in place" "[ \"\$out\" = '🐆 Sonnet · ctx 12% · 3 open' ]"
out=$(sl '{"model":{"display_name":"Opus"},"context_window":{"total_input_tokens":50000,"context_window_size":200000}}')
check "context worked out from token counts when no percentage" "printf '%s' \"\$out\" | grep -q 'ctx 25%'"
out=$(printf '{}' | OPEN_ITEMS_FILE="$T/none.md" NO_COLOR=1 PINK_TERMINAL_ASCII=1 bash "$HERE/statusline.sh")
check "empty JSON and no items file: just the glyph, ASCII mode" "[ \"\$out\" = '=^.^= ' ]"
out=$(printf '{"model":{"display_name":"Opus"}}' | OPEN_ITEMS_FILE="$T/none.md" bash "$HERE/statusline.sh")
check "colour mode uses hot pink truecolor" "printf '%s' \"\$out\" | grep -q '255;45;138'"
out=$(printf 'garbage' | NO_COLOR=1 bash "$HERE/statusline.sh"); rc=$?
check "garbage input never breaks the line" "[ $rc -eq 0 ]"

if command -v plutil >/dev/null 2>&1; then
  check "iTerm2 theme passes plutil -lint" "plutil -lint '$HERE/themes/rocha-coded.itermcolors' >/dev/null"
fi
check "iTerm2 theme defines all 16 ANSI colours" "[ \$(grep -c '<key>Ansi [0-9]* Color</key>' '$HERE/themes/rocha-coded.itermcolors') -eq 16 ]"
check "Ghostty theme: 16 palette lines plus background and foreground" "[ \$(grep -cE '^palette = ([0-9]|1[0-5])=#[0-9A-F]{6}$' '$HERE/themes/rocha-coded.ghostty') -eq 16 ] && grep -q '^background = #FFE1EC$' '$HERE/themes/rocha-coded.ghostty'"
check "Warp theme parses with 8 normal and 8 bright colours" "ruby -ryaml -e 'd=YAML.load_file(ARGV[0]); exit(d[\"terminal_colors\"][\"normal\"].size==8 && d[\"terminal_colors\"][\"bright\"].size==8 && d[\"background\"]==\"#FFE1EC\" ? 0 : 1)' '$HERE/themes/rocha-coded.yaml' 2>/dev/null || python3 -c 'import yaml,sys;d=yaml.safe_load(open(sys.argv[1]));assert len(d[\"terminal_colors\"][\"normal\"])==8' '$HERE/themes/rocha-coded.yaml'"
check "wallpaper.svg is well-formed XML with the headline" "python3 -c 'import xml.dom.minidom,sys;xml.dom.minidom.parse(sys.argv[1])' '$HERE/wallpaper.svg' && grep -q 'WOMAN SHOW' '$HERE/wallpaper.svg'"

mkdir -p "$T/claude"; echo '{"statusLine":{"type":"command","command":"echo old"}}' > "$T/claude/settings.json"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" > "$T/log" 2>&1
check "install replaces the old status line and keeps it in a backup" "grep -q 'founders-kit/pink-terminal/statusline.sh' '$T/claude/settings.json' && grep -q 'echo old' '$T/claude/'settings.json.backup-*"
cmd=$(python3 -c "import json;print(json.load(open('$T/claude/settings.json'))['statusLine']['command'])")
check "the registered command runs" "printf '{\"model\":{\"display_name\":\"Opus\"}}' | NO_COLOR=1 bash -c \"\$cmd\" | grep -q 'Opus'"
CLAUDE_DIR="$T/claude" GHOSTTY_THEMES_DIR="$T/gh" WARP_THEMES_DIR="$T/warp" bash "$HERE/install.sh" --themes > "$T/log" 2>&1
check "--themes copies Ghostty and Warp themes" "[ -f '$T/gh/rocha-coded' ] && [ -f '$T/warp/rocha-coded.yaml' ]"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --uninstall > "$T/log" 2>&1
check "uninstall removes the status line" "! grep -q statusLine '$T/claude/settings.json'"

echo "pink-terminal: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
