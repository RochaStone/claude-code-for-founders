#!/usr/bin/env python3
"""Shared logic for voice-gate.sh (PreToolUse) and voice-sentinel.sh (PostToolUse).

  voice_gate_core.py gate      reads hook JSON from $VOICE_GATE_INPUT, prints a deny decision or nothing
  voice_gate_core.py sentinel  reads hook JSON from $VOICE_GATE_INPUT, records "voice file was read"

Config: $VOICE_GATE_CONFIG, else voice-gate.json next to this file.
  voice_file      the file Claude must Read before writing copy
  guarded_paths   glob patterns for copy surfaces (** = any folders, * = anything but /)
  ignore_paths    optional glob patterns that are never gated
Fails open: if anything is missing or unreadable, the write is allowed. A broken gate must
never stop you working. It only ever blocks a guarded path when the voice file is unread.
"""
import json
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
RUN_DIR = os.environ.get("VOICE_GATE_RUN_DIR", os.path.join(HERE, "run"))


def glob_to_regex(pattern):
    pattern = os.path.expanduser(pattern)
    out, i = [], 0
    while i < len(pattern):
        if pattern.startswith("**/", i):
            out.append("(?:.*/)?")
            i += 3
        elif pattern.startswith("**", i):
            out.append(".*")
            i += 2
        elif pattern[i] == "*":
            out.append("[^/]*")
            i += 1
        elif pattern[i] == "?":
            out.append("[^/]")
            i += 1
        else:
            out.append(re.escape(pattern[i]))
            i += 1
    body = "".join(out)
    # A relative pattern can match anywhere in an absolute path.
    if not pattern.startswith("/"):
        body = "(?:.*/)?" + body
    return re.compile("^" + body + "$")


def matches(path, patterns):
    return any(glob_to_regex(p).match(path) for p in patterns or [])


def load_config():
    path = os.environ.get("VOICE_GATE_CONFIG", os.path.join(HERE, "voice-gate.json"))
    try:
        with open(path, encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, json.JSONDecodeError):
        return None


def read_input():
    try:
        return json.loads(os.environ.get("VOICE_GATE_INPUT", "") or "{}")
    except json.JSONDecodeError:
        return {}


def session_file(data):
    sid = re.sub(r"[^A-Za-z0-9_-]", "", str(data.get("session_id") or ""))[:128] or "unknown"
    return os.path.join(RUN_DIR, sid)


def resolve(path, data):
    path = os.path.expanduser(path)
    if not os.path.isabs(path):
        path = os.path.join(data.get("cwd") or os.getcwd(), path)
    return os.path.realpath(path)


def gate():
    data = read_input()
    cfg = load_config()
    if not cfg or not cfg.get("voice_file") or not cfg.get("guarded_paths"):
        return 0
    ti = data.get("tool_input") or {}
    target = ti.get("file_path") or ti.get("notebook_path") or ""
    if not target:
        return 0
    target = resolve(target, data)
    voice = resolve(cfg["voice_file"], data)
    if target == voice or matches(target, cfg.get("ignore_paths")):
        return 0
    if not matches(target, cfg["guarded_paths"]):
        return 0
    if os.path.exists(session_file(data)):
        return 0
    if os.path.exists(voice):
        how = f"Read your voice file first, then repeat this write:\n  {voice}"
    else:
        how = (f"Your voice file does not exist yet:\n  {voice}\n"
               "Create it from voice.example.md (writing the voice file itself is always allowed), then Read it.")
    reason = (
        "VOICE GATE: this is a copy surface, and your voice has not been loaded in this session.\n"
        f"  {target}\n\n{how}\n\n"
        "Then, before drafting: write in the voice, use the words it uses, never the words it bans.\n"
        + (cfg.get("message") or "")
    ).rstrip()
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}))
    return 0


def sentinel():
    data = read_input()
    cfg = load_config()
    if not cfg or not cfg.get("voice_file"):
        return 0
    ti = data.get("tool_input") or {}
    if not ti.get("file_path"):
        return 0
    if resolve(ti["file_path"], data) != resolve(cfg["voice_file"], data):
        return 0
    try:
        os.makedirs(RUN_DIR, exist_ok=True)
        with open(session_file(data), "a", encoding="utf-8") as fh:
            fh.write(time.strftime("%Y-%m-%dT%H:%M:%S") + " voice file read\n")
        cutoff = time.time() - 2 * 86400
        for name in os.listdir(RUN_DIR):
            p = os.path.join(RUN_DIR, name)
            if os.path.isfile(p) and os.path.getmtime(p) < cutoff:
                os.remove(p)
    except OSError as err:
        print(f"voice-sentinel: could not record the read: {err}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    sys.exit(gate() if mode == "gate" else sentinel() if mode == "sentinel" else 0)
