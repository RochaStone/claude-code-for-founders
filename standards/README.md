# Standards

**The house rules that keep a founder's code safe, written down once so Claude follows them every time.**

You are not an engineer. You don't need to be.
You need the rules an engineer would insist on, in a file Claude reads at the start of every session, and two scripts that check the work before anything leaves your computer.

Runs on: Claude Code on your computer. The scripts run anywhere with bash.

## What you get
| File | What it does |
|---|---|
| `CLAUDE.md.template` | The rules: security first, safe versions, forbidden patterns, script names, what to do when something breaks, what "done" means, memory rules |
| `security-check.sh.template` | Run before every commit and push. Blocks live keys, tracked env files, key files, swallowed errors, risky dependencies |
| `verify-quality.sh.template` | Run before calling anything done. Checks scripts parse, JSON is valid, your project's own lint and tests pass, no stray console.log |
| `deploy-guard.sh` | A reminder Claude sees right before any deploy or push. Never blocks |

## Install into a project
```sh
./standards/install.sh ~/Projects/my-app
```
It adds `CLAUDE.md`, `scripts/security-check.sh` and `scripts/verify-quality.sh`.
It never overwrites. If the project already has a CLAUDE.md, the template lands beside it as `CLAUDE.standards.md`. Ask Claude to merge the two.

For rules that apply to every project, ask Claude: "merge the security, quality failure protocol and memory sections of standards/CLAUDE.md.template into my ~/.claude/CLAUDE.md."

## Turn on the deploy guard
```sh
./standards/install.sh --deploy-guard
```
Before any `git push`, `vercel --prod`, `netlify deploy`, `firebase deploy`, `npm publish` and friends, Claude sees a four-line checklist: did the human say yes in this session, run the security check, name the destination, prove it worked with the live result.
It adds context. It never stops a command.

## The quality failure protocol
When something breaks: stop, rewind (in Claude Code, `/rewind` or Esc twice), log it in `QUALITY_ISSUES.md`, add a rule so it can't happen the same way twice, then restart from the clean point.
Patching forward on top of a broken step is how one bug becomes five.

## A note on versions
The safe-versions table was right when it was written. Versions go stale. Check current security advisories before you rely on it.

## Uninstall
```sh
./standards/install.sh --uninstall-deploy-guard
```
The files it added to your project are yours. Delete them by hand if you want them gone.

## Test it
```sh
bash standards/tests/test_standards.sh
```
The test plants a fake key, a tracked env file, an empty catch block and a syntax error in a throwaway repo and checks each one is caught.

## Made by Rocha

Rocha \
Brand Alchemist & AI Architect \
Author of *Brand Alchemy in the Thriving Era* \
Creator of [Conscious Founder OS](https://founders.thrivingera.com) \
Founder, [Thriving Era Studio](https://thrivingera.com)

I take female founders AI native in 7 days, and I build what they need next. \
Start with the audit: [thrivingera.com/audit](https://thrivingera.com/audit). \
Or book an exploratory call: [calendly.com/rochelle-thrivingera/exploratory-call](https://calendly.com/rochelle-thrivingera/exploratory-call). It is where we decide if we work together.

[Instagram @rocheverse](https://instagram.com/rocheverse) · [Substack](https://rochastone.substack.com) · [LinkedIn](https://www.linkedin.com/in/rochellelivingstonecosmic) · [More free tools](https://thrivingera.com/free) · [All tools on GitHub](https://github.com/RochaStone)
