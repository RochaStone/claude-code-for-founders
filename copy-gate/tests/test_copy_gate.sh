#!/usr/bin/env bash
# Tests the copy-gate skills (shape and scrub) and the installer, in a throwaway CLAUDE_DIR.
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d "${TMPDIR:-/tmp}/cg-test.XXXXXX"); trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
check(){ if eval "$2"; then echo "  ok   $1"; PASS=$((PASS+1)); else echo "  FAIL $1"; FAIL=$((FAIL+1)); fi; }
echo "copy-gate"

for s in interview-me humanizer fact-checker claims-verify prompt-master; do
  f="$HERE/skills/$s/SKILL.md"
  check "$s: frontmatter name matches its folder" "sed -n '2p' '$f' | grep -qx 'name: $s'"
  check "$s: has a description" "sed -n '3p' '$f' | grep -q '^description: '"
done
check "grill-me is renamed everywhere" "! grep -rqi 'grill' '$HERE/skills' '$HERE/install.sh'"
check "no brand or private references in the skills" "! grep -rqiE 'thriving|rocha|/Users/|memory/|\\.claude/projects' '$HERE/skills'"

mkdir -p "$T/claude/skills/humanizer"; echo "my own humanizer" > "$T/claude/skills/humanizer/SKILL.md"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" > "$T/log" 2>&1
check "install links the skills" "[ -L '$T/claude/skills/interview-me' ] && [ -f '$T/claude/skills/interview-me/SKILL.md' ]"
check "install never overwrites your own same-named skill" "grep -q 'my own humanizer' '$T/claude/skills/humanizer/SKILL.md' && grep -q 'skipped humanizer' '$T/log'"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --force > "$T/log" 2>&1
check "--force backs yours up, then installs" "ls -d '$T/claude/skills/'humanizer.backup-* >/dev/null 2>&1 && [ -L '$T/claude/skills/humanizer' ]"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --copy > "$T/log" 2>&1
check "--copy replaces the links with real folders" "[ -d '$T/claude/skills/fact-checker' ] && [ ! -L '$T/claude/skills/fact-checker' ]"
mkdir -p "$T/claude/skills/other"
CLAUDE_DIR="$T/claude" bash "$HERE/install.sh" --uninstall > "$T/log" 2>&1
check "uninstall removes only this kit's skills" "[ ! -e '$T/claude/skills/fact-checker' ] && [ -d '$T/claude/skills/other' ] && ls -d '$T/claude/skills/'humanizer.backup-* >/dev/null 2>&1"

echo "copy-gate: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
