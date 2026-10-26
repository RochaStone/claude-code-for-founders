#!/usr/bin/env bash
# Runs every piece's tests. Each test uses throwaway folders and never touches your real ~/.claude.
set -u
cd "$(dirname "$0")/.." || exit 1
failed=0
for t in goal-tests/tests/test_runner.sh never-ask-twice/tests/test_never_ask_twice.sh \
         voice-gate/tests/test_voice_gate.sh copy-gate/tests/test_copy_gate.sh \
         standards/tests/test_standards.sh pink-terminal/tests/test_pink_terminal.sh; do
  echo
  bash "$t" || failed=$((failed + 1))
done
echo
if [ "$failed" -eq 0 ]; then echo "ALL TESTS PASSED (6 suites)"; exit 0; fi
echo "$failed suite(s) failed"; exit 1
