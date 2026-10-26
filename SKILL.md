---
name: claude-code-for-founders
description: "Helps a founder install, configure, test or remove any of the six Claude Code for Founders pieces: goal tests (daily checks on what they shipped), never ask twice (open items with defaults), voice gate (read the voice file before writing copy), copy gate (five pre-publish skills), standards (CLAUDE.md rules, security and quality scripts, deploy reminder) and pink terminal (status line, themes, wallpaper). Use when they ask to install, set up, turn on, configure, check or uninstall any of these."
---
# Claude Code for Founders: install helper

The person you are helping is a founder, often not an engineer. Plain words. One step at a time. Show before you change.

This folder holds six independent pieces. Each has its own `README.md` and `install.sh`. Paths below are relative to this folder (the one this SKILL.md is in).

| Piece | Folder | Install | Remove |
|---|---|---|---|
| Goal tests | `goal-tests/` | `./goal-tests/install.sh [--time HH:MM]` | `--uninstall` |
| Never ask twice | `never-ask-twice/` | `./never-ask-twice/install.sh` | `--uninstall` |
| Voice gate | `voice-gate/` | `./voice-gate/install.sh` | `--uninstall` |
| Copy gate | `copy-gate/` | `./copy-gate/install.sh [--copy]` (`--zip` for Cowork) | `--uninstall` |
| Standards | `standards/` | `./standards/install.sh <project folder>` and `--deploy-guard` | `--uninstall-deploy-guard` |
| Pink terminal | `pink-terminal/` | `./pink-terminal/install.sh [--themes]`, `--wallpaper WxH` | `--uninstall` |

## How to help
1. Ask which piece they want, if they haven't said. Recommend starting with one.
2. Read that piece's `README.md` before you act. Tell them in two or three plain sentences what it will change on their computer.
3. Run its tests first, so you both know it works on this machine: `bash <piece>/tests/test_*.sh`. The tests use throwaway folders and never touch their real settings.
4. Run the installer. Show them its output. Every installer backs up `~/.claude/settings.json` first, never overwrites their files, and is safe to run twice.
5. Do the hand-finished steps with them:
   - Never ask twice: paste `never-ask-twice/CLAUDE.md.snippet` into `~/.claude/CLAUDE.md` (show the diff first) and replace the three fictional sample items in `~/.claude/OPEN_ITEMS.md` with theirs.
   - Voice gate: help them write their voice file from `voice-gate/voice.example.md`, in their own words, then set `voice_file` and `guarded_paths` in `~/.claude/founders-kit/voice-gate/voice-gate.json`.
   - Goal tests: write their first probe with them from `goal-tests/examples/`, following `goal-tests/CONTRACT.md`, and run one sweep.
   - Copy gate: help them fill `~/.claude/canon.md` from `copy-gate/skills/claims-verify/canon.example.md`.
6. Tell them hooks and the status line start with their next Claude Code session.

## Rules
- Never run an `--uninstall`, never edit their `settings.json` by hand, and never overwrite a file of theirs without asking first.
- Goal test probes are read-only. Never write a probe that deploys, pushes, sends, submits or buys.
- Never put a key, token or password in a config file. Secrets go in `~/.claude/goal-tests/secrets.env` with `chmod 600`.
- If an installer fails, show the error, explain it in one sentence and stop. The settings backup is next to `settings.json`.
