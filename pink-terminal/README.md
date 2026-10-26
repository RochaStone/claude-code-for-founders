# Pink terminal

**Hot pink paper, ink type, and a leopard in your status line.**

Too busy creating my dream life.
This piece dresses Claude Code and your terminal in the Rocha Coded palette: hot pink, candy pink, pale pink paper, ink, marker red, plum and a little gold.

Runs on: Claude Code on your computer (the status line), plus iTerm2, Ghostty or Warp (the themes).

## The status line
```text
🐆  Opus · ctx 42% · $0.42 · 3 open ♡
```
Model, how full the conversation is, what this session has cost, and how many open items are waiting (from the never-ask-twice list).
Each part only appears when Claude Code sends it. Past 80% context the text turns marker red, so you know to wrap up.

```sh
./pink-terminal/install.sh
```
Your settings are backed up first. A status line you already had is replaced, and kept in the backup.

Options:
- `NO_COLOR=1` prints it plain.
- `PINK_TERMINAL_ASCII=1` swaps the leopard emoji for `=^.^=` in terminals that can't show emoji.

## The themes
```sh
./pink-terminal/install.sh --themes
```
| Terminal | File | To use it |
|---|---|---|
| iTerm2 | `themes/rocha-coded.itermcolors` | Double-click it, then Settings > Profiles > Colors > Color Presets > rocha-coded |
| Ghostty | `themes/rocha-coded.ghostty` | The installer copies it to `~/.config/ghostty/themes/rocha-coded`. Add `theme = rocha-coded` to your Ghostty config |
| Warp | `themes/rocha-coded.yaml` | The installer copies it to `~/.warp/themes/`. Pick Rocha Coded in Settings > Appearance > Themes |

Pale pink paper background, ink text, a hot pink cursor, candy pink selection. All sixteen colours are tuned to read on pink.

## The wallpaper
`wallpaper.svg`: hot pink paper, WELCOME TO MY ONE WOMAN SHOW in a Didone, "build your founder world" in red marker, gold sparkles.
Render it at your screen size (needs Google Chrome):
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
