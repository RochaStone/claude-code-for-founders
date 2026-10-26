#!/usr/bin/env bash
# Tests for the session-start hook and the installer. Uses a throwaway CLAUDE_DIR.
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d "${TMPDIR:-/tmp}/nat-test.XXXXXX"); trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
check(){ if eval "$2"; then echo "  ok   $1"; PASS=$((PASS+1)); else echo "  FAIL $1"; FAIL=$((FAIL+1)); fi; }
echo "never-ask-twice"

out=$(OPEN_ITEMS_FILE="$HERE/templates/OPEN_ITEMS.md" bash "$HERE/session-start.sh")
check "hook counts 3 open items in the template" "printf '%s' \"\$out\" | grep -q '3 open, 0 parked'"
check "hook shows owner and default" "printf '%s' \"\$out\" | grep -q '#2 \[ME\] Decide the price.*default: Keep it in drafts'"
check "hook keeps the block compact (under 1KB)" "[ \${#out} -lt 1024 ]"

cat > "$T/items.md" <<'MD'
## Open
| # | Item | Owner | Default | Raised |
|---|---|---|---|---|
| 9 | A | CLAUDE | do A | x |
| 8 | B | ME | wait | x |
## Parked
| # | Item | Parked on | Why |
|---|---|---|---|
| 7 | C | x | leave it |
## Done
| # | Item | Closed on | How |
|---|---|---|---|
| 6 | D | x | done |
MD
out=$(OPEN_ITEMS_FILE="$T/items.md" OPEN_ITEMS_MAX=1 bash "$HERE/session-start.sh")
check "parked and done items are not shown as open" "printf '%s' \"\$out\" | grep -q '2 open, 1 parked' && ! printf '%s' \"\$out\" | grep -q '#7'"
check "the max setting caps the list and says how many more" "printf '%s' \"\$out\" | grep -q '+1 more'"
out=$(OPEN_ITEMS_FILE="$T/missing.md" bash "$HERE/session-start.sh"); rc=$?
check "a missing file prints one line and exits 0" "[ $rc -eq 0 ] && printf '%s' \"\$out\" | grep -q 'none yet'"

# Installer: existing settings are kept, backed up, and the hook is added once.
mkdir -p "$T/claude"
echo '{"model":"opus","hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"echo mine"}]}]}}' > "$T/claude/settings.json"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" > "$T/log" 2>&1
check "install exits 0" "[ $? -eq 0 ]"
check "install writes a backup first" "ls '$T/claude/'settings.json.backup-* >/dev/null 2>&1"
check "install keeps your other settings and hooks" "python3 -c \"import json;d=json.load(open('$T/claude/settings.json'));assert d['model']=='opus';assert d['hooks']['PreToolUse'][0]['hooks'][0]['command']=='echo mine'\""
check "install registers one SessionStart hook" "python3 -c \"import json;d=json.load(open('$T/claude/settings.json'));assert len(d['hooks']['SessionStart'])==1\""
check "install creates OPEN_ITEMS.md from the template" "[ -f '$T/claude/OPEN_ITEMS.md' ]"
cmd=$(python3 -c "import json;print(json.load(open('$T/claude/settings.json'))['hooks']['SessionStart'][0]['hooks'][0]['command'])")
check "the registered command runs and prints the block" "bash -c \"\$cmd\" | grep -q 'OPEN ITEMS: 3 open'"
echo "my own list" > "$T/claude/OPEN_ITEMS.md"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" > "$T/log" 2>&1
check "re-install is idempotent (still one hook)" "python3 -c \"import json;d=json.load(open('$T/claude/settings.json'));assert len(d['hooks']['SessionStart'])==1\""
check "re-install never overwrites your OPEN_ITEMS.md" "grep -q 'my own list' '$T/claude/OPEN_ITEMS.md'"
echo '{ broken json' > "$T/claude/settings.json"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" > "$T/log" 2>&1; rc=$?
check "a broken settings.json is refused and left exactly as it was" "[ $rc -ne 0 ] && grep -q '{ broken json' '$T/claude/settings.json'"
echo '{}' > "$T/claude/settings.json"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" >/dev/null 2>&1
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --uninstall >/dev/null 2>&1
check "uninstall removes the hook" "python3 -c \"import json;d=json.load(open('$T/claude/settings.json'));assert 'hooks' not in d\""

echo "never-ask-twice: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
