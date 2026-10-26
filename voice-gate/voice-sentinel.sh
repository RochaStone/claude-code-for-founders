#!/usr/bin/env bash
# voice-sentinel.sh: Claude Code PostToolUse hook for Read.
# When the file Claude just read is your voice file, it records that for this session,
# which opens the voice gate. Never blocks anything. Always exits 0.
HERE="$(cd "$(dirname "$0")" && pwd)"
command -v python3 >/dev/null 2>&1 || exit 0
VOICE_GATE_INPUT="$(cat)" python3 "$HERE/voice_gate_core.py" sentinel
exit 0
