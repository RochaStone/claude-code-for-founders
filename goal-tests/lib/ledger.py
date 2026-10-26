#!/usr/bin/env python3
"""Config reader and ledger keeper for goals-runner.sh.

  ledger.py config  CONFIG_PATH GT_HOME          -> prints shell variable lines (safely quoted)
  ledger.py update  CONFIG_PATH LEDGER RESULTS OUTDIR
        RESULTS is a tab separated file: name, rc, goal, build, output (one line per probe).
        Updates LEDGER. If the failing set changed, writes OUTDIR/subject.txt and OUTDIR/body.txt
        and prints CHANGED. Otherwise prints SAME.
  ledger.py skip    LEDGER REASON               -> records a skipped sweep (offline), touches nothing else
  ledger.py channels CONFIG_PATH                 -> prints one notify channel per line
"""
import json
import os
import shlex
import subprocess
import sys
from datetime import datetime

DEFAULTS = {
    "goals_dir": "goals",
    "timeout_seconds": 90,
    "watch_repos": [],
    "offline_check_url": "",
    "env_file": "secrets.env",
    "ledger_file": "ledger.json",
    "log_file": "goal-tests.log",
    "notify": {"channels": ["stdout"]},
}


def now():
    return datetime.now().strftime("%Y-%m-%dT%H:%M:%S")


def expand(path, base):
    path = os.path.expanduser(os.path.expandvars(str(path)))
    return path if os.path.isabs(path) else os.path.join(base, path)


def read_config(path):
    cfg = json.loads(json.dumps(DEFAULTS))
    if path and os.path.exists(path):
        with open(path, encoding="utf-8") as fh:
            user = json.load(fh)
        cfg.update({k: v for k, v in user.items() if not k.startswith("_")})
    return cfg


def cmd_config(config_path, gt_home):
    cfg = read_config(config_path)
    out = {
        "GOALS_DIR": expand(cfg["goals_dir"], gt_home),
        "DEADLINE": str(int(cfg["timeout_seconds"])),
        "OFFLINE_URL": cfg.get("offline_check_url") or "",
        "ENV_FILE": expand(cfg["env_file"], gt_home) if cfg.get("env_file") else "",
        "LEDGER": expand(cfg["ledger_file"], gt_home),
        "LOG": expand(cfg["log_file"], gt_home),
    }
    for k, v in out.items():
        print(f"{k}={shlex.quote(v)}")


def cmd_channels(config_path):
    cfg = read_config(config_path)
    for ch in cfg.get("notify", {}).get("channels", ["stdout"]):
        print(ch)


def load_ledger(path):
    if os.path.exists(path):
        try:
            with open(path, encoding="utf-8") as fh:
                return json.load(fh)
        except (json.JSONDecodeError, OSError) as err:
            print(f"ledger unreadable, starting fresh: {err}", file=sys.stderr)
    return {"version": 1, "failing": [], "probes": {}, "runs": []}


def save_ledger(path, data):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)
        fh.write("\n")
    os.replace(tmp, path)


def git(repo, *args):
    try:
        res = subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True, timeout=20)
        return res.stdout.strip() if res.returncode == 0 else ""
    except (OSError, subprocess.TimeoutExpired):
        return ""


def what_changed(probe, cfg, gt_home):
    last_pass = probe.get("last_pass")
    if not last_pass:
        return ["no previous pass recorded (new probe), so there is nothing to compare against"]
    lines = [f"last passed: {last_pass.replace('T', ' ')}"]
    repos = []
    build = probe.get("build", "")
    if build and build != "-":
        repos.append(expand(build, gt_home))
    repos += [expand(r, gt_home) for r in cfg.get("watch_repos", [])]
    seen = set()
    any_commits = False
    for repo in repos:
        if repo in seen or not os.path.isdir(os.path.join(repo, ".git")):
            continue
        seen.add(repo)
        commits = git(repo, "log", "--oneline", f"--since={last_pass}", "-n", "15")
        name = os.path.basename(repo.rstrip("/"))
        if commits:
            any_commits = True
            lines.append(f"commits in {name} since then:")
            lines += ["    " + c for c in commits.splitlines()]
        dirty = git(repo, "status", "--porcelain")
        if dirty:
            lines.append(f"uncommitted changes in {name}:")
            lines += ["    " + d for d in dirty.splitlines()[:5]]
    if seen and not any_commits:
        lines.append("no commits in the watched repos since then. Look outside the code: hosting, DNS, a renewed key, an outside service.")
    if not seen:
        lines.append("no git repo configured for this probe (add one with # BUILD: or watch_repos)")
    return lines


