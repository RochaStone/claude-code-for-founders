#!/usr/bin/env python3
"""Safely add or remove hooks and the status line in a Claude Code settings.json.

Every install script in this kit goes through this one file, so the rules are the same everywhere:
  1. A timestamped backup is written before anything changes.
  2. If the file is not valid JSON, nothing is written and the script exits 2.
  3. Running the same install twice changes nothing (idempotent).
  4. The new file is written to a temp file and moved into place, so a crash never leaves half a file.

Usage:
  claude-settings-merge.py add-hook        --settings F --event PreToolUse --matcher "Write|Edit" --command CMD [--timeout 10]
  claude-settings-merge.py remove-hook     --settings F --contains TEXT
  claude-settings-merge.py set-statusline  --settings F --command CMD
  claude-settings-merge.py remove-statusline --settings F --contains TEXT
"""
import argparse
import json
import os
import shutil
import sys
import tempfile
import time


def load(path):
    if not os.path.exists(path):
        return {}
    with open(path, encoding="utf-8") as fh:
        raw = fh.read()
    if not raw.strip():
        return {}
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as err:
        print(f"settings file is not valid JSON, nothing changed: {path} ({err})", file=sys.stderr)
        sys.exit(2)
    if not isinstance(data, dict):
        print(f"settings file is not a JSON object, nothing changed: {path}", file=sys.stderr)
        sys.exit(2)
    return data


def save(path, data):
    folder = os.path.dirname(os.path.abspath(path))
    os.makedirs(folder, exist_ok=True)
    if os.path.exists(path):
        backup = f"{path}.backup-{time.strftime('%Y%m%d-%H%M%S')}"
        n = 1
        while os.path.exists(backup):
            backup = f"{path}.backup-{time.strftime('%Y%m%d-%H%M%S')}-{n}"
            n += 1
        shutil.copy2(path, backup)
        print(f"backup written: {backup}")
    fd, tmp = tempfile.mkstemp(dir=folder, prefix=".settings-", suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)
        fh.write("\n")
    os.replace(tmp, path)


def add_hook(args):
    data = load(args.settings)
    hooks = data.setdefault("hooks", {})
    if not isinstance(hooks, dict):
        print("settings.hooks is not an object, nothing changed", file=sys.stderr)
        sys.exit(2)
    groups = hooks.setdefault(args.event, [])
    for group in groups:
        for h in group.get("hooks", []):
            if h.get("command") == args.command:
                print(f"already installed: {args.event} hook")
                return
    entry = {"type": "command", "command": args.command}
    if args.timeout:
        entry["timeout"] = args.timeout
    group = {"hooks": [entry]}
    if args.matcher:
        group["matcher"] = args.matcher
    groups.append(group)
    save(args.settings, data)
    print(f"added {args.event} hook" + (f" for {args.matcher}" if args.matcher else ""))


def remove_hook(args):
    data = load(args.settings)
    hooks = data.get("hooks", {})
    removed = 0
    for event in list(hooks.keys()):
        kept_groups = []
        for group in hooks[event]:
            inner = [h for h in group.get("hooks", []) if args.contains not in h.get("command", "")]
            removed += len(group.get("hooks", [])) - len(inner)
            if inner:
                group["hooks"] = inner
                kept_groups.append(group)
        if kept_groups:
            hooks[event] = kept_groups
        else:
            del hooks[event]
    if not removed:
        print("nothing to remove")
        return
    if not hooks:
        data.pop("hooks", None)
    save(args.settings, data)
    print(f"removed {removed} hook(s)")


def set_statusline(args):
    data = load(args.settings)
    current = data.get("statusLine")
    if isinstance(current, dict) and current.get("command") == args.command:
        print("already installed: status line")
        return
    if current:
        print(f"replacing your previous status line (kept in the backup): {json.dumps(current)}")
    data["statusLine"] = {"type": "command", "command": args.command, "padding": 0}
    save(args.settings, data)
    print("status line set")


def remove_statusline(args):
    data = load(args.settings)
    current = data.get("statusLine")
    if isinstance(current, dict) and args.contains in current.get("command", ""):
        del data["statusLine"]
        save(args.settings, data)
        print("status line removed")
    else:
        print("nothing to remove")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="action", required=True)
    a = sub.add_parser("add-hook")
    a.add_argument("--settings", required=True)
    a.add_argument("--event", required=True)
    a.add_argument("--matcher", default="")
    a.add_argument("--command", required=True)
    a.add_argument("--timeout", type=int, default=0)
    r = sub.add_parser("remove-hook")
    r.add_argument("--settings", required=True)
    r.add_argument("--contains", required=True)
    s = sub.add_parser("set-statusline")
    s.add_argument("--settings", required=True)
    s.add_argument("--command", required=True)
    rs = sub.add_parser("remove-statusline")
    rs.add_argument("--settings", required=True)
    rs.add_argument("--contains", required=True)
    args = p.parse_args()
    {"add-hook": add_hook, "remove-hook": remove_hook,
     "set-statusline": set_statusline, "remove-statusline": remove_statusline}[args.action](args)


if __name__ == "__main__":
    main()
