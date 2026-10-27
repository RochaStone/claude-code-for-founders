# Copy gate

**Five small skills that stand between a draft and the internet.**

Nothing public goes out on a first draft. Not because the draft is bad. Because nobody checked it.
The copy gate is a pre-publish ritual you can run in one conversation:

1. **Interview me.** Claude asks you 10 to 15 sharp questions before it writes a word.
2. **Draft.** Now it writes, with your answers.
3. **Humanizer.** Strips the AI tells: the stock words, the stock phrases, the too-neat rhythm.
4. **Fact-checker.** Rates every claim against the world: true, mixed, false or unverifiable.
5. **Claims-verify.** A fresh assistant with no memory of the draft tries to prove it wrong against your own facts: your prices, what is live, your real story.

Then you decide. The gate checks. You publish.

Bonus: **prompt-master** rebuilds any prompt that keeps giving you average output.

Runs on: Claude Code on your computer, and Claude Cowork as uploaded skills.

## Start here
Every step below happens in the **terminal**: the app where you type instructions to your computer. On a Mac, press Cmd and Space together, type Terminal, and press Return. A window with a blinking cursor opens. That is it.
A **command** is one line you type (or paste) into the terminal, then press Return.
If you haven't downloaded the kit yet, start with the root README's Start here. It takes about two minutes.
A **skill** is a set of instructions Claude loads when you ask for that job. A **zip** is one compressed file that holds a whole folder.

1. Go to the kit's folder. `cd` means "change folder", and `~` means your home folder.
   ```sh
   cd ~/.claude/skills/claude-code-for-founders
   ```
   You will see nothing at all, and that means it worked.
2. Install the five skills into Claude Code.
   ```sh
   ./copy-gate/install.sh
   ```
   You will see five lines, from `installed interview-me (link)` to `installed prompt-master (link)`.
3. Start a new Claude Code session.
   *A new session: in the terminal, type `/exit` to leave Claude Code, then type `claude` and press Return to start it again. In the desktop app, open a new chat.*
   You will see your usual Claude, now with five new skills ready.
4. Try the first step of the ritual. Type this to Claude:
   "Interview me before you write my launch email."
   You will see a numbered list of questions. Answer the ones you like, and Claude takes it from there.

**Using Claude Cowork instead?** Make the five skill zips with `./copy-gate/install.sh --zip` (they appear in `dist/copy-gate/`). Upload them in the Claude desktop app (Customize > Skills > + > Upload a skill, one zip at a time), then say in a Cowork task: "Interview me before you write my launch email."

## Install in Claude Code
```sh
./copy-gate/install.sh           # links the five skills into ~/.claude/skills
./copy-gate/install.sh --copy    # or copies them, if you'd rather not keep this folder
```
If you already have a skill with the same name, it is skipped and left alone. `--force` moves yours to a backup first.

## Install in Claude Cowork
```sh
./copy-gate/install.sh --zip     # builds one zip per skill in dist/copy-gate/
```
Then in the Claude desktop app: Customize > Skills > + > Upload a skill, once per zip.

After the first release, you can skip building: download the five skill zips from the [latest release](https://github.com/RochaStone/claude-code-for-founders/releases/latest).

## Use it
Ask in plain words:
- "Interview me before you write my launch email."
- "Humanize this caption."
- "Fact check this post."
- "Run claims-verify on the sales page draft."
- "Fix this prompt with prompt-master."

Or run the whole ritual: "Interview me, draft the welcome email, then humanize, fact-check and claims-verify it."

## Your canon
Claims-verify checks your draft against one short file of facts that are true about your business today.
Copy `skills/claims-verify/canon.example.md` to `~/.claude/canon.md` and fill it in: current prices, what is live and what is not, your counts, the names you may use, your real story, the claims you never make.
Anything not in the canon is treated as unproven. That is the point.

## What's inside
| Skill | Job |
|---|---|
| `interview-me` | Questions first, work second |
| `humanizer` | Rewrites AI-sounding language so it sounds like a person |
| `fact-checker` | Rates each claim against reliable sources |
| `claims-verify` | Fresh-context check of every claim against your canon |
| `prompt-master` | Rebuilds a prompt with six levers: who, where, what, shape, avoid, bar |

## Uninstall
```sh
./copy-gate/install.sh --uninstall
```
It removes only the skills this kit installed.

## Test it
```sh
bash copy-gate/tests/test_copy_gate.sh
```

## If it goes wrong
This happens to everyone the first time. Here are the three most common ones.
- **It says `skipped humanizer: you already have a skill with that name`.** Your own skill is safe. To use this one instead, run `./copy-gate/install.sh --force`. It keeps yours as a backup.
- **Claude doesn't seem to know the skills.** Skills load when a session starts, so start a fresh one.
- **Cowork won't take the upload.** Upload the `.zip` file, not the folder, and one skill at a time.

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
