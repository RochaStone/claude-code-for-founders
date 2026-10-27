#!/usr/bin/env bash
# Quality gate for this repo: every script parses, JSON parses, the plist lints, no em dashes,
# no file over 500 lines, and every suite of tests passes.
set -u
cd "$(dirname "$0")/.." || exit 1
FAIL=0
ok()  { echo "  ✓ $1"; }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
echo "=== Quality check ==="

broken=""
for f in $(find . -name '*.sh' -not -path './.git/*' -not -path './dist/*') standards/*.sh.template; do
  bash -n "$f" 2>/dev/null || broken="$broken $f"
done
[ -z "$broken" ] && ok "every shell script parses" || bad "shell syntax errors:$broken"

pybad=""
for f in $(find . -name '*.py' -not -path './.git/*'); do python3 -m py_compile "$f" 2>/dev/null || pybad="$pybad $f"; done
find . -name '__pycache__' -not -path './.git/*' -prune -exec rm -rf {} +
[ -z "$pybad" ] && ok "every Python file compiles" || bad "Python errors:$pybad"

jbad=""
for f in $(find . \( -name '*.json' -o -name '*.json.example' \) -not -path './.git/*'); do python3 -m json.tool "$f" >/dev/null 2>&1 || jbad="$jbad $f"; done
[ -z "$jbad" ] && ok "every JSON file parses" || bad "invalid JSON:$jbad"

if command -v plutil >/dev/null 2>&1; then
  plutil -lint pink-terminal/themes/rocha-coded.itermcolors >/dev/null && ok "iTerm2 theme plist lints" || bad "iTerm2 plist invalid"
fi

EM=$(printf '\342\200\224'); EN=$(printf '\342\200\223')
dashes=$(grep -rIl -e "$EM" -e "$EN" --exclude-dir=.git --exclude-dir=dist . 2>/dev/null)
[ -z "$dashes" ] && ok "no em or en dashes anywhere" || bad "dashes found in: $dashes"

long=$(find . -type f \( -name '*.sh' -o -name '*.py' -o -name '*.md' -o -name '*.html' \) -not -path './.git/*' -exec awk 'END { if (NR > 500) print FILENAME " (" NR " lines)" }' {} \;)
[ -z "$long" ] && ok "no file over 500 lines" || bad "files over 500 lines: $long"

big=$(find docs/img -name '*.svg' -size +2k 2>/dev/null)
[ -z "$big" ] && ok "pixel badges and dividers are under 2 KB each" || bad "README pixel images over 2 KB: $big"

TLOG=$(mktemp "${TMPDIR:-/tmp}/ccff-tests.XXXXXX")
if ./scripts/run-tests.sh > "$TLOG" 2>&1; then ok "all test suites pass"; else bad "tests failed:"; tail -20 "$TLOG"; fi
rm -f "$TLOG"

echo "=== $FAIL failed ==="
[ "$FAIL" -eq 0 ] && { echo "QUALITY CHECK PASSED"; exit 0; } || { echo "QUALITY CHECK FAILED"; exit 1; }
