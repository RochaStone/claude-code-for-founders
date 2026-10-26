# Voice gate

**Claude cannot write a word of your public copy until it has read how you sound.**

You wrote down how you talk. Claude forgot to look. The email went out sounding like everyone else.
The voice gate makes reading your voice file the price of writing copy.
Try to write a landing page, an email or a caption before reading it, and the write is refused with one instruction: read the voice file first.
One read opens the gate for the rest of the session. Code, configs and everything else pass straight through.

Runs on: Claude Code on your computer.

## Install
```sh
./voice-gate/install.sh
```
Then:
1. Write your voice file. Start from [`voice.example.md`](voice.example.md), five headings and nothing else: How I sound, Words I use, Words I never use, Sentences I'd never write, Three lines that are me.
2. Open `~/.claude/founders-kit/voice-gate/voice-gate.json`. Point `voice_file` at your file and set `guarded_paths` to where your copy lives.
3. Start a new Claude Code session.

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

## How it works, for the curious
Two Claude Code hooks:
- `voice-gate.sh` runs before every Write, Edit and MultiEdit. If the path matches `guarded_paths` and this session has not read your voice file, it answers with a deny decision and the reason.
- `voice-sentinel.sh` runs after every Read. When the file read is your voice file, it notes that for this session in `run/`. Notes older than two days are cleaned up.

It fails open. A missing config, a broken config or odd input never blocks you. It only ever blocks one thing: copy written blind.
Writing the voice file itself is always allowed, so Claude can help you create it.

## Uninstall
```sh
./voice-gate/install.sh --uninstall
```

## Test it
```sh
bash voice-gate/tests/test_voice_gate.sh
```
The test plays the hook calls Claude Code makes: a blocked write, a read of the voice file, then the same write allowed.

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
