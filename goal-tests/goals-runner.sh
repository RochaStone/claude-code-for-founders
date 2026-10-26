#!/usr/bin/env bash
# goals-runner.sh: replays every probe in goals/*.sh and tells you only when something changes.
#
# The probe contract (full text in CONTRACT.md):
#   # GOAL:  <one line: what this proves still works>
#   # BUILD: <path to the git repo behind it, or ->
#   exit 0 = still works. Anything else = broken. Keep the printed detail to one short line.
#   Probes are READ-ONLY. They never deploy, push, send, buy or change anything.
#
# What a sweep does:
#   1. Optional offline guard: if offline_check_url is set and unreachable, the sweep is skipped,
#      not failed. Nothing is recorded as broken when the wifi is down.
#   2. Runs each probe with a wall clock limit (timeout_seconds, default 90). Slow = broken (exit 124).
#   3. Updates ledger.json: status, last pass, last fail, streak, run history.
#   4. Notifies ONLY when the failing set changes: something new broke, or something recovered.
#      A notice for a new break includes what changed since it last passed (git log of the
#      probe's BUILD repo and every repo in watch_repos).
#
# Usage: goals-runner.sh [--config PATH]
#        GOAL_TESTS_CONFIG=PATH goals-runner.sh
# Exit: 0 all green (or skipped offline), 1 at least one probe broken, 2 setup problem.
set -u
PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

GT_HOME="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${GOAL_TESTS_CONFIG:-$GT_HOME/goal-tests.config.json}"
if [ "${1:-}" = "--config" ] && [ -n "${2:-}" ]; then CONFIG="$2"; fi
LEDGER_PY="$GT_HOME/lib/ledger.py"

command -v python3 >/dev/null 2>&1 || { echo "goal-tests needs python3" >&2; exit 2; }
[ -f "$LEDGER_PY" ] || { echo "missing $LEDGER_PY" >&2; exit 2; }

cfg_vars=$(python3 "$LEDGER_PY" config "$CONFIG" "$GT_HOME") || { echo "could not read config: $CONFIG" >&2; exit 2; }
GOALS_DIR="" DEADLINE=90 OFFLINE_URL="" ENV_FILE="" LEDGER="" LOG=""
eval "$cfg_vars"

log() { echo "[$(date '+%F %T')] $*" >> "$LOG"; }

# Secrets for probes or notifiers live in an owner-only env file, never in the config.
if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  mode=$(stat -f '%Lp' "$ENV_FILE" 2>/dev/null || stat -c '%a' "$ENV_FILE" 2>/dev/null)
  case "$mode" in
    600|400) set -a; # shellcheck disable=SC1090
             . "$ENV_FILE"; set +a ;;
    *) echo "skipping $ENV_FILE: mode $mode is readable by others. Fix with: chmod 600 \"$ENV_FILE\"" >&2
       log "env file skipped, mode $mode" ;;
  esac
fi

STATE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/goal-tests.XXXXXX")
trap 'rm -rf "$STATE_DIR"' EXIT

# ── Offline guard ──────────────────────────────────────────────────────────
if [ -n "$OFFLINE_URL" ]; then
  online=0
  for attempt in 1 2 3; do
    if curl -sS --max-time 8 -o /dev/null "$OFFLINE_URL" 2>/dev/null; then online=1; break; fi
    log "network unreachable (attempt $attempt of 3)"
    [ "$attempt" -lt 3 ] && sleep "${GOAL_TESTS_RETRY_WAIT:-15}"
  done
  if [ "$online" -ne 1 ]; then
    python3 "$LEDGER_PY" skip "$LEDGER" "offline: $OFFLINE_URL unreachable"
    log "sweep SKIPPED: offline. Probes unknown, not failed."
    echo "Sweep skipped: offline. Nothing was marked broken."
    exit 0
  fi
fi

# ── Run one probe with a wall clock limit ──────────────────────────────────
run_probe() { # $1 script -> sets RC and OUT
  local script="$1" out_f pid start
  out_f="$STATE_DIR/out.$$.$RANDOM"
  (cd "$GT_HOME" && exec bash "$script") > "$out_f" 2>&1 &
  pid=$!
  start=$(date +%s)
  while kill -0 "$pid" 2>/dev/null; do
    if [ $(( $(date +%s) - start )) -ge "$DEADLINE" ]; then
      pkill -9 -P "$pid" 2>/dev/null
      kill -9 "$pid" 2>/dev/null
      wait "$pid" 2>/dev/null
      RC=124
      OUT="killed: took longer than ${DEADLINE}s. $(head -c 200 "$out_f" | tr '\t\n\r' '   ')"
      return
    fi
    sleep 1
  done
  wait "$pid"; RC=$?
  OUT=$(head -c 300 "$out_f" | tr '\t\n\r' '   ' | sed 's/ *$//')
  [ -z "$OUT" ] && OUT="(no output)"
}

# ── Sweep ──────────────────────────────────────────────────────────────────
[ -d "$GOALS_DIR" ] || { echo "no goals folder yet: $GOALS_DIR (copy a probe from examples/ into it)"; exit 0; }
RESULTS="$STATE_DIR/results.tsv"
: > "$RESULTS"
count=0
for script in "$GOALS_DIR"/*.sh; do
  [ -f "$script" ] || continue
  name=$(basename "$script" .sh)
  goal=$(grep -m1 '^# GOAL:' "$script" | sed 's/^# GOAL: *//' | tr '\t' ' ')
  build=$(grep -m1 '^# BUILD:' "$script" | sed 's/^# BUILD: *//' | tr '\t' ' ')
  [ -z "$goal" ] && goal="(this probe has no # GOAL: line, see CONTRACT.md)"
  [ -z "$build" ] && build="-"
  run_probe "$script"
  printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$RC" "$goal" "$build" "$OUT" >> "$RESULTS"
  if [ "$RC" -eq 0 ]; then echo "PASS $name: $OUT"; log "PASS $name: $OUT"
  else echo "FAIL $name (exit $RC): $OUT"; log "FAIL $name rc=$RC: $OUT"; fi
  count=$((count + 1))
done
[ "$count" -eq 0 ] && { echo "no probes in $GOALS_DIR yet. Copy one from examples/ to start."; exit 0; }

NOTICE_DIR="$STATE_DIR/notice"
verdict=$(python3 "$LEDGER_PY" update "$CONFIG" "$LEDGER" "$RESULTS" "$NOTICE_DIR") || { echo "ledger update failed" >&2; exit 2; }
if [ "$verdict" = "CHANGED" ]; then
  bash "$GT_HOME/notify/notify.sh" "$(cat "$NOTICE_DIR/subject.txt")" "$NOTICE_DIR/body.txt" "$CONFIG"
  log "failing set changed, notice sent: $(cat "$NOTICE_DIR/subject.txt")"
fi

failing=$(awk -F'\t' '$2 != 0' "$RESULTS" | wc -l | tr -d ' ')
log "sweep complete: $count probes, $failing failing"
[ "$failing" -gt 0 ] && exit 1
exit 0
