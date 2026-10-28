# Voice gate

**Claude cannot write a word of your public copy until it has read how you sound.**

You wrote down how you talk. Claude forgot to look. The email went out sounding like everyone else.
The voice gate makes reading your voice file the price of writing copy.
Try to write a landing page, an email or a caption before reading it, and the write is refused with one instruction: read the voice file first.
One read opens the gate for the rest of the session. Code, configs and everything else pass straight through.

Runs on: Claude Code on your computer.

## Start here
Every step below happens in the **terminal**: the app where you type instructions to your computer. On a Mac, press Cmd and Space together, type Terminal, and press Return. A window with a blinking cursor opens. That is it.
A **command** is one line you type (or paste) into the terminal, then press Return.
If you haven't downloaded the kit yet, start with the root README's Start here. It takes about two minutes.
A **hook** is a tiny rule Claude Code runs on its own at a set moment. These two run before Claude writes a file and after it reads one. Your **settings file** is `~/.claude/settings.json`, where Claude Code keeps its preferences. The installer saves a backup of it first.

<img src="../docs/img/step-01.svg" alt="Step 1" height="22">&nbsp; Go to the kit's folder. `cd` means "change folder", and `~` means your home folder.
```sh
cd ~/.claude/skills/claude-code-for-founders
```
You will see nothing at all, and that means it worked.

<img src="../docs/img/step-02.svg" alt="Step 2" height="22">&nbsp; Install the voice gate.
```sh
./voice-gate/install.sh
```
You will see `added PreToolUse hook for Write|Edit|MultiEdit` and `added PostToolUse hook for Read`.

<img src="../docs/img/step-03.svg" alt="Step 3" height="22">&nbsp; Write your voice file. This makes a folder for it and copies in the blank template.
```sh
mkdir -p ~/brand && cp voice-gate/voice.example.md ~/brand/voice.md
```
You will see nothing, which means it worked. Open `~/brand/voice.md` and fill in the five headings in your own words. Or ask Claude: "help me fill in my voice file, ask me one question at a time".

<img src="../docs/img/step-04.svg" alt="Step 4" height="22">&nbsp; Start a new Claude Code session, then ask it to write a caption into a folder called `copy`.
*A new session: in the terminal, type `/exit` to leave Claude Code, then type `claude` and press Return to start it again. In the desktop app, open a new chat.*
You will see Claude stop, read your voice file, and then write. That pause is the gate doing its job.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Install
```sh
./voice-gate/install.sh
```
Then:
1. Write your voice file. Start from [`voice.example.md`](voice.example.md), five headings and nothing else: How I sound, Words I use, Words I never use, Sentences I'd never write, Three lines that are me.
2. Open `~/.claude/founders-kit/voice-gate/voice-gate.json`. Point `voice_file` at your file and set `guarded_paths` to where your copy lives.
3. Start a new Claude Code session.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## The config
```json
{
  "voice_file": "~/brand/voice.md",
  "guarded_paths": ["**/copy/**", "**/*.email.md", "**/landing/**", "**/newsletter/**", "**/captions/**"],
  "ignore_paths": ["**/node_modules/**", "**/*.bak"],
  "message": ""
}
```
`**` matches any folders. `*` matches anything inside one folder name.
`message` is an extra line Claude sees every time the gate closes. Use it for your one non-negotiable.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## How it works, for the curious
Two Claude Code hooks:
- `voice-gate.sh` runs before every Write, Edit and MultiEdit. If the path matches `guarded_paths` and this session has not read your voice file, it answers with a deny decision and the reason.
- `voice-sentinel.sh` runs after every Read. When the file read is your voice file, it notes that for this session in `run/`. Notes older than two days are cleaned up.

It fails open. A missing config, a broken config or odd input never blocks you. It only ever blocks one thing: copy written blind.
Writing the voice file itself is always allowed, so Claude can help you create it.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Uninstall
```sh
./voice-gate/install.sh --uninstall
```

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Test it
```sh
bash voice-gate/tests/test_voice_gate.sh
```
The test plays the hook calls Claude Code makes: a blocked write, a read of the voice file, then the same write allowed.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## If it goes wrong (everyone's first time) <img src="../docs/img/heart.svg" alt="" height="16">
This happens to everyone the first time. Here are the three most common ones.
- **Claude says "VOICE GATE" and stops.** That is the gate working. Say "read my voice file, then carry on".
- **The gate never stops anything.** Start a new session, then check `guarded_paths` in `~/.claude/founders-kit/voice-gate/voice-gate.json` matches the folders your copy lives in.
- **It says your voice file does not exist yet.** Check `voice_file` in that same config points at `~/brand/voice.md` (or wherever you saved yours).

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
