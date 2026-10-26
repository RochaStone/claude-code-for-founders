#!/usr/bin/env bash
# Tests the script templates on throwaway repos, the deploy guard hook, and the installer.
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d "${TMPDIR:-/tmp}/std-test.XXXXXX"); trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
check(){ if eval "$2"; then echo "  ok   $1"; PASS=$((PASS+1)); else echo "  FAIL $1"; FAIL=$((FAIL+1)); fi; }
echo "standards"
g() { git -C "$P" -c core.hooksPath=/dev/null "$@"; }

P="$T/app"; mkdir -p "$P/src"
g init -q 2>/dev/null; g config user.email t@example.com; g config user.name t
bash "$HERE/install.sh" "$P" > "$T/log" 2>&1
check "install adds CLAUDE.md and both scripts" "[ -f '$P/CLAUDE.md' ] && [ -x '$P/scripts/security-check.sh' ] && [ -x '$P/scripts/verify-quality.sh' ]"
printf '.env\nnode_modules/\n' > "$P/.gitignore"
printf 'export function hi() {\n  return 1\n}\n' > "$P/src/app.js"
printf '#!/usr/bin/env bash\necho ok\n' > "$P/scripts/dev.sh"
printf '{"name":"x"}\n' > "$P/config.json"
g add -A; g commit -qm init

"$P/scripts/security-check.sh" > "$T/out" 2>&1; rc=$?
check "security-check passes on a clean repo" "[ $rc -eq 0 ] && grep -q 'SECURITY CHECK PASSED' '$T/out'"
"$P/scripts/verify-quality.sh" > "$T/out" 2>&1; rc=$?
check "verify-quality passes on a clean repo" "[ $rc -eq 0 ] && grep -q 'QUALITY CHECK PASSED' '$T/out'"

# Plant a fake live key (assembled at runtime so this test file never holds one).
printf 'const KEY = "%s%s"\n' "sk_li" "ve_abcdefghijklmnopqrstuvwx" > "$P/src/pay.js"; g add -A
"$P/scripts/security-check.sh" > "$T/out" 2>&1; rc=$?
check "security-check blocks a live key shape" "[ $rc -eq 1 ] && grep -q 'key or token shapes found' '$T/out'"
git -C "$P" rm -q --cached src/pay.js; rm "$P/src/pay.js"

echo 'SECRET=1' > "$P/.env.production"; g add -f .env.production
"$P/scripts/security-check.sh" > "$T/out" 2>&1; rc=$?
check "security-check blocks a tracked .env file" "[ $rc -eq 1 ] && grep -q 'env files tracked' '$T/out'"
git -C "$P" rm -q --cached .env.production; rm "$P/.env.production"

printf 'try { go() } catch (e) {}\n' > "$P/src/bad.js"; g add -A
"$P/scripts/security-check.sh" > "$T/out" 2>&1; rc=$?
check "security-check blocks an empty catch block" "[ $rc -eq 1 ] && grep -q 'errors swallowed' '$T/out'"
git -C "$P" rm -q --cached src/bad.js; rm "$P/src/bad.js"

printf 'try:\n    go()\nexcept Exception:\n    pass\n' > "$P/src/bad.py"; g add -A
"$P/scripts/security-check.sh" > "$T/out" 2>&1; rc=$?
check "security-check blocks a bare except-pass" "[ $rc -eq 1 ] && grep -q 'errors swallowed' '$T/out'"
git -C "$P" rm -q --cached src/bad.py; rm "$P/src/bad.py"

printf '#!/usr/bin/env bash\nif then fi\n' > "$P/scripts/broken.sh"; g add -A
"$P/scripts/verify-quality.sh" > "$T/out" 2>&1; rc=$?
check "verify-quality fails on a shell syntax error" "[ $rc -eq 1 ] && grep -q 'broken.sh' '$T/out'"
git -C "$P" rm -q --cached scripts/broken.sh; rm "$P/scripts/broken.sh"

printf 'export const a = 1\nconsole.log(a)\n' > "$P/src/noisy.js"; g add -A
"$P/scripts/verify-quality.sh" > "$T/out" 2>&1; rc=$?
check "verify-quality fails on console.log in app code" "[ $rc -eq 1 ] && grep -q 'console.log left' '$T/out'"

bash "$HERE/install.sh" "$P" > "$T/log" 2>&1
check "re-install keeps your files and parks the template beside CLAUDE.md" "grep -q 'kept yours' '$T/log' && [ -f '$P/CLAUDE.standards.md' ]"

# Deploy guard: reminder on deploy commands, silence on everything else.
out=$(printf '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' | bash "$HERE/deploy-guard.sh")
check "deploy guard adds context before git push" "printf '%s' \"\$out\" | python3 -c 'import json,sys;h=json.load(sys.stdin)[\"hookSpecificOutput\"];assert h[\"hookEventName\"]==\"PreToolUse\";assert \"DEPLOY GUARD\" in h[\"additionalContext\"]'"
out=$(printf '{"tool_name":"Bash","tool_input":{"command":"npx vercel --prod"}}' | bash "$HERE/deploy-guard.sh")
check "deploy guard catches vercel --prod" "printf '%s' \"\$out\" | grep -q 'DEPLOY GUARD'"
out=$(printf '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' | bash "$HERE/deploy-guard.sh")
check "deploy guard is silent on ordinary commands" "[ -z \"\$out\" ]"
check "deploy guard never denies" "! grep -q 'permissionDecision' '$HERE/deploy-guard.sh'"

mkdir -p "$T/claude"; echo '{}' > "$T/claude/settings.json"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --deploy-guard >/dev/null 2>&1
check "--deploy-guard registers a PreToolUse Bash hook" "python3 -c \"import json;d=json.load(open('$T/claude/settings.json'));assert d['hooks']['PreToolUse'][0]['matcher']=='Bash'\""
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --uninstall-deploy-guard >/dev/null 2>&1
check "--uninstall-deploy-guard removes it" "python3 -c \"import json;d=json.load(open('$T/claude/settings.json'));assert 'hooks' not in d\""

echo "standards: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
