#!/usr/bin/env bash
# install.sh: makes Claude Code and your terminal pink.
#
#   ./install.sh                     set the pink status line in ~/.claude/settings.json
#   ./install.sh --themes            also copy the Ghostty and Warp themes into place (iTerm2 is one double-click)
#   ./install.sh --wallpaper [WxH]   render the wallpaper to ~/Pictures/one-woman-show.png (default 2560x1600, needs Google Chrome)
#   ./install.sh --uninstall         remove the status line (only if it is this one)
#
# settings.json is backed up first. If you already had a status line, it is replaced and kept in the backup.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
MERGE="$SRC/../scripts/claude-settings-merge.py"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
DEST="$CLAUDE_DIR/founders-kit/pink-terminal"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
STATUS=1; THEMES=0; WALL=""

while [ $# -gt 0 ]; do
  case "$1" in
    --themes) THEMES=1; shift ;;
    --wallpaper) STATUS=0; WALL="2560x1600"; shift
                 if [[ "${1:-}" =~ ^[0-9]{3,5}x[0-9]{3,5}$ ]]; then WALL="$1"; shift; fi ;;
    --uninstall) python3 "$MERGE" remove-statusline --settings "$SETTINGS" --contains "founders-kit/pink-terminal/statusline.sh"; exit 0 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

if [ -n "$WALL" ]; then
  if [ ! -x "$CHROME" ]; then CHROME=$(command -v google-chrome || command -v chromium || true); fi
  [ -n "$CHROME" ] || { echo "needs Google Chrome to render. Or open wallpaper.svg in a browser and screenshot it." >&2; exit 1; }
  W=${WALL%x*}; H=${WALL#*x}
  OUT="${WALLPAPER_OUT:-$HOME/Pictures/one-woman-show.png}"
  mkdir -p "$(dirname "$OUT")"
  TMPD=$(mktemp -d); trap 'rm -rf "$TMPD"' EXIT
  # Inline (not <img>) so the SVG can load its Google Fonts. Other screen shapes get hot pink margins.
  { printf '<!doctype html><meta charset="utf-8"><style>html,body{margin:0;background:#FF2D8A;overflow:hidden}svg{width:100vw;height:100vh;display:block}</style>'
    cat "$SRC/wallpaper.svg"; } > "$TMPD/w.html"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size="$W,$H" --virtual-time-budget=8000 --screenshot="$OUT" "file://$TMPD/w.html" >/dev/null 2>&1
  [ -s "$OUT" ] || { echo "render failed" >&2; exit 1; }
  echo "wallpaper saved: $OUT"
  echo "Set it: System Settings > Wallpaper > Add Photo, or right-click the file > Set Desktop Picture."
  exit 0
fi

if [ "$STATUS" -eq 1 ]; then
  command -v python3 >/dev/null 2>&1 || { echo "needs python3. On a Mac: xcode-select --install" >&2; exit 1; }
  mkdir -p "$DEST"; cp "$SRC/statusline.sh" "$DEST/"; chmod +x "$DEST/statusline.sh"
  items="${OPEN_ITEMS_FILE:-$CLAUDE_DIR/OPEN_ITEMS.md}"
  cmd="OPEN_ITEMS_FILE=$(printf '%q' "$items") bash $(printf '%q' "$DEST/statusline.sh")"
  python3 "$MERGE" set-statusline --settings "$SETTINGS" --command "$cmd"
  [ -f "$items" ] || echo "no open items file yet at $items, so the count stays hidden until you add one (see never-ask-twice)"
fi

if [ "$THEMES" -eq 1 ]; then
  GH="${GHOSTTY_THEMES_DIR:-$HOME/.config/ghostty/themes}"
  WARP="${WARP_THEMES_DIR:-$HOME/.warp/themes}"
  mkdir -p "$GH" && cp "$SRC/themes/rocha-coded.ghostty" "$GH/rocha-coded" && echo "Ghostty: add 'theme = rocha-coded' to ~/.config/ghostty/config"
  mkdir -p "$WARP" && cp "$SRC/themes/rocha-coded.yaml" "$WARP/rocha-coded.yaml" && echo "Warp: Settings > Appearance > Themes > Rocha Coded"
  echo "iTerm2: double-click themes/rocha-coded.itermcolors, then Settings > Profiles > Colors > Color Presets > rocha-coded"
fi
echo "Start a new Claude Code session to see the status line."
