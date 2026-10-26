#!/usr/bin/env bash
# Tests for goals-runner.sh. Runs in a throwaway folder. Touches nothing in your real ~/.claude.
#   bash goal-tests/tests/test_runner.sh
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d "${TMPDIR:-/tmp}/gt-test.XXXXXX")
trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
ok()   { echo "  ok   $1"; PASS=$((PASS+1)); }
bad()  { echo "  FAIL $1"; FAIL=$((FAIL+1)); }
check(){ if eval "$2"; then ok "$1"; else bad "$1"; fi; }
jget() { python3 -c "import json,sys; d=json.load(open('$T/gt/ledger.json')); print($1)"; }

echo "goal-tests: runner"

# Install into the throwaway folder (no schedule), exactly as a user would.
GOAL_TESTS_HOME="$T/gt" bash "$HERE/install.sh" --no-schedule >/dev/null 2>&1
check "install copies the runner, notifiers and examples" "[ -x '$T/gt/goals-runner.sh' ] && [ -f '$T/gt/notify/smtp.py' ] && [ -f '$T/gt/examples/site-is-up.sh' ]"
check "install creates a config from the example" "[ -f '$T/gt/goal-tests.config.json' ]"

# A git repo for 'what changed since last pass'.
REPO="$T/my-site"
mkdir -p "$REPO" && git -C "$REPO" init -q && git -C "$REPO" config core.hooksPath /dev/null && git -C "$REPO" config user.email t@example.com && git -C "$REPO" config user.name t
echo one > "$REPO/a.txt" && git -C "$REPO" add a.txt && git -C "$REPO" commit -qm "first version" && sleep 1

cat > "$T/gt/goal-tests.config.json" <<JSON
{ "goals_dir": "goals", "timeout_seconds": 3, "watch_repos": [], "offline_check_url": "",
  "notify": { "channels": ["stdout"] } }
JSON

cat > "$T/gt/goals/always-green.sh" <<'P'
#!/usr/bin/env bash
# GOAL: the always green probe passes
# BUILD: -
echo OK
P
cat > "$T/gt/goals/flaky.sh" <<P
#!/usr/bin/env bash
# GOAL: the fake page still says Book a call
# BUILD: $REPO
[ -f "$T/broken" ] && { echo 'FAIL: page no longer says "Book a call"'; exit 1; }
echo OK
P

run() { bash "$T/gt/goals-runner.sh" > "$T/out.txt" 2>&1; echo $? > "$T/rc.txt"; }
notices() { grep -c "GOAL TESTS NOTICE" "$T/out.txt" || true; }

# Run 1: both green. First ever run, nothing broke, so no notice.
run
check "run 1: exit 0 when all green" "[ \$(cat '$T/rc.txt') -eq 0 ]"
check "run 1: no notice when nothing changed" "[ \$(notices) -eq 0 ]"
check "run 1: ledger failing set is empty" "[ \"\$(jget 'len(d[\"failing\"])')\" = 0 ]"
check "run 1: ledger records last_pass for flaky" "[ -n \"\$(jget 'd[\"probes\"][\"flaky\"][\"last_pass\"]')\" ]"

# A commit lands after the last pass, then the page breaks.
sleep 1
echo two > "$REPO/a.txt" && git -C "$REPO" commit -qam "new hero section"
touch "$T/broken"

# Run 2: flaky fails. The failing set changed, so exactly one notice, with what changed.
run
check "run 2: exit 1 when a probe fails" "[ \$(cat '$T/rc.txt') -eq 1 ]"
check "run 2: exactly one notice" "[ \$(notices) -eq 1 ]"
check "run 2: notice names the broken probe" "grep -q 'BROKEN: flaky' '$T/out.txt'"
check "run 2: notice carries the GOAL line" "grep -q 'goal: the fake page still says Book a call' '$T/out.txt'"
check "run 2: notice shows the commit since last pass" "grep -q 'new hero section' '$T/out.txt'"
check "run 2: notice does not show the commit before last pass" "! grep -q 'first version' '$T/out.txt'"
check "run 2: ledger failing set is [flaky]" "[ \"\$(jget 'd[\"failing\"]')\" = \"['flaky']\" ]"
check "run 2: ledger keeps the failure detail" "[ \"\$(jget 'd[\"probes\"][\"flaky\"][\"rc\"]')\" = 1 ]"

# Run 3: still broken. Same failing set, so NO new notice (no alert fatigue).
run
check "run 3: still exit 1" "[ \$(cat '$T/rc.txt') -eq 1 ]"
check "run 3: no repeat notice for a persisting break" "[ \$(notices) -eq 0 ]"
check "run 3: fail streak counts up to 2" "[ \"\$(jget 'd[\"probes\"][\"flaky\"][\"fail_streak\"]')\" = 2 ]"