def cmd_update(config_path, ledger_path, results_path, outdir):
    cfg = read_config(config_path)
    gt_home = os.path.dirname(os.path.abspath(ledger_path))
    ledger = load_ledger(ledger_path)
    prev_failing = set(ledger.get("failing", []))
    probes = ledger.setdefault("probes", {})
    stamp = now()
    seen, report, passed, failed = set(), [], 0, 0
    with open(results_path, encoding="utf-8") as fh:
        for raw in fh:
            parts = raw.rstrip("\n").split("\t")
            if len(parts) < 5:
                continue
            name, rc, goal, build, output = parts[0], int(parts[1]), parts[2], parts[3], parts[4]
            seen.add(name)
            p = probes.setdefault(name, {})
            p.update({"goal": goal, "build": build, "rc": rc, "last_output": output, "last_run": stamp})
            if rc == 0:
                passed += 1
                p.update({"status": "pass", "last_pass": stamp, "fail_streak": 0})
                report.append(f"PASS {name}: {output}")
            else:
                failed += 1
                p.update({"status": "fail", "last_fail": stamp, "fail_streak": p.get("fail_streak", 0) + 1})
                report.append(f"FAIL {name} (exit {rc}): {output}")
    for gone in [n for n in probes if n not in seen]:
        del probes[gone]
    curr_failing = sorted(n for n in seen if probes[n]["status"] == "fail")
    new_fails = [n for n in curr_failing if n not in prev_failing]
    recovered = sorted(n for n in prev_failing if n in seen and n not in curr_failing)
    ledger["failing"] = curr_failing
    ledger["last_run"] = stamp
    changed = bool(new_fails or recovered)
    ledger.setdefault("runs", []).append({"at": stamp, "passed": passed, "failed": failed, "notified": changed})
    ledger["runs"] = ledger["runs"][-60:]

    if changed:
        os.makedirs(outdir, exist_ok=True)
        if new_fails:
            more = f" (+{len(new_fails) - 1} more)" if len(new_fails) > 1 else ""
            subject = f"Goal tests: BROKEN: {new_fails[0]}{more}"
        else:
            subject = f"Goal tests: recovered: {', '.join(recovered)}"
        body = []
        if new_fails:
            body += ["Something that used to work has stopped.", "", "BROKEN"]
            for n in new_fails:
                p = probes[n]
                body.append(f"- {n} (exit {p['rc']}): {p['last_output']}")
                body.append(f"  goal: {p['goal']}")
                body.append("  what changed since it last passed:")
                body += ["    " + line for line in what_changed(p, cfg, gt_home)]
            body.append("")
        if recovered:
            body += ["RECOVERED"] + [f"- {n}" for n in recovered] + [""]
        body += ["Full sweep"] + report + ["",
                 "A break that persists is not sent again every day. It stays in ledger.json until it is fixed."]
        with open(os.path.join(outdir, "subject.txt"), "w", encoding="utf-8") as fh:
            fh.write(subject + "\n")
        with open(os.path.join(outdir, "body.txt"), "w", encoding="utf-8") as fh:
            fh.write("\n".join(body) + "\n")
    # The ledger only moves after the notice files exist, so a crash never swallows a change.
    save_ledger(ledger_path, ledger)
    print("CHANGED" if changed else "SAME")


def cmd_skip(ledger_path, reason):
    ledger = load_ledger(ledger_path)
    ledger["last_skipped"] = {"at": now(), "reason": reason}
    save_ledger(ledger_path, ledger)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    cmd = argv[1]
    if cmd == "config" and len(argv) == 4:
        cmd_config(argv[2], argv[3])
    elif cmd == "update" and len(argv) == 6:
        cmd_update(*argv[2:6])
    elif cmd == "skip" and len(argv) == 4:
        cmd_skip(argv[2], argv[3])
    elif cmd == "channels" and len(argv) == 3:
        cmd_channels(argv[2])
    else:
        print(__doc__)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
