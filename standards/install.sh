#!/usr/bin/env bash
# install.sh: puts the standards into a project, and optionally turns on the deploy guard.
#
#   ./install.sh ~/Projects/my-app        add CLAUDE.md, scripts/security-check.sh and
#                                          scripts/verify-quality.sh to that project
#   ./install.sh --deploy-guard           register the deploy reminder hook in ~/.claude/settings.json
#   ./install.sh --uninstall-deploy-guard remove it again
#
# Nothing you already have is overwritten. If the project has a CLAUDE.md, the template is saved
# next to it as CLAUDE.standards.md for you (or Claude) to merge by hand.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
MERGE="$SRC/../scripts/claude-settings-merge.py"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
DEST="$CLAUDE_DIR/founders-kit/standards"

case "${1:-}" in
  ""|-h|--help) sed -n '2,11p' "$0"; exit 0 ;;
  --deploy-guard)
    command -v python3 >/dev/null 2>&1 || { echo "needs python3" >&2; exit 1; }
    mkdir -p "$DEST"; cp "$SRC/deploy-guard.sh" "$DEST/"; chmod +x "$DEST/deploy-guard.sh"
    python3 "$MERGE" add-hook --settings "$SETTINGS" --event PreToolUse --matcher "Bash" \
      --command "bash $(printf '%q' "$DEST/deploy-guard.sh")" --timeout 10
    echo "Deploy guard on. It starts with your next Claude Code session."
    exit 0 ;;
  --uninstall-deploy-guard)
    python3 "$MERGE" remove-hook --settings "$SETTINGS" --contains "founders-kit/standards/deploy-guard.sh"
    exit 0 ;;
esac

PROJECT="$1"
[ -d "$PROJECT" ] || { echo "not a folder: $PROJECT" >&2; exit 2; }
PROJECT="$(cd "$PROJECT" && pwd)"
mkdir -p "$PROJECT/scripts"
place() { # $1 source  $2 target  $3 executable?
  if [ -e "$2" ]; then echo "kept yours: $2"; return; fi
  cp "$1" "$2"; [ "${3:-}" = x ] && chmod +x "$2"; echo "added: $2"
}
place "$SRC/security-check.sh.template" "$PROJECT/scripts/security-check.sh" x
place "$SRC/verify-quality.sh.template" "$PROJECT/scripts/verify-quality.sh" x
if [ -e "$PROJECT/CLAUDE.md" ]; then
  place "$SRC/CLAUDE.md.template" "$PROJECT/CLAUDE.standards.md"
  echo "your CLAUDE.md exists: merge CLAUDE.standards.md into it, then delete CLAUDE.standards.md"
else
  place "$SRC/CLAUDE.md.template" "$PROJECT/CLAUDE.md"
fi
echo
echo "Try them now:  cd \"$PROJECT\" && ./scripts/security-check.sh && ./scripts/verify-quality.sh"
