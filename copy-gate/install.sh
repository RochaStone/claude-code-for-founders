#!/usr/bin/env bash
# install.sh: installs the five copy-gate skills into Claude Code.
#
#   ./install.sh              symlink each skill into ~/.claude/skills (a git pull updates them)
#   ./install.sh --copy       copy instead of symlink (keeps working if you delete this folder)
#   ./install.sh --force      if a skill with the same name exists, move it aside to a backup first
#   ./install.sh --zip        build one zip per skill in dist/copy-gate/ for Claude Cowork upload
#   ./install.sh --uninstall  remove only the skills this kit installed
#
# A skill folder you already have under the same name is never overwritten without --force.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)/skills"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
DEST="$CLAUDE_DIR/skills"
SKILLS="interview-me humanizer fact-checker claims-verify prompt-master"
MARK=".installed-by-claude-code-for-founders"
MODE=link; FORCE=0; ACTION=install

for arg in "$@"; do
  case "$arg" in
    --copy) MODE=copy ;;
    --force) FORCE=1 ;;
    --zip) ACTION=zip ;;
    --uninstall) ACTION=uninstall ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

ours() { # true if $1 was put there by this kit
  { [ -L "$1" ] && [ "$(readlink "$1")" = "$SRC/$(basename "$1")" ]; } || [ -f "$1/$MARK" ]
}

if [ "$ACTION" = zip ]; then
  OUT="$(cd "$SRC/../.." && pwd)/dist/copy-gate"
  mkdir -p "$OUT"
  for s in $SKILLS; do
    rm -f "$OUT/$s.zip"
    (cd "$SRC" && zip -qr "$OUT/$s.zip" "$s" -x "*.DS_Store")
    echo "built $OUT/$s.zip"
  done
  echo "Upload each zip in the Claude desktop app: Customize > Skills > + > Upload a skill."
  exit 0
fi

if [ "$ACTION" = uninstall ]; then
  for s in $SKILLS; do
    if [ -e "$DEST/$s" ] || [ -L "$DEST/$s" ]; then
      if ours "$DEST/$s"; then rm -rf "$DEST/$s"; echo "removed $s"; else echo "left $s alone (not installed by this kit)"; fi
    fi
  done
  exit 0
fi

mkdir -p "$DEST"
for s in $SKILLS; do
  target="$DEST/$s"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if ours "$target"; then
      rm -rf "$target"
    elif [ "$FORCE" -eq 1 ]; then
      backup="$target.backup-$(date +%Y%m%d-%H%M%S)"
      mv "$target" "$backup"; echo "moved your existing $s to $backup"
    else
      echo "skipped $s: you already have a skill with that name at $target (use --force to back it up and replace it)"
      continue
    fi
  fi
  if [ "$MODE" = copy ]; then
    cp -R "$SRC/$s" "$target"; touch "$target/$MARK"
  else
    ln -s "$SRC/$s" "$target"
  fi
  echo "installed $s ($MODE)"
done
cat <<NEXT

Start a new Claude Code session, then ask: "interview me before you write my launch email".
For claims-verify, copy skills/claims-verify/canon.example.md to $CLAUDE_DIR/canon.md and fill it in.
NEXT
