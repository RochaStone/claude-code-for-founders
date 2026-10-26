#!/usr/bin/env bash
# install.sh: installs the never-ask-twice SessionStart hook.
#
#   ./install.sh               copy the hook, create ~/.claude/OPEN_ITEMS.md from the template
#                              (only if you have none), register the hook in ~/.claude/settings.json
#   ./install.sh --uninstall   remove the hook from settings.json (your OPEN_ITEMS.md stays)
#
# settings.json is backed up before any change, and a broken settings.json is never touched.
# The CLAUDE.md part is yours to paste: see CLAUDE.md.snippet.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
MERGE="$SRC/../scripts/claude-settings-merge.py"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
DEST="$CLAUDE_DIR/founders-kit/never-ask-twice"
ITEMS="${OPEN_ITEMS_FILE:-$CLAUDE_DIR/OPEN_ITEMS.md}"

command -v python3 >/dev/null 2>&1 || { echo "this installer needs python3. On a Mac: xcode-select --install" >&2; exit 1; }

if [ "${1:-}" = "--uninstall" ]; then
  python3 "$MERGE" remove-hook --settings "$SETTINGS" --contains "founders-kit/never-ask-twice/session-start.sh"
  echo "Your OPEN_ITEMS.md is untouched: $ITEMS"
  exit 0
fi

mkdir -p "$DEST"
cp "$SRC/session-start.sh" "$SRC/PROTOCOL.md" "$DEST/"
chmod +x "$DEST/session-start.sh"
echo "hook copied to $DEST"

if [ -f "$ITEMS" ]; then
  echo "kept your open items file: $ITEMS"
else
  mkdir -p "$(dirname "$ITEMS")"
  cp "$SRC/templates/OPEN_ITEMS.md" "$ITEMS"
  echo "created $ITEMS from the template (the three sample items are fiction: replace them)"
fi

cmd="OPEN_ITEMS_FILE=$(printf '%q' "$ITEMS") bash $(printf '%q' "$DEST/session-start.sh")"
python3 "$MERGE" add-hook --settings "$SETTINGS" --event SessionStart --command "$cmd" --timeout 10

cat <<NEXT

Last step, by hand: paste never-ask-twice/CLAUDE.md.snippet into $CLAUDE_DIR/CLAUDE.md.
Then start a new Claude Code session. The first thing it sees is your open items.
NEXT
