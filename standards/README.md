# Standards

**The house rules that keep a founder's code safe, written down once so Claude follows them every time.**

You are not an engineer. You don't need to be.
You need the rules an engineer would insist on, in a file Claude reads at the start of every session, and two scripts that check the work before anything leaves your computer.

Runs on: Claude Code on your computer. The scripts run anywhere with bash.

## Start here
Every step below happens in the **terminal**: the app where you type instructions to your computer. On a Mac, press Cmd and Space together, type Terminal, and press Return. A window with a blinking cursor opens. That is it.
A **command** is one line you type (or paste) into the terminal, then press Return.
If you haven't downloaded the kit yet, start with the root README's Start here. It takes about two minutes.
To **deploy** means putting your work live on the internet. To **push** means sending your code to GitHub. An **API key** is a password one service gives another, and it must never be written inside your code.

<img src="../docs/img/step-01.svg" alt="Step 1" height="22">&nbsp; Go to the kit's folder. `cd` means "change folder", and `~` means your home folder.
```sh
cd ~/.claude/skills/claude-code-for-founders
```
You will see nothing at all, and that means it worked.

<img src="../docs/img/step-02.svg" alt="Step 2" height="22">&nbsp; Add the house rules and the two check scripts to your project. Change `~/Projects/my-app` to your project's folder. Tip: type the start of the command, then drag your project folder into the terminal window and its address appears.
```sh
./standards/install.sh ~/Projects/my-app
```
You will see `added:` three times, once for each file.

<img src="../docs/img/step-03.svg" alt="Step 3" height="22">&nbsp; Run the security check in your project.
```sh
cd ~/Projects/my-app && ./scripts/security-check.sh
```
You will see a list of ticks and `SECURITY CHECK PASSED`. If something shows a cross, the line under it says what to fix.

<img src="../docs/img/step-04.svg" alt="Step 4" height="22">&nbsp; Turn on the deploy reminder, so Claude checks with you before anything goes live.
```sh
~/.claude/skills/claude-code-for-founders/standards/install.sh --deploy-guard
```
You will see `Deploy guard on.` It starts with your next Claude Code session.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## What you get
| File | What it does |
|---|---|
| `CLAUDE.md.template` | The rules: security first, safe versions, forbidden patterns, script names, what to do when something breaks, what "done" means, memory rules |
| `security-check.sh.template` | Run before every commit and push. Blocks live keys, tracked env files, key files, swallowed errors, risky dependencies |
| `verify-quality.sh.template` | Run before calling anything done. Checks scripts parse, JSON is valid, your project's own lint and tests pass, no stray console.log |
| `deploy-guard.sh` | A reminder Claude sees right before any deploy or push. Never blocks |

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Install into a project
```sh
./standards/install.sh ~/Projects/my-app
```
It adds `CLAUDE.md`, `scripts/security-check.sh` and `scripts/verify-quality.sh`.
It never overwrites. If the project already has a CLAUDE.md, the template lands beside it as `CLAUDE.standards.md`. Ask Claude to merge the two.

For rules that apply to every project, ask Claude: "merge the security, quality failure protocol and memory sections of standards/CLAUDE.md.template into my ~/.claude/CLAUDE.md."

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Turn on the deploy guard
```sh
./standards/install.sh --deploy-guard
```
Before any `git push`, `vercel --prod`, `netlify deploy`, `firebase deploy`, `npm publish` and friends, Claude sees a four-line checklist: did the human say yes in this session, run the security check, name the destination, prove it worked with the live result.
It adds context. It never stops a command.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## The quality failure protocol
When something breaks: stop, rewind (in Claude Code, `/rewind` or Esc twice), log it in `QUALITY_ISSUES.md`, add a rule so it can't happen the same way twice, then restart from the clean point.
Patching forward on top of a broken step is how one bug becomes five.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## A note on versions
The safe-versions table was right when it was written. Versions go stale. Check current security advisories before you rely on it.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Uninstall
```sh
./standards/install.sh --uninstall-deploy-guard
```
The files it added to your project are yours. Delete them by hand if you want them gone.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Test it
```sh
bash standards/tests/test_standards.sh
```
The test plants a fake key, a tracked env file, an empty catch block and a syntax error in a throwaway repo and checks each one is caught.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## If it goes wrong (everyone's first time) <img src="../docs/img/heart.svg" alt="" height="16">
This happens to everyone the first time. Here are the three most common ones.
- **It says `not a folder`.** The project address has a typo. Drag the folder into the terminal window instead of typing it.
- **The security check says `key or token shapes found`.** A password-like key is sitting in your code. Ask Claude: "move this key into a .env file and show me what to rotate". Then change the key with the service it came from.
- **It says `kept yours`.** You already had that file, so it was left exactly as it was. Nothing is lost.

[Sign my guestbook](https://github.com/RochaStone/claude-code-for-founders/issues) ✧ say hello, ask a question, or tell me what you built.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Made by Rocha

Rocha \
Brand Alchemist & AI Architect \
Author of *Brand Alchemy in the Thriving Era* \
Creator of [Conscious Founder Operating System](https://founders.thrivingera.com) \
Founder, [Thriving Era Studio](https://thrivingera.com)

I help female founders build their founder world, and I build what they need next. \
Start with the audit: [thrivingera.com/audit](https://thrivingera.com/audit). \
Or book an exploratory call: [calendly.com/rochelle-thrivingera/exploratory-call](https://calendly.com/rochelle-thrivingera/exploratory-call). It is where we decide if we work together.

[Instagram @rocheverse](https://instagram.com/rocheverse) · [Substack](https://rochastone.substack.com) · [LinkedIn](https://www.linkedin.com/in/rochellelivingstonecosmic) · [More free tools](https://thrivingera.com/free) · [All tools on GitHub](https://github.com/RochaStone)
