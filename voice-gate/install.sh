#!/usr/bin/env bash
# install.sh: installs the voice gate (two hooks) into Claude Code.
#
#   ./install.sh               copy the hooks, create voice-gate.json from the example (only if
#                              you have none), register both hooks in ~/.claude/settings.json
#   ./install.sh --uninstall   remove both hooks from settings.json (your config and voice file stay)
#
# settings.json is backed up before any change, and a broken settings.json is never touched.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
MERGE="$SRC/../scripts/claude-settings-merge.py"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
DEST="$CLAUDE_DIR/founders-kit/voice-gate"

command -v python3 >/dev/null 2>&1 || { echo "this installer needs python3. On a Mac: xcode-select --install" >&2; exit 1; }

if [ "${1:-}" = "--uninstall" ]; then
  python3 "$MERGE" remove-hook --settings "$SETTINGS" --contains "founders-kit/voice-gate/"
  echo "Your config is untouched: $DEST/voice-gate.json"
  exit 0
fi

mkdir -p "$DEST"
cp "$SRC/voice-gate.sh" "$SRC/voice-sentinel.sh" "$SRC/voice_gate_core.py" "$SRC/voice.example.md" "$DEST/"
chmod +x "$DEST/voice-gate.sh" "$DEST/voice-sentinel.sh"
if [ -f "$DEST/voice-gate.json" ]; then
  echo "kept your config: $DEST/voice-gate.json"
else
  cp "$SRC/voice-gate.json.example" "$DEST/voice-gate.json"
  echo "created config: $DEST/voice-gate.json (set voice_file and guarded_paths)"
fi

python3 "$MERGE" add-hook --settings "$SETTINGS" --event PreToolUse --matcher "Write|Edit|MultiEdit" \
  --command "bash $(printf '%q' "$DEST/voice-gate.sh")" --timeout 10
python3 "$MERGE" add-hook --settings "$SETTINGS" --event PostToolUse --matcher "Read" \
  --command "bash $(printf '%q' "$DEST/voice-sentinel.sh")" --timeout 10

cat <<NEXT

Next:
  1. Write your voice file. Start from $DEST/voice.example.md and save it where voice_file points.
  2. Edit guarded_paths in $DEST/voice-gate.json to match where your copy lives.
  3. Start a new Claude Code session. Hooks load when a session starts.
NEXT