# Run 4: fixed. Recovery is a change, so one notice.
rm -f "$T/broken"
run
check "run 4: exit 0 after the fix" "[ \$(cat '$T/rc.txt') -eq 0 ]"
check "run 4: one recovery notice" "[ \$(notices) -eq 1 ] && grep -q 'recovered: flaky' '$T/out.txt'"
check "run 4: ledger failing set empty again" "[ \"\$(jget 'len(d[\"failing\"])')\" = 0 ]"

# Run 5: green and unchanged. Silence.
run
check "run 5: no notice when still green" "[ \$(notices) -eq 0 ]"
check "ledger keeps a run history" "[ \"\$(jget 'len(d[\"runs\"])')\" = 5 ]"

# A probe that hangs is killed at the deadline and counts as broken (exit 124).
cat > "$T/gt/goals/hangs.sh" <<'P'
#!/usr/bin/env bash
# GOAL: a probe that never finishes
# BUILD: -
sleep 30
P
start=$(date +%s); run; took=$(( $(date +%s) - start ))
check "a hanging probe is killed near the deadline (took ${took}s)" "[ $took -lt 10 ]"
check "a hanging probe is recorded as exit 124" "[ \"\$(jget 'd[\"probes\"][\"hangs\"][\"rc\"]')\" = 124 ]"
check "a new hang is a change, so it notifies" "[ \$(notices) -eq 1 ] && grep -q 'BROKEN: hangs' '$T/out.txt'"
rm -f "$T/gt/goals/hangs.sh"

# Deleting a broken probe is not a recovery: no notice, and it leaves the ledger.
run
check "a removed probe leaves the ledger" "[ \"\$(jget '\"hangs\" in d[\"probes\"]')\" = False ]"
check "a removed probe does not send a recovery notice" "[ \$(notices) -eq 0 ]"

# Offline guard: an unreachable check URL skips the sweep and marks nothing broken.
touch "$T/broken"
cat > "$T/gt/goal-tests.config.json" <<JSON
{ "goals_dir": "goals", "timeout_seconds": 3, "offline_check_url": "http://127.0.0.1:9/",
  "notify": { "channels": ["stdout"] } }
JSON
GOAL_TESTS_RETRY_WAIT=0 bash "$T/gt/goals-runner.sh" > "$T/out.txt" 2>&1; rc=$?
check "offline: exit 0 and says skipped" "[ $rc -eq 0 ] && grep -q 'skipped: offline' '$T/out.txt'"
check "offline: failing set untouched" "[ \"\$(jget 'len(d[\"failing\"])')\" = 0 ] && [ -n \"\$(jget 'd[\"last_skipped\"][\"at\"]')\" ]"

# An env file readable by others is refused (secrets stay owner-only).
echo 'GT_SECRET=hello' > "$T/gt/secrets.env"; chmod 644 "$T/gt/secrets.env"
cat > "$T/gt/goal-tests.config.json" <<JSON
{ "goals_dir": "goals", "timeout_seconds": 3, "notify": { "channels": ["stdout"] } }
JSON
bash "$T/gt/goals-runner.sh" > "$T/out.txt" 2>&1
check "a world readable secrets.env is skipped with a fix" "grep -q 'chmod 600' '$T/out.txt'"

# The three example probes carry the header contract.
for p in site-is-up form-endpoint-answers page-still-says; do
  check "example $p has # GOAL: and # BUILD:" "grep -q '^# GOAL: ' '$HERE/examples/$p.sh' && grep -q '^# BUILD: ' '$HERE/examples/$p.sh'"
done
check "no example probe sends data (no POST, PUT or DELETE)" "! grep -qE -- '-X (POST|PUT|DELETE)|--data' '$HERE'/examples/*.sh"

# The plist the installer writes is valid (macOS only).
if command -v plutil >/dev/null 2>&1; then
  GOAL_TESTS_HOME="$T/gt" bash "$HERE/install.sh" --print-plist --time 07:50 > "$T/job.plist"
  check "launchd plist passes plutil -lint" "plutil -lint '$T/job.plist' >/dev/null"
  check "launchd plist is set for 07:50" "grep -q '<integer>7</integer>' '$T/job.plist' && grep -q '<integer>50</integer>' '$T/job.plist'"
fi
check "install rejects a bad time" "! bash '$HERE/install.sh' --print-plist --time 25:99 >/dev/null 2>&1"

echo "goal-tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
