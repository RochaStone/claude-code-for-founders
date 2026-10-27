# Make it yours: style.json

One small file holds your look: your colours, your fonts, your words.
Every Rocha Coded tool reads the same file, so you make it once and everything wears it.
Rocha's look ships as the example. Yours replaces it.

## Where the tools look
1. `./style.json` in the folder you are working in
2. `~/.rocha-coded/style.json` (one file for everything you do)
3. The bundled example, `examples/style.rocha-coded.json`

The first one found wins.
Your file only borrows colours and fonts from the bundled example: any `palette` or `fonts` key you leave blank or leave out uses Rocha's, so a half-finished file still looks finished.
Your words never come from hers. A blank `lines`, `name`, `owner`, `handle`, `references` or `notes` stays blank, and anything visible shows YOUR WORDS HERE until you fill it in.

## Start
Copy `style.example.json` to `~/.rocha-coded/style.json` and fill it in.
Or ask Claude: "make me a style.json". Give it 3 to 5 references (screenshots, links, a Pinterest board), your palette if you have one, and the words you say a lot.
It writes the file and shows you one rendered sample. Your taste is yours. Nothing assumes it is Rocha's.

## The keys
Every tool uses the same keys. A tool may ignore the ones it doesn't need. Never rename them.

| Key | What goes in it |
|---|---|
| `name` | The name of your look, like "Rocha Coded". Theme files are named after it |
| `owner` | Your name, as you sign things |
| `handle` | Your social handle |
| `site` | Your website |
| `palette.hero` | Your GROUND: the background everything sits on, like a deep plum. Not an accent |
| `palette.accent` | Your one accent: pills, highlights, a scrawl on the ground |
| `palette.paper` | Your paper, and the type colour on your ground, like cream |
| `palette.paper_pink` | A second paper tone, like blush (any colour, despite the name) |
| `palette.ink` | Your type colour on paper |
| `palette.marker` | A scrawl colour on paper, like magenta pen |
| `palette.plum` | A deep, dark tone (often the same as the ground) |
| `palette.wine` | A second dark tone, for kickers and accents on paper |
| `palette.gold` | Thin rules, numbers, a stamp |
| `palette.cool` | One rare cool tone, for pill fills only |
| `fonts.masthead` | Big titles. A Google Fonts name, like "Fraunces" |
| `fonts.label` | Small all-caps tags |
| `fonts.body` | Paragraphs |
| `fonts.scrawl` | Hand marker |
| `fonts.script` | A signature script, one accent per surface |
| `fonts.mono` | Receipts and code |
| `motif` | One of: `guest-check`, `front-page`, `magazine-scrawl`, `pink-paper`, `sticker-collage`, `rotary`, `leopard`, `retro-tv`, `neutral` |
| `lines.masthead` | Your publication name, for front pages and covers |
| `lines.headline` | Your big line |
| `lines.scrawl` | A short handwritten line |
| `lines.todo` | A to-do list title |
| `lines.stamp` | One short word for stamps and badges |
| `lines.celebrate` | What you say when something goes right |
| `lines.affirm` | Your affirmation |
| `lines.invite` | Optional: invitation card text, lines split by " / " |
| `lines.magazine` | Optional: a magazine cover title |
| `references` | Images (paths next to the file) or links Claude looks at when making things in your style |
| `notes` | Your look in a sentence or two |

Colours are hex: `#50163C`. Fonts are Google Fonts names. If a font isn't on Google Fonts, tools fall back to the next font in their stack and say so.

## In this kit
Only pink-terminal is visual. It reads:
- `palette` for the status line colours, the three terminal themes and the wallpaper (`hero` is the ground, `paper` the type, `accent` the open-items chip, `gold` the stamp and rules),
- `lines.stamp` for the badge at the end of the status line and the stamp on the wallpaper,
- `lines.headline` and `lines.scrawl` for the wallpaper text.

To test a style file without moving it, set `ROCHA_CODED_STYLE=/path/to/style.json`.
