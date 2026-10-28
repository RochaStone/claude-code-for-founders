# Never ask twice

**One list of everything open. Every item has a default. Silence moves things forward.**

Claude suggests something. You miss it. It is never mentioned again.
Or the same question comes back four times in one afternoon.
This piece ends both. Everything unresolved lives on one page, each item with what happens if you say nothing.
If you never answer, Claude takes the default next session and tells you in one line.
At most three flags per reply, the important ones first. "Leave it" parks anything.
Missing a question costs you nothing.

Runs on: Claude Code on your computer.

## Start here
Every step below happens in the **terminal**: the app where you type instructions to your computer. On a Mac, press Cmd and Space together, type Terminal, and press Return. A window with a blinking cursor opens. That is it.
A **command** is one line you type (or paste) into the terminal, then press Return.
If you haven't downloaded the kit yet, start with the root README's Start here. It takes about two minutes.
A **hook** is a tiny rule Claude Code runs on its own at a set moment. This one runs when a session starts. Your **settings file** is `~/.claude/settings.json`, where Claude Code keeps its preferences. The installer saves a backup of it before changing anything.

<img src="../docs/img/step-01.svg" alt="Step 1" height="22">&nbsp; Go to the kit's folder. `cd` means "change folder", and `~` means your home folder.
```sh
cd ~/.claude/skills/claude-code-for-founders
```
You will see nothing at all, and that means it worked.

<img src="../docs/img/step-02.svg" alt="Step 2" height="22">&nbsp; Install the hook and your open items list.
```sh
./never-ask-twice/install.sh
```
You will see `added SessionStart hook` and a note about the last step.

<img src="../docs/img/step-03.svg" alt="Step 3" height="22">&nbsp; Show the rules Claude will follow, so you can copy them.
```sh
cat never-ask-twice/CLAUDE.md.snippet
```
You will see a short list that starts with `## Never ask twice`. Copy it, then open `~/.claude/CLAUDE.md` in any text editor (create it if it isn't there) and paste it at the end. Or ask Claude: "add the never-ask-twice snippet to my CLAUDE.md".

<img src="../docs/img/step-04.svg" alt="Step 4" height="22">&nbsp; Start a new Claude Code session.
*A new session: in the terminal, type `/exit` to leave Claude Code, then type `claude` and press Return to start it again. In the desktop app, open a new chat.*
You will see Claude mention your open items before anything else. The three samples are made up, so swap them for your own in `~/.claude/OPEN_ITEMS.md`.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

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

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## What Claude sees at the start of every session
Your open items, in a little window, with a visitor counter that counts your sessions:
```text
+-[ open-items.txt ]---------------------------------------------------------------------[_][o][x]-+
| 3 open, 0 parked                                                                 never ask twice |
| #3 [CLAUDE] Pick the header colour for the spring... | default: Use candy pink from the brand... |
| #2 [ME] Decide the price for the new mini course | default: Keep it in drafts, unpublished, u... |
| #1 [CLAUDE] The newsletter footer still links the... | default: Swap in the new booking link ... |
| Protocol: do every CLAUDE item whose default is unblocked, report in one short block.            |
| ME items: once per session, one line each. Max 3 flags per reply. Unanswered = take the default. |
+--------------------------------------------------------------------------------------------------+
 you are visitor no. 000,042 *
```

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## The rules
Read [PROTOCOL.md](PROTOCOL.md). The short version:
- Every item carries a default.
- Unanswered means "take the default", then say so in one line.
- ME items are money, voice, positioning and anything that can't be undone. Everything else is CLAUDE's to decide and report.
- Three flags per reply, maximum.
- Items leave only as DONE or PARKED. Never by being forgotten.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## A memory index that stays readable
`templates/MEMORY.md` shows the shape that keeps a memory index useful: one line per entry, the detail in its own file, and a `READ BEFORE ...` trigger that tells Claude exactly when to open it.
Claude Code keeps its own memory folders. Use this shape for the index file in whichever one you use.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Settings
- `OPEN_ITEMS_FILE`: use a different file. The installer bakes your path into the hook.
- `OPEN_ITEMS_MAX`: how many items to show (default 12).

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Uninstall
```sh
./never-ask-twice/install.sh --uninstall
```
Your `OPEN_ITEMS.md` stays.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Test it
```sh
bash never-ask-twice/tests/test_never_ask_twice.sh
```

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## If it goes wrong (everyone's first time) <img src="../docs/img/heart.svg" alt="" height="16">
This happens to everyone the first time. Here are the three most common ones.
- **Claude doesn't mention your open items.** Hooks load when a session starts, so start a fresh one.
- **The installer says your settings file is not valid JSON.** It changed nothing, on purpose. Ask Claude: "my ~/.claude/settings.json is broken, please fix it and show me the change", then run the installer again.
- **Claude still asks the same question twice.** The rules live in the snippet. Check it is pasted into `~/.claude/CLAUDE.md`, then start a new session.

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
