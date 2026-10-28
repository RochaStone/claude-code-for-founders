# Pink terminal

**The girly terminal: a plum CRT status line with a pixel leopard, block progress and a candy cursor. Plus wallpapers in three looks. All in your colours, if you'd rather.**

Too busy creating my dream life.
This piece dresses Claude Code and your terminal in the current Rocha Coded look: editorial and certain, leaning dark.
Plum ground, cream type, candy pink for the one thing that matters, gold for rules and stamps.

Runs on: Claude Code on your computer (the status line), plus iTerm2, Ghostty or Warp (the themes).

## Start here
Every step below happens in the **terminal**: the app where you type instructions to your computer. On a Mac, press Cmd and Space together, type Terminal, and press Return. A window with a blinking cursor opens. That is it.
A **command** is one line you type (or paste) into the terminal, then press Return.
If you haven't downloaded the kit yet, start with the root README's Start here. It takes about two minutes.
The **status line** is the one line at the bottom of Claude Code that shows what is going on. An **environment variable** is a named setting you put in front of a command, like `NO_COLOR=1`.

<img src="../docs/img/step-01.svg" alt="Step 1" height="22">&nbsp; Go to the kit's folder. `cd` means "change folder", and `~` means your home folder.
```sh
cd ~/.claude/skills/claude-code-for-founders
```
You will see nothing at all, and that means it worked.

<img src="../docs/img/step-02.svg" alt="Step 2" height="22">&nbsp; Install the status line.
```sh
./pink-terminal/install.sh
```
You will see `status line set`.

<img src="../docs/img/step-03.svg" alt="Step 3" height="22">&nbsp; Copy the terminal themes into place too.
```sh
./pink-terminal/install.sh --themes
```
You will see one line each for Ghostty, Warp and iTerm2, telling you where to pick the theme.

<img src="../docs/img/step-04.svg" alt="Step 4" height="22">&nbsp; Start a new Claude Code session.
*A new session: in the terminal, type `/exit` to leave Claude Code, then type `claude` and press Return to start it again. In the desktop app, open a new chat.*
You will see a plum line with a leopard at the bottom, and a candy pink chip when you have open items.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## The status line
```text
░▒▓ ᓚᘏᗢ rocheverse:~$ Opus · ctx ████░░░░░░ 42% · $0.42 · LORE ▓▒░  [ 3 open ] █
```
A little plum screen at the bottom of Claude Code. The dithered edges give it a soft scanline feel, with no glow and no flicker.
Inside: the pixel leopard, your prompt, the model, how full the conversation is as ten blocks, what this session has cost and your stamp word.
How many open items are waiting (from the never-ask-twice list) sits in its own candy pink chip, then a candy block cursor.
Each part only appears when Claude Code sends it. Past 80% context the type turns gold, so you know to wrap up.

```sh
./pink-terminal/install.sh
```
Your settings are backed up first. A status line you already had is replaced, and kept in the backup.

Options:
- `NO_COLOR=1` prints it plain.
- `PINK_TERMINAL_GLYPH=emoji` swaps the pixel leopard `ᓚᘏᗢ` for 🐆, and `PINK_TERMINAL_ASCII=1` for `=^.^=`. Set it when you install and it is remembered.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Make it yours
Everything here reads your `style.json` (see [STYLE.md](../STYLE.md)): the status line colours and stamp, the themes and the wallpaper.
With no style.json, you get Rocha's look from `examples/style.rocha-coded.json`.
Make your own terminal themes from your file:
```sh
python3 pink-terminal/themes/make-themes.py --style ~/.rocha-coded/style.json --out ~/Desktop
```
The three themes shipped here are that generator's output for Rocha's style.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

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

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## The wallpapers
One set of words, three looks. `make-wallpaper.py` draws all three from your style.json:
- **analog**: The Rocheverse Times front page on a plum desk, with washi tape, a dateline and a stamp.
- **cyberpunk**: a plum CRT in a cyberdeck bezel with gold screws, a prompt, scanlines, a block progress bar and a candy cursor.
- **y2k-blog**: a 2003 blog window with a plum title bar, a sidebar (about me, mood, guestbook), a marquee, a hit counter and gold pixel hearts.

Your `motif` in style.json picks the look, or pass `--motif`. Your palette and fonts re-tone all three. `wallpaper.svg` is Rocha's default, analog.
Render it at your screen size (needs Google Chrome). The installer builds it from your style.json first:
```sh
./pink-terminal/install.sh --wallpaper 2560x1600 --motif y2k-blog
```
It saves to `~/Pictures/one-woman-show.png`. Set it in System Settings > Wallpaper.

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Uninstall
```sh
./pink-terminal/install.sh --uninstall
```

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## Test it
```sh
bash pink-terminal/tests/test_pink_terminal.sh
```

<img src="../docs/img/divider.svg" alt="" width="600" height="3">

## If it goes wrong (everyone's first time) <img src="../docs/img/heart.svg" alt="" height="16">
This happens to everyone the first time. Here are the three most common ones.
- **The leopard shows as a box.** Your terminal can't draw emoji. Reinstall with `PINK_TERMINAL_ASCII=1 ./pink-terminal/install.sh` and it becomes `=^.^=`.
- **The colours look blocky or wrong.** Older versions of the Mac's built-in Terminal can't show these colours. iTerm2, Ghostty and Warp all can, and all three are free.
- **The wallpaper says it needs Google Chrome.** Chrome draws the picture. Install it, or open `wallpaper.svg` in any browser and take a screenshot.

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
