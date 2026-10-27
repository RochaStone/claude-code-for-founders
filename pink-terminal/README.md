# Pink terminal

**A plum ground, cream type, one candy pink chip, and a leopard in your status line. Or your colours, if you'd rather.**

Too busy creating my dream life.
This piece dresses Claude Code and your terminal in the current Rocha Coded look: editorial and certain, leaning dark.
Plum ground, cream type, candy pink for the one thing that matters, gold for rules and stamps.

Runs on: Claude Code on your computer (the status line), plus iTerm2, Ghostty or Warp (the themes).

## Start here
Every step below happens in the **terminal**: the app where you type instructions to your computer. On a Mac, press Cmd and Space together, type Terminal, and press Return. A window with a blinking cursor opens. That is it.
A **command** is one line you type (or paste) into the terminal, then press Return.
If you haven't downloaded the kit yet, start with the root README's Start here. It takes about two minutes.
The **status line** is the one line at the bottom of Claude Code that shows what is going on. An **environment variable** is a named setting you put in front of a command, like `NO_COLOR=1`.

1. Go to the kit's folder. `cd` means "change folder", and `~` means your home folder.
   ```sh
   cd ~/.claude/skills/claude-code-for-founders
   ```
   You will see nothing at all, and that means it worked.
2. Install the status line.
   ```sh
   ./pink-terminal/install.sh
   ```
   You will see `status line set`.
3. Copy the terminal themes into place too.
   ```sh
   ./pink-terminal/install.sh --themes
   ```
   You will see one line each for Ghostty, Warp and iTerm2, telling you where to pick the theme.
4. Start a new Claude Code session.
   *A new session: in the terminal, type `/exit` to leave Claude Code, then type `claude` and press Return to start it again. In the desktop app, open a new chat.*
   You will see a plum line with a leopard at the bottom, and a candy pink chip when you have open items.

## The status line
```text
🐆 Opus · ctx 42% · $0.42 · LORE   3 open
```
Model, how full the conversation is, what this session has cost and your stamp word, in cream on plum.
How many open items are waiting (from the never-ask-twice list) sits in its own candy pink chip, so it is the first thing you see.
Each part only appears when Claude Code sends it. Past 80% context the line turns gold, so you know to wrap up.

```sh
./pink-terminal/install.sh
```
Your settings are backed up first. A status line you already had is replaced, and kept in the backup.

Options:
- `NO_COLOR=1` prints it plain.
- `PINK_TERMINAL_ASCII=1` swaps the leopard emoji for `=^.^=` in terminals that can't show emoji.

## Make it yours
Everything here reads your `style.json` (see [STYLE.md](../STYLE.md)): the status line colours and stamp, the themes and the wallpaper.
With no style.json, you get Rocha's look from `examples/style.rocha-coded.json`.
Make your own terminal themes from your file:
```sh
python3 pink-terminal/themes/make-themes.py --style ~/.rocha-coded/style.json --out ~/Desktop
```
The three themes shipped here are that generator's output for Rocha's style.

## The themes
```sh
./pink-terminal/install.sh --themes
```
| Terminal | File | To use it |
|---|---|---|
| iTerm2 | `themes/rocha-coded.itermcolors` | Double-click it, then Settings > Profiles > Colors > Color Presets > rocha-coded |
| Ghostty | `themes/rocha-coded.ghostty` | The installer copies it to `~/.config/ghostty/themes/rocha-coded`. Add `theme = rocha-coded` to your Ghostty config |
| Warp | `themes/rocha-coded.yaml` | The installer copies it to `~/.warp/themes/`. Pick Rocha Coded in Settings > Appearance > Themes |

Plum background, cream text, a candy pink cursor, wine selection. The accents are candy pink, gold, lilac and mint, with wine for red. Every accent is lifted until it reads on plum, so error text is never invisible.

## The wallpaper
`wallpaper.svg`: a plum ground, WHAT IF YOUR FOUNDER WORLD WORKS OUT? in Fraunces 900 cream, "build your founder world" in candy pink marker, a gold LORE stamp and thin gold rules.
It is generated from Rocha's style by `make-wallpaper.py`. Yours uses your headline, scrawl, stamp and palette.
Render it at your screen size (needs Google Chrome). The installer builds it from your style.json first:
```sh
./pink-terminal/install.sh --wallpaper 2560x1600
```
It saves to `~/Pictures/one-woman-show.png`. Set it in System Settings > Wallpaper.

## Uninstall
```sh
./pink-terminal/install.sh --uninstall
```

## Test it
```sh
bash pink-terminal/tests/test_pink_terminal.sh
```

## If it goes wrong
This happens to everyone the first time. Here are the three most common ones.
- **The leopard shows as a box.** Your terminal can't draw emoji. Reinstall with `PINK_TERMINAL_ASCII=1 ./pink-terminal/install.sh` and it becomes `=^.^=`.
- **The colours look blocky or wrong.** Older versions of the Mac's built-in Terminal can't show these colours. iTerm2, Ghostty and Warp all can, and all three are free.
- **The wallpaper says it needs Google Chrome.** Chrome draws the picture. Install it, or open `wallpaper.svg` in any browser and take a screenshot.

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
