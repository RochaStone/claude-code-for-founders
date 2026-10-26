# Images in this repo

Every image here is generated. No photos, no real people, no screenshots of anyone's posts.

| File | What it is | Made from |
|---|---|---|
| `docs/hero.png` | Newspaper front page, "The Rocheverse Times" | `docs/hero.html`, rendered with headless Chrome at 1600x1000 |
| `pink-terminal/wallpaper.svg` | Wallpaper, "Welcome to my one woman show", scrawled "build your founder world" | hand-written SVG. Render a PNG with `pink-terminal/install.sh --wallpaper` |

To re-render the hero after editing `docs/hero.html`:
```sh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --hide-scrollbars \
  --window-size=1600,1000 --virtual-time-budget=8000 --screenshot="$PWD/docs/hero.png" "file://$PWD/docs/hero.html"
```
