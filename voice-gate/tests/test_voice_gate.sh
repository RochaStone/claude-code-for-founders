#!/usr/bin/env bash
# Simulates Claude Code hook calls: a blocked write, a Read of the voice file, then an allowed write.
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d "${TMPDIR:-/tmp}/vg-test.XXXXXX"); trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
check(){ if eval "$2"; then echo "  ok   $1"; PASS=$((PASS+1)); else echo "  FAIL $1"; FAIL=$((FAIL+1)); fi; }
echo "voice-gate"

export VOICE_GATE_RUN_DIR="$T/run" VOICE_GATE_CONFIG="$T/voice-gate.json"
mkdir -p "$T/brand" "$T/site/copy" "$T/site/src"
printf '# My voice\n## How I sound\nWarm and certain.\n' > "$T/brand/voice.md"
cat > "$T/voice-gate.json" <<JSON
{ "voice_file": "$T/brand/voice.md",
  "guarded_paths": ["**/copy/**", "**/*.email.md", "**/landing/**"],
  "ignore_paths": ["**/*.bak"] }
JSON

hook() { # $1 script  $2 session  $3 tool  $4 path
  printf '{"session_id":"%s","hook_event_name":"x","tool_name":"%s","cwd":"%s","tool_input":{"file_path":"%s","content":"hi"}}' \
    "$2" "$3" "$T" "$4" | bash "$HERE/$1"
}
decision() { python3 -c 'import json,sys; s=sys.stdin.read().strip(); print(json.loads(s)["hookSpecificOutput"]["permissionDecision"] if s else "allow")'; }

out=$(hook voice-gate.sh s1 Write "$T/site/copy/home.md")
check "write to a copy path before reading the voice: denied" "[ \"\$(printf '%s' \"\$out\" | decision)\" = deny ]"
check "the deny is valid PreToolUse hook JSON with a reason" "printf '%s' \"\$out\" | python3 -c 'import json,sys;h=json.load(sys.stdin)[\"hookSpecificOutput\"];assert h[\"hookEventName\"]==\"PreToolUse\";assert \"voice.md\" in h[\"permissionDecisionReason\"]'"
check "*.email.md is guarded" "[ \"\$(hook voice-gate.sh s1 Edit "$T/site/welcome.email.md" | decision)\" = deny ]"
check "a code file passes straight through" "[ \"\$(hook voice-gate.sh s1 Write "$T/site/src/app.js" | decision)\" = allow ]"
check "an ignored path passes" "[ \"\$(hook voice-gate.sh s1 Write "$T/site/copy/old.bak" | decision)\" = allow ]"
check "writing the voice file itself is always allowed" "[ \"\$(hook voice-gate.sh s1 Write "$T/brand/voice.md" | decision)\" = allow ]"

hook voice-sentinel.sh s1 Read "$T/site/src/app.js" >/dev/null
check "reading some other file does not open the gate" "[ \"\$(hook voice-gate.sh s1 Write "$T/site/copy/home.md" | decision)\" = deny ]"

out=$(hook voice-sentinel.sh s1 Read "$T/brand/voice.md"); rc=$?
check "the sentinel is silent and exits 0" "[ $rc -eq 0 ] && [ -z \"\$out\" ]"
check "the sentinel records the read for this session" "[ -f '$T/run/s1' ]"
check "after reading the voice: the same write is allowed" "[ \"\$(hook voice-gate.sh s1 Write "$T/site/copy/home.md" | decision)\" = allow ]"
check "a different session is still blocked" "[ \"\$(hook voice-gate.sh s2 Write "$T/site/copy/home.md" | decision)\" = deny ]"

hook voice-sentinel.sh "../../evil" Read "$T/brand/voice.md" >/dev/null
check "a hostile session id cannot write outside the run folder" "[ ! -e '$T/evil' ] && [ -f '$T/run/evil' ]"

rm -f "$T/brand/voice.md"
out=$(hook voice-gate.sh s3 Write "$T/site/copy/home.md")
check "a missing voice file says how to create it" "printf '%s' \"\$out\" | grep -q 'does not exist yet'"

out=$(echo 'not json' | bash "$HERE/voice-gate.sh"); rc=$?
check "garbage input fails open (allowed, exit 0)" "[ $rc -eq 0 ] && [ -z \"\$out\" ]"
out=$(VOICE_GATE_CONFIG="$T/none.json" hook voice-gate.sh s1 Write "$T/site/copy/home.md")
check "no config means no gate" "[ -z \"\$out\" ]"

# Installer: two hooks, backup, idempotent, uninstall.
mkdir -p "$T/claude"; echo '{"theme":"light"}' > "$T/claude/settings.json"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" >/dev/null 2>&1
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" >/dev/null 2>&1
check "install registers PreToolUse Write|Edit|MultiEdit and PostToolUse Read, once each" "python3 -c \"import json;d=json.load(open('$T/claude/settings.json'));h=d['hooks'];assert len(h['PreToolUse'])==1 and h['PreToolUse'][0]['matcher']=='Write|Edit|MultiEdit';assert len(h['PostToolUse'])==1 and h['PostToolUse'][0]['matcher']=='Read';assert d['theme']=='light'\""
check "install creates voice-gate.json and keeps a backup" "[ -f '$T/claude/founders-kit/voice-gate/voice-gate.json' ] && ls '$T/claude/'settings.json.backup-* >/dev/null 2>&1"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --uninstall >/dev/null 2>&1
check "uninstall removes both hooks" "python3 -c \"import json;d=json.load(open('$T/claude/settings.json'));assert 'hooks' not in d\""

check "voice.example.md is a blank template with the five headings" "[ \$(grep -c '^## ' '$HERE/voice.example.md') -eq 5 ]"

echo "voice-gate: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
