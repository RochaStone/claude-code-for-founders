#!/usr/bin/env bash
# voice-gate.sh: Claude Code PreToolUse hook for Write, Edit and MultiEdit.
# Denies a write to a copy surface (paths in voice-gate.json) until this session has Read your
# voice file. Unlocking costs one Read. Code, configs and everything else pass straight through.
# Input: hook JSON on stdin. Output: a permission decision JSON when it blocks, nothing when it allows.
HERE="$(cd "$(dirname "$0")" && pwd)"
command -v python3 >/dev/null 2>&1 || exit 0
VOICE_GATE_INPUT="$(cat)" python3 "$HERE/voice_gate_core.py" gate
exit 0
