# Claude Code for Founders

*Free tools from the Rocheverse.* Part of the **Rocha Coded** collection.

![The Rocheverse Times: What if your founder world works out?](docs/hero.png)

**Claude Code, made safe for founders.**

You build with it. What you shipped keeps working, and you hear about it the morning it doesn't.
It never asks you the same question twice.
It never writes in a voice that isn't yours.
It never ships a claim you can't stand behind, and never pushes anything you didn't say yes to.
And it looks good doing it.

Six small pieces. Take one. Take all six. Each one installs on its own and comes out again just as cleanly.

## The six pieces

| Piece | What you get | Installs |
|---|---|---|
| [Goal tests](goal-tests/) | Everything you shipped, checked every morning. One notice when something breaks, with what changed. Silence when nothing did. | a daily job on your computer |
| [Never ask twice](never-ask-twice/) | One list of everything open, each item with a default. Unanswered questions get the default, not a second ask. | a session-start hook |
| [Voice gate](voice-gate/) | Claude can't write your public copy until it has read how you sound. | two hooks |
| [Copy gate](copy-gate/) | Interview, draft, humanize, fact-check, verify. Five skills between a draft and the internet. | five skills |
| [Standards](standards/) | The house rules an engineer would insist on, plus the scripts that check them before anything leaves your computer. | files in your project, an optional hook |
| [Pink terminal](pink-terminal/) | A hot pink status line with a leopard in it, terminal themes and a wallpaper. | a status line, themes |

## Where it runs
This kit runs in **Claude Code on your computer**: the terminal or the Claude desktop app, on a Mac or Linux.
Hooks, a daily job and a status line live on your machine, so that is where they belong.
The copy-gate skills also work in **Claude Cowork** as uploaded skills.

You need Python 3, which most Macs already have. If one is missing, run `xcode-select --install`.

## Install

| Where you use it | Install it | Start it |
|---|---|---|
| [Claude Code](#claude-code) (recommended) | clone into `~/.claude/skills`, run one piece's installer | ask: "help me install the voice gate" |
| [Claude Cowork](#claude-cowork) | upload the copy-gate skill zips | ask: "interview me before you write this" |

### Claude Code
```sh
git clone https://github.com/RochaStone/claude-code-for-founders ~/.claude/skills/claude-code-for-founders
cd ~/.claude/skills/claude-code-for-founders
```
Then install the pieces you want, one at a time:
```sh
./goal-tests/install.sh
./never-ask-twice/install.sh
./voice-gate/install.sh
./copy-gate/install.sh
./standards/install.sh ~/Projects/my-app
./pink-terminal/install.sh
```
Or let Claude do it. Start Claude Code and say "help me install never ask twice". The kit's own skill walks it through, one piece at a time, showing you each change first.

To update later: `git -C ~/.claude/skills/claude-code-for-founders pull`, then re-run the installers you use.

### Claude Cowork
1. Build the skill zips: `./copy-gate/install.sh --zip`. They land in `dist/copy-gate/`.
2. In the Claude desktop app: Customize > Skills, then + > Upload a skill. Upload each zip.
3. In a Cowork task, ask: "Interview me before you write my launch email."

After the first release, you can skip building: download the five skill zips from the [latest release](https://github.com/RochaStone/claude-code-for-founders/releases/latest).

## Make it yours
One file, `style.json`, holds your colours, fonts and words. Put it in your working folder or at `~/.rocha-coded/style.json`, and the pink terminal wears your look instead of mine.
Two examples ship: `examples/style.rocha-coded.json` (my look) and `style.example.json` (blank, explained key by key in [STYLE.md](STYLE.md)).
The same file works across every Rocha Coded tool, so you make it once.

## Every installer makes the same promises
- **Backup first.** `~/.claude/settings.json` is copied to a dated backup before anything changes.
- **Never breaks your settings.** If the file isn't valid JSON, nothing is written.
- **Safe to run twice.** Running an installer again changes nothing it already did.
- **Never overwrites yours.** Your config, your lists, your skills with the same name all stay.
- **Comes out cleanly.** Every piece has `--uninstall`, and it only removes what this kit added.

## Proof it works
Every piece ships with its own tests. Run them all:
```sh
./scripts/run-tests.sh
```
They run in throwaway folders and never touch your real `~/.claude`.

## Why this exists
Each piece is a rule I set after something went wrong in my own work with Claude Code.
A page that quietly broke. A question I missed and never saw again. A paragraph that sounded like nobody.
Rules nothing enforces get skipped on a busy day. So I made them enforce themselves.
This didn't exist, so I built it.

*The future doesn't belong to founders who become more like AI. It belongs to the ones who leverage AI to amplify more fully themselves.*

## Licence
MIT. See [LICENSE](LICENSE).

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
