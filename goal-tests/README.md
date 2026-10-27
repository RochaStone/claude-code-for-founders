# Goal tests

**Everything you shipped, checked every morning. You only hear about it when something changes.**

You built a page in March. It worked. Somewhere in June it stopped, and nobody told you.
Goal tests fix that. Each thing you ship gets one tiny check. Every morning a quiet sweep runs all of them.
When something breaks, you get one notice, with what changed since it last worked.
When it is still broken tomorrow, you get nothing. When it is fixed, you get one line saying so.
No alert fatigue. No daily noise. Silence means it all still works.

Runs on: a Mac or Linux computer with Python 3. Not Cowork (it needs a daily schedule on your machine).

## Start here
Every step below happens in the **terminal**: the app where you type instructions to your computer. On a Mac, press Cmd and Space together, type Terminal, and press Return. A window with a blinking cursor opens. That is it.
A **command** is one line you type (or paste) into the terminal, then press Return.
If you haven't downloaded the kit yet, start with the root README's Start here. It takes about two minutes.
A **probe** is one tiny check, like "my home page still loads". A **schedule** runs something at a set time every day: on a Mac that is **launchd**, on Linux it is **cron**. You never have to touch either. The installer sets it up.

1. Go to the kit's folder. `cd` means "change folder", and `~` means your home folder.
   ```sh
   cd ~/.claude/skills/claude-code-for-founders
   ```
   You will see nothing at all, and that means it worked.
2. Install goal tests and schedule the morning check for 8am.
   ```sh
   ./goal-tests/install.sh
   ```
   You will see `daily sweep scheduled at 08:00` and a short Next list.
3. Copy your first probe into place. This one checks a web page loads.
   ```sh
   cp ~/.claude/goal-tests/examples/site-is-up.sh ~/.claude/goal-tests/goals/
   ```
   You will see nothing, which means it copied. Open that copied file in any text editor and change `https://example.com/` to your own website.
4. Run your first check now, instead of waiting for the morning.
   ```sh
   bash ~/.claude/goal-tests/goals-runner.sh
   ```
   You will see `PASS site-is-up: OK 200`. Your website is officially being looked after.

## Install
```sh
./goal-tests/install.sh                 # daily at 08:00
./goal-tests/install.sh --time 07:30    # pick your time
```
It installs to `~/.claude/goal-tests/` and schedules the sweep (launchd on a Mac, which catches up after the laptop wakes, or one crontab line on Linux).
Then copy an example into `~/.claude/goal-tests/goals/`, change its URL, and run one sweep by hand:
```sh
bash ~/.claude/goal-tests/goals-runner.sh
```

## A probe
Three examples ship in `examples/`:
- `site-is-up.sh`: the home page answers.
- `form-endpoint-answers.sh`: the endpoint behind your form is still there. It never submits the form.
- `page-still-says.sh`: the page still shows the words that matter, like your button text and your price.

Every probe follows [the contract](CONTRACT.md): a `# GOAL:` line, a `# BUILD:` line, exit 0 when it works.
**Probes are read-only.** They look. They never deploy, push, send or buy.
Ask Claude to write the next one: "write a goal test probe that checks my booking page still shows Friday slots."

## How you hear about it
Set the channels in `~/.claude/goal-tests/goal-tests.config.json`:

| Channel | What it does | Needs |
|---|---|---|
| `stdout` | prints the notice into the job's log file | nothing |
| `macos` | a Notification Centre banner | a Mac |
| `webhook` | posts the notice to Slack, Discord, Zapier, Make or n8n | a webhook URL |
| `smtp` | emails you, using Python's own mail library | your mail server details |

Secrets (the webhook URL, the mail password) go in `~/.claude/goal-tests/secrets.env`, never in the config.
Lock it: `chmod 600 ~/.claude/goal-tests/secrets.env`. The runner refuses an env file other people can read.

## What a notice looks like
```text
Goal tests: BROKEN: offer-page

Something that used to work has stopped.

BROKEN
- offer-page (exit 1): FAIL: page no longer says "Book a call"
  goal: my offer page still shows the words that matter
  what changed since it last passed:
    last passed: 2026-10-24 08:00:03
    commits in my-website since then:
        3f2a9c1 new hero section
```

## The details, for the curious
- **One clock per probe.** Each probe gets 90 seconds (`timeout_seconds`). Slower counts as broken, exit 124.
- **Offline is not broken.** Set `offline_check_url` and a sweep with no internet is skipped, not failed.
- **The ledger.** `ledger.json` keeps each probe's status, last pass, last fail, fail streak and the last 60 sweeps.
- **What changed.** For a new break, the notice lists commits since the last pass in the probe's `# BUILD:` repo and every repo in `watch_repos`, plus uncommitted changes.
- **Deleting a broken probe** removes it quietly. It is not reported as recovered.

## Uninstall
```sh
./goal-tests/install.sh --uninstall
```
This removes the daily job. Your probes, config and ledger stay in `~/.claude/goal-tests/`.

## Test it
```sh
bash goal-tests/tests/test_runner.sh
```

## If it goes wrong
This happens to everyone the first time. Here are the three most common ones.
- **You see `FAIL ... could not reach`.** Check the address in the probe has `https://` at the front and opens in your browser. If you are offline, the check waits for the wifi.
- **No banner appears on your Mac.** Open System Settings > Notifications, find Script Editor, and turn on Allow notifications.
- **The 8am check didn't happen.** Your laptop was asleep. The check runs as soon as it wakes, so nothing is missed.

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
