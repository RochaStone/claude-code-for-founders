#!/usr/bin/env bash
# install.sh: installs goal tests and schedules a daily sweep.
#
#   ./install.sh                     install to ~/.claude/goal-tests, sweep daily at 08:00
#   ./install.sh --time 07:30        pick the time (24 hour clock, your computer's time zone)
#   ./install.sh --no-schedule       install only, no daily job
#   ./install.sh --print-plist       show the macOS launchd job it would create, change nothing
#   ./install.sh --uninstall         remove the daily job (your probes and ledger stay)
#
# macOS gets a launchd agent (it catches up after the laptop wakes). Linux gets one crontab line.
# Re-running is safe: files are refreshed, your config, probes and ledger are never overwritten.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
DEST="${GOAL_TESTS_HOME:-$CLAUDE_DIR/goal-tests}"
LABEL="com.rochacoded.goal-tests"
AGENTS_DIR="${LAUNCH_AGENTS_DIR:-$HOME/Library/LaunchAgents}"
PLIST="$AGENTS_DIR/$LABEL.plist"
MARK="# goal-tests (claude-code-for-founders)"
TIME="08:00"; SCHEDULE=1; PRINT_PLIST=0; UNINSTALL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --time) TIME="${2:-}"; shift 2 ;;
    --no-schedule) SCHEDULE=0; shift ;;
    --print-plist) PRINT_PLIST=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

if ! [[ "$TIME" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
  echo "--time must look like 07:50 (24 hour clock)" >&2; exit 2
fi
HOUR=$((10#${TIME%%:*})); MIN=$((10#${TIME##*:}))

plist() {
cat <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$DEST/goals-runner.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>$HOUR</integer>
    <key>Minute</key><integer>$MIN</integer>
  </dict>
  <key>StandardOutPath</key><string>$DEST/launchd.out</string>
  <key>StandardErrorPath</key><string>$DEST/launchd.err</string>
  <key>RunAtLoad</key><false/>
</dict>
</plist>
PLIST
}

if [ "$PRINT_PLIST" -eq 1 ]; then plist; exit 0; fi

unschedule() {
  if [ "$(uname -s)" = "Darwin" ]; then
    if [ -f "$PLIST" ]; then
      [ "${GOAL_TESTS_NO_LAUNCHCTL:-0}" = "1" ] || launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
      rm -f "$PLIST"; echo "removed daily job: $PLIST"
    fi
  elif command -v crontab >/dev/null 2>&1; then
    current=$(crontab -l 2>/dev/null || true)
    if printf '%s\n' "$current" | grep -qF "$MARK"; then
      printf '%s\n' "$current" | grep -vF "$MARK" | crontab -
      echo "removed daily crontab line"
    fi
  fi
}

if [ "$UNINSTALL" -eq 1 ]; then
  unschedule
  echo "Your probes, config and ledger are still in $DEST. Delete that folder yourself if you want them gone."
  exit 0
fi

command -v python3 >/dev/null 2>&1 || { echo "goal tests need python3. On a Mac: xcode-select --install" >&2; exit 1; }

mkdir -p "$DEST/goals" "$DEST/examples" "$DEST/lib" "$DEST/notify"
cp "$SRC/goals-runner.sh" "$SRC/CONTRACT.md" "$DEST/"
cp "$SRC/lib/ledger.py" "$DEST/lib/"
cp "$SRC/notify/"* "$DEST/notify/"
cp "$SRC/examples/"*.sh "$DEST/examples/"
chmod +x "$DEST/goals-runner.sh" "$DEST/notify/"* "$DEST/examples/"*.sh
if [ ! -f "$DEST/goal-tests.config.json" ]; then
  cp "$SRC/goal-tests.config.example.json" "$DEST/goal-tests.config.json"
  echo "created config: $DEST/goal-tests.config.json (edit it)"
else
  echo "kept your config: $DEST/goal-tests.config.json"
fi
echo "installed runner to $DEST"

if [ "$SCHEDULE" -eq 1 ]; then
  unschedule >/dev/null
  if [ "$(uname -s)" = "Darwin" ]; then
    mkdir -p "$AGENTS_DIR"
    plist > "$PLIST"
    plutil -lint "$PLIST" >/dev/null || { echo "generated plist did not validate: $PLIST" >&2; exit 1; }
    [ "${GOAL_TESTS_NO_LAUNCHCTL:-0}" = "1" ] || launchctl bootstrap "gui/$(id -u)" "$PLIST"
    echo "daily sweep scheduled at $TIME (launchd: $PLIST)"
  elif command -v crontab >/dev/null 2>&1; then
    line="$MIN $HOUR * * * /bin/bash \"$DEST/goals-runner.sh\" >> \"$DEST/cron.out\" 2>&1 $MARK"
    { crontab -l 2>/dev/null | grep -vF "$MARK" || true; echo "$line"; } | crontab -
    echo "daily sweep scheduled at $TIME (crontab)"
  else
    echo "no launchd or crontab found. Run $DEST/goals-runner.sh yourself, or schedule it your own way."
  fi
fi

cat <<NEXT

Next:
  1. Copy a probe from $DEST/examples into $DEST/goals and edit its URL.
  2. Run one sweep now:  bash "$DEST/goals-runner.sh"
  3. Read CONTRACT.md before you write your own. Probes look, they never touch.
NEXT
