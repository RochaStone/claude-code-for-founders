# The probe contract

A probe is one small script that proves one thing you shipped still works.
The runner replays every probe every day and only speaks up when something changes.

## The header
Every probe starts with two lines after the shebang:

```bash
#!/usr/bin/env bash
# GOAL: <one line: what this proves still works, in words you would understand half asleep>
# BUILD: <path to the git repo behind it, or - if there is none>
```

`GOAL` is what the notice tells you is broken.
`BUILD` is where the runner looks for "what changed since it last passed".

## The exit code
- `exit 0` means it still works.
- Any other exit means it is broken.
- Taking longer than the time limit (90 seconds by default) counts as broken, exit 124.
- Print one short line either way. `OK` is enough when it passes. On a fail, say what you saw: `FAIL: page no longer says "Book a call"`.

## The rule that is not optional
**Probes are read-only.** A probe never:
- deploys, pushes, publishes or merges anything,
- sends an email, a DM, a text or a form submission,
- charges a card, creates an order, or writes to a live database,
- deletes or edits a file outside its own temp folder.

A probe looks. It never touches.
If the only way to prove something works is to make it do the thing, prove the step before it instead (the endpoint answers, the page loads, the button is there).

## Good probes are
- **Cheap.** One or two requests. Seconds, not minutes.
- **About the end state.** "The page still shows the price" beats "the build command exits 0".
- **Specific.** One thing each. Ten small probes beat one probe that checks ten things, because the notice names the broken one.
- **Quiet when green.** No output beyond the one line.

## Secrets
If a probe needs a key (for a read-only API call), put it in `secrets.env` next to the runner, `chmod 600 secrets.env`, and read it as an environment variable. Never paste a key into a probe.
