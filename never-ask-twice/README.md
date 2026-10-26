# Never ask twice

**One list of everything open. Every item has a default. Silence moves things forward.**

Claude suggests something. You miss it. It is never mentioned again.
Or the same question comes back four times in one afternoon.
This piece ends both. Everything unresolved lives on one page, each item with what happens if you say nothing.
If you never answer, Claude takes the default next session and tells you in one line.
At most three flags per reply, the important ones first. "Leave it" parks anything.
Missing a question costs you nothing.

Runs on: Claude Code on your computer.

## Install
```sh
./never-ask-twice/install.sh
```
This does three things:
1. Creates `~/.claude/OPEN_ITEMS.md` from the template, only if you don't have one. The three sample items are fiction. Replace them.
2. Copies the session-start hook to `~/.claude/founders-kit/never-ask-twice/`.
3. Registers it in `~/.claude/settings.json`, after writing a backup.

Then one step by hand: paste [`CLAUDE.md.snippet`](CLAUDE.md.snippet) into `~/.claude/CLAUDE.md`.
That is the part that tells Claude the rules. The hook only makes sure it sees the list.

## What Claude sees at the start of every session
```text
=== OPEN ITEMS: 3 open, 0 parked (never ask twice) ===
#3 [CLAUDE] Pick the header colour for the spring workshop page | default: Use candy pink from the brand sheet and show me a screenshot
#2 [ME] Decide the price for the new mini course | default: Keep it in drafts, unpublished, until I name a price
#1 [CLAUDE] The newsletter footer still links the old booking page | default: Swap in the new booking link and report the diff
Protocol: do every CLAUDE item whose default is unblocked, report in one short block.
ME items: one line each, at most once this session. Max 3 flags per reply. Unanswered = take the default.
```

## The rules
Read [PROTOCOL.md](PROTOCOL.md). The short version:
- Every item carries a default.
- Unanswered means "take the default", then say so in one line.
- ME items are money, voice, positioning and anything that can't be undone. Everything else is CLAUDE's to decide and report.
- Three flags per reply, maximum.
- Items leave only as DONE or PARKED. Never by being forgotten.

## A memory index that stays readable
`templates/MEMORY.md` shows the shape that keeps a memory index useful: one line per entry, the detail in its own file, and a `READ BEFORE ...` trigger that tells Claude exactly when to open it.
Claude Code keeps its own memory folders. Use this shape for the index file in whichever one you use.

## Settings
- `OPEN_ITEMS_FILE`: use a different file. The installer bakes your path into the hook.
- `OPEN_ITEMS_MAX`: how many items to show (default 12).

## Uninstall
```sh
./never-ask-twice/install.sh --uninstall
```
Your `OPEN_ITEMS.md` stays.

## Test it
```sh
bash never-ask-twice/tests/test_never_ask_twice.sh
```

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
